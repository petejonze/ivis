classdef AdaptiveTrack < handle
    %#####
    %
    %   Completely reworked version
    %
    %   Implements a simple Transformed Levitt Staircase (Levitt, 1971). To
    %   crudely mimic OOP style encapsulation, we shall use 'persistant'
    %   variables to store data, so that the main experiment loop doesn't have
    %   to provide anything except the initialisation parameters (which could
    %   be optional, but for safety and ease we will make them compulsary here,
    %   since if you don't know what parameters you want then you arguably
    %   shouldn't be running the experiment in the first place), and ongoing
    %   performance info (was the last trial right/wrong). Optionally this code
    %   can also output a figure at an ongoing basis, or upon demand. To allow
    %   for the latter performance data is saved on an ongoing basis also, and
    %   can be queried directly.
    %
    %   This function could be extended as follows:
    %       > providing alternate stopping criteria (e.g. nReversals, nTrials)
    %       > by allowing for interleaved tracks
    %       > by including 'gain' factors (for variable step sizes)
    %       > by making the leadin phase optional
    %
    %   n.b.
    %   for a more complicated staircase a toolbox has been developed, but
    %   looked a bit messy and/or OTT for this project. Details here:
    %   http://arthur.is.verweg.com/projects/staircase/
    %
    %   n.b.
    %   3down-1up targets: 79.4% correct
    %   2down-1up targets: 70.7% correct
    %
    % @Requires the following toolkits: <none>
    %
    % @Constructor Parameters:
    %
    %     	######
    %
    %
    % @Example:         aT = AdaptiveTrack(AdaptiveTrack.getDummyParams())
    %                   aT.Update(true);
    %
    % @See also:        AdaptiveTrack_example.m
    %
    % @Earliest compatible Matlab version:	v2008
    %
    % @Author:          Pete R Jones
    %
    % @Creation Date:	05/07/10
    % @Last Update:     27/03/13
    %
    % @Current Verion:  3.1.0
    % @Version History: v1.0.0	PJ 24/02/2011    Initial build.
    %                   v2.0.0	PJ 29/11/2011    Added relative deltas (e.g. for freq discrim).
    %                   v3.0.0	PJ 27/03/2013    Completely rewritten from scratch
    %                   v2.1.0	PJ 25/06/2013    Added downMod for asymmetric steps
    %
    % @Todo:            lots
    
    properties (GetAccess = 'public', SetAccess = 'private')
        % user specified parameters
        startVal
        stepSize % step size
        downMod % multiplicative constant applied to downward steps (for asymetric up/down step sizes)
        nReversals
        nUp % n wrong in a row before going up (getting easier)
        nDown % n right in a row before going down (getting harder)
        isAbsolute % otherwise multiplicative
        minVal
        maxVal
        minNTrials
        maxNTrials
        verbosity
        
        % other internal params
        deltaHistory % History vectors expand on each loop. Perhaps not ideal coding practice, but the performance hit is insigificant.
        wasCorrectHistory
        reversalsHistory
        stageHistory
        figHandles
        stageColours
        prevRevDirection = NaN
    end
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = 'public')
        
        %% == CONSTRUCTOR =================================================
        
        function obj=AdaptiveTrack(params)
            % parse inputs ------------------------------------------------
            if numel(params.nReversals) ~= numel(params.stepSize)
                error('AdaptiveTrack:InvalidInput','Number of reversal limits (%i) must match number of delta values (%i)',length(params.nReversalsLim),length(params.delta));
            end
            % auto-expand scalars
            nStages = length(params.stepSize);
            if numel(params.nUp) ~= nStages && numel(params.nUp) == 1
                params.nUp = repmat(params.nUp, 1, nStages);
            end
            if numel(params.nDown) ~= nStages && numel(params.nDown) == 1
                params.nDown = repmat(params.nDown, 1, nStages);
            end
            if numel(params.downMod) ~= nStages && numel(params.downMod) == 1
                params.downMod = repmat(params.downMod, 1, nStages);
            end
            if numel(params.isAbsolute) ~= nStages && numel(params.isAbsolute) == 1
                params.isAbsolute = repmat(params.isAbsolute, 1, nStages);
            end
            
            % set specified parameter values ------------------------------
            obj.startVal   	= params.startVal;
            obj.stepSize  	= params.stepSize;
            obj.downMod     = params.downMod; % multiplicative modified applied to downward steps (e.g. 0.5 = down steps half the size of up steps)
            obj.nReversals 	= params.nReversals;
            obj.nUp        	= params.nUp;
            obj.nDown   	= params.nDown;
            obj.isAbsolute	= params.isAbsolute;
            obj.minVal     	= params.minVal;
            obj.maxVal   	= params.maxVal;
            obj.minNTrials 	= params.minNTrials;
            obj.maxNTrials 	= params.maxNTrials;
            obj.verbosity 	= params.verbosity;
            
            % init  -------------------------------------------------------
            if obj.verbosity > 1
                obj.figHandles = obj.createPlot(obj.maxNTrials, obj.startVal, obj.minVal, obj.maxVal);
                obj.stageColours =  {'k:','r-','b-','g-','y-'}; % num2cell(colormap(hsv(nStages)),2);
            end
        end
        % Destructor
        function obj = delete(obj)
% fprintf('\n\n\n\nDELETING ADAPTIVE TRACK\n\n\n\n');            
            if ~isempty(obj.figHandles) && ~isempty(obj.figHandles.hFig) && ishandle(obj.figHandles.hFig)  
% fprintf('\n\n\n\nREMOVING FIGURE\n\n\n\n');                    
                delete(obj.figHandles.hFig);
            end
drawnow();
            obj.figHandles = [];
            clear obj;
        end
        
        %% == METHODS =====================================================
        
        function [delta, stage] = getDelta(obj)
            
            % if first trial
            if isempty(obj.deltaHistory)
                delta = obj.startVal;
                stage = 1;
                return
            end
            
            % if after last trial
            if obj.isFinished()
                delta = NaN;
                stage = NaN;
                return;
            end
            
            % calculate number of preceding trials right/wrong in a row
            [nRightInARow, nWrongInARow] = obj.getNInARow();
            
            % compute stage (e.g., leadin, main)
            stage = obj.getCurrentStage();
            if isempty(stage)
                error('no stage???');
            end
            
            % calc direction of change (if any)
            if nRightInARow > 0 && (mod(nRightInARow, obj.nDown(stage)) == 0)
                stepDirection = -1; % decrease value
                dMod = obj.downMod(stage);
            elseif nWrongInARow > 0 && (mod(nWrongInARow, obj.nUp(stage)) == 0)
                stepDirection = 1; % increase value
                dMod = 1; % do nothing
            else
                delta = obj.deltaHistory(end); % no change (same as last value) [alt could set stepDirection to 0 and step through]
                return
            end
            
            % calc new delta value
            if obj.isAbsolute(stage)
                delta = obj.deltaHistory(end) + (obj.stepSize(stage)*dMod)*stepDirection; % previous value +/- step
            else
                %delta = obj.deltaHistory(end) / (obj.stepSize(stage)^stepDirection); % previous value * step
%                 obj.deltaHistory(end)
%                 obj.stepSize(stage)
%                 stepDirection
%                 dMod
                delta = obj.deltaHistory(end) * (obj.stepSize(stage).^-stepDirection)^dMod;
            end
                
            % ensure within limits
            delta = min(delta, obj.maxVal); % not too big
            delta = max(delta, obj.minVal); % not too small
        end
        
        function [nRightInARow, nWrongInARow] = getNInARow(obj)
            nWrongInARow = obj.wasCorrectHistory(end) == 0;
            nRightInARow = obj.wasCorrectHistory(end) == 1;
            dx = diff(obj.wasCorrectHistory);
            for i = length(dx):-1:1
                if dx(i) ~= 0
                    break
                end
                nWrongInARow = nWrongInARow + (obj.wasCorrectHistory(i) == 0);
                nRightInARow = nRightInARow + (obj.wasCorrectHistory(i) == 1);
            end
        end
        
        function [vals,idx,N,stage] = getReversals(obj, inStage, evenOnly)
            
            if nargin < 2 || isempty(inStage)
                inStage = 1:length(obj.stepSize);
            end
            if nargin < 3 || isempty(evenOnly)
                evenOnly = true;
            end
            
            stage = obj.stageHistory;
            
            idx = obj.reversalsHistory~=0 & ismember(stage, inStage);
            vals = obj.deltaHistory(idx);
            N = length(vals);
            
            if evenOnly && mod(N,2) && N > 0
                idx(find(idx,1,'first')) = false;
                vals(1) = [];
                N = N - 1;
            end
        end
        
        function stage = getCurrentStage(obj)
            nRevs = sum(abs(obj.reversalsHistory));
            stage = find(nRevs < cumsum(obj.nReversals), 1, 'first');
            
            nStages = length(obj.stepSize);
            if stage > nStages % not sure if this ever happens any more
                error('a:b','Is finished')
            end
            
            % hack to deal with minNTrials being set
            if isempty(stage) && (length(obj.minNTrials) < obj.minNTrials)
                fprintf('warning: overriding track finished due to minNTrials\n');
                stage = nStages;
            end
                
        end
        
        function bool = wasAReversal(obj)
            bool = abs(obj.reversalsHistory(end)) ~= 0;
        end
        
        function [est,vals]=computeThreshold(obj, N, inStage)
            % n.b., geomean(vals)
            if nargin < 2
                N = [];
            end
            if nargin < 3 || isempty(inStage)
                inStage = length(obj.stepSize); % highest
            end
            
            vals = obj.getReversals(inStage, true);
            if ~isempty(N)
                vals = vals(end-N:end);
            end
            
            % calc threshold
            est = mean(vals);
        end
        
        
        function fin = isFinished(obj)
            fin = false;

            if length(obj.wasCorrectHistory) < obj.minNTrials % n completed trials
                return
            end
            
            if length(obj.wasCorrectHistory) >= obj.maxNTrials % n completed trials
                fin = true;
                return
            end
            
            if nansum(abs(obj.reversalsHistory)) >= sum(obj.nReversals) % n completed reversals [nansum is a hack for minNTrials]
                fin = true;
                return
            end
        end
        
        
        function [] = goBackN(obj, N)
            
            N = N - 1;
            obj.deltaHistory(end-N:end) = [];
            obj.wasCorrectHistory(end-N:end) = [];
            obj.reversalsHistory(end-N:end) = [];
            obj.stageHistory(end-N:end) = [];

            if sum(abs(diff(obj.wasCorrectHistory))) == 0 % check me
                obj.prevRevDirection = NaN;
            end
        end
        
 
        % update with new results
        function [] = update(obj, wasCorrect)
            
            % ensure limit hasn't been reached
            if obj.isFinished()
                error('StaircaseUpdate:LimitReached', 'Cannot update, limit reached');
            end
            
            % compute
            [deltaVal, stage] = obj.getDelta();
            
            % compute
            trialNum = length(obj.deltaHistory)+1;
            
            % update performance history
            obj.deltaHistory(end+1) = deltaVal;
            obj.wasCorrectHistory(end+1) = wasCorrect;
            obj.stageHistory(end+1) = stage;
            
            % compute if reversal
            nextDeltaVal = obj.getDelta();
            revDirection = 0;
            if trialNum == 1 
                % NEW: added to make 1down-1up work
                dx = sign(deltaVal - nextDeltaVal);
                if dx ~= 0
                    obj.prevRevDirection = dx;
                end
            else
                dx = sign(deltaVal - nextDeltaVal);
                if dx ~= 0 && dx ~= obj.prevRevDirection
                    if ~isnan(obj.prevRevDirection)
                        revDirection = dx;
                    end
                    obj.prevRevDirection = dx;
                end
            end
            
            % update reversal history
            obj.reversalsHistory(end+1) = revDirection;
            
            % feedback
            if obj.verbosity > 0
                cStr = {'InCorrect','Correct  '}; rStr = {'        ','Reversal','NaN'};
                if isnan(revDirection), revDirection = 2; end
                fprintf('   %5.0f: %6.2f  %s   %s     [S%i]\n',trialNum,deltaVal,cStr{wasCorrect+1},rStr{abs(revDirection)+1},obj.stageHistory(end));
                
                % PLOT
                if obj.verbosity > 1
                    obj.updatePlot();
                end
            end
            
        end
        
        
        
    end
    
    %% ====================================================================
    %  -----STATIC METHODS-----
    %$ ====================================================================
    
    methods(Static)
        % useful when debugging
        function params = getDummyParams()
            params = [];
            params.startVal = 100;
            params.stepSize = [10 5 2.5]; % 1./[1.1 1.05 1.001];
            params.downMod = [1 .5 .5];
            params.nReversals = [4 8 8];
            params.nUp = 1; % [1 1 1];
            params.nDown = 1; % [1 1 1];
            params.isAbsolute = true;
            params.minVal = 50;
            params.maxVal = 200;
            params.minNTrials = 0;
            params.maxNTrials = 50;
            params.verbosity = 2;
        end
    end
    
    %% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================
    
    methods(Access = 'private')
        
        function figHandles = createPlot(obj, maxN,initialVal,minVal,maxVal)
            figHandles.hFig=figure(length(findobj('Type','figure'))+1); % create on top of any existing
            set(figHandles.hFig, 'Position', [300 100 600 800]); % [x y width height]
            hold on
            figHandles.hPerf = plot(-1,-1);
            figHandles.hRight = plot(-1,-1 ...
                ,'o' ...
                ,'LineWidth',2 ...
                ,'MarkerFaceColor','g' ...
                ,'MarkerEdgeColor','k' ...
                ,'MarkerSize',10);
            figHandles.hWrong = plot(-1,-1 ...
                ,'o' ...
                ,'LineWidth',2 ...
                ,'MarkerFaceColor','r' ...
                ,'MarkerEdgeColor','k' ...
                ,'MarkerSize',10);
            figHandles.hNextTarget = plot(1,initialVal ...
                ,'x' ...
                ,'MarkerEdgeColor','k' ...
                ,'MarkerSize',10);
            figHandles.vlines = cell(1, length(obj.stepSize));
            hold off
            if maxN>1; xlim([1 maxN]); end
            ylim([minVal, maxVal]);
            xlabel('Trial Number','FontSize',16);
            ylabel('\Delta','FontSize',16);
            set(figHandles.hFig,'Name','Adaptive Track','NumberTitle','off'); % set window title
            set(gcf, 'Renderer', 'Painters'); % Painters? OpenGL? OpenGL conflicts with psychtoolbox  
        end
        
        function [] = updatePlot(obj)
            % update markers
            trialNums = 1:length(obj.deltaHistory);
            set(obj.figHandles.hPerf,'XData',trialNums,'YData',obj.deltaHistory);
            set(obj.figHandles.hRight,'XData',trialNums(obj.wasCorrectHistory==1),'YData',obj.deltaHistory(obj.wasCorrectHistory==1));
            set(obj.figHandles.hWrong,'XData',trialNums(obj.wasCorrectHistory==0),'YData',obj.deltaHistory(obj.wasCorrectHistory==0));
            
            % highlight reversals (each stage in different colour)
            nStages = length(obj.stepSize);
            
           	axes(gca);   
            for i = 1:nStages
                if ishandle(obj.figHandles.vlines{i})
                    delete(obj.figHandles.vlines{i});
                end
                idx = (obj.stageHistory==i) & (obj.reversalsHistory~=0);
                if sum(idx)>0
                    obj.figHandles.vlines{i} = vline(find(idx), obj.stageColours{i});
                end
            end

            % update next target value [cross]
            set(obj.figHandles.hNextTarget,'XData',length(obj.deltaHistory)+1,'YData',obj.getDelta());
               
            % refresh graphics
            drawnow();
        end
        
    end
end
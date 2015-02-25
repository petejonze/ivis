classdef (Abstract) IvGUIelement < Singleton
	% Generic GUI Java window, to be instantiated by a subclass.
    %
    % IvGUIelement Methods:
	%   none
    %
    % See Also:
    %   none
    %
    % Example:
    %   none
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 02/2013 : first_build\n
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %  
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
      
	properties (GetAccess = public, SetAccess = protected)
        hFig
    end

    properties (Abstract, Constant)
        FIG_NAME
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
      
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function [] = delete(obj)
            % IvGUIelement Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %             
            if ~isempty(obj.hFig) && ishandle(obj.hFig)
                delete(obj.hFig);
            end
            obj.hFig = [];
            clear obj;
        end
    end
    
    
    %% ====================================================================
    %  -----PROTECTED METHODS-----
    %$ ====================================================================
          
    methods (Access = protected)
        
        function [effectiveFDims, fDims, aDims] = init(obj, idx, normaliseDims, bgcolor)
            % Initialise the GUI element; set the renderer and compute the
            % plot area dimensions.
            %
            % @param    idx             GUI frame index
            % @param    normaliseDims   normalised figure dimensions
            % @param    bgcolor         figure background colour
            % @return   effectiveFDims  effective figure dimensions
            % @return   fDims           figure dimensions
            % @return   aDims           axis dimensions
            %
            % @todo     sort out isempty(normaliseDims)
            % @date     26/06/14
            % @author   PRJ
            % 
            
            % parse inputs
            if nargin < 3
                normaliseDims = [];             
            end
            if ~isempty(normaliseDims) && (nargin < 4 || isempty(bgcolor))
                %error('bgcolor required if normaliseDims specified');
                bgcolor = [0 0 0];
            end
  
            % part of trying to move towards a system where a PTB screen needn't be
            % specified:
            if isempty(normaliseDims)
                normaliseDims = []; % [1024 768];
                bgcolor = [0 0 0];
                fprintf('Todo: IvGUIelement without screen\n');
            end
            
            % open figure component and embed in GUI
            ivis.gui.IvGUI.getInstance().addFigurePanel(idx, obj.FIG_NAME);
            obj.hFig = ivis.gui.IvGUI.getInstance().hFig(idx)';
            
            % set renderer
            set(obj.hFig, 'Renderer', 'Painters'); % OpenGL conflicts with psychtoolbox
             
            % compute
            effectiveFDims = []; fDims = []; aDims = [];
            if ~isempty(normaliseDims)
                % compute dimensions
                tmp = get(obj.hFig ,'position');
                fDims = tmp(3:4); % fig width, height
                compressFactor = max(normaliseDims./fDims); % find limiting dimension
                nfDims = (normaliseDims/compressFactor)./fDims; % new fig dims
                effectiveFDims = fDims .* nfDims; % ala guiCalib

                % set colour, scale, direction of axes
                axes('Color', bgcolor, 'Units', 'normalize', 'Position', [[1 1]-nfDims nfDims], 'DrawMode', 'fast', 'XTick', [], 'YTick', []);
                % axis ij; % specify "matrix" axes mode. Coordinate system origin is at upper left corner.
                set(gca, 'YDir', 'reverse');
                xlim([0 1]); ylim([0 1]); % fix axes
                
                tmp = get(gca ,'position');
                aDims = tmp(3:4); % axes dimensions
            end
        end
    end

end
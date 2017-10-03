classdef LennardJonesPotential < handle
	% Simulate the diffusion of molecules (useful for bouncing things
	% around at area).
    %
    %     All the hard work done by Maarten Baan: http://www.youtube.com/watch?v=Q6f5ZXyHtfs
    %     n.b. always users Euler method (didn't bother implemeting Verlet)
    %     
    %     EXAMPLE USAGE:
    %     
    %     close all; clear all
    %     
    %     x = 1:6;
    %     y = 1:6;
    %     v = (rand(6,1)-0.5)*4;
    %     u = (rand(6,1)-0.5)*4;
    %     m = ones(6,1);
    %     b = [0 7 0 7];
    %     ifi = 1/120;
    %     myLJP = LennardJonesPotential(x,y,v,u,m,b,.75,ifi);
    %     
    %     for i = 1:1000
    %         myLJP.calcNextTimestep();
    %         myLJP.plot();
    %         pause(ifi);
    %     end
    %
  	% LennardJonesPotential Methods:
    %   * LennardJonesPotential - Constructor.
    %   * calcNextTimestep      - Update "molecule" locations.
    %   * initPlot              - Create a figure window.
    %   * plot                  - Update figure window.
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
          
    properties (GetAccess = public, SetAccess = private)
        % user specified parameters
        x
        y
        v
        u
        m
        N % number of particles
        borders
        % optional params
      	sigma = 1;              %particle diameter
        dt = 0.005;             %time step in seconds
        epsilon = 1;            %material parameter
        maxVelocity = inf;        
        % other internal parameters
        V;
        T;
        f_x;
        f_y;
        V_j;
        t = 0; % timestep
        hFig % for plotting
        hCircles % for plotting
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)

        function obj = LennardJonesPotential(x, y, v, u, m, borders, sigma, dt, epsilon, maxVelocity)
            % LennardJonesPotential Constructor.
            %
            % @param    x initial x positions [vector]
            % @param    y initial y positions
            % @param    v initial x velocities
            % @param    u initial y velocities
            % @param    m masses
            % @param    borders [x0 x1 y0 y1] [leave empty for no borders]
            % @param    sigma foo
            % @param    dt foo
            % @param    epsilon foo    
            % @param    maxVelocity foo 
            % @return   obj LennardJonesPotential
            %
            % @date     26/06/14
            % @author   PRJ
            %   
 
            % validate params
            if isrow(x), x = x'; end
            if isrow(y), y = y'; end
            if isrow(v), v = v'; end
            if isrow(u), u = u'; end
            if isrow(m), m = m'; end

            % store params
            obj.x = x;
            obj.y = y;
            obj.v = v;
            obj.u = u;
            obj.m = m;
            obj.borders = borders;
            if nargin >= 7 && ~isempty(sigma), obj.sigma = sigma; end
            if nargin >= 8 && ~isempty(dt), obj.dt = dt; end
            if nargin >= 9 && ~isempty(epsilon), obj.epsilon = epsilon; end
            if nargin >= 10 && ~isempty(maxVelocity), obj.maxVelocity = maxVelocity; end

            % calc additional
            obj.N = length(x);              %n particles
            obj.V = zeros(obj.N,1);         %allocate potential energy array
            obj.T = zeros(obj.N,1);         %allocate kinetic energy array
            obj.f_x = zeros(1,obj.N);       %allocate force matrix x-direction
            obj.f_y = zeros(1,obj.N);       %allocate force matrix y-direction
            obj.V_j = zeros(1,obj.N);       %allocate LennardJones potential matrix
            
        end
        
        function [xPos, yPos, speed, potentialEnergy, kineticEnergy] = calcNextTimestep(obj)
            % Update "molecule" locations.
            %
            % @return   xPos
            % @return   yPos
            % @return   speed
            % @return   potentialEnergy
            % @return   kineticEnergy
            %
            % @date     26/06/14
            % @author   PRJ
            %               
            for i=1:obj.N
                for j=1:obj.N %set force/energobj.y interactions for each particle
                    if i~=j %don't take self inducting terms into account
                        
                        %compute the distance
                        rij = sqrt((obj.x(i)-obj.x(j))^2+ (obj.y(i)-obj.y(j))^2);
                        
                        %compute unit normal vector, n(1)=n_x, n(2)=n_y
                        n = [ obj.x(i)-obj.x(j) obj.y(i)-obj.y(j) ]/norm([ obj.x(i)-obj.x(j) obj.y(i)-obj.y(j) ]);
                        
                        %for x direction
                        obj.f_x(j) = n(1)*-4*obj.epsilon*((6*obj.sigma^6)/rij^7 - (12*obj.sigma^12)/rij^13);
                        
                        %for y direction
                        obj.f_y(j) = n(2)*-4*obj.epsilon*((6*obj.sigma^6)/rij^7 - (12*obj.sigma^12)/rij^13);
                        
                        %potential energy
                        obj.V_j(j) = 4*obj.epsilon*((obj.sigma/rij)^12-(obj.sigma/rij)^6);
                        
                    else %if i=j: force=0, potential=0
                        obj.f_x(j) = 0;
                        obj.f_y(j) = 0;
                        obj.V_j(j) = 0;
                    end
                end
                
                %Compute the position and velocitobj.y using Euler or Verlet
                oldX = obj.x;
                oldY = obj.y;
                
                % Forward Euler x
                obj.x(i) = obj.x(i) + obj.v(i)*obj.dt; % overwrite old position with new
              
                obj.v(i) = obj.v(i) + sum(obj.f_x)/obj.m(i)*obj.dt;
                obj.v(i) = max(obj.v(i), -obj.maxVelocity);
                obj.v(i) = min(obj.v(i), obj.maxVelocity);

                % Forward Euler y
                obj.y(i) = obj.y(i) + obj.u(i)*obj.dt; % overwrite
                obj.u(i) = obj.u(i) + sum(obj.f_y)/obj.m(i)*obj.dt;
                obj.u(i) = max(obj.u(i), -obj.maxVelocity);
                obj.u(i) = min(obj.u(i), obj.maxVelocity);

                % If borders are on (i.e. not empty) then bounce-off if
                % necessary
                if ~isempty(obj.borders)
                    if (obj.x(i) < obj.borders(1)+obj.sigma/4) || (obj.x(i) > obj.borders(2)-obj.sigma/4) %obj.x
                        obj.x(i) = 2*oldX(i) - obj.x(i);
                        obj.v(i) = -obj.v(i);
                    end
                    if (obj.y(i) < obj.borders(3)+obj.sigma/4) || (obj.y(i) > obj.borders(4)-obj.sigma/4) %obj.y
                        obj.y(i) = 2*oldY(i) - obj.y(i);
                        obj.u(i) = -obj.u(i);
                    end
                end

                
                %Energy calculations
                obj.V(i) = sum(obj.V_j); %Potential energy: sum of influence of other particles
                obj.T(i) = 1/2*obj.m(i)*(obj.v(i)^2+obj.u(i)^2); %Kinetic energy: 1/2mv^2
            end
            
            % Return variables
            xPos = obj.x;
            yPos = obj.y;
            speed = sqrt(obj.v.^2 + obj.u.^2);
            potentialEnergy = obj.V;
            kineticEnergy = obj.T;
        end
        
        function [] = initPlot(obj)
            % Create a figure window.
            %
            % @date     26/06/14
            % @author   PRJ
            %   
            
            obj.hFig = figure();
            
            %%% Set the axis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~isempty(obj.borders) %if borders are given set the axis equal to the borders
                ax_x = obj.borders(1:2);
                ax_y = obj.borders(3:4);
            else %if not set the axis automatically to the highest traveled distance of the particles
                error('a:b','functionality not yet written');
            end
            set(gca,'DataAspectRatio',[1 1 1]); %set aspect ratio x:y to 1:1
            axis([ax_x ax_y]); %set the axis
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % plot the circles
            hold on
            circle = linspace(0,2*pi,100); %create a circle
            for i = 1:obj.N
                xx = obj.sigma/2*cos(circle)+obj.x(i); %x-location of particle
                yy = obj.sigma/2*sin(circle)+obj.y(i); %y-location of particle
                color = [abs(obj.v(i))/max(abs(obj.v)) 0 abs(obj.u(i))/max(abs(obj.u))]; %color is based on the max velocity in v and u direction: red = high v, blue = high u, or combo
                
                % plot
                obj.hCircles(i) = fill(xx,yy,color,'erasemode','normal');
            end
            hold off
        end 
        
        function [] = plot(obj, xPos, yPos)
            % Update figure window.
            %
            % @param    xPos
            % @param    yPos
            %
            % @date     26/06/14
            % @author   PRJ
            %   
            
            % parse
            if nargin < 2 || isempty(xPos)
                xPos = obj.x;
            end
            if nargin < 3 || isempty(yPos)
                yPos = obj.y;
            end
            
            % check if a valid plot handle exists, if not create and
            % initialise one
            if isempty(obj.hFig) || ~ishandle(obj.hFig)
                obj.initPlot();
            end
            
            % update graphics
            circle = linspace(0,2*pi,100); %create a circle
            for i=1:obj.N % update N circles...
                % update params
                xx = obj.sigma/2*cos(circle)+xPos(i); %x-location of particle
                yy = obj.sigma/2*sin(circle)+yPos(i); %y-location of particle
                color = [abs(obj.v(i))/max(abs(obj.v)) 0 abs(obj.u(i))/max(abs(obj.u))];
                % set params
                set(obj.hCircles(i),'XData',xx,'YData',yy,'FaceColor',color);
            end
            
            % update figure
            drawnow(); 
        end
        
    end % End of public methods
    
end
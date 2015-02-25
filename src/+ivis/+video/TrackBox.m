classdef (Sealed) TrackBox < Singleton & ivis.broadcaster.IvListener
    % Display Tobii eyetracker box schema and current eyeball info.
    %
    % Utility function that displays a scale wireframe model of the display
    % screen and Tobii x120 trackbox. Estimated eyeball and fixation
    % positions are displayed, or the wireframe is turned red if no input
    % is detected. The screen parameters are taken from IvParams. However,
    % the track box dimensions are guestimated and hardcoded, since they
    % cannot be extracted from the Tobii given the current matlab SDK
    % bindings.
    %
    % TrackBox Methods:
    %   * draw      - Draw trackbox, and keep updating until stopped
    %   * stop      - Stop drawing trackbox and release memory
    %   * toggle	- Alternate between start/stop states
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
    %   1.0 PJ 03/2013 : first_build\n
    %
    % @ todo: Should probably be refactored to be part of a Tobii-specific package (or even inside the Tobii class itself)
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %

    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (Constant)
        ALLOW_IMPLICIT_CONSTRUCTION = true;
    end
    
    properties (GetAccess = public, SetAccess = private)
        winhandle               % ######
        eyeTracker              % ######
        monitorwidth_mm = 365;  % ######
        monitorheight_mm = 270; % ######
        monitorwidth_px;        % ######
        monitorheight_px;       % ######
        tobiidist = 150;        % ######
        boxdist_mm = 600;       % ######
        boxsize_mm = 300;       % ######
        amax;                   % ######
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = TrackBox()
            % TrackBox Constructor.
            %
            % @return   obj  TrackBox object
            %             
            % @date     26/06/14                          
            % @author   PRJ
            %

            % get screen params
            params = ivis.main.IvParams.getInstance();
            obj.winhandle = params.graphics.winhandle;
            winRect=Screen('Rect', obj.winhandle);
            
            % Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
            % mogl OpenGL for Matlab wrapper:
            InitializeMatlabOpenGL(1);
            
            % Setup the OpenGL rendering context of the onscreen window for use by
            % OpenGL wrapper. After this command, all following OpenGL commands will
            % draw into the onscreen window winhandle':
            Screen('BeginOpenGL', obj.winhandle);
            
            % Get the aspect ratio of the screen:
            ar=winRect(4)/winRect(3);
            
            % Turn on OpenGL local lighting model: The lighting model supported by
            % OpenGL is a local Phong model with Gouraud shading.
            glEnable(GL_LIGHTING);
            
            % Enable the first local light source GL_LIGHT_0. Each OpenGL
            % implementation is guaranteed to support at least 8 light sources.
            glEnable(GL_LIGHT0);
            
            % Enable two-sided lighting - Back sides of polygons are lit as well.
            glLightModelfv(GL_LIGHT_MODEL_TWO_SIDE,GL_TRUE);
            
            % Enable proper occlusion handling via depth tests:
            % Disabled to allow screen capture
            %     glEnable(GL_DEPTH_TEST);
            
            % Define the cubes light reflection properties by setting up reflection
            % coefficients for ambient, diffuse and specular reflection:
            %     glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT, [ .33 .22 .03 1 ]);
            %     glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE, [ .78 .57 .11 1 ]);
            %     glMaterialfv(GL_FRONT_AND_BACK,GL_SHININESS,27.8);
            glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT, [ .4 .4 .3 1 ]);
            glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE, [ .9 .6 .3 1 ]);
            glMaterialfv(GL_FRONT_AND_BACK,GL_SHININESS,35);
            
            % Set projection matrix: This defines a perspective projection,
            % corresponding to the model of a pin-hole camera - which is a good
            % approximation of the human eye and of standard real world cameras --
            % well, the best aproximation one can do with 3 lines of code ;-)
            glMatrixMode(GL_PROJECTION);
            glLoadIdentity;
            % Field of view is 25 degrees from line of sight. Objects closer than
            % 0.1 distance units or farther away than 100 distance units get clipped
            % away, aspect ratio is adapted to the monitors aspect ratio:
            gluPerspective(25,1/ar,0.1,100);
            
            % Setup modelview matrix: This defines the position, orientation and
            % looking direction of the virtual camera:
            glMatrixMode(GL_MODELVIEW);
            glLoadIdentity;
            
            % Cam is located at 3D position (3,3,5), points upright (0,1,0) and fixates
            % at the origin (0,0,0) of the worlds coordinate system:
            gluLookAt(3,3,5,0,0,0,0,1,0);
            
            % Point lightsource at (1,2,3)...
            glLightfv(GL_LIGHT0,GL_POSITION,[ 1 2 3 0 ]);
            % Emits white (1,1,1,1) diffuse light:
            glLightfv(GL_LIGHT0,GL_DIFFUSE, [ 1 1 1 1 ]);
            
            % There's also some white, but weak (R,G,B) = (0.1, 0.1, 0.1)
            % ambient light present:
            glLightfv(GL_LIGHT0,GL_AMBIENT, [ .1 .1 .1 1 ]);
            
            % No more OpenGL commands for now
            Screen('EndOpenGL', obj.winhandle);
            
            % set internal params
            obj.eyeTracker = ivis.eyetracker.IvDataInput.getInstance();
            obj.monitorwidth_px = params.graphics.monitorWidth;
            obj.monitorheight_px = params.graphics.monitorHeight;
            xmax = max(obj.monitorwidth_mm, obj.boxsize_mm);
            ymax = max(obj.monitorheight_mm, obj.boxsize_mm);
            zmax = obj.tobiidist+obj.boxdist_mm+obj.boxsize_mm/2;
            obj.amax = max([xmax, ymax, zmax])/1.5;  
        end
        
        function [] = delete(obj)
            % IvWebcam Desctructor.
            %         
            % @date     26/06/14                          
            % @author   PRJ
            %  
            
            obj.stopListening('PreFlip');
        end
        
        %% == METHODS =====================================================
        
        function [] = draw(obj,~,~)
            % ######.
            %         
            % @date     26/06/14                          
            % @author   PRJ
            %  
            
            % ensure that deal with Tobii
            if ~strcmpi(obj.eyeTracker.NAME, ivis.eyetracker.IvTobii.NAME)
                fprintf('TrackBox only defined for Tobii. Disabling\n');
                obj.stopListening('PreFlip');
                return
            end
            
            global GL
            
            % Switch to OpenGL rendering again for drawing of next frame:
            Screen('BeginOpenGL', obj.winhandle);

            % Setup cubes rotation around axis:
            glPushMatrix;
            
            % rotate around the y axis
            glRotated(10, 0, 1, 0); %
            % glRotated(30, 0, 1, 0); % make square on
            
            % Clear out the backbuffer: This also cleans the depth-buffer for
            % proper occlusion handling:
            glClear(GL.DEPTH_BUFFER_BIT);
            
            % query input device for estimated eyeball position and fixation
            % point
            leyeposition = obj.ucs2mycs(obj.eyeTracker.leyeSpatialPosition, 0, 0, obj.tobiidist);
            reyeposition = obj.ucs2mycs(obj.eyeTracker.reyeSpatialPosition, 0, 0, obj.tobiidist);
            %xy = ivis.log.IvDataLog.getInstance().getLastKnownXY(1, false, true) <-- won't work if logging==false
            xy = obj.eyeTracker.lastXYTV(1:2);
            
            % ######
            glTranslated(-1.75, .5, -.5);
            glLineWidth(1.75);
            glColor3f(.7,.1,.1); % red (only used when not using lighting, below)
            if (any(isnan(leyeposition)) || all(leyeposition == [0 0 -150])) ...
                    && (any(isnan(reyeposition)) || all(reyeposition == [0 0 -150]))
                glDisable(GL.LIGHTING); % when lighting is disabled will revert to using explicitly defined colours
            else
                glEnable(GL.LIGHTING);
            end
            
            % ######
            v = [ 0 0 0; obj.monitorwidth_mm 0 0; obj.monitorwidth_mm obj.monitorheight_mm 0; 0 obj.monitorheight_mm 0];
            v = obj.normalise(v);
            obj.drawsurface( v )
            
            % DRAW FIXATION POINT
            if ~isempty(xy) && ~any(isnan(xy))
                xy(2) = obj.monitorheight_px - xy(2); % invert y coords
                xy = obj.normalise(xy ./ [obj.monitorwidth_px obj.monitorheight_px] .* [obj.monitorwidth_mm obj.monitorheight_mm]); % place on monitor. scale between 0 - 1 (proportion of monitor), then convert to mm, then convert to 0 - 1 normalised units
                obj.drawcircle(xy(1),xy(2),0.03,10);
            end
            
            % DRAW CUBE
            % move back
            % n.b. must move left as well?
            glTranslated(obj.normalise(obj.monitorwidth_mm/2), 0, obj.normalise(obj.tobiidist+obj.boxdist_mm) );
            obj.drawcube( obj.normalise(obj.boxsize_mm) )
            
            % DRAW EYES
            glTranslated(0, 0, -obj.normalise(obj.boxdist_mm));
            if ~any(isnan(leyeposition))
                if all(leyeposition ~= [0 0 -150])
                    v = obj.normalise(leyeposition);
                    glTranslated(v(1), v(2), v(3));
                    glutSolidSphere(0.05, 10, 10);
                    glTranslated(-v(1), -v(2), -v(3));
                end
            end
            if ~any(isnan(reyeposition))
                if all(reyeposition ~= [0 0 -150])
                    v = obj.normalise(reyeposition);
                    glTranslated(v(1), v(2), v(3));
                    glutSolidSphere(0.05, 10, 10);
                    glTranslated(-v(1), -v(2), -v(3));
                end
            end
            
            glPopMatrix;
            
            % Finish OpenGL rendering into PTB window and check for OpenGL errors.
            Screen('EndOpenGL', obj.winhandle);
        end

        function [] = start(obj)
            % #####.
            %   
            % @date     26/06/14                          
            % @author   PRJ
            %  
            obj.startListening('PreFlip', @obj.draw);
        end
        
        function [] = stop(obj)
            % #####.
            %   
            % @date     26/06/14                          
            % @author   PRJ
            %  
            
            obj.stopListening('PreFlip');
        end
        
    end
    
    
    %% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================
    
    methods (Access = private)
    
        function [] = drawcube(obj, cubesize)
            % #####.
            %
            % @param    cubesize    #####
            %             
            % @date     26/06/14                          
            % @author   PRJ
            %  
            
            % centered on current point
            v=([0 0 0 ; 1 0 0 ; 1 1 0 ; 0 1 0 ; 0 0 1 ; 1 0 1 ; 1 1 1 ; 0 1 1]-0.5)*cubesize;
            
            obj.drawsurface(v([4 3 2 1],:));
            obj.drawsurface(v([5 6 7 8],:));
            obj.drawsurface(v([1 2 6 5],:));
            obj.drawsurface(v([3 4 8 7],:));
            obj.drawsurface(v([2 3 7 6],:));
            obj.drawsurface(v([4 1 5 8],:));
        end
        
        function [] = drawsurface(obj, v)
            % #####.
            %
            % @param    v   #####
            %             
            % @date     26/06/14                          
            % @author   PRJ
            %  
            
            % We want to access OpenGL constants. They are defined in the global
            % variable GL. GLU constants and AGL constants are also available in the
            % variables GLU and AGL...
            global GL
            
            % Compute surface normal vector. Needed for proper lighting calculation:
            n=cross(v(2,:)-v(1,:),v(3,:)-v(2,:));
            
            % Set opengl mode
            glPolygonMode(GL.FRONT_AND_BACK,GL.LINE)
            
            % Bind (Select) texture 'tx' for drawing:
            % glBindTexture(GL.TEXTURE_2D,tx);
            % Begin drawing of a new polygon:
            glBegin(GL.POLYGON);
            
            % Assign n as normal vector for this polygons surface normal:
            glNormal3dv(n);
            
            % Draw
            for i = 1:size(v,1)
                glVertex3dv(v(i,:));
            end
            
            % Done with this polygon:
            glEnd();
        end
        
        function y = normalise(obj, x)
            % ####.
            %
            % @param    x   ####
            % @return   y   ####
            %             
            % @date     26/06/14                          
            % @author   PRJ
            %  
            
            y = x/obj.amax;
            %     y(:,3) = y(:,3) + 0.5;
            %     y = y*2;
            %     y(:,2) = y(:,2) + 1-ymax/amax;
        end
        
        function y = ucs2mycs(obj, x, xmod, ymod, zmod)
            % #####.
            %
            % @param    x       ######
            % @param    xmod    ######
            % @param    ymod    ######
            % @param    zmod    ######
            % @return   y       ######
            %             
            % @date     26/06/14                          
            % @author   PRJ
            %  
            
            % Tobii's User Coordinate System to My Coordinate System (normalised to
            % the OpenGL reference frame)
            y = bsxfun(@plus, x, [xmod, ymod, -zmod]);
        end
        
        function [] = drawcircle(obj, cx, cy, r, num_segments)
            % ######.
            %
            % @param    cx              ######
            % @param    cy              ######
            % @param    r               ######
            % @param    num_segments    ######
            %             
            % @date     26/06/14                          
            % @author   PRJ
            %  
            
            global GL
            theta = 2 * 3.1415926 / num_segments;
            c = cos(theta); %precalculate the sine and cosine
            s = sin(theta);
            x = r; % we start at angle = 0
            y = 0;
            
            glBegin(GL.LINE_LOOP);
            for i = 0:(num_segments-1)
                glVertex2f(x + cx, y + cy); % output vertex
                
                %apply the rotation matrix
                t = x;
                x = c * x - s * y;
                y = s * t + c * y;
            end
            
            % Done with this polygon:
            glEnd();
        end
        
    end 
    
    
    %% ====================================================================
    %  -----SINGLETON BLURB-----
    %$ ====================================================================
    
    methods (Static, Access = ?Singleton)
        function obj = getSetSingleton(obj)
            persistent singleObj
            if nargin > 0, singleObj = obj; end
            obj = singleObj;
        end
    end
    methods (Static, Access = public)
        function obj = getInstance()
            obj = Singleton.getInstanceSingleton(mfilename('class'));
        end
        function [] = finishUp()
            Singleton.finishUpSingleton(mfilename('class'));
        end
    end
    
end
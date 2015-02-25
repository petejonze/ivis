classdef (Sealed) IvSMI < ivis.eyetracker.IvDataInput
    % Singleton instantiation of IvDataInput, designed not to be driven by
    % an SMI eyetracker
    %
    %   Note: this relies on Frans Cornelissen's IVXToolbox, which is
    %   bundled with PsychToolBox. However, much of this code has been
    %   rewritten/encorporated into the current class file.
    %
    %   This class was inspired by code by Jenny Read :
    %   http://www.jennyreadresearch.com/research/matlab-code/#SMIRED
    %
   	% IvSMI Methods:
    %   * IvSMI     - Constructor.
    %   * connect	- Establish a link to the eyetracking hardware.
    %   * reconnect	- Disconnect and re-establish link to eyetracker.
    %   * refresh  	- Query the eyetracker for new data; process and store.
    %   * flush   	- Query the eyetracker for new data; discard.
    %   * validate  - Validate initialisation parameters.
    %
   	% IvSMI Static Methods:  
    %   * readRawLog- Parse data stored in a .raw binary file (hardware-brand specific format).
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
    
%@todo: allow use-specified parameters   
%@todo: add calibration support
%@todo: maybe allow user to extract an 'ivx' style data structure, if they
%want to 'manually' interact with the iViewX toolbox
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (Constant)
        NAME = 'IvSMI';
    end
    properties (GetAccess = private, SetAccess = private)
        host = '10.10.10.1';
        port = 4444;
        localport = 5555;
        udp
        udpreadtimeout
        udpmaxread
        screenHSize_px = 1024;
        screenVSize_px = 768;
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods(Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvSMI()
            % IvSMI Constructor.
            %
            % @return   IvSMI
            %
            % @date     21/10/14
            % @author   PRJ
            %
            
            % n.b., superclass IvDataInput will already have stored all the
            % necessary parameters and commencing logging, etc., if so
            % requested

            
            ivx = iViewXInitDefaults();
            obj.udp = ivx.udp;
            obj.udpreadtimeout = ivx.udpreadtimeout;
            obj.udpmaxread = ivx.udpmaxread;

            % connect
            obj.connect();
        end
        
        function delete(obj)
            % IvSMI Destructor.
            %
            % @date     21/10/14
            % @author   PRJ
            %

            try
                obj.IVXsend('ET_EST');
            catch ME
                fprintf('FAILED TO STOP TRACKING???\n');
                disp(ME)
            end
            
            try
                pnet(obj.udp, 'close');
            catch ME
                fprintf('FAILED TO DISCONNECT EYETRACKER???\n');
                disp(ME)
            end
            
            try
                status = pnet(obj.udp,'status');
                if status > 0
                    error('IvSMI still connected? (status = %i).', status);
                end
            catch ME
                fprintf('FAILED TO CHECK DISCONNECTED???\n');
                disp(ME)
            end
        end

        %% == METHODS =====================================================
        
        function connect(obj) % interface implementation
            fprintf('Connecting to SMI tracker...');

            % Close any existing connections:
            pnet('closeall');
            
            % Open new connection (will keep this connection open for the
            % duration, to minimize connection/disconnection overheads):
            obj.udp = pnet('udpsocket',obj.localport);
            
            % Check connection succeeded
            if isempty(obj.udp)
                error('IvSMI connection failed (no handle returned).');
            end
            status = pnet(obj.udp,'status');
            if status <= 0
                error('IvSMI connection failed (status = %i).', status);
            end
            
            % Check connection is working by pinging IviewX
            obj.IVXsend('ET_PNG');
            data = obj.IVXreceive();
            if ~strncmp(data,'ET_PNG',6)
                error('IvSMI:Connection_Failed', 'Failed to connect to SMI eyetracker (ping not returned)');
            end
            
            % ???
            pnet(obj.udp, 'setreadtimeout',obj.udpreadtimeout);
            
            
            % commence eye tracking
            fprintf('   commencing tracking...');
            % 'Specify format of IVX data'
            obj.IVXsend('ET_FRM "%TS %SX %SY"');
            % 'Set screen size'
            sendstr = sprintf('ET_CSZ %d %d', obj.screenHSize_px, obj.screenVSize_px);
            obj.IVXsend(sendstr);
            % % 'Make sure we are not streaming data yet' (turn: datastreamingoff)
            obj.IVXsend('ET_EST');
            % start recording eye position
            obj.IVXsend('ET_REC');

            % clear any outstanding data
            fprintf('   flushing...');
            obj.flush();
            
            % ready to use
            fprintf('   tracking\n');          
        end
        
        function n = reconnect(obj) %#ok  interface implementation
            try
                ETT_stoptracking();
                ETT_disconnect();
            catch ME
                rethrow(ME)
            end
            obj.connect();
        end
        
        function n = refresh(obj, logData) %#ok  interface implementation           
            data = ETT_getdata();
% #####            
% parse and deal with data somehow            
        end
        
        function n = flush(obj) %#ok  interface implementation        
            
            % ' Clear buffer of eye movement recording data'
            IVXsend('ET_CLR', ivx);
            
%             % ???
%             data = IVXreceive(ivx)
% 
%             
n = NaN;
        end
    end

    %% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================    
    
    methods (Access = private)
        
        function [] = IVXsend(obj, sendstr)
            % IVXsend Send string 'sendstr' to the eyetracker. Note:
            %
            %     ET_ACC  accepts calibration point
            %     ET_BRK  cancels calibration
            %     ET_CAL  starts calibration
            %     ET_CHG  indicates calibration point change
            %     ET_CSZ  sets size of calibration area
            %     ET_DEF  resets calibration points to default positions
            %     ET_FIN  indicates end of calibration
            %     ET_LEV  sets check level for calibration
            %     ET_PNT  sets position of calibration point
            %     ET_RCL  starts drift correction
            % 
            % For more on usage, see iViewX.m
            %
            % @param   sendstr
            %
            % @date     21/10/14
            % @author   PRJ
            %

            pnet(obj.udp, 'write',[sendstr char(10)]); % Write to write buffer
            pnet(obj.udp,'writepacket',obj.host,obj.port); % Send buffer as UDP packet
        end
        
        function data = IVXreceive(obj)
            % IVXsend Query the eyetracker for data. Format is...
            %
            % @return   data
            %
            % @date     21/10/14
            % @author   PRJ
            %
            
            % init
            data = [];
            
            % Read data in from the eyetracker
            len = pnet(obj.udp,'readpacket');
            
            % if packet larger then 1(?) byte then read maximum of
            % obj.udpmaxread doubles in network byte order
            if len>0
                data = pnet(obj.udp,'read',obj.udpmaxread);
                
                % "For some god-only-knows reason, I have found that, when
                % sending back ET_VLS, the RED sends back a space which is
                % ASCII character 26 instead of 32. This terminates the string
                % and screws up my code. I will therefore replace ASCII 26 with
                % 32:" - Jenny Read
                data(double(data)<32 | double(data)>127)=32;
            end
        end
        
        function data = IVXreceiveAll(obj)
            error('functionality not yet written. See iViewXComm.m');
        end
        
    end
        
    
    
    


    %% ====================================================================
    %  -----PROTECTED STATIC METHODS-----
    %$ ====================================================================    
    
    methods (Static, Access = protected)
        
        function [] = validate(varargin) % interface implementation           
            % ensure that SDK installed
            if exist('ETT_connect','file')~=2
                error('ETT_connect.m not found on path. Please ensure that the SMI Matlab wrapper is installed');
            end
        end
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================
    
    methods (Static, Access = public)

        function outputs = readRawLog(fullFn) %#ok interface implementation              
            fprintf('\n\n    **this is used to interface with IvRawLog in order to parse raw binary files**\n\n')  
            outputs = [];
        end  
    end
    
end
classdef (Abstract) IvListener < handle
	% Methods for pairing (or unpairing) an arbitrary function with a given
	% broadcaster event name.
    %
    % IvListener Methods:
	%   * startListening    - Inform broadcaster to execute the specified functionHandle whenever a given event with name eventName occurs. 
    %   * stopListening     - Stop listening to broadcast event.
    %   * toggleListening   - Toggle whether or not subscribed to event (if not already subscribed a valid function handle must be supplied).       
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
        listenerHandles = {}    % listener handles
        eventNames = {}         % event names
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
    
        %% == CONSTRUCTOR =================================================

        function [] = delete(obj)
            % Object destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %   
            
            % unsubscribe from *all% events
            for i = 1:length(obj.listenerHandles)
                delete(obj.listenerHandles{i});
            end
            
            % remove handle references
            obj.listenerHandles = [];
            obj.eventNames = [];
        end
        
        %% == METHODS =====================================================

        function [] = startListening(obj, eventName, functionHandle)
            % Inform broadcaster to execute the specified functionHandle
            % whenever a given event with name eventName occurs.
            %
            % @param    eventName       char, name of event 
            % @param    functionHandle	handle to function to execute
            %
            % @date     26/06/14
            % @author   PRJ
            %   
            
            % validate input
            if ismember(eventName, obj.eventNames)
                return
                %error('IvListener:InvalidInput', 'Already listening to %s', eventName);
            end
                
            % subscribe to broadcaster, store handle
            obj.listenerHandles{end+1} = addlistener(ivis.broadcaster.IvBroadcaster.getInstance(), eventName , functionHandle);
            
            % store name
            obj.eventNames{end+1} = eventName;
        end
        
        function [] = stopListening(obj, eventName)
            % Stop listening to broadcast event.
            %
            % @param    eventName       char, name of event
            %
            % @date     26/06/14
            % @author   PRJ
            %      
            
          	% validate input
            if ~ismember(eventName, obj.eventNames)
                return
                %error('IvListener:InvalidInput', 'Not listening for %s', eventName);
            end
               
            % get index
            idx = ismember(obj.eventNames, eventName);
            
            % unsubscribe from broadcaster, remove references
            delete(obj.listenerHandles{idx});
            obj.listenerHandles(idx) = [];
            obj.eventNames(idx) = [];
        end
        
        function [] = toggleListening(obj, eventName, functionHandle)
            % Toggle whether or not subscribed to event (if not already
            % subscribed a valid function handle must be supplied).
            %
            % @param    eventName       char, name of event 
            % @param    functionHandle	handle to function to execute
            %
            % @date     26/06/14
            % @author   PRJ
            %   
            
            if ismember(eventName, obj.eventNames)
                obj.startListening(eventName, functionHandle)
            else
                obj.stopListening(eventName)
            end
        end
        
        function [] = startListeningTo(obj, hostObj, hostProperty, eventName, functionHandle)
            % Add a listener for a property change in a given object
            %
            % @param    hostObj         object to listen for a change in
            % @param    hostProperty	parameter to listen for change in
            % @param    eventName       char, name of event 
            % @param    functionHandle	handle to function to execute
            %
            % @date     26/06/14
            % @author   PRJ
            %   

            % subscribe to broadcaster, store handle
            obj.listenerHandles{end+1} = addlistener(hostObj, hostProperty, eventName, functionHandle);
            % e.g., addlistener(graphicObj, 'nullrect',  'PostSet', @obj.aPostSet_EventHandler);
            
            % store name
            obj.eventNames{end+1} = eventName;
        end
    end
    
end
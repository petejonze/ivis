%# requires XUNIT 3.1

% init
clc
close all
clear all %#ok
    
% check for dependencies
v = ver('xunit');
if isempty(v)
    error('XUnit not detected. The +xunit package must be on the path before continuing');
end
if ~strcmpi(v.Version, '3.1')
    warning('XUnit v%s detected.\nTests were developed using XUnit v3.1\nShall proceed and hope for the best', v.Version);
end

% run tests
runtests('ivis.test','-verbose')
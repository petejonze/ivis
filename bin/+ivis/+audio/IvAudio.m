%  Singleton resposible for loading and playing audio.
% 
%  Is mainly a wrapper for PsychPortAudio, with handy methods for
%  loading files. A simple mechanism for calibration is included, but
%  for simplicity it only supports a single input-output mapping. If you
%  want to independently calibrate different ears or different
%  frequencies, you will have to modify this code.
% 
%  IvAudio Methods:
%    * IvAudio        - Constructor.
%    * enable         - Connect to audio device and store handle.
%    * disable        - Close connection to audio device.
%    * test           - Play tone pip to ensure functions are cached and everything is working.
%    * calibrate      - Fit a calibration function to a two column matrix {rms_in, db_out}.
%    * stop           - Stop audio stream; wrapper for PsychPortAudio('Stop').
%    * play           - Helper/convenience function for playing a sound immediately, via PsychPortAudio.
%    * rampOnOff 	 - Apply a Hann (raised cosine) window to the specified audio vector/matric.
%    * setLevel       - Calibrate the specified audio vector to play at a specified level, given a pre-computed rms-db mapping.
%    * setDefaultLevel- Set the default output level, e.g., if no level is specified when calling obj.play().
%    * wavload        - Load audio stream from specified .wav file.    
% 
%  IvAudio Static Methods:
%    * loadAll       - Helper/convenience function for loading all sounds with a given extension, and in a given directory.
%    * getPureTone   - Get a sine wave with a given frequency/duration.
%    * padChannels   - Expand audio vector/matrix so that rows match N out channels (filling extra channels with zeros).
%    * setRMS        - Set root-mean-square power to a specified value.
%    * UnitTest   	- A simple (temporary?) test, to check that the class works.
% 
%  See Also:
%    ivisDemo_audio.m
% 
%  Author:
%    Pete R Jones <petejonze@gmail.com>
% 
%  Verinfo:
%    1.0 PJ 02/2013 : first_build\n
%    1.1 PJ 06/2013 : updated documentation\n
% 
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
% 
%

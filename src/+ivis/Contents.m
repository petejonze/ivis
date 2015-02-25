% =========================================================================
% ivis package listing [Version 1.4 23-July-2013]
% =========================================================================
%
% VerHistory:	0.1	01-Jan-2013 First iteration [newcastle].
%               0.2	25-Apr-2013 More classifiers
%               0.3	30-Apr-2013 Tweak to Main logic (split initialisation into initialisation and launch)
%               0.4	10-May-2013 Refactored classifier logic (hit function
%                               handles no longer stored inside graphics, and classes moved
%                               to a separate package (+pdf) accordingly. All classifiers
%                               and classifierGUIs now instantiate an improved abstract
%                               class. All now support drawing to the Screen. Added a
%                               smooth-pursuit classifier.
%               0.5 23-Jul-2013 Imnproved package layour. Synched to
%                               GitHub. Improved GUI support (no longer hangs after
%                               repeated screen opening). Improved documentation.
%                               Miscellaneous tweaks and fixes.
%               0.6 19-Jun-2014 Substantial rewrites. Updated
%                               documentation, standardised gui code, refactored logging
%                               and calibration functionality to packages separate from the
%                               datainput class
%
% ivis.audio        - For loading, buffering and playing sounds (via PsychPortAudio).
% ivis.broadcaster	- Mechanism for propogating update commands throughout the system.
% ivis.calibration	- Tools for calibration and drift correction.
% ivis.classifier	- Various ways of deciding between hypotheses based on incoming eyetracking data (e.g., which object looking at).
% ivis.eyetracker	- For extracting and processing incoming data from an external peripheral (e.g., eyetracker or mouse).
% ivis.graphic      - Wrappers of psychtoolbox textures, used as a basic unit by some classifiers.
% ivis.gui          - Swing components for visualising specific objects in a Java frame.
% ivis.log          - Data storage and reading/writing raw (binary) files and data (csv) files.
% ivis.main         - Entry/exit point, used to load ivis and close it down.
% ivis.test         - Unit test functions to ensure code validity [used in development only].
% ivis.math         - Mathematical tility functions.
% ivis.math.pdf     - Various probability density functions used by some classifiers.
% ivis.video        - For loading, buffering and controlling videos (via Psychtoolbox).
%
### Project Description
ivis a Matlab toolbox for running gaze-contingent psychophysical experiments. Key features include:
- A standardised interface for a range of eye-tracking hardware (Tobii, SMI, Eyelink, etc.)
- Automated buffering, smoothing, and storing of eye-tracking data
- Support for manual claibration/drift-correction of the eye-tracker
- Automated classification of eye-movements (e.g., "which object did the user look at"), using a range of techniques
- Automatically updated GUIs, showing where the user is looking, and the state of any classifiers

The toolkit is written in an Object Oriented style, so should be easy to extend/develop, and it incorporates various 'professional' features, such as doxygen documentation, and unit testing.
		
### Quick Start: Setting up
1. Download the toolkit (e.g., by clicking the "Clone or download" button)
2. Unzip it into an appropriate directory (e.g., C:\toolkits\ivis-master\ivis\InstallIvis.m)
3. Run InstallIvis.m (This may prompt you to install any required 3rd-party toolboxes; see below)
4. Test whether it is working by running through the demos in \ivis\demos


### System Requirements
Hardware:
- The system has been developed using a number of eyetrackers (Tobii x120; Tobii EyeX; SMI Red; Eyelink 1000; etc.). It should also be relatively straightforward to extend the system to work with other types of eyetracker (e.g., eyelink). Please contact petejonze@gmail.com for more info.
- Users without an eyetracker to hand can also use the mouse as the data-input device (also useful when debugging)
- Apart from the eyetracker, no specialised equipment is required. However, a modern graphics cards, a dual-monitor setup, and an ASIO compliant soundcard are recommended.
	
Software:
- Matlab 2012 or newer, running on Windows, Mac, or Linux (32 or 64 bit). Note that older versions of Matlab will not work, due to the heavy reliance on relatively modern, Object-Oriented features - sorry. See documentation for a full breakdown of proven systems.

Required matlab toolkits:
- Psychtoolbox
- [Optional] A Matlab binding for your eyetracker (e.g., the Tobii Matlab SDK v3.0)

### For More Information
For info on how to use:
- Run "help demos" in Matlab (without quote marks)
- For more examples, see also the unit-tests in \src\+ivis\+test
	
For technical documentation:
- Run "help ivis" in Matlab (without quote marks)
- See the doxygen file ivis/doc/doxygen/index.html

Any problems or queries:
- Log an issue on the issues page
- and/or e-mail me: petejonze@gmail.com


### Keeping Uptodate
Users familiar with Git can ensure that they are always using the most recent version by subscribing to the central repository, at: https://github.com/petejonze/ivis

### FAQ
**Q** How can I find out more about this code?

**A** E-mail me!

---------------------------

**Q** What should my directory structure look like?

**A** For me, it looks like this:
- Dropbox\MatlabToolkits\ivis-master\ivis\Contents.m
- Dropbox\MatlabToolkits\Psychtoolbox\Contents.m

---------------------------

**Q** How shold I cite this work?

**A** TBA

---------------------------
**Q** I've noticed a bug in file x, what should I do?  

**A** E-mail me a description of the error, including a copy of the MATLAB output if possible. Better yet, fix it and send me the solution. Or best of all, sign up to Git repository and update the primary source code directly.


### Enjoy!
@petejonze  
02/10/2017

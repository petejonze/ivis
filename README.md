### Project Description
ivis a Matlab toolbox for eye-gaze conditional psychophysical experiments. It automates much of the data processing, and provides simple commands for handling common tasks. This makes experiments more reliable and quicker to develop - whole experiments can be written using tens (rather than thousands) of lines of code! Step-by-step examples are provided which show you how to perform tasks such as real-time gaze-classification, saccade-identification, noise-removal, data logging, and much, much more.

The toolkit is written in an Object Oriented style, so should be easy to extend/develop, and it incorporates various 'professional' features, such as Git-based version control, doxygen documentation, and unit testing (i.e., isn't just a bunch of Matlab scripts that I've cobbled together). It's currently very early days, but if you're interested in getting involved or discussing what we're doing, please send me an email: petejonze@gmail.com


		
### Quick Start: Setting up
1. Download the toolkit (using the link on the left) and unzip it into an appropriate directory (e.g., C:\toolkits\ivis)
2. Run InstallIvis.m (This will prompt you to install any required 3rd-party toolboxes; see list below)
3. Test whether it is working by running through the demos in ivisDemos


### System Requirements
Hardware:
- The system has been developed using a Tobii (X120) eyetracker. However, it should be relatively straightforward to extend the system to work with other types of eyetracker (e.g., eyelink). Please contact petejonze@gmail.com for more info.
- Apart from the eyetracker, no specialised equipment is required. However, a modern graphics cards, a dual-monitor setup, and an ASIO compliant soundcard are recommended.
	
Software:
- Matlab 2012 or newer, running on Windows, Mac, or Linux (32 or 64 bit). Note that older versions of Matlab will not work, due to the heavy reliance on relatively modern, Object-Oriented features - sorry. See documentation for a full breakdown of proven systems.

Required matlab toolkits:
- PsychTestRig (optionally bundled with ivis)
- Psychtoolbox
- A Matlab binding for your eyetracker (e.g., the Tobii Matlab SDK v3.0)

		
### For More Information
For info on how to use:
- Run "help ivisDemos" in Matlab (without quote marks)
- See the user guide in ivis/doc/guide
	
For technical documentation:
- Run "help ivis" in Matlab (without quote marks)
- See the doxygen file ivis/doc/doxygen/index.html

Any problems or queries:
- Log an issue on the issues page
- and/or e-mail me: petejonze@gmail.com


### Keeping Uptodate
Users familiar with Git can ensure that they are always using the most recent version by subscribing to the central repository, at: https://github.com/petejonze/ivis

### FAQ
**Q** Is it all very complicated, will I need to know lots of programming?  
**A** Pains have been taken to make the code easy to use, and fully worked examples are given that demonstrate most of the core functions in action. The hope is that the toolkit will do all the boring/complicated stuff -- freeing you to concentrate on designing and running the experiment you want.

---------------------------

**Q** I've noticed a bug in file x, what should I do?  
**A** E-mail and let me know. Better yet, fix it and send me a copy. Or sign up to Git to get direct access to the primary source code.


### Enjoy!
@petejonze  
18/07/2013

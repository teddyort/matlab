Version 1.0
Summary:
Converts text to speech.

Matlab Releases: V7 R14 SP2 and 2010a

Required Products:
Microsoft SAPI / .NET

Description:
Any text is spoken.

Get started ...
1. add the text2speech folder to your Matlab path
2. Test your new function: text2speech('This is a test.')

Get started, if you use SAPI (before .NET)...
1. Make sure SAPI is installed on your computer
   a) get the Speech SDK 5.1 (86MB) for free from Microsoft:
http://www.microsoft.com/downloads/details.aspx?FamilyId=5E86EC97-40A7-453F-B0EE-6583171B4530&displaylang=en
   b) test your default computer voice
Start->Control Panel-> Sounds,Speech...->Speech->Text To Speech->Preview Voice
2. add the text2speech folder to your Matlab path
3. Test your new function: text2speech('This is a test.')

I would like to thank "Desmond Lang" for his Text-To-Speech tutorial
and my wife for letting me play with the computer ;).

You can find Desmond's tutorial at:
http://www.gamedev.net/reference/articles/article1904.asp

Example:
Casual chat.
tts('Hi - how are you?');
tts({'Hello. How are you?','It is nice to speak to you.','regards SAPI.'})

Emphasising (only for the SAPI version)
text2speech('You can <EMPH> emphasis </EMPH> text.');

Silence (only for the SAPI version)
text2speech('There will be silence now <SILENCE MSEC=''500''/> and speech again.');

text2speech('You can <pitch middle=''-10''/> drop the pitch.');
text2speech('But you can make it <pitch middle=''+10''/> jump as well.');


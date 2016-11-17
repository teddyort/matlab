function tts( text )
% This function converts text into speech.
% You can enter any form of text (less than 512 characters per line) into
% this function and it speaks it all.
%
% Note: Requires .NET
%
% Input:
% * text ... text to be spoken (character array, or cell array of characters)
%
% Output:
% * spoken text
%
% Example:
% Casual chat.
% Speak({'Hello. How are you?','It is nice to speak to you.','regards SAPI.'})
%
% Emphasising, silence, pitching, ... can be done (see external links)
%
% TODO: allow the above mentioned changes in voice
%
% See also: initSpeech, unloadSpeechLibrary
%
% External
% Microsoft's TTS Namespace
% http://msdn.microsoft.com/en-us/library/system.speech.synthesis.ttsengine(v=vs.85).aspx
% Microsoft's Synthesizer Class
% http://msdn.microsoft.com/en-us/library/system.speech.synthesis.speechsynthesizer(v=vs.85).aspx
%
%% Signature
% Author: W.Garn
% E-Mail: wgarn@yahoo.com
% Date: 2011/01/25 12:20:00 
% 
% Copyright 2011 W.Garn
%
if nargin<1
    text = 'Please call this function with text';
end
try
    NET.addAssembly('System.Speech');
    Speaker = System.Speech.Synthesis.SpeechSynthesizer;
    if ~isa(text,'cell')
        text = {text};
    end
    for k=1:length(text)
        Speaker.Speak (text{k});
    end
catch
    warning(['If this is not a Windows system or ' ...
        'the .Net class exists you will not be able to use this function.' ...
        'Please let me know what went wrong: wgarn@yahoo.com']);
end


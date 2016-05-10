%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                               %
% CSC401. Statistical Machine Translation                       %
%                                                               %
% Assignemnt 2.                                                 %
% part1. Preprocessing                                          %
%                                                               %
% preprocess.m                                                  %
%                                                               %
% Created by Seungkyu Kim on Mar 6th, 2016                      %
% Copyright 2016 Seungkyu Kim All rights reserved.              %
%                                                               %
%                                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%

  global CSC401_A2_DEFNS
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down 
  inSentence = regexprep( inSentence, '\s+', ' '); 

  % initialize outSentence
  outSentence = inSentence;

  % perform language-agnostic changes
  % e.g., outSentence = regexprep( outSentence, 'TODO', 'TODO');
  
  % add whitespace between final punctuation
  outSentence = regexprep(outSentence, '(.*?)([\.\!?]+) (SENTEND)', '$1 $2 $3');
  
  % add whitespace between non-final punctuation
  outSentence = regexprep(outSentence, '(.*?)([\(\):,;\=<>+-"])(.*?)', '$1 $2 $3');
  
  % add whitespace before and after dashes where in parentheses
  outSentence = regexprep(outSentence, '(.*?\(.*?)(-)(.*?\).*?)', '$1 $2 $3');

  % add whitespace before and after dashes
  outSentence = regexprep(outSentence, '(.*?)(-)(.*?)', '$1 $2 $3'); 
 
  switch language
  	case 'e'
 
		% add space between any non-whitespace character and apostrophe	
		outSentence = regexprep(outSentence, '(.*?[^ ])('')( .*?)', '$1 $2$3');

		% add space between any non-whitespace character and apostrophe with following s, eg dog's -> dog 's
    		outSentence = regexprep(outSentence, '(.*?[^ ])(''s)( .*?)', '$1 $2$3');

		% add space between any non-whitespace character and spostrophe with following ll, eg we'll -> we 'll
    		outSentence = regexprep(outSentence, '(.*?[^ ])(''ll)( .*?)', '$1 $2$3');

		% add space after aphostrophe
    		outSentence = regexprep(outSentence, '(.*?[^ ])(.''.*)( .*?)', '$1 $2$3');

   	case 'f'

		% add space after apostrophe with the leading singular, 'cdjlmnst'
    		outSentence = regexprep(outSentence, '(.*? )([nmctdsjc]'')([^ ].*?)', '$1$2 $3');

		% not be seperated: d'abord, d'accord, d'ailleurs, d'habitude
		outSentence = regexprep(outSentence, '(.*? )(d'') (abord|accord|ailleurs||habitude)( .*?)', '$1$2$3$4');
    		
		% seperate leading qu' from concatenated word
		outSentence = regexprep(outSentence, '(.*? )(qu'')([^ ].*?)', '$1$2 $3');
		
		% seperate following on or il after apostrophe with leading 'lorsqu'
		outSentence = regexprep(outSentence, '(.*? )(lorsqu'')(on|il) ', '$1$2 $3');

		% seperate following on or il after apostrophe with leading 'quisqu'    
		outSentence = regexprep(outSentence, '(.*? )(puisqu'')(on|il) ', '$1$2 $3');
    

  end

  % get rid of extra whitespace since we could have inserted that
  outSentence = regexprep( outSentence, '\s+', ' '); 

  % convert symbols in outSentence
  outSentence = convertSymbols( outSentence );


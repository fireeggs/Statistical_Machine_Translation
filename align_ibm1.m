function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       infoDir      : (directory name) The top-level directory containing 
%                                       info from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/info/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the info structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training info
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter,
    AM = em_step(AM, eng, fre);
  end
  
  disp(AM)
  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
  eng = {};
  fre = {};

  % TODO: your code goes here.
  
  eng_files = dir( [mydir, filesep, '*', 'e'] );
  fre_files = dir( [mydir, filesep, '*', 'f'] );
  
  count_lines = 0;
 
  % Iterate all the English files 
  for i=1:length(eng_files)

	eng_lines = textread( [mydir, filesep, eng_files(i).name], '%s', 'delimiter', '\n');
	fre_lines = textread( [mydir, filesep, fre_files(i).name], '%s', 'delimiter', '\n');
	
	% Iterates lines from English file
	for j=1:length(eng_lines)
	
		% Compute lines up to given numSentences	
		if count_lines <= numSentences

			lines = count_lines + 1;
			eng{lines} = strsplit(preprocess( eng_lines{j}, 'e' ), ' ');
			fre{lines} = strsplit(preprocess( fre_lines{j}, 'f' ), ' ');	
			
			count_lines = count_lines + 1;

		else 
			return
		
		end
	
	end

  end

end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)

    % TODO: your code goes here

	% First count all the word in eng and set up the structure for Eng and Fre words
	for i=1:length(eng)
		
		eng_sentence = eng{i};
		fre_sentence = fre{i};		

		for j=1:length(eng_sentence)
			
			eng_word = eng_sentence{j};

			for k=1:length(fre_sentence)
				
				fre_word = fre_sentence{k};
				
				% assign new struct with given eng and fre word
				if ~isfield( AM, eng_word )
					AM.(eng_word).(fre_word) = 0;
				
				else
					
					if ~isfield( AM.(eng_word), fre_word )
						AM.(eng_word).(fre_word) = 0;
				
					end
				
				end
				
			end

		end

	end	

	% Second, Normalizing and assign its probability to AM	
	total_eng_words = fieldnames(AM);

	for i=1:length(total_eng_words)
		
		eng_word = total_eng_words{i};
		total_fre_words = fieldnames(AM.(eng_word));
		prob = 1 / length(total_fre_words);

		for k=1:length(total_fre_words);
		
			fre_word = total_fre_words{k};
			AM.(eng_word).(fre_word) = prob;
		
		end
	
	end

end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
	
	% TODO: your code goes here
	
	tcount = {};
	total = {};

	for i=1:length(eng)
		
		eng_sentence = eng{i};
		fre_sentence = fre{i};
		
		for j=1:length(eng_sentence)
			
			eng_word = eng_sentence{j};
			
			if ~isfield(total, eng_word)
				total.(eng_word) = 0;
			end
			
			for k=1:length(fre_sentence)
				fre_word = fre_sentence{k};
				
				if ~isfield(tcount, eng_word)
					tcount.(eng_word).(fre_word) = 0;
				else
			
					if ~isfield(tcount.(eng_word), fre_word)
						tcount.(eng_word).(fre_word) = 0;
					end
			
				end

			end

		end

	end

	for i=1:length(eng)

		eng_sentence = eng{i};
		fre_sentence = fre{i};

		uniq_eng_words = unique(eng_sentence(1,:));
		uniq_fre_words = unique(fre_sentence(1,:));
		
		count_eng = cellfun(@(x) sum(ismember(eng_sentence,x)), uniq_eng_words);
		count_fre = cellfun(@(x) sum(ismember(fre_sentence,x)), uniq_fre_words);

		for j=1: length(uniq_fre_words);
	
			fre_word = uniq_fre_words{j};
			denom_c = 0;
			
			for k=1:length(uniq_eng_words)
	
				eng_word = uniq_eng_words{k};
				denom_c = denom_c + t.(eng_word).(fre_word) * count_fre(j);

			end

			for k=1:length(uniq_eng_words)
	
				eng_word = uniq_eng_words{k};
				info = (t.(eng_word).(fre_word) * count_fre(j) * count_eng(k))/denom_c;
				
				tcount.(eng_word).(fre_word) = tcount.(eng_word).(fre_word) + info;
				total.(eng_word) = total.(eng_word) + info;

			end
		
		end
	
	end

	total_eng_words = fieldnames(total);

	for j=1:length(total_eng_words)
	
		eng_word = total_eng_words{j};
		total_fre_words = fieldnames(tcount.(eng_word));

		for k=1:length(total_fre_words)
	
			fre_word = total_fre_words{k};
			t.(eng_word).(fre_word) = tcount.(eng_word).(fre_word) / total.(eng_word);

		end

	end

end

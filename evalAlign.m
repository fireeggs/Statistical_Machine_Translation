%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                               %
% CSC401. Statistical Machine Translation                       %
%                                                               %
% Assignemnt 2.                                                 %
% part5. Translate and Evaluate the Test Data                   %
%                                                               %
% evalAlign.m                                                   %
%                                                               %
% Created by Seungkyu Kim on Mar 15th, 2016                     %
% Copyright 2016 Seungkyu Kim All rights reserved.              %
%                                                               %
%                                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%  This is simply the script (not the function) that you use to perform your evaluations in 

% some of your definitions
trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training/';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing/';
fn_LME       = 'eng_LM';
fn_LMF       = 'fr_LM';
lm_type      = '';
delta        = 0.5;
numSentences = 100;

% Train your language models. This is task 2 which makes use of task 1
disp('>> lm_train()');
% LME = lm_train( trainDir, 'e', fn_LME );
% LMF = lm_train( trainDir, 'f', fn_LMF );

% ============= load LME, LMF, AMFR ================= (need to be removed)

LME = importdata('./Training_part2_e');

AM_1K = importdata('./AM_Training_1K_10');
AM_10K = importdata('./AM_Training_10K_10');
AM_15K = importdata('./AM_Training_15K_10');
AM_30K = importdata('./AM_Training_30K_10');

% ============= load LME, LMF, AMFR ================= (need to be romoved)


vocabSize    = length(fieldnames(LME.uni));
%vocabSize_2    = length(fieldnames(LM.uni));
%vocabSize = 0;

% Train your alignment model of French, given English 

disp('>> align_ibm1()');
%AM_1K = align_ibm1( trainDir, 1000, 10, 'AM_1K');
%AM_10K = align_ibm1( trainDir, 10000, 10, 'AM_10K');
%AM_15K = align_ibm1( trainDir, 15000, 10, 'AM_15K');
%AM_30K = align_ibm1( trainDir, 30000, 10, 'AM_30K');

% a bit more work to grab the English and French sentences. 
% You can probably reuse your previous code for this  

% translate the 25 French sentences in /u/cs401/A2 SMT/data/Hansard/Testing/Task5.f
disp('>> 25 sentences ...');
eng = {};
eng_gg = {}; % gg = google
fre = {};

fid_e = fopen([testDir 'Task5.e']);
fid_e_gg = fopen([testDir 'Task5.google.e']);
fid_f = fopen([testDir 'Task5.f']);

tline_e = fgetl(fid_e);
tline_e_gg = fgetl(fid_e_gg);
tline_f = fgetl(fid_f);
for l = 1:25
    %disp(tline_e)
    eng{l} = preprocess(tline_e, 'e');
    eng_gg{l} = preprocess(tline_e_gg, 'e');
    fre{l} = preprocess(tline_f, 'f');

    tline_e = fgetl(fid_e);
    tline_e_gg = fgetl(fid_e_gg);
    tline_f = fgetl(fid_f);
end

fclose(fid_e);
fclose(fid_e_gg);
fclose(fid_f);

%sizes = {AM_1K, AM_10K, AM_15K, AM_30K};
sizes = {AM_1K}
% Decode the test sentence 'fre'

%sprintf('length of fre_to_eng: %', length(fre_to_eng))
%sprintf('length of eng: %d', length(fre))
disp('decoding...');
fre_to_eng = {};
for i=1:length(sizes)
    temp = {};
    disp('....................................................');
    for j=1:length(fre)
        disp(j);
        temp{j} = decode( fre{j}, LME, sizes{i}, lm_type, delta, vocabSize );
    end
    fre_to_eng{i} = temp;
end

disp('Analyzing...');
for x=1:length(fre_to_eng)
    %disp(x);
    total = 0;
    correct = 0;
    cur_fre = fre_to_eng{x};   
    disp('....................................................');
    for i=1:length(cur_fre)
        decoded_word = cur_fre{i};
        og_word = strsplit(' ', eng{i});
        length_sentence = min(length(og_word), length(decoded_word));
        total = total + length_sentence;
        correct = correct + nnz(strcmp(decoded_word(1:length_sentence), og_word(1:length_sentence)));
        
    end
    disp(correct);
    disp(total)
    accuracy = correct/total;
    
    disp(accuracy);
end

for x=1:length(fre_to_eng)
    disp(x);
    total = 0;
    correct = 0;
    cur_fre = fre_to_eng(x);   
    disp('....................................................');
    for i=1:length(cur_fre)
        decoded_word = cur_fre{i};
        og_word = strsplit(' ', eng_gg{i});
        length_sentence = min(length(og_word), length(decoded_word));
        total = total + length_sentence;
        correct = correct + nnz(strcmp(decoded_word(1:length_sentence), og_word(1:length_sentence)));
    end
    accuracy = correct/total;
    disp(accuracy);
end

%[status, result] = unix('')
                                     

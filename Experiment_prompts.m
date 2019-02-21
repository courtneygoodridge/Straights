choice = menu('Ethics approval has been granted by the School of Psychology Research Ethics Committee', 'Continue')


prompt = {'Participant ID:','Age:', 'Gender', 'Number of months with a UK driving license'}; % prompts
title = 'Demographics'; % title of the box
dims = [1 50]; % dimensions of the box 
definput = {'','', 'Female / Male / Other / Prefer not to say', ''}; % define what input is
answer = inputdlg(prompt,title,dims,definput)

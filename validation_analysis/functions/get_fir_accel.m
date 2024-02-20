function fir_accel = get_fir_accel(subtbl)
redesign = false;
if redesign
    order=27;
    tic
    firf = designfilt('lowpassfir','FilterOrder',order, ...
        'CutoffFrequency',1.2,'SampleRate',10);
    toc
else
    load('..\lookups\firf_27_1pt2Hz.mat','firf')
    order = 27;
end
a_num=diff(subtbl.v)*10; % 0.5 samples late
subtbl.a_fir=filter(firf,[a_num;0]); % +qq-0.5 samples late
% shift a_fir
fir_accel = [subtbl.a_fir((order+1)/2:end);nan((order+1)/2-1,1)];
end
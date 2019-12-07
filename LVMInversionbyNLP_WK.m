clear
clc,close all
load  RCDOeWK_phi.mat
pls=MVM{1};

%We define our desired y vector and mean center scale according to model
%ydes=[0.6739    3.1634]'
%ydes=[0.7    3.1634]'
%ydes=[0.6739    3.4]'
%ydes=[pls.my(1) pls.my(2)]'
ydes=[0.7	0	0	0	0	0	0	0	0	0	0	0]'

%GAMS CODE
YEQ=ydes;
YEQ_WEIGHTS=zeros(12,1);
YEQ_WEIGHTS(1)=5;



cd GamsFiles
XNAMES=DATA{MVM{1}.xid}.varnames;
YNAMES=DATA{MVM{1}.yid}.varnames;

%EXPORT MODEL PARAMETERS
PCNAMES={};
for i=1:size(pls.t,2)
PCNAMES{end+1,1}=['LV',num2str(i)];
end

inctext={};
rcount =1;
inctext{rcount,1}=...
    ['m   REGRESSOR VARIABLES/',XNAMES{1}];
for i=2:length(XNAMES)
    inctext{rcount,1}=[inctext{rcount,1},', ',XNAMES{i}];
end
inctext{rcount,1}=[inctext{rcount,1},'/'];
rcount = rcount +1;
inctext{rcount,1}=...
    ['n   Product Characteristics Data /',YNAMES{1}];
for i=2:length(YNAMES)
    inctext{rcount,1}=[inctext{rcount,1},', ',YNAMES{i}];
end
inctext{rcount,1}=[inctext{rcount,1},'/'];
rcount = rcount +1;
inctext{rcount,1}=['a PC Names /LV1*LV',num2str(size(pls.t,2)),'/'];

fid=fopen('SETStatements.txt','wt');
for i=1:size(inctext,1)
fwrite(fid,inctext{i,1});
fwrite(fid,10,'char');
end
fclose(fid);

fid=fopen('MX.txt','wt');
for i=1:length(XNAMES)
    fwrite(fid,[XNAMES{i},'  ',num2str(pls.mx(i),'%18.13e')],'char');
    fwrite(fid,10,'char');
end
fclose(fid);

fid=fopen('SX.txt','wt');
for i=1:length(XNAMES)
    fwrite(fid,[XNAMES{i},'  ',num2str(pls.sx(i),'%18.13e')],'char');
    fwrite(fid,10,'char');
end
fclose(fid);

fid=fopen('MY.txt','wt');
for i=1:length(YNAMES)
    fwrite(fid,[YNAMES{i},'  ',num2str(pls.my(i),'%18.13e')],'char');
    fwrite(fid,10,'char');
end
fclose(fid);

fid=fopen('SY.txt','wt');
for i=1:length(YNAMES)
    fwrite(fid,[YNAMES{i},'  ',num2str(pls.sy(i),'%18.13e')],'char');
    fwrite(fid,10,'char');
end
fclose(fid);

fid=fopen('SPEXLim99.txt','wt');
fwrite(fid,['SPEXlim99  99% CI for SPEX /',num2str(pls.limits.spe.x(2),'%18.13e'),'/']);
fclose(fid);

fid=fopen('HOT2Xlim99.txt','wt');
fwrite(fid,['HOT2Xlim99  99% CI for HOTT2 /',num2str(pls.limits.hott.x(2),'%18.13e'),'/']);
fclose(fid);


r2ypv=sum(pls.r2ypv,2);
fid=fopen('R2YPV.txt','wt');
for i=1:length(YNAMES)
    fwrite(fid,[YNAMES{i},'  ',num2str(r2ypv(i),'%18.13e')],'char');
    fwrite(fid,10,'char');
end
fclose(fid);

fid=fopen('YEQ.txt','wt');
for i=1:length(YNAMES)
    fwrite(fid,[YNAMES{i},'  ',num2str(YEQ(i),'%18.13e')],'char');
    fwrite(fid,10,'char');
end
fclose(fid);

fid=fopen('YEQ_WEIGHTS.txt','wt');
for i=1:length(YNAMES)
    fwrite(fid,[YNAMES{i},'  ',num2str(YEQ_WEIGHTS(i),'%18.13e')],'char');
    fwrite(fid,10,'char');
end
fclose(fid);

var_t=var(pls.t);
a={};for i=1:length(var_t),a{end+1}=['LV',num2str(i)];end
fid=fopen('VAR_T.txt','wt');
for i=1:length(var_t)
    fwrite(fid,[a{i},'  ',num2str(var_t(i),'%18.13e')],'char');
    fwrite(fid,10,'char');
end
fclose(fid);


writeGamsTable('WS.txt',XNAMES,PCNAMES,pls.ws);
writeGamsTable('Q.txt',YNAMES,PCNAMES,pls.q);
writeGamsTable('P.txt',XNAMES,PCNAMES,pls.p);
[status,result]=system('gams LVMInversionbyNLP-Excercise o LVMInversionbyNLP-Excercise.lst'); 
    load MYGAMSoutput_t.txt
   % load MYGAMSoutput_xnew.txt
    MYGAMSoutput_xnew=((pls.p*MYGAMSoutput_t).*pls.sx')+pls.mx';
    load MYGAMSoutput_minlp_status.txt
    load MYGAMSoutput_y.txt
    load MYGAMSoutput_spex.txt
    load MYGAMSoutput_hott2.txt
    [GamsStatus solmsg] = GetGamsStatus('MYGAMSoutput_minlp_status.txt');
    solmsg
    fprintf('Scores by NLP: \n'); 
    fprintf(['t(1)=',num2str(MYGAMSoutput_t(1)),' \n'])
    fprintf(['t(2)=',num2str(MYGAMSoutput_t(2)),' \n'])
    fprintf(['t(3)=',num2str(MYGAMSoutput_t(3)),' \n'])
    fprintf(['t(4)=',num2str(MYGAMSoutput_t(4)),' \n'])
    fprintf(['t(5)=',num2str(MYGAMSoutput_t(5)),' \n'])
    fprintf(['HotT^2=',num2str(MYGAMSoutput_hott2),' \n']) 
    fprintf('\n');
    
    for j=1:length(ydes)
    fprintf([YNAMES{j},' =',num2str(MYGAMSoutput_y(j)),'\n'])
    end
    
cd ..

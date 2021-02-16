function pure=RunGAMS(PCA,X,Y,wl_axis,PC_axis,samp_axis,comp_axis)
    
writeGamsTable('X.txt',samp_axis,wl_axis,(X))
writeGamsTable('Y.txt',samp_axis,comp_axis,Y)

fid=fopen('SETStatements1.txt','wt');
fwrite(fid,['k Sample /samp1*samp',num2str(size(X,1)),'/']);

for i=1:size(PCA.loads{2,1},2)
    fid=fopen('SETStatements2.txt','wt');
    fwrite(fid,['a PC Names /LV1*LV',num2str(i),'/']);    
    
    writeGamsTable('P.txt',wl_axis,PC_axis(1:i),PCA.loads{2,1}(:,1:i))
    writeGamsTable('VAR_T.txt',PC_axis(1:i),[],[std(PCA.loads{1,1}(:,1:i))]')
    
    [status(i),result]=system('gams PureSpecSearch_2 o PureSpecSearch_2.lst');
    
    load MYGAMSoutput_purex.txt
    pure(i,:,:)=reshape(MYGAMSoutput_purex,size(X,2),size(Y,2));
    i
end
status
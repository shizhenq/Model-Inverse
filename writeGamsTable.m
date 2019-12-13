function writeGamsTable(filename,Rnames,Cnames,Data,varargin)
%function writeGamsTable(filename,Rnames,Cnames,Data,<numdigits>)
spacer=3;
if nargin >4
    numdigits=varargin(4);
else
    numdigits=18;
end
numdigits=numdigits+3;
Rnames=char(Rnames);

%In case column names are too big
if numdigits<size(Cnames,2)
    numdigits=size(Cnames,2)+2;
end

FileHeader=repmat(' ',1,size(Rnames,2));
for i=1:length(Cnames)
    beforespace=floor((numdigits-size(Cnames{i},2))/2);
    afterspace=(numdigits-beforespace-size(Cnames{i},2));
    FileHeader=[FileHeader,repmat(' ',1,spacer),repmat(' ',1,beforespace),Cnames{i},repmat(' ',1,afterspace)];
end
    fid=fopen(filename,'wt');
    fwrite(fid,FileHeader,'char');
    fwrite(fid,10,'char');
maxnumbersize=0;
for i=1:size(Data,1)
    for j=1:size(Data,2)
      thisnumber=strtrim(num2str(Data(i,j),['%+',num2str(numdigits),'.13e']));
      if size(thisnumber,2)>maxnumbersize
          maxnumbersize=size(thisnumber,2);
      end
    end
end
      beforespace=floor((numdigits-maxnumbersize)/2);
      afterspace=(numdigits-beforespace-maxnumbersize);

for i=1:size(Data,1)
    ThisLine=[Rnames(i,:)];
    for j=1:size(Data,2)
      thisnumber=strtrim(num2str(Data(i,j),['%+',num2str(numdigits),'.13e']));
      if size(thisnumber,2)<maxnumbersize
          thisnumber=[thisnumber,repmat(' ',1,maxnumbersize-size(thisnumber,2))];
      end
      ThisLine=[ThisLine,repmat(' ',1,spacer),repmat(' ',1,beforespace),thisnumber,repmat(' ',1,afterspace)];
    end
    fwrite(fid,ThisLine,'char');fwrite(fid,10,'char');
end

    fclose(fid);

function val = readDoubleFromFID(FID, string)

% READDOUBLEFROMFID Read a double from an FID.
%
%	Description:
%
%	VAL = READDOUBLEFROMFID(FID, NAME) reads a double from a stream.
%	 Returns:
%	  VAL - value of variable in file.
%	 Arguments:
%	  FID - stream to read from.
%	  NAME - name of double.
%	
%
%	See also
%	WRITEDOUBLETOFID, READINTFROMFID, READBOOLFROMFID, READSTRINGFROMFID


%	Copyright (c) 2008 Neil D. Lawrence
% 	readDoubleFromFID.m SVN version 23
% 	last update 2008-07-11T15:18:23.000000Z
  
val = str2num(readStringFromFID(FID, string));

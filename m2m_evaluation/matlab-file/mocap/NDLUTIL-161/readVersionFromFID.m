function val = readVersionFromFID(FID)

% READVERSIONFROMFID Read version number from an FID.
%
%	Description:
%
%	VAL = READVERSIONFROMFID(FID) reads version number from a stream.
%	 Returns:
%	  VAL - value of variable in file.
%	 Arguments:
%	  FID - stream to read from.
%	
%
%	See also
%	WRITEVERSIONTOFID, READDOUBLEFROMFID, READSTRINGFROMFID


%	Copyright (c) 2008 Neil D. Lawrence
% 	readVersionFromFID.m SVN version 23
% 	last update 2008-07-11T15:18:53.000000Z
  
val = str2num(readStringFromFID(FID, 'version'));

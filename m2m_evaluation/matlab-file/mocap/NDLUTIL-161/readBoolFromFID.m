function val = readBoolFromFID(FID, string)

% READBOOLFROMFID Read a boolean from an FID.
%
%	Description:
%
%	VAL = READBOOLFROMFID(FID, NAME) reads a boolean from a stream.
%	 Returns:
%	  VAL - value of variable in file.
%	 Arguments:
%	  FID - stream to read from.
%	  NAME - name of boolean.
%	
%
%	See also
%	WRITEBOOLTOFID, READINTFROMFID, READDOUBLEFROMFID


%	Copyright (c) 2008 Neil D. Lawrence
% 	readBoolFromFID.m SVN version 23
% 	last update 2008-07-11T15:18:36.000000Z

  
val = str2num(readStringFromFID(FID, string));

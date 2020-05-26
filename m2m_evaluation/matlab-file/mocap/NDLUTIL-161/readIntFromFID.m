function val = readIntFromFID(FID, string)

% READINTFROMFID Read an integer from an FID.
%
%	Description:
%
%	VAL = READINTFROMFID(FID, NAME) reads an integer from a stream.
%	 Returns:
%	  VAL - value of variable in file.
%	 Arguments:
%	  FID - stream to read from.
%	  NAME - name of integer.
%	readBoolFromFID, readStringFromFID
%	
%
%	See also
%	WRITEINTTOFID, READDOUBLEFROMFID, READINTFROMFID, 


%	Copyright (c) 2008 Neil D. Lawrence
% 	readIntFromFID.m SVN version 23
% 	last update 2008-07-11T15:19:53.000000Z
  
  
val = str2num(readStringFromFID(FID, string));

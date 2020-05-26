function writeStringToFID(FID, name, val)

% WRITESTRINGTOFID Writes a string to an FID.
%
%	Description:
%
%	WRITESTRINGTOFID(FID, NAME, VAL) writes an string from a stream.
%	 Arguments:
%	  FID - stream to write from.
%	  NAME - name of string.
%	  VAL - value of variable to place in file.
%	
%
%	See also
%	READSTRINGFROMFID, WRITEINTTOFID, WRITEBOOLTOFID, WRITEDOUBLETOFID


%	Copyright (c) 2008 Neil D. Lawrence
% 	writeStringToFID.m SVN version 23
% 	last update 2008-07-11T15:18:17.000000Z
  
fprintf(FID, [name '=' val '\n']);

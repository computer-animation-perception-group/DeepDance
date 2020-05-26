function writeDoubleToFID(FID, name, val)

% WRITEDOUBLETOFID Writes a double to an FID.
%
%	Description:
%
%	WRITEDOUBLETOFID(FID, NAME, VAL) writes a double to a stream.
%	 Arguments:
%	  FID - stream to write to.
%	  NAME - name of double.
%	  VAL - value of variable to place in file.
%	
%
%	See also
%	READDOUBLEFROMFID, WRITESTRINGTOFID, WRITEBOOLTOFID, WRITEINTTOFID


%	Copyright (c) 2008 Neil D. Lawrence
% 	writeDoubleToFID.m SVN version 23
% 	last update 2008-07-11T15:19:26.000000Z
  
writeStringToFID(FID, name, num2str(val));

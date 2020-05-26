function writeVersionToFID(FID, val)

% WRITEVERSIONTOFID Writes a version to an FID.
%
%	Description:
%
%	WRITEVERSIONTOFID(FID, VAL) writes a version from a stream.
%	 Arguments:
%	  FID - stream to write to.
%	  VAL - value of version to place in file.
%	
%
%	See also
%	READVERSIONFROMFID, WRITESTRINGTOFID


%	Copyright (c) 2008 Neil D. Lawrence
% 	writeVersionToFID.m SVN version 23
% 	last update 2008-07-11T15:19:19.000000Z
  
writeStringToFID(FID, 'version', num2str(val));
  

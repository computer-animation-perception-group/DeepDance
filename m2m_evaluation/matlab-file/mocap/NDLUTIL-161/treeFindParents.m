function tree = treeFindParents(tree)

% TREEFINDPARENTS Given a tree that lists only children, add parents.
%
%	Description:
%
%	TREE = TREEFINDPARENTS(TREE) takes a tree structure which lists the
%	parents of each node and computes the children for each node and
%	places them in.
%	 Returns:
%	  TREE - a tree that lists parents and children.
%	 Arguments:
%	  TREE - the tree that lists only parents.
%	
%
%	See also
%	TREEFINDCHILDREN


%	Copyright (c) 2005, 2006 Neil D. Lawrence
% 	treeFindParents.m CVS version 1.1
% 	treeFindParents.m SVN version 22
% 	last update 2007-11-03T14:26:09.000000Z

for i = 1:length(tree)
  for j = 1:length(tree(i).children)
    if tree(i).children(j)
      tree(tree(i).children(j)).parent ...
          = [tree(tree(i).children(j)).parent i];
    end
  end
end


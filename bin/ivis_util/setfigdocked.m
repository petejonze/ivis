%    SETFIGDOCKED docks figures at specified positions in group of figures whose
%    structure is defined by parameters GridSize, Spanned Cells, ...
%    This function also allows maximizing and docking groups into MATLAB desktop
% 
%    This function runs on MATLAB 7.1 sp3 or higher
% 
%    group = setfigdocked('PropertyName1',value1,'PropertyName2',value2,...)
%    PropertyName:
%        - GroupName     name of group need to be generated
%        - GridSize      scalar or vector quantity, defines number of rows
%                        and columns of cell in group
%        - SpanCell      vector or matrix quantity, size n x 4,
%                        [row col occupiedrows occupiedcols]
%                        build an cell at the position (row, col) in group
%                        cell (GridSize) which occupies "occupiedrows"
%                        rows and "occupiedcols" columns
%        - Figure        handle of figure
%        - Figindex      index position of figure in group cell
%        - Maximize      0/1
%        - GroupDocked   0/1
% 
%    Examples:
%       Example 1:
%            %creates empty group 'Group of Images'with 2 rows and 3 columns
%            group = setfigdocked('GroupName','Group of Images','GridSize',[2 3]);
%            im1 = imread('cameraman.tif');
%            imshow(im1)
%            group = setfigdocked('GroupName','Group of Images','Figure',gcf);
%            figure; imhist(im1)
%            group = setfigdocked('GroupName','Group of Images','Figure',gcf,'Figindex',4);
% 
%            im2 = imread('rice.png');
%            figure; imshow(im2)
%            group = setfigdocked('GroupName','Group of Images','Figure',gcf,'Figindex',2);
%            figure; imhist(im2)
%            group = setfigdocked('GroupName','Group of Images','Figure',gcf,'Figindex',5);
% 
%            im3 = imread('eight.tif');
%            figure; imshow(im3)
%            group = setfigdocked('GroupName','Group of Images','Figure',gcf,'Figindex',3);
%            figure; imhist(im3)
%            group = setfigdocked('GroupName','Group of Images','Figure',gcf,'Figindex',6);
% 
% 
%       Example 2:
%           group = setfigdocked('GroupName','Image and Edges','GridSize',3,'SpanCell',[1 2 2 2]);
%           im1 = imread('cameraman.tif');
%           figure;imshow(im1);set(gcf,'Name','Cameraman','NumberTitle','off')
%           group = setfigdocked('GroupName','Image and Edges','Figure',gcf,'Figindex',2);
% 
%           figure; edge(im1,'prewitt');set(gcf,'Name','Prewitt method','NumberTitle','off')
%           group = setfigdocked('GroupName','Image and Edges','Figure',gcf,'Figindex',1);
% 
%           figure; edge(im1,'roberts');set(gcf,'Name','Roberts method','NumberTitle','off')
%           group = setfigdocked('GroupName','Image and Edges','Figure',gcf,'Figindex',3);
% 
%           figure; edge(im1,'roberts');set(gcf,'Name','Roberts method','NumberTitle','off')
%           group = setfigdocked('GroupName','Image and Edges','Figure',gcf,'Figindex',4);
% 
%           figure; edge(im1,'roberts');set(gcf,'Name','Roberts method','NumberTitle','off')
%           group = setfigdocked('GroupName','Image and Edges','Figure',gcf,'Figindex',5);
% 
%           figure; edge(im1,'canny');set(gcf,'Name','Canny Method','NumberTitle','off')
%           group = setfigdocked('GroupName','Image and Edges','Figure',gcf,'Figindex',6);
% 
%           group = setfigdocked('GroupName','Image and Edges','Maximize',1,'GroupDocked',0);
%

function [h,e] = calculateCM(img1,img2)
%input i, h, k=0 ,ro>1
    
    tic;
    [h mappedImg2] = homography( img1, img2);
    e = double((-1) .* img2 + mappedImg2);
    e = e(:,:,1);
    
    nrIteration = 10;
    J = zeros(length(e(:,1)),length(e(1,:)),nrIteration)+0.1;

    sigma = zeros(length(e(:,1)),length(e(1,:)),nrIteration);
    enext = zeros(length(e(:,1)),length(e(1,:)),nrIteration);
    ro = 1.1;
    k = 1;
    m = 1;
    dh = 0.1;
        
%     while k<nrIteration 
%         wim1 = (imTrans(double(img1),(h)));
%         wim1 = imresize(wim1,[size(img1,1) size(img1,2)],'bicubic');
        
%         syms x y z;
%         f = h*[x y z]';
%         J = jacobian(f,[x y z]');
%         x = 1; y = 1; z = 1;
%         a = eval(f);
%         J = conv2(double(img2(:,:,1)),a,'same');
%         sigma = double(img2(:,:,1) - wim1(:,:,1));
% 
%         J = 0.1;
%         sigma = -e;
%         
%         sigma(:,1,k) = sigma(:,1,k) + 0.1;
%         J(:,:,k) = ( sigma(:,:,k) + e(:,:)) /dh(1,m)+0.1;
%         
%         m = 1;
%         dh = zeros(1,nrIteration);
%         lambda = zeros(1,nrIteration)+0.1;
%         mu = zeros(1,nrIteration)+0.1;
%         enext(:,:,1) = e; 
%         
%         while m<nrIteration
%     
%             enext(:,:,m+1) = S( mu(m) , ( J(:,:) * dh(m) - sigma(:,:) + mu(m)*lambda(m)/2 ) );
% %             dh(m+1) = mean(mean( ( J(:,:)' * J(:,:) ) \ J(:,:)' * ( sigma(:,:) + enext(:,:,m+1) - lambda(m)/mu(m)) ));
%             dh(m+1) = mean(mean( ( sigma(:,:) + enext(:,:,m+1) - lambda(m)/mu(m)) ));
% 
%             lambda(m+1) = mean(mean(mean(lambda(m) + mu(m) * ( J(:,:) * dh(m+1) - sigma(:,:) - enext(:,:,m+1) )))); 
%             mu(m+1) = ro*mu(m);
%             m = m+1;
%         end
%         h = h + dh(m);
%         e = enext(:,:,m);
%         k = k+1;
%     end
    toc;
end


function [e]= S(mu ,nr)
    e = nr-mu;
    e(e<0) = 0;
end


%%

% IMTRANS - Homogeneous transformation of an image.
%
% Applies a geometric transform to an image
%
%  [newim, newT] = imTrans(im, T, region, sze);
%
%  Arguments: 
%        im     - The image to be transformed.
%        T      - The 3x3 homogeneous transformation matrix.
%        region - An optional 4 element vector specifying 
%                 [minrow maxrow mincol maxcol] to transform.
%                 This defaults to the whole image if you omit it
%                 or specify it as an empty array [].
%        sze    - An optional desired size of the transformed image
%                 (this is the maximum No of rows or columns).
%                 This defaults to the maximum of the rows and columns
%                 of the original image.
%
%  Returns:
%        newim  - The transformed image.
%        newT   - The transformation matrix that relates transformed image
%                 coordinates to the reference coordinates for use in a
%                 function such as DIGIPLANE.
%
%  The region argument is used when one is inverting a perspective
%  transformation of a plane and the vanishing line of the plane lies within
%  the image.  Attempts to transform any part of the vanishing line will
%  position you at infinity.  Accordingly one should specify a region that
%  excludes any part of the vanishing line.
%
%  The sze parameter is optionally used to control the size of the
%  output image.  When inverting a perpective or affine transformation
%  the scale parameter is unknown/arbitrary, and without specifying
%  it explicitly the transformed image can end up being very small 
%  or very large.
%
%  Problems: If your transformed image ends up as being two small bits of
%  image separated by a large black area then the chances are that you have
%  included the vanishing line of the plane within the specified region to
%  transform.  If your image degenerates to a very thin triangular shape
%  part of your region is probably very close to the vanishing line of the
%  plane.

% Copyright (c) 2000-2005 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% http://www.csse.uwa.edu.au/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% April 2000 - original version.
% July 2001  - transformation of region boundaries corrected.

function [newim, newT] = imTrans(im, T, region, sze);

if isa(im,'uint8')
    im = double(im);  % Make sure image is double     
end

% Set up default region and transformed image size values
if ndims(im) == 3
    [rows cols depth] = size(im);
else
    [rows cols] = size(im);
    depth = 1;
end

if nargin == 2
    region = [1 rows 1 cols];
    sze = max([rows cols]);
elseif nargin == 3    
    sze = max([rows cols]);
end

if isempty(region)
    region = [1 rows 1 cols];
end

	
threeD = (ndims(im)==3);  % A colour image
if threeD    % Transform red, green, blue components separately
    im = im/255;  
    [r, newT] = transformImage(im(:,:,1), T, region, sze);
    [g, newT] = transformImage(im(:,:,2), T, region, sze);
    [b, newT] = transformImage(im(:,:,3), T, region, sze);
    
    newim = repmat(uint8(0),[size(r),3]);
    newim(:,:,1) = uint8(round(r*255));
    newim(:,:,2) = uint8(round(g*255));
    newim(:,:,3) = uint8(round(b*255));
    
else                % Assume the image is greyscale
    [newim, newT] = transformImage(im, T, region, sze);
end
end

%------------------------------------------------------------

% The internal function that does all the work

function [newim, newT] = transformImage(im, T, region, sze);

[rows, cols] = size(im);

if 0
% Determine default parameters if needed
if nargin == 2
  region = [1 rows 1 cols];
  sze = max(rows,cols);
elseif nargin == 3
  sze = max(rows,cols);
elseif nargin ~= 4
  error('Incorrect arguments to imtrans');
end
end
% Cut the image down to the specified region
%if nargin == 3 | nargin == 4
    im = im(region(1):region(2), region(3):region(4));
    [rows, cols] = size(im);
%end

% Find where corners go - this sets the bounds on the final image
B = bounds(T,region);
nrows = B(2) - B(1);
ncols = B(4) - B(3);

% Determine any rescaling needed
s = sze/max(nrows,ncols);

S = [s 0 0        % Scaling matrix
     0 s 0
     0 0 1];

T = S*T;
Tinv = inv(T);

% Recalculate the bounds of the new (scaled) image to be generated
B = bounds(T,region);
nrows = B(2) - B(1);
ncols = B(4) - B(3);

% Construct a transformation matrix that relates transformed image
% coordinates to the reference coordinates for use in a function such as
% DIGIPLANE.  This transformation is just an inverse of a scaling and
% origin shift. 
newT=inv(S - [0 0 B(3); 0 0 B(1); 0 0 0]);

% Set things up for the image transformation.
newim = zeros(nrows,ncols);
[xi,yi] = meshgrid(1:ncols,1:nrows);    % All possible xy coords in the image.

% Transform these xy coords to determine where to interpolate values
% from. Note we have to work relative to x=B(3) and y=B(1).
sxy = homoTrans(Tinv, [xi(:)'+B(3) ; yi(:)'+B(1) ; ones(1,ncols*nrows)]);
xi = reshape(sxy(1,:),nrows,ncols);
yi = reshape(sxy(2,:),nrows,ncols);

[x,y] = meshgrid(1:cols,1:rows);
x = x+region(3)-1; % Offset x and y relative to region origin.
y = y+region(1)-1; 
newim = interp2(x,y,double(im),xi,yi); % Interpolate values from source image.


% Plot bounding region
%P = [region(3) region(4) region(4) region(3)
%     region(1) region(1) region(2) region(2)
%      1    1    1    1   ];
%B = round(homoTrans(T,P));
%Bx = B(1,:);
%By = B(2,:);
%Bx = Bx-min(Bx); Bx(5)=Bx(1);
%By = By-min(By); By(5)=By(1);
%show(newim,2), axis xy
%line(Bx,By,'Color',[1 0 0],'LineWidth',2);
% end plot bounding region

end


%---------------------------------------------------------------------
%
% Internal function to find where the corners of a region, R
% defined by [minrow maxrow mincol maxcol] are transformed to 
% by transform T and returns the bounds, B in the form 
% [minrow maxrow mincol maxcol]

function B = bounds(T, R)

P = [R(3) R(4) R(4) R(3)      % homogeneous coords of region corners
     R(1) R(1) R(2) R(2)
      1    1    1    1   ];
     
PT = round(homoTrans(T,P)); 

B = [min(PT(2,:)) max(PT(2,:)) min(PT(1,:)) max(PT(1,:))];
%      minrow          maxrow      mincol       maxcol  

end

%%

% HOMOTRANS - homogeneous transformation of points
%
% Function to perform a transformation on homogeneous points/lines
% The resulting points are normalised to have a homogeneous scale of 1
%
% Usage:
%           t = homoTrans(P,v);
%
% Arguments:
%           P  - 3 x 3 or 4 x 4 transformation matrix
%           v  - 3 x n or 4 x n matrix of points/lines

%  Peter Kovesi
%  School of Computer Science & Software Engineering
%  The University of Western Australia
%  pk @ csse uwa edu au
%  http://www.csse.uwa.edu.au/~pk
%
%  April 2000
%  September 2007

function t = homoTrans(P,v)
    
    [dim,npts] = size(v);
    
    if ~all(size(P)==dim)
	error('Transformation matrix and point dimensions do not match');
    end

    t = P*v;  % Transform

    for r = 1:dim-1     %  Now normalise    
	t(r,:) = t(r,:)./t(end,:);
    end
    
    t(end,:) = ones(1,npts);
    
    
end

%%

function [ BB ] = calcbb( H, im )
%CALCBB Compute bounding box

[imwidth imheight tempx] = size(im);

% Bounding box calculation

xmax=0;
ymax=0;
xmin=0;
ymin=0;

% Transform Point(1,1)
	oldPoint = [1; 1; 1];
	newPoint= H* oldPoint;
	newPoint= newPoint/newPoint(3);

if (newPoint(1) < xmin) 
        xmin = newPoint(1);
end
if (newPoint(2) < ymin) 
        ymin = newPoint(2);
end
if (newPoint(1) > xmax) 
        xmax = newPoint(1);
end
if (newPoint(2) > ymax) 
        ymax = newPoint(2);
end
    
% Transform Point(1,imheight)
	oldPoint = [1; imheight; 1];
	newPoint= H* oldPoint;
	newPoint= newPoint/newPoint(3);

if (newPoint(1) < xmin) 
        xmin = newPoint(1);
end
if (newPoint(2) < ymin) 
        ymin = newPoint(2);
end
if (newPoint(1) > xmax) 
        xmax = newPoint(1);
end
if (newPoint(2) > ymax) 
        ymax = newPoint(2);
end

% Transform Point(imwidth,1)
	oldPoint = [imwidth; 1; 1];
	newPoint= H* oldPoint;
	newPoint= newPoint/newPoint(3);

if (newPoint(1) < xmin) 
        xmin = newPoint(1);
end
if (newPoint(2) < ymin) 
        ymin = newPoint(2);
end
if (newPoint(1) > xmax) 
        xmax = newPoint(1);
end
if (newPoint(2) > ymax) 
        ymax = newPoint(2);
end

% Transform Point(imwidth,imheight)
	oldPoint = [imwidth; imheight; 1];
	newPoint= H* oldPoint;
	newPoint= newPoint/newPoint(3);

if (newPoint(1) < xmin) 
        xmin = newPoint(1);
end
if (newPoint(2) < ymin) 
        ymin = newPoint(2);
end
if (newPoint(1) > xmax) 
        xmax = newPoint(1);
end
if (newPoint(2) > ymax) 
        ymax = newPoint(2);
end

BB = [xmin, xmax; ymin, ymax];

% End of BB calculation


end



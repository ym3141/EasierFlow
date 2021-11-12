function [D,xfull,yfull] = density (d,Nres)
    if nargin==1
        Nres=100;
    end
    dsize=min(size(d,1),10000);
    d=d(randperm(dsize),:);
    %generate the grid points
    xfull=linspace(min(d(:,1)),max(d(:,1)),Nres);
    yfull=linspace(min(d(:,2)),max(d(:,2)),Nres);
    [xfull,yfull]=meshgrid(xfull,yfull);

    dnorm=bsxfun(@rdivide,bsxfun(@minus,d,min(d)),range(d));
    x=linspace(0,1,Nres);
    y=linspace(0,1,Nres);
    [x,y]=meshgrid(x,y);
    [lx,ly]=size(x);
    gridpoints=[x(:),y(:)];

    %find the nearest neighbours
    Nnn=round(sqrt(length(dnorm)));
    [nn100,nndist]=knnsearch(dnorm,gridpoints,'K',Nnn);
    nndist=nndist(:,end);
    nndist=reshape(nndist,lx,ly);
    D=1./nndist;
    %contour(x,y,log(nndist),-1:-0.4:-3)
end
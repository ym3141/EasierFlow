function fcscontour(xdat,ydat,ycolor,varargin)
% draw a contour for a fcs data array.
% FCSCONTOUR(xdat,ydat) draws a contour for the two data vectors
% FCSCONTOUR(data,xcolor,ycolor) draws the xcolor and ycolor from the
% data array
%
%optional arguments can also be 'dotplot','contour','contourf','colordotplot'
%than we can have xaxis and yaxis scalings as 'lin' 'log' 'logicle' for x
%and  'ylin' 'ylog' ylogicle' for y, each followed by parameters
%

%parse input parameters
if size(xdat,2)>1
    xcolor=ydat;
    ydat=xdat(:,ycolor);
    xdat=xdat(:,xcolor);
elseif nargin==3
    varargin={ycolor};
elseif nargin>3
    varargin=[{ycolor} varargin];
end
%parse varargin - the optional parameters
option='contour';
xscalefun=@linearscale;
xtickfun=@lineartick;
yscalefun=@linearscale;
ytickfun=@lineartick;
xprm=[];
yprm=[];
for inputstr=find(cellfun(@ischar,varargin))
    switch varargin{inputstr}
        case 'lin'
            xscalefun=@linearscale;
            xtickfun=@lineartick;
            if size(varargin,2)>inputstr && isnumeric(varargin{inputstr+1})
                xprm=varargin{inputstr+1};
            end
        case 'log'
            xscalefun=@logscale;
            xtickfun=@logtick;
            if size(varargin,2)>inputstr && isnumeric(varargin{inputstr+1})
                xprm=varargin{inputstr+1};
            end
        case 'logicle'
            xscalefun=@logicle;
            xtickfun=@logicletick;
            if size(varargin,2)>inputstr && isnumeric(varargin{inputstr+1})
                xprm=varargin{inputstr+1};
            end
        case 'ylin'
            yscalefun=@linearscale;
            ytickfun=@lineartick;
            if size(varargin,2)>inputstr && isnumeric(varargin{inputstr+1})
                yprm=varargin{inputstr+1};
            end
        case 'ylog'
            yscalefun=@logscale;
            ytickfun=@logtick;
            if size(varargin,2)>inputstr && isnumeric(varargin{inputstr+1})
                yprm=varargin{inputstr+1};
            end
        case 'ylogicle'
            yscalefun=@logicle;
            ytickfun=@logicletick;
            if size(varargin,2)>inputstr && isnumeric(varargin{inputstr+1})
                yprm=varargin{inputstr+1};
            end
        otherwise
            option=varargin{inputstr};
    end
end
%parse xprm and yprm
switch length(xprm)
    case 3
        xmin=xprm(1);
        xmax=xprm(2);
        xprm=xprm(3);
    case 2
        xmin=xprm(1);
        xmax=xprm(2);
        xprm=[];
    case 1
        xmin=min(xdat);
        xmax=max(xdat);
    otherwise
        xmin=min(xdat);
        xmax=max(xdat);
        xprm=[];
end
switch length(yprm)
    case 3
        ymin=yprm(1);
        ymax=yprm(2);
        yprm=yprm(3);
    case 2
        ymin=yprm(1);
        ymax=yprm(2);
        yprm=[];
    case 1
        ymin=min(ydat);
        ymax=max(ydat);
    otherwise
        ymin=min(ydat);
        ymax=max(ydat);
        yprm=[];
end
%make the minvalue and maxvalue within the range of samples
xmax=min(xmax,max(xdat));
xmin=max(xmin,min(xdat));
ymax=min(ymax,max(ydat));
ymin=max(ymin,min(ydat));

%take the data in the wanted range only and rescale it
xdat=xscalefun(xdat,xprm);
ydat=yscalefun(ydat,yprm);
inrange=xdat<xscalefun(xmax,xprm) & xdat>xscalefun(xmin,xprm) & ydat<yscalefun(ymax,yprm) & ydat>yscalefun(ymin,yprm);
xdat=xdat(inrange);
ydat=ydat(inrange);

switch option
    case {'dotplot', 'Dot Plot'}
    otherwise
        [mhist,Xm,Ym]=density([xdat,ydat]);
        mhist(isinf(mhist))=0;
        %create x,y indices
        yint=min(max(1,ceil(100*(ydat-min(ydat))/(max(ydat)-min(ydat)))),100);
        xint=min(max(1,ceil(100*(xdat-min(xdat))/(max(xdat)-min(xdat)))),100);
end

switch option
    case {'dotplot', 'Dot Plot'}
        plot(xdat,ydat,'.','MarkerSize',1);
    case {'contourf', 'Filled Contour'}
        [cntr,cntrh]=contourf(Xm,Ym,mhist,10);
        set(cntrh,'LineStyle','none');
    case {'colordotplot' 'Colored Dot Plot'}
        scatter(xdat,ydat,1,(mhist(sub2ind([100 100],yint,xint))));
    otherwise
        plot(xdat,ydat,'.','MarkerSize',1);
        hold on
        contour(Xm,Ym,mhist,10);
        hold off
end
%set labeling of the axes
xtickfun(xmin,xmax,xprm,'X');
ytickfun(ymin,ymax,yprm,'Y');


%these function are the scaling functions.
%INPUT:
%  x a vector or scalar to be transformed
%  prm parameters for the transformation
    function y=linearscale(x,prm)
        y=x;
    end
    function y=logscale(x,prm)
        %  if only a number, returns zero for values less than 1
        %  for an array, returns the log for the positive ones, and -Inf for the
        %  negative ones, thus any number below one is negative and will be
        %  dropped.
        if isscalar(x)
            y=0;
            y(x>1)=log10(x);
        else
            y=log10(x);
            y(x<0)=-Inf;
        end
    end
    function y=logicle(x,prm)
        if ~isscalar(prm)
            prm=1;
        end
        %divide by log10(exp(1)) to get asymptotically to log10
        %divide the argument by 2 to get to log10(x)
        %
        %a is a coefficient that stretches the zero
        %
        %to get from this value back to the original data do:
        % x= 2*sinh(log(10)*y)/prm
        y=asinh(prm*x/2)/log(10);
    end

%these functions set the ticks and labeling for the graphs
%INPUT:
%  minvalue, maxvalue
%  prm parameters for the transformation
%note: for now just ignores the parameters and labels until 1e7.
    function lineartick(minvalue,maxvalue,prm,dim)
        axis auto
    end
    function logtick(minvalue,maxvalue,prm,dim)
        %only strat at 1
        ticksnum=floor(logscale(minvalue,prm)):ceil(logscale(maxvalue,prm));
        nticks=range(ticksnum)+1;
        ticksl=cell(9,nticks);
        ticksl(1,:)=arrayfun(@(x) sprintf('10^{%d}',x),ticksnum,'unif',0);
        ticks=bsxfun(@times,(1:9)',10.^ticksnum);
        set(gca,[dim 'Tick'],logscale(ticks(:),prm))
        set(gca,[dim 'TickLabel'],ticksl)
    end
    function logicletick(minvalue,maxvalue,prm,dim)
        if maxvalue>0
            ticksnumpos=floor(log10(2.2/prm)):ceil(log10(maxvalue));
            ntickspos=range(ticksnumpos)+1;
            tickslpos=cell(9,ntickspos);
            tickslpos(1,:)=arrayfun(@(x) sprintf('10^{%d}',x),ticksnumpos,'unif',0);
            tickspos=bsxfun(@times,(1:9)',10.^ticksnumpos);
        else
            tickspos=[];
            tickslpos=[];
        end
        if minvalue<0
            ticksnumneg=floor(log10(2.2/prm)):ceil(log10(-minvalue));
            nticksneg=range(ticksnumneg)+1;
            tickslneg=cell(9,nticksneg);
            tickslneg(1,:)=arrayfun(@(x) sprintf('10^{%d}',x),ticksnumneg,'unif',0);
            ticksneg=bsxfun(@times,(1:9)',10.^ticksnumneg);
        else
            ticksneg=[];
            tickslneg=[];
        end

        ticks=[-reshape(ticksneg(end:-1:1), 1, []) 0 tickspos(:)'];
        set(gca,[dim 'Tick'],logicle(ticks,prm))
        set(gca,[dim 'TickLabel'],[reshape(tickslneg(end:-1:1),[],1);{0};tickslpos(:)])
    end

end

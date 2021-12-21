function [hout,binsout]=fcshist(varargin)
    %plot a histogram.
    %
    %fcshist(vec1,vec2,vec3,...,vecn)
    %   plots all vectors
    %fcshist(array,c1,c2,c3,...,cn)
    %   plots columns c from array
    %
    %last param can be 'log','lin','logicle',
    %the next one can be parameters, which are [minvalue, maxvalue, param];
    %and the next is the y scaling 'ylin' or 'ylog'
    %
    %also can have 'smooth',smooth_prm. where smooth_prm is the approximate
    %mean amount of equivalent counts in a bin. default 700. for no smooth,
    %smooth_prm=0;
    %
    %and 'norm',normprm. normprm is the fraction of the input from a larger
    %dataset, such that the sum over the histogram will be proportional to.
    %

    %parse input variables
    smooth_prm=700;
    normprm=1;
    scalefun=@linearscale;
    tickfun=@lineartick;
    param=[];
    yscale='lin';
    for inputstr=find(cellfun(@ischar,varargin))
        switch varargin{inputstr}
            case 'smooth'
                if size(varargin,2)>inputstr && ~ischar(varargin{inputstr+1}) && varargin{inputstr+1}>=0
                    smooth_prm=varargin{inputstr+1};
                end
            case 'norm'
                if size(varargin,2)>inputstr && ~ischar(varargin{inputstr+1})
                    normprm=varargin{inputstr+1};
                end
            case 'log'
                scalefun=@logscale;
                tickfun=@logtick;
                if size(varargin,2)>inputstr && ~ischar(varargin{inputstr+1})
                    param=varargin{inputstr+1};
                end
            case 'lin'
                scalefun=@linearscale;
                tickfun=@lineartick;
                if size(varargin,2)>inputstr && ~ischar(varargin{inputstr+1})
                    param=varargin{inputstr+1};
                end
            case 'logicle'
                scalefun=@logicle;
                tickfun=@logicletick;
                if size(varargin,2)>inputstr && ~ischar(varargin{inputstr+1})
                    param=varargin{inputstr+1};
                end
            case 'ylin'
                yscale='lin';
            case 'ylog'
                yscale='log';
        end
    end
    %remove the strings from the end of varargin
    if find(cellfun(@ischar,varargin))
        varargin={varargin{1:find(cellfun(@ischar,varargin),1)-1}};
    end
    %if the input is an array change the input to vectors
    if min(size(varargin{1}))~=1
        varargin=num2cell(varargin{1}(:,[varargin{2:end}]),1);
    end

    switch length(param)
        case 3
            minvalue=param(1);
            maxvalue=param(2);
            param=param(3);
        case 2
            minvalue=param(1);
            maxvalue=param(2);
            param=[];
        case 1
            minvalue=min(cellfun(@min,varargin));
            maxvalue=max(cellfun(@max,varargin));
        otherwise
            minvalue=min(cellfun(@min,varargin));
            maxvalue=max(cellfun(@max,varargin));
            param=[];
    end
    %make the minvalue and maxvalue within the range of samples
    maxvalue=min(maxvalue,max(cellfun(@max,varargin)));
    minvalue=max(minvalue,min(cellfun(@min,varargin)));

    bins=linspace(scalefun(minvalue,param),scalefun(maxvalue,param),1024);
    h=zeros(length(bins),size(varargin,2));


    for i=1:(size(varargin,2))
        in=varargin{i};
        htmp=hist(scalefun(in(in<maxvalue & in>minvalue),param),bins);
        %note: one doesnt see the fact that only part of the data is shownexcept
        %in the normalization.
        %smooth it as if it would reach 700 events. but keep it normalized such
        %that the sum divided by number of bins is 1.
        norm=sum(htmp)/length(in);
        htmp=smooth(htmp,round(smooth_prm/mean(htmp(htmp~=0))+1));
        %    h(:,i)=htmp./sum(htmp)*norm*length(bins);
        h(:,i)=htmp./sum(htmp)*norm*normprm/mean(diff(bins));
    end

    if nargout==0
        plot(bins,h);
        set(gca,'YScale',yscale);
        tickfun(minvalue,maxvalue,param,'X');
    else
        hout=h;
        binsout=bins;
    end



    %these function are the scaling functions.
    %INPUT:
    %  x a vector or scalar to be transformed
    %  prm parameters for the transformation

        function y=linearscale(x,prm)
            y=x;
        end

        function y=logscale(x,prm)
            %  if only a number, returns zero for values less than 1
            %  for an array, returns only positive elements
            if isscalar(x)
                y=0;
                y(x>1)=log10(x);
            else
                y=log10(x(x>0));
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
        set(gca,[dim 'Tick'],logscale(ticks,prm))
        set(gca,[dim 'TickLabel'],ticksl)
    end
    function logicletick(minvalue,maxvalue,prm,dim)
        if maxvalue>0
            ticksnumpos=floor(log10(2.2*5/prm)):ceil(log10(maxvalue));
            ntickspos=range(ticksnumpos)+1;
            tickslpos=cell(9,ntickspos);
            tickslpos(1,:)=arrayfun(@(x) sprintf('10^{%d}',x),ticksnumpos,'unif',0);
            tickspos=bsxfun(@times,(1:9)',10.^ticksnumpos);
        else
            tickspos=[];
            tickslpos=[];
        end
        if minvalue<0
            ticksnumneg=floor(log10(2.2*5/prm)):ceil(log10(-minvalue));
            nticksneg=range(ticksnumneg)+1;
            tickslneg=cell(9,nticksneg);
            tickslneg(1,:)=arrayfun(@(x) sprintf('-10^{%d}',x),ticksnumneg,'unif',0);
            ticksneg=bsxfun(@times,(1:9)',10.^ticksnumneg);
        else
            ticksneg=[];
            tickslneg=[];
        end

        ticks=[-reshape(ticksneg(end:-1:1),1,[]), 0, tickspos(:)'];
        set(gca,[dim 'Tick'],logicle(ticks,prm))
        set(gca,[dim 'TickLabel'],[reshape(tickslneg(end:-1:1),[],1);{0};tickslpos(:)])
    end

end

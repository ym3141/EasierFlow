function simdata=fcsdeconv(indata,iniso)
    %OUT=fcsdeconv(DATA,CTRL)
    %trys to remove the distribution defined by the data in CTRL from the
    %distribution defined by the data in DATA.
    %OUT is a sorted events with the resulting distribution
    %

    %find the quantization step of the data
    levels=sort(diff(unique(indata)));
    step=median(levels./round(levels/min(levels)));
    minvalue=min(min([indata(:);iniso(:)]));
    maxvalue=max(max([indata(:);iniso(:)]));
    % %change step to get about 50000 bins
    step=max(step,floor((maxvalue-minvalue)/step/50000)*step);
    bins=-maxvalue:step:maxvalue;

    %make the data histogram
    h=hist(indata,bins);
    h=h./sum(h);
    %smooth it as if it would reach 700 events.
    %h=smooth(h,round(700/max(h)/length(indata)+1));


    %make the isotype histogram
    hi=hist(iniso,bins);
    hi=hi./sum(hi);
    %remove the data that accumulates at the ends of the isotype histogram
    hi(end)=0;hi(1)=0;
    %smooth it as if it would reach 700 events.
    %hi=smooth(hi,round(700/max(hi)/length(iniso)+1));

    %do deconv with it
    hdec=deconvlucy(h,hi);

    %convert regular hist to loghist
    simlength=10000;
    simdata=zeros(1,sum(round(simlength*hdec)));
    position=0;
    for i=bins(hdec~=0)
        curlength=round(simlength*(hdec(bins==i)));
        simdata(position+1:position+curlength)=i*ones(1,curlength);
        position=position+curlength;
    end
end

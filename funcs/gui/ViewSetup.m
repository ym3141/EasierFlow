function ViewSetup(varargin)
    fh = varargin{1};
    mArgsIn=guidata(fh);
    StatNames={'Count','Mean','Median','rSD','Std','% of total','% of gate','Quadrants','Fit'};
    Num_stat=length(StatNames);
    size_y=25+20*ceil(Num_stat/2)+100+25;

    h=figure('Position',[0,0,300,size_y],...
        'MenuBar','none',...
        'Name','Statistics SetUp',...
        'NumberTitle','off',...
        'Visible','off');
    movegui(h,'center');

    uicontrol(h,'Style','text',...
        'Position',[0,0,300,size_y],...
        'String','');
    btngrp_stat=uibuttongroup(...
        'Title','Choose the Statistics to be Calculated:',...
        'Units','pixels',...
        'Position',[0 size_y-25-20*ceil(Num_stat/2) 300 25+20*ceil(Num_stat/2)]);
    for i=1:2:Num_stat
        uicontrol(btngrp_stat,...
            'Style','checkbox',...
            'String',[StatNames{i}],...
            'Tag',StatNames{i},...
            'Position',[5 25+20*ceil(Num_stat/2)-35-10*i 110 20],...
            'Value',mArgsIn.Statistics.ShowInStatView(i),...
            'Callback',{@SetShowInStatView});
        if i<Num_stat
            uicontrol(btngrp_stat,...
                'Style','checkbox',...
                'String',[StatNames{i+1}],...
                'Tag',StatNames{i+1},...
                'Position',[115 25+20*ceil(Num_stat/2)-35-10*i 110 20],...
                'Value',mArgsIn.Statistics.ShowInStatView(i+1),...
                'Callback',{@SetShowInStatView});
        end
    end
    uibuttongroup(...
        'Units','pixels',...
        'Position',[0,25,300,size_y-25-20*ceil(Num_stat/2)-25],...
        'Title','Choose the Quadrants Statistics:');


    uicontrol(h,'Style','push',...
        'Position',[0,size_y-25-20*ceil(Num_stat/2)-100-25,300,25],...
        'String','Set',...
        'Callback',{@(a,b) close(get(a,'parent'))} );


    set(h,'visible','on')

    function SetShowInStatView(hObject,~)
        objects=findobj(get(hObject,'Parent'),'Style','checkbox');
        vals=get(objects,'value');
        res=logical(cell2mat(vals))';
        mArgsIn.Statistics.ShowInStatView=res(end:-1:1);
        %close(get(hObject,'Parent'));
        guidata(fh,mArgsIn);
        % Recalc the statistics
        if isfield(mArgsIn.Handles,'statwin')
            Args=guidata(mArgsIn.Handles.statwin);
            Args.fCalcStat(mArgsIn);
        end

    end

end

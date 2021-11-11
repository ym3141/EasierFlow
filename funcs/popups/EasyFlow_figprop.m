function EasyFlow_figprop(varargin)
    % EasyFlow_FIGPROP Figure properties for the EasyFlow
    %

    %  Initialization tasks

    %  Initialize input/output parameters
    hMainFig=varargin{1};
    mArgsIn=guidata(hMainFig);
    %if there is already an instance running just make it visible and raise it.
    if isfield(mArgsIn.Handles,'graphprop')
        set(mArgsIn.Handles.graphprop,'Visible','on');
        figure(mArgsIn.Handles.graphprop);
        return;
    end


    % Initialize data structures

    %  Construct the figure
    scrsz=get(0,'ScreenSize');
    guisizex=300;
    guisizey=200;
    fh=figure('Position',[(scrsz(3)-guisizex)/2,(scrsz(4)-guisizey)/2,guisizex,guisizey],...
        'MenuBar','none',...
        'Name','FACS GUI Figure Properties',...
        'NumberTitle','off',...
        'Visible','off',...
        'Resize','off',...
        'CloseRequestFcn',{@fhClose,hMainFig});
    mArgsIn.Handles.graphprop=fh;
    guidata(hMainFig,mArgsIn);
    %  Construct the components
    GraphType=uibuttongroup(...
        'Title','GraphType',...
        'Units','pixels',...
        'Position',[0 0 100 200]);
    uicontrol(GraphType,...
        'Style','Radio',...
        'String','Histogram',...
        'Position',[0 160 95,20]);
    uicontrol(GraphType,...
        'Style','Radio',...
        'String','Dot Plot',...
        'Position',[0 120 95,20]);
    uicontrol(GraphType,...
        'Style','Radio',...
        'String','Colored Dot Plot',...
        'Position',[0 80 95,20]);
    uicontrol(GraphType,...
        'Style','Radio',...
        'String','Contour',...
        'Position',[0 40 95,20]);
    uicontrol(GraphType,...
        'Style','Radio',...
        'String','Filled Contour',...
        'Position',[0 0 95,20]);

    Xaxis=uibuttongroup(...
        'Title','Xaxis',...
        'Units','pixels',...
        'Position',[100 100 100 100]);
    uicontrol(Xaxis,...
        'Style','Radio',...
        'String','Linear',...
        'Tag','lin',...
        'UserData',[0 Inf 1],...
        'Position',[0 65 95 20]);
    uicontrol(Xaxis,...
        'Style','Radio',...
        'String','Logarithmic',...
        'Tag','log',...
        'UserData',[0 Inf 1],...
        'Position',[0 45 95 20]);
    uicontrol(Xaxis,...
        'Style','Radio',...
        'String','Hyperbolic',...
        'Tag','logicle',...
        'UserData',[-Inf Inf 1],...
        'Position',[0 25 95 20]);
    uicontrol(Xaxis,...
        'Style','Radio',...
        'String','Logicle',...
        'Tag','logicle',...
        'UserData',[-Inf Inf 10^-1.6],...
        'Position',[0 5 95 20]);
    Xprm=uibuttongroup(...
        'Units','pixels',...
        'Position',[200 100 100 93]);
    uicontrol(Xprm,...
        'Style','checkbox',...
        'Position',[3 70 80 20],...
        'String','AutoAxis',...
        'Value',1,...
        'Tag','AutoXAxis',...
        'Callback',{@XAutoCallback});
    uicontrol(Xprm,...
        'Style','Text',...
        'Position',[0 42 48 20],...
        'String','Min',...
        'Value',1,...
        'Enable','off');
    uicontrol(Xprm,...
        'Style','Text',...
        'Position',[0 22 48 20],...
        'String','Max',...
        'Value',1,...
        'Enable','off');
    uicontrol(Xprm,...
        'Style','Text',...
        'Position',[0 2 48 20],...
        'String','Prm',...
        'Value',1,...
        'Enable','off');
    Xparam(1)=uicontrol(Xprm,...
        'Style','Edit',...
        'String','Min',...
        'Position',[48 42 48 20],...
        'Enable','off',...
        'Callback',{@XparamCallback,hMainFig});
    Xparam(2)=uicontrol(Xprm,...
        'Style','Edit',...
        'String','Max',...
        'Position',[48 22 48 20],...
        'Enable','off',...
        'Callback',{@XparamCallback,hMainFig});
    Xparam(3)=uicontrol(Xprm,...
        'Style','Edit',...
        'String','Prm',...
        'Position',[48 2 48 20],...
        'Enable','off',...
        'Callback',{@XparamCallback,hMainFig});

    Yaxis=uibuttongroup(...
        'Title','Yaxis',...
        'Units','pixels',...
        'Position',[100 0 100 100]);
    uicontrol(Yaxis,...
        'Style','Radio',...
        'String','Linear',...
        'Tag','ylin',...
        'UserData',[0 Inf 1],...
        'Position',[0 65 95,20]);
    uicontrol(Yaxis,...
        'Style','Radio',...
        'String','Logarithmic',...
        'Tag','ylog',...
        'UserData',[0 Inf 1],...
        'Position',[0 45 95,20]);
    uicontrol(Yaxis,...
        'Style','Radio',...
        'String','Hyperbolic',...
        'Tag','ylogicle',...
        'UserData',[-Inf Inf 1],...
        'Position',[0 25 95,20]);
    uicontrol(Yaxis,...
        'Style','Radio',...
        'String','Logicle',...
        'Tag','ylogicle',...
        'UserData',[-Inf Inf 10^-1.6],...
        'Position',[0 5 95,20]);
    Yprm=uibuttongroup('Units','pixels','Position',[200 0 100 93],'Visible','off');
    uicontrol(Yprm,'Style','checkbox','Position',[3 70 80 20],'String','AutoAxis','Tag','AutoYAxis','Value',1,'Callback',{@YAutoCallback});
    uicontrol(Yprm,'Style','Text','Position',[0 42 48 20],'String','Min','Value',1,'Enable','off');
    uicontrol(Yprm,'Style','Text','Position',[0 22 48 20],'String','Max','Value',1,'Enable','off');
    uicontrol(Yprm,'Style','Text','Position',[0 2 48 20],'String','Prm','Value',1,'Enable','off');
    Yparam(1)=uicontrol(Yprm,'Style','Edit','String','Min','Position',[48 42 48 20],'Enable','off','Callback',{@YparamCallback,hMainFig});
    Yparam(2)=uicontrol(Yprm,'Style','Edit','String','Max','Position',[48 22 48 20],'Enable','off','Callback',{@YparamCallback,hMainFig});
    Yparam(3)=uicontrol(Yprm,'Style','Edit','String','Prm','Position',[48 2 48 20],'Enable','off','Callback',{@YparamCallback,hMainFig});
    Yprmhist=uibuttongroup('Units','pixels','Position',[200 0 100 93],'SelectionChangeFcn',{@YprmhistCallback});
    uicontrol(Yprmhist,'Style','Text','Position',[0 62 90 20],'String','Normalize area to:');
    uicontrol(Yprmhist,'Style','Radio','Position',[0 42 30 20],'String','1','Tag','Total','Value',1);
    uicontrol(Yprmhist,'Style','Radio','Position',[30 42 30 20],'String','%','Tag','Gated');
    uicontrol(Yprmhist,'Style','Radio','Position',[60 42 30 20],'String','#','Tag','Abs');
    uicontrol(Yprmhist,'Style','Text','Position',[0 22 90 20],'String','Smoothing:','HorizontalAlignment','left');
    uicontrol(Yprmhist,'Style','Edit','Position',[35 2 30 20],'String','1','Tag','smoothprm','Enable','on','BackgroundColor',[1 1 1],'Callback',@SmoothCallback);

    %  Initialization tasks
    set(GraphType,'SelectionChangeFcn',{@GraphTypeSelCh,hMainFig});
    set(Xaxis,'SelectionChangeFcn',{@XaxisSelCh,hMainFig});
    set(Yaxis,'SelectionChangeFcn',{@YaxisSelCh,hMainFig});
    set(GraphType,'SelectedObject',getcolumn(get(GraphType,'Children')',mArgsIn.Display.graph_type_Radio));
    set(Xaxis,'SelectedObject',getcolumn(get(Xaxis,'Children')',mArgsIn.Display.graph_Xaxis_Radio));
    set(Yaxis,'SelectedObject',getcolumn(get(Yaxis,'Children')',mArgsIn.Display.graph_Yaxis_Radio));

    Args.GraphType=GraphType;
    Args.Xaxis=Xaxis;
    Args.Yaxis=Yaxis;
    Args.Xparam=Xparam;
    Args.Yparam=Yparam;
    Args.SetEnabledBtnsFcn=@SetEnabledBtns;
    guidata(fh,Args);

    %Initialize
    SetEnabledBtns(hMainFig,fh);
    %Set the Y axis parameters area
    GraphTypeSelCh(GraphType,[],hMainFig)
    %getXparam;
    for ind=1:3
        set(Args.Xparam(ind),'String',num2str(mArgsIn.Display.graph_Xaxis_param(ind)));
        set(Args.Yparam(ind),'String',num2str(mArgsIn.Display.graph_Yaxis_param(ind)));
    end


    %  Render GUI visible
    set(fh,'Visible','on');

%  Callbacks.
    function fhClose(hObject,eventdata,hMainFig)
        %when it is closed, only make it invisible.
        mArgsIn=guidata(hMainFig);
        mArgsIn.Handles=rmfield(mArgsIn.Handles,'graphprop');
        guidata(hMainFig,mArgsIn);
        if isempty(gcbf)
            if length(dbstack) == 1
                warning('MATLAB:closereq', ...
                    'Calling closereq from the command line is now obsolete, use close instead');
            end
            close force
        else
            delete(gcbf);
        end
    end

    function GraphTypeSelCh(hObject,eventdata,hMainFig)
        mArgsIn=guidata(hMainFig);
        mArgsIn.Display.Changed=1;
        mArgsIn.Display.graph_type=get(get(hObject,'SelectedObject'),'String');
        mArgsIn.Display.graph_type_Radio=find(get(hObject,'Children')==get(hObject,'SelectedObject'));
        guidata(hMainFig,mArgsIn);
        Args=guidata(mArgsIn.Handles.graphprop);
        if strcmp(mArgsIn.Display.graph_type,'Histogram')
            btns=get(Args.Yaxis,'Children');
            set(btns(1),'Enable','off');
            set(btns(2),'Enable','off');
            if get(Args.Yaxis,'SelectedObject')~=btns(3)
                set(Args.Yaxis,'SelectedObject',btns(4));
                YaxisSelCh(Args.Yaxis,[],hMainFig);
            end
            set(Yprmhist,'Visible','on');
            set(Yprm,'Visible','off');
        else
            btns=get(Args.Yaxis,'Children');
            set(btns(1),'Enable','on');
            set(btns(2),'Enable','on');
            set(Yprmhist,'Visible','off');
            set(Yprm,'Visible','on');
        end
        if ~strcmp(eventdata,'dontplot')
            mArgsIn.Handles.DrawFcn(mArgsIn);
            figure(gcbf);
        end
    end
    function XaxisSelCh(hObject,eventdata,hMainFig)
        mArgsIn=guidata(hMainFig);
        mArgsIn.Display.Changed=1;
        mArgsIn.Display.graph_Xaxis=get(get(hObject,'SelectedObject'),'Tag');
        if get(findobj(fh,'Tag','AutoXAxis'),'Value')==1
            mArgsIn.Display.graph_Xaxis_param=get(get(hObject,'SelectedObject'),'UserData');
        end
        mArgsIn.Display.graph_Xaxis_Radio=find(get(hObject,'Children')==get(hObject,'SelectedObject'));
        guidata(hMainFig,mArgsIn);
        mArgsIn.Handles.DrawFcn(mArgsIn);
        figure(gcbf);
    end
    function YaxisSelCh(hObject,eventdata,hMainFig)
        mArgsIn=guidata(hMainFig);
        mArgsIn.Display.Changed=1;
        mArgsIn.Display.graph_Yaxis=get(get(hObject,'SelectedObject'),'Tag');
        if get(findobj(fh,'Tag','AutoYAxis'),'Value')==1
            mArgsIn.Display.graph_Yaxis_param=get(get(hObject,'SelectedObject'),'UserData');
        end
        mArgsIn.Display.graph_Yaxis_Radio=find(get(hObject,'Children')==get(hObject,'SelectedObject'));
        guidata(hMainFig,mArgsIn);
        mArgsIn.Handles.DrawFcn(mArgsIn);
        figure(gcbf);
    end

    function XparamCallback(hObject,eventdata,hMainFig)
        mArgsIn=guidata(hMainFig);
        mArgsIn.Display.Changed=1;
        Args=guidata(mArgsIn.Handles.graphprop);
        for i=1:3
            if ~isnan(str2double(get(Args.Xparam(i),'String')))
                mArgsIn.Display.graph_Xaxis_param(i)=str2double(get(Args.Xparam(i),'String'));
            end
        end
        guidata(hMainFig,mArgsIn);
        mArgsIn.Handles.DrawFcn(mArgsIn);
        figure(gcbf);
    end
    function XAutoCallback(hObject,eventdata)
        mArgsIn=guidata(hMainFig);
        mArgsIn.Display.Changed=1;
        if get(hObject,'Value')==1
            set(get(get(hObject,'Parent'),'Children'),'Enable','off');
            set(hObject,'Enable','on');
            mArgsIn.Display.graph_Xaxis_param=get(get(Xaxis,'SelectedObject'),'UserData');
            mArgsIn.Display.XAuto=1;
        else
            set(get(get(hObject,'Parent'),'Children'),'Enable','on');
            for i=1:3
                if ~isnan(str2double(get(Args.Xparam(i),'String')))
                    mArgsIn.Display.graph_Xaxis_param(i)=str2double(get(Args.Xparam(i),'String'));
                end
            end
            mArgsIn.Display.XAuto=0;
        end
        guidata(hMainFig,mArgsIn);
        mArgsIn.Handles.DrawFcn(mArgsIn);
        figure(gcbf);
    end
    function YprmhistCallback(hObject,eventdata)
        mArgsIn=guidata(hMainFig);
        mArgsIn.Display.Changed=1;
        mArgsIn.Display.histnormalize=get(get(hObject,'SelectedObject'),'Tag');
        guidata(hMainFig,mArgsIn);
        mArgsIn.Handles.DrawFcn(mArgsIn);
        figure(gcbf);
    end
    function YparamCallback(hObject,eventdata,hMainFig)
        mArgsIn=guidata(hMainFig);
        mArgsIn.Display.Changed=1;
        Args=guidata(mArgsIn.Handles.graphprop);
        for i=1:3
            if ~isnan(str2double(get(Args.Yparam(i),'String')))
                mArgsIn.Display.graph_Yaxis_param(i)=str2double(get(Args.Yparam(i),'String'));
            end
        end
        guidata(hMainFig,mArgsIn);
        mArgsIn.Handles.DrawFcn(mArgsIn);
        figure(gcbf);
    end
    function YAutoCallback(hObject,eventdata)
        mArgsIn=guidata(hMainFig);
        mArgsIn.Display.Changed=1;
        if get(hObject,'Value')==1
            set(get(get(hObject,'Parent'),'Children'),'Enable','off');
            set(hObject,'Enable','on');
            mArgsIn.Display.graph_Yaxis_param=get(get(Yaxis,'SelectedObject'),'UserData');
            mArgsIn.Display.YAuto=1;
        else
            %            set(hObject,'Value',1);
            set(get(get(hObject,'Parent'),'Children'),'Enable','on');
            for i=1:3
                if ~isnan(str2double(get(Args.Yparam(i),'String')))
                    mArgsIn.Display.graph_Yaxis_param(i)=str2double(get(Args.Yparam(i),'String'));
                end
            end
            mArgsIn.Display.YAuto=0;
        end
        guidata(hMainFig,mArgsIn);
        mArgsIn.Handles.DrawFcn(mArgsIn);
        figure(gcbf);
    end
    function SmoothCallback(hObject,eventdata)
        mArgsIn=guidata(hMainFig);
        mArgsIn.Display.smoothprm=str2double(get(hObject,'string'));
        mArgsIn.Display.Changed=1;
        guidata(hMainFig,mArgsIn);
        mArgsIn.Handles.DrawFcn(mArgsIn);
    end
%  Utility functions for MYGUI
    function SetEnabledBtns(hMainFig,fh)
        mArgsIn=guidata(hMainFig);
        Args=guidata(fh);
        set(GraphType,'SelectedObject',getcolumn(get(GraphType,'Children')',mArgsIn.Display.graph_type_Radio));
        set(Xaxis,'SelectedObject',getcolumn(get(Xaxis,'Children')',mArgsIn.Display.graph_Xaxis_Radio));
        set(Yaxis,'SelectedObject',getcolumn(get(Yaxis,'Children')',mArgsIn.Display.graph_Yaxis_Radio));
        
        %check validity of 2d plots
        if get(mArgsIn.Handles.Color2PUM,'Value')==1
            btns=get(Args.GraphType,'Children');
            set(btns(1),'Enable','off');
            set(btns(2),'Enable','off');
            set(btns(3),'Enable','off');
            set(btns(4),'Enable','off');
            set(Args.GraphType,'SelectedObject',btns(5));
        else
            btns=get(Args.GraphType,'Children');
            set(btns(1),'Enable','on');
            set(btns(2),'Enable','on');
            set(btns(3),'Enable','on');
            set(btns(4),'Enable','on');
        end
        GraphTypeSelCh(Args.GraphType,'dontplot',hMainFig);
        
        %set the current parameters for the x axis
        if isfield(mArgsIn.Display,'XAuto')
            set(findobj(fh,'Tag','AutoXAxis'),'Value',mArgsIn.Display.XAuto);
            if mArgsIn.Display.XAuto==1
                set(get(get(findobj(fh,'Tag','AutoXAxis'),'Parent'),'Children'),'Enable','off');
                set(findobj(fh,'Tag','AutoXAxis'),'Enable','on');
            else
                set(get(get(findobj(fh,'Tag','AutoXAxis'),'Parent'),'Children'),'Enable','on');
            end
        else
            set(findobj(fh,'Tag','AutoXAxis'),'Value',1);
            set(get(get(findobj(fh,'Tag','AutoXAxis'),'Parent'),'Children'),'Enable','off');
            set(findobj(fh,'Tag','AutoXAxis'),'Enable','on');
        end
        for ind=1:3
            set(Args.Xparam(ind),'String',num2str(mArgsIn.Display.graph_Xaxis_param(ind)));
        end
        
        %set the current parameters for the y axis
        if isfield(mArgsIn.Display,'YAuto')
            set(findobj(fh,'Tag','AutoYAxis'),'Value',mArgsIn.Display.YAuto);
            if mArgsIn.Display.YAuto==1
                set(get(get(findobj(fh,'Tag','AutoYAxis'),'Parent'),'Children'),'Enable','off');
                set(findobj(fh,'Tag','AutoYAxis'),'Enable','on');
            else
                set(get(get(findobj(fh,'Tag','AutoYAxis'),'Parent'),'Children'),'Enable','on');
            end
        else
            set(findobj(fh,'Tag','AutoYAxis'),'Value',1);
            set(get(get(findobj(fh,'Tag','AutoYAxis'),'Parent'),'Children'),'Enable','off');
            set(findobj(fh,'Tag','AutoYAxis'),'Enable','on');
        end
        if strcmp(get(get(GraphType,'SelectedObject'),'String'),'Histogram')
            set(Yprm,'Visible','off');
            set(Yprmhist,'Visible','on');
            if isfield(mArgsIn.Display,'histnormalize')
                set(Yprmhist,'SelectedObject',findobj(Yprmhist,'Tag',mArgsIn.Display.histnormalize));
            else
                set(Yprmhist,'SelectedObject',findobj(Yprmhist,'Tag','Total'));
            end
            if isfield(mArgsIn.Display,'smoothprm')
                set(findobj(Yprmhist,'Tag','smoothprm'),'string',mArgsIn.Display.smoothprm);
            else
                set(findobj(Yprmhist,'Tag','smoothprm'),'string',-1);
            end
            
        else
            for ind=1:3
                set(Args.Yparam(ind),'String',num2str(mArgsIn.Display.graph_Yaxis_param(ind)));
            end
            set(Yprm,'Visible','on');
            set(Yprmhist,'Visible','off');
        end
        
    end

end

function mainGUI(efdb)
    %% Opens up a new empty easyflow session.
    % Note from Yitong Ma: The easyflow software was originally write by
    % Yaron Anteb, and the orginal version was all written in a single file
    % (this mainGUI.m, called easyflow.m previousely). I have tried to
    % split up this file and put codes into indevidual files in the form of
    % functions. What should remain here are the construction of the main
    % GUI, and their callbacks. That said, there are still lots of other
    % things remains in here at this moment.

    %% Addpath to the function files
    addpath(genpath('./funcs'));

    % Key UI params (in pixels)
    uipos_graphPanelTopDist = 30;
    uipos_graphPanelWidth = 150;
    uipos_topPanelHeight = 100;
    uipos_rightPanelWidth = 200;
    uipos_figpropPanelHeight = 420;

    % Get the current version number
    curversion = efdb.version;
    localConfig = efdb.DBInfo.localConfig;
    Handles = efdb.Handles;

    %%  Construct the main GUI
    scrsz=get(0,'ScreenSize');
    Handles.fh=figure('Position',[scrsz(3)*.15,(scrsz(4)-720)/2, 1080, 720],...
        'MenuBar','none',...
        'Name','EasyFlow - FACS Analysis Tool',...
        'NumberTitle','off',...
        'Visible','off',...
        'ResizeFcn',{@fhResizeFcn},...
        'KeyPressFcn',{@fhKeyPressFcn},...
        'CloseRequestFcn',@fhClose);

    %%  Construct the left regions
    uicontrol(Handles.fh,...
        'Style','listbox','Max',2,'Tag','GraphList',...
        'Value',[],...
        'CreateFcn',@GeneralCreateFcn,...
        'Callback',@GraphListCallback);
    uicontrol(Handles.fh,...
        'Style','pushbutton','String','Add',...
        'Tag','AddBtn',...
        'CreateFcn',@GeneralCreateFcn,...
        'Callback',@AddBtnCallback);
    uicontrol(Handles.fh,...
        'Style','pushbutton','String','Del',...
        'Tag','DelBtn',...
        'CreateFcn',@GeneralCreateFcn,...
        'Callback',@DelBtnCallback);
    uipanel(Handles.fh,...
        'Units','pixels',...
        'Tag','TopPanel',...
        'CreateFcn',@GeneralCreateFcn);
    uibuttongroup(...
        'Units','pixels','Title','Gate List',...
        'Tag','GateList',...
        'CreateFcn',@GeneralCreateFcn);
    
    %%  Construct the ploting regions
    axes('Parent',Handles.fh,...
        'Units','pixels',...
        'Tag','ax',...
        'CreateFcn',@GeneralCreateFcn);
    
    %% Construct the right panel (Fig prop)
    propPanel = uipanel(Handles.fh, 'Units','pixels', 'Tag','FigPropPanel', 'CreateFcn',@GeneralCreateFcn);      
    ui_FigPropPanel(efdb, propPanel, [uipos_rightPanelWidth, uipos_figpropPanelHeight]);

    %%  Construct the top panel
    uicontrol(Handles.TopPanel,...
        'Style','edit',...
        'HorizontalAlignment','left',...
        'String','GraphName',...
        'BackgroundColor',[1 1 1],...
        'Position',[5 75 122 20],...
        'Tag','GraphName',...
        'Enable','off',...
        'CreateFcn',@GeneralCreateFcn,...
        'Callback',@GraphNameCallback);
    uicontrol(Handles.TopPanel,...
        'Style','text',...
        'HorizontalAlignment','left',...
        'String','Data:',...
        'Position',[5 50 122 20]);
    uicontrol(Handles.TopPanel,...
        'Style','popupmenu',...
        'Position',[5 35 122 20],...
        'String',' ',...
        'BackgroundColor',[1 1 1],...
        'Tag','TubePUM',...
        'Enable','off',...
        'CreateFcn',@GeneralCreateFcn,...
        'Callback',@TubePUMCallback);
    uicontrol(Handles.TopPanel,...
        'Style','text',...
        'HorizontalAlignment','left',...
        'String','Control:',...
        'Visible','off',...
        'Position',[137 50 122 20]);
    uicontrol(Handles.TopPanel,...
        'Style','text',...
        'HorizontalAlignment','left',...
        'String','X Axis:',...
        'Position',[269-132 50 122 20]);
    uicontrol(Handles.TopPanel,...
        'Style','popupmenu',...
        'Position',[269-132 35 122 20],...
        'String',' ',...
        'BackgroundColor',[1 1 1],...
        'Tag','ColorPUM',...
        'Enable','off',...
        'CreateFcn',@GeneralCreateFcn,...
        'Callback',@ColorPUMCallback);
    uicontrol(Handles.TopPanel,...
        'Style','text',...
        'HorizontalAlignment','left',...
        'String','Y Axis:',...
        'Position',[401-132 50 122 20]);
    uicontrol(Handles.TopPanel,...
        'Style','popupmenu',...
        'Position',[401-132 35 122 20],...
        'String',' ',...
        'BackgroundColor',[1 1 1],...
        'Tag','Color2PUM',...
        'Enable','off',...
        'CreateFcn',@GeneralCreateFcn,...
        'Callback',@Color2PUMCallback);
    uicontrol(Handles.TopPanel,...
        'Style','pushbutton',...
        'Position',[543-132 35 35 35],...
        'Cdata',imread('./asset/PelatteIcon2.tif'),...
        'Tag','ColorBtn',...
        'CreateFcn',@GeneralCreateFcn,...
        'Enable','off',...
        'Callback',@ColorBtnCallback);
    
    %%  Constract the menu
    MenuSession = uimenu(Handles.fh,'Label','Session',...
        'Callback',@mSessionCallback);
    
    MenuData = uimenu(Handles.fh,'Label','Data',...
        'Callback',@mDataCallback);
    
    MenuGraphs = uimenu(Handles.fh,'Label','Graphs',...
        'Callback',@mGraphsCallback);
    
    MenuDisplay = uimenu(Handles.fh,'Label','Display',...
        'Callback',@mDisplayCallback);
    
    MenuGates = uimenu(Handles.fh,'Label','Gates',...
        'Callback',@mGatesCallback);
    
    MenuStats = uimenu(Handles.fh,'Label','Stats');
    
    MenuSettings = uimenu(Handles.fh,'Label','Settings');
    
    MenuHelp = uimenu(Handles.fh,'Label','Help');
    
    %%    Sessions menu
    uimenu(MenuSession,...
        'Label','New Session',...
        'Callback',@SessionNewCallback);
    uimenu(MenuSession,...
        'Label','Open Session...',...
        'Callback',@SessionLoadCallback);
    uimenu(MenuSession,...
        'Label','Save',...
        'Callback',@SessionSaveCallback);
    uimenu(MenuSession,...
        'Label','Save As...',...
        'Callback',@SessionSaveAsCallback);
    uimenu(MenuSession,...
        'Label','Export To Workspace...',...
        'Callback',@SessionExportCallback);
    uimenu(MenuSession,...
        'Label','Use Relative Path',...
        'Callback',@SessionUseRelPath);
    %%    Data menu
    GenerateDataMenu(MenuData)
    %%    Graphs menu
    GenerateGraphsMenu(MenuGraphs)
    %%    Display menu
    GenerateDisplayMenu(MenuDisplay)
    %%    Gates menu
    GenerateGatesMenu(MenuGates)
    %%    STATS menu
    uimenu(MenuStats,...
        'Label','Stat Window...',...
        'Callback',@StatWinCallback);
    uimenu(MenuStats,...
        'Label','SetUp...',...
        'Callback',@ViewSetup);
    %%    Settings menu
    uimenu(MenuSettings, 'Label', 'Local settings',...
        'Callback', @LocalSettingsPopup)
    %%    HELP menu
    uimenu(MenuHelp,...
        'Label','Show Keyboard Shortcuts',...
        'Callback',{@HelpKeys});
    uimenu(MenuHelp,...
        'Label','About...',...
        'Callback',{@HelpAbout});
    %% Context menus
    %Graphs
    GraphsCM = uicontextmenu('Parent',Handles.fh,...
        'Callback',@mGraphsCallback);
    set(Handles.GraphList,'UIContextMenu',GraphsCM);
    GenerateGraphsMenu(GraphsCM)
    %Gates
    Handles.GatesCM = uicontextmenu('Parent',Handles.fh,...
        'Callback',@mGatesCallback);
    set(Handles.GateList,'UIContextMenu',Handles.GatesCM);
    GenerateGatesMenu(Handles.GatesCM)
    %Display
    DisplayCM = uicontextmenu('Parent',Handles.fh,...
        'Callback',@mDisplayCallback);
    set(Handles.ax,'UIContextMenu',DisplayCM);
    GenerateDisplayMenu(DisplayCM);

    %% Handles to functions
    Handles.DrawFcn=@DrawGraphs;
    Handles.UpdateGateListFcn=@UpdateGateList;
    Handles.CalculateGatedData=@CalculateGatedData;
    Handles.RecalcGateLogicalMask=@RecalcGateLogicalMask;

    %         %% Create a database and add to gui
    %         efdb=init_efdb(localConfig);
    efdb.Handles=Handles;
    efdb_save(efdb);

    fh = Handles.fh;

    %  Render GUI visible
    set(fh,'Visible','on');

    %% construction function
    function GeneralCreateFcn(hObject,~)
        if ~isempty(get(hObject,'Tag'))
            Handles.(get(hObject,'Tag'))=hObject;
        end
    end
    function GenerateDataMenu(hObject)
        % Data menu
        uimenu(hObject,...
            'Label','Load Data Files...',...
            'Callback',@SampleLoadCallback);
        uimenu(hObject,...
            'Label','Load Data Folder...',...
            'Callback',@FolderLoadCallback);
        uimenu(hObject,...
            'Label','Save Samples',...
            'Callback',@TubeSaveCallback);
        uimenu(hObject,...
            'Label','Remove Samples...',...
            'Callback',@TubeRemoveCallback);
        uimenu(hObject,...
            'Label','Rename Samples...',...
            'Callback',@TubeRenameCallback);
        uimenu(hObject,...
            'Label','File Rename Samples...',...
            'Callback',@FileTubeRenameCallback);
        uimenu(hObject,...
            'Label','Samples parameters...',...
            'Callback',@TubeShowPrmCallback);
        MenuTubeComp=uimenu(hObject,...
            'Label','Compensation');
        uimenu(hObject,...
            'Label','View Parameters...',...
            'Callback',@TubePrmCallback);
        uimenu(hObject,...
            'Label','Add parameter',...
            'callback',@TubeAddParam);
        % Compensation submenu
        uimenu(MenuTubeComp,...
            'Label','Set Compensation...',...
            'Callback',@TubeCompCallback);
    end
    function GenerateGraphsMenu(hObject)
        uimenu(hObject,...
            'Label','Batch...',...
            'Callback',{@ToolsBatch});
        uimenu(hObject,...
            'Label','Add all tubes',...
            'Callback',{@ToolsAddall});
        uimenu(hObject,...
            'Label','New Fit',...
            'Callback',{@ToolsNewFit});
        uimenu(hObject,...
            'Label','Apply Fit',...
            'Callback',{@ToolsApplyFit});
        uimenu(hObject,...
            'Label','Remove Fit',...
            'Callback',{@ToolsRemFit});
        uimenu(hObject,...
            'Label','Export Data',...
            'Callback',{@ToolsExport});
    end
    function GenerateGatesMenu(hObject)
        uimenu(hObject,...
            'Label','Add Gate',...
            'Callback',@MenuGatesAddGate);
        uimenu(hObject,...
            'Label','Add Contour Gate',...
            'Callback',@MenuGatesAddContourGate);
        uimenu(hObject,...
            'Label','Add Logical Gate',...
            'Callback',@MenuGatesAddLogicalGate);
        uimenu(hObject,...
            'Label','Add Artifacts Gate',...
            'Callback',@MenuGatesAddArtifactsGate);
        uimenu(hObject,...
            'Label','Remove Gate',...
            'Callback',@MenuGatesRemove);
        uimenu(hObject,...
            'Label','Edit Gates',...
            'Callback',@MenuGatesEditor);
    end
    function GenerateDisplayMenu(hObject)
        acmquadmenu=uimenu(hObject,...
            'Label','Quadrants');
        uimenu(acmquadmenu,...
            'Label','Set Quadrants',...
            'Callback',@ACM_setquad);
        uimenu(acmquadmenu,...
            'Label','Copy Quadrants',...
            'Callback',@ACM_cpquad);
        uimenu(acmquadmenu,...
            'Label','Paste Quadrants',...
            'Callback',@ACM_pastequad);
        uimenu(acmquadmenu,...
            'Label','Remove Quadrants',...
            'Callback',@ACM_rmquad);
        uimenu(hObject,...
            'Label','Fix Axis',...
            'Callback',@ACM_fixaxis);
        uimenu(hObject,...
            'Label','Draw to Figure',...
            'Callback',@ACM_DrawToFigure);
        uimenu(hObject,...
            'Label','Graph Properties is now in the right panel',...
            'Enable', 'off',...
            'Callback',@ACM_graphprop);
    end



%%  Callbacks for MYGUI.
% loading DB        efdb=efdb_load(hObject);
% saving DB         efdb_save(efdb);
% disable gui       efdb=disable_gui(efdb);
% enable gui        efdb=enable_gui(efdb);
%

    function fhResizeFcn(hObject,~)
        
        efdb=efdb_load(hObject);
        guipos=get(hObject,'Position');

        set(hObject,'Position',guipos);
        
        try
            set(efdb.Handles.GraphList,'Position',[0, 0, uipos_graphPanelWidth, guipos(4)-uipos_graphPanelTopDist]);
            set(efdb.Handles.AddBtn,'Position',[0, guipos(4)-uipos_graphPanelTopDist, floor(uipos_graphPanelWidth/2), uipos_graphPanelTopDist]);
            set(efdb.Handles.DelBtn,'Position',[floor(uipos_graphPanelWidth/2), guipos(4)-uipos_graphPanelTopDist, floor(uipos_graphPanelWidth/2), uipos_graphPanelTopDist]);
            set(efdb.Handles.TopPanel,'Position',[uipos_graphPanelWidth, guipos(4)-uipos_topPanelHeight, guipos(3)-uipos_rightPanelWidth-uipos_graphPanelWidth, uipos_topPanelHeight]);
            set(efdb.Handles.GateList,'Position',[guipos(3)-uipos_rightPanelWidth, uipos_figpropPanelHeight, uipos_rightPanelWidth, guipos(4)-uipos_figpropPanelHeight]);
            set(efdb.Handles.FigPropPanel,'Position',[guipos(3)-uipos_rightPanelWidth, 0, uipos_rightPanelWidth, uipos_figpropPanelHeight]);

            set(efdb.Handles.ax,'OuterPosition',[uipos_graphPanelWidth, 0, guipos(3)-uipos_rightPanelWidth-uipos_graphPanelWidth, guipos(4)-uipos_topPanelHeight]);

            efdb_save(efdb);
            
        catch resizeError
            if ~(strcmp(resizeError.identifier,'MATLAB:hg:set_chck:DimensionsOutsideRange'))
                rethrow(resizeError);
            end
        end
        
        %redraw the gates in the gate list
        UpdateGateList(efdb);
    end

    function fhClose(hObject,eventdata)
        efdb=efdb_load(hObject);
        if isfield(efdb,'DBInfo') && isfield(efdb.DBInfo,'isChanged') && efdb.DBInfo.isChanged==1
            button = questdlg('Some unsaved data will be lost.','Exit EasyFlow','Save', 'Quit', 'Cancel', 'Cancel');
            if strcmp(button,'Cancel')
                return
            end
            if strcmp(button,'Save')
                if isfield(efdb.DBInfo,'Name') && exist(efdb.DBInfo.Name,'file')
                    SessionSaveCallback(hObject,eventdata);
                else
                    SessionSaveAsCallback(hObject,eventdata);
                end
            end
        end
        
        if isfield(efdb.Handles,'graphprop')
            delete(efdb.Handles.graphprop)
            efdb.Handles=rmfield(efdb.Handles,'graphprop');
        end
        if isfield(efdb.Handles,'statwin')
            delete(efdb.Handles.statwin)
            efdb.Handles=rmfield(efdb.Handles,'statwin');
        end
        if isfield(efdb.Handles,'gateedit')
            delete(efdb.Handles.gateedit)
            efdb.Handles=rmfield(efdb.Handles,'gateedit');
        end
        if isfield(efdb.Handles,'compensation')
            delete(efdb.Handles.compensation)
            efdb.Handles=rmfield(efdb.Handles,'compensation');
        end
        efdb_save(efdb);
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
    function fhKeyPressFcn(hObject,eventdata)
        efdb=efdb_load(hObject);
        if strcmp(eventdata.Modifier,'control')
            if strcmp(eventdata.Key,'a')
                for graph=efdb.curGraph
                    efdb.GraphDB(graph).Name=efdb.GraphDB(graph).Data;
                end
                List=get(efdb.Handles.GraphList,'String');
                List(get(efdb.Handles.GraphList,'Value'))={efdb.GraphDB(efdb.curGraph).Data};
                set(efdb.Handles.GraphList,'String',List);
                set(efdb.Handles.GraphName,'String',efdb.GraphDB(efdb.curGraph(1)).Data);
                efdb.DBInfo.isChanged=1;
                efdb = DrawGraphs(efdb);
            end
            if strcmp(eventdata.Key,'c')
                for graph=efdb.curGraph
                    efdb.GraphDB(graph).PlotColor=[];
                end
                efdb.DBInfo.isChanged=1;
                efdb = DrawGraphs(efdb);
            end
        end
        efdb_save(efdb);
    end

    function TubePUMCallback(hObject,eventdata)
        efdb=efdb_load(hObject);
        for curGraph=efdb.curGraph
            efdb.GraphDB(curGraph).Data=efdb.TubeNames{get(hObject,'Value')};
            efdb.GraphDB(curGraph).DataDeconv=[];
            %set up the new gates for this tube
            curtube=matlab.lang.makeValidName(efdb.GraphDB(curGraph).Data);
            %keep gates that exist in the new tube
            if isfield(efdb,'GatesDB') && isfield(efdb.GatesDB,curtube)
                efdb.GraphDB(curGraph).Gates=efdb.GraphDB(curGraph).Gates(isfield(efdb.GatesDB.(curtube),efdb.GraphDB(curGraph).Gates));
            else
                efdb.GraphDB(curGraph).Gates=[];
            end
        end
        efdb=CalculateGatedData(efdb);
        efdb.DBInfo.isChanged=1;
        efdb=DataChange(efdb);
        efdb_save(efdb);
        GraphListCallback(efdb.Handles.GraphList,eventdata)
        efdb=CalculateMarkers(efdb);
        efdb_save(efdb);
    end
    function ColorPUMCallback(hObject,~)
        efdb=efdb_load(hObject);
        if strcmp(get(hObject,'String'),' ')
            return;
        end
        colorlist=get(hObject,'String');
        colorname=strtrim(strtok(colorlist(get(hObject,'Value')),':'));
        for curGraph=efdb.curGraph
            efdb.GraphDB(curGraph).Color=char(colorname);
            efdb.GraphDB(curGraph).DataDeconv=[];
        end
        %change color to show homogeneity
        set(efdb.Handles.ColorPUM,'ForegroundColor',[0 0 0]);
        efdb.DBInfo.isChanged=1;
        efdb = DrawGraphs(efdb);
        efdb=CalculateMarkers(efdb);
        efdb=DataChange(efdb);
        efdb_save(efdb);
    end
    function Color2PUMCallback(hObject,~)
        efdb=efdb_load(hObject);
        colorlist=get(hObject,'String');
        colorname=strtrim(strtok(colorlist(get(hObject,'Value')),':'));
        for curGraph=efdb.curGraph
            efdb.GraphDB(curGraph).Color2=char(colorname);
            efdb.GraphDB(curGraph).DataDeconv=[];
        end
        %change color to show homogeneity
        set(efdb.Handles.Color2PUM,'ForegroundColor',[0 0 0]);
        efdb.DBInfo.isChanged=1;
        %if the graph properties editor exists tell it to update the
        %buttons.
        %if not, only check that color2 is ok.
        if isfield(efdb.Handles,'graphprop')
            Args=guidata(efdb.Handles.graphprop);
            Args.SetEnabledBtnsFcn(efdb.Handles.fh,efdb.Handles.graphprop);
        else
            if get(efdb.Handles.Color2PUM,'Value')==1 ...color 2 is 'None'
                    && ~strcmp(efdb.Display.graph_type,'Histogram') %we must have histogram
                efdb.Display.graph_type='Histogram';
                efdb.Display.graph_type_Radio=4;
                efdb.Display.Changed=1;
                efdb.DBInfo.isChanged=1;
            end
        end
        efdb = DrawGraphs(efdb);
        efdb = CalculateMarkers(efdb);
        efdb = DataChange(efdb);
        efdb_save(efdb);
    end
    function AddBtnCallback(hObject,eventdata)
        efdb=efdb_load(hObject);
        %reselect selected graphs to save their configuration
        GraphListCallback(efdb.Handles.GraphList,eventdata);
        %add item to the GraphList and GraphDB and select the new graph
        List=get(efdb.Handles.GraphList,'String');
        curGraph=length(List)+1;
        List{curGraph}=['Graph_' num2str(curGraph)];
        %create the new item
        if ~isfield(efdb,'curGraph') || isempty(efdb.curGraph) || efdb.curGraph(1)==0
            efdb.GraphDB(curGraph).Name=['Graph_' num2str(curGraph)];
            efdb.GraphDB(curGraph).Data=char(efdb.TubeNames(1));
            efdb.GraphDB(curGraph).Ctrl='None';
            efdb.GraphDB(curGraph).Color='None';
            efdb.GraphDB(curGraph).Color2='None';
            efdb.GraphDB(curGraph).RemoveCtrl=0;
            efdb.GraphDB(curGraph).DataDeconv=[];
            efdb.GraphDB(curGraph).Gates={};
            efdb.GraphDB(curGraph).GatesOff={};
            %mArgsIn.GraphDB(curGraph).Markers={};
            efdb.GraphDB(curGraph).Stat=struct;
            efdb.GraphDB(curGraph).plotdata=[];
            efdb.GraphDB(curGraph).gatedindex=[];
            efdb.GraphDB(curGraph).gatedindexctrl=[];
            efdb.GraphDB(curGraph).Display=efdb.Display;
            efdb.GraphDB(curGraph).fit=[];
        else
            prevGraph=efdb.curGraph(1);
            efdb.GraphDB(curGraph).Name=['Graph_' num2str(curGraph)];
            efdb.GraphDB(curGraph).Data=efdb.GraphDB(prevGraph).Data;
            efdb.GraphDB(curGraph).Ctrl=efdb.GraphDB(prevGraph).Ctrl;
            efdb.GraphDB(curGraph).Color=efdb.GraphDB(prevGraph).Color;
            efdb.GraphDB(curGraph).Color2=efdb.GraphDB(prevGraph).Color2;
            efdb.GraphDB(curGraph).RemoveCtrl=efdb.GraphDB(prevGraph).RemoveCtrl;
            efdb.GraphDB(curGraph).DataDeconv=efdb.GraphDB(prevGraph).DataDeconv;
            efdb.GraphDB(curGraph).Gates=efdb.GraphDB(prevGraph).Gates;
            efdb.GraphDB(curGraph).GatesOff=efdb.GraphDB(prevGraph).GatesOff;
            %mArgsIn.GraphDB(curGraph).Markers=mArgsIn.GraphDB(prevGraph).Markers;
            efdb.GraphDB(curGraph).Stat=efdb.GraphDB(prevGraph).Stat;
            efdb.GraphDB(curGraph).plotdata=efdb.GraphDB(prevGraph).plotdata;
            efdb.GraphDB(curGraph).gatedindex=efdb.GraphDB(prevGraph).gatedindex;
            efdb.GraphDB(curGraph).gatedindexctrl=efdb.GraphDB(prevGraph).gatedindexctrl;
            efdb.GraphDB(curGraph).Display=efdb.GraphDB(prevGraph).Display;
            efdb.GraphDB(curGraph).fit=efdb.GraphDB(prevGraph).fit;
        end
        set(efdb.Handles.GraphList,'String',List);
        set(efdb.Handles.GraphList,'Value',curGraph);
        efdb.DBInfo.isChanged=1;
        efdb_save(efdb);
        GraphListCallback(efdb.Handles.GraphList,eventdata);
    end
    function DelBtnCallback(hObject,eventdata)
        %delete item from the GraphList and GraphDB and select the previous
        %one
        efdb=efdb_load(hObject);
        selected=get(efdb.Handles.GraphList,'Value');
        if selected==0
            return;
        end
        efdb.GraphDB(selected)=[];
        
        List=get(efdb.Handles.GraphList,'String');
        List(selected)=[];
        efdb.curGraph=min(min(selected),length(List));
        
        set(efdb.Handles.GraphList,'Value',efdb.curGraph);
        set(efdb.Handles.GraphList,'String',List);
        
        efdb.DBInfo.isChanged=1;
        efdb_save(efdb);
        GraphListCallback(efdb.Handles.GraphList,eventdata);
    end
    function ColorBtnCallback(hObject,~)
        efdb=efdb_load(hObject);
        color=uisetcolor;
        if ~isscalar(color)
            [efdb.GraphDB(efdb.curGraph).PlotColor]=deal(color);
        end
        efdb.DBInfo.isChanged=1;
        efdb = DrawGraphs(efdb);
        efdb_save(efdb);
    end
    function GraphNameCallback(hObject,~)
        efdb=efdb_load(hObject);
        List=get(efdb.Handles.GraphList,'String');
        List{get(efdb.Handles.GraphList,'Value')}=get(hObject,'String');
        set(efdb.Handles.GraphList,'String',List);
        efdb.GraphDB(get(efdb.Handles.GraphList,'Value')).Name=get(hObject,'String');
        efdb.DBInfo.isChanged=1;
        efdb_save(efdb);
    end
    function GraphListCallback(hObject,~)
        efdb=efdb_load(hObject);
        fhIn=efdb.Handles.fh;
        %if changed, save the display settings for the old graphs
        graphlist=get(hObject,'Value');
        if isfield(efdb.Display,'Changed') && efdb.Display.Changed==1
            for graph=efdb.curGraph %this is the previously selected graphs
                efdb.GraphDB(graph).Display=efdb.Display;
            end
        end
        if isempty(graphlist)
            return
        elseif graphlist(1)==0 %no graphs
            efdb.curGraph=0;
            set(efdb.Handles.TubePUM,'Enable','off');
            set(efdb.Handles.ColorPUM,'Enable','off');
            set(efdb.Handles.Color2PUM,'Enable','off');
            set(efdb.Handles.GraphName,'Enable','off');
            set(efdb.Handles.ColorBtn,'Enable','off');
            return
        else
            %clear plotdata from old plotted graphs
            if isfield(efdb,'curGraph') && ~isempty(efdb.curGraph) && ~any(efdb.curGraph==0)
                [efdb.GraphDB(efdb.curGraph).plotdata]=deal([]);
            end
            
            efdb.curGraph=graphlist;
            %enable compnents,
            %read the TopPanel parameters for the first one of the graphs and verify them
            %ColorBtn
            set(efdb.Handles.ColorBtn,'Enable','on');
            %Name
            if isscalar(efdb.curGraph)
                set(efdb.Handles.GraphName,'Enable','on');
                if ~isfield(efdb.GraphDB(efdb.curGraph(1)),'Name') || ~ischar(efdb.GraphDB(efdb.curGraph(1)).Name)
                    efdb.GraphDB(efdb.curGraph(1)).Name=['Graph_' num2str(efdb.curGraph(1))];
                end
                set(efdb.Handles.GraphName,'String',efdb.GraphDB(efdb.curGraph(1)).Name);
            else
                set(efdb.Handles.GraphName,'Enable','off');
                set(efdb.Handles.GraphName,'String',efdb.GraphDB(efdb.curGraph(1)).Name);
            end
            %Data
            set(efdb.Handles.TubePUM,'Enable','on');
            if length(unique({efdb.GraphDB(efdb.curGraph).Data}))==1
                set(efdb.Handles.TubePUM,'ForegroundColor',[0 0 0]);
                %23/3/9     DataNumber=find(cellfun(@(x) strcmp(x,mArgsIn.GraphDB(mArgsIn.curGraph(1)).Data),mArgsIn.TubeNames),1);
                DataNumber=find(strcmp(efdb.GraphDB(efdb.curGraph(1)).Data,efdb.TubeNames),1);
                if DataNumber
                    set(efdb.Handles.TubePUM,'Value',DataNumber);
                else
                    set(efdb.Handles.TubePUM,'Value',1);
                end
            else
                set(efdb.Handles.TubePUM,'ForegroundColor',[1 0 0]);
                set(efdb.Handles.TubePUM,'Value',1);
            end
            
            %set up the new gates for this graph
            UpdateGateList(efdb);
            
            %Color and color2
            %create the common colors lists.
            %if the data tube is not found or one of the graph is
            %none, the list is empty
            if isfield(efdb.TubeDB,'Tubename') && length(unique([efdb.TubeDB.Tubename,{efdb.GraphDB(efdb.curGraph).Data}]))==length(unique([efdb.TubeDB.Tubename]))
                tubeidx=arrayfun(@(x) find(strcmp([efdb.TubeDB.Tubename],x),1,'first'), {efdb.GraphDB(efdb.curGraph).Data});
                allparname=[efdb.TubeDB(tubeidx).parname];
                [allparname,m,n]=unique(allparname(:),'first');
                apearencenum=histcounts(n,0.5+(0:length(allparname)));
                %take all param that appear in all tubes and sort them according to
                %their apearence order
                parname=allparname(apearencenum==length(efdb.curGraph));
                m=m(apearencenum==length(efdb.curGraph));
                [msort,indx]=sort(m);
                parname=char(parname(indx));%=allparname(msort)
                allparsym=[efdb.TubeDB(tubeidx).parsymbol];
                parsym=char(allparsym(msort));
                seperator=char(ones(size(parname,1),1)*': ');
                %set new lists with the colors
                set(efdb.Handles.ColorPUM,'String',[{'None'};cellstr([parname,seperator,parsym])]);
                set(efdb.Handles.Color2PUM,'String',[{'None'};cellstr([parname,seperator,parsym])]);
            else
                set(efdb.Handles.ColorPUM,'String',{'None'});
                set(efdb.Handles.Color2PUM,'String',{'None'});
            end
            set(efdb.Handles.ColorPUM,'Enable','on');
            if length(unique({efdb.GraphDB(efdb.curGraph).Color}))==1
                set(efdb.Handles.ColorPUM,'ForegroundColor',[0 0 0]);
                colorlist=strtrim(strtok(get(efdb.Handles.ColorPUM,'String'),':'));
                colorind=find(strcmp(colorlist,efdb.GraphDB(efdb.curGraph(1)).Color),1,'first');
                if colorind
                    set(efdb.Handles.ColorPUM,'Value',colorind);
                else
                    set(efdb.Handles.ColorPUM,'Value',1);
                end
            else
                set(efdb.Handles.ColorPUM,'ForegroundColor',[1 0 0]);
                set(efdb.Handles.ColorPUM,'Value',1);
            end
            set(efdb.Handles.Color2PUM,'Enable','on');
            if length(unique({efdb.GraphDB(efdb.curGraph).Color2}))==1
                set(efdb.Handles.Color2PUM,'ForegroundColor',[0 0 0]);
                color2list=strtrim(strtok(get(efdb.Handles.Color2PUM,'String'),':'));
                color2ind=find(strcmp(color2list,efdb.GraphDB(efdb.curGraph(1)).Color2),1,'first');
                if color2ind
                    set(efdb.Handles.Color2PUM,'Value',color2ind);
                else
                    set(efdb.Handles.Color2PUM,'Value',1);
                end
            else
                set(efdb.Handles.Color2PUM,'ForegroundColor',[1 0 0]);
                set(efdb.Handles.Color2PUM,'Value',1);
            end
            
            %read the display settings from the first graph, and update the
            %figure prop window.
            if isfield(efdb.GraphDB(efdb.curGraph(1)),'Display') && ~isempty(efdb.GraphDB(efdb.curGraph(1)).Display)
%                 efdb.Display=efdb.GraphDB(efdb.curGraph(1)).Display;
                if isfield(efdb.Display,'Axis')
                    set(findobj(fhIn,'Label','Fix Axis'), 'Checked', 'on');
                else
                    set(findobj(fhIn,'Label','Fix Axis'), 'Checked', 'off');
                end
                if isfield(efdb.Handles,'graphprop')
                    guidata(fhIn,efdb);
                    Args=guidata(efdb.Handles.graphprop);
                    Args.SetEnabledBtnsFcn(fhIn,efdb.Handles.graphprop);
                    efdb=guidata(fhIn);
                end
                efdb.Display.Changed=0;
            end
            %update the compensation window
            if isfield(efdb.Handles,'compensation')
                guidata(fhIn,efdb);
                Args=guidata(efdb.Handles.compensation);
                Args.fUpdateComp(fhIn);
                efdb=guidata(fhIn);
            end
        end
        efdb.DBInfo.isChanged=1;
        %Draw Graphs
        efdb = DrawGraphs(efdb);
        efdb_save(efdb);
    end
    function GateListCallback(hObject,~)
        efdb=efdb_load(hObject);
        gatename=get(hObject,'Tag');
        for graph=get(efdb.Handles.GraphList,'Value')
            efdb.GraphDB(graph).DataDeconv=[];
            efdb.GraphDB(graph).Gates(strcmp(efdb.GraphDB(graph).Gates,gatename))=[];
            efdb.GraphDB(graph).GatesOff(strcmp(efdb.GraphDB(graph).GatesOff,gatename))=[];
            if get(hObject,'Value')==1
                efdb.GraphDB(graph).Gates{end+1}=gatename;
            else
                efdb.GraphDB(graph).GatesOff{end+1}=gatename;
            end
        end
        efdb.DBInfo.isChanged=1;
        guidata(fh,efdb)
        %Update list, and Draw Graphs
        %tbd: maybe change this to the general datachange function
        efdb=CalculateGatedData(efdb);
        UpdateGateList(efdb);
        efdb = DrawGraphs(efdb);
        efdb_save(efdb);
    end

    function mSessionCallback(hObject,varargin)
        fhIn=ancestor(hObject,'figure');
        efdbIn=guidata(fhIn);
        filemenu=get(hObject,'Children');
        set(filemenu,'Enable','on');
        if ~isfield(efdbIn,'DBInfo') || ~isfield(efdbIn.DBInfo,'Name') || ~exist(efdbIn.DBInfo.Name,'file')
            set(filemenu(strcmp(get(filemenu,'Label'),'Save')),'Enable','off');
        end

        if isempty(efdbIn.GraphDB)
            set(filemenu,'Enable','off');
            set(findobj(hObject,'Label','Open Session...'),'Enable','on');
        end
        MenuFileRelpath=findobj(hObject,'Label','Use Relative Path');
        if isfield(efdbIn.DBInfo,'RootFolder')
            MenuFileRelpath.Checked='on';
        else
            MenuFileRelpath.Checked='off';
        end        
        if isequal(rmfield(efdbIn,'Handles'),rmfield(init_efdb(localConfig),'Handles'))
            set(findobj(hObject,'Label', 'New Session'),'Enable','off')
        else
            set(findobj(hObject,'Label', 'New Session'),'Enable','on')
        end
    end
    function mDataCallback(hObject,varargin)
        fhIn=ancestor(hObject,'figure');
        efdbIn=guidata(fhIn);
        menuobj=get(hObject,'Children');
        set(menuobj,'Enable','on');
        if isempty(efdbIn.TubeDB)
            set(menuobj,'Enable','off');
        end
        item = findobj(hObject, 'Label', 'Load Data Files...');
        item.Enable='on';
        item = findobj(hObject, 'Label', 'Load Data Folder...');
        item.Enable='on';
    end
    function mGraphsCallback(hObject,~)
        mArgsIn=guidata(fh);
        set(get(hObject,'Children'),'Enable','on');
        if isempty(mArgsIn.GraphDB)
            set(get(hObject,'Children'),'Enable','off');
            set(findobj(hObject,'Label','Add all tubes'),'Enable','on');
        elseif strcmp(mArgsIn.Display.graph_type,'Histogram')
            set(findobj(hObject,'Label','Load Fit'),'Enable','on');
            if isscalar(mArgsIn.curGraph)
                set(findobj(hObject,'Label','New Fit'),'Enable','on');
            else
                set(findobj(hObject,'Label','New Fit'),'Enable','off');
            end
        else
            set(findobj(hObject,'Label','Load Fit'),'Enable','off');
            set(findobj(hObject,'Label','New Fit'),'Enable','off');
        end
        guidata(fh,mArgsIn);
    end
    function mDisplayCallback(hObject,~)
        mArgsIn=guidata(fh);
        if strcmp(mArgsIn.Display.graph_type,'Histogram')
            set(findobj(hObject,'Label','Quadrants'),'Enable','off');
        else
            set(findobj(hObject,'Label','Quadrants'),'Enable','on');
        end
    end
    function mGatesCallback(hObject,~)
        fhIn=ancestor(hObject,'figure');
        efdbIn=guidata(fhIn);
        if isempty(efdbIn.curGraph) 
            set(hObject.Children,'Enable','off')
        else
            set(hObject.Children,'Enable','on')
        end
        if strcmp(efdbIn.Display.graph_type,'Histogram')
            set(findobj(hObject,'Label','Add Contour Gate'),'Enable','off');
        end
        if isempty(fieldnames(efdbIn.GatesDBnew))
            set(findobj(hObject,'Label','Add Logical Gate'),'Enable','off');
        end
        % it the menu is called not on a gate, disable editing options
        if strcmp(get(gco,'Tag'),'GateList')
            set(findobj(hObject,'Label','Remove Gate'),'Enable','off');
            set(findobj(hObject,'Label','Edit Gates'),'Enable','off');
        end
    end

    function SessionNewCallback(varargin)
        run('./mainEasierFlow.m');
    end

    function SessionLoadCallback(hObject,eventdata)
        fhIn=ancestor(hObject,'figure');
        efdbIn=guidata(fhIn);
        set(fhIn,'pointer','watch');

        if isfield(efdbIn,'DBInfo') && isfield(efdbIn.DBInfo,'Path') && ischar(efdbIn.DBInfo.Path) && exist(efdbIn.DBInfo.Path,'dir')
            [filename,dirname]=uigetfile('*.efl','Open Analysis',efdbIn.DBInfo.Path);
        else
            [filename,dirname]=uigetfile('*.efl','Open Analysis',localConfig.fcsFileDir);
        end
%         end
        if ~ischar(filename) || ~exist([dirname,filename],'file')
            set(fhIn,'pointer','arrow');
            return
        end
        
        %if this is not a new window with empty database then open a new
        %easyflow instance
        if ~isempty(efdbIn.TubeDB) || ~isempty(efdbIn.GraphDB)
            eval([mfilename '(''' [dirname,filename] ''')'])
            return
        end
        
        readargs=load('-mat',[dirname,filename]);
        %move these into updateversion when having a new version
        %until here        
        if isfield(readargs,'sArgs')
            sArgs=readargs.sArgs;
            %update the file to the new version
            oldmArgsIn=efdbIn;
            if ~isfield(sArgs,'version') || sArgs.version~=curversion
                sArgs=UpdateVersion(sArgs, curversion);
                if isempty(sArgs)
                    guidata(fhIn,oldmArgsIn);
                    set(fhIn,'pointer','arrow');
                    return;
                end
            end
            if ischar(dirname) && exist(dirname,'dir')
                sArgs.DBInfo.Path=dirname;
            end
            sArgs.DBInfo.Name=[dirname,filename];
            sArgs.DBInfo.isChanged=0;
            %if needed change paths to absolute
            if isfield(sArgs.DBInfo,'RootFolder')
                sArgs=rel2abspath(sArgs);
            end
            %add the handles
            sArgs.Handles=efdbIn.Handles;
            %set up either the loaded tubeDB or load the saved one
            if ~isfield(sArgs,'TubeDB')
                if isempty(efdbIn.TubeDB)
                    msgbox('File does not contain tubes. Please load the tubes first.','EasyFlow','error','modal');
                    uiwait;
                    return
                else
                    button='Current';
                end
            elseif ~isempty(efdbIn.TubeDB)
                button = questdlg('Load saved tubes or use current?.','Load Session','Saved', 'Current', 'Saved');
                set(fhIn,'pointer','watch');
            else
                button='Saved';
            end
            if strcmp(button,'Saved')
                foundall=1;
                usenewdir=0;
                newdir=localConfig.fcsFileDir;
                tic; ntot=length(sArgs.TubeDB);
                h=waitbar(0,'Loading Tubes...');
                tmpTubeDB=cell(length(sArgs.TubeDB),1);
                for i=1:length(sArgs.TubeDB)
                    if exist([sArgs.TubeDB(i).tubepath filesep sArgs.TubeDB(i).tubefile],'file')
                        fcsfile=fcsload([sArgs.TubeDB(i).tubepath filesep sArgs.TubeDB(i).tubefile]);
                    elseif usenewdir==1 && exist([newdir filesep sArgs.TubeDB(i).tubefile],'file') 
                        fcsfile=fcsload([newdir filesep sArgs.TubeDB(i).tubefile]);
                    else
                        tmpbutton = questdlg(['Cannot find ' sArgs.TubeDB(i).tubefile ...
                            'in directory ' sArgs.TubeDB(i).tubepath ...
                            '.'],'Load Session','Browse', 'Skip', 'Browse');
                        if strcmp(tmpbutton,'Next')
                            foundall=0;
                            continue
                        else
                            tmpnewdir=uigetdir(sArgs.DBInfo.Path,'Select Samples Folder');
                            sArgs.DBInfo.Path=tmpnewdir;
                            fcsfile=fcsload([tmpnewdir filesep sArgs.TubeDB(i).tubefile]);
                            usenewdir=1;
                            newdir=tmpnewdir;
                        end
                    end
                    if isempty(fcsfile)
                        foundall=0;
                        continue
                    end
                    tmpTubeDB{i}=LoadTube(fcsfile);
                    waitbar(i/ntot,h,['Loading Tubes (' num2str(ceil(toc*(ntot/i-1))) ' sec)']);
                end
                tmpTubeDB=cell2mat(tmpTubeDB);
                close(h);
                if foundall==0
                    msgbox('Some tubes were not opend successfully.','EasyFlow','error','modal');
                    uiwait;
                end
                
                if exist('tmpTubeDB','var')
                    [tmpTubeDB.Tubename]=deal(sArgs.TubeDB.Tubename);
                    sArgs.TubeDB=tmpTubeDB;
                else
                    msgbox('Cannot find fcs files.','EasyFlow','error','modal');
                    uiwait;
                    sArgs.TubeDB=[];
                end
            else
                sArgs.TubeDB=efdbIn.TubeDB;
            end
            
        else
            sArgs=efdbIn;
        end
        guidata(fhIn,sArgs)
        efdbIn=guidata(fhIn);
        % reread the tubes
        if ~isempty(efdbIn.TubeDB)
            efdbIn.TubeNames=[{'None'};[efdbIn.TubeDB.Tubename]'];
        else
            efdbIn.TubeNames={'None'};
        end
        set(efdbIn.Handles.TubePUM,'String',efdbIn.TubeNames);
        
        % initialize GraphDB and set all DataDeconv to []
        if isfield(efdbIn.GraphDB,'DataDeconv')
            efdbIn.GraphDB=rmfield(efdbIn.GraphDB,'DataDeconv');
            efdbIn.GraphDB(efdbIn.curGraph(1)).DataDeconv=[];
        end
        %read the graph list
        if isfield(efdbIn.GraphDB,'Name')
            List={efdbIn.GraphDB.Name};
            set(efdbIn.Handles.GraphList,'String',List);
            set(efdbIn.Handles.GraphList,'Value',efdbIn.curGraph);
        end
        %update the gate list
        UpdateGateList(efdbIn);
        guidata(fhIn,efdbIn);
        GraphListCallback(efdbIn.Handles.GraphList,[]);
        set(fhIn,'pointer','arrow')
        [~ ,name]=fileparts(efdbIn.DBInfo.Name);
        set(fhIn,'Name',['EasyFlow - FACS Analysis Tool (' name ')'])
        %resize the gui to the saved configuration
        fhResizeFcn(fhIn,eventdata)
        
        %update the FigPropPanel
        uiUpdate_FigPropPanel(efdbIn, propPanel);
        
        %finally, if I just opened the file, ischanged=0;
        efdbIn=guidata(fhIn);
        efdbIn.DBInfo.isChanged=0;
        guidata(fhIn,efdbIn);
        
        
    end
    function SessionSaveCallback(~,~)
        mArgsIn=guidata(fh);
        sArgs=mArgsIn;
        %remove raw data and handles before saving
        sArgs.TubeDB=rmfield(sArgs.TubeDB,'fcsfile');
        sArgs.TubeDB=rmfield(sArgs.TubeDB,'compdata');
        sArgs=rmfield(sArgs,'Handles');
        %if needed change paths to relative
        if isfield(sArgs.DBInfo,'RootFolder')
            sArgs=abs2relpath(sArgs);
        end
        sArgs.DBInfo.Path='';
        sArgs.DBInfo.Name='';
        sArgs.DBInfo.enabled_gui='';
        if ~isfield(mArgsIn,'DBInfo') || ~isfield(mArgsIn.DBInfo,'Name') || ~exist(mArgsIn.DBInfo.Name,'file')
            msgbox('No file selected. Use Save As.','EasyFlow','error','modal');
            uiwait;
            return
        end
        mArgsIn.DBInfo.isChanged=0;
        save(mArgsIn.DBInfo.Name,'sArgs');
        guidata(fh,mArgsIn);
        [~ ,name]=fileparts(mArgsIn.DBInfo.Name);
        set(fh,'Name',['EasyFlow - FACS Analysis Tool (' name ')'])
    end
    function SessionSaveAsCallback(~,~)
        mArgsIn=guidata(fh);
        sArgs=mArgsIn;
        %remove raw data and handles before saving
        sArgs.TubeDB=rmfield(sArgs.TubeDB,'fcsfile');
        sArgs.TubeDB=rmfield(sArgs.TubeDB,'compdata');
        sArgs=rmfield(sArgs,'Handles');
        %if needed change paths to relative
        if isfield(sArgs.DBInfo,'RootFolder')
            sArgs=abs2relpath(sArgs);
        end
        sArgs.DBInfo.Path='';
        sArgs.DBInfo.Name='';
        sArgs.DBInfo.enabled_gui='';
        if isfield(mArgsIn.DBInfo,'Path') && ischar(mArgsIn.DBInfo.Path) && exist(mArgsIn.DBInfo.Path,'dir')
            [file,path] = uiputfile('*.efl','Save As',mArgsIn.DBInfo.Path);
        else
            [file,path] = uiputfile('*.efl','Save As',localConfig.fcsFileDir);
        end
        if ischar(path) && exist(path,'dir')
            mArgsIn.DBInfo.Path=path;
        end
        mArgsIn.DBInfo.Name=[path,file];
        save(mArgsIn.DBInfo.Name,'sArgs');
        mArgsIn.DBInfo.isChanged=0;
        guidata(fh,mArgsIn);
        [~ ,name]=fileparts(mArgsIn.DBInfo.Name);
        set(fh,'Name',['EasyFlow - FACS Analysis Tool (' name ')'])
    end
    function SessionExportCallback(~,~)
        mArgsIn=guidata(fh);
        export2wsdlg({'Save MetaData as:'},{'mArgsIn'},{mArgsIn});
        guidata(fh,mArgsIn)
    end
    function SessionUseRelPath(~,~)
        mArgsIn=guidata(fh);
        MenuFileRelpath=findobj(fh,'Label','Use Relative Path');
        if strcmp(MenuFileRelpath.Checked,'off')
            MenuFileRelpath.Checked='on';
            mArgsIn.DBInfo.RootFolder='.';
            mArgsIn.DBInfo.isChanged=1;
        else
            MenuFileRelpath.Checked='off';
            mArgsIn.DBInfo=rmfield(mArgsIn.DBInfo,'RootFolder');
            mArgsIn.DBInfo.isChanged=1;
        end
        guidata(fh,mArgsIn)
    end

    function SampleLoadCallback(~,~)
        set(fh,'pointer','watch');
        mArgsIn=guidata(fh);
        if isfield(mArgsIn,'DBInfo') && isfield(mArgsIn.DBInfo,'Path') && ischar(mArgsIn.DBInfo.Path) && exist(mArgsIn.DBInfo.Path,'dir')
            [filename,dirname]=uigetfile({'*.fcs';'*.xlsx'},'Open Tubes',mArgsIn.DBInfo.Path,'MultiSelect','on');
        else
            [filename,dirname]=uigetfile({'*.fcs';'*.xlsx'},'Open Tubes',localConfig.fcsFileDir,'MultiSelect','on');
        end
        if ischar(dirname) && exist(dirname,'dir')
            mArgsIn.DBInfo.Path=dirname;
        end
        if ischar(filename)
            filename={filename};
        elseif isnumeric(filename) && filename==0
            set(fh,'pointer','arrow');
            return
        end
        tic; ntot=length(filename); loopnum=0;
        h=waitbar(0,'Loading Tubes...','WindowStyle','modal');
        for curfile=filename
            if ~exist([dirname char(curfile)],'file')
                continue
            end
            % use here file load, to either open fcs or xlsx files
            fcsfile=fileload([dirname char(curfile)]);
            if isempty(fcsfile)
                continue
            end
            % the TUBE NAME is the field by which the tube is named, if not
            % use filname and make a tubename field
            ctube=LoadTube(fcsfile);
            if ~isempty(mArgsIn.TubeDB)
                %automatically make tubename unique
                tubename=matlab.lang.makeUniqueStrings(ctube.Tubename{1},[mArgsIn.TubeDB.Tubename]);
                ctube.fcsfile=fcssetparam(ctube.fcsfile,'TUBE NAME',tubename);
                ctube.Tubename{1}=tubename;

                if isempty(ctube.Tubename{1})
                    continue
                elseif any(strcmp(strcat({mArgsIn.TubeDB.tubepath},{mArgsIn.TubeDB.tubefile}),[ctube.tubepath ctube.tubefile]))
                    %there is a different tube with the same file path.
                    msgbox(['Can''t open file ' fcsfile.filename '. The file is already open.'],'EasyFlow','error','modal');
                    uiwait;
                    continue;
                end
            end
            mArgsIn.TubeDB(end+1)=ctube;
            % if this tube already appears in the graphDB then recalc gated
            % data
            if isfield(mArgsIn,'curGraph') && ~isempty(mArgsIn.curGraph)
                tmpcur=mArgsIn.curGraph;
                mArgsIn.curGraph=find(strcmp({mArgsIn.GraphDB.Name},mArgsIn.TubeDB(end).Tubename));
                mArgsIn=CalculateGatedData(mArgsIn);
                mArgsIn.curGraph=tmpcur;
            end
            loopnum=loopnum+1;
            waitbar(loopnum/ntot,h,['Loading Tubes (' num2str(ceil(toc*(ntot/loopnum-1))) ' sec)']);
        end
        close(h);
        mArgsIn.TubeNames=[{'None'};[mArgsIn.TubeDB.Tubename]'];
        set(mArgsIn.Handles.TubePUM,'String',mArgsIn.TubeNames);
        guidata(fh,mArgsIn);
        set(fh,'pointer','arrow');
    end
    function FolderLoadCallback(~,~)
        set(fh,'pointer','watch');
        mArgsIn=guidata(fh);
        if isfield(mArgsIn,'DBInfo') && isfield(mArgsIn.DBInfo,'Path') && ischar(mArgsIn.DBInfo.Path) && exist(mArgsIn.DBInfo.Path,'dir')
            dirname=uigetdir(mArgsIn.DBInfo.Path,'Open Tubes');
        else
            dirname=uigetdir(localConfig.fcsFileDir,'Open Tubes');
        end
        if exist(dirname,'dir')
            mArgsIn.DBInfo.Path=dirname;
        end
        filename = dir([dirname, filesep, '**', filesep, '*.fcs'])';
        tic; ntot=length(filename); loopnum=0;
        h=waitbar(0,'Loading Tubes...','WindowStyle','modal');
        for curfilestruct=filename
            dirname = curfilestruct.folder;
            curfile = curfilestruct.name;
            if ~exist([dirname filesep char(curfile)],'file')
                continue
            end
            fcsfile=fcsload([dirname filesep char(curfile)]);
            if isempty(fcsfile)
                continue
            end
            % the TUBE NAME is the field by which the tube is named, if not
            % use filname and make a tubename field
            ctube=LoadTube(fcsfile);
            if ~isempty(mArgsIn.TubeDB)
                %automatically make tubename unique
                tubename=matlab.lang.makeUniqueStrings(ctube.Tubename{1},[mArgsIn.TubeDB.Tubename]);
                ctube.fcsfile=fcssetparam(ctube.fcsfile,'TUBE NAME',tubename);
                ctube.Tubename{1}=tubename;


                if isempty(ctube.Tubename{1})
                    continue
                elseif any(strcmp(strcat({mArgsIn.TubeDB.tubepath},{mArgsIn.TubeDB.tubefile}),[ctube.tubepath ctube.tubefile]))
                    %there is a different tube with the same file path.
                    msgbox(['Can''t open file ' fcsfile.filename '. The file is already open.'],'EasyFlow','error','modal');
                    uiwait;
                    continue;
                end
            end
            mArgsIn.TubeDB(end+1)=ctube;
            % if this tube already appears in the graphDB then recalc gated
            % data
            if isfield(mArgsIn,'curGraph') && ~isempty(mArgsIn.curGraph)
                tmpcur=mArgsIn.curGraph;
                mArgsIn.curGraph=find(strcmp({mArgsIn.GraphDB.Name},mArgsIn.TubeDB(end).Tubename));
                mArgsIn=CalculateGatedData(mArgsIn);
                mArgsIn.curGraph=tmpcur;
            end
            loopnum=loopnum+1;
            waitbar(loopnum/ntot,h,['Loading Tubes (' num2str(ceil(toc*(ntot/loopnum-1))) ' sec)']);
        end
        close(h);
        mArgsIn.TubeNames=[{'None'};[mArgsIn.TubeDB.Tubename]'];
        set(mArgsIn.Handles.TubePUM,'String',mArgsIn.TubeNames);
        guidata(fh,mArgsIn);
        set(fh,'pointer','arrow');
    end
    function TubeSaveCallback(~,~)
        mArgsIn=guidata(fh);
        button = questdlg('Do you really want to overwrite tube data files? you should save an original version of the files.', 'Save Tubes', 'Save', 'Cancel', 'Cancel');
        if strcmp(button,'Save')
            fcssave([mArgsIn.TubeDB.fcsfile],1);
        end
    end
    function TubeShowPrmCallback(~,~)
        mArgsIn=guidata(fh);
        S=mArgsIn.TubeNames(2:end);
        if isempty(S)
            msgbox('No open tubes were found.','EasyFlow','error','modal');
            uiwait;
            return;
        end
        [Selection,ok] = listdlg('ListString',S,'Name','Select Tube','PromptString','Select tubes to rename','SelectionMode','single');
        if ok==0
            return;
        end        
        if ok==1
            i=Selection;
            fcsedit(mArgsIn.TubeDB(i).fcsfile);
            guidata(fh,mArgsIn);
        end
    end
    function TubeRemoveCallback(~,eventdata)
        mArgsIn=guidata(fh);
        if ~isfield(mArgsIn.TubeDB,'Tubename')
            msgbox('No open tubes were found.','EasyFlow','error','modal');
            uiwait;
            return;
        end
        S=[mArgsIn.TubeDB.Tubename];
        if isempty(S)
            msgbox('No open tubes were found.','EasyFlow','error','modal');
            uiwait;
            return;
        end
        [Selection,ok] = listdlg('ListString',S,'Name','Select Tube','PromptString','Select tubes to be removed','OKString','Remove');
        if ok==1
            % remove it from the TubeDB structures
            mArgsIn.TubeDB=mArgsIn.TubeDB(setdiff(1:length(S),Selection));
            if isfield(mArgsIn,'GatesDB') && ~isempty(mArgsIn.GatesDB)
                mArgsIn.GatesDB=rmfield(mArgsIn.GatesDB,intersect(matlab.lang.makeValidName(S(Selection)),fieldnames(mArgsIn.GatesDB)));
            end
            mArgsIn.TubeNames=[{'None'};[mArgsIn.TubeDB.Tubename]'];
            set(mArgsIn.Handles.TubePUM,'String',mArgsIn.TubeNames);
        end
        %reread graphs
        guidata(fh,mArgsIn);
        GraphListCallback(mArgsIn.Handles.GraphList,eventdata)
    end
    function TubeRenameCallback(~,~)
        mArgsIn=guidata(fh);
        S=mArgsIn.TubeNames(2:end);
        if isempty(S)
            msgbox('No open tubes were found.','EasyFlow','error','modal');
            uiwait;
            return;
        end
        [Selection,ok] = listdlg('ListString',S,'Name','Select Tube','PromptString','Select tubes to rename');
        if ok==0
            return;
        end
        renamerule=inputdlg('Enter the new name. Use $ as the original tube name');
        if isempty(renamerule)
            return;
        end
        
        if ok==1
            for i=Selection
                %check that the new name does not exists
                if any(strcmp([mArgsIn.TubeDB([1:i-1,i+1:end]).Tubename],strrep(renamerule, '$', S(i))))
                    %tubename already already exists, continue
                    msgbox(['Can''t rename ' mArgsIn.TubeDB(i).Tubename ' to ' strrep(renamerule, '$', S(i)) '. The new tube name already exists.'],'EasyFlow','error','modal');
                    uiwait;
                    continue;
                end
                % rename it in the TubeDB structures
                mArgsIn.TubeDB(i).Tubename=strrep(renamerule, '$', S(i));
                % change in the fcsfiles
                mArgsIn.TubeDB(i).fcsfile=fcssetparam(mArgsIn.TubeDB(i).fcsfile,'TUBE NAME',mArgsIn.TubeDB(i).Tubename{1});
                % replace the names in the GraphDB and GatesDB
                if ~isempty(mArgsIn.GraphDB)
                    [mArgsIn.GraphDB(strcmp({mArgsIn.GraphDB.Data},S(i))).Data]=deal(strrep(char(renamerule), '$', S{i}));
                end
                if isfield(mArgsIn,'GatesDB') && isfield(mArgsIn.GatesDB,matlab.lang.makeValidName(S(i)))
                    mArgsIn.GatesDB.(matlab.lang.makeValidName(strrep(char(renamerule), '$', S{i})))=mArgsIn.GatesDB.(matlab.lang.makeValidName(S{i}));
                    mArgsIn.GatesDB=rmfield(mArgsIn.GatesDB,matlab.lang.makeValidName(S{i}));
                end
            end
            mArgsIn.TubeNames=[{'None'};[mArgsIn.TubeDB.Tubename]'];
            set(mArgsIn.Handles.TubePUM,'String',mArgsIn.TubeNames);
            guidata(fh,mArgsIn);
        end
    end
    function FileTubeRenameCallback(~,~)
        mArgsIn=guidata(fh);
        S=mArgsIn.TubeNames(2:end);
        if isempty(S)
            msgbox('No open tubes were found.','EasyFlow','error','modal');
            uiwait;
            return;
        end
        % open an xls file with the renaming
        if isfield(mArgsIn,'DBInfo') && isfield(mArgsIn.DBInfo,'Path') && ischar(mArgsIn.DBInfo.Path) && exist(mArgsIn.DBInfo.Path,'dir')
            [xlsfilename,targetdir]=uigetfile('.xlsx','Open Template',mArgsIn.DBInfo.Path);
        else
            [xlsfilename,targetdir]=uigetfile('.xlsx','Open Template',localConfig.fcsFileDir);
        end
        if ~ischar(targetdir)
            return
        end
        mArgsIn.DBInfo.Path=targetdir;
        enabled_gui=findobj(fh,'Enable','on');
        set(enabled_gui,'Enable','off');
        set(fh,'pointer','watch');
        drawnow
        [~,~,template]=xlsread([targetdir,xlsfilename]);
        template=cellfun(@num2str,template,'uni',0);
        
        for i=1:size(template,1)
            %use the filename to get the tubename
            tubenum=find(strcmp({mArgsIn.TubeDB.tubefile}',[template{i,1},'.fcs']));
            if isempty(tubenum)
                continue
            end
            NonEmptyFields=~strcmp(template(i,1:end),'NaN');
            NonEmptyFields(1)=0;
            newtubename={strjoin(template(i,NonEmptyFields),'_')};
            %check that the new name does not exists
            if any(strcmp([mArgsIn.TubeDB([1:tubenum-1,tubenum+1:end]).Tubename],newtubename))
                %tubename already already exists, continue
                msgbox(['Can''t rename ' mArgsIn.TubeDB(i).Tubename ' to ' newtubename{1} '. The new tube name already exists.'],'EasyFlow','error','modal');
                uiwait;
                continue;
            end
            % rename it in the TubeDB structures
            mArgsIn.TubeDB(tubenum).Tubename=newtubename;
            % change in the fcsfiles
            mArgsIn.TubeDB(tubenum).fcsfile=fcssetparam(mArgsIn.TubeDB(tubenum).fcsfile,'TUBE NAME',newtubename);
            % replace the names in the GraphDB and GatesDB
            if ~isempty(mArgsIn.GraphDB)
                [mArgsIn.GraphDB(strcmp({mArgsIn.GraphDB.Data},S(tubenum))).Data]=deal(newtubename{1});
            end
            if isfield(mArgsIn,'GatesDB') && isfield(mArgsIn.GatesDB,matlab.lang.makeValidName(S(tubenum)))
                mArgsIn.GatesDB.(matlab.lang.makeValidName(newtubename{1}))=mArgsIn.GatesDB.(matlab.lang.makeValidName(S{tubenum}));
                mArgsIn.GatesDB=rmfield(mArgsIn.GatesDB,matlab.lang.makeValidName(S{tubenum}));
            end
        end
        
        mArgsIn.TubeNames=[{'None'};[mArgsIn.TubeDB.Tubename]'];
        set(mArgsIn.Handles.TubePUM,'String',mArgsIn.TubeNames);
        guidata(fh,mArgsIn);
        set(fh,'pointer','arrow')
        set(enabled_gui,'Enable','on');
    end
    function TubeCompCallback(~,~)
        v=version('-release');
        v=str2double(v(1:end-1));
        if v<2008
            msgbox('You have an old version of MATLAB. Update.','EasyFlow','error','modal');
            uiwait;
            return;
        end
        EasyFlow_compensation(fh);
        mArgsIn=guidata(fh);
        mArgsIn.DBInfo.isChanged=1;
        guidata(fh,mArgsIn)
    end
    function TubePrmCallback(~,~)
        mArgsIn=guidata(fh);
%        newfcs=fcsedit([mArgsIn.TubeDB.fcsfile])
%        mArgsIn.DBInfo.isChanged=1;
        guidata(fh,mArgsIn)
    end
    function TubeAddParam(~,~)
        set(fh,'pointer','watch');
        mArgsIn=guidata(fh);
        %select the tubes for which we want to add the new parameter
        S=mArgsIn.TubeNames(2:end);
        if isempty(S)
            msgbox('No open tubes were found.','EasyFlow','error','modal');
            uiwait;
            return;
        end
        [Selection,ok] = listdlg('ListString',S,'Name','Select Tubes','PromptString','Select tubes to add parameter');
        if ok==0
            return;
        end

        ParamName=char(inputdlg('Parameter Name:','Add Parameter'));

        %define the new parameter
        calcprm_eq=char(inputdlg('Insert equation. Use p1,p2,... as your parameters. Note that they are vectors'...
            ,'Define Equation'));
        %change mArgsIn.TubeDB:
        %cprmnum is the next number of calculated param. find the last
        %calculated param say CP8 so the next one is CP9. 
        cprmnum=max(... find the maximum of all calculated parameter numbers
            cellfun(... for every tube in tubeindex
            @(tubex) max([0 cellfun(@(x) str2double(x(3)), ...get the character after the CP
            ...mArgsIn.TubeDB(1).parname( ~cellfun(@isempty, strfind(tubex,'CP')) ))])+1 ...for every parname with 'CP'
            mArgsIn.TubeDB(1).parname(contains(tubex,'CP')) )])+1 ...for every parname with 'CP'
            ,{mArgsIn.TubeDB(Selection).parname}));
        for i=Selection
            mArgsIn.TubeDB(i).parname{end+1}=['CP' num2str(cprmnum)];
            mArgsIn.TubeDB(i).parsymbol{end+1}=ParamName;
            calcprm_eq_rep=regexprep(calcprm_eq,'p([0-9]*)',['mArgsIn.TubeDB(' num2str(i) ').compdata(:,$1)']);
            mArgsIn.TubeDB(i).compdata(:,end+1)=eval(calcprm_eq_rep);
            
            %change the fcsfile itself
            %the data
            mArgsIn.TubeDB(i).fcsfile.fcsdata(:,end+1)=mArgsIn.TubeDB(i).compdata(:,end);
            %and the header
            ParamProp=cellfun(@(x) x(4), mArgsIn.TubeDB(i).fcsfile.var_name(~cellfun(@isempty, regexp(mArgsIn.TubeDB(i).fcsfile.var_name,'\$P1[A-Z]','once'))));
            pnum=num2str(str2double(mArgsIn.TubeDB(i).fcsfile.var_value(strcmp(mArgsIn.TubeDB(i).fcsfile.var_name,'$PAR')))+1);
            mArgsIn.TubeDB(i).fcsfile=fcssetparam(mArgsIn.TubeDB(i).fcsfile, '$PAR', pnum);
            
            for pprop=ParamProp'
                switch pprop
                    case 'B'
                        pname=['$P' pnum 'B'];
                        pval='32';
                    case 'E'
                        pname=['$P' pnum 'E'];
                        pval='0.000000,0.000000';
                    case 'G'
                        pname=['$P' pnum 'G'];
                        pval='1';
                    case 'N'
                        pname=['$P' pnum 'N'];
                        pval=['CP' num2str(cprmnum)];
                    case 'R'
                        pname=['$P' pnum 'R'];
                        pval='262144';
                    case 'S'
                        pname=['$P' pnum 'S'];
                        pval=ParamName;
                    otherwise
                        pname=['$P' pnum pprop];
                        pval='';
                        msgbox('Everything is fine, but tell Yaron: Add Parap>UnknownParamProp'...
                            ,'EasyFlow','warn','modal');
                end
                mArgsIn.TubeDB(i).fcsfile=fcssetparam(mArgsIn.TubeDB(i).fcsfile, pname, pval);
            end
            
            

        end
        guidata(fh,mArgsIn);
        GraphListCallback(mArgsIn.Handles.GraphList,[])
        set(fh,'pointer','arrow')
    end

    function ToolsBatch(~,~)
        mArgsIn=guidata(fh);
        inpstr=inputdlg({'Replace (regexp allowed)','With'},'Batch conversion',[1,5]');
        if isempty(inpstr)
            return
        end
        str1=inpstr{1};
        str2=cellstr(inpstr{2})';
        initial_tubenum=length(mArgsIn.GraphDB);
        GraphDB=fcsbatch(mArgsIn.GraphDB(mArgsIn.curGraph),str1,str2);
        mArgsIn.GraphDB=[mArgsIn.GraphDB,GraphDB];
        set(mArgsIn.Handles.GraphList,'String',{mArgsIn.GraphDB.Name});
        mArgsIn.DBInfo.isChanged=1;
        
        %recalculate gates for the new graphs
        tic;
        curGraph=mArgsIn.curGraph;
        h=waitbar(0,'Loading...');
        loop_length=length(mArgsIn.GraphDB)-initial_tubenum;
        for i=(initial_tubenum+1):length(mArgsIn.GraphDB)
            mArgsIn.curGraph=i;
            if ~isfield(mArgsIn,'GatesDB') || ~isfield(mArgsIn.GatesDB,char((matlab.lang.makeValidName(mArgsIn.GraphDB(mArgsIn.curGraph).Data))))
                mArgsIn.GraphDB(mArgsIn.curGraph).Gates={};
            else
                mArgsIn.GraphDB(mArgsIn.curGraph).Gates=intersect(...
                    mArgsIn.GraphDB(mArgsIn.curGraph).Gates,...
                    fieldnames(mArgsIn.GatesDB.(matlab.lang.makeValidName(mArgsIn.GraphDB(1).Data))));
            end
            mArgsIn=CalculateGatedData(mArgsIn);
            timeleft=toc*(loop_length/(i-initial_tubenum)-1);
            waitbar((i-initial_tubenum)/loop_length,h,[num2str(5*ceil(timeleft/5)) ' seconds remaining...']);
        end
        delete(h);
        mArgsIn.curGraph=curGraph;
        guidata(fh,mArgsIn)
    end
    function ToolsAddall(~,eventdata)
        mArgsIn=guidata(fh);
        curgraph=length(mArgsIn.GraphDB)+1;
        %reselect selected graphs to save their configuration
        GraphListCallback(mArgsIn.Handles.GraphList,eventdata);
        for tubename=mArgsIn.TubeNames(2:end)'
            mArgsIn=AddGraph(mArgsIn,[],tubename{1});
        end
        mArgsIn.curGraph=curgraph:length(mArgsIn.GraphDB);
        set(mArgsIn.Handles.GraphList,'Value',mArgsIn.curGraph);

        mArgsIn=CalculateGatedData(mArgsIn);
        mArgsIn.DBInfo.isChanged=1;
        mArgsIn=DataChange(mArgsIn);
        guidata(fh,mArgsIn);
        GraphListCallback(mArgsIn.Handles.GraphList,eventdata)
        mArgsIn=guidata(fh);
        mArgsIn=CalculateMarkers(mArgsIn);
        guidata(fh,mArgsIn);
    end
    function ToolsNewFit(~,~)
        mArgsIn=guidata(fh);
        f=mArgsIn.GraphDB(mArgsIn.curGraph(1)).plotdata(:,1);
        h=mArgsIn.GraphDB(mArgsIn.curGraph(1)).plotdata(:,2);
        cftool(f,h);
        guidata(fh,mArgsIn)
    end
    function ToolsApplyFit(~,~)
        mArgsIn=guidata(fh);
        vars=evalin('base','who');
        vars=vars(cellfun(@(x) isa(evalin('base',x),'fittype'),vars));
        fitvarname=popupdlg('choose a fit variable',vars);
        if isempty(fitvarname)
            return;
        end
        fitvar=evalin('base',vars{fitvarname});        
        %precheck if variable is fittype
        if ~isa(fitvar,'fittype')
            msgbox(['The variable ' vars{fitvarname} ' does not contain a fit data.'],'EasyFlow','error','modal');
            uiwait;
            return;
        end
        for cgraph=mArgsIn.curGraph
            f=mArgsIn.GraphDB(cgraph).plotdata(:,1);
            h=mArgsIn.GraphDB(cgraph).plotdata(:,2);
            [cfun,gof]=fit(f(:),h(:),fitvar);
            h=line(f, cfun(f));
            set(h,'linestyle',':');
            set(h,'Color',mArgsIn.GraphDB(cgraph).PlotColor);
            mArgsIn.GraphDB(cgraph).fit={cfun,gof,mArgsIn.Display.graph_Xaxis,mArgsIn.Display.graph_Xaxis_param(3)};
        end
        guidata(fh,mArgsIn)
    end
    function ToolsRemFit(~,~)
        mArgsIn=guidata(fh);
        [mArgsIn.GraphDB(mArgsIn.curGraph).fit]=deal([]);
        mArgsIn = DrawGraphs(mArgsIn);
        guidata(fh,mArgsIn)
    end
    function ToolsExport(~,~)
        mArgsIn=guidata(fh);
        output=cell(length(mArgsIn.curGraph),1);
        for i=1:length(mArgsIn.curGraph)
            graph=mArgsIn.curGraph(i);
            gateddata=[];
            pname=[];
            tubeidx=find(strcmp([mArgsIn.TubeDB.Tubename],mArgsIn.GraphDB(graph).Data),1,'first');
            if tubeidx
                gateddata=mArgsIn.TubeDB(tubeidx).compdata(mArgsIn.GraphDB(graph).gatedindex,:);
                pname=mArgsIn.TubeDB(tubeidx).parsymbol;
            end
            output{i}.Data=gateddata;
            output{i}.Name=mArgsIn.GraphDB(graph).Name;
            output{i}.ParamName=pname;
        end
        export2wsdlg({'Save Data as:'},{'Output'},{cell2mat(output)}); % if problem remove the 'cell2mat'
    end
    function StatWinCallback(~,~)
        EasyFlow_statwin(fh);
    end
    
    function HelpAbout(~,~)
        h=figure('Position',[0,0,300,140],...
            'MenuBar','none',...
            'Name','About EasyFlow',...
            'NumberTitle','off',...
            'Visible','off');
        movegui(h,'center');
        
        uicontrol(h,'Style','text',...
            'Position',[0,130,300,10],...
            'FontSize',10,...
            'FontWeight','normal',...
            'String','');
        uicontrol(h,'Style','text',...
            'Position',[0,90,300,40],...
            'FontSize',20,...
            'FontWeight','bold',...
            'String','EasyFlow');
        uicontrol(h,'Style','text',...
            'Position',[0,70,300,20],...
            'FontSize',10,...
            'FontWeight','bold',...
            'String','FACS Analysis Tool');
        uicontrol(h,'Style','text',...
            'Position',[0,60,300,10],...
            'FontSize',10,...
            'FontWeight','normal',...
            'String','');
        uicontrol(h,'Style','text',...
            'Position',[0,40,300,20],...
            'FontSize',10,...
            'FontWeight','normal',...
            'String',['Version ', sprintf('%.2f',curversion), ' ', versiondate]);
        uicontrol(h,'Style','text',...
            'Position',[0,20,300,20],...
            'FontSize',10,...
            'FontWeight','normal',...
            'String','Authors:');
        uicontrol(h,'Style','text',...
            'Position',[0,00,300,20],...
            'FontSize',10,...
            'FontWeight','normal',...
            'String','Yaron E Antebi');
        
        set(h,'Visible','on')
        
        
    end

    function ACM_graphprop(~,~)
        EasyFlow_figprop(fh);
    end

    function ACM_fixaxis(~,~)
        mArgsIn=guidata(fh);
        if strcmp(get(gcbo, 'Checked'),'on')
            if isfield(mArgsIn.Display,'Axis')
                mArgsIn.Display=rmfield(mArgsIn.Display,'Axis');
            end
            axis('auto');
            set(gcbo, 'Checked', 'off');
        else
            mArgsIn.Display.Axis=axis;
            set(gcbo, 'Checked', 'on');
        end
        mArgsIn.Display.Changed=1;
        mArgsIn.DBInfo.isChanged=1;
        guidata(fh,mArgsIn)
    end
    function ACM_setquad(~,~)
        mArgsIn=guidata(fh);
        [x,y]=ginput(1);
        %rescale the coordinates to its linear scale values
        switch mArgsIn.Display.graph_Xaxis
            case 'log'
                x=10.^x;
            case 'logicle'
                x=2*sinh(log(10)*x)/mArgsIn.Display.graph_Xaxis_param(3);
        end
        switch mArgsIn.Display.graph_Yaxis
            case 'ylog'
                y=10.^y;
            case 'ylogicle'
                y=2*sinh(log(10)*y)/mArgsIn.Display.graph_Yaxis_param(3);
        end
        for cgraph=mArgsIn.curGraph
            mArgsIn.GraphDB(cgraph).Stat.quad=[x,y];
        end
        mArgsIn=CalculateMarkers(mArgsIn);
        DrawQuads(mArgsIn);
        mArgsIn.DBInfo.isChanged=1;
        guidata(fh,mArgsIn)
    end
    function ACM_cpquad(~,~)
        mArgsIn=guidata(fh);
        mArgsIn.copy.quad=mArgsIn.GraphDB(mArgsIn.curGraph(1)).Stat.quad;
        mArgsIn.DBInfo.isChanged=1;
        guidata(fh,mArgsIn)
    end
    function ACM_pastequad(~,~)
        mArgsIn=guidata(fh);
        if isfield(mArgsIn,'copy') && isfield(mArgsIn.copy,'quad')
            for cgraph=mArgsIn.curGraph
                mArgsIn.GraphDB(cgraph).Stat.quad=mArgsIn.copy.quad;
            end
        end
        mArgsIn=CalculateMarkers(mArgsIn);
        DrawQuads(mArgsIn);
        mArgsIn.DBInfo.isChanged=1;
        guidata(fh,mArgsIn)
    end
    function ACM_rmquad(~,~)
        mArgsIn=guidata(fh);
        mArgsIn.GraphDB(mArgsIn.curGraph(1)).Stat=rmfield(mArgsIn.GraphDB(mArgsIn.curGraph(1)).Stat,'quad');
        delete(findobj(gca,'Tag','quad'));
        mArgsIn.DBInfo.isChanged=1;
        mArgsIn=CalculateMarkers(mArgsIn);
        guidata(fh,mArgsIn)
    end
    function ACM_DrawToFigure(hObject,~)
        efdb=efdb_load(hObject);
        DrawToFigure(efdb);
    end

    function MenuGatesAddGate(hObject,~)
        efdbIn=efdb_load(hObject);
        efdbIn=disable_gui(efdbIn);
        
        %
        %check parameters and determine the gate name
        %
        %check that all plots have the same axis
        allplots_color={efdbIn.GraphDB(efdbIn.curGraph).Color};
        if size(unique(cell2mat(allplots_color(:)),'rows'),1)~= 1
            %not all plots have the same x-axis. 
            %cannot create a gate
            msgbox('All plots should have the same X-axis.','EasyFlow','error','modal');
            uiwait;
            enable_gui(efdbIn);
            return;
        end
        if ~strcmp(efdbIn.Display.graph_type,'Histogram')
            %need also to check the y axis
            allplots_color={efdbIn.GraphDB(efdbIn.curGraph).Color2};
            if size(unique(cell2mat(allplots_color(:)),'rows'),1)~= 1
                %not all plots have the same y-axis.
                %cannot create a gate
                msgbox('All plots should have the same Y-axis.','EasyFlow','error','modal');
                uiwait;
                enable_gui(efdbIn);
                return;
            end
        end
        gatename=char(inputdlg('Gate name:','Add Gate',1));
        % check that the name is non empty and valid and doesn't exist already.
        if isempty(gatename)
            enable_gui(efdbIn);
            return;
        end
        if ~isvarname(gatename)
            msgbox('The gate name is invalid. It should containt leters and numbers and start with a letter.','EasyFlow','error','modal');
            uiwait;
            enable_gui(efdbIn);
            return;
        end
        if isfield(efdbIn,'GatesDBnew')
            allgates=fieldnames(efdbIn.GatesDBnew);
            if any(strcmp(allgates,gatename))
                msgbox('A gate with this name already exists.','EasyFlow','error','modal');
                uiwait;
                enable_gui(efdbIn);
                return;
            end
        end
        
        %
        %create the gate
        %
        switch efdbIn.Display.graph_type
            case 'Histogram'
                %define the gate
                lingate=gate1d;
                %do the necessary transformation on the values of the gate to make
                %them linear
                switch efdbIn.Display.graph_Xaxis
                    case 'log'
                        lingate(1:2)=10.^lingate(1:2);
                    case 'logicle'
                        lingate(1:2)=2*sinh(log(10)*lingate(1:2))/efdbIn.Display.graph_Xaxis_param(3);
                end
                %create the gate structure
                new_gate{1}=lingate;
                new_gate{2}=efdbIn.GraphDB(efdbIn.curGraph(1)).Color;
                new_gate{3}='1D';
                %add to the GatesDB 
                efdbIn.GatesDBnew.(gatename)=new_gate;
            otherwise
                %define the gate
                lingate=gate2d;
                %do the necessary transformation on the values of the gate to make
                %them linear
                switch efdbIn.Display.graph_Xaxis
                    case 'log'
                        lingate(1,:)=10.^lingate(1,:);
                    case 'logicle'
                        lingate(1,:)=2*sinh(log(10)*lingate(1,:))/efdbIn.Display.graph_Xaxis_param(3);
                end
                switch efdbIn.Display.graph_Yaxis
                    case 'ylog'
                        lingate(2,:)=10.^lingate(2,:);
                    case 'ylogicle'
                        lingate(2,:)=2*sinh(log(10)*lingate(2,:))/efdbIn.Display.graph_Yaxis_param(3);
                end
                %create the gate structure
                new_gate{1}=lingate;
                new_gate{2}=efdbIn.GraphDB(efdbIn.curGraph(1)).Color;
                new_gate{3}=efdbIn.GraphDB(efdbIn.curGraph(1)).Color2;
                %add to the GatesDB 
                efdbIn.GatesDBnew.(gatename)=new_gate;
        end
%removed on 2020_01_14. should be deleteable.
        % apply the gate to all tubes 
%        for cur_tube_indx=1:length(efdbIn.TubeDB)
%            gatemask=calculate_gate_mask(efdbIn.TubeDB(cur_tube_indx),new_gate);
%            efdbIn.TubeDB(cur_tube_indx).gatemask.(gatename)=gatemask;
%        end
        % Update the GUI component
        UpdateGateList(efdbIn);
        %DrawGraphs(fh);
        efdbIn=enable_gui(efdbIn);
        efdb_save(efdbIn);
    end
    function MenuGatesAddContourGate(hObject,~)
        efdbIn=efdb_load(hObject);
        efdbIn=disable_gui(efdbIn);
        
        %
        %check parameters and determine the gate name
        %
        %contour only works in 2d
        if strcmp(efdbIn.Display.graph_type,'Histogram')
            msgbox('A gate with this name already exists.','EasyFlow','error','modal');
            uiwait;
            return;
        end        
        %check that all plots have the same x and y axis
        allplots_color={efdbIn.GraphDB(efdbIn.curGraph).Color};
        if size(unique(cell2mat(allplots_color(:)),'rows'),1)~= 1
            %not all plots have the same x-axis. 
            %cannot create a gate
            msgbox('All plots should have the same X-axis.','EasyFlow','error','modal');
            uiwait;
            enable_gui(efdbIn);
            return;
        end
        allplots_color={efdbIn.GraphDB(efdbIn.curGraph).Color2};
        if size(unique(cell2mat(allplots_color(:)),'rows'),1)~= 1
            %not all plots have the same y-axis.
            %cannot create a gate
            msgbox('All plots should have the same Y-axis.','EasyFlow','error','modal');
            uiwait;
            enable_gui(efdbIn);
            return;
        end
        gatename=char(inputdlg('Gate name:','Add Gate'));
        % check that the name is non empty and valid and doesn't exist already.
        if isempty(gatename)
            enable_gui(efdbIn);
            return;
        end
        if ~isvarname(gatename)
            msgbox('The gate name is invalid. use only a letter followed by letters and numbers.','EasyFlow','error','modal');
            uiwait;
            enable_gui(efdbIn);
            return;
        end
        if isfield(efdbIn,'GatesDBnew')
            allgates=fieldnames(efdbIn.GatesDBnew);
            if any(strcmp(allgates,gatename))
                msgbox('A gate with this name already exists.','EasyFlow','error','modal');
                uiwait;
                enable_gui(efdbIn);
                return;
            end
        end
        
        %
        %create the gate
        %
        %define the gate
        lingate=gate2d_cntr;
        %do the necessary transformation on the values of the gate to make
        %them linear
        switch efdbIn.Display.graph_Xaxis
            case 'log'
                lingate(1,:)=10.^lingate(1,:);
            case 'logicle'
                lingate(1,:)=2*sinh(log(10)*lingate(1,:))/efdbIn.Display.graph_Xaxis_param(3);
        end
        switch efdbIn.Display.graph_Yaxis
            case 'ylog'
                lingate(2,:)=10.^lingate(2,:);
            case 'ylogicle'
                lingate(2,:)=2*sinh(log(10)*lingate(2,:))/efdbIn.Display.graph_Yaxis_param(3);
        end
        %create the gate structure
        new_gate{1}=lingate;
        new_gate{2}=efdbIn.GraphDB(efdbIn.curGraph(1)).Color;
        new_gate{3}=efdbIn.GraphDB(efdbIn.curGraph(1)).Color2;
        %add to the GatesDB
        efdbIn.GatesDBnew.(gatename)=new_gate;
        
        % apply the gate to all tubes
        for cur_tube_indx=1:length(efdbIn.TubeDB)
            gatemask=calculate_gate_mask(efdbIn.TubeDB(cur_tube_indx),new_gate);
            efdbIn.TubeDB(cur_tube_indx).gatemask.(gatename)=gatemask;
        end
        % Update the GUI component
        UpdateGateList(efdbIn);
        
        efdbIn=enable_gui(efdbIn);
        efdb_save(efdbIn);
    end
    function MenuGatesAddLogicalGate(hObject,~)
        efdbIn=efdb_load(hObject);
        efdbIn=disable_gui(efdbIn);

        %
        %check parameters and determine the gate name
        %
        gatename=char(inputdlg('Gate name:','Add Logical Gate'));
        % check that the name is non empty and valid and doesn't exist already.
        if isempty(gatename)
            return;
        end
        if ~isvarname(gatename)
            msgbox('The gate name is invalid. use only a letter followed by letters and numbers.','EasyFlow','error','modal');
            uiwait;
            enable_gui(efdbIn);
            return;
        end
        if isfield(efdbIn,'GatesDBnew')
            allgates=fieldnames(efdbIn.GatesDBnew);
            if any(strcmp(allgates,gatename))
                msgbox('A gate with this name already exists.','EasyFlow','error','modal');
                uiwait;
                enable_gui(efdbIn);
                return;
            end
        end
        
        
        %select gates and logical operation
        if isempty(allgates)
            msgbox('No gates were found.','EasyFlow','error','modal');
            uiwait;
            enable_gui(efdbIn);
            return;
        end
        [Selection,ok] = listdlg('ListString',allgates,'Name','Select Gates','PromptString','Select gates','OKString','OK');
        if ok~=1
            enable_gui(efdbIn);
            return
        end
        switch length(Selection)
            case 0
                msgbox('No gates were selected.','EasyFlow','error','modal');
                uiwait;
                enable_gui(efdbIn);
                return;
            case 1
                logical_op={'Not'};
            case 2
                logical_op={'And','Or','Xor'};
            otherwise
                logical_op={'And','Or'};
        end
        [OpSelection,ok] = listdlg('ListString',logical_op,'Name','Select Operation','PromptString','Select logical operation','OKString','OK','SelectionMode','single');
        if ok~=1
            enable_gui(efdbIn);
            return
        end
        %create the gate structure
        new_gate{1}=logical_op{OpSelection};
        new_gate{2}=allgates(Selection);
        new_gate{3}='logical';
        %add to the GatesDB
        efdbIn.GatesDBnew.(gatename)=new_gate;

        % apply the gate to all tubes
        for cur_tube_indx=1:length(efdbIn.TubeDB)
            gatemask=calculate_gate_mask(efdbIn.TubeDB(cur_tube_indx),new_gate);
            efdbIn.TubeDB(cur_tube_indx).gatemask.(gatename)=gatemask;
        end
        % Update the GUI component
        UpdateGateList(efdbIn);
        
        efdbIn=enable_gui(efdbIn);
        efdb_save(efdbIn);
    end
    function MenuGatesAddArtifactsGate(hObject,~)
        efdbIn=efdb_load(hObject);
        efdbIn=disable_gui(efdbIn);

        %
        %check parameters and determine the gate name
        %
        gatename=char(inputdlg('Gate name:','Add Artifacts Gate'));
        % check that the name is non empty and valid and doesn't exist already.
        if isempty(gatename)
            return;
        end
        if ~isvarname(gatename)
            msgbox('The gate name is invalid. use only a letter followed by letters and numbers.','EasyFlow','error','modal');
            uiwait;
            return;
        end
        if isfield(efdbIn,'GatesDBnew')
            allgates=fieldnames(efdbIn.GatesDBnew);
            if any(strcmp(allgates,gatename))
                msgbox('A gate with this name already exists.','EasyFlow','error','modal');
                uiwait;
                enable_gui(efdbIn);
                return;
            end
        end
        
        %take the y axis unless it is a 1d histogram
        if strcmp(efdbIn.Display.graph_type,'Histogram')
            colorname=efdbIn.GraphDB(efdbIn.curGraph(1)).Color;
            disp_scale=efdbIn.Display.graph_Xaxis;
            disp_par=efdbIn.Display.graph_Xaxis_param(3);
        else
            colorname=efdbIn.GraphDB(efdbIn.curGraph(1)).Color2;
            disp_scale=efdbIn.Display.graph_Yaxis(2:end);
            disp_par=efdbIn.Display.graph_Yaxis_param(3);
        end
        %create the gate structure
        new_gate{1}={disp_scale,disp_par};
        new_gate{2}=colorname;
        new_gate{3}='artifact';
        %add to the GatesDB
        efdbIn.GatesDBnew.(gatename)=new_gate;

        % apply the gate to all tubes
        for cur_tube_indx=1:length(efdbIn.TubeDB)
            gatemask=calculate_gate_mask(efdbIn.TubeDB(cur_tube_indx),new_gate);
            efdbIn.TubeDB(cur_tube_indx).gatemask.(gatename)=gatemask;
        end
        % Update the GUI component
        UpdateGateList(efdbIn);
        
        efdbIn=enable_gui(efdbIn);
        efdb_save(efdbIn);
    end
    function MenuGatesEditor(hObject,~)
        efdbIn=efdb_load(hObject);
        efdbIn=disable_gui(efdbIn);
        gatename = get(gco,'Tag');
        old_gate = efdbIn.GatesDBnew.(gatename);

        switch efdbIn.Display.graph_type
            case 'Histogram'
                %make sure the color is proper
                if ~strcmp(old_gate{2},efdbIn.GraphDB(efdbIn.curGraph(1)).Color) ...
                        || ~strcmp(old_gate{3},'1D')
                    msgbox(['wrong axis need ', old_gate{2}, ' and ', old_gate{3}],'EasyFlow','error','modal');
                    uiwait;
                    enable_gui(efdbIn);
                    return;
                end
                efdbIn = remove_gates(gatename, efdbIn);
                efdbIn = DrawGraphs(efdbIn);
                %get the old gate values
                lingate=old_gate{1};
                %scale the numbers to the axis scaling
                scalegate=[lin2scale(lingate(1:2), efdbIn.Display.graph_Xaxis, efdbIn.Display.graph_Xaxis_param),... 
                    lin2scale(lingate(3), efdbIn.Display.graph_Yaxis, efdbIn.Display.graph_Yaxis_param)];
                %define the new gate
                scalegate = gate1d(scalegate);
                %transform back to linear values
                lingate=[scale2lin(scalegate(1:2), efdbIn.Display.graph_Xaxis, efdbIn.Display.graph_Xaxis_param),... 
                    scale2lin(scalegate(3), efdbIn.Display.graph_Yaxis, efdbIn.Display.graph_Yaxis_param)];
                %create the gate structure
                new_gate{1}=lingate;
                new_gate{2}=efdbIn.GraphDB(efdbIn.curGraph(1)).Color;
                new_gate{3}='1D';
                %add to the GatesDB 
                efdbIn.GatesDBnew.(gatename)=new_gate;
            otherwise
                %make sure the color is proper
                if ~strcmp(old_gate{2},efdbIn.GraphDB(efdbIn.curGraph(1)).Color) ...
                        || ~strcmp(old_gate{3},efdbIn.GraphDB(efdbIn.curGraph(1)).Color2)
                    msgbox(['wrong axis need ', old_gate{2}, ' and ', old_gate{3}],'EasyFlow','error','modal');
                    uiwait;
                    enable_gui(efdbIn);
                    return;
                end
                efdbIn = remove_gates(gatename, efdbIn);
                efdbIn = DrawGraphs(efdbIn);
                %get the old gate values
                lingate=old_gate{1};
                %scale the numbers to the axis scaling
                scalegate=[lin2scale(lingate(1,:), efdbIn.Display.graph_Xaxis, efdbIn.Display.graph_Xaxis_param);... 
                    lin2scale(lingate(2,:), efdbIn.Display.graph_Yaxis, efdbIn.Display.graph_Yaxis_param)];

                %define the gate
                scalegate=gate2d(scalegate);
                %transform back to linear values
                lingate=[scale2lin(scalegate(1,:), efdbIn.Display.graph_Xaxis, efdbIn.Display.graph_Xaxis_param);... 
                    scale2lin(scalegate(2,:), efdbIn.Display.graph_Yaxis, efdbIn.Display.graph_Yaxis_param)];
                %create the gate structure
                new_gate{1}=lingate;
                new_gate{2}=efdbIn.GraphDB(efdbIn.curGraph(1)).Color;
                new_gate{3}=efdbIn.GraphDB(efdbIn.curGraph(1)).Color2;
                %add to the GatesDB 
                efdbIn.GatesDBnew.(gatename)=new_gate;
        end
        % Update the GUI component
        UpdateGateList(efdbIn);
        efdbIn=enable_gui(efdbIn);
        efdb_save(efdbIn);
    end
    function MenuGatesRemove(hObject,~)
        efdbIn=efdb_load(hObject);
        gatename = get(gco,'Tag');
        efdbIn = remove_gates(gatename, efdbIn);
        efdbIn = DrawGraphs(efdbIn);
        efdb_save(efdbIn);
    end
    function efdb = remove_gates(gatename, efdb)
        efdb.GatesDBnew=rmfield(efdb.GatesDBnew,gatename);
        %remove the gate from all graphs
        for i=1:length(efdb.GraphDB)
            efdb.GraphDB(i).Gates(strcmp(efdb.GraphDB(i).Gates,gatename))=[];
            efdb.GraphDB(i).GatesOff(strcmp(efdb.GraphDB(i).GatesOff,gatename))=[];
        end
        %remove it from tubes
        for i=1:length(efdb.TubeDB)
            if isfield(efdb.TubeDB(i),'gatemask') && isfield(efdb.TubeDB(i).gatemask,gatename)
                efdb.TubeDB(i).gatemask = rmfield(efdb.TubeDB(i).gatemask,gatename);
            end
        end
        % recalculate gates state
        curGraph = efdb.curGraph;
        efdb.curGraph = 1:length(efdb.GraphDB);
        efdb=CalculateGatedData(efdb);
        efdb.curGraph = curGraph;
        UpdateGateList(efdb);
    end
    function l = scale2lin(s,axis_scale, axis_param)
        l=s;
        switch axis_scale
            case {'log', 'ylog'}
                l=10.^s;
            case {'logicle', 'ylogicle'}
                l=2*sinh(log(10)*s)/axis_param(3);
        end
        
    end
    function s = lin2scale(l,axis_scale, axis_param)
        s=l;
        switch axis_scale
            case {'log', 'ylog'}
                s=log10(l);
            case {'logicle', 'ylogicle'}
                s=asinh(0.5*l*axis_param(3))/log(10);
        end
        
    end
%%  Functions for specific events
    function mArgsIn=DataChange(mArgsIn)
        %this function should be executed every time the data is changed,
        %i.e. the graph looks different. it acts only on the mArgsIn.curGraph
        %and redo the analysis
        
        %remove the fit
        [mArgsIn.GraphDB(mArgsIn.curGraph).fit]=deal([]);
        
    end
    function mArgsIn=AddGraph(mArgsIn,template,datatube)
        if ~exist('datatube','var')
            datatube=char(mArgsIn.TubeNames(1));
        end
        if ~exist('template','var')
            template=[];
        end
        %add item to the GraphList and GraphDB and select the new graph
        List=get(mArgsIn.Handles.GraphList,'String');
        curGraph=length(List)+1;
        List{curGraph}=['Graph_' num2str(curGraph)];
        %create the new item
        if isempty(template)
            mArgsIn.GraphDB(curGraph).Name=['Graph_' num2str(curGraph)];
            mArgsIn.GraphDB(curGraph).Data=datatube;
            mArgsIn.GraphDB(curGraph).Ctrl='None';
            mArgsIn.GraphDB(curGraph).Color='None';
            mArgsIn.GraphDB(curGraph).Color2='None';
            mArgsIn.GraphDB(curGraph).RemoveCtrl=0;
            mArgsIn.GraphDB(curGraph).DataDeconv=[];
            mArgsIn.GraphDB(curGraph).Gates={};
            mArgsIn.GraphDB(curGraph).GatesOff={};
            mArgsIn.GraphDB(curGraph).Stat=struct;
            mArgsIn.GraphDB(curGraph).plotdata=[];
            mArgsIn.GraphDB(curGraph).gatedindex=[];
            mArgsIn.GraphDB(curGraph).gatedindexctrl=[];
            mArgsIn.GraphDB(curGraph).Display=mArgsIn.Display;
            mArgsIn.GraphDB(curGraph).fit=[];
        else
            prevGraph=template;
            mArgsIn.GraphDB(curGraph).Name=['Graph_' num2str(curGraph)];
            mArgsIn.GraphDB(curGraph).Data=mArgsIn.GraphDB(prevGraph).Data;
            mArgsIn.GraphDB(curGraph).Ctrl=mArgsIn.GraphDB(prevGraph).Ctrl;
            mArgsIn.GraphDB(curGraph).Color=mArgsIn.GraphDB(prevGraph).Color;
            mArgsIn.GraphDB(curGraph).Color2=mArgsIn.GraphDB(prevGraph).Color2;
            mArgsIn.GraphDB(curGraph).RemoveCtrl=mArgsIn.GraphDB(prevGraph).RemoveCtrl;
            mArgsIn.GraphDB(curGraph).DataDeconv=mArgsIn.GraphDB(prevGraph).DataDeconv;
            mArgsIn.GraphDB(curGraph).Gates=mArgsIn.GraphDB(prevGraph).Gates;
            mArgsIn.GraphDB(curGraph).GatesOff=mArgsIn.GraphDB(prevGraph).GatesOff;
            mArgsIn.GraphDB(curGraph).Stat=mArgsIn.GraphDB(prevGraph).Stat;
            mArgsIn.GraphDB(curGraph).plotdata=mArgsIn.GraphDB(prevGraph).plotdata;
            mArgsIn.GraphDB(curGraph).gatedindex=mArgsIn.GraphDB(prevGraph).gatedindex;
            mArgsIn.GraphDB(curGraph).gatedindexctrl=mArgsIn.GraphDB(prevGraph).gatedindexctrl;
            mArgsIn.GraphDB(curGraph).Display=mArgsIn.GraphDB(prevGraph).Display;
            mArgsIn.GraphDB(curGraph).fit=mArgsIn.GraphDB(prevGraph).fit;
        end
        set(mArgsIn.Handles.GraphList,'String',List);
        set(mArgsIn.Handles.GraphList,'Value',curGraph);
        mArgsIn.DBInfo.isChanged=1;
    end

%%  Utility functions for MYGUI

    function UpdateGateList(mArgsIn)
        % Populate the gate list component in the gui.
        if ~isfield(mArgsIn,'curGraph') || isempty(mArgsIn.curGraph) || ~isfield(mArgsIn.GraphDB(mArgsIn.curGraph(1)),'Gates')
            return
        end
        
        %get the indices of the selected and unselected gates.
        selected=[]; unselected=[];
        allGates=fieldnames(mArgsIn.GatesDBnew);
        for cgraph=mArgsIn.curGraph
            curtube=matlab.lang.makeValidName(mArgsIn.GraphDB(cgraph).Data);
            if isfield(mArgsIn,'GatesDB') && isfield(mArgsIn.GatesDB,curtube)
                [allGates,~,inew]=unique([allGates; cell(fieldnames(mArgsIn.GatesDB.(curtube)))]);
                selected=inew(selected)'; unselected=inew(unselected)';
            end
            for gate=mArgsIn.GraphDB(cgraph).Gates
                if isempty(gate) || ~any(strcmp(gate,allGates))
                    mArgsIn.GraphDB(cgraph).Gates(strcmp(mArgsIn.GraphDB(cgraph).Gates,gate))=[];
                    continue
                end
                selected(end+1)=find(strcmp(gate,allGates));
            end
            for gate=mArgsIn.GraphDB(cgraph).GatesOff
                if isempty(gate) || ~any(strcmp(gate,allGates))
                    mArgsIn.GraphDB(cgraph).GatesOff(strcmp(mArgsIn.GraphDB(cgraph).GatesOff,gate))=[];
                    continue
                end
                unselected=[find(strcmp(gate,allGates)) unselected];
            end
        end
        %find those that appear as selected in all graphs
        tmp=find(hist(selected,1:length(allGates))==length(mArgsIn.curGraph));
        %the others are both selected and unselected
        both=setdiff(unique(selected),tmp);
        %take those in tmp but in the order they first apear in tmp (the
        %order for the last tube)
        [~,iselected]=intersect(selected,tmp);
        selected=selected(sort(iselected));
        %remove those that are both from the unselected
        tmp=setdiff(unique(unselected),both);
        [~,iunselected]=intersect(unselected,tmp);
        unselected=unselected(sort(iunselected));
        % make row vectors
        selected=selected(:)';
        unselected=unselected(:)';
        both=both(:)';
%        if isempty(unselected), unselected=[]; end
        delete(get(mArgsIn.Handles.GateList,'Children'))
        guipos=get(mArgsIn.Handles.GateList,'Position');
%         guisizey=guipos(4);
        pos=1;
        %first put the selected gates by the order of their selection
        for item=selected
            h=uicontrol(mArgsIn.Handles.GateList,...
                'Style','checkbox',...
                'String',[allGates{item}],...
                'Tag',allGates{item},...
                'Position',[5 guipos(4)-15-20*pos guipos(3)-5 20],...
                'Value',1,...
                'Callback',@GateListCallback,...
                'UIContextMenu', mArgsIn.Handles.GatesCM);
            if length(mArgsIn.curGraph)==1
                set(h,'String',[allGates{item} ' (' num2str(round(100*mArgsIn.GraphDB(mArgsIn.curGraph(1)).Stat.gatepercent(pos))) '%)'])
            end
            pos=pos+1;
        end
        %then put the non determined
        for item=both
            uicontrol(mArgsIn.Handles.GateList,...
                'Style','checkbox',...
                'String',allGates{item},...
                'Tag',allGates{item},...
                'Position',[5 guipos(4)-15-20*pos guipos(3)-5 20],...
                'Value',1,...
                'ForegroundColor',[1 0 0],...
                'FontAngle','italic',...
                'Callback',@GateListCallback,...
                'UIContextMenu', mArgsIn.Handles.GatesCM);
            pos=pos+1;
        end
        %then put the unselected gates by the order of their unselection
        for item=unselected
            uicontrol(mArgsIn.Handles.GateList,...
                'Style','checkbox',...
                'String',allGates{item},...
                'Tag',allGates{item},...
                'Position',[5 guipos(4)-15-20*pos guipos(3)-5 20],...
                'Value',0,...
                'Callback',@GateListCallback,...
                'UIContextMenu', mArgsIn.Handles.GatesCM);
            pos=pos+1;
        end
        %then put the rest
        for item=1:length(allGates)
            if find([selected both unselected]==item)
            else
                uicontrol(mArgsIn.Handles.GateList,...
                    'Style','checkbox',...
                    'String',allGates{item},...
                    'Tag',allGates{item},...
                    'Position',[5 guipos(4)-15-20*pos guipos(3)-5 20],...
                    'Value',0,...
                    'Callback',@GateListCallback,...
                    'UIContextMenu', mArgsIn.Handles.GatesCM);
                pos=pos+1;
            end
        end
    end

    
    function gatemask=calculate_gate_mask(Sample, gate)
        %probably need to make sure it is not a logical or an artifact gate
        %before starting
        switch gate{3}
            case 'logical'
                switch gate{1}
                    case 'Not'
                        cgate=gate{2};
                        gatemask= not( Sample.gatemask.( char( cgate) ) );
                    case 'Xor'
                        cgate1=gate{2}(1);
                        cgate2=gate{2}(2);
                        gatemask=xor(...
                            Sample.gatemask.( char( cgate1) ),...
                            Sample.gatemask.( char( cgate2) ));
                    case 'And'
                        gatemask=true( size( Sample.compdata ,1),1);
                        for cgate=gate{2}'
                            gatemask=and(gatemask,...
                                Sample.gatemask.( char( cgate) ));
                        end
                    case 'Or'
                        gatemask=false( size( Sample.compdata ,1),1);
                        for cgate=gate{2}'
                            gatemask=or(gatemask,...
                                Sample.gatemask.( char( cgate) ));
                        end
                end
            case 'artifact'
                colorind=find(strcmp(Sample.parname,gate{2}),1,'first');
                scaleddata=fcsscaleconvert(Sample.compdata(:,colorind),'lin',1, gate{1}{:});
                gatemask=fcsartifact(scaleddata);
            otherwise %regular 1 or 2 dimensional gate. TBD - redefine the 3rd element to be explicit.
                colorind1=find(strcmp(Sample.parname,gate{2}),1,'first');
                colorind2=find(strcmp(Sample.parname,gate{3}),1,'first');
                if isempty(colorind2)
                    gatemask=gate1d(gate{1}, Sample.compdata, colorind1);
                else
                    gatemask=gate2d(gate{1}, Sample.compdata, colorind1, colorind2);
                end
        end
    end
    function mArgsIn=RecalcGateLogicalMask(mArgsIn,tubename_list)
        %calculate the second element of the gate (the logical mask) from
        %the other elements. first calculate the regular gates and than the
        %logical-derived gates
        %
        %tubename_list is the tubename after matlab.lang.makeValidName
        for ctubename=tubename_list
            ctubeidx=find(strcmp(matlab.lang.makeValidName([mArgsIn.TubeDB.Tubename]),ctubename),1,'first');
            if isfield(mArgsIn,'GatesDB') && isfield(mArgsIn.GatesDB,(char(ctubename)))
                for gatename=fieldnames(mArgsIn.GatesDB.((char(ctubename))))'
                    gate=mArgsIn.GatesDB.((char(ctubename))).(char(gatename));
                    if isempty(gate{4})
                        colorind=find(strcmp(mArgsIn.TubeDB(ctubeidx).parname,gate{3}),1,'first');
                        mArgsIn.GatesDB.((char(ctubename))).(char(gatename)){2}=...
                            mArgsIn.TubeDB(ctubeidx).compdata(:,colorind)>gate{1}(1) ...
                            & mArgsIn.TubeDB(ctubeidx).compdata(:,colorind)<gate{1}(2);
                    elseif strcmp(gate{4},'artifact')
                        colorind=find(strcmp(mArgsIn.TubeDB(ctubeidx).parname,gate{3}),1,'first');
                        %use the current display settings to scale the data. maybe to ask?
                        scaleddata=fcsscaleconvert(mArgsIn.TubeDB(ctubeidx).compdata(:,colorind),'lin',1, gate{1}{1}, gate{1}{2});
                        mArgsIn.GatesDB.(char(ctubename)).(char(gatename)){2}=fcsartifact(scaleddata);

                    elseif ischar(gate{4}) && strcmp(gate{4},'logical')
                        %this is a logical-derived gate. keep it for later.
                    else
                        colorind(1)=find(strcmp(mArgsIn.TubeDB(ctubeidx).parname,gate{3}),1,'first');
                        colorind(2)=find(strcmp(mArgsIn.TubeDB(ctubeidx).parname,gate{4}),1,'first');
                        mArgsIn.GatesDB.((char(ctubename))).(char(gatename)){2}=...
                            gate2d(gate{1},mArgsIn.TubeDB(ctubeidx).compdata,colorind(1),colorind(2));
                    end
                end
                for gatename=fieldnames(mArgsIn.GatesDB.((char(ctubename))))'
                    gate=mArgsIn.GatesDB.(matlab.lang.makeValidName(char(ctubename))).(char(gatename));
                    if ischar(gate{4}) && strcmp(gate{4},'logical')
                        %this is a logical-derived gate. do it now.
                        switch gate{1}
                            case 'Not'
                                cgate=gate{3};
                                mArgsIn.GatesDB.(matlab.lang.makeValidName(char(ctubename))).(char(gatename)){2}=not(mArgsIn.GatesDB.(matlab.lang.makeValidName(char(ctubename))).(char(cgate)){2});
                            case 'Xor'
                                cgate1=gate{3}(1);
                                cgate2=gate{3}(2);
                                mArgsIn.GatesDB.(matlab.lang.makeValidName(char(ctubename))).(char(gatename)){2}=xor(mArgsIn.GatesDB.(matlab.lang.makeValidName(char(ctubename))).(char(cgate1)){2},mArgsIn.GatesDB.(matlab.lang.makeValidName(char(ctubename))).(char(cgate2)){2});
                            case 'And'
                                gate_ind=true(size(mArgsIn.GatesDB.(matlab.lang.makeValidName(char(ctubename))).(char(gate{3}(1))){2}));
                                for cgate=gate{3}
                                    gate_ind=and(gate_ind,mArgsIn.GatesDB.(matlab.lang.makeValidName(char(ctubename))).(char(cgate)){2});
                                end
                                mArgsIn.GatesDB.(matlab.lang.makeValidName(char(ctubename))).(char(gatename)){2}=gate_ind;
                            case 'Or'
                                gate_ind=false(size(mArgsIn.GatesDB.(matlab.lang.makeValidName(char(ctubename))).(char(gate{3}(1))){2}));
                                for cgate=gate{3}
                                    gate_ind=or(gate_ind,mArgsIn.GatesDB.(matlab.lang.makeValidName(char(ctubename))).(char(cgate)){2});
                                end
                                mArgsIn.GatesDB.(matlab.lang.makeValidName(char(ctubename))).(char(gatename)){2}=gate_ind;
                        end
                    end
                end
            end
        end
    end
    function efdbIn=CalculateGatedData(efdbIn)
        % Integrate all gates that should be applied to each plot
        % generates mArgsIn.GraphDB(graph).gatedindex and calculate some
        % stats.
        
        for graph=efdbIn.curGraph
            %check that the tube exists
            try
                tubename=matlab.lang.makeValidName(efdbIn.GraphDB(graph).Data);
            catch err
                keyboard
                rethrow(err)
            end
            tubeidx=find(strcmp([efdbIn.TubeDB.Tubename],efdbIn.GraphDB(graph).Data),1,'first');
            if tubeidx
                percent=zeros(length(efdbIn.GraphDB(graph).Gates),1);
                efdbIn.GraphDB(graph).gatedindex=true(size(efdbIn.TubeDB(tubeidx).compdata,1),1);
                for cur_gate_idx=1:length(efdbIn.GraphDB(graph).Gates)
                    gatename=efdbIn.GraphDB(graph).Gates(cur_gate_idx);
                    %find the gate
                    if isfield(efdbIn,'GatesDBnew') && isfield(efdbIn.GatesDBnew,gatename)
                        gate=efdbIn.GatesDBnew.(char(gatename));
                    else
                        %this gate is not defined mark it with a -1 percent
                        percent(cur_gate_idx)=-1;
                        continue
                    end
                    if ~isfield(efdbIn.TubeDB,'gatemask') || ~isfield(efdbIn.TubeDB(tubeidx).gatemask,gatename)
                        %need to calculate the gatemask
                        efdbIn.TubeDB(tubeidx).gatemask.(char(gatename))=calculate_gate_mask(efdbIn.TubeDB(tubeidx),gate);
                    end
                    num_events_parent=sum(efdbIn.GraphDB(graph).gatedindex);
                    cur_gatemask=efdbIn.TubeDB(tubeidx).gatemask.(char(gatename));
                    efdbIn.GraphDB(graph).gatedindex=efdbIn.GraphDB(graph).gatedindex & cur_gatemask;
                    percent(cur_gate_idx)=sum(efdbIn.GraphDB(graph).gatedindex)/num_events_parent;
                end
                efdbIn.GraphDB(graph).Stat.gatepercent=percent;
            else %tube does not exist
                efdbIn.GraphDB(graph).Stat.gatepercent=0;
                efdbIn.GraphDB(graph).gatedindex=[];
            end
        end
    end
    function Tube=LoadTube(fcsfile)
        Tube.fcsfile=[];
        %who calls this function? FileLoadCallback, Tube menu->Load...
        Tube.Tubename=fcsfile.var_value(strcmp(fcsfile.var_name,'TUBE NAME'));
        if isempty(Tube.Tubename) && any(strcmp(fcsfile.var_name,'$CYT')) && ~isempty(strfind(fcsfile.var_value{strcmp(fcsfile.var_name,'$CYT')},'MACSQuant'))
            Tube.Tubename=fcsfile.var_value(strcmp(fcsfile.var_name,'$CELLS'));
        end
        if isempty(Tube.Tubename)
            Tube.Tubename={fcsfile.filename};
            fcsfile=fcssetparam(fcsfile,'TUBE NAME',fcsfile.filename);
        end
        Tube.tubepath=fcsfile.dirname;
        Tube.tubefile=fcsfile.filename;
        for i=1:str2double(fcsfile.var_value{strcmp(fcsfile.var_name,'$PAR')})
            Tube.parname(i)=fcsfile.var_value(strcmp(fcsfile.var_name,['$P' num2str(i) 'N']));
            symbol=fcsfile.var_value(strcmp(fcsfile.var_name,['$P' num2str(i) 'S']));
            if ~isempty(symbol)
                Tube.parsymbol(i)=fcsfile.var_value(strcmp(fcsfile.var_name,['$P' num2str(i) 'S']));
            else
                Tube.parsymbol(i)={''};
            end
        end
        
        if any(strcmp(fcsfile.var_name,'SPILL'))
            fcsfile.var_name{strcmp(fcsfile.var_name,'SPILL')} ='SPILL';
        end
        if any(strcmp(fcsfile.var_name,'$SPILLOVER'))%used to be SPILL in fcs3.0 should be this.
            spill=textscan(fcsfile.var_value{strcmp(fcsfile.var_name,'$SPILLOVER')},'%s','delimiter', ',');
            spill=spill{1};
            mtxsize=str2double(spill{1});
            % The compenstaion parameters names
            Tube.CompensationPrm=spill(2:mtxsize+1);
            % The compensation matrix
            Tube.CompensationMtx=reshape(arrayfun(@str2double,spill(mtxsize+2:end)),mtxsize,mtxsize);
        else
            Tube.CompensationPrm=fcsfile.var_value(cellfun(@isempty,regexp(fcsfile.var_value,'FSC')) ...
                & cellfun(@isempty,regexp(fcsfile.var_value,'SSC')) ...
                & ~cellfun(@isempty,regexp(fcsfile.var_value,'-A$')) ...
                & ~cellfun(@isempty,(regexp(fcsfile.var_name,'\$P[0-9]+N'))));
            mtxsize=length(Tube.CompensationPrm);
            Tube.CompensationMtx=eye(mtxsize);
            spill=[sprintf('%d',mtxsize)...
                sprintf(',%s',Tube.CompensationPrm{:})...
                sprintf(',%d',Tube.CompensationMtx)];
            fcsfile=fcssetparam(fcsfile,'SPILL',spill);
        end
        Tube.fcsfile=fcsfile;
        
        % Compensate the data.
        % check if we want to compensate the data
        Tube.CompensationIndex=[];
        if ~isempty(Tube.CompensationMtx)
            for i=Tube.CompensationPrm'
                Tube.CompensationIndex(end+1)=find(strcmp(char(i),Tube.parname));
            end
            Tube.compdata=fcsfile.fcsdata;
            Tube.compdata(:,Tube.CompensationIndex)=Tube.compdata(:,Tube.CompensationIndex)/(Tube.CompensationMtx');
        else
            Tube.compdata=fcsfile.fcsdata;
        end
    end

    function efdb=abs2relpath(efdb)
        %change all tube paths to relative.
        %mostly effects efdb.TubeDB().tubepath
        %
        % find rel path for tubefiles from the session-file.
        % the tubefiles folder would be [session-folder, relativepath]
        
        function relpath = a2r(root, target)
            if root(1)~=target(1)
                %they are in different drives
                relpath=target;
                return
            end
            [~,~,~,rootlist] = regexp(root,['\' filesep' '[^\' filesep ']+']);
            [~,~,~,targetlist] = regexp(target,['\' filesep' '[^\' filesep ']+']);
            
            diff_level = 1;
            for level=1:length(rootlist)
                if strcmp(rootlist{level},targetlist{level})
                    diff_level = diff_level+1;
                else
                    break
                end
            end
            relpath='.';
            for j=diff_level:length(rootlist)
                relpath = [relpath, filesep, '..'];
            end
            for j=diff_level:length(targetlist)
                relpath = [relpath, targetlist{j}];
            end
        end
        
        root = fileparts(efdb.DBInfo.Name);        
        for i=1:length(efdb.TubeDB)
            efdb.TubeDB(i).tubepath = ...
                a2r(root, efdb.TubeDB(i).tubepath);
        end
    end
    function efdb=rel2abspath(efdb)
        %change all tube paths to absolute.
        %mostly effect efdb.TubeDB().tubepath

        root = fileparts(efdb.DBInfo.Name);
        for i=1:length(efdb.TubeDB)
            efdb.TubeDB(i).tubepath = ...
                char(java.io.File([root filesep efdb.TubeDB(i).tubepath]).getCanonicalPath);
        end
    end

    function efdb=disable_gui(efdb)
        efdb.DBInfo.enabled_gui=findobj(efdb.Handles.fh,'Enable','on');
        set(efdb.DBInfo.enabled_gui,'Enable','off');
    end
    function efdb=enable_gui(efdb)
        ind_handle=ishandle(efdb.DBInfo.enabled_gui);
        set(efdb.DBInfo.enabled_gui(ind_handle),'Enable','on');
    end
    function efdb=efdb_load(hObject)
        fhIn=ancestor(hObject,'figure');
        efdb=guidata(fhIn);
    end
    function efdb_save(efdb)
        % save the variable efdb into the guidata of the figure stored in
        % efdb
        
        %find the figure object
        fhIn=efdb.Handles.fh;

        % If the save-able parts of the efdb were changed, mark it.
        if ~isempty(guidata(fhIn))
            if ~isequal(rmfield(efdb,'Handles'),rmfield(guidata(fhIn),'Handles'))
                efdb.DBInfo.isChanged=1;
            end
        end
        
        % Save the guidata
        guidata(fhIn,efdb)
    end
end

%%
function GraphDB=fcsbatch(inGraphDB,str1,str2)
%str1 is the string to be replaced
%str 2 is a char array
%

len=length(inGraphDB);
%create GraphDB using temporary first entry
GraphDB=inGraphDB(1);

for str=str2
    for i=1:len
        GraphDB(end+1)=inGraphDB(i);
        GraphDB(end).Data=regexprep(inGraphDB(i).Data,str1,char(str));
    end
end

GraphDB(1)=[];
end

function y=fcsscaleconvert(x,varargin)
%convert numbers between display scales.
%
%fcshist(vec,scale1,scale1prm,scale2,scale2prm)
%   convert the numbers in vec from scale1 to scale to with the given
%   scale parameters.
%
%scale can be 'log','lin','logicle',
%scaleprm is the parameter of the scale. relevant only for the logicle.

scale1fun=@arclinearscale;
param1=1;
scale2fun=@linearscale;
param2=1;

strpos=find(cellfun(@ischar,varargin));
if length(strpos)~=2
    error('Wrong numbers of arguments');
end

switch varargin{strpos(1)}
    case 'log'
        scale1fun=@arclogscale;
    case 'lin'
        scale1fun=@arclinearscale;
    case 'logicle'
        scale1fun=@arclogicle;
        if size(varargin,2)>strpos(1) && ~ischar(varargin{strpos(1)+1})
            param1=varargin{strpos(1)+1};
        else
            param1=1;
        end
end
switch varargin{strpos(2)}
    case 'log'
        scale2fun=@logscale;
    case 'lin'
        scale2fun=@linearscale;
    case 'logicle'
        scale2fun=@logicle;
        if size(varargin,2)>strpos(2) && ~ischar(varargin{strpos(2)+1})
            param2=varargin{strpos(2)+1};
        else
            param2=1;
        end
end

y=scale2fun(scale1fun(x,param1),param2);



%these function are the scaling functions.
%INPUT:
%  x a vector or scalar to be transformed (in a linear scale)
%  prm parameters for the transformation
%  y the scaled vector
    function y=linearscale(x,prm)
        y=x;
    end
    function y=logscale(x,prm)
        %  returns -Inf for values less than 0
        %
        y=log10(x);
        y(x<0)=-Inf;
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
        %to get from this value back to the original linear data do:
        % x= 2*sinh(log(10)*y)/prm
        y=asinh(prm*x/2)/log(10);
    end

%these function are the inverse scaling functions.
%INPUT:
%  y a vector or scalar to be transformed (scaled)
%  prm parameters for the transformation
%  x the vector in a linear scale
    function x=arclinearscale(y,prm)
        x=y;
    end
    function x=arclogscale(y,prm)
        %  if only a number, returns zero for values less than 1
        %  for an array, returns only positive elements
        x=10.^y;
    end
    function x=arclogicle(y,prm)
        if ~isscalar(prm)
            prm=1;
        end
        %divide by log10(exp(1)) to get asymptotically to log10
        %divide the argument by 2 to get to log10(x)
        %
        %a is a coefficient that stretches the zero
        %
        %to get from this value back to the original data do:
        x = 2*sinh(log(10)*y)/prm;
        % y=asinh(prm*x/2)/log(10);
    end
end
function normalEvents=fcsartifact(x)
% look in the vector x of data points for areas that behave statistically
% different (mean and std)
% returns a vector of logicals 1 - good sample, 0 - bad sample

% calculate running average(m) and running std(d)
windowsize=500;
m=filter(ones(1,windowsize)/windowsize,1,x);
m2=filter(ones(1,windowsize)/windowsize,1,x.^2);
s=sqrt(m2-m.^2);
% find for each point how many std from the mean
cutoff=0.7;
score=[];
score(:,1)=1/cutoff*(m-median(m))./std(m-median(m));
score(:,2)=1/cutoff*(s-median(s))./std(s-median(s));
sctot=prod(abs(score'));
normalEvents=smooth(sctot,windowsize)<1;
end





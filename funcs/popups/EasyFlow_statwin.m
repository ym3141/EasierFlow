function EasyFlow_statwin(varargin)
% EasyFlow_FIGPROP Figure properties for the EasyFlow
%

%  Initialization tasks

%  Initialize input/output parameters
hMainFig=varargin{1};
mArgsIn=guidata(hMainFig);
%if there is already an instance running just make it visible and raise it.
if isfield(mArgsIn.Handles,'statwin')
    set(mArgsIn.Handles.statwin,'Visible','on');
    figure(mArgsIn.Handles.statwin);
    CalcStat(mArgsIn.Handles.statwin,mArgsIn);
    return;
end


% Initialize data structures

%  Construct the figure
scrsz=get(0,'ScreenSize');
guisize=600;
fh=figure('Position',[(scrsz(3)-guisize)/2,(scrsz(4)-guisize/3)/2,guisize,guisize/3],...
    'MenuBar','none',...
    'Name','FACS GUI Statistics',...
    'NumberTitle','off',...
    'Visible','off',...
    'ResizeFcn',{@fhResizeFcn},...
    'CloseRequestFcn',{@fhClose,hMainFig},...
    'KeyPressFcn',{@fhKeyPressFcn});
mArgsIn.Handles.statwin=fh;
guidata(hMainFig,mArgsIn);
%  Construct the components
Args.Handles.table=uitable(fh,...
    'ColumnEditable',false);


%Context menu
StatCM = uicontextmenu('Parent',fh);
uimenu(StatCM,...
    'Label','Save To Workspace',...
    'Callback',{@StatSaveWS,fh});
uimenu(StatCM,...
    'Label','Save To Excel',...
    'Callback',{@StatSaveXL,fh});
uimenu(StatCM,...
    'Label','Copy',...
    'Callback',{@StatCopy,fh});
%set(Args.Handles.StatList,'UIContextMenu',StatCM);
set(Args.Handles.table,'UIContextMenu',StatCM);

%  Initialization tasks
Args.fCalcStat=@(mArgsIn) CalcStat(fh,mArgsIn);
guidata(fh,Args);
CalcStat(fh,mArgsIn);
set(fh,'Position',[scrsz(3) scrsz(4) 1 1]);
set(fh,'vis','on');
table_ext=get(Args.Handles.table,'Extent');
set(fh,'vis','off');
set(Args.Handles.table,'Position',table_ext);
fhpos=[0 0 15 15]+table_ext;
fhpos(3)=min(scrsz(3)*0.9,max(100,fhpos(3)));
fhpos(4)=min(scrsz(4)*0.9,max(100,fhpos(4)));
set(fh,'Position',fhpos);
movegui(fh,'center')

%  Render GUI visible
set(fh,'Visible','on');


%  Callbacks.
    function fhClose(hObject,eventdata,hMainFig)
        % % % %         %when it is closed, only make it invisible.
        mArgsIn=guidata(hMainFig);
        mArgsIn.Handles=rmfield(mArgsIn.Handles,'statwin');
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
        % % % %         set(hObject,'Visible','off');
    end
    function fhResizeFcn(hObject,eventdata)
        Args=guidata(hObject);
        scrsz=get(0,'ScreenSize');
        guipos=get(hObject,'Position');
        guisizex=guipos(3);
        guisizey=guipos(4);
        set(Args.Handles.table,'Position',[0 0 guisizex guisizey]);
    end
    function fhKeyPressFcn(hObject,eventdata)
        if strcmp(eventdata.Modifier,'control')
            if eventdata.Key=='c'
                StatCopy(hObject,eventdata,fh);
            end
        end
    end
    function StatSaveWS(hObject,eventdata,fh)
        Args=guidata(fh);
        stattext=[ {''} get(Args.Handles.table,'ColumnName')';...
            get(Args.Handles.table,'RowName') get(Args.Handles.table,'Data')];
        export2wsdlg({'Save Statistics as:'},{'Stat'},{stattext});
    end
    function StatSaveXL(hObject,eventdata,fh)
        Args=guidata(fh);
        [FileName,PathName] = uiputfile('*.xls');
        if FileName
            if exist([PathName,FileName],'file')
                delete([PathName,FileName])
            end
            stattext=[ {''} get(Args.Handles.table,'ColumnName')';...
                get(Args.Handles.table,'RowName') get(Args.Handles.table,'Data')];
            status=xlswrite([PathName,FileName],stattext);
        end
    end
    function StatCopy(hObject,eventdata,fh)
        Args=guidata(fh);
        stattext=[ {''} get(Args.Handles.table,'ColumnName')';...
            get(Args.Handles.table,'RowName') get(Args.Handles.table,'Data')];
        
        textarray=cellfun(@num2str,stattext,'UniformOutput',0);
        ctab=sprintf('\t');
        spacearray=char(ones(size(textarray,1),1)*ctab);
        stat_text=[char(textarray(:,1))];
        for testnum=1:size(textarray,2)-1
            stat_text=[stat_text, spacearray, char(textarray(:,testnum+1))];
        end
        cnewline=sprintf('\n');
        cnewline=char(ones(size(textarray,1),1)*cnewline);
        stat_text=[stat_text, cnewline]';
        
        %         for cline=1:size(stattext,1)
        %             statstr=sprintf('%s%s\n',statstr,stattext(cline,:));
        %         end
        clipboard('copy',stat_text(:)');
    end

%  Utility functions for MYGUI
    function CalcStat(fh,mArgsIn)
        tests={@counttest,@meantest,@mediantest,@madtest,@stdtest,@percenttotal,@percentgate,@QuadMarker,@fitdata};
        Args=guidata(fh);
        graphs=get(mArgsIn.Handles.GraphList,'String');
        graphs_index=get(mArgsIn.Handles.GraphList,'Value');
        rownames=graphs(graphs_index);
        colnames={};
        StatDB={};
        for testnum=tests(mArgsIn.Statistics.ShowInStatView)
            testfcn=testnum{1};
            newcolname=cellstr(testfcn(mArgsIn));
            newcol=[];
            for cgraph=[1:length(graphs_index)]
                res=testfcn(mArgsIn,graphs_index(cgraph));
                if length(res)>length(newcolname);
                    newcolname{length(res)}=[];
                    if ~isempty(newcol)
                        newcol{end,length(res)}=[];
                    end
                elseif length(res)<length(newcolname);
                    res{length(newcolname)}=[];
                end
                newcol=[newcol;res];
            end
            if ~iscell(newcol)
                newcol=num2cell(newcol);
            end
            StatDB=[StatDB newcol];
            colnames=[colnames newcolname];
        end
        Args.StatDB=StatDB;
        set(Args.Handles.table,'Data',StatDB,...
            'ColumnName',colnames,...
            'RowName',rownames);
        guidata(fh,Args);
    end

%statistics functions. for one argument returns the heading for the column.
%for two arguments return a 1xn array of the statistic. results are cell
%array
    function res=counttest(mArgsIn,cgraph)
        if nargin==1
            res='Count';
        else
            res=sum(mArgsIn.GraphDB(cgraph).gatedindex);
        end
    end
    function res=meantest(mArgsIn,cgraph)
        if nargin==1
            if strcmp(mArgsIn.Display.graph_type,'Histogram')
                res='Mean';
            else
                res={'Mean','Mean'};
            end
        else
            tubeidx=find(strcmp([mArgsIn.TubeDB.Tubename],mArgsIn.GraphDB(cgraph).Data));
            if tubeidx
                if strcmp(mArgsIn.Display.graph_type,'Histogram')
                    coloridx=[find(strcmp([mArgsIn.TubeDB(tubeidx).parname],mArgsIn.GraphDB(cgraph).Color))];
                else
                    coloridx=[find(strcmp([mArgsIn.TubeDB(tubeidx).parname],mArgsIn.GraphDB(cgraph).Color)),...
                        find(strcmp([mArgsIn.TubeDB(tubeidx).parname],mArgsIn.GraphDB(cgraph).Color2))];
                end
                res=mean(mArgsIn.TubeDB(tubeidx).compdata(mArgsIn.GraphDB(cgraph).gatedindex,coloridx));
            else
                res=[];
            end
            res=double(res);
        end
    end
    function res=mediantest(mArgsIn,cgraph)
        if nargin==1
            if strcmp(mArgsIn.Display.graph_type,'Histogram')
                res='Median';
            else
                res={'Median','Median'};
            end
        else
            tubeidx=find(strcmp([mArgsIn.TubeDB.Tubename],mArgsIn.GraphDB(cgraph).Data));
            if tubeidx
                if strcmp(mArgsIn.Display.graph_type,'Histogram')
                    coloridx=[find(strcmp([mArgsIn.TubeDB(tubeidx).parname],mArgsIn.GraphDB(cgraph).Color))];
                else
                    coloridx=[find(strcmp([mArgsIn.TubeDB(tubeidx).parname],mArgsIn.GraphDB(cgraph).Color)),...
                        find(strcmp([mArgsIn.TubeDB(tubeidx).parname],mArgsIn.GraphDB(cgraph).Color2))];
                end
                res=median(mArgsIn.TubeDB(tubeidx).compdata(mArgsIn.GraphDB(cgraph).gatedindex,coloridx));
            else
                res=[];
            end
            res=double(res);
        end
    end
    function res=madtest(mArgsIn,cgraph)
        if nargin==1
            if strcmp(mArgsIn.Display.graph_type,'Histogram')
                res='rSD';
            else
                res={'rSD','rSD'};
            end
        else
            tubeidx=find(strcmp([mArgsIn.TubeDB.Tubename],mArgsIn.GraphDB(cgraph).Data));
            if tubeidx
                if strcmp(mArgsIn.Display.graph_type,'Histogram')
                    coloridx=[find(strcmp([mArgsIn.TubeDB(tubeidx).parname],mArgsIn.GraphDB(cgraph).Color))];
                else
                    coloridx=[find(strcmp([mArgsIn.TubeDB(tubeidx).parname],mArgsIn.GraphDB(cgraph).Color)),...
                        find(strcmp([mArgsIn.TubeDB(tubeidx).parname],mArgsIn.GraphDB(cgraph).Color2))];
                end
                res=0.7413*iqr(mArgsIn.TubeDB(tubeidx).compdata(mArgsIn.GraphDB(cgraph).gatedindex,coloridx),1);
            else
                res=[];
            end
            res=double(res);
        end
    end
    function res=stdtest(mArgsIn,cgraph)
        if nargin==1
            if strcmp(mArgsIn.Display.graph_type,'Histogram')
                res='Std';
            else
                res={'Std','Std'};
            end
        else
            tubeidx=find(strcmp([mArgsIn.TubeDB.Tubename],mArgsIn.GraphDB(cgraph).Data));
            if tubeidx
                if strcmp(mArgsIn.Display.graph_type,'Histogram')
                    coloridx=[find(strcmp([mArgsIn.TubeDB(tubeidx).parname],mArgsIn.GraphDB(cgraph).Color))];
                else
                    coloridx=[find(strcmp([mArgsIn.TubeDB(tubeidx).parname],mArgsIn.GraphDB(cgraph).Color)),...
                        find(strcmp([mArgsIn.TubeDB(tubeidx).parname],mArgsIn.GraphDB(cgraph).Color2))];
                end
                res=std(mArgsIn.TubeDB(tubeidx).compdata(mArgsIn.GraphDB(cgraph).gatedindex,coloridx),1);
            else
                res=[];
            end
            res=double(res);
        end
    end
    function res=percenttotal(mArgsIn,cgraph)
        if nargin==1
            res='% of total';
        else
            if isfield(mArgsIn.GraphDB(cgraph).Stat,'gatepercent')
                res=100*prod(mArgsIn.GraphDB(cgraph).Stat.gatepercent);
            else
                res=100;
            end
            res=double(res);
        end
    end
    function res=percentgate(mArgsIn,cgraph)
        if nargin==1
            res='% gated';
        else
            if isfield(mArgsIn.GraphDB(cgraph).Stat,'gatepercent') && ~isempty(mArgsIn.GraphDB(cgraph).Stat.gatepercent)
                res=100*mArgsIn.GraphDB(cgraph).Stat.gatepercent(end);
            else
                res=[];
            end
            res=double(res);
        end
    end
    function res=QuadMarker(mArgsIn,cgraph)
        if nargin==1
            res={'Q1 %','Q2 %','Q3 %','Q4 %',...
                'Q1 Xmedian','Q2 Xmedian','Q3 Xmedian','Q4 Xmedian',...
                'Q1 Ymedian','Q2 Ymedian','Q3 Ymedian','Q4 Ymedian'};
        else
            if isfield(mArgsIn.GraphDB(cgraph).Stat,'quad') %&& length(mArgsIn.GraphDB(cgraph).Stat.quadp)==4
                quad=mArgsIn.GraphDB(cgraph).Stat.quad;
                posx=mArgsIn.GraphDB(cgraph).plotdata(:,1)>quad(1);
                posy=mArgsIn.GraphDB(cgraph).plotdata(:,2)>quad(2);
                quad1=sum(and(posx,posy))/length(posx)*100;
                quad2=sum(and(~posx,posy))/length(posx)*100;
                quad3=sum(and(~posx,~posy))/length(posx)*100;
                quad4=sum(and(posx,~posy))/length(posx)*100;
                res=[quad1,quad2,quad3,quad4,...
                    median(mArgsIn.GraphDB(cgraph).plotdata(and(posx,posy),1)),...
                    median(mArgsIn.GraphDB(cgraph).plotdata(and(~posx,posy),1)),...
                    median(mArgsIn.GraphDB(cgraph).plotdata(and(~posx,~posy),1)),...
                    median(mArgsIn.GraphDB(cgraph).plotdata(and(posx,~posy),1)),...
                    median(mArgsIn.GraphDB(cgraph).plotdata(and(posx,posy),2)),...
                    median(mArgsIn.GraphDB(cgraph).plotdata(and(~posx,posy),2)),...
                    median(mArgsIn.GraphDB(cgraph).plotdata(and(~posx,~posy),2)),...
                    median(mArgsIn.GraphDB(cgraph).plotdata(and(posx,~posy),2))];
                res=num2cell(double(res));
            else
                res=[];
            end
        end
    end
    function res=fitdata(mArgsIn,cgraph)
        if nargin==1
            res={'Fit Model' 'Fit Param'};
        else
            if isfield(mArgsIn.GraphDB(cgraph),'fit') && ~isempty(mArgsIn.GraphDB(cgraph).fit)
                fmodel=mArgsIn.GraphDB(cgraph).fit{1};
                res=[formula(fmodel) reshape([coeffnames(fmodel) num2cell(coeffvalues(fmodel)')]',2*numcoeffs(fmodel),1)'];
            else
                res=[];
            end
        end
    end
end

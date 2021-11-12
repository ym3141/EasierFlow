function EasyFlow_compensation(varargin)
%  Initialization tasks

%  Initialize input/output parameters
    hMainFig=varargin{1};
    mArgsIn=guidata(hMainFig);
    %if there is already an instance running just make it visible and raise it.
    if isfield(mArgsIn.Handles,'compensation')
        set(mArgsIn.Handles.compensation,'Visible','on');
        figure(mArgsIn.Handles.compensation);
        return;
    end


    %  Initialize data structures
    %tubeidx=arrayfun(@(x) find(strcmp([mArgsIn.TubeDB.Tubename],x),1,'first'), {mArgsIn.GraphDB(mArgsIn.curGraph).Data});
    graph=mArgsIn.curGraph(1);
    tubename=mArgsIn.GraphDB(graph).Data;
    tubeidx=find(strcmp([mArgsIn.TubeDB.Tubename],tubename),1,'first');
    mtxsize=length(mArgsIn.TubeDB(tubeidx).CompensationPrm);
    mtxnames=mArgsIn.TubeDB(tubeidx).CompensationPrm;
    mtxvalue=mArgsIn.TubeDB(tubeidx).CompensationMtx;

    %if some tubes have different compensation - don't show anything.
    for cgraph=mArgsIn.curGraph
        ctubename=mArgsIn.GraphDB(cgraph).Data;
        ctubeidx=find(strcmp([mArgsIn.TubeDB.Tubename],ctubename),1,'first');
        if mtxsize~=length(mArgsIn.TubeDB(ctubeidx).CompensationPrm)...
                || any(~strcmp(mtxnames,mArgsIn.TubeDB(ctubeidx).CompensationPrm))...
                || any(any(mtxvalue~=mArgsIn.TubeDB(ctubeidx).CompensationMtx))
            msgbox('There are tubes with different compensation matrices. Cannot open matrix.','EasyFlow','error','modal');
            uiwait;
            return;
        end
    end


    guisizex=0;
    guisizey=0;
    scrsz=get(0,'ScreenSize');

    %  Construct the figure
    fh=figure('Position',[scrsz(3) scrsz(4) 1 1],...
        'MenuBar','none',...
        'Name','FACS GUI Edit Compensation',...
        'NumberTitle','off',...
        'Visible','off',...
        'Resize','off',...
        'CloseRequestFcn',{@fhClose,hMainFig});
    mArgsIn.Handles.compensation=fh;
    guidata(hMainFig,mArgsIn);
    Args.fUpdateComp=@UpdateComp;
    guidata(fh,Args);

    %  Construct the components
    table=uitable(fh,...
        'ColumnName',mtxnames,...
        'RowName',mtxnames,...
        'Data',mtxvalue,...
        'ColumnEditable',true,...
        'CellEditCallback',@ChangeCallback);
    set(fh,'Visible','on');
    fhpos=[(scrsz(3)-guisizex)/2,(scrsz(4)-guisizey)/2,0,0]+get(table,'Extent')+[0 0 0 20];
    set(fh,'Visible','off');
    set(fh,'Position',fhpos);
    set(table,'Position',[1 1 fhpos(3) fhpos(4)-20]);
    uicontrol(fh,...
        'Style','text',...
        'String',['Compensation matrix for ' tubename],...
        'Position',[0 fhpos(4)-20 fhpos(3) 20])
    %Context menus
    %Gates
    TableCM = uicontextmenu('Parent',fh,...
        'Callback',@MenuTable);
    uimenu(TableCM,...
        'Label','Copy',...
        'Callback',@MenuTableCopy);
    uimenu(TableCM,...
        'Label','Paste',...
        'Callback',@MenuTablePaste);
    uimenu(TableCM,...
        'Label','Export',...
        'Callback',@MenuTableExport);
    uimenu(TableCM,...
        'Label','Import',...
        'Callback',@MenuTableImport);
    uimenu(TableCM,...
        'Label','Use Compensation',...
        'Callback',@MenuTableUseComp);
    uimenu(TableCM,...
        'Label','AutoCalc Compensation',...
        'Callback',@MenuTableAutoComp);
    set(table,'UIContextMenu',TableCM);

    %  Initialization tasks

    %  Render GUI visible
    set(fh,'Visible','on');


    % %  Wait for termination of GUI to give output
    % if nargout>0
    %     uiwait;%uiresume
    %     %  Return the output
    %     mOutputArgs{1}=mArgsIn.GraphDB;
    %     if nargout==size(mOutputArgs,2)
    %         [varargout{1:nargout}] = mOutputArgs{:};
    %     end
    % end

    %  Callbacks.
    function fhClose(hObject,eventdata,hMainFig)
        mArgsIn=guidata(hMainFig);
        mArgsIn.Handles=rmfield(mArgsIn.Handles,'compensation');
        guidata(hMainFig,mArgsIn);
        if isempty(hObject)
            if length(dbstack) == 1
                warning('MATLAB:closereq', ...
                    'Calling closereq from the command line is now obsolete, use close instead');
            end
            close force
        else
            delete(hObject);
        end
    end
    function ChangeCallback(hObject,eventdata)
        mArgsIn=guidata(hMainFig);
        mtxvalue=get(table,'Data');
        
        cM=strtrim(cellstr(num2str(mtxvalue(:),'%.4f')));
        cSpill={num2str(length(mArgsIn.TubeDB(tubeidx).CompensationPrm)) mArgsIn.TubeDB(tubeidx).CompensationPrm{:} cM{:}};
        sep=cell(size(cSpill(:)));
        [sep{:}]=deal(',');
        cSpill=[cSpill(:),sep]';
        Spill=[cSpill{1:end-1}];
        
        %move over all tubes in the curent selected graphs
        for ctubename=unique({mArgsIn.GraphDB(mArgsIn.curGraph).Data})
            ctubeidx=find(strcmp([mArgsIn.TubeDB.Tubename],ctubename),1,'first');
            mArgsIn.TubeDB(ctubeidx).CompensationMtx=mtxvalue;
            %set the new comp in the param of the fcsfile
            mArgsIn.TubeDB(ctubeidx).fcsfile=fcssetparam(mArgsIn.TubeDB(ctubeidx).fcsfile,'SPILL',Spill);
            %recalc compensation
            fcsfile=mArgsIn.TubeDB(ctubeidx).fcsfile;
            uncompdata=fcsfile.fcsdata;
            mArgsIn.TubeDB(ctubeidx).compdata=uncompdata;
            mArgsIn.TubeDB(ctubeidx).compdata(:,mArgsIn.TubeDB(ctubeidx).CompensationIndex)=uncompdata(:,mArgsIn.TubeDB(ctubeidx).CompensationIndex)*inv(mtxvalue');
            
            %recalculate the gate logical indices
            
            mArgsIn=mArgsIn.Handles.RecalcGateLogicalMask(mArgsIn,matlab.lang.makeValidName(ctubename));
            
        end
        
        %needto recalc gated data to show
        mArgsIn=mArgsIn.Handles.CalculateGatedData(mArgsIn);
        mArgsIn.DBInfo.isChanged=1;
        guidata(hMainFig,mArgsIn);
        mArgsIn.Handles.DrawFcn(mArgsIn);
        %figure(gcbf);
    end

    function MenuTable(hObject,eventdata)
        mArgsIn=guidata(hMainFig);
        if isfield(mArgsIn,'copy') && isfield(mArgsIn.copy,'compensation')
            set(findobj(hObject,'Label','Paste'),'Enable','on');
        else
            set(findobj(hObject,'Label','Paste'),'Enable','off');
        end
        
    end
    function MenuTableCopy(hObject,eventdata)
        mArgsIn=guidata(hMainFig);
        mArgsIn.copy.compensation=mtxvalue;
        mArgsIn.DBInfo.isChanged=1;
        guidata(hMainFig,mArgsIn)
    end
    function MenuTablePaste(hObject,eventdata)
        mArgsIn=guidata(hMainFig);
        if isfield(mArgsIn,'copy') && isfield(mArgsIn.copy,'compensation')
            set(table,'Data',mArgsIn.copy.compensation);
            ChangeCallback(table,[]);
        end
    end
    function MenuTableExport(hObject,eventdata)
        export2wsdlg({'Save Compensation Matrix As:'},{'CompMtx'},{mtxvalue});
    end
    function MenuTableImport(hObject,eventdata)
        mArgsIn=guidata(hMainFig);
        vars=evalin('base','who');
        mtxvarname=popupdlg('choose a matrix',vars);
        mtxvar=evalin('base',vars{mtxvarname});

        if size(mtxvalue)==size(mtxvar)
            set(table,'Data',mtxvar);
            ChangeCallback(table,[]);
            else
            msgbox(['The variable ' vars{fitvarname} ' does not contain a matrix of the correct size.'],'EasyFlow','error','modal');
            uiwait;
        end
    end
    function MenuTableUseComp(hObject,eventdata)
        mArgsIn=guidata(hMainFig);
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
        [Selection,ok] = listdlg('ListString',S,'Name','Select Tubes','PromptString','Select tubes for which to use this compensation.','OKString','Set Compensation');
        if ok==1
            %format the spill
            cM=strtrim(cellstr(num2str(mtxvalue(:),'%.4f')));
            cSpill={num2str(length(mArgsIn.TubeDB(tubeidx).CompensationPrm)) mArgsIn.TubeDB(tubeidx).CompensationPrm{:} cM{:}};
            sep=cell(size(cSpill(:)));
            [sep{:}]=deal(',');
            cSpill=[cSpill(:),sep]';
            Spill=[cSpill{1:end-1}];
            
            for ctubeidx=Selection
                if mtxsize~=length(mArgsIn.TubeDB(ctubeidx).CompensationPrm)...
                        || any(~strcmp(mtxnames,mArgsIn.TubeDB(ctubeidx).CompensationPrm))
                    msgbox(['The tube ' S{ctubeidx} ' has different colors. Cannot use matrix.'],'EasyFlow','error','modal');
                    uiwait;
                    continue;
                end
                
                mArgsIn.TubeDB(ctubeidx).CompensationMtx=mtxvalue;
                %set the new comp in the param of the fcsfile
                mArgsIn.TubeDB(ctubeidx).fcsfile=fcssetparam(mArgsIn.TubeDB(ctubeidx).fcsfile,'SPILL',Spill);
                %recalc compensation
                fcsfile=mArgsIn.TubeDB(ctubeidx).fcsfile;
                uncompdata=fcsfile.fcsdata;
                mArgsIn.TubeDB(ctubeidx).compdata=uncompdata;
                mArgsIn.TubeDB(ctubeidx).compdata(:,mArgsIn.TubeDB(ctubeidx).CompensationIndex)=uncompdata(:,mArgsIn.TubeDB(ctubeidx).CompensationIndex)*inv(mtxvalue');
                
                %recalculate the gate logical indices
                ctubename=mArgsIn.TubeDB(ctubeidx).Tubename;
                mArgsIn=mArgsIn.Handles.RecalcGateLogicalMask(mArgsIn,matlab.lang.makeValidName(ctubename));
            end
            %need to recalc gates but not for the curGraph
            changed_graphs=find(cellfun(@(x) any(strcmp(S(Selection),x)),{mArgsIn.GraphDB.Data}));
            cgraphs=mArgsIn.curGraph;
            mArgsIn.curGraph=changed_graphs;
            mArgsIn=mArgsIn.Handles.CalculateGatedData(mArgsIn);
            mArgsIn.curGraph=cgraphs;
            mArgsIn.DBInfo.isChanged=1;
            guidata(hMainFig,mArgsIn);
            mArgsIn.Handles.DrawFcn(mArgsIn);
        end
    end
    function MenuTableAutoComp(hObject,eventdata)
        [compmat,colorlist]=EFCalcComp;
        mArgsIn=guidata(hMainFig);
        [~,tblIdx,clrIdx]=intersect(table.ColumnName,colorlist);
        table.Data(tblIdx,tblIdx)=compmat(clrIdx,clrIdx);
        ChangeCallback(table,[]);
    end

%  Utility functions for MYGUI
    function UpdateComp(hMainFig)
        mArgsIn=guidata(hMainFig);
        graph=mArgsIn.curGraph(1);
        tubename=mArgsIn.GraphDB(graph).Data;
        tubeidx=find(strcmp([mArgsIn.TubeDB.Tubename],tubename),1,'first');
        mtxsize=length(mArgsIn.TubeDB(tubeidx).CompensationPrm);
        mtxnames=mArgsIn.TubeDB(tubeidx).CompensationPrm;
        mtxvalue=mArgsIn.TubeDB(tubeidx).CompensationMtx;
        
        %if some tubes have different compensation - don't show anything.
        for cgraph=mArgsIn.curGraph
            ctubename=mArgsIn.GraphDB(cgraph).Data;
            ctubeidx=find(strcmp([mArgsIn.TubeDB.Tubename],ctubename),1,'first');
            if mtxsize~=length(mArgsIn.TubeDB(ctubeidx).CompensationPrm)...
                    || any(~strcmp(mtxnames,mArgsIn.TubeDB(ctubeidx).CompensationPrm))...
                    || any(any(mtxvalue~=mArgsIn.TubeDB(ctubeidx).CompensationMtx))
                msgbox('There are tubes with different compensation matrices. Cannot open matrix.','EasyFlow','error','modal');
                uiwait;
                fhClose(fh,[],hMainFig);
                return;
            end
        end
        
        fhpos=get(fh,'Position');
        fhpos=[fhpos(1),fhpos(2),0,0]+get(table,'Extent')+[0 0 0 20];
        set(fh,'Position',fhpos);
        set(table,'Position',[1 1 fhpos(3) fhpos(4)-20]);
        set(findobj(fh,'Type','uicontrol'),'String',['Compensation matrix for ' tubename],'Position',[0 fhpos(4)-20 fhpos(3) 20]);
        set(table,'Data',mtxvalue);
        
    end
end

function [compmat,colorlist]=EFCalcComp
    %open unstained file. use it to get the colorlist.
    [filename,pathname] = uigetfile('*.fcs','Enter Unstained File');
    if isnumeric(filename)
        error('No file to load.');
    else
        cd(pathname);
        unstained=fcsload(filename);
    end
    parname_idx= ~cellfun(@isempty,regexp(unstained.var_name,'\$P[0-9]+N'));
    parname=unstained.var_value(parname_idx);
    colorlist_idx=find(~cellfun(@isempty,regexp(parname,'.+A')));
    colorlist=parname(colorlist_idx);

    %open single color files
    usedcolors=[];
    singledata={};
    for curcolor = 1:length(colorlist)
        [filename,pathname] = uigetfile('*.fcs',['Enter ' colorlist{curcolor} '-stained File']);
        %TBD:check the the colors in this file are the same
        if ~isnumeric(filename)
            cd(pathname);
            tmpdata=fcsload(filename);
            singledata{end+1}=tmpdata.fcsdata;
            usedcolors(end+1)=colorlist_idx(curcolor);
        end
    end
    %remove the extra colors
    singledata=arrayfun(@(x) x{1}(:,usedcolors),singledata,'UniformOutput',0);

    colorlist=parname(usedcolors);
    compmat=fcscompensate(singledata);
end

function [M,AF]=fcscompensate(I)
    %fcscompensate(I) returns the compensation matrix, given cell array of matrices each with a
    %single color data.
    %number of elements in I is the same as size(,2) of each of the elements.
    %the n'th element of I is stained with the nth color, measured in the nth
    %nth row of each of the elements of I.
    %
    %better results are when the staining as least homogeneous.
    %
    %minimize the standard deviation of the overflown data
    %but ignore very off points (more than one std away)
    %
    %if R are the real values for the n colors, and O are the observed ones
    %then we have
    %   O=M*R+AF
    % such that M is the spillover matrix and AF is the autoflouresence and
    %   R=inv(M)*(O-AF)

    color_num=length(I);
    M=zeros(color_num);
    AFmat=zeros(color_num);

    for stain_color=1:color_num
        for ow_color=1:color_num
            data=I{stain_color};
            %        M(ow_color,stain_color)=fminsearch(@(x) stdstd(x,data(:,ow_color),data(:,stain_color)),0);
            M(ow_color,stain_color)=fminbnd(@(x) mad(data(:,ow_color)-x*data(:,stain_color),1),0,2);
            AFmat(ow_color,stain_color)=median(data(:,ow_color)-M(ow_color,stain_color)*data(:,stain_color));
        end
    end

    AF=inv(diag(color_num*ones(1,color_num))-M)*sum(AFmat,2);



    function s=stdstd(m,ow,stain)
        A=ow-m*stain;
        s=std(A(abs(A-mean(A))<std(A)));
        i=1;stat=struct;
        for tube=fieldnames(mArgsIn.data)'
            f=fit([1:length(mArgsIn.data.(char(tube)))]',mArgsIn.data.(char(tube))(:,end)/100,'poly1');
            stat(i).name=char(tube);
            stat(i).cpl=1/f.p1;%cells per lambda, actually per second
            stat(i).mcpl=length(mArgsIn.data.(char(tube)))/mArgsIn.data.(char(tube))(end,end)*100;%mean cells per lambda
            i=i+1;
        end
    end
end
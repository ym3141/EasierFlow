function mArgsIn=UpdateVersion(mArgsIn, curversion)
%% function used to handel sessions files older than 3.20
% By Yaron
    if ~isfield(mArgsIn,'version') || mArgsIn.version<2.5
        %Update to version 0.2.5
        mArgsIn.version=2.5;
        %if color is an integer, change it to a string.
        if isnumeric([mArgsIn.GraphDB.Color])
            DT={mArgsIn.GraphDB.Data};
            CLR={mArgsIn.GraphDB.Color};
            CLR2={mArgsIn.GraphDB.Color2};
            for i=1:length(DT)
                if isfield(mArgsIn.hdr,DT{i})
                    mArgsIn.GraphDB(i).Color=mArgsIn.hdr.(DT{i}).par(CLR{i}).name;
                    mArgsIn.GraphDB(i).Color2=mArgsIn.hdr.(DT{i}).par(CLR2{i}).name;
                elseif strcmp('None',DT{i})
                    mArgsIn.GraphDB(i).Color='None';
                    mArgsIn.GraphDB(i).Color2='None';
                else
                    msgbox(['Your file was saved in an older version and cannot be converted. To convert it you need first to load the tube ' DT{i}]...
                        ,'EasyFlow','error','modal');
                    uiwait;
                    mArgsIn=[];
                    return;
                end
            end
        end
        %if ther is GraphDB.Isotype, GraphDB.RemoveIso, change to Ctrl and
        %RemoveCtrl
        if isfield(mArgsIn.GraphDB,'Isotype')
            [mArgsIn.GraphDB.Ctrl]=deal(mArgsIn.GraphDB.Isotype);
            mArgsIn.GraphDB=rmfield(mArgsIn.GraphDB,'Isotype');
        end
        if isfield(mArgsIn.GraphDB,'RemoveIso')
            [mArgsIn.GraphDB.RemoveCtrl]=deal(mArgsIn.GraphDB.RemoveIso);
            mArgsIn.GraphDB=rmfield(mArgsIn.GraphDB,'RemoveIso');
        end
        %change the gates to save the color name rather than the number
        if isfield(mArgsIn,'GatesDB')
            for tube=fieldnames(mArgsIn.GatesDB)'
                for gatename=fieldnames(mArgsIn.GatesDB.(char(tube)))'
                    if isfield(mArgsIn,'hdr') && isfield(mArgsIn.hdr,char(tube))
                        if length(mArgsIn.GatesDB.(char(tube)).(char(gatename)))>1 && isnumeric(mArgsIn.GatesDB.(char(tube)).(char(gatename)){2})
                            if length(mArgsIn.GatesDB.(char(tube)).(char(gatename)))==2
                                mArgsIn.GatesDB.(char(tube)).(char(gatename)){2}=mArgsIn.hdr.(char(tube)).par(mArgsIn.GatesDB.(char(tube)).(char(gatename)){2}).name;
                            elseif length(mArgsIn.GatesDB.(char(tube)).(char(gatename)))==3
                                mArgsIn.GatesDB.(char(tube)).(char(gatename)){2}=mArgsIn.hdr.(char(tube)).par(mArgsIn.GatesDB.(char(tube)).(char(gatename)){2}).name;
                                mArgsIn.GatesDB.(char(tube)).(char(gatename)){3}=mArgsIn.hdr.(char(tube)).par(mArgsIn.GatesDB.(char(tube)).(char(gatename)){3}).name;
                            end
                        end
                    elseif isfield(mArgsIn,'TubeDB') && any(strcmp([mArgsIn.TubeDB.Tubename],tube))
                        tubeidx=find(strcmp([mArgsIn.TubeDB.Tubename],tube));
                        if length(mArgsIn.GatesDB.(char(tube)).(char(gatename)))>1 && isnumeric(mArgsIn.GatesDB.(char(tube)).(char(gatename)){2})
                            if length(mArgsIn.GatesDB.(char(tube)).(char(gatename)))==2
                                mArgsIn.GatesDB.(char(tube)).(char(gatename)){2}=mArgsIn.TubeDB(tubeidx).parname(mArgsIn.GatesDB.(char(tube)).(char(gatename)){2});
                            elseif length(mArgsIn.GatesDB.(char(tube)).(char(gatename)))==3
                                mArgsIn.GatesDB.(char(tube)).(char(gatename)){2}=mArgsIn.TubeDB(tubeidx).parname(mArgsIn.GatesDB.(char(tube)).(char(gatename)){2});
                                mArgsIn.GatesDB.(char(tube)).(char(gatename)){3}=mArgsIn.TubeDB(tubeidx).parname(mArgsIn.GatesDB.(char(tube)).(char(gatename)){3});
                            end
                        end
                    elseif strcmp('None',char(tube))
                        continue
                    else
                        msgbox(['Your file was saved in an older version and cannot be converted. To convert it you need first to load the tube ' char(tube)]...
                            ,'EasyFlow','error','modal');
                        uiwait;
                        mArgsIn=[];
                        return;
                    end
                end
            end
        end
        %end update to ver 0.2.5
    end
    if mArgsIn.version<2.6
        %update to ver 0.2.6
        %mArgsIn.workdata=mArgsIn.data;
        %mArgsIn.data=mArgsIn.datauncomp;
        %mArgsIn=rmfield(mArgsIn,datauncomp);
    end
    if mArgsIn.version<2.7
        curGraph=mArgsIn.curGraph;
        mArgsIn.curGraph=1:length(mArgsIn.GraphDB);
        mArgsIn=CalculateGatedData(mArgsIn);
        mArgsIn.curGraph=curGraph;
    end
    if mArgsIn.version<2.8
        %add a 'fit' field
        if ~isempty(mArgsIn.GraphDB) && ~isfield(mArgsIn.GraphDB,'fit')
            [mArgsIn.GraphDB.fit]=deal([]);
        end
    end
    if mArgsIn.version<2.9
        %arrange the gates
        %recalculate the gate logical indices
        if isempty(mArgsIn.TubeDB)
            mArgsIncur=guidata(mArgsIn.Handles.fh);
            mArgsIn2=mArgsIncur;
            mArgsIn2.GraphDB=[];
            mArgsIn2.TubeNames={'None'};
            if isfield(mArgsIn2,'curGraph')
                mArgsIn2=rmfield(mArgsIn2,'curGraph');
            end
            if isfield(mArgsIn2,'GatesDB')
                mArgsIn2=rmfield(mArgsIn2,'GatesDB');
            end
            if isfield(mArgsIn2,'copy')
                mArgsIn2=rmfield(mArgsIn2,'copy');
            end
            guidata(mArgsIn.Handles.fh,mArgsIn2)
            TubeLoadCallback(0,[],mArgsIn.Handles.fh);
            mArgsIn2=guidata(mArgsIn.Handles.fh);
            mArgsIncur.TubeDB=mArgsIn2.TubeDB;
            mArgsIncur.TubeNames=mArgsIn2.TubeNames;
            guidata(mArgsIn.Handles.fh,mArgsIncur)
            mArgsIn.TubeDB=mArgsIn2.TubeDB;
            mArgsIn.TubeNames=mArgsIn2.TubeNames;
        end
        if isfield(mArgsIn.TubeDB, 'Tubename')
            for ctubename=[mArgsIn.TubeDB.Tubename];
                ctubeidx=find(strcmp([mArgsIn.TubeDB.Tubename],ctubename),1,'first');
                if isfield(mArgsIn,'GatesDB') && isfield(mArgsIn.GatesDB,matlab.lang.makeValidName(char(ctubename)))
                    for gatename=fieldnames(mArgsIn.GatesDB.(matlab.lang.makeValidName(char(ctubename))))'
                        gate=mArgsIn.GatesDB.(matlab.lang.makeValidName(char(ctubename))).(char(gatename));
                        if length(gate)==2
                            gate{3}=gate{2};
                            gate{4}=[];
                            colorind=find(strcmp(mArgsIn.TubeDB(ctubeidx).parname,gate{3}),1,'first');
                            gate{2}=...
                                mArgsIn.TubeDB(ctubeidx).compdata(:,colorind)>gate{1}(1) ...
                                & mArgsIn.TubeDB(ctubeidx).compdata(:,colorind)<gate{1}(2);
                        elseif length(gate)==3
                            gate{4}=gate{3};
                            gate{3}=gate{2};
                            colorind(1)=find(strcmp(mArgsIn.TubeDB(ctubeidx).parname,gate{3}),1,'first');
                            colorind(2)=find(strcmp(mArgsIn.TubeDB(ctubeidx).parname,gate{4}),1,'first');
                            gate{2}=...
                                gate2d(gate{1},mArgsIn.TubeDB(ctubeidx).compdata,colorind(1),colorind(2));
                        end
                        mArgsIn.GatesDB.(matlab.lang.makeValidName(char(ctubename))).(char(gatename))=gate;
                    end
                end
            end
        end
        [mArgsIn.GraphDB.GatesOff]=deal({});
    end
    if mArgsIn.version<3.0
        for i=1:length(mArgsIn.GraphDB)
            if ~isfield(mArgsIn.GraphDB(i).Display,'smoothprm')
                mArgsIn.GraphDB(i).Display.smoothprm=-1;
            end
            if ~isfield(mArgsIn,'Statistics')
                mArgsIn.Statistics.ShowInStatView=true(1,9);
            end
        end
        if isfield(mArgsIn,'GatesDB')
            for tube=fieldnames(mArgsIn.GatesDB)'
                for gate=fieldnames(mArgsIn.GatesDB.(char(tube)))'
                    if isempty(mArgsIn.GatesDB.(char(tube)).(char(gate)){4}) && isinf(mArgsIn.GatesDB.(char(tube)).(char(gate)){1}(3))
                        mArgsIn.GatesDB.(char(tube)).(char(gate)){1}(3)=0;
                    end
                end
            end
        end

        mArgsIn.DBInfo.geom.Graphsize=100;
        mArgsIn.DBInfo.geom.Gatesize=120;
    end
    if mArgsIn.version<3.19
        %
        % Change the field DBFile to DBInfo
        %
        mArgsIn.DBInfo=mArgsIn.DBFile;
        mArgsIn=rmfield(mArgsIn,'DBFile');
        %
        % New gates strucutre. global gates for all tubes.
        %
        %collect all gates from all tubes into a single structure which
        %will be the new GatesDB
        allgates=struct();
        for tube=fieldnames(mArgsIn.GatesDB)'
            for cur_gate=fieldnames(mArgsIn.GatesDB.(tube{1}))'
                tmpgate=mArgsIn.GatesDB.(tube{1}).(cur_gate{1})([1,3:end]);
                if ~any(structfun(@(x) isequal(x,tmpgate), allgates))
                    gatename=matlab.lang.makeUniqueStrings(cur_gate{1}, fieldnames(allgates));
                    allgates.(gatename)=tmpgate;
                end
            end
        end
        %put the logical gate in TubeDB.isgated
        %or maybe calculate from scratch?
        for tube=fieldnames(mArgsIn.GatesDB)'
            % previously (delete): tube_ind=strcmp(tube,[mArgsIn.TubeDB.Tubename]);
            tube_ind=strcmp(tube,matlab.lang.makeValidName([mArgsIn.TubeDB.Tubename], 'ReplacementStyle','hex'));
            for cur_gate=fieldnames(mArgsIn.GatesDB.(tube{1}))'
                tmpisgated=mArgsIn.GatesDB.(tube{1}).(cur_gate{1})(2);
                mArgsIn.TubeDB(tube_ind).gatemask.(cur_gate{1})=tmpisgated;
            end
        end
        mArgsIn.GatesDBnew=allgates;
    end
    if mArgsIn.version<3.23
        mFile = load('./asset/PlotColors.mat');
        mArgsIn.Display.GraphColor = mFile.ColorMat;
        mArgsIn.Display.XAuto = true;
        mArgsIn.Display.YAuto = true;
    end
    %insert before this line the text in FileLoadCallback after the comment:

    mArgsIn.version=curversion;
    mArgsIn.DBInfo.isChanged=1;
    %updates for next version are in FileLoadCallback
end
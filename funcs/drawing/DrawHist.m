function efdb = DrawHist(efdb)
    %Draw histograms.
    %go over all selected graphs and draws them.
    %if no Ctrl only draws the data.
    %if have Ctrl, cna either draw both or do deconvolution.
    no_data_graphs=[];
    allgraphs=get(efdb.Handles.GraphList,'Value');
    lgnd=cell(1,length(allgraphs));
    lgnd_len = 0;
    for i=1:length(allgraphs)
        graph=allgraphs(i);
        if isfield(efdb.TubeDB,'Tubename')
            tubeidx=find(strcmp([efdb.TubeDB.Tubename],efdb.GraphDB(graph).Data),1,'first');
        else
            tubeidx=[];
        end
        %check that the tube exists
        if isempty(tubeidx)
            efdb.GraphDB(graph).plotdata=[];
            continue
        end
        %check histnormalize display settings.
        if ~isfield(efdb.Display,'histnormalize')
            efdb.Display.histnormalize='Total';
        end
        %find the color index
        colorind=find(strcmp(efdb.TubeDB(tubeidx).parname,efdb.GraphDB(graph).Color),1,'first');
        if isempty(colorind)
            continue
        end
        % add the graphname to the legend
        lgnd_len = lgnd_len +1;
        lgnd{lgnd_len}=efdb.GraphDB(graph).Name;
        %create the plotdata and the control data
        gateddata=efdb.TubeDB(tubeidx).compdata(efdb.GraphDB(graph).gatedindex,:);
        efdb.GraphDB(graph).plotdata=gateddata(:,colorind);
        if ~strcmp(efdb.GraphDB(graph).Ctrl,'None')
            ctrlidx=find(strcmp([efdb.TubeDB.Tubename],efdb.GraphDB(graph).Ctrl),1,'first');
            gatedCtrl=efdb.TubeDB(ctrlidx).compdata(efdb.GraphDB(graph).gatedindexctrl,:);
            if isfield(efdb.GraphDB(graph),'RemoveCtrl') && isequal(efdb.GraphDB(graph).RemoveCtrl,1)
                if ~isfield(efdb.GraphDB(graph),'DataDeconv') || isequal(efdb.GraphDB(graph).DataDeconv,[])
                    %create deconv
                    efdb.GraphDB(graph).DataDeconv=fcsdeconv(gateddata(:,colorind),gatedCtrl(:,colorind));
                end
                efdb.GraphDB(graph).plotdata=efdb.GraphDB(graph).DataDeconv;
            end
        end
        %draw the data
        if isempty(efdb.GraphDB(graph).plotdata)
            no_data_graphs=[no_data_graphs ''', ''' efdb.GraphDB(graph).Name];
            continue;
        end
        switch efdb.Display.histnormalize
            case 'Gated'
                %integral = gated percent
                normprm=prod(efdb.GraphDB(graph).Stat.gatepercent);
                yname='Percent of total';
            case 'Abs'
                %integral=num of cells
                normprm=length(gateddata(:,colorind));
                yname='Number of events';
            otherwise
                %integral = 1
                normprm=1;
                yname='Percent';
        end
        fcshist(efdb.GraphDB(graph).plotdata,efdb.Display.graph_Xaxis,efdb.Display.graph_Xaxis_param,efdb.Display.graph_Yaxis,'norm',normprm,'smooth',efdb.Display.smoothprm);
        [hist,bins]=fcshist(efdb.GraphDB(graph).plotdata,efdb.Display.graph_Xaxis,efdb.Display.graph_Xaxis_param,efdb.Display.graph_Yaxis,'norm',normprm,'smooth',efdb.Display.smoothprm);
        efdb.GraphDB(graph).plotdata=[bins(:),hist(:)];
        graphs=get(gca,'Children');
        if ~isfield(efdb.GraphDB(graph),'PlotColor') || length(efdb.GraphDB(graph).PlotColor)~=3
            efdb.GraphDB(graph).PlotColor=efdb.Display.GraphColor(mod(graph,7)+(mod(graph,7)==0)*7,:);
        end
        set(graphs(1),'Color',efdb.GraphDB(graph).PlotColor);
        %if a fit exists, draw the fit
        if isfield(efdb.GraphDB(graph),'fit') && ~isempty(efdb.GraphDB(graph).fit)
            scaledbins=fcsscaleconvert(bins,efdb.Display.graph_Xaxis,efdb.Display.graph_Xaxis_param(3),efdb.GraphDB(graph).fit{3},efdb.GraphDB(graph).fit{4});
            dy=diff(bins);
            dy=mean([dy(1) dy; dy dy(end)]);
            dx=diff(scaledbins);
            dx=mean([dx(1) dx; dx dx(end)]);
            J=dx./dy;
            h=line(bins, J'.*efdb.GraphDB(graph).fit{1}(scaledbins));
            set(h,'linestyle',':');
            set(h,'Color',efdb.GraphDB(graph).PlotColor);
            lgnd{end+1}=[efdb.GraphDB(graph).Name ' - Fit'];
        end
        %if also control, draw the control
        if ~strcmp(efdb.GraphDB(graph).Ctrl,'None')...
                && (~isfield(efdb.GraphDB(graph),'RemoveCtrl') || ~isequal(efdb.GraphDB(graph).RemoveCtrl,1))
            lgnd{end+1}=[efdb.GraphDB(graph).Name ' Control'];
            if isempty(gatedCtrl)
                msgbox(['The control for graph ' efdb.GraphDB(graph).Name ' contains no data.'],'EasyFlow','error','modal');
                uiwait;
                continue;
            end
            fcshist(gatedCtrl(:,colorind),efdb.Display.graph_Xaxis,efdb.Display.graph_Xaxis_param,efdb.Display.graph_Yaxis,'norm',normprm,'smooth',efdb.Display.smoothprm);
            graphs=get(gca,'Children');
            if ~isfield(efdb.GraphDB(graph),'PlotColor') || length(efdb.GraphDB(graph).PlotColor)~=3
                efdb.GraphDB(graph).PlotColor=efdb.Display.GraphColor(mod(graph,7)+(mod(graph,7)==0)*7,:);
            end
            set(graphs(1),'Color',efdb.GraphDB(graph).PlotColor);
            set(graphs(1),'LineStyle',':');
        end
    end
    %set up the periphery of the graph
    fs=min(10,30/length(lgnd));
    if ~isempty(lgnd) && ~isempty(get(gca,'Children')) && fs>1.5
        legend(lgnd,'FontSize',fs,'Interpreter','None');
    end
    if isfield(efdb.Display,'Axis')
        axis(efdb.Display.Axis);
    end
    xlabel(getcolumn(get(efdb.Handles.ColorPUM,'string')',get(efdb.Handles.ColorPUM,'value')));
    if exist('yname','var')
        ylabel(yname);
    end
    if ~isempty(no_data_graphs)
        msgbox(['The graphs ''' no_data_graphs ''' contain no data.'],'EasyFlow','error','modal');
        uiwait;
    end
end
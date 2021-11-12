function efdb = Draw2D(efdb)
        %Draw 2d contours
    no_data_graphs=[];
    if isscalar(efdb.curGraph) || strcmp(efdb.Display.graph_type,'Dot Plot')
        for graph=efdb.curGraph
            tubeidx=find(strcmp([efdb.TubeDB.Tubename],efdb.GraphDB(graph).Data),1,'first');
            %check that the tube exists
            if isempty(tubeidx)
                efdb.GraphDB(graph).plotdata=[];
                continue
            end
            gateddata=efdb.TubeDB(tubeidx).compdata(efdb.GraphDB(graph).gatedindex,:);
            efdb.GraphDB(graph).plotdata=[];
            if isempty(gateddata)
                no_data_graphs=[no_data_graphs ''', ''' efdb.GraphDB(graph).Name];
                continue;
            end
            colorind=find(strcmp(efdb.TubeDB(tubeidx).parname,efdb.GraphDB(graph).Color),1,'first');
            if ~colorind, continue, end
            color2ind=find(strcmp(efdb.TubeDB(tubeidx).parname,efdb.GraphDB(graph).Color2),1,'first');
            if ~color2ind, continue, end
            fcscontour(gateddata,...
                colorind,color2ind,...
                efdb.Display.graph_type,efdb.Display.graph_Xaxis,efdb.Display.graph_Xaxis_param,efdb.Display.graph_Yaxis,efdb.Display.graph_Yaxis_param);
            efdb.GraphDB(graph).plotdata=gateddata(:,[colorind,color2ind]);
            graphs=get(gca,'Children');
            if strcmp(get(get(gca,'children'),'type'),'line')
                if ~isfield(efdb.GraphDB(graph),'PlotColor') || length(efdb.GraphDB(graph).PlotColor)~=3
                    efdb.GraphDB(graph).PlotColor=efdb.Display.GraphColor(mod(graph,7)+(mod(graph,7)==0)*7,:);
                end
                set(graphs(1),'Color',efdb.GraphDB(graph).PlotColor);
            end
        end
    else
        dilute=length(efdb.curGraph);
        alldata=[];
        for graph=efdb.curGraph
            tubeidx=find(strcmp([efdb.TubeDB.Tubename],efdb.GraphDB(graph).Data),1,'first');
            %check that the tube exists
            if isempty(tubeidx)
                continue
            end
            gateddata=efdb.TubeDB(tubeidx).compdata(efdb.GraphDB(graph).gatedindex,:);
            efdb.GraphDB(graph).plotdata=[];
            if isempty(gateddata)
                no_data_graphs=[no_data_graphs ''', ''' efdb.GraphDB(graph).Name];
                continue;
            end
            colorind=find(strcmp(efdb.TubeDB(tubeidx).parname,efdb.GraphDB(graph).Color),1,'first');
            if ~colorind, continue, end
            color2ind=find(strcmp(efdb.TubeDB(tubeidx).parname,efdb.GraphDB(graph).Color2),1,'first');
            if ~color2ind, continue, end
            %                 fcscontour(gateddata,...
            %                     colorind,color2ind,...
            %                     mArgsIn.Display.graph_type,mArgsIn.Display.graph_Xaxis,mArgsIn.Display.graph_Xaxis_param,mArgsIn.Display.graph_Yaxis,mArgsIn.Display.graph_Yaxis_param);
            efdb.GraphDB(graph).plotdata=gateddata(:,[colorind,color2ind]);
            alldata=[alldata; efdb.GraphDB(graph).plotdata(1:dilute:end,:)];
            %                 graphs=get(gca,'Children');
            %                 if strcmp(get(get(gca,'children'),'type'),'line')
            %                     if ~isfield(mArgsIn.GraphDB(graph),'PlotColor') || length(mArgsIn.GraphDB(graph).PlotColor)~=3
            %                         mArgsIn.GraphDB(graph).PlotColor=mArgsIn.Display.GraphColor(mod(graph,7)+(mod(graph,7)==0)*7,:);
            %                     end
            %                     set(graphs(1),'Color',mArgsIn.GraphDB(graph).PlotColor);
            %                 end
        end
        fcscontour(alldata,...
            1,2,...
            efdb.Display.graph_type,efdb.Display.graph_Xaxis,efdb.Display.graph_Xaxis_param,efdb.Display.graph_Yaxis,efdb.Display.graph_Yaxis_param);
    end
    if isfield(efdb.Display,'Axis')
        axis(efdb.Display.Axis);
    else
        axis tight;
    end
    if ~isempty(no_data_graphs)
        msgbox(['The graphs ''' no_data_graphs ''' contain no data.'],'EasyFlow','error','modal');
        uiwait;
    end
    if isfield(efdb.GraphDB(efdb.curGraph(1)).Stat,'quad')
        DrawQuads(efdb);
    end
    xlabel(getcolumn(get(efdb.Handles.ColorPUM,'string')',get(efdb.Handles.ColorPUM,'value')));
    ylabel(getcolumn(get(efdb.Handles.ColorPUM,'string')',get(efdb.Handles.Color2PUM,'value')));
end
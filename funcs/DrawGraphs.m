function efdb = DrawGraphs(efdb)
    %Draw the graphs. use the mArgsIn.Display.graph_* parameters
    %mArgsIn.Display.graph_Xaxis can be 'lin' 'log' 'asinh' 'logicle'
    %mArgsIn.Display.graph_type can be 'Histogram','Dot Plot','Colored Dot
    %Plot','Contour','Filled Contour'
    %mArgsIn.Display.graph_Yaxis can be 'ylin' or 'ylog'
    %set up the axis for plotting
    set(0,'CurrentFigure',efdb.Handles.fh)
%         plot(1,1);
    cla(efdb.Handles.ax);
    hold on;
    switch efdb.Display.graph_type
        case 'Histogram'
            efdb = DrawHist(efdb);
        case {'Contour', 'Filled Contour', 'Dot Plot', 'Colored Dot Plot'}
            efdb = Draw2D(efdb);
        otherwise
            efdb = DrawHist(efdb);
    end
    hold off
    efdb=CalculateMarkers(efdb);
end
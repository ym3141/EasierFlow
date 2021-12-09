function mArgsIn = DrawToFigure(mArgsIn)
    %Draw the graphs in a special figure. use the mArgsIn.Display.graph_* parameters
    %mArgsIn.Display.graph_Xaxis can be 'lin' 'log' 'asinh' 'logicle'
    %mArgsIn.Display.graph_type can be 'Histogram','Dot Plot','Colored Dot
    %Plot','Contour','Filled Contour'
    %mArgsIn.Display.graph_Yaxis can be 'ylin' or 'ylog'
    %set up the axis for plotting
    hFig=figure;
    if ~isdeployed
        plottools(hFig);
    end
    cla(gca);
    hold on;
    switch mArgsIn.Display.graph_type
        case 'Histogram'
            mArgsIn = DrawHist(mArgsIn);
        case {'Contour', 'Filled Contour', 'Dot Plot', 'Colored Dot Plot'}
            mArgsIn = Draw2D(mArgsIn);
        otherwise
            mArgsIn = DrawHist(mArgsIn);
    end
    hold off
    %set font size to 12 and typeface to Arial
    h = legend('show');
    set(h,'FontSize',12);
    set(h,'FontName','Arial');

    %set line widths of profiles
    hs = get(gca,'Children');
    set(hs,'LineWidth',2);

    %set font size and typeface for axis labels
    h=gca;
    set(h,'FontSize',12);
    set(h,'FontName','Arial');

end
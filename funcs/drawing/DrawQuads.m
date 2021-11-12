function mArgsIn = DrawQuads(mArgsIn)
    quad=mArgsIn.GraphDB(mArgsIn.curGraph(1)).Stat.quad;
    posx=mArgsIn.GraphDB(mArgsIn.curGraph(1)).plotdata(:,1)>quad(1);
    posy=mArgsIn.GraphDB(mArgsIn.curGraph(1)).plotdata(:,2)>quad(2);
    quad1=sum(and(posx,posy))/length(posx)*100;
    quad2=sum(and(~posx,posy))/length(posx)*100;
    quad3=sum(and(~posx,~posy))/length(posx)*100;
    quad4=sum(and(posx,~posy))/length(posx)*100;
    % rescale quad to the axis scale
    switch mArgsIn.Display.graph_Xaxis
        case 'log'
            quadx=log10(quad(1));
        case 'logicle'
            quadx=asinh(quad(1)*mArgsIn.Display.graph_Xaxis_param(3)/2)/log(10);
        otherwise
            quadx=quad(1);
    end
    % rescale quad to the axis scale
    switch mArgsIn.Display.graph_Yaxis
        case 'ylog'
            quady=log10(quad(2));
        case 'ylogicle'
            quady=asinh(quad(2)*mArgsIn.Display.graph_Yaxis_param(3)/2)/log(10);
        otherwise
            quady=quad(2);
    end

    frame=axis;
    delete(findobj(gca,'Tag','quad'));
    line([frame(1),frame(2)],[quady,quady],'Color','k','Tag','quad');
    line([quadx,quadx],[frame(3),frame(4)],'Color','k','Tag','quad');
    axis(frame);
    text(frame(1)+(frame(2)-frame(1))*0.99,frame(3)+(frame(4)-frame(3))*0.99,[num2str(quad1),'%'],'BackgroundColor',[.7 .7 .7],'HorizontalAlignment','right','VerticalAlignment','top','Tag','quad');
    text(frame(1)+(frame(2)-frame(1))*0.01,frame(3)+(frame(4)-frame(3))*0.99,[num2str(quad2),'%'],'BackgroundColor',[.7 .7 .7],'HorizontalAlignment','left','VerticalAlignment','top','Tag','quad');
    text(frame(1)+(frame(2)-frame(1))*0.01,frame(3)+(frame(4)-frame(3))*0.01,[num2str(quad3),'%'],'BackgroundColor',[.7 .7 .7],'HorizontalAlignment','left','VerticalAlignment','bottom','Tag','quad');
    text(frame(1)+(frame(2)-frame(1))*0.99,frame(3)+(frame(4)-frame(3))*0.01,[num2str(quad4),'%'],'BackgroundColor',[.7 .7 .7],'HorizontalAlignment','right','VerticalAlignment','bottom','Tag','quad');
end
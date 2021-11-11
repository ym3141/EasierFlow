function uiUpdate_FigPropPanel(efdb, propPanel)
    props = efdb.Display;
    
    Yparam = flip(propPanel.Children(2).Children(1:3))';
    Xparam = flip(propPanel.Children(2).Children(4:6))';
    Yaxis = flip(propPanel.Children(2).Children(12).Children)';
    Yauto = propPanel.Children(2).findobj('Tag', 'AutoYAxis');
    Yprmhist = propPanel.Children(1).Children([5, 4, 3, 1])';
    
    XaxisBG = propPanel.Children(2).findobj('Tag', 'XaxisBG');
    YaxisBG = propPanel.Children(2).findobj('Tag', 'YaxisBG');
    
    Xauto = propPanel.Children(2).findobj('Tag', 'AutoXAxis');
    
    propPanel.Children(3).SelectedObject = propPanel.Children(3).findobj('String', props.graph_type);
    if strcmp(props.graph_type,'Histogram')
        set([Yparam,Yaxis([3,4]),Yauto], 'Enable','off');
        set(Yprmhist,'Enable','on');
    else
        set([Yaxis([3,4]),Yauto], 'Enable','on');
        set(Yprmhist,'Enable','off');
        if get(Yauto, 'Value') == 0
            set([Yparam, 'Enable', 'on']);
        end
    end
    
    XaxisBG.SelectedObject = XaxisBG.findobj('Tag', props.graph_Xaxis);
    YaxisBG.SelectedObject = YaxisBG.findobj('Tag', props.graph_Yaxis);
    
    Xauto.Value = props.XAuto;
    if Xauto.Value
        set(Xparam,'Enable','off');
    else
        set(Xparam,'Enable','on');
    end
    
    for i = [1,2,3]
        Yparam(i).String = props.graph_Yaxis_param(i);
        Xparam(i).String = props.graph_Xaxis_param(i);
    end
    
    Yprmhist(4).Value = props.smoothprm;
    
    
%     switch(props.graph_type)
%         case 
%     end
end
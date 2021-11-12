function efdb=CalculateMarkers(efdb)
    % Unknown function to Yitong

    if strcmp(efdb.Display.graph_type,'Histogram')
        for cgraph=get(efdb.Handles.GraphList,'Value')
            efdb.GraphDB(cgraph).Stat.quadp=[];
        end
    else
        for cgraph=get(efdb.Handles.GraphList,'Value')
            if isfield(efdb.GraphDB(cgraph).Stat,'quad')
                quad=efdb.GraphDB(cgraph).Stat.quad;
                posx=efdb.GraphDB(cgraph).plotdata(:,1)>quad(1);
                posy=efdb.GraphDB(cgraph).plotdata(:,2)>quad(2);
                quad1=sum(and(posx,posy))/length(posx)*100;
                quad2=sum(and(~posx,posy))/length(posx)*100;
                quad3=sum(and(~posx,~posy))/length(posx)*100;
                quad4=sum(and(posx,~posy))/length(posx)*100;
                %remove the next line
                efdb.GraphDB(cgraph).Stat.quadp=[quad1,quad2,quad3,quad4];
            else
                efdb.GraphDB(cgraph).Stat.quadp=[];
            end
        end
    end
    % Recalc the statistics
    if isfield(efdb.Handles,'statwin')
        Args=guidata(efdb.Handles.statwin);
        Args.fCalcStat(efdb);
    end
end
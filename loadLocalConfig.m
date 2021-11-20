function config=loadLocalConfig()
%% load system wide local settings, currently just root directary of fcs files
% if json file exist load it, if not prompt a window for the user to
% initialize the program (create the ./localConfig.json)
%%   
    if isfile('./localConfig.json')
        jsontxt = fileread('./localConfig.json');
        config = jsondecode(jsontxt);
        
    else
        disp('There seems no local config to load, prompting initialization window...');
        
        config = struct;
        
        scrsz=get(0,'ScreenSize');
        d = dialog('Position', [scrsz(3)/2, scrsz(4)/2, 350, 130], 'Name', 'Welcome to EasierFlow');
        txt = uicontrol('Parent', d,...
               'Style', 'text','Max', 2,...
               'Position', [20, 80, 300, 40],...
               'HorizontalAlignment', 'left', ...
               'String', ["It seems this is your first time starting up EasierFlow. Welcome!", ...
                          "Please tell us your root directary for fcs files: "]);

        DirDisp = uicontrol('Parent', d,...
               'Style','edit', 'enable', 'off',...
               'Position', [20, 60, 300, 20], ...
               'HorizontalAlignment', 'left', ...
               'String', './Root_directory_of_your_fcs_files (default = current directory)', ...
               'Callback', @edit_callback);

        btnBr = uicontrol('Parent', d,...
               'Position',[20 20 70 25],...
               'String','Browse',...
               'Callback', @browse_callback);
        
        btnOK = uicontrol('Parent', d,...
               'Position',[110 20 70 25],...
               'String', 'OK',...
               'Enable', 'off',...
               'Callback', @OK_callback);
           
        btnSk = uicontrol('Parent', d,...
               'Position',[200 20 70 25],...
               'String','Skip',...
               'Callback', 'delete(gcf)');

        % Wait for d to close before running to completion
        uiwait(d);        
        
        config.configVer = easierFlowInfo('version');
        if ~isfield(config, 'fcsFileDir')
            config.fcsFileDir = './';
        end
        
        config.fcsFileDir = strrep(config.fcsFileDir, '\', '/');
        
        jsonText = jsonencode(config);
        fid = fopen('./localConfig.json', 'w');
        fprintf(fid, jsonText); 
        fclose(fid);
    end
    
    function edit_callback(hObject, eventdata)
        input = get(hObject,'String');
        if isfolder(input)
            btnOK.Enable = 'on';
        else
            btnOK.Enable = 'off';
        end
            
    end
    
    function browse_callback(hObject, eventdata)
        slctPath = uigetdir();
        if slctPath
            config.fcsFileDir = slctPath; 
            DirDisp.String = config.fcsFileDir;
            btnOK.Enable = 'on';
        end
    end
    
    function OK_callback(hObject, eventdata)
        config.fcsFileDir = DirDisp.String;
        delete(d);
    end
end
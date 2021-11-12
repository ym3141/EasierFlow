function result=popupdlg(promptstring,liststring)

    figurename='EasyFlow';
    %        promptstring='Enter a fit variable name:';
    okstring='OK';
    cancelstring='Cancel';
    %        liststring={'a','b'};
    initialvalue=1;
    figwidth=160;
    border=15;
    sep=5;
    th=20;%text height
    bh=30;%button height

    fp = get(0,'defaultfigureposition');
    fp(3)=figwidth;
    fp(4)=border*2+th*2+2*sep+bh;

    fig_props = { ...
        'name'                   figurename ...
        'color'                  get(0,'defaultUicontrolBackgroundColor') ...
        'resize'                 'off' ...
        'numbertitle'            'off' ...
        'menubar'                'none' ...
        'windowstyle'            'modal' ...
        'visible'                'on' ...
        'createfcn'              ''    ...
        'position'               fp   ...
        'closerequestfcn'        'delete(gcbf)' ...
        };
    fig=figure(fig_props{:});

    prompt_text = uicontrol('style','text','string',promptstring,...
        'horizontalalignment','left',...
        'position',[border fp(4)-border-th fp(3)-2*border th]);

    popupmenu = uicontrol('style','popupmenu',...
        'position',[15 fp(4)-border-th-(th+sep) fp(3)-2*border th],...
        'string',liststring,...
        'backgroundcolor','w',...
        'tag','listbox',...
        'value',initialvalue, ...
        'callback', {@doPopupmenuClick});

    bw=(fp(3)-2*border-sep)/2;%button width
    ok_btn = uicontrol('style','pushbutton',...
        'string',okstring,...
        'position',[border border bw bh],...
        'callback',{@doOK});

    cancel_btn = uicontrol('style','pushbutton',...
        'string',cancelstring,...
        'position',[border+bw+sep border bw bh],...
        'callback',{@doCancel});

    set([fig, ok_btn, cancel_btn, popupmenu], 'keypressfcn', {@doKeypress});

    % make sure we are on screen
    movegui(fig)
    set(fig, 'visible','on'); drawnow;

    uicontrol(popupmenu);
    uiwait;

    function doKeypress(hobj,evnt)
        switch evnt.Key
            case 'escape'
                doCancel([],[]);
            case 'return'
                switch get(fig,'currentobj')
                    case cancel_btn
                        doCancel([],[]);
                    case {ok_btn, popupmenu}
                        doOK([],[]);
                end
        end
    end
    function doPopupmenuClick(hobj,evnt)
        
    end
    function doOK(hobj,evnt)
        result=get(popupmenu,'value');
        delete(gcbf)
    end
    function doCancel(hobj,evnt)
        result=[];
        delete(gcbf)
    end

end

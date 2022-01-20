classdef DataClass_Display
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        graph_type = 'Histogram'
        graph_Xaxis = 'log'
        graph_Xaxis_param = [0 Inf 1]
        graph_Yaxis = 'ylin'
        graph_Yaxis_param = 1
        XAuto = true
        YAuto = true
        smoothprm = 100
        GraphColor
    end
    
    methods
        function obj = DataClass_Display(paletteFile)
            mFile = load(paletteFile);
            obj.GraphColor=mFile.ColorMat;
        end
        
        function radioIdx = getRadioIdxs(obj, which)
            radioIdxs = [0, 0, 0];
            radioIdxs(1) = find(strcmp({'Histogram', 'Dot Plot', 'Colored Dot Plot', 'Contour', 'Filled Contour'}, obj.graph_type));
            radioIdxs(2) = find(strcmp({'lin', 'log', 'logicle'}, obj.graph_Xaxis));
            radioIdxs(3) = find(strcmp({'ylin', 'ylog', 'ylogicle'}, obj.graph_Yaxis));
            
            radioIdx = radioIdxs(which);
        end
    end
end


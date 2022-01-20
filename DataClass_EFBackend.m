classdef DataClass_EFBackend
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        version = 3.23
    end
    
    properties
        TubeDB DataClass_Tubes = DataClass_Tubes() 
        Handles = []
        GraphDB = []
        GatesDB = []
        GatesDBnew struct = struct()
        Display DataClass_Display = DataClass_Display('./asset/PlotColors.mat')
        TubeNames = {'None'}
        Statistics = []
        copy = []
        curGraph = []
        DBInfo = []
    end
    
    
    methods
        function obj = DataClass_EFBackend(localConfig)
            obj.DBInfo.localConfig = localConfig;
            obj.DBInfo.Path = localConfig.fcsFileDir;
            
            obj.Statistics.ShowInStatView=[true(1,5),false(1,4)];
        end
    end
end


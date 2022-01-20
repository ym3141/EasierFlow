% The entry point of EasierFlow
% All non-gui things about the main program should go here

localConfig = loadLocalConfig();
efdb = DataClass_EFBackend(localConfig);

efGUI(efdb);
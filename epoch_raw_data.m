function epochs = epoch_raw_data(raw_data,args)

switch args.settings.project
    case 'NeuroSyntax2'
        epochs = epoch_neurosyntax2data(raw_data,args);
end

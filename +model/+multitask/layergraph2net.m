fun = @(dlX) model.multitask.model_multitask(dlX,parameters,false,state);
lgraph = functionToLayerGraph(fun,dlX);

    layers=imageInputLayer([1 599 1],'Name','Input','Normalization','none');
    lgraph = addLayers(lgraph,layers);
    lgraph = connectLayers(lgraph,'Input','conv_1');
    layers = regressionLayer('Name','routput_1');
    lgraph = addLayers(lgraph,layers);
    layers = regressionLayer('Name','routput_2');
    lgraph = addLayers(lgraph,layers);
    lgraph = connectLayers(lgraph,'fc_1','routput_1');
    lgraph = connectLayers(lgraph,'fc_2','routput_2');

    
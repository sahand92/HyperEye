function [gradients,state,loss] = modelGradients(dlX,T1,T2,T3,parameters,state)

doTraining = true;
[dlY1,dlY2,dlY3,state] = model.multitask.model_multitask(dlX,parameters,doTraining,state);

loss_1 = mse(dlY1,T1);
loss_2 = mse(dlY2,T2);
loss_3 = crossentropy(dlY3,T3);
 
loss = loss_1 + loss_2 + 0.1*loss_3;
gradients = dlgradient(loss,parameters);

end
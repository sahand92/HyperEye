function [M, P, T] = predict_fnc(in) %#codegen

mynet = load('net_multitask_grains_net');

% pass in input   
[M, P, T] = predict(mynet.net_multi,in); 
function [mdl, rmse] = nn_power(Xy)
rng('default')
mdl = fitrnet(Xy,'mean_engine_power','Standardize',true,'Activations','relu','Lambda',7.67,'LayerSizes',[299 8]);
rmse = sqrt(mean( (Xy.mean_engine_power-mdl.predict(Xy)).^2 ));
end
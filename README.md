# Machine Learning Engineering Project Template
This project is a template for creating a Machine Learning Serving API and ETL

## Dependencies

Docker and docker-compose are the only requirements for 
executing tests and running the ETL and API 

It is necessary to clone the following repo:

`git clone --branch setup https://github.com/Fernando-Freire/MLFlow_docker_compose_template.git`

and execute the commands specified in that repository's README.

Then, run `mlflow run https://github.com/Fernando-Freire/Machine_Learning_Project_Template.git

After that the models should be on MLFlow ready to be served.

## Organization

This project is organized to show two ways of serving the model, 
so it is separated into two parts:
 - The ETL, which should download the MLFlow model, the raw data, 
 then pre-process it, apply the model to all the data, and save it
 on redis database.
 - The API, which should offer health checks methods and a POST
 method for the final user to consult the model result based in input data.
 The API should first consult redis for ready data and also download
 the MLFlow model and pass input data through, store it and return to the user
 for data that has never been apllied to the model.




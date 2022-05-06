from typing import Dict

import mlflow



class MLFlow():
    def __init__(self, mlflow_uri: str, word_embedding: str, model_algorithm: str):
        mlflow.set_tracking_uri(mlflow_uri)
        mlflow.set_experiment(experiment_name=word_embedding + "-" + model_algorithm)

    @staticmethod
    def import_word_embedding_model(word_embedding: str, category: str):

        # models:/<model_name>/<model_version>
        # models:/<model_name>/<stage>
        # s3://my_bucket/path/to/model

        model_uri = "models:/"+word_embedding + "-" + category+"/"+"1"
        if word_embedding == "bow" or word_embedding == "tfidf":
            model = mlflow.sklearn.load_model(model_uri=model_uri)
        elif (
            word_embedding == "Word2Vec"
            or word_embedding == "Doc2Vec"
            or word_embedding == "FastText"
        ):
            model = mlflow.pyfunc.load_model(model_uri=model_uri)

        return model

    @staticmethod
    def import_training_model(model_algorithm: str, category: str):
        model_uri = "models:/"+model_algorithm + "-" + category+"/"+"1"
        if (
            model_algorithm == "DecisionTree"
            or model_algorithm == "ExtraTreeClassifier"
        ):
            model = mlflow.sklearn.load_model(model_uri=model_uri)
        elif model_algorithm == "lightgbm":
            model = mlflow.lightgbm.load_model(model_uri=model_uri)

        return model

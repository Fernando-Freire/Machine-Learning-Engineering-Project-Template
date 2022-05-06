


from typing import Dict

from sklearn.metrics import classification_report
from api.adapters.mlflow import MLFlow
from api.adapters.pandas import Pandas
from api.core.domain import PreProcessedData


word_embedding = "Word2Vec"
model_algorithm = "lgb"


@staticmethod
def get_report(
    test_predictions, test_data: PreProcessedData, category_name: str
) -> Dict:
    report = classification_report(
        test_predictions,
        test_data.target,
        output_dict=True,
        target_names=["non-category", "is-cateogory"],
    )

    return _flat_dict(report=report)

@staticmethod
def _flat_dict(report: Dict) -> Dict:

    [flat_dict] = pd.json_normalize(report, sep="_").to_dict(orient="records")

    return flat_dict

class MainConfig(BaseSettings):
    train_data_s3_path: str
    train_data_file_name: str
    mlflow_uri: str
    s3_uri: str
    aws_access_key_id: str
    aws_secret_access_key: str

config = MainConfig()

model_versioner = MLFlow(
        mlflow_uri=config.mlflow_uri,
        word_embedding=word_embedding,
        model_algorithm=model_algorithm,
    )


storage_options = {
        "key": config.aws_access_key_id,
        "secret": config.aws_secret_access_key,
        "client_kwargs": {"endpoint_url": config.s3_uri},
    }
filepath = config.train_data_s3_path + config.train_data_file_name

data = Pandas().get_dataset_splited()

metrics_dict = []

for category in Pandas().get_classes(storage_options=storage_options, filepath=filepath):

    train_data, test_data = Pandas.get_dataset_splited(
            storage_options, filepath, class_name=category, test_size=0
        )
    pre_processed_train_data: PreProcessedData = MLFlow.import_word_embedding_model(word_embedding=word_embedding).predict(train_data.features)
    train_predictions = MLFlow.import_training_model(model_algorithm=model_algorithm).predict(pre_processed_train_data.feature_matrix)

    pre_processed_test_data: PreProcessedData = MLFlow.import_word_embedding_model(word_embedding=word_embedding).predict(test_data.features)
    test_predictions = MLFlow.import_training_model(model_algorithm=model_algorithm).predict(pre_processed_test_data.feature_matrix)

    training_report = get_report(
            test_predictions, train_predictions, category_name=category
        )
    metrics_dict[category] = training_report
    print(training_report)
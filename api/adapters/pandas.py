from typing import Dict, List, Tuple

import pandas as pd
from sklearn.model_selection import train_test_split

from api.core.domain import DataXY


class Pandas():
    @staticmethod
    def get_classes(storage_options: Dict, filepath: str, **kwargs) -> List[str]:
        df = Pandas._read_data_from_s3(storage_options, filepath)
        return df["category"].unique().tolist()

    @staticmethod
    def _get_data(storage_options: Dict, filepath: str, **kwargs) -> pd.DataFrame:
        df = Pandas._read_data_from_s3(storage_options, filepath)
        df = Pandas._basic_preprocessing(df)
        df = Pandas._one_hot_encoding(df)
        return df

    @staticmethod
    def get_dataset_splited(
        storage_options: Dict,
        filepath: str,
        class_name: str,
        test_size: float,
        **kwargs
    ) -> tuple[DataXY, DataXY]:
        data = Pandas._get_data(storage_options, filepath)
        return Pandas._split_data_set(
            raw_data=data, y_name=class_name, test_size=test_size
        )

    @staticmethod
    def _read_data_from_s3(storage_options: Dict, filepath: str) -> pd.DataFrame:
        return pd.read_csv(filepath_or_buffer=filepath, storage_options=storage_options)

    @staticmethod
    def _basic_preprocessing(df: pd.DataFrame) -> pd.DataFrame:
        df = df.drop_duplicates("product_id")
        df = df.astype({"concatenated_tags": str, "title": str})
        df["text"] = df[["concatenated_tags", "title"]].apply(
            lambda x: " ".join(x), axis=1
        )
        df = df.filter(["text", "category"])
        return df

    @staticmethod
    def _one_hot_encoding(df: pd.DataFrame) -> pd.DataFrame:
        df_one = pd.get_dummies(df.category)
        return pd.concat([df, df_one], axis=1)

    @staticmethod
    def _split_data_set(
        raw_data: pd.DataFrame, y_name: str, test_size: float
    ) -> Tuple[DataXY, DataXY]:
        if test_size > 0:
            X_train, X_test, Y_train, Y_test = train_test_split(
                raw_data["text"],
                raw_data[y_name],
                test_size=test_size,
                shuffle=True,
                random_state=15,
            )
        else:
            X_train = raw_data["text"].copy()
            Y_train = raw_data[y_name].copy()
            X_test = X_train.copy()
            Y_test = Y_train.copy()

        return DataXY(features=pd.Series(X_train), target=Y_train), DataXY(
            features=pd.Series(X_test), target=Y_test
        )

import pandas as pd
from numpy import ndarray
from pydantic import BaseModel


class DataXY(BaseModel):
    features: pd.Series
    target: pd.Series

    class Config:
        arbitrary_types_allowed = True


class PreProcessedData(BaseModel):
    feature_matrix: ndarray
    target: pd.Series

    class Config:
        arbitrary_types_allowed = True


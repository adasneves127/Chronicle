from fastapi import FastAPI

app = FastAPI(
    title="Chronicle",
    version="0.0.1"
)

import src.api.main
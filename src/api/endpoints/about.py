from apiApp import app

def get_about_information():
    return {
        "SystemName": app.title,
        "KnowledgeBase": "",
        "Website": "",
        "Sales": {},
        "Support": {},
        "APIVersion": app.version
    }

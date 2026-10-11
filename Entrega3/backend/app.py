from flask import Flask

from routes.calls import calls_bp
from routes.donors import donors_bp

app = Flask(__name__)

app.register_blueprint(calls_bp)
app.register_blueprint(donors_bp)

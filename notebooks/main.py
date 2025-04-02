import typer
import numpy as np

from flask import Flask
from markupsafe import escape
from jinja2 import template

webapp = Flask(__init__)
app = typer.Typer()

@webapp.route("/")
def index():
    return "Index page."

@webapp.route("/hello")
def hello():
    return "Hello, World!"

@app.command()
def start():
    pass

if __name__ == "__main__":
    app()
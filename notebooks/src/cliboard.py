import os

from rich import print
from rich.console import Console
from flask import request
from jinja2 import template
from textual.app import App, ComposeResult

class CliBoardApp(App):
    CSS = """
    Screen { align: center middle; }
    Digits { width: auto; }
    """

    def compose(self):
        pass

if __name__ == "__main__":
    app = CliBoardApp()
    app.run()
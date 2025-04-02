import typer

from rich import print

app = typer.Typer()

@app.command()
def now(name):
    print("""
        [blue][bold]Welcome to the MathAsScriting generator for MakinLang![/bold][/blue]    
""")

if __name__ == "__main__":
    app()
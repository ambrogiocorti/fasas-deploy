"""Entrypoint per l'hosting Python Enzonic (MAIN_FILE=main.py)."""

import os
from pathlib import Path


if __name__ == "__main__":
    os.chdir(Path(__file__).resolve().parent)
    os.execvp("bash", ["bash", "scripts/avvia_enzonic.sh"])

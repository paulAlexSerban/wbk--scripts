setup_dev_env:
	@curl -LsSf https://astral.sh/uv/install.sh | sh
	@uv sync
	@nvm use

clean_notebooks:
	@find . -name "*.ipynb" -not -path "./.venv/*" -exec uv run jupyter nbconvert --clear-output --inplace {} \;

test:
	@echo "Running tests..."
	@uv run pytest --maxfail=1 --disable-warnings -v
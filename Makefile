all: env jupyter serve

## Install Dependencies
env: env.yaml
	CONDA_SUBDIR=osx-64 mamba env update -p ./envs -f env.yaml --prune
	@echo ">>> Updated conda env. Activate with:\nconda activate ./envs"

# Serve the website
serve:
	quarto preview --no-browser

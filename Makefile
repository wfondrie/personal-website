IPYNB_POSTS = $(wildcard content/post/*.ipynb)

all: env jupyter serve

## Install Dependencies
env: env.yaml
	CONDA_SUBDIR=osx-64 mamba env update -p ./envs -f env.yaml --prune
	@echo ">>> Updated conda env. Activate with:\nconda activate ./envs"

# Serve the website
serve:
	quarto preview --no-browser

# Convert all Jupyter notebooks:
jupyter: $(IPYNB_POSTS:.ipynb=.md)

# Convert individual Jupyter notebooks:
content/post/%.md static/post/%_files: content/post/%.ipynb
	jupyter nbconvert --to markdown $< --NbConvertApp.output_files_dir=../../static/post/${*}_files
	sed -i'' -e 's/(..\/..\/static\//(\//g' content/post/${*}.md

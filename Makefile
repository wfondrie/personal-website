IPYNB_POSTS = $(wildcard content/post/*.ipynb)

all: env jupyter serve

## Install Dependencies
env: env.yaml
ifeq (conda env list | grep "\W*$(realpath ./envs)",)
	conda env create -p ./envs -f env.yaml
	@echo ">>> New conda env created. Activate with:\nconda activate ./envs"
else
	conda env update -p ./envs -f env.yaml --prune
	@echo ">>> Updated conda env. Activate with:\nconda activate ./envs"
endif

# Serve the website
serve:
	R -e "blogdown::serve_site(port=4004)"

# Convert all Jupyter notebooks:
jupyter: $(IPYNB_POSTS:.ipynb=.md)

# Convert individual Jupyter notebooks:
content/post/%.md static/post/%_files: content/post/%.ipynb
	jupyter nbconvert --to markdown $< --NbConvertApp.output_files_dir=../../static/post/${*}_files
	sed -i'' -e 's/(..\/..\/static\//(\//g' content/post/${*}.md

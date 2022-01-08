# How to use R packages in Python

As a data scientist working with biological data, the programming language I use on a daily basis is Python. However, I sometimes find myself needing to use an R package, such as those provided by  [Bioconductor](https://www.bioconductor.org/). For me this is most often the excellent [MSstats](https://msstats.org/) R package from Meena Choi ([@MeenaChoi](https://twitter.com/MeenaChoi)) and folks in Olga Vitek's lab ([@olgavitek](https://twitter.com/olgavitek)). Although it has always been possible to write R scripts alongside my Python scripts and Jupyter notebooks, I find it cumbersome to switch back and forth between them, particularly when it involves generating unnecessary intermediate files.

In this post I'll show you how I use the MSstats R package from within a Python script or Jupyter notebook, providing an example for how you can use the occasional R package in your own analyses. This post will assume that you're comfortable programming in Python and that you're familiar with the Pandas, NumPy, and Matplotlib Python packages.[^1] Additionally, I'll assume that you have some familiarity with R programming, since you're reading this post. I'll be using proteomics data as an example, but understanding it is not critical for learning from this post.

[^1]:If these are not familiar and you want to learn, I recommend the ["Plotting and Programming in Python"](http://swcarpentry.github.io/python-novice-gapminder/) Software Carpentry course. 

This entire post is available as a Jupyter notebook on GitHub: https://github.com/wfondrie/msstats-demo

## Setup
If you want to follow along with this post, you'll need to install a few things. I use conda as my package manager for Python and R whenever possible.[^2] First, we'll create a new conda environment, `msstats-demo`, and install the necessary packages from the [bioconda](https://bioconda.github.io/) and [conda-forge](https://conda-forge.org/) channels. I've created a conda environment YAML file that looks like this:

[^2]: If you need to install conda, I'd recommend the [miniconda distribution](https://docs.conda.io/en/latest/miniconda.html).

```yaml
# https://github.com/wfondrie/msstats-demo/environment.yaml
name: msstats-demo
channels:
  - bioconda
  - conda-forge
  - defaults
dependencies:
  - ppx>=1.2.5                   # For downloading data
  - bioconductor-msstats==4.2.0  # The MSstats R package
  - notebook                     # Jupyter notebook
  - ipywidgets                   # For progress bars
  - pandas                       # DataFrames for tabular data
  - numpy                        # To do math
  - matplotlib                   # The de facto standard Python plotting library
  - seaborn                      # Make matplotlib plots pretty
  - rpy2                         # For using R packages in Python!
```

Let's start by creating the conda environment from this file:
```bash
conda env create -f https://raw.githubusercontent.com/wfondrie/msstats-demo/main/environment.yaml
```

Then activate our new conda environment:  
```bash
conda activate msstats-demo
```

Now let's fire up Python. If you want to use a [Jupyter notebook](https://jupyter.org/), you can launch it with:
```bash
jupyter notebook 
```

Then click `New` &#8594; `Python 3 (ipykernel)` to open a new notebook. 

## Getting started

For this post, we're going to reproduce an analysis of the the dataset from [Selevsek et al](https://doi.org/10.1074/mcp.M113.035550) as performed in the [MassIVE.quant paper](https://doi.org/10.1038/s41592-020-0955-0). We'll use Python to download and read the data, process that data with the MSstats R package, then recreate the volcano plot in Figure 2j with Python. Let's start by loading the libraries we'll need into our Python session:


```python
import ppx
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# These will let us use R packages:
from rpy2.robjects.packages import importr
from rpy2.robjects import pandas2ri

# Convert pandas.DataFrames to R dataframes automatically.
pandas2ri.activate()
```

The [rpy2](https://rpy2.github.io/) Python package will perform the magic that allows us to use R packages in our Python session. The `importr` function give us the power to import R packages and `pandas2ri`---along with the subsequent `pandas2ri.activate()` line---will allow our Pandas DataFrames to be automically converted into R data frames when used as input to an R function.

We also need to set up a plotting style that looks nice on my website:


```python
# Set plotting theme:
primary = "#404040"
accent = "#24B8A0"
pal = sns.color_palette([primary, accent])
style = {
    "axes.edgecolor": primary,
    "axes.labelcolor": primary,
    "text.color": primary,
    "xtick.color": primary,
    "ytick.color": primary,
}

sns.set_palette(pal)
sns.set_context("talk")
sns.set_style("ticks", style)
```

Now let's download the dataset from the [MassIVE mass spectrometry data repository](https://massive.ucsd.edu/ProteoSAFe/static/massive.jsp) under the accession RMSV000000251. We'll use the [ppx Python package](https://ppx.readthedocs.io) to do this: 


```python
proj = ppx.find_project("RMSV000000251")

# The proteomics data:
quant_file = "2019-06-03_mnchoi_bb4aeafb/quant/Selevsek2015-MSstats-input-90nodup-i.csv"

# The annotation file:
annot_file = "2019-06-03_mnchoi_bb4aeafb/metadata/Selevsek2015_DIA_Skyline_all_annotation.csv"

# The local paths to them:
quant_path, annot_path = proj.download([quant_file, annot_file], silent=True)
```

We can then read the proteomics data into our Python session using Pandas:


```python
quant_df = pd.read_csv(quant_path, dtype={"StandardType": str})
quant_df.head() # View the first five rows
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>ProteinName</th>
      <th>PeptideSequence</th>
      <th>PeptideModifiedSequence</th>
      <th>PrecursorCharge</th>
      <th>PrecursorMz</th>
      <th>FragmentIon</th>
      <th>ProductCharge</th>
      <th>ProductMz</th>
      <th>IsotopeLabelType</th>
      <th>Condition</th>
      <th>BioReplicate</th>
      <th>FileName</th>
      <th>Area</th>
      <th>StandardType</th>
      <th>Truncated</th>
      <th>DetectionQValue</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>Biognosys standards</td>
      <td>LGGNEQVTR</td>
      <td>LGGNEQVTR</td>
      <td>2</td>
      <td>487.256705</td>
      <td>y7</td>
      <td>1</td>
      <td>803.400606</td>
      <td>light</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>nselevse_L120412_001_SW.wiff</td>
      <td>353982.43750</td>
      <td>iRT</td>
      <td>False</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1</th>
      <td>Biognosys standards</td>
      <td>LGGNEQVTR</td>
      <td>LGGNEQVTR</td>
      <td>2</td>
      <td>487.256705</td>
      <td>y7</td>
      <td>1</td>
      <td>803.400606</td>
      <td>light</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>nselevse_L120412_002_SW.wiff</td>
      <td>408376.46875</td>
      <td>iRT</td>
      <td>False</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Biognosys standards</td>
      <td>LGGNEQVTR</td>
      <td>LGGNEQVTR</td>
      <td>2</td>
      <td>487.256705</td>
      <td>y7</td>
      <td>1</td>
      <td>803.400606</td>
      <td>light</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>nselevse_L120412_003_SW.wiff</td>
      <td>437152.65625</td>
      <td>iRT</td>
      <td>False</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Biognosys standards</td>
      <td>LGGNEQVTR</td>
      <td>LGGNEQVTR</td>
      <td>2</td>
      <td>487.256705</td>
      <td>y7</td>
      <td>1</td>
      <td>803.400606</td>
      <td>light</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>nselevse_L120412_004_SW.wiff</td>
      <td>344150.12500</td>
      <td>iRT</td>
      <td>False</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Biognosys standards</td>
      <td>LGGNEQVTR</td>
      <td>LGGNEQVTR</td>
      <td>2</td>
      <td>487.256705</td>
      <td>y7</td>
      <td>1</td>
      <td>803.400606</td>
      <td>light</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>nselevse_L120412_005_SW.wiff</td>
      <td>383755.62500</td>
      <td>iRT</td>
      <td>False</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
</div>



We also need to read the annotation data using Pandas:


```python
annot_df = pd.read_csv(annot_path)
annot_df.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Condition</th>
      <th>BioReplicate</th>
      <th>Run</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>T000</td>
      <td>1</td>
      <td>nselevse_L120412_001_SW.wiff</td>
    </tr>
    <tr>
      <th>1</th>
      <td>T000</td>
      <td>2</td>
      <td>nselevse_L120412_002_SW.wiff</td>
    </tr>
    <tr>
      <th>2</th>
      <td>T000</td>
      <td>3</td>
      <td>nselevse_L120412_003_SW.wiff</td>
    </tr>
    <tr>
      <th>3</th>
      <td>T015</td>
      <td>1</td>
      <td>nselevse_L120412_004_SW.wiff</td>
    </tr>
    <tr>
      <th>4</th>
      <td>T015</td>
      <td>2</td>
      <td>nselevse_L120412_005_SW.wiff</td>
    </tr>
  </tbody>
</table>
</div>



Finally, we need to create a contrast matrix that will define the comparisons we want to test with MSstats:


```python
cols = annot_df["Condition"].unique()
cols.sort()

rows = ["T1-T0", "T2-T0", "T3-T0", "T4-T0", "T5-T0"]

contrasts = [
    [-1, 1, 0, 0, 0, 0],
    [-1, 0, 1, 0, 0, 0],
    [-1, 0, 0, 1, 0, 0],
    [-1, 0, 0, 0, 1, 0],
    [-1, 0, 0, 0, 0, 1],
]

contrast_df = pd.DataFrame(
    contrasts,
    columns=cols,
    index=rows,
)

contrast_df
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>T000</th>
      <th>T015</th>
      <th>T030</th>
      <th>T060</th>
      <th>T090</th>
      <th>T120</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>T1-T0</th>
      <td>-1</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>T2-T0</th>
      <td>-1</td>
      <td>0</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>T3-T0</th>
      <td>-1</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>T4-T0</th>
      <td>-1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>0</td>
    </tr>
    <tr>
      <th>T5-T0</th>
      <td>-1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
    </tr>
  </tbody>
</table>
</div>



## Run MSstats in Python using rpy2

Now for the fun part: let's run MSstats without leaving our Python session. Just like if we were using R directly, we first need to import the libraries that we'll be using. This looks a little different using rpy2, but ultimately we assign the imported R package to a variable that we can use like any other Python package. Here, we import MSstats:


```python
MSstats = importr("MSstats")
```

Next, we'll perform our MSstats data processing. Note that each of these functions actually call the underlying MSstats R package. The rpy2 Python package does all of the work tranforming our Pandas DataFrames (`quant_df`, `annot_df`, and `contrast_df`) into R data frames that MSstats can use. When each function is complete, it returns an R object. Fortunately, we've setup rpy2 to automatically convert R data frames back into Pandas DataFrames, allowing us to use the results seamlessly. The final output returned by MSstats in this analysis (`results` below)  will be a Pandas DataFrame containing the p-values for each protein for contrasts that we specified in our contrast matrix (`contrast_df`).

If you're following along, this next step may take a few minutes. Go ahead and enjoy a cup of coffee or your favorite beverage while it's running.


```python
raw = MSstats.SkylinetoMSstatsFormat(
    quant_df,
    annotation=annot_df,
    removeProtein_with1Feature=True,
    use_log_file=False,
)

processed = MSstats.dataProcess(
    raw, 
    use_log_file=False,
)

# Note that the 'contrast_matrix' argument below
# is actually 'contrast.matrix' in the MSstats
# R package. rpy2 swaps '.' for '_' so that it
# becomes a valid Python variable name.
results, *_ = MSstats.groupComparison(
    contrast_matrix=contrast_df, 
    data=processed,
    use_log_file=False,
)
```

    INFO  [2022-01-07 15:30:17] ** Raw data from Skyline imported successfully.
    INFO  [2022-01-07 15:31:07] ** Raw data from Skyline cleaned successfully.
    INFO  [2022-01-07 15:31:07] ** Using provided annotation.
    INFO  [2022-01-07 15:31:07] ** Run labels were standardized to remove symbols such as '.' or '%'.
    INFO  [2022-01-07 15:31:07] ** The following options are used:
      - Features will be defined by the columns: IsotopeLabelType, PeptideSequence, PrecursorCharge, FragmentIon, ProductCharge
      - Shared peptides will be removed.
      - Proteins with a single feature will be removed.
      - Features with less than 3 measurements across runs will be removed.
    INFO  [2022-01-07 15:31:07] ** Rows with values of StandardType equal to iRT are removed 
    INFO  [2022-01-07 15:31:08] ** Intensities with values of Truncated equal to TRUE are replaced with NA
    INFO  [2022-01-07 15:31:11] ** Intensities with values smaller than 0.01 in DetectionQValue are replaced with 0
    INFO  [2022-01-07 15:31:11] ** Sequences containing DECOY, Decoys are removed.
    INFO  [2022-01-07 15:31:16] ** Features with all missing measurements across runs are removed.
    INFO  [2022-01-07 15:31:19] ** Shared peptides are removed.
    INFO  [2022-01-07 15:31:28] ** Multiple measurements in a feature and a run are summarized by summaryforMultipleRows: sum
    INFO  [2022-01-07 15:31:28] ** Features with one or two measurements across runs are removed.
    INFO  [2022-01-07 15:31:30] Proteins with a single feature are removed.
    INFO  [2022-01-07 15:31:34] ** Run annotation merged with quantification data.
    INFO  [2022-01-07 15:31:35] ** Features with one or two measurements across runs are removed.
    INFO  [2022-01-07 15:31:36] ** Fractionation handled.
    INFO  [2022-01-07 15:31:39] ** Updated quantification data to make balanced design. Missing values are marked by NA
    INFO  [2022-01-07 15:31:40] ** Finished preprocessing. The dataset is ready to be processed by the dataProcess function.
    INFO  [2022-01-07 15:31:44] ** There are 499195 intensities which are zero or less than 1. These intensities are replaced with 1
    INFO  [2022-01-07 15:31:47] ** Log2 intensities under cutoff = 7.4056  were considered as censored missing values.
    INFO  [2022-01-07 15:31:47] ** Log2 intensities = NA were considered as censored missing values.
    INFO  [2022-01-07 15:31:48] ** Use all features that the dataset originally has.
    INFO  [2022-01-07 15:31:48] 
     # proteins: 2189
     # peptides per protein: 1-157
     # features per peptide: 1-6
    INFO  [2022-01-07 15:31:48] 
                        T000 T015 T030 T060 T090 T120
                 # runs    3    3    3    3    3    3
        # bioreplicates    3    3    3    3    3    3
     # tech. replicates    1    1    1    1    1    1
    INFO  [2022-01-07 15:31:50] Some features are completely missing in at least one condition:  
     KEGLDGHR_2_y3_1,
     KEGLDGHR_2_y4_1,
     KEGLDGHR_2_y5_1,
     KEGLDGHR_2_y7_1,
     VQHPNIVNLLDSFVEPISK_3_b8_1 ...
    INFO  [2022-01-07 15:31:50]  == Start the summarization per subplot...
      |======================================================================| 100%
    INFO  [2022-01-07 15:58:26]  == Summarization is done.
    INFO  [2022-01-07 15:58:34]  == Start to test and get inference in whole plot ...
      |======================================================================| 100%
    INFO  [2022-01-07 15:59:19]  == Comparisons for all proteins are done.


Now that the process is complete, we can verify that `results` is a Pandas DataFrame containing our MSstats results:


```python
results.head()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Protein</th>
      <th>Label</th>
      <th>log2FC</th>
      <th>SE</th>
      <th>Tvalue</th>
      <th>DF</th>
      <th>pvalue</th>
      <th>adj.pvalue</th>
      <th>issue</th>
      <th>MissingPercentage</th>
      <th>ImputationPercentage</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>1</th>
      <td>Q0250</td>
      <td>T1-T0</td>
      <td>0.001292</td>
      <td>0.111103</td>
      <td>0.011625</td>
      <td>10</td>
      <td>0.990953</td>
      <td>0.995633</td>
      <td>None</td>
      <td>0.033333</td>
      <td>0.033333</td>
    </tr>
    <tr>
      <th>2</th>
      <td>Q0250</td>
      <td>T2-T0</td>
      <td>-0.106017</td>
      <td>0.111103</td>
      <td>-0.954230</td>
      <td>10</td>
      <td>0.362464</td>
      <td>0.533674</td>
      <td>None</td>
      <td>0.066667</td>
      <td>0.066667</td>
    </tr>
    <tr>
      <th>3</th>
      <td>Q0250</td>
      <td>T3-T0</td>
      <td>-0.123694</td>
      <td>0.111103</td>
      <td>-1.113334</td>
      <td>10</td>
      <td>0.291610</td>
      <td>0.442217</td>
      <td>None</td>
      <td>0.100000</td>
      <td>0.100000</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Q0250</td>
      <td>T4-T0</td>
      <td>0.267058</td>
      <td>0.111103</td>
      <td>2.403706</td>
      <td>10</td>
      <td>0.037080</td>
      <td>0.111271</td>
      <td>None</td>
      <td>0.033333</td>
      <td>0.033333</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Q0250</td>
      <td>T5-T0</td>
      <td>0.242798</td>
      <td>0.111103</td>
      <td>2.185348</td>
      <td>10</td>
      <td>0.053757</td>
      <td>0.120164</td>
      <td>None</td>
      <td>0.033333</td>
      <td>0.033333</td>
    </tr>
  </tbody>
</table>
</div>



We've successfully run MSstats without leaving our Python session!

## Reproduce a figure panel from the paper

The only task left is reproduce a panel from a figure in the MassIVE.quant paper. We'll recreate the volcano plot from Figure 2j and see how close our results are to the original.[^3] However, we'll make this plot using [seaborn](https://seaborn.pydata.org/) and [matplotlib](https://matplotlib.org/) in our Python session!

[^3]: I haven't included the original figure for copyright reasons.


```python
# Filter the results for the points we want to plot
results = results.loc[results["adj.pvalue"] > 0, :]
results = results.loc[results["Label"] == "T5-T0", :]
results["accepted"] = results["adj.pvalue"] <= 0.05
results["neg_log_pvalue"] = -np.log10(results["adj.pvalue"])

# Get the number of up and down-regulated proteins
n_up = ((results["log2FC"] > 0) & results["accepted"]).sum()
n_down = ((results["log2FC"] < 0) & results["accepted"]).sum()

# Create the figure
plt.figure()

# Create the Scatter plot
sns.scatterplot(
    data=results, 
    x="log2FC", 
    y="neg_log_pvalue",
    hue="accepted",
    legend=False,
    s=20
)

# Add annotations
plt.text(
    x=0.02, 
    y=0.98, 
    s=f"Up: {n_up}\nDown: {n_down}", 
    transform=plt.gca().transAxes,
    va="top",
)

# Add the horizontal line
plt.axhline(-np.log10(0.05), linestyle="dashed", zorder=0)

# Add labeling
plt.xlabel("log2 fold change")
plt.ylabel("-log10(adjusted p-value)")
plt.title("Skyline:all")

# Set the axes limits
plt.ylim(0, 8)
plt.xlim(-4, 4)

# Show the plot
plt.show()
```


    
![png](/post/2022-01-08-how-to-us-r-packages-in-python_files/2022-01-08-how-to-us-r-packages-in-python_22_0.png)
    


This looks pretty close to the original to me, particularly considering that we didn't make any attempt to match our software versions with the original analysis. The number of up and down-regulated proteins is nearly identical, with our analysis finding one fewer down-regulated protein than in the original.

## Conclusion

The rpy2 Python package provides a pretty convenient way to use the occassional R package in Python, and I've shown you how to use it to run MSstats. Finally, I'll leave you with this: if you want to use the occasional Python package in R, try the [reticulate](https://rstudio.github.io/reticulate/) R package.

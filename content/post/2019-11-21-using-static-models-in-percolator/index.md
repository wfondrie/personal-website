---
title: Using Static Models in Percolator
author: William E. Fondrie
date: '2019-11-23'
slug: using-static-models-in-percolator
---

*I've written this blog post as a short companion piece to my [newest manuscript](https://doi.org/10.1101/849331), "A machine learning strategy that leverages large datasets to boost statistical power in small-scale experiments," which is now available on bioRxiv. This post assumes you have a basic familiarity with proteomics database searches, Percolator, and using a command line.*

[Percolator](http://percolator.ms) is a post-processing tool that improves the sensitivity of peptide detection in proteomics experiments using a semi-supervised machine learning algorithm. In a nutshell, Percolator learns how to combine different features from your database search results to better discriminate between good and bad PSMs.[^1] In this post I'm going to describe how to use the new "static model" operating mode for Percolator and mention some best practices to follow. Let's get started!

[^1]: I plan to write an in-depth post on how Percolator works at some point in the future.

## What are static models?
Normally, Percolator dynamically learns its models from the dataset you wish to analyze by executing its algorithm in a 3-fold cross-validation scheme[^2]: the dataset is split into three parts, where two parts are used to train a model and the held-out part is re-scored using the learned model. The good news is that these details are taken care of internally by Percolator, making it easy to analyze an experiment (Figure 1). This dynamic modeling approach is robust for the normal size of proteomics experiments, but may lead to unwanted variability and reduced power when experiments are small.[^3]

[^2]: See [Granholm *et al.*, 2012](https://doi.org/10.1186/1471-2105-13-S16-S3).
[^3]: See [Fondrie and Noble, 2019](https://doi.org/10.1101/849331).

![*Figure 1. How a Percolator analysis is normally performed.*](/images/std_percolator.svg)  

As an alternative, we've implemented support for a more traditional machine learning paradigm within Percolator: learn a model from a training dataset and use it to evaluate a new experiment (Figure 2). This is what we call the "static model" approach, because the model is unaltered after it is learned. Static models allow you to use a large training dataset to learn a good model and apply it to new experiments. This approach is particularly useful when an experiment is too small to robustly use Percolator's normal, dynamic modeling method. Additionally, static models are useful when experiments need to be analzyed in a consistent manner, because the same Percolator model can be used evaluate multiple experiments.

![*Figure 2. How a Percolator analysis is performed with static models.*](/images/static_percolator.svg)

Now that you know what static models are, let's walk through how you can create and use a static model of your own.

## What you'll need

### Software
We've implemented support for static models as of [Percolator](http://percolator.ms) v3.04, so you'll need to install this version or newer to use them. Alternatively, you could use a recent version of [Crux](http://crux.ms), which contains Percolator and bunch of other proteomics tools.[^4] You'll need to have one of these installed to follow along.

[^4]: If you want to use Crux, verify a recent version is installed: Navigate to the "Download" page, select the appropriate version, and click "I agree to the licensing terms, download the most recent build of Crux."

### Data
We'll first need a training dataset that will be used by Percolator to train a model. This training dataset can be the aggregate of many experiments, one large experiment, or whatever else you want it to be, so long as the PSMs are saved in a [format ready for Percolator](https://github.com/percolator/percolator/wiki/Interface). **Critically, PSMs that are used in the training dataset should not be evaluated with the resulting static model!** Evaluating PSMs that the model was learned from leads to over-optimistic results and, as a result, inaccurate false discovery rate (FDR) estimates.

We'll also need one or more datasets that we want to analyze using our static model. These PSMs should also be in a format ready to be used by Percolator. Again, these test datasets should not contain any of the PSMs that were used by Percolator to train the model.

A question you may ask is: "How similar do the dataset I want to analyze and my training dataset need to be in order to get good results?" Unfortunately, there is not a straightforward answer to this question. Instead, I would advise that they be *as similar as practically possible*. The good news is that it is easy to run Percolator in its standard, dynamic mode and compare that performance to using the static model.

## Training a new static model  
Now that you have your training dataset (which I'll just call "train.txt"), it's time to train a new static model with Percolator. First, open your terminal and navigate to your training dataset file. Then it's as easy as running one of the following commands:

```bash
# If you are using stand-alone Percolator:
percolator --weights percolator.weights.txt train.txt

# or, if you are using Crux:
crux percolator --output-weights T train.txt
```

In either case, the model learned from the training dataset will be saved to a file called "percolator.weights.txt", which we can use as our static model for a new dataset.[^5]

[^5]: For Crux, this will be saved by default in the "crux-output" directory.

## Evaluating a new dataset with the static model
Now that we have a static model saved to "percolator.weights.txt", we can use it to evaluate a new dataset. In this case we'll call the PSMs from the new dataset "test.txt". To use the static model to evaluate the new dataset, run one of the following commands:

```bash
# If you are using stand-alone Percolator:
percolator --init-weights percolator.weights.txt --static test.txt

# or, if you are using Crux:
crux percolator --init-weights percolator.weights.txt --static T test.txt
```

Of course, you can also run Percolator with its normal, dynamic model training for comparison:
```bash
# If you are using stand-alone Percolator:
percolator test.txt

# or, if you are using Crux:
crux percolator test.txt
```

## Conclusions
Hopefully, you now know what a static model is in the context of Percolator, as well as how to create and use them. If you want more details on situations when static models can be beneficial, you should definitely check out [the manuscript](https://doi.org/10.1101/849331). Also, if a detailed post on how Percolator works sounds interesting, please let me know.

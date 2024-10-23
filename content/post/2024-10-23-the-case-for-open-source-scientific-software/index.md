---
title: The Case for Open-Source Scientific Software
author: William E Fondrie
date: '2024-10-23'
slug: the-case-for-open-source-scientific-software
---

<img src="cover.webp" alt="alt" style="max-width: 400px; display: block; margin-left: auto; margin-right: auto;">

In modern scientific research, computational methods play a pivotal role---and in many cases are the central focus of a scientific paper.
Yet, despite the heavy reliance on algorithms and software, code is often not treated with the rigor and expectations of openness as data in many fields.
Sparked by a recent Twitter/X controversy in the proteomics field, this post explores the importance of open-source software in scientific research and why it’s essential for driving scientific progress.
It also discusses how folks can commercialize their open-source software to support its continued development.
It will not discuss why for-profit companies should release open-source software; that'll be a future post.

Also, as always, these opinions are my own and do not reflect those of my employer.

But first, I'll offend some folks:

## Computational Papers Without Code Are Just Advertisements

In 2024, both the Nobel Prizes in Physics and Chemistry were awarded for breakthroughs in deep learning and protein structure prediction. 
These accomplishments highlight how impactful computational research can be, yet they also stress the importance of transparency.
Without open-source code, computational papers are little more than advertisements for an idea—claims that cannot be fully verified or reproduced.

A striking example is the controversy surrounding the [2024 AlphaFold3 paper](https://doi.org/10.1038/s41586-024-07487-w), which---unlike its predecessor---failed release the code. 
This move [sparked frustration in the scientific community](https://www.nature.com/articles/d41586-024-01463-0) because, without code, it's impossible to replicate or scrutinize the work. 
Publishing an algorithm without code is like withholding experimental data in traditional research—it prevents others from building on or challenging the findings.

Moreover, even the best-described algorithms often differ in their real-world implementations. 
Code provides the essential details needed to truly understand how a model works in practice. 
Open-source code fuels scientific progress by allowing others to reproduce results, identify bugs, and push the field forward. 
Without it, computational research risks becoming a black box, stifling innovation rather than promoting it.
Indeed, I've seen this in my own work where users have found nuances not captured in the methods of the papers we've published, or have found bugs that we subsequently fixed. 

One example of open-source impact from my own work has been with [Casanovo](https://github.com/Noble-Lab/casanovo).
Since Casanovo is fully open-source, we've seen an explosion of new deep learning methods for *de novo* sequencing peptides from mass spectra.
Some of these tools explicitly depend on Casanovo, others depend on the underlying open-source library I wrote ([Depthcharge](https://github.com/wfondrie/depthcharge)), while others literally copy and paste our codebase into their work as their starting point. 
All of this is awesome and what science is all about; exploring areas that have never been explored before, sharing what we find, and providing a stepping stone to propel all of humanity forward---not just ourselves.

## Open-Source Promotes Scientific Transparency and Rigor

We hit on this in the previous section, but transparency is the cornerstone of science; and open-source software exemplifies this principle.
Sharing code allows other researchers to not only reproduce the results but also scrutinize them.
Open-source fosters an environment where peer review extends beyond the publication of a paper—it includes the software itself.
Indeed, the software becomes alive when it picked up by users.
Bugs or inefficiencies can be spotted by others, improving the overall quality of the science.
For me, a prime example of this is [Mokapot](https://github.com/wfondrie/mokapot/) which is niche proteomics software, but now has 13 contributors!

Additionally, open-source code encourages rigorous testing.
As others in the community work with the software, they often find edge cases that the original authors may have missed.
This collaborative environment leads to better, more reliable tools, increasing the overall credibility of the research.
It also allows others to replicate algorithms in their own code, and contribute back improvement that they may find.

## Open-Source Propels Science Forward

And closed-source scientific software holds a field back.

When new algorithms are proposed for scientific fields, yet their implementation is locked behind proprietary barriers, it stifles innovation.
Conversely, open-source software is the building block of progress.
By allowing others to build on your work, you create opportunities for the field to evolve more rapidly.
Programming languages like Python and R, and the many packages like PyTorch and Scikit-learn have become cornerstones of research, precisely because they’re open and free for all to use and improve.

## Wait, so is propietary, closed-source, scientific software ever acceptable?

I think the answer is clearly yes---but not under the guise scientific research intended for public benefit.
Rather, the process of incorporating new algorithms into propietary software is inherently a commercial activity.
Even when built around open-source software, there is the opportunity to improve usability, scaling, and efficiency with commercial investment.
Commercialized scientific software can be a huge boon to researches who are not primarily focused on the advancements of the computational methods and instead care most about their application.

Indeed, I think it follows that research funded by public grant mechanisms (like through the NIH), should always be open-source.[^1] 
Anything else would be contrary to the mission of publicly funded research.

[^1]: A notable exception in the case of the NIH would be their Small Business Innovation Research (SBIR) and Small Business Technology Transfer (STTR) programs. 
    These both have the stated goal of commercializing technology rather than conducting and sharing research.

You might find yourself thinking, "I don't want some company stealing my open-source software, making it part of their propietary code, and making money off of it." 
If that is you, I'd recommend researching common open-source software licenses. 
The strong copyleft licenses like the [GPL-3.0](https://www.gnu.org/licenses/gpl-3.0.html) or the [AGPL-3.0](https://www.gnu.org/licenses/agpl-3.0.en.html) licenses generally require any code derived from their source be open-source under a compatible license as well.
Companies are generally risk-adverse on legal matters and respect these licenses.


## Strategies to Commercialize Open-Source Software

While open-source software is freely available, that doesn’t mean that it lacks commercial potential.
When commercializing open-source software, it's important to strike a balance—ensuring that core functionalities remain open and free for scientific exploration while building sustainable revenue models through value-added services or exclusive features.
Here are just a few models for commercializing open-source projects without compromising the ethos of openness:

- **Dual Licensing**: Offer the software under an open-source license under a strong copyleft license, while providing a paid license with less strict terms for entities that may want to incorporate your software in a closed-source tool.
- **Support and Services**: Many companies, like Red Hat or RStudio, profit by offering support, custom development, or consulting for open-source tools.
- **SaaS (Software as a Service)**: Offer a hosted version of the open-source software with added features, such as ease of use, maintenance, or cloud integration, similar to how GitLab or MongoDB monetize their platforms.
  This is also the route that open-source proteomics software like Sage is using to support development under [Chaparral](https://www.chaparral.ai/).
- **Open core**: Offer the core functionality of your software as fully open-source, but allow access to certain features only to paying customers. Often, this model uses a time delay for adding features to the open-source core, essentially allowing paying customers early access to new features. This model is used by projects like [mkdocs-material](https://github.com/squidfunk/mkdocs-material).

These strategies allow developers to remain committed to open-source ideals while maintaining financial sustainability.

Open-source scientific software is not just a good idea; it’s a philosophy that embodies transparency, collaboration, and progress.
As computational research becomes increasingly central to breakthroughs in every scientific field, open-source software must be part of the broader push for open science. 
Transparency, reproducibility, and collaboration are the cornerstones of scientific progress, and they rely on the free exchange of both data and code.
Plus, it is way more fun to [build in the open](https://youtu.be/th79W4rv67g?si=jo6P2GVu3AwZVjvl)!

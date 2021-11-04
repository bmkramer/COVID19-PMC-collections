# COVID-19 PMC collections
Licences and permanence of COVID19 Public Health Emergency collections in PubMed Central (PMC)

last update: November 4, 2021

## Public Health Emergency COVID-19 Initiative
In response to a [call from National Science and Technology Advisors from a dozen countries](https://wellcome.ac.uk/sites/default/files/covid19-open-access-letter.pdf), a [number of publishers](https://wellcome.ac.uk/press-release/publishers-make-coronavirus-covid-19-content-freely-available-and-reusable) have committed to making their coronavirus-related articles freely available through PubMed Central and other public repositories, and facilitate text mining and secondary analysis through machine-readable formats and licenses. 


Publisher collections made available in PMC as part of this [Public Health Emergency COVID-19 Initiative](https://www.ncbi.nlm.nih.gov/pmc/about/covid-19/) are listed as part of the PMC [special collections]( https://www.ncbi.nlm.nih.gov/pmc/journals/collections/?titles=current&search=journals). 


## Licenses and permanence
One outstanding question is under which licenses these papers are made available, and especially, to what extent they are to be a permanent part of PubMed Central, or are subject to withdrawal after the (immediate) urgency of the COVID19 public health emergency has passed. 

In the [FAQ](https://www.ncbi.nlm.nih.gov/pmc/about/covid-19-faq/) of the PMC COVID-19 Initiative, it is stated that articles which are not made available under a [Creative Commons](https://creativecommons.org/)-license, <em>"will include a custom license that allows for the article to be made available via the PMC Open Access Subset for re-use and secondary analysis with acknowledgement of the original source"</em>. For such articles, the National Library of Medicine (NLM) proposes a license that includes a perpetual license to PMC to make the article available, even when permissions for unrestricted re-use and analysis are withdrawn

>"This article is made available via the PMC Open Access Subset for unrestricted re-use and analyses in any form or by any means with acknowledgement of the original source. These permissions are granted for the duration of the COVID-19 pandemic or until permissions are revoked in writing. Upon expiration of these permissions, PMC is granted a perpetual license to make this article available via PMC and Europe PMC, consistent with existing copyright protections."

However, the FAQ also makes clear that when a copyright holder decides to use another license and requests content be removed from the archive at the end of the initiative, PMC will remove the content. 

## Analyzing licenses of publisher collections in the PMC COVID-19 Initative

So which licenses are used by publishers for content in the PMC COVID-19 initiative? License information of articles in publisher collections in the PMC COVID-19 Initiative was retrieved programmatically though the [Entrez Programming Utilities](https://www.ncbi.nlm.nih.gov/books/NBK25499/), using the R package [rentrez](https://cran.r-project.org/web/packages/rentrez/index.html) on **Nov 1-2, 2021**. Programmatic classification of licenses was supplemented by manual inspection of the license statements. Scripts and data are shared in this GitHub repo. Results are summarized in Table 1 below.  

The data would also allow for analysis of licenses for individual publisher imprints and/or societies that publish with one of the large publishers, or for analysis at the level of journal titles.   

Only publications included in PMC [special collections](https://www.ncbi.nlm.nih.gov/pmc/journals/collections/?titles=current&search=journals) that are identified as Public Health Emergency collections were included, so contributions from other publishers might have been missed. 

|PMC Public Health Emergency collection|number of papers (2021-11-01)|CC license|CC-BY|open government license|custom license (perpetual access via PMC)|custom license (temporary access)|custom license (other)|unknown|
|--------------------------------------|:---------------------------:|:--------:|:---:|:---------------------:|:---------------------------------------:|:-------------------------------:|:--------------------:|:-----:|
| AAAS | 182 | 173 | 173 | - | - | - | 8 | 1 |
| American College of Physicians | 300 | - | - | - | 300 | - | - | - |
| ACS | 789 | 84 | 38 | - | - | 675 | 26 | 4 |
| AOSIS | 200 | 200 | 200 | - | - | - | - | - |
| ASME | 22 | - | - | - | 22 | - | - | - |
| BMJ | 2073 | 1535 | 269 | - | - | 523 | - | 15 |
| Cambridge University Press | 2254 | 1726 | 1715 | - | 518 | 3 | - | 7 |
| Elsevier | 77218 | 4962 | 1087 | - | 57 | 70842 | 22 | 1335 |
| IEEE | 79 | 67 | 67 | - | - | - | - | 12 |
| IOP | 42 | - | - | - | - | 42 | - | - |
| JMIR | 44 | 44 | 44 | - | - | - | - | - |
| Karger | 592 | 95 | 5 | - | 428 | - | - | 69 |
| NEJM | 271 | - | - | - | 182 | - | - | 89 |
| Oxford University Press | 11369 | 2931 | 880 | 210 | 4005 | 115 | 3961 | 147 |
| Radiological Society | 228 | 1 | 1 | - | 221 | - | - | 6 |
| Sage | 899 | 889 | 691 | - | 1 | - | - | 9 |
| Springer Nature | 67989 | 21409 | 20672 | 1 | - | 43804 | 18 | 2757 |
| Taylor & Francis | 858 | 80 | 34 | - | 706 | - | 2 | 70 |
| Thieme | 357 | 57 | 2 | - | 298 | - | - | 2 |
| University of Toronto Press | 24 | - | - | - | 24 | - | - | - |
| Wiley | 18645 | 2851 | 1492 | - | 171 | 14985 | 148 | 490 |
| Wolters Kluwer | 2284 | 400 | 90 | 7 | 1856 | - | 1 | 20 |


**Table 1.  Numbers of articles in publisher collections in PMC COVID-19 Initiave with different types of licenses (NB numbers for CC-license include CC-BY)**
 

The analysis shows that only a minority of papers shared in the COVID-19 Initiative have a CC-license (and only a subset of those a CC-BY license). For papers that are not shared with a CC-license, some publishers (e.g. <em>Cambridge University Press</em>, <em>Oxford University Press</em>, <em>Taylor & Francis</em> and <em>Wolters Kluwer</em>) have opted to use a license as described above, guaranteeing perpetual access through PMC (even after other reuse permissions are withdrawn). Other publishers (e.g. <em>BMJ</em>, <em>ACS</em>, <em>Elsevier</em>, <em>IOP</em>, <em>Springer Nature</em> and <em>Wiley</em>) use a custom license that specifies that access to these papers is temporary. Two examples of such licenses are quoted below: 

>"Since January 2020 Elsevier has created a COVID-19 resource centre with free information in English and Mandarin on the novel coronavirus COVID-19. The COVID-19 resource centre is hosted on Elsevier Connect, the company's public news and information website. Elsevier hereby grants permission to make all its COVID-19-related research that is available on the COVID-19 resource centre - including this research content - immediately available in PubMed Central and other publicly funded repositories, such as the WHO COVID database with rights for unrestricted research re-use and analyses in any form or by any means with acknowledgement of the original source. These permissions are granted for free by Elsevier for as long as the COVID-19 resource centre remains active." [<em>Elsevier</em>]  

>"This article is made available via the PMC Open Access Subset for
unrestricted research re-use and analyses in any form or by any
means with acknowledgement of the original source. These
permissions are granted for the duration of the World Health
Organization (WHO) declaration of COVID-19 as a global
pandemic." [<em>Springer Nature</em>] 

## Implications
That many COVID-19 related research papers are currently made publicly available, both for reading and for analysis and (re)use, is in itself a positive development. Their full-text inclusion in PubMed Central allows for a centralized access point, subsequent inclusion in other databases such as [Europe PMC](https://europepmc.org/) and the [CORD-19 dataset](https://pages.semanticscholar.org/coronavirus-research), and further downstream usage. At the same time, the fact that many of these publictions carry licenses that in some ways restrict further sharing and reuse (e.g. CC-BY-NC-ND instead of CC-BY), only allow unlimited reuse and analysis for a limited time, or even allow reading access for a limited time only, points to the limitations of this model. 

It will remain to be seen whether publishers will indeed request removal of articles from PMC in the future, e.g. after the WHO declares the pandemic to be over (e.g. Springer Nature) and/or after the publishers themselves decide to close their COVID-19-related resource initiatives (e.g. Elsevier). 

One final question is whether there is **precedence of content being made available through PMC on a temporary basis**, and what this means for the status of open access articles made available through PMC, e.g. in assessing types and levels of open access over time.

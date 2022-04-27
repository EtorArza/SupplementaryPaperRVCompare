# SupplementaryPaperRVCompare

Repo for reproducing the figures in the [paper](
https://doi.org/10.48550/arXiv.2203.07889).

## Installation

Install dependencies with apt:

```bash
sudo apt update
sudo apt install r-base
sudo apt install python3-pip
```

The .R scripts will install and load the required dependencies.
For the python dependencies, 

```bash
pip3 install tqdm
pip3 install numpy
pip3 install pandas
pip3 install matplotlib
pip3 install tensorflow
pip3 install keras
```

---


## Generating the Figures


### Figure 1

![Figure 1](readmeAssets/Fig1.png?raw=true "Figure 1")


#### Step 0 (*Optional, takes a lot of time*): 
Delete the previously computed results and compute them again. Note that this will take a lot of time, as 10000 samples for each algorithm are required.

```bash
rm data/scoresA.csv
rm data/scoresB.csv
```

Generate the samples for A - *ADAM*:

```bash
python3 get_sample.py A
```
Wait until the 10000th sample is generated (seed = 10000 will be printed).

Then we do the same for B - *RMSProp*.

```bash
python3 get_sample.py B
```
Again wait untill 10000 samples are generated.


#### Step 1: 



---


## License
[CC0](https://creativecommons.org/choose/zero/)


NOTE: The folder on data/pleda_gradient contains code from other authors so CC0 does not apply to this folder. Please contact them for more info on their license.
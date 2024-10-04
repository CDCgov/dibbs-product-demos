# Validating eCR Messages

This repository provides a way to conduct validation of eICR messages in Python leveraging a couple of open source tools. The tools are:

- [Saxonc-HE](https://pypi.org/project/saxonche/)
- [SchXslt](https://github.com/schxslt/schxslt)

## [Saxonc-HE](https://github.com/Saxonica/Saxon-HE)

The documentation for the Python API can be found [here](https://www.saxonica.com/saxon-c/doc12/html/saxonc.html). Saxon-HE is an open-source product available under the Mozilla Public License version 2.0.

## SchXslt

SchXslt is copyright (c) by David Maus <dmaus@dmaus.name> and released under the terms of the MIT license.

## Structure

```
.
├── logs
│   ├── check-svrl-results.py
│   └── svrl-output.xml
├── README.md
├── sample-files
│   ├── CDAR2_IG_PHCASERPT_R2_STU1.1_2019APR_SAMPLE_ZIKA.xml
│   ├── CDAR2_IG_PHCASERPT_R2_STU1.1_SAMPLE_MANUAL.xml
│   ├── CDAR2_IG_PHCASERPT_R2_STU1.1_Sample.xml
│   ├── eICR-TC-COVID-DX_20210412_eicr.xml
│   ├── eICR-TC-COVID-LabNeg_20210412_eicr.xml
│   ├── eICR-TC-COVID-Lab-Order_20210412_eicr.xml
│   ├── eICR-TC-COVID-LabPos_20210412_eicr.xml
│   ├── eICR-TC-COVID-Problem_20210412_eicr.xml
│   └── README.md
├── schema
│   ├── CDAR2_IG_PHCASERPT_R2_STU1.1_SCHEMATRON.sch
│   ├── CDAR2_IG_PHCASERPT_R2_STU1.1_SCHEMATRON.xsl
│   ├── convert-sch-to-xslt.py
│   ├── schxslt
│   │   ├── compile
│   │   │   ├── api-2.0.xsl
│   │   │   ├── compile-2.0.xsl
│   │   │   ├── functions.xsl
│   │   │   └── templates.xsl
│   │   ├── compile-for-svrl.xsl
│   │   ├── expand.xsl
│   │   ├── include.xsl
│   │   ├── pipeline-for-svrl.xsl
│   │   ├── pipeline.xsl
│   │   ├── svrl.xsl
│   │   ├── util
│   │   │   └── normalize-svrl.xsl
│   │   └── version.xsl
│   └── voc.xml
└── validate_ecr.py
```

## Installation

### `mamba`/`conda`:

```bash
mamba env create -f environment.yml
```

Then to activate:

```bash
mamba activate ecr-validation
```

This will install `fzf` via conda-fordge as well as the `requirements.txt` packages.

### For `pip`

```bash
pip install -r requirements.txt
```

If you don't use `mamba`/`conda` you'll need to have `fzf` available to run the command on the cli.

### For [`fzf`](https://github.com/junegunn/fzf)

MacOS:

```bash
brew install fzf
```

Ubuntu/Debian:

```bash
sudo apt install fzf
```

Windows:

```bash
scoop install fzf
```

> many other ways to install via the [`fzf repo`](https://github.com/junegunn/fzf)

## How to use this code

```bash
python validate_ecr.py
```

Then `fzf` will show you all the files in `sample-files` and you can select the one you'd like to validate and validation will run and the `svrl` output will be written to the `svrl-output.xml`. Be mindful that this file is ephemeral and will be overwritten with each run.

### How it works

- In order to use the Schematron (`.sch`) file, it must first be converted via XSLT to an `.xsl` file.
- The `convert-sch-to-xslt.py` script has already done this so you do not need to run it yourself but can if you would like to.
- The `validate_ecr.py` script uses `saxonche` to validate the eICR messages by parsing through the `svrl` output from the validation.
- In the `logs` directory you'll see the `svrl` output for the file that was selected in the `validate_ecr.py` run; this is not necessary but shows you a way to store validation or log `svrl` output should you need to.
- The `check-svrl-results.py` file was where the development for the terminal output was finalized. This code is now a part of the `parse_svrl` function in `validate_ecr.py`.
- The `simple-svrl-output.py` script was used to validate the results from this code against the AIMS online validator.

## Goals

The goal here is to produce `svrl` results that are 1:1 comparable to the [AIMS Validator's](https://validator.aimsplatform.org/) output. This means that we can be confident when developing code and tools that interact with eICR that we can be confident that the same level of validation conducted on the AIMS platform is done in other downstream processes as well as the local public health jurisdictional level.

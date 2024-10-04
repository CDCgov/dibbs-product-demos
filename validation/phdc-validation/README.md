# PHDC Validation

This is a quickly thrown together validation of the XML that makes up a Public Health Document Container (PHDC). Depending on your python installation/virtual environment setup, you'll either use the `environment.yml` for `mamba`/`conda` or the `requirements.txt` for pure `pip`. However, if you only use pure `pip` you'll need to have `fzf` installed, as this is used instead of setting up `argparse` or some other mechanism to get a list of XML docs in the `data` directory that you can choose to feed to the validation function. The `environment.yml` will install `fzf` from `conda-forge` if you go that route. Here's how to set up:

## `mamba`/`conda`:

```bash
mamba env create -f environment.yml
```

Then to activate:

```bash
mamba activate phdc-dev
```

## For `pip`

```bash
pip install -r requirements.txt
```

Whatever your virtual env strategy is fold this in as you will.

## For [`fzf`](https://github.com/junegunn/fzf)

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

## Then to run the validation:

```bash
python validate.py
```

This will prompt `fzf` to bring up a window so you can fuzzy find the input in the `data` directory. It'll output errors in a table using `rich`. The text output also has nerd font glyphs if you're using a patched font from nerd font our use a terminal with a fallback font that uses nerd font symbols.


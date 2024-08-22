# `Rscript` versions of the Quarto Notebooks

> [!IMPORTANT]
> It is important to run these R scripts in your terminal using the `Rscript` command at the `ecr-parser` directory. **NOT** at `ecr-parser/scripts/` directory. This is because the file paths are hard coded to work in this way.

## Prerequisites

The services need to be up and running so before you try to run the R scripts, you'll need to start the services with Docker compose:

```bash
docker compose up -d
```

## Running the scripts

This will do everything that you can run interactively in the Quarto Notebook in a single command. This is an example of how you can use the Quarto Notebooks as a way to test how to interact with the APIs to solidify your ideal workflow and then using the `Rscript` command to run it on some frequency that works for your needs.

### Convert to FHIR

```bash
Rscript scripts/01-convert-to-fhir.R
```

### Convert to flat file (`*.csv`)

```bash
Rscript scripts/02-convert-to-flat-file.R
```

# FHIR Validator

The [FHIR Validator](https://github.com/hapifhir/org.hl7.fhir.core/releases/latest/download/validator_cli.jar) is provided as open source code (see https://github.com/hapifhir/org.hl7.fhir.core) by the FHIR project in association with HL7, SmileCDR, and the HAPI FHIR project. From a java code point of view, the validator is part of the HAPI core library and available as part the HAPI distribution. HL7 acknowledges the support of the ONC in providing the validator to the community. Read more [here](https://confluence.hl7.org/pages/viewpage.action?pageId=35718580#UsingtheFHIRValidator-Usingthevalidator)

## Dependencies

A Java Development Kit (JDK) is required to run the validator. The validator is tested to run on all currently support LTS versions of Java (at the time of writing this documentation, JDK 11 and 17).

You will also need to download and place the `validator_cli.jar` file in the root of this repository:

```
.
├── fhir-bundles
│   ├── dibbs-converted
│   ├── ecr-ig
│   ├── eicr-rr-batch-bundle.json
│   ├── ...
│   └── README.md
├── hapi
│   ├── docker-compose.yaml
│   └── README.md
├── README.md
├── terminology_log.txt
├── validate.sh
├── validation_output.html
├── validation_output.xml
└── validator_cli.jar
```

> [!TIP]
> You can use the `download-validator.sh` script to download the `validator_cli.jar` file from its GitHub release page. It will also check the version of your current `validator_cli.jar` file and download the latest version if it is outdated. To run the script you can use the following command: `./download-validator.sh`.

## Running the FHIR Validator

An example of how to run the command to test against the eCR FHIR IG::

```bash
java -jar validator_cli.jar \
  fhir-bundles/fhir-bundle-to-validate.json \
  -ig hl7.fhir.us.ecr\#2.1.2 \
  -version 4.0.1 \
  -output validation_output.xml \
  -html-output validation_output.html \
  -txLog terminology_log.txt \
  -level warnings
```

> [!IMPORTANT]
> The command will download files and save them to `~/.fhir/` so be aware that the first time you run this command it will take longer to retrieve all the required files.

### Command Breakdown

- `java -jar validator_cli.jar`: Runs the FHIR Validator CLI.
- `fhir-bundles/fhir-bundle-to-validate.json`: The FHIR bundle you want to validate.
- `-ig hl7.fhir.us.ecr\#2.1.2`: Specifies the Implementation Guide (eCR version 2.1.2) for validation.
- `-version 4.0.1`: Validates against FHIR R4 (version 4.0.1).
- `-output validation_output.xml`: Outputs the validation results in XML format.
- `-html-output validation_output.html`: Outputs the validation results in HTML format for easier viewing.
- `-txLog terminology_log.txt`: Logs terminology operations.
- `-level warnings`: Sets the validation level to display warnings.

## Convenience `bash` script

There is also a `validate.sh` script that can be leveraged to make running the validator easier. To use it simple run:

```bash
./validate.sh fhir-bundles/fhir-bundle.json
```

## Sample FHIR Bundles

Information about where the sample FHIR bundles in the `fhir-bundles` directory are sourced from:

- `dibbs-converted` bundles are produced from the DIBBs `fhir-converter` API that use a custom created Liquid template that the Microsoft FHIR-Converter uses to convert CDA eICR and CDA RR XML files to FHIR.
- `ecr-ig` contains all of the example data from the eCR FHIR IG.
- The bundles that are in the `fhir-bundles` directory are created as a way to show how you can use the eICR and RR profiles from the eCR FHIR IG to create a single batch bundle that contains parts of the FHIR documents to support true to the spec FHIR, bundles that can be stored in a FHIR server (like HAPI), and additionally can be consumed by the DIBBs APIs.

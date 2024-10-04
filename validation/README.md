# Validation projects

There are three validation projects that could be of interest or benefit for technical folks within Public Health Scotland. These are:

- **eCR Validation:** provides a way to conduct validation of eICR messages in Python leveraging [Saxonc-HE](https://pypi.org/project/saxonche/), and [SchXslt](https://github.com/schxslt/schxslt). It is currently set up for the 1.1 version of the eICR spec but can be expanded to the 3.1 version of eICR or the current version of the RR spec as well.
- **FHIR Validation:** the [FHIR Validator](https://github.com/hapifhir/org.hl7.fhir.core/releases/latest/download/validator_cli.jar) is provided as open source code (see https://github.com/hapifhir/org.hl7.fhir.core) by the FHIR project in association with HL7, SmileCDR, and the HAPI FHIR project. The code here provides some helper shell scripts for downloading and updating the validator, and running it against R4 and the eCR FHIR IG. There is also example FHIR bundles that are of type batch with the profiles for both eICR and RR in one bundle. This is an effort to harmonize with the DIBBs API, valid FHIR based on R4 and the eCR FHIR IG, and being able to interact with FHIR servers, like HAPI.
- **PHDC Validation:** validation of the XML that makes up a Public Health Document Container (PHDC), which is based on HL7v3 CDA in python.

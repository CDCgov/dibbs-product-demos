#!/bin/bash
java -jar validator_cli.jar "$1" \
  -ig hl7.fhir.us.ecr\#2.1.2 \
  -version 4.0.1 \
  -output validation_output.xml \
  -html-output validation_output.html \
  -txLog terminology_log.txt \
  -level warnings

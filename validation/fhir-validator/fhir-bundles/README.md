# eICR and RR FHIR Batch Bundle Documentation

## Overview

This document outlines the required resources and structure for creating an ideal FHIR batch bundle that combines resources for both the eICR and RR. The resources are based on the eICR and RR profiles from the **eCR FHIR Implementation Guide (IG)**. This bundle will support the following scenarios:

1. **STLT and DIBBs use:** STLTs who want to transform individual eICR and RR FHIR documents into a single batch for use via DIBBs containerized APIs, or other FHIR interfaces.
2. **Storage:** Resources are properly linked to ensure compatibility with FHIR servers, like HAPI.
3. **Validation:** Ensuring that all mandatory elements are in place for successful validation against the eCR IG.

For an example batch bundle with all the resources used here as an example, see `eicr-rr-batch-bundle.json`

## FHIR Profiles and Documentation

### **eICR Profiles**

1. **eICR Patient**: [eICR Patient Profile](http://hl7.org/fhir/us/ecr/StructureDefinition/us-ph-patient)
2. **eICR Practitioner**: [eICR Practitioner Profile](http://hl7.org/fhir/us/core/StructureDefinition/us-core-practitioner)
3. **eICR Organization**: [eICR Organization Profile](http://hl7.org/fhir/us/ecr/StructureDefinition/eicr-organization)
4. **eICR Encounter**: [eICR Encounter Profile](http://hl7.org/fhir/us/ecr/StructureDefinition/eicr-encounter)
5. **eICR Condition**: [eICR Condition Profile](http://hl7.org/fhir/us/ecr/StructureDefinition/eicr-condition)
6. **eICR Observation**: [eICR Observation Profile](http://hl7.org/fhir/us/ecr/StructureDefinition/eicr-observation)
7. **eICR Composition**: [eICR Composition Profile](http://hl7.org/fhir/us/ecr/StructureDefinition/eicr-composition)

### **RR Profiles**

1. **RR Observation**: [RR Observation Profile](http://hl7.org/fhir/us/ecr/StructureDefinition/rr-observation)
2. **RR Composition**: [RR Composition Profile](http://hl7.org/fhir/us/ecr/StructureDefinition/rr-composition)

---

## Key Sections of the Batch Bundle

### 1. **Patient Resource**

- **Profile**: `http://hl7.org/fhir/us/ecr/StructureDefinition/us-ph-patient`
- **Required Fields**:
  - `identifier`: Usually a Medical Record Number (MRN). Use `identifier.type` to distinguish MRN and other identifiers.
  - `name`, `telecom`, `gender`, `birthDate`, `address`.
  - `meta.profile`: Reference to eICR Patient profile.
  - `fullUrl`: Unique identifier for referencing within the batch bundle.
  - `request`: HTTP operation, typically `PUT` for updates, or `POST` for new submissions.
- **Reason for Requirement**: The patient resource identifies the subject of the case report and is crucial for public health case reporting. It also supports proper linkage to other resources like the Encounter and Condition resources.

See `eicr-rr-patient.json` for an example.

### 2. **Practitioner Resource**

- **Profile**: `http://hl7.org/fhir/us/core/StructureDefinition/us-core-practitioner`
- **Required Fields**:
  - `identifier`: Relevant practitioner identifiers (e.g., NPI).
  - `name`, `telecom`.
  - `meta.profile`: Reference to eICR Practitioner profile.
  - `fullUrl`: Unique identifier within the batch.
  - `request`: Typically `PUT` for updates or `POST` for new submissions.
- **Reason for Requirement**: Identifies the healthcare provider responsible for diagnosis or care. Multiple practitioners (author, performer) may be referenced in RR documents, especially for reportability status determination.

> [!Note]
> There is also a [`PractitionerRole`](http://hl7.org/fhir/us/ecr/StructureDefinition/us-ph-practitionerrole) resource that is unique to the eCR IG that can be used in conjunction with the Practitioner resource as well.

See `eicr-rr-practitioner.json` for an example.

### 3. **Organization Resource**

- **Profile**: `http://hl7.org/fhir/us/ecr/StructureDefinition/eicr-organization`
- **Required Fields**:
  - `identifier`: Include NPI or other organization-level identifiers.
  - `name`, `telecom`, `address`.
  - `meta.profile`: Reference to eICR Organization profile.
  - `fullUrl`: Unique identifier.
  - `request`: Typically `PUT` for updates or `POST` for new submissions.
- **Reason for Requirement**: This resource identifies the healthcare organization providing patient care, crucial for public health workflows requiring facility-level reporting.

See `eicr-rr-organization.json` for an example.

### 4. **Encounter Resource**

- **Profile**: `http://hl7.org/fhir/us/ecr/StructureDefinition/eicr-encounter`
- **Required Fields**:
  - `status`: Status of the encounter (e.g., `finished`, `in-progress`).
  - `class`: Coded using `http://terminology.hl7.org/CodeSystem/v3-ActCode` (e.g., `ambulatory`, `inpatient`).
  - `subject`: Reference to the **Patient**.
  - `period`: Start and end times.
  - `meta.profile`: Reference to eICR Encounter profile.
  - `fullUrl`: Unique reference within the batch.
  - `request`: Typically `PUT` for updates or `POST` for new submissions.
- **Reason for Requirement**: The encounter resource links the clinical event to observations, conditions, and other events. This is essential for public health tracing and documentation.

See `eicr-rr-encounter.json` for an example.

### 5. **Condition Resource**

- **Profile**: `http://hl7.org/fhir/us/ecr/StructureDefinition/eicr-condition`
- **Required Fields**:
  - `code`: Reportable condition (e.g., SNOMED code for COVID-19: `840539006`).
  - `subject`: Reference to the **Patient**.
  - `encounter`: Reference to the `Encounter` resource.
  - `onsetDateTime`: Onset date and time.
  - `meta.profile`: Reference to eICR Condition profile.
  - `fullUrl`: Unique reference within the batch.
  - `request`: Typically `PUT` for updates or `POST` for new submissions.
- **Reason for Requirement**: Represents the reportable condition that triggered the case report. The **Condition** resource is critical for tracking and reporting.

See `eicr-rr-condition.json` for an example.

### 6. **Observation Resource (eICR)**

- **Profile**: `http://hl7.org/fhir/us/ecr/StructureDefinition/eicr-observation`
- **Required Fields**:
  - `status`, `code`, `subject`, `effectiveDateTime`, `valueCodeableConcept`.
  - `meta.profile`: Reference to eICR Observation profile.
  - `fullUrl`: Unique identifier for cross-referencing in the batch.
  - `request`: Typically `PUT` for updates or `POST` for new submissions.
- **Reason for Requirement**: Represents relevant clinical data (e.g., lab results, diagnostic information) necessary for the eICR.

See `eicr-rr-observation.json` for an example.

### 7. **Observation Resource (RR - Processing Status)**

- **Profile**: `http://hl7.org/fhir/us/ecr/StructureDefinition/rr-observation`
- **Required Fields**:
  - `status`, `code`, `subject`, `effectiveDateTime`, `performer`, `valueCodeableConcept`.
  - `meta.profile`: Reference to RR Observation profile.
  - `fullUrl`: Unique identifier for cross-referencing in the batch.
  - `request`: Typically `PUT` or `POST`.
- **Reason for Requirement**: Tracks the public health agency’s decision on whether the reported condition is reportable.

### 8. **Composition Resource (eICR Document)**

- **Profile**: `http://hl7.org/fhir/us/ecr/StructureDefinition/eicr-composition`
- **Required Fields**:
  - `status`, `type`, `subject`, `encounter`, `author`, `custodian`, `date`.
  - **Sections**:
    - `ReasonForVisitSection`, `ChiefComplaintSection`, `HistoryOfPresentIllnessSection`, `ProblemSection`, `MedicationsAdministeredSection`, `ResultsSection`, `SocialHistorySection`.
  - `meta.profile`: Reference to eICR Composition profile.
- **Reason for Requirement**: Acts as the core document tying together all patient data, observations, and conditions.

### 9. **Observation Resource (RR - Condition Status)**

- **Profile**: `http://hl7.org/fhir/us/ecr/StructureDefinition/rr-observation`
- **Required Fields**:
  - `status`, `code`, `subject`, `effectiveDateTime`, `performer`, `valueCodeableConcept`.
  - `meta.profile`: Reference to RR Observation profile.
  - `request`: Typically `PUT` for updates or `POST` for new submissions.

---

## Bundle Structure Example

Below is an example structure for the batch bundle:

### eICR Patient

The **Patient** resource provides demographic and identifying information, required for both eICR and RR.

```json
{
  "resourceType": "Patient",
  "id": "patient-saga-anderson-001",
  "meta": {
    "profile": ["http://hl7.org/fhir/us/ecr/StructureDefinition/us-ph-patient"]
  },
  "text": {
    "status": "generated",
    "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\"><p><b>Patient:</b> Ms. Saga Anderson, Female, DoB: 1987-11-11</p></div>"
  },
  "extension": [
    {
      "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race",
      "extension": [
        {
          "url": "ombCategory",
          "valueCoding": {
            "system": "urn:oid:2.16.840.1.113883.6.238",
            "code": "2054-5",
            "display": "Black or African American"
          }
        },
        {
          "url": "text",
          "valueString": "Black or African American"
        }
      ]
    },
    {
      "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity",
      "extension": [
        {
          "url": "ombCategory",
          "valueCoding": {
            "system": "urn:oid:2.16.840.1.113883.6.238",
            "code": "2186-5",
            "display": "Not Hispanic or Latino"
          }
        },
        {
          "url": "text",
          "valueString": "Not Hispanic or Latino"
        }
      ]
    },
    {
      "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex",
      "valueCode": "F"
    }
  ],
  "identifier": [
    {
      "use": "usual",
      "type": {
        "coding": [
          {
            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
            "code": "MR",
            "display": "Medical Record Number"
          }
        ]
      },
      "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
      "value": "MRN123456"
    },
    {
      "use": "official",
      "type": {
        "coding": [
          {
            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
            "code": "SB",
            "display": "Social Beneficiary Identifier"
          }
        ]
      },
      "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
      "value": "SSN987-65-4320"
    },
    {
      "use": "secondary",
      "system": "http://hospital-system.org",
      "value": "HSP12345678"
    }
  ],
  "active": true,
  "name": [
    {
      "use": "official",
      "text": "Ms. Saga Anderson",
      "family": "Anderson",
      "given": ["Saga"],
      "prefix": ["Ms."]
    }
  ],
  "telecom": [
    {
      "system": "phone",
      "value": "206-555-0123",
      "use": "home"
    },
    {
      "system": "email",
      "value": "saga.anderson@example.com",
      "use": "home"
    }
  ],
  "gender": "female",
  "birthDate": "1987-11-11",
  "deceasedBoolean": false,
  "address": [
    {
      "use": "home",
      "type": "both",
      "text": "6 Watery Lighthouse Trailer Park Way, Unit #2, Watery, WA, 98440",
      "line": ["6 Watery Lighthouse Trailer Park Way", "Unit #2"],
      "city": "Watery",
      "state": "WA",
      "postalCode": "98440",
      "country": "US"
    }
  ],
  "maritalStatus": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/v3-MaritalStatus",
        "code": "M",
        "display": "Married"
      }
    ]
  },
  "contact": [
    {
      "relationship": [
        {
          "coding": [
            {
              "system": "http://terminology.hl7.org/CodeSystem/v2-0131",
              "code": "C",
              "display": "Emergency Contact"
            }
          ]
        }
      ],
      "name": {
        "family": "Woods",
        "given": ["David"]
      },
      "telecom": [
        {
          "system": "phone",
          "value": "(703) 555-1234",
          "use": "home"
        }
      ],
      "address": {
        "line": ["3 Night Springs Lane"],
        "city": "Fairfax",
        "state": "VA",
        "postalCode": "22030",
        "country": "US"
      }
    },
    {
      "relationship": [
        {
          "coding": [
            {
              "system": "http://terminology.hl7.org/CodeSystem/v2-0131",
              "code": "N",
              "display": "Next-of-Kin"
            }
          ]
        }
      ],
      "name": {
        "family": "Anderson",
        "given": ["Logan"]
      },
      "gender": "female",
      "telecom": [
        {
          "system": "phone",
          "value": "(703) 555-5678",
          "use": "home"
        }
      ],
      "address": {
        "line": ["3 Night Springs Lane"],
        "city": "Fairfax",
        "state": "VA",
        "postalCode": "22030",
        "country": "US"
      }
    }
  ],
  "communication": [
    {
      "language": {
        "coding": [
          {
            "system": "urn:ietf:bcp:47",
            "code": "en-US",
            "display": "English (Region=United)"
          }
        ]
      },
      "preferred": true
    }
  ]
}
```

**Important Fields**:

- `identifier`: Includes MRN and SSN for uniquely identifying the patient.
- `meta.profile`: References eICR Patient Profile.
- `fullUrl`: Unique identifier for the patient resource within the batch.
- `request`: HTTP operation (`PUT`) to create or update the resource.

Validation of `eicr-rr-batch-patient.json`:

- `0 errors, 0 warnings, 0 hints. Generated Sep 27, 2024, 5:26:02 PM by Validator Version 6.3.29 (Git# 53ec74518475). Built 2024-09-26T12:30:54.127Z (28 hours old) (832ms)`

### Practitioner Resource

The **Practitioner** resource represents the healthcare provider involved in the patient's care.

```json
{
  "resourceType": "Practitioner",
  "id": "practitioner-emma-nelson-001",
  "meta": {
    "profile": [
      "http://hl7.org/fhir/us/core/StructureDefinition/us-core-practitioner"
    ]
  },
  "identifier": [
    {
      "use": "official",
      "system": "http://hl7.org/fhir/sid/us-npi",
      "value": "1234567890",
      "type": {
        "coding": [
          {
            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
            "code": "NPI",
            "display": "National Provider Identifier"
          }
        ]
      }
    }
  ],
  "name": [
    {
      "family": "Nelson",
      "given": ["Emma"],
      "prefix": ["Dr."]
    }
  ],
  "telecom": [
    {
      "system": "phone",
      "value": "206-555-0987",
      "use": "work"
    },
    {
      "system": "email",
      "value": "emma.nelson@nelsonpractice.org",
      "use": "work"
    }
  ],
  "text": {
    "status": "generated",
    "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">Generated Narrative for Practitioner</div>"
  }
}
```

**Important Fields**:

- `identifier`: Practitioner's NPI.
- `name`: Practitioner's full name.
- `meta.profile`: References eICR Practitioner Profile.
- `fullUrl`: Unique identifier for the practitioner within the batch.
- `request`: `PUT` method for creation or updating.

Validation of `eicr-rr-batch-practitioner.json`:

- `0 errors, 1 warning, 0 hints. Generated Sep 27, 2024, 9:12:01 PM by Validator Version 6.3.29 (Git# 53ec74518475). Built 2024-09-26T12:30:54.127Z (32 hours old) (249ms)`

### Organization Resource

The **Organization** resource represents the healthcare facility responsible for care.

```json
{
  "resourceType": "Organization",
  "id": "organization-nelson-family-practice-001",
  "meta": {
    "profile": [
      "http://hl7.org/fhir/us/ecr/StructureDefinition/eicr-organization"
    ]
  },
  "identifier": [
    {
      "use": "official",
      "system": "http://hl7.org/fhir/sid/us-npi",
      "value": "9876543210",
      "type": {
        "coding": [
          {
            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
            "code": "NPI",
            "display": "National Provider Identifier"
          }
        ]
      }
    }
  ],
  "name": "Nelson Family Practice",
  "address": [
    {
      "line": ["123 Harbor St"],
      "city": "Bright Falls",
      "state": "WA",
      "postalCode": "98440",
      "country": "United States"
    }
  ],
  "telecom": [
    {
      "system": "phone",
      "value": "206-555-0199",
      "use": "work"
    },
    {
      "system": "email",
      "value": "info@nelsonpractice.org",
      "use": "work"
    }
  ],
  "text": {
    "status": "generated",
    "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">Generated Narrative for Organization</div>"
  }
}
```

**Important Fields**:

- `identifier`: Organization's NPI.
- `name`: Organization name.
- `address`: The organization's address.
- `meta.profile`: References eICR Organization Profile.
- `fullUrl`: Unique identifier for the organization resource.
- `request`: `PUT` for creation or update.

Validation of `eicr-rr-batch-organization.json`:

- `0 errors, 2 warnings, 0 hints. Generated Sep 27, 2024, 9:13:04 PM by Validator Version 6.3.29 (Git# 53ec74518475). Built 2024-09-26T12:30:54.127Z (32 hours old) (1960ms)`

### Encounter Resource

The **Encounter** resource links the condition and observation data to the patient.

```json
{
  "resourceType": "Encounter",
  "id": "encounter-eicr-saga-anderson-001",
  "status": "finished",
  "class": {
    "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
    "code": "AMB",
    "display": "Ambulatory"
  },
  "subject": {
    "reference": "Patient/patient-saga-anderson-001"
  },
  "period": {
    "start": "2021-08-02T09:00:00Z",
    "end": "2021-08-02T10:30:00Z"
  },
  "type": [
    {
      "coding": [
        {
          "system": "http://snomed.info/sct",
          "code": "11429006",
          "display": "Consultation"
        }
      ]
    }
  ],
  "text": {
    "status": "generated",
    "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">Generated Narrative for Encounter</div>"
  }
}
```

**Important Fields**:

- `status`: Encounter status (e.g., `finished`, `in-progress`).
- `class`: The type of encounter (e.g., `ambulatory`, `inpatient`).
- `subject`: Reference to the patient.
- `period`: Start and end of the encounter.
- `meta.profile`: References eICR Encounter Profile.
- `fullUrl`: Unique identifier for the encounter.
- `request`: `PUT` for creation or update.

Validation of `eicr-rr-batch-encounter.json`:

- `0 errors, 0 warnings, 0 hints. Generated Sep 27, 2024, 9:13:47 PM by Validator Version 6.3.29 (Git# 53ec74518475). Built 2024-09-26T12:30:54.127Z (32 hours old) (269ms)`

### Condition Resource

The **Condition** resource represents the clinical condition that triggered the report.

```json
{
  "resourceType": "Condition",
  "id": "condition-covid19-001",
  "clinicalStatus": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/condition-clinical",
        "code": "active",
        "display": "Active"
      }
    ]
  },
  "verificationStatus": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/condition-ver-status",
        "code": "confirmed",
        "display": "Confirmed"
      }
    ]
  },
  "category": [
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/condition-category",
          "code": "encounter-diagnosis",
          "display": "Encounter Diagnosis"
        }
      ]
    }
  ],
  "code": {
    "coding": [
      {
        "system": "http://snomed.info/sct",
        "code": "840539006",
        "display": "COVID-19"
      }
    ]
  },
  "subject": {
    "reference": "Patient/patient-saga-anderson-001"
  },
  "encounter": {
    "reference": "Encounter/encounter-eicr-saga-anderson-001"
  },
  "onsetDateTime": "2021-08-02T09:15:00Z",
  "text": {
    "status": "generated",
    "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">Generated Narrative for Condition</div>"
  }
}
```

**Important Fields**:

- `code`: SNOMED code for the condition (e.g., `840539006` for COVID-19).
- `subject`: Reference to the patient.
- `encounter`: Reference to the related encounter.
- `onsetDateTime`: Date/time when the condition started.
- `meta.profile`: References eICR Condition Profile.
- `fullUrl`: Unique identifier for the condition.
- `request`: `PUT` for creation or update.

Validation of `eicr-rr-batch-condition.json`:

- `0 errors, 0 warnings, 0 hints. Generated Sep 27, 2024, 9:14:34 PM by Validator Version 6.3.29 (Git# 53ec74518475). Built 2024-09-26T12:30:54.127Z (32 hours old) (209ms)`

### Observation Resource (eICR)

The **Observation (eICR)** resource represents key clinical data, such as lab results, diagnostic information, or vital signs, which are relevant to a patient's case. This resource helps document and communicate crucial medical findings that inform public health reporting.

```json
{
  "resourceType": "Observation",
  "id": "observation-covid19-pcr-001",
  "meta": {
    "profile": [
      "http://hl7.org/fhir/us/ecr/StructureDefinition/eicr-observation"
    ]
  },
  "text": {
    "status": "generated",
    "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">COVID-19 PCR Test Result: Detected</div>"
  },
  "status": "final",
  "category": [
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/observation-category",
          "code": "laboratory",
          "display": "Laboratory"
        }
      ]
    }
  ],
  "code": {
    "coding": [
      {
        "system": "http://loinc.org",
        "code": "94500-6",
        "display": "SARS-CoV-2 (COVID-19) RNA [Presence] in Respiratory system specimen by NAA with probe detection"
      }
    ],
    "text": "COVID-19 PCR Test"
  },
  "subject": {
    "reference": "Patient/patient-saga-anderson-001"
  },
  "encounter": {
    "reference": "Encounter/encounter-eicr-saga-anderson-001"
  },
  "effectiveDateTime": "2021-08-03T12:45:00Z",
  "performer": [
    {
      "reference": "Organization/organization-nelson-family-practice-001"
    }
  ],
  "valueCodeableConcept": {
    "coding": [
      {
        "system": "http://snomed.info/sct",
        "code": "260373001",
        "display": "Detected"
      }
    ],
    "text": "COVID-19 RNA Detected"
  }
}
```

**Important Fields**:

- `status`: The state of the observation, e.g., `final`.
- `category`: The type of observation, e.g., `laboratory`.
- `code`: LOINC code representing the test, e.g., `94500-6` for a COVID-19 PCR test.
- `subject`: The patient the observation refers to, e.g., `Patient/patient-saga-anderson`.
- `encounter`: The encounter linked to this observation, e.g., `Encounter/encounter-eicr-saga-anderson`.
- `effectiveDateTime`: Date and time of the observation, e.g., `2021-08-03T12:45:00Z`.
- `performer`: The organization or individual who performed the test, e.g., `Organization/organization-nelson-family-practice`.
- `valueCodeableConcept`: The result of the test, e.g., `260373001` (Detected).
- `meta.profile`: Reference to `http://hl7.org/fhir/us/ecr/StructureDefinition/eicr-observation`.

Validation of `eicr-rr-batch-observation-eicr.json`:

- `0 errors, 1 warning, 0 hints. Generated Sep 27, 2024, 9:15:34 PM by Validator Version 6.3.29 (Git# 53ec74518475). Built 2024-09-26T12:30:54.127Z (32 hours old) (1866ms)`

### Composition Resource (eICR Document)

The **Composition (eICR)** resource acts as the core document tying together all patient data, observations, and conditions within an electronic case report (eICR). This resource is central to public health reporting, linking a patient’s medical history, clinical observations, and encounters.

```json
{
  "resourceType": "Composition",
  "id": "composition-eicr-covid19-001",
  "meta": {
    "profile": [
      "http://hl7.org/fhir/us/ecr/StructureDefinition/eicr-composition"
    ]
  },
  "identifier": {
    "system": "http://hospital-system.org/compositions",
    "value": "eicr-covid19-identifier-001"
  },
  "status": "final",
  "type": {
    "coding": [
      {
        "system": "http://loinc.org",
        "code": "55751-2",
        "display": "Public health Case report"
      }
    ]
  },
  "subject": {
    "reference": "Patient/patient-saga-anderson-001"
  },
  "encounter": {
    "reference": "Encounter/encounter-eicr-saga-anderson-001"
  },
  "date": "2021-08-03T12:45:00Z",
  "author": [
    {
      "reference": "Practitioner/practitioner-emma-nelson-001"
    }
  ],
  "custodian": {
    "reference": "Organization/organization-nelson-family-practice-001"
  },
  "title": "COVID-19 Public Health Case Report",
  "section": [
    {
      "title": "Reason for Visit",
      "code": {
        "coding": [
          {
            "system": "http://loinc.org",
            "code": "51852-2",
            "display": "Letter"
          }
        ]
      },
      "entry": [
        {
          "reference": "Encounter/encounter-eicr-saga-anderson-001"
        }
      ]
    },
    {
      "title": "Chief Complaint",
      "code": {
        "coding": [
          {
            "system": "http://loinc.org",
            "code": "10154-3",
            "display": "Chief complaint Narrative - Reported"
          }
        ]
      },
      "entry": [
        {
          "reference": "Encounter/encounter-eicr-saga-anderson-001"
        }
      ],
      "text": {
        "status": "generated",
        "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">Chief Complaint: COVID-19 related symptoms reported by the patient.</div>"
      }
    },
    {
      "title": "Condition",
      "code": {
        "coding": [
          {
            "system": "http://snomed.info/sct",
            "code": "840539006",
            "display": "COVID-19"
          }
        ]
      },
      "entry": [
        {
          "reference": "Encounter/encounter-eicr-saga-anderson-001"
        }
      ]
    },
    {
      "title": "Results",
      "code": {
        "coding": [
          {
            "system": "http://loinc.org",
            "code": "11502-2",
            "display": "Laboratory report"
          }
        ]
      },
      "entry": [
        {
          "reference": "Encounter/encounter-eicr-saga-anderson-001"
        }
      ]
    },
    {
      "title": "History of Present Illness",
      "code": {
        "coding": [
          {
            "system": "http://loinc.org",
            "code": "11348-0",
            "display": "History of Past illness Narrative"
          }
        ]
      },
      "text": {
        "status": "generated",
        "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">Patient reports 5-day history of fever, cough, and difficulty breathing, consistent with COVID-19.</div>"
      }
    },
    {
      "title": "Problem Section",
      "code": {
        "coding": [
          {
            "system": "http://loinc.org",
            "code": "11450-4",
            "display": "Problem list - Reported"
          }
        ]
      },
      "entry": [
        {
          "reference": "Encounter/encounter-eicr-saga-anderson-001"
        }
      ],
      "text": {
        "status": "generated",
        "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">Primary Problem: COVID-19 infection.</div>"
      }
    },
    {
      "title": "Medications Administered",
      "code": {
        "coding": [
          {
            "system": "http://loinc.org",
            "code": "29549-3",
            "display": "Medication administered Narrative"
          }
        ]
      },
      "text": {
        "status": "generated",
        "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">Administered medications include acetaminophen for fever management.</div>"
      }
    },
    {
      "title": "Social History",
      "code": {
        "coding": [
          {
            "system": "http://loinc.org",
            "code": "29762-2",
            "display": "Social history Narrative"
          }
        ]
      },
      "text": {
        "status": "generated",
        "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">Patient reports no recent travel, but has been in contact with confirmed COVID-19 cases.</div>"
      }
    }
  ],
  "text": {
    "status": "generated",
    "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">COVID-19 Public Health Case Report</div>"
  }
}
```

**Important Fields**:

- `status`: The current status of the eICR, e.g., `final`.
- `type`: The document type, e.g., `Public health Case report` (LOINC code `55751-2`).
- `subject`: The patient the eICR refers to, e.g., `Patient/patient-saga-anderson`.
- `encounter`: The encounter associated with the eICR, e.g., `Encounter/encounter-eicr-saga-anderson`.
- `author`: The individual or organization who authored the document, e.g., `Practitioner/practitioner-emma-nelson`.
- `custodian`: The organization responsible for maintaining the eICR, e.g., `Organization/organization-nelson-family-practice`.
- `date`: The creation date and time of the eICR, e.g., `2021-08-03T12:45:00Z`.
- `meta.profile`: Reference to `http://hl7.org/fhir/us/ecr/StructureDefinition/eicr-composition`.

**Required Sections**:

- `ReasonForVisitSection`: Describes the reason for the patient’s visit or encounter.
- `ChiefComplaintSection`: Records the patient's chief complaint as reported.
- `HistoryOfPresentIllnessSection`: Provides details on the patient's current illness history.
- `ProblemSection`: Lists the patient's problems or conditions.
- `MedicationsAdministeredSection`: Details medications that were administered to the patient.
- `ResultsSection`: Includes diagnostic test results.
- `SocialHistorySection`: Captures social history details relevant to the patient’s condition.

Validation of `eicr-rr-composition-eicr.json`:

- `5 errors, 0 warnings, 0 hints. Generated Sep 27, 2024, 9:17:58 PM by Validator Version 6.3.29 (Git# 53ec74518475). Built 2024-09-26T12:30:54.127Z (32 hours old) (818ms)`
  - These 5 errors are similar to the eCR FHIR IG's example bundle named `Composition-composition-eicr-zika.json`, which also has the same `Slice` errors that this example has.

### Observation Resource (RR - Processing Status)

The **Observation (RR - Processing Status)** resource tracks the public health agency’s decision on whether the reported condition is reportable. This resource helps capture the outcome of the reportability decision process. If the eICR was processed with a warning then this observation is followed by an Observation resource using the `rr-eicr-processing-status-reason-observation`.

```json
{
  "resourceType": "Observation",
  "id": "observation-eicr-status-001",
  "meta": {
    "profile": [
      "http://hl7.org/fhir/us/ecr/StructureDefinition/rr-eicr-processing-status-observation"
    ]
  },
  "text": {
    "status": "generated",
    "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\"><p>eICR was processed</p></div>"
  },
  "status": "final",
  "code": {
    "coding": [
      {
        "system": "urn:oid:2.16.840.1.114222.4.5.274",
        "code": "RRVS17",
        "display": "eICR was processed"
      }
    ]
  }
}
```

**Important Fields**:

- `status`: The current status of the observation.
- `code`: A LOINC code representing the processing status.
- `subject`: The patient the observation refers to, e.g., `Patient/patient-rr-example`.
- `effectiveDateTime`: The date and time the decision was made.
- `performer`: The public health agency responsible for the decision, e.g., `Organization/organization-rr-example`.
- `valueCodeableConcept`: The result of the processing, e.g., `RR:Reportable` or `RR:Not Reportable`.
- `meta.profile`: Reference to `http://hl7.org/fhir/us/ecr/StructureDefinition/rr-observation`.
- `fullUrl`: A unique identifier for cross-referencing in batch submissions, e.g., `urn:uuid:12345-abcde-67890-fghij`.
- `request`: Specifies whether the operation is a `PUT` (update) or `POST` (new submission).

**Validation of `eicr-rr-observation-rr-status.json`:**

- `0 errors, 6 warnings, 0 hints. Generated Sep 27, 2024, 9:42:16 PM by Validator Version 6.3.29 (Git# 53ec74518475). Built 2024-09-26T12:30:54.127Z (33 hours old) (481ms)`

### Composition Resource (RR)

The **Composition (RR - Reportability Response)** resource is the core document that communicates the results of the reportability decision back to the submitter. It contains information about the public health agency’s response, the relevant condition, and any additional reporting requirements.

```json
{
  "resourceType": "Composition",
  "id": "composition-rr-covid19-001",
  "meta": {
    "versionId": "1",
    "lastUpdated": "2024-09-26T00:00:00.000Z",
    "profile": ["http://hl7.org/fhir/us/ecr/StructureDefinition/rr-composition"]
  },
  "identifier": {
    "system": "http://acme.org/identifiers",
    "value": "RR12347"
  },
  "status": "final",
  "type": {
    "coding": [
      {
        "system": "http://loinc.org",
        "code": "88085-6",
        "display": "Reportability response report Document Public health"
      }
    ]
  },
  "subject": {
    "reference": "Patient/patient-saga-anderson-001"
  },
  "encounter": {
    "reference": "Encounter/encounter-eicr-saga-anderson-001"
  },
  "date": "2024-09-26T12:30:00Z",
  "author": [
    {
      "reference": "Organization/organization-nelson-family-practice-001"
    }
  ],
  "custodian": {
    "reference": "Organization/organization-nelson-family-practice-001"
  },
  "title": "COVID-19 Reportability Response",
  "extension": [
    {
      "url": "http://hl7.org/fhir/StructureDefinition/composition-clinicaldocument-versionNumber",
      "valueString": "1"
    },
    {
      "url": "http://hl7.org/fhir/us/ecr/StructureDefinition/us-ph-information-recipient-extension",
      "valueReference": {
        "reference": "Practitioner/practitioner-emma-nelson-001"
      }
    }
  ],
  "text": {
    "status": "generated",
    "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">This is the narrative content for the reportability response</div>"
  },
  "section": [
    {
      "title": "Reportability Response Subject Section",
      "code": {
        "coding": [
          {
            "system": "http://loinc.org",
            "code": "88084-9",
            "display": "Reportable condition response information and summary Document"
          }
        ]
      },
      "text": {
        "status": "generated",
        "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">Public Health Reporting: COVID-19 is reportable.</div>"
      },
      "entry": [
        {
          "reference": "Observation/observation-rr-covid19-001"
        }
      ]
    },
    {
      "extension": [
        {
          "url": "http://hl7.org/fhir/us/ecr/StructureDefinition/rr-eicr-processing-status-extension",
          "extension": [
            {
              "url": "eICRProcessingStatus",
              "valueReference": {
                "reference": "Observation/observation-eicr-status-001",
                "display": "Processed"
              }
            }
          ]
        },
        {
          "url": "http://hl7.org/fhir/us/ecr/StructureDefinition/rr-priority-extension",
          "valueCodeableConcept": {
            "coding": [
              {
                "system": "urn:oid:2.16.840.1.114222.4.5.274",
                "code": "RRVS17",
                "display": "Immediate action required"
              }
            ]
          }
        }
      ],
      "title": "COVID-19 Reportability Response Summary Section",
      "code": {
        "coding": [
          {
            "system": "http://loinc.org",
            "code": "55112-7",
            "display": "Document summary"
          }
        ]
      },
      "text": {
        "status": "generated",
        "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">COVID-19 is reportable to public health. Immediate action is required.</div>"
      },
      "entry": [
        {
          "reference": "Observation/observation-rr-covid19-001"
        }
      ]
    }
  ]
}
```

**Important Fields**:

- `status`: The current status of the composition, e.g., `final`.
- `type`: The type of report, e.g., `Reportability response report Document Public health`.
- `subject`: The patient or case the report pertains to, e.g., `Patient/patient-rr-example`.
- `encounter`: The encounter related to the report, e.g., `Encounter/encounter-example`.
- `author`: The organization or individual creating the report, e.g., `Organization/organization-example`.
- `custodian`: The organization responsible for maintaining the report, e.g., `Organization/organization-example`.
- `date`: The date the report was created, e.g., `2023-09-25T12:00:00Z`.
- `meta.profile`: Reference to `http://hl7.org/fhir/us/ecr/StructureDefinition/rr-composition`.

**Sections**:

- `Reportability Response Subject Section`: Contains summary information regarding the reportable condition and response.
- `Electronic Initial Case Report Section`: Includes details about the original eICR submission, processing status, and any follow-up actions required.
- `Reportability Response Summary Section`: Summarizes the public health agency’s response, including actions required by the reporting organization.

- **Reason for Requirement**: The RR Composition serves as the primary vehicle for communicating the public health agency’s response to the reportable condition, informing the submitter about next steps, required actions, or further investigation.
  **Validation of `eicr-rr-batch-composition-rr.json`:**

- `3 errors, 4 warnings, 0 hints. Generated Sep 27, 2024, 9:28:07 PM by Validator Version 6.3.29 (Git# 53ec74518475). Built 2024-09-26T12:30:54.127Z (32 hours old) (547ms)`
  - These 3 errors are similar to the eCR FHIR IG's example bundle named `Composition-composition-rr-one-cond-one-pha.json`, which also has the same `Slice` errors that this example has.

## HAPI FHIR Server

Ensuring that a STLT is also able to store converted CDA eICR and RR FHIR bundles in a FHIR server is a critical piece of interoperability. It is also a great way to ensure that the conversions produced by the custom Liquid templates for the Microsoft FHIR-Converter are meeting the standard and that there are no significant issues.

### Running the HAPI FHIR Server

Running a local version of the HAPI FHIR server using the following Docker compose file:

```yaml
version: "3.7"

services:
  fhir:
    container_name: fhir
    image: "hapiproject/hapi:latest"
    ports:
      - "8080:8080"
    environment:
      - spring.datasource.url=jdbc:postgresql://db:5432/hapi
      - spring.datasource.username=admin
      - spring.datasource.password=admin
      - spring.datasource.driverClassName=org.postgresql.Driver
      - spring.jpa.properties.hibernate.dialect=ca.uhn.fhir.jpa.model.dialect.HapiFhirPostgresDialect
      - spring.jpa.properties.hibernate.search.enabled=false
    depends_on:
      - db

  db:
    image: postgres
    restart: always
    environment:
      POSTGRES_PASSWORD: admin
      POSTGRES_USER: admin
      POSTGRES_DB: hapi
    volumes:
      - ./hapi.postgres.data:/var/lib/postgresql/data

volumes:
  hapi-postgres-data:
```

### Uploading the FHIR Bundles

When using the `eicr-rr-batch-bundle.json` at `http://localhost:8080/fhir` this is the response:

```json
{
  "resourceType": "Bundle",
  "id": "33ad7aa8-31cc-4bc3-9151-649cbd38aecd",
  "type": "batch-response",
  "link": [
    {
      "relation": "self",
      "url": "http://localhost:8080/fhir"
    }
  ],
  "entry": [
    {
      "response": {
        "status": "201 Created",
        "location": "Patient/patient-saga-anderson-003/_history/1",
        "etag": "1",
        "lastModified": "2024-09-30T17:27:47.148+00:00",
        "outcome": {
          "resourceType": "OperationOutcome",
          "issue": [
            {
              "severity": "information",
              "code": "informational",
              "details": {
                "coding": [
                  {
                    "system": "https://hapifhir.io/fhir/CodeSystem/hapi-fhir-storage-response-code",
                    "code": "SUCCESSFUL_UPDATE_AS_CREATE",
                    "display": "Update as create succeeded."
                  }
                ]
              },
              "diagnostics": "Successfully created resource \"Patient/patient-saga-anderson-003/_history/1\" using update as create (ie. create with client assigned ID). Took 4ms."
            }
          ]
        }
      }
    },
    {
      "response": {
        "status": "201 Created",
        "location": "Practitioner/practitioner-emma-nelson-003/_history/1",
        "etag": "1",
        "lastModified": "2024-09-30T17:27:47.171+00:00",
        "outcome": {
          "resourceType": "OperationOutcome",
          "issue": [
            {
              "severity": "information",
              "code": "informational",
              "details": {
                "coding": [
                  {
                    "system": "https://hapifhir.io/fhir/CodeSystem/hapi-fhir-storage-response-code",
                    "code": "SUCCESSFUL_UPDATE_AS_CREATE",
                    "display": "Update as create succeeded."
                  }
                ]
              },
              "diagnostics": "Successfully created resource \"Practitioner/practitioner-emma-nelson-003/_history/1\" using update as create (ie. create with client assigned ID). Took 2ms."
            }
          ]
        }
      }
    },
    {
      "response": {
        "status": "201 Created",
        "location": "Organization/organization-nelson-family-practice-003/_history/1",
        "etag": "1",
        "lastModified": "2024-09-30T17:27:47.181+00:00",
        "outcome": {
          "resourceType": "OperationOutcome",
          "issue": [
            {
              "severity": "information",
              "code": "informational",
              "details": {
                "coding": [
                  {
                    "system": "https://hapifhir.io/fhir/CodeSystem/hapi-fhir-storage-response-code",
                    "code": "SUCCESSFUL_UPDATE_AS_CREATE",
                    "display": "Update as create succeeded."
                  }
                ]
              },
              "diagnostics": "Successfully created resource \"Organization/organization-nelson-family-practice-003/_history/1\" using update as create (ie. create with client assigned ID). Took 1ms."
            }
          ]
        }
      }
    },
    {
      "response": {
        "status": "201 Created",
        "location": "Encounter/encounter-eicr-saga-anderson-003/_history/1",
        "etag": "1",
        "lastModified": "2024-09-30T17:27:47.191+00:00",
        "outcome": {
          "resourceType": "OperationOutcome",
          "issue": [
            {
              "severity": "information",
              "code": "informational",
              "details": {
                "coding": [
                  {
                    "system": "https://hapifhir.io/fhir/CodeSystem/hapi-fhir-storage-response-code",
                    "code": "SUCCESSFUL_UPDATE_AS_CREATE",
                    "display": "Update as create succeeded."
                  }
                ]
              },
              "diagnostics": "Successfully created resource \"Encounter/encounter-eicr-saga-anderson-003/_history/1\" using update as create (ie. create with client assigned ID). Took 1ms."
            }
          ]
        }
      }
    },
    {
      "response": {
        "status": "201 Created",
        "location": "Condition/condition-covid19-003/_history/1",
        "etag": "1",
        "lastModified": "2024-09-30T17:27:47.200+00:00",
        "outcome": {
          "resourceType": "OperationOutcome",
          "issue": [
            {
              "severity": "information",
              "code": "informational",
              "details": {
                "coding": [
                  {
                    "system": "https://hapifhir.io/fhir/CodeSystem/hapi-fhir-storage-response-code",
                    "code": "SUCCESSFUL_UPDATE_AS_CREATE",
                    "display": "Update as create succeeded."
                  }
                ]
              },
              "diagnostics": "Successfully created resource \"Condition/condition-covid19-003/_history/1\" using update as create (ie. create with client assigned ID). Took 1ms."
            }
          ]
        }
      }
    },
    {
      "response": {
        "status": "201 Created",
        "location": "Observation/observation-covid19-pcr-003/_history/1",
        "etag": "1",
        "lastModified": "2024-09-30T17:27:47.210+00:00",
        "outcome": {
          "resourceType": "OperationOutcome",
          "issue": [
            {
              "severity": "information",
              "code": "informational",
              "details": {
                "coding": [
                  {
                    "system": "https://hapifhir.io/fhir/CodeSystem/hapi-fhir-storage-response-code",
                    "code": "SUCCESSFUL_UPDATE_AS_CREATE",
                    "display": "Update as create succeeded."
                  }
                ]
              },
              "diagnostics": "Successfully created resource \"Observation/observation-covid19-pcr-003/_history/1\" using update as create (ie. create with client assigned ID). Took 4ms."
            }
          ]
        }
      }
    },
    {
      "response": {
        "status": "201 Created",
        "location": "Observation/observation-rr-covid19-003/_history/1",
        "etag": "1",
        "lastModified": "2024-09-30T17:27:47.225+00:00",
        "outcome": {
          "resourceType": "OperationOutcome",
          "issue": [
            {
              "severity": "information",
              "code": "informational",
              "details": {
                "coding": [
                  {
                    "system": "https://hapifhir.io/fhir/CodeSystem/hapi-fhir-storage-response-code",
                    "code": "SUCCESSFUL_UPDATE_AS_CREATE",
                    "display": "Update as create succeeded."
                  }
                ]
              },
              "diagnostics": "Successfully created resource \"Observation/observation-rr-covid19-003/_history/1\" using update as create (ie. create with client assigned ID). Took 3ms."
            }
          ]
        }
      }
    },
    {
      "response": {
        "status": "201 Created",
        "location": "Observation/observation-condition-status-003/_history/1",
        "etag": "1",
        "lastModified": "2024-09-30T17:27:47.239+00:00",
        "outcome": {
          "resourceType": "OperationOutcome",
          "issue": [
            {
              "severity": "information",
              "code": "informational",
              "details": {
                "coding": [
                  {
                    "system": "https://hapifhir.io/fhir/CodeSystem/hapi-fhir-storage-response-code",
                    "code": "SUCCESSFUL_UPDATE_AS_CREATE",
                    "display": "Update as create succeeded."
                  }
                ]
              },
              "diagnostics": "Successfully created resource \"Observation/observation-condition-status-003/_history/1\" using update as create (ie. create with client assigned ID). Took 2ms."
            }
          ]
        }
      }
    },
    {
      "response": {
        "status": "201 Created",
        "location": "Observation/observation-eicr-status-003/_history/1",
        "etag": "1",
        "lastModified": "2024-09-30T17:27:47.251+00:00",
        "outcome": {
          "resourceType": "OperationOutcome",
          "issue": [
            {
              "severity": "information",
              "code": "informational",
              "details": {
                "coding": [
                  {
                    "system": "https://hapifhir.io/fhir/CodeSystem/hapi-fhir-storage-response-code",
                    "code": "SUCCESSFUL_UPDATE_AS_CREATE",
                    "display": "Update as create succeeded."
                  }
                ]
              },
              "diagnostics": "Successfully created resource \"Observation/observation-eicr-status-003/_history/1\" using update as create (ie. create with client assigned ID). Took 2ms."
            }
          ]
        }
      }
    },
    {
      "response": {
        "status": "201 Created",
        "location": "Composition/composition-eicr-covid19-003/_history/1",
        "etag": "1",
        "lastModified": "2024-09-30T17:27:47.260+00:00",
        "outcome": {
          "resourceType": "OperationOutcome",
          "issue": [
            {
              "severity": "information",
              "code": "informational",
              "details": {
                "coding": [
                  {
                    "system": "https://hapifhir.io/fhir/CodeSystem/hapi-fhir-storage-response-code",
                    "code": "SUCCESSFUL_UPDATE_AS_CREATE",
                    "display": "Update as create succeeded."
                  }
                ]
              },
              "diagnostics": "Successfully created resource \"Composition/composition-eicr-covid19-003/_history/1\" using update as create (ie. create with client assigned ID). Took 2ms."
            }
          ]
        }
      }
    },
    {
      "response": {
        "status": "201 Created",
        "location": "Composition/composition-rr-covid19-003/_history/1",
        "etag": "1",
        "lastModified": "2024-09-30T17:27:47.275+00:00",
        "outcome": {
          "resourceType": "OperationOutcome",
          "issue": [
            {
              "severity": "information",
              "code": "informational",
              "details": {
                "coding": [
                  {
                    "system": "https://hapifhir.io/fhir/CodeSystem/hapi-fhir-storage-response-code",
                    "code": "SUCCESSFUL_UPDATE_AS_CREATE",
                    "display": "Update as create succeeded."
                  }
                ]
              },
              "diagnostics": "Successfully created resource \"Composition/composition-rr-covid19-003/_history/1\" using update as create (ie. create with client assigned ID). Took 3ms."
            }
          ]
        }
      }
    }
  ]
}
```

All resources were successfully created, so we have a batch bundle that leverages both eICR and RR profiles, is valid (save for the few `Slice` related errors that are also present in the eCR IG's sample data), and successfully integrates with the HAPI FHRI server.

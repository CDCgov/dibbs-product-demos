# DIBBs Product Demos

## What is DIBBs?

### DIBBs

**Definition:**  
**DIBBs** (Data Integration Building Blocks) are microservice APIs designed to be connected in a variety of ways, enabling the construction of both simple and complex workflows.

**Pronunciation:**  
"DIBBs" sounds like when you say, "I call dibbs on the front seat" before a road trip.

**Usage:**  
DIBBs are modular components that can be flexibly combined to perform data integration tasks, supporting diverse and scalable solutions.

---

**Example in a Sentence:**

> "We'll use a few DIBBs to quickly set up the data pipeline for the eCR Parser."

---

**Key Characteristics:**

- **Modular:** Each DIBB is a standalone microservice API.
- **Flexible:** Can be integrated in various configurations to suit different needs.
- **Scalable:** Suitable for both simple tasks and complex data workflows.

> **ℹ️ General disclaimer:** This repository was created for use by CDC programs to collaborate on public health related projects in support of the [CDC mission](https://www.cdc.gov/about/organization/mission.htm). GitHub is not hosted by the CDC, but is a third party website used by CDC and its partners to share information and collaborate on software. CDC use of GitHub does not imply an endorsement of any one particular service, product, or enterprise.

## Overview

This goal of this repository is to provide a central location for DIBBs product demos. The repository will contain both code and the assets required to run the code for various DIBBs products in a variety of deployment environments. The goal is to meet State, Tribal, Local, and Territorial (STLT) public health staff where they are at. This will range from production cloud deployments to 'production-lite' settings with shared servers or on individual staff's host machine. Our goal is for the same solution to both work in a variety of settings and meet you where you're at both in terms of technical capacity and commitment to the tools we create.

## Current DIBBs Product Demos

- [eCR Parser](/ecr-parser/README.md): The eCR Parser enables users to extract relevant data from a given healthcare message and export the data into a simple JSON file that can be easily loaded into a tabular format (like a spreadsheet) based on a user-defined parsing schema. It does this by first converting the incoming eCR data, which is made up of Electronic Initial Case Report (eICR) files and their corresponding Reportability Response (RR) into the Fast Healthcare Interoperability Resources (FHIR) standard. Once files are in the FHIR format, jurisdictions can then configure the parsing schema to extract whatever fields they’re interested in using FHIRPath, a navigation and extraction language. By reducing the amount of unnecessary data that jurisdictions extract, the eCR Parser reduces the manual time spent on data wrangling and makes data analysis and investigation easier.

## Related documents

- [Open Practices](open_practices.md)
- [Rules of Behavior](rules_of_behavior.md)
- [Thanks and Acknowledgements](thanks.md)
- [Disclaimer](DISCLAIMER.md)
- [Contribution Notice](CONTRIBUTING.md)
- [Code of Conduct](code-of-conduct.md)

## Public Domain Standard Notice

This repository constitutes a work of the United States Government and is not
subject to domestic copyright protection under 17 USC § 105. This repository is in
the public domain within the United States, and copyright and related rights in
the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
All contributions to this repository will be released under the CC0 dedication. By
submitting a pull request you are agreeing to comply with this waiver of
copyright interest.

## License Standard Notice

The repository utilizes code licensed under the terms of the Apache Software
License and therefore is licensed under ASL v2 or later.

This source code in this repository is free: you can redistribute it and/or modify it under
the terms of the Apache Software License version 2, or (at your option) any
later version.

This source code in this repository is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the Apache Software License for more details.

You should have received a copy of the Apache Software License along with this
program. If not, see http://www.apache.org/licenses/LICENSE-2.0.html

The source code forked from other open source projects will inherit its license.

## Privacy Standard Notice

This repository contains only non-sensitive, publicly available data and
information. All material and community participation is covered by the
[Disclaimer](DISCLAIMER.md)
and [Code of Conduct](code-of-conduct.md).
For more information about CDC's privacy policy, please visit [http://www.cdc.gov/other/privacy.html](https://www.cdc.gov/other/privacy.html).

## Contributing Standard Notice

Anyone is encouraged to contribute to the repository by [forking](https://help.github.com/articles/fork-a-repo)
and submitting a pull request. (If you are new to GitHub, you might start with a
[basic tutorial](https://help.github.com/articles/set-up-git).) By contributing
to this project, you grant a world-wide, royalty-free, perpetual, irrevocable,
non-exclusive, transferable license to all users under the terms of the
[Apache Software License v2](http://www.apache.org/licenses/LICENSE-2.0.html) or
later.

All comments, messages, pull requests, and other submissions received through
CDC including this GitHub page may be subject to applicable federal law, including but not limited to the Federal Records Act, and may be archived. Learn more at [http://www.cdc.gov/other/privacy.html](http://www.cdc.gov/other/privacy.html).

## Records Management Standard Notice

This repository is not a source of government records, but is a copy to increase
collaboration and collaborative potential. All government records will be
published through the [CDC web site](http://www.cdc.gov).

## Additional Standard Notices

Please refer to [CDC's Template Repository](https://github.com/CDCgov/template) for more information about [contributing to this repository](https://github.com/CDCgov/template/blob/main/CONTRIBUTING.md), [public domain notices and disclaimers](https://github.com/CDCgov/template/blob/main/DISCLAIMER.md), and [code of conduct](https://github.com/CDCgov/template/blob/main/code-of-conduct.md).

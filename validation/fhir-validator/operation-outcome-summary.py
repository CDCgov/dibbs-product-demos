import json
from collections import defaultdict

# load json from the validation_output.json file
# this file is an OperationOutcome resource; see more at the link below
# https://www.hl7.org/fhir/r4/operationoutcome.html
with open("validation_output.json", "r") as f:
    data = json.load(f)

# initialize dictionaries to store counts and details from the OperationOutcome resource
# - severity_count:
#   the count of issues categorized by their severity (e.g., error, warning), indicating
#   how critical each issue is in the OperationOutcome resource.
severity_count = defaultdict(int)

# - issue_code_counts:
#   the count of issues grouped by their code, which categorizes the type of issue
#   (e.g., structure, required) as defined in the OperationOutcome.
issue_code_count = defaultdict(int)

# - error_details:
#   a list of human-readable descriptions (details.text) of specific issues,
#   grouped by the issue code, providing detailed explanations for each problem
#   in the OperationOutcome.
error_details = defaultdict(list)  # Organize details under issue codes

# iterate over the 'issue' section of the OperationOutcome resource
for issue in data.get("issue", []):
    # categorize by severity
    severity = issue.get("severity", "unknown")
    severity_count[severity] += 1

    # categorize by issue code
    code = issue.get("code", "unknown")
    issue_code_count[code] += 1

    # categorize by details text and associate it with the issue code
    details_text = issue.get("details", {}).get("text", "unknown")
    if details_text not in error_details[code]:
        error_details[code].append(details_text)

# create an output json object to store counts and details
output = {
    "severity_counts": dict(severity_count),
    "issue_code_counts": dict(issue_code_count),
    "error_details": dict(error_details),
}

# write the output of the result as a json file
with open("operation-outcome-summary.json", "w") as output_json:
    output_json.write(json.dumps(output, indent=4))
    print("OperationOutcome summary written to operation-outcome-summary.json")

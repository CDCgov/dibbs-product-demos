library(renv)
renv::load()

library(fs)
library(httr2)
library(jsonlite)
library(tidyverse)

message_parser <- "http://localhost:8085"
health_check <- str_glue("{message_parser}/")
parsing_schema <- str_glue("{message_parser}/schemas")
message_parser <- str_glue("{message_parser}/parse_message")

# check the health of the fhir converter
check_health <- function(endpoint_url) {
  resp <- request(endpoint_url) |>
    req_perform() |>
    resp_body_json()
  
  if (resp$status == "OK") {
    print("Message Parser is up and running.")
  } else {
    print("Message Parser is not running.")
  }
}

check_health(health_check)

# read in the parsing schema
print("Reading the parsing schema from 'config/ecr-parsing-schema.json'...")
ecr_parsing_schema <- read_json("config/ecr-parsing-schema.json")
print("Parsing schema loaded successfully.")

# put the parsing schema in the container to use
print("Uploading the parsing schema to the Message Parser...")
request(parsing_schema) |>
  req_url_path_append("/ecr-parsing-schema.json") |>
  req_method("PUT") |>
    req_headers(
    "Content-Type" = "application/json"
  ) |>
  req_body_json(data = list(
    parsing_schema = ecr_parsing_schema,
    overwrite = TRUE
  )) |>
  req_perform()
print("Parsing schema uploaded successfully.")

# extract the fhir bundle from the fhir converter's response
extract_fhir_bundle <- function(file_path) {
  print(str_glue("Extracting FHIR bundle from: {file_path}"))
  fromJSON(file_path) |>
    pluck("response", "FhirResource")
}

replace_null_and_unlist <- function(resp_list) {
  replaced <- map(resp_list, ~ if (is.null(.x)) NA_character_ else .x)
  result <- unlist(replaced)
  return(result)
}

# send the request to the message parser
send_request <- function(fhir_bundle) {
  print("Sending FHIR bundle to Message Parser...")
  response <- request(message_parser) %>%
    req_body_json(list(
      message_format = "fhir",
      message_type = "ecr",
      parsing_schema_name = "ecr-parsing-schema.json",
      message = fhir_bundle
    )) |>
    req_perform()
  print("Received response from Message Parser.")
  
  return(resp_body_json(response))
}

# function to process response and extract data into a dataframe
process_response <- function(response) {
  print("Processing the response...")
  demographics_list <- discard(response$parsed_values, names(response$parsed_values) %in% c("labs", "active_problems"))
  labs_list <- response$parsed_values |> pluck("labs")
  active_problems_list <- response$parsed_values |> pluck("active_problems")
  
  demographics_df <- demographics_list %>%
    replace_null_and_unlist() %>%
    enframe() %>%
    pivot_wider(names_from = name, values_from = value)
  
  if (!is.null(labs_list)) {
    labs_df <- labs_list |>
      map_dfr(~ replace_null_and_unlist(.x) |>
                enframe() |>
                pivot_wider(names_from = name, values_from = value))
    
    labs_df <- bind_cols(
      demographics_df |> select(patient_id, eicr_id, eicr_set_id, eicr_version_number, authoring_datetime),
      labs_df
    )
  } else {
    labs_df <- tibble()
  }
  
  if (!is.null(active_problems_list)) {
    active_problems_df <- active_problems_list |>
      map_dfr(~ replace_null_and_unlist(.x) |>
                enframe() |>
                pivot_wider(names_from = name, values_from = value))
    
    active_problems_df <- bind_cols(
      demographics_df |> select(patient_id, eicr_id, eicr_set_id, eicr_version_number, authoring_datetime),
      active_problems_df
    )
  } else {
    active_problems_df <- tibble()
  }
  
  print("Response processed successfully.")
  list(demographics = demographics_df, active_problems = active_problems_df, labs = labs_df)
}

# get list of fhir bundles to parse
print("Listing FHIR bundles in 'data/fhir-conversion' directory...")
files <- dir_ls("data/fhir-conversion", glob = "*.json")

# map over the files to get the data
results <- map(files, ~ {
  print(str_glue("Processing file: {.x}"))
  fhir_bundle <- extract_fhir_bundle(.x)
  response <- send_request(fhir_bundle)
  process_response(response)
})

# combine demographics and write to csv
print("Combining demographics data...")
demographics_all <- bind_rows(map(results, "demographics"))
demographics_output <- str_glue("data/flat-ecr/demographics-{Sys.Date()}.csv")
write_csv(demographics_all, demographics_output)
print(str_glue("Demographics data saved to: {demographics_output}"))

# combine and write active_problems to csv if there is data
print("Combining active problems data...")
active_problems_all <- bind_rows(map(results, "active_problems"), .id = NULL)
if (nrow(active_problems_all) > 0) {
  active_problems_output <- str_glue("data/flat-ecr/active-problems-{Sys.Date()}.csv")
  write_csv(active_problems_all, active_problems_output)
  print(str_glue("Active problems data saved to: {active_problems_output}"))
} else {
  print("No active problems data to save.")
}

# combine and write labs to csv if there is data
print("Combining labs data...")
labs_all <- bind_rows(map(results, "labs"), .id = NULL)
if (nrow(labs_all) > 0) {
  labs_output <- str_glue("data/flat-ecr/labs-{Sys.Date()}.csv")
  write_csv(labs_all, labs_output)
  print(str_glue("Labs data saved to: {labs_output}"))
} else {
  print("No labs data to save.")
}

print("Script execution completed.")

library(renv)
renv::load()

library(fs)
library(httr2)
library(jsonlite)
library(tidyverse)

# urls for the fhir converter service
fhir_converter <- "http://localhost:8082"
health_check <- str_glue("{fhir_converter}/")
convert_to_fhir <- str_glue("{fhir_converter}/convert-to-fhir")

# check the health of the fhir converter
check_health <- function(endpoint_url) {
  resp <- request(endpoint_url) |>
    req_perform() |>
    resp_body_json()
  
  if (resp$status == "OK") {
    print("FHIR Converter is up and running.")
  } else {
    print("FHIR Converter is not running.")
  }
}

check_health(health_check)

# define directories
# go up one level from the current script location
ecr_data_directory <- path("data", "eicr-and-rr")
fhir_bundle_directory <- path("data", "fhir-conversion")

# function to read and collapse xml content into a single string
read_and_collapse_xml <- function(file_path) {
  print(str_glue("Reading file: {file_path}"))
  xml_content <- readLines(file_path, warn = FALSE)
  paste(xml_content, collapse = "\n")
}

# function to create a json payload
create_json_payload <- function(eicr_content, rr_content, input_type = "ecr", root_template = "EICR") {
  list(
    input_data = eicr_content,
    input_type = input_type,
    root_template = root_template,
    rr_data = rr_content
  )
}

# function to send post request to the api
send_post_request <- function(api_url, data) {
  print("Sending request with data...")

  response <- request(api_url) |>
    req_body_json(data) |>
    req_perform()

  status <- resp_status(response)
  print(str_glue("Response status: {status}"))

  return(response)
}

# function to save json response to a file
save_json_response <- function(response, file_id, output_dir) {
  json_response <- resp_body_json(response)
  json_file_path <- path(output_dir, str_glue("{file_id}-bundle.json"))
  write_json(json_response, json_file_path, pretty = TRUE, auto_unbox = TRUE)

  return(json_file_path)
}

# function to generate the rr file path based on the eicr file path
get_rr_file_path <- function(eicr_file_path) {
  file_name <- path_file(eicr_file_path)

  if (str_detect(file_name, "_eICR")) {
    rr_file_name <- str_replace(file_name, "_eICR", "_RR")
  } else if (str_detect(file_name, "_eicr")) {
    rr_file_name <- str_replace(file_name, "_eicr", "_RR")
  }

  return(path(path_dir(eicr_file_path), rr_file_name))
}

# function to process eicr files and send them to the fhir converter
process_files <- function(data_dir, output_dir, api_url) {
  print("Starting file processing...")
  file_list <- dir_ls(data_dir, glob = "*_eicr.xml|*_eICR.xml")

  for (eicr_file_path in file_list) {
    print(str_glue("Processing file: {eicr_file_path}"))
    rr_file_path <- get_rr_file_path(eicr_file_path)
    print(str_glue("Corresponding RR file: {rr_file_path}"))

    if (!file_exists(rr_file_path)) {
      print(str_glue("RR file does not exist for: {eicr_file_path}"))
      next
    }

    eicr_content <- read_and_collapse_xml(eicr_file_path)
    rr_content <- read_and_collapse_xml(rr_file_path)

    file_id <- str_split(path_file(eicr_file_path), "_CDA_eICR|_eICR|_eicr")[[1]][[1]]
    print(str_glue("File ID: {file_id}"))

    data <- create_json_payload(
      eicr_content = eicr_content, 
      rr_content = rr_content)

    tryCatch({
      response <- send_post_request(api_url, data)
      
      if (resp_status(response) == 200) {
        print(str_glue("Successfully converted the XML files for ID: {file_id}"))
        json_file_path <- save_json_response(response, file_id, output_dir)
        print(str_glue("Saved JSON response for ID: {file_id} to {json_file_path}"))
      } else {
        print(str_glue("Failed to convert the XML files for ID: {file_id}\nStatus code: {resp_status(response)}"))
        print(str_glue("Response content: {resp_body_string(response)}"))
      }
    }, error = function(e) {
      print(str_glue("Error during the request for ID {file_id}: {e$message}"))
    })
  }
  print("File processing complete.")
}

# start the file processing
process_files(data_dir = ecr_data_directory, output_dir = fhir_bundle_directory, api_url = convert_to_fhir)

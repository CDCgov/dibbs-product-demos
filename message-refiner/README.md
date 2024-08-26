# Message Refiner

## Spinning up the services

Using the `docker-compose.yaml` file we will pull the two DIBBs that we want to use and get them up and running locally.

- `message-refiner` - This is the service that will take an eICR XML file and refine it based on query parameters.
- `trigger-code-reference` - This is the service that query the trigger codes for eCR data look for related clinical codes.

We want to make sure we're in the folder 'message-refiner' where the `docker-compose.yaml` file is located. Then we'll then run:

```{bash}
docker compose up -d
```

To make sure they're up and running, use this command:

```{bash}
docker ps
```

You should see the two services running:

```{bash}
CONTAINER ID   IMAGE                                               COMMAND                  CREATED         STATUS         PORTS                                       NAMES
5e98ceffcb54   ghcr.io/cdcgov/phdi/message-refiner:latest          "/bin/sh -c 'uvicorn…"   2 seconds ago   Up 2 seconds   0.0.0.0:8087->8080/tcp, :::8087->8080/tcp   message-r
efiner
64945637c738   ghcr.io/cdcgov/phdi/trigger-code-reference:latest   "/bin/sh -c 'uvicorn…"   2 seconds ago   Up 2 seconds   0.0.0.0:8086->8080/tcp, :::8086->8080/tcp   trigger-c
ode-reference
```

## Getting the sample Postman collection

To get the sample postman collection run the following `curl` command to download the collection file that you will then run

```{bash}
curl -JO http://localhost:8087/example-collection
```

This will download a file from the API using the suggested filename so you can load it into Postman, a GUI for making API requests.

> [!INFO] > `curl` is a command line tool used to transfer data from or to a server using various protocols. If you do not have `curl` installed on your system, don't worry! You can download the file you need [here](https://github.com/CDCgov/phdi/blob/main/containers/message-refiner/assets/Message_Refiner_UAT.postman_collection.json). On the right hand side you'll see the word "Raw", next to it a button to copy the text, and next to that a button to download the file.

## Running the sample Postman collection

### Download Postman

If you do not have Postman installed on your system, you can download it [here](https://www.postman.com/downloads/).

### Load the collection

To load the Postman collection you just downloaded, open Postman and click on the "Import" button in the top left corner. Then click on "Choose Files" and select the file you just downloaded.

The collection has a number of different requests that you can run to test the API. To run a request, click on the request in the left hand panel and then click on the "Send" button. You should see the response from the API in the main panel.

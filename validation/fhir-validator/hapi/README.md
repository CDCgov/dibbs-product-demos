# HAPI FHIR Server with PostgreSQL via Docker Compose

This directory contains a Docker Compose setup to run the HAPI FHIR server backed by a PostgreSQL database.

## What is HAPI FHIR?

HAPI FHIR is a Java-based implementation of the HL7 FHIR (Fast Healthcare Interoperability Resources) standard for exchanging healthcare information electronically. It provides a robust framework to build and deploy FHIR-compliant applications, including a server capable of storing and retrieving FHIR resources. This setup allows you to quickly spin up a local HAPI FHIR server to:

- Test FHIR-based integrations.
- Validate FHIR resources.
- Develop FHIR applications in a controlled environment.

For more details about HAPI FHIR, visit the official website.

## Quick Start

1. Start the services using Docker Compose:

```bash
docker compose up -d
```

This command will:

- Start the PostgreSQL database in a container.
- Start the HAPI FHIR server in a container, configured to connect to the PostgreSQL database.

2. Access the HAPI FHIR server:

- Open your browser and go to `http://localhost:8080` to interact with the HAPI FHIR interface.

## Docker Compose Overview

The `docker-compose.yaml` file defines two services:

1. `fhir`:

- Runs the HAPI FHIR server.
- Exposes port `8080` to allow access to the FHIR server.
- Configured to use PostgreSQL as its database backend.

2. `db`:

- Runs a PostgreSQL database.
- Stores persistent data in the volume `hapi-postgres-data`.

## Configuration

- **HAPI FHIR** is configured to use PostgreSQL via environment variables defined in the `docker-compose.yaml` file.

- The PostgreSQL database is set up with:
  - Username: `admin`
  - Password: `admin`
  - Database Name: `hapi`

## Persistent Data

- The PostgreSQL data is persisted locally using Docker volumes. The database files are stored in `./hapi.postgres.data` on your machine, ensuring that FHIR data remains available even if you stop and restart the containers.

## Managing the Containers

- Stop the containers:

```bash
docker compose down
```

- Restart the containers:

```bash
docker compose up -d
```

## Logs and Debugging

- To view the logs for the HAPI FHIR server:

```bash
docker compose logs fhir
```

- To view the logs for the PostgreSQL database:

```bash
docker compose logs db
```

## Customization

- You can modify the `docker-compose.yaml` file to adjust the database credentials, port mapping, or other service configurations.
- For different use cases, you can also customize the FHIR server behavior by updating the environment variables.

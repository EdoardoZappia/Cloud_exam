## Deployment

The deployment of our Nextcloud-based file storage system utilizes Docker and docker-compose, enabling a straightforward and efficient setup process on a laptop. This section outlines the deployment plan, leveraging the provided `docker-compose.yml` file to create a local containerized environment.

- **Preparation**: Ensure Docker and docker-compose are installed and running on the laptop. Place the `docker-compose.yml` file in a dedicated project directory.

- **Configuration**: The `docker-compose.yml` file defines two main services:
  - `db` (MariaDB database)
  - `app` (Nextcloud application)
  
  It also specifies volumes for persistent storage and a dedicated network for inter-service communication.

- **Deployment Execution**:
  1. Navigate to the project directory in a terminal.
  2. Run `docker-compose up -d`. This command pulls the necessary images, creates volumes for data persistence, sets up the network, and starts the services in detached mode.
  3. Once the containers are running, Nextcloud is accessible via [http://localhost:8080](http://localhost:8080), where you can complete the setup through the web interface.

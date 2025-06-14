# YARP Worker

![Quality Gate Status](https://sonarqube.etherlab.com.br/api/project_badges/quality_gate?project=guilhermelinosp_yarp-worker_a2c93dff-a9c3-4e98-a7cd-d89135f556d1&token=sqb_73ba6590e253f29ee88277220697b2e9552dca6e)

YARP Worker is a background worker service built with YARP (Yet Another Reverse Proxy) to handle asynchronous tasks for web applications. It leverages .NET and YARP for scalable task processing and reverse proxy capabilities.

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Features
- Asynchronous task processing with YARP integration
- Configurable reverse proxy for routing tasks
- SonarQube integration for code quality

## Prerequisites
- [.NET SDK](https://dotnet.microsoft.com/download) (version 8.0 or higher)
- Access to [SonarQube instance](https://sonarqube.etherlab.com.br) for code quality checks (optional)

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/guilhermelinosp/yarp-worker.git
   cd yarp-worker
   ```
2. Restore dependencies:
   ```bash
   dotnet restore
   ```
3. Build the project:
   ```bash
   dotnet build
   ```

## Configuration
1. Copy the example configuration file:
   ```bash
   cp appsettings.json.example appsettings.json
   ```
2. Update `appsettings.json` with your settings (e.g., YARP routes, database connections).
3. (Optional) Set environment variables:
   ```bash
   export SONARQUBE_TOKEN="your_token_here"
   ```

## Usage
1. Run the application:
   ```bash
   dotnet run
   ```
2. Access the service at `http://localhost:5000`.
3. Monitor code quality via the [SonarQube dashboard](https://sonarqube.etherlab.com.br/dashboard?id=guilhermelinosp_yarp-worker_a2c93dff-a9c3-4e98-a7cd-d89135f556d1).

Example API call:
```bash
curl -X POST http://localhost:5000/api/task -d '{"task":"example"}' -H "Content-Type: application/json"
```

## Contributing
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit changes (`git commit -m 'Add your feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

Ensure code passes SonarQube checks.

## License
This project is licensed under the [MIT License](LICENSE).

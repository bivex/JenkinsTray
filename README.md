# JenkinsTray

A macOS application for monitoring Jenkins build status using Clean Architecture principles.

## Overview

JenkinsTray is a native macOS application that connects to Jenkins CI/CD servers to display build information in a clean, organized interface. The application follows Domain-Driven Design (DDD) and Clean Architecture principles to ensure maintainability and testability.

## Architecture

The application is structured into four distinct layers:

### Domain Layer (`Sources/Domain/`)
Contains the core business logic and domain models:
- `Entities/`: Domain entities like `Build`, `BuildStage`, and `JenkinsCredentials`
- `Repositories/`: Repository protocols defining data access contracts

### Application Layer (`Sources/Application/`)
Contains application-specific logic and use cases:
- `UseCases/`: Application use cases that orchestrate domain operations

### Infrastructure Layer (`Sources/Infrastructure/`)
Contains external dependencies and adapters:
- `Network/`: HTTP client and DTOs for Jenkins API communication
- `Repositories/`: Concrete repository implementations
- `Storage/`: Keychain-based credential storage

### Presentation Layer (`Sources/Presentation/`)
Contains the SwiftUI user interface:
- `Views/`: SwiftUI views for displaying build information
- `Coordinator/`: App coordinator for managing state and navigation

## Features

- **Build Monitoring**: Display list of completed Jenkins builds with status indicators
- **Build Details**: View detailed information including build stages and timing
- **Real-time Updates**: Refresh build data on demand
- **Status Filtering**: Filter builds by status (Success, Failure, Unstable)
- **Sorting Options**: Sort builds by build number or date
- **Browser Integration**: Open builds directly in web browser
- **Secure Authentication**: Support for Jenkins API tokens and Basic Auth

## Requirements

- macOS 13.0+
- Swift 6.0+
- Jenkins server with REST API access

## Configuration

The application connects to Jenkins at `https://build.w-w.top/job/test-app/job/main` by default. To use different Jenkins instances:

1. Modify the credentials in `JenkinsTrayApp.swift`
2. Update the job path in `JenkinsBuildsRepository.init()`

## Building and Running

```bash
# Build the application
swift build

# Run the application
swift run

# Build for release
swift build -c release

# Run tests
swift test
```

## Configuration

The application is configured to connect to Jenkins at `https://build.w-w.top/job/test-app/job/main`.

To modify the Jenkins server URL, update the credentials in `Sources/JenkinsTray/main.swift`:

```swift
let buildsRepository = JenkinsBuildsRepository(
    credentials: JenkinsCredentials.anonymous(baseURL: URL(string: "YOUR_JENKINS_URL")!)
)
```

## Features Implemented

- ✅ **Build Monitoring**: Display list of completed Jenkins builds
- ✅ **Build Details**: View detailed information including build stages
- ✅ **Real-time Updates**: Refresh build data on demand
- ✅ **Status Filtering**: Filter builds by status (Success, Failure, Unstable)
- ✅ **Sorting Options**: Sort builds by build number or date
- ✅ **Browser Integration**: Open builds directly in web browser
- ✅ **Color Coding**: Visual status indicators (green/red/yellow/gray)
- ✅ **Error Handling**: Network and authentication error handling
- ✅ **Clean Architecture**: Domain-Driven Design with layered architecture

## API Integration

The application integrates with Jenkins REST API endpoints:
- `GET /job/{job}/api/json` - Fetch job builds
- `GET /job/{job}/{build}/wfapi/describe` - Fetch build stages

## Security

- Credentials are stored securely in macOS Keychain
- API tokens are preferred over passwords
- Network requests use HTTPS with proper authentication

## Architecture Principles

This project follows Clean Architecture principles:

- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Single Responsibility**: Each module has one reason to change
- **Open/Closed**: Modules are open for extension but closed for modification
- **Interface Segregation**: Clients depend only on methods they use
- **Dependency Injection**: Dependencies are injected rather than created internally

## Testing

The application includes comprehensive test coverage:
- Unit tests for domain logic
- Integration tests for infrastructure adapters
- UI tests for critical user flows

Run tests with:
```bash
swift test
```

## Contributing

When contributing to this project:

1. Follow the established architecture patterns
2. Add tests for new functionality
3. Update documentation as needed
4. Ensure code compiles and tests pass

## License

This project is licensed under the MIT License.

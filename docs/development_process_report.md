# Development Process Report for the SmartBus Mobile Application

## 1. Introduction

SmartBus is an ongoing final year project aimed at improving the way passengers interact with public bus transport services. The application is being developed as a mobile-first system that allows users to register, log in, browse available bus routes, view route details, purchase tickets, manage wallet balance, and receive service alerts. The project responds to common public transport challenges such as limited route visibility, manual ticket handling, difficulty tracking fare payments, and lack of timely passenger communication.

The current implementation is built using Flutter, which supports cross-platform development for Android, iOS, web, and desktop targets from a single codebase. The application integrates with a remote backend API for authentication, routes, tickets, wallet data, and alerts. Since development is still ongoing, the current report focuses on the development activities completed so far, the implemented modules, technical decisions, challenges encountered, and the remaining work required before final deployment.

## 2. Project Objectives

The main objective of the SmartBus application is to provide a digital platform that makes bus transport access more convenient, organized, and traceable for passengers.

Specific objectives include:

- To allow passengers to create accounts, log in securely, and verify registration using OTP.
- To provide a list of available bus routes and enable passengers to search for routes.
- To display detailed route information, including stops, distance, duration, fare, and route progression.
- To support digital ticket purchase based on selected boarding and drop-off stops.
- To generate and display ticket information that can be used for validation.
- To provide wallet balance and transaction history features.
- To notify passengers about service updates, delays, ticket events, and wallet activities.
- To support user preferences such as theme mode and language selection.

## 3. Development Methodology

The project follows an iterative and incremental development approach. Instead of building the entire system at once, the application is divided into smaller functional modules that are designed, implemented, tested, and improved step by step.

The major development phases followed so far are:

1. Requirement identification and feature planning.
2. Flutter project setup and dependency configuration.
3. User interface design for authentication, routes, tickets, wallet, and alerts.
4. Backend API integration using Dio.
5. State management implementation using GetX.
6. Local storage setup using SharedPreferences.
7. Error handling, loading states, and user feedback integration.
8. Ongoing testing, debugging, and refinement.

This approach has made it easier to build the application progressively while still allowing improvements as new requirements emerge.

## 4. Tools and Technologies Used

The following tools and technologies are currently used in the project:

| Category | Technology |
| --- | --- |
| Framework | Flutter |
| Programming language | Dart |
| State management | GetX |
| API client | Dio |
| Local storage | SharedPreferences |
| Navigation | GetX routing and Persistent Bottom Navigation Bar |
| UI responsiveness | Flutter ScreenUtil |
| Maps/routes support | Flutter OSM Plugin |
| Notifications | Awesome Notifications |
| QR code display | qr_flutter |
| Image and SVG handling | cached_network_image, flutter_svg |
| Loading effects | shimmer, loading_animation_widget |
| Logging | logger |
| Main backend API | `https://smart-bus-y0ky.onrender.com/api` |

Flutter was selected because it allows fast development of visually consistent mobile interfaces and supports future expansion to other platforms.

## 5. System Architecture

The SmartBus application currently follows a layered structure that separates presentation, state management, data models, configuration, and reusable widgets.

The main folders used in the `lib` directory include:

- `screens`: Contains the main application screens such as login, signup, OTP verification, home, route search, route detail, ticket, wallet, and alerts.
- `controllers`: Contains GetX controllers responsible for managing business logic, API calls, loading states, and screen data.
- `models`: Contains data models such as user, route, stop, ticket, transaction, driver, passenger, and student.
- `config`: Contains configuration files for API setup, local storage, theme, and translations.
- `constants`: Contains reusable constants such as colors, routes, API base URLs, and asset references.
- `widgets`: Contains reusable UI components such as buttons, input fields, cards, loading widgets, and footer components.
- `utils`: Contains helper utilities, wrappers, animation helpers, error templates, and date/time conversion functions.

This structure improves maintainability because each major responsibility is placed in a clear part of the codebase.

## 6. Development Process by Module

### 6.1 Project Initialization

The project was initialized as a Flutter application named `smartbus`. After setup, important dependencies were added to support networking, local storage, state management, navigation, notifications, maps, icons, animations, QR codes, and responsive design.

The application entry point is `main.dart`. During startup, Flutter bindings are initialized, shared preferences are loaded, and the root application widget is launched. The app uses `GetMaterialApp` to manage routing, theme, and application-level state.

### 6.2 Authentication Module

The authentication module was developed to allow passengers to create accounts and access the application securely. It currently includes:

- Login using email, phone number, or FID.
- User registration with full name, email, phone number, password, and FID.
- OTP verification after registration.
- OTP resend functionality.
- Logout functionality.
- Token storage after successful authentication.

The `AuthController` manages authentication logic. It validates user input, sends requests to the backend API, stores access and refresh tokens, and redirects users to the appropriate screen after authentication.

The app also includes token refresh logic in the API configuration. When an access token expires, the app attempts to refresh it using the saved refresh token. If token refresh fails, the user is logged out and redirected to the login screen. This improves session continuity and reduces unnecessary login interruptions.

### 6.3 Route Management Module

The route management module allows passengers to view available routes and search for specific routes. This is handled mainly by the `RouteController`, which communicates with the following backend endpoints:

- `GET /v1/routes`
- `GET /v1/routes/search`
- `GET /v1/routes/{id}`

The home screen displays available routes, while the route search screen allows users to search based on route names or related input. The route detail screen shows more complete route information, including stops, route statistics, fare information, and stop selection.

Route data is represented using the `Route` model. The model converts backend data into usable Flutter objects and also supports multilingual route names based on the selected locale.

### 6.4 Ticketing Module

The ticketing module is one of the core parts of the SmartBus system. It allows passengers to view ticket history, identify an active ticket, and purchase a new ticket for a selected route.

The `TicketController` currently supports:

- Fetching all tickets from the backend.
- Identifying the active ticket from ticket history.
- Purchasing a ticket using selected route, boarding stop, and drop-off stop.
- Sending an idempotency key during ticket purchase to reduce duplicate transaction risk.

Ticket data is represented using the `Ticket` model, which includes ticket ID, passenger ID, route ID, selected stops, fare amount, status, QR payload, QR signature, purchase time, expiry time, and related route or stop data.

The ticket screen separates active tickets from ticket history. The ticket detail screen provides detailed information about a selected ticket and can display QR-related ticket data for validation.

### 6.5 Wallet Module

The wallet module was developed to support digital fare payment. It currently allows the user to view wallet balance, see transaction history, and add funds.

The `WalletController` communicates with the backend using:

- `GET /v1/wallet/balance`
- `GET /v1/wallet/transactions`
- `POST /v1/wallet/topup`

The wallet balance is converted from minor currency units into Birr for user display. Transactions are mapped into a `WalletTransaction` model and shown in the wallet screen. During top-up, the system sends an idempotency key to reduce the chance of duplicate top-up requests.

At the current stage, the payment method is still represented in a simplified way, and future work may include full integration with real payment providers such as Telebirr or bank-based payment gateways.

### 6.6 Alerts Module

The alerts module provides passengers with notifications and updates. It retrieves alerts from the backend through `GET /v1/alerts`. If the API fails or no data is available during testing, the controller provides mock alert data so the interface can still be tested.

The current alert types include examples such as:

- Route delay notifications.
- Wallet top-up success messages.
- Ticket expiry messages.

The module also includes a local `markAllAsRead` function, which updates the read status on the client side. Backend synchronization for read status is planned as future work.

### 6.7 User Interface and Navigation

The application interface is organized around a persistent bottom navigation layout. The main navigation tabs are:

- Routes
- My Ticket
- Wallet
- Alerts

This structure was selected because these are the main passenger workflows and should be accessible quickly after login.

The UI uses reusable widgets for buttons, input fields, cards, loading animations, and error states. The application also includes custom theme handling and supports light/dark mode through `ThemeModeController`.

### 6.8 Localization and Preferences

The project includes initial localization support using GetX translations. English and Amharic translation entries are currently defined. The app stores language and theme preferences using SharedPreferences, making it possible to preserve user settings between sessions.

Some translation text still requires cleanup and verification, especially the Amharic text encoding. This will be handled in a later refinement phase.

### 6.9 API Integration and Error Handling

The backend API integration is implemented using Dio. A central `DioConfig` class defines the API base URL, timeout values, request logging, and authentication interception.

The application uses a shared `DioService` template for `GET` and `POST` requests. Controllers pass success and failure callbacks to update UI state depending on the API response.

Error handling currently includes:

- Network timeout handling.
- Bad response handling.
- Unauthorized response handling.
- Token refresh on expired sessions.
- Snackbar messages for user feedback.
- Error utility assets for common error states.

This has helped make the application more resilient while development and backend integration continue.

## 7. Current Project Status

The application is still under development. The following features have been implemented or partially implemented:

| Feature | Status |
| --- | --- |
| Flutter project setup | Completed |
| Authentication screens | Implemented |
| Login and registration API integration | Implemented |
| OTP verification | Implemented |
| Token storage and refresh | Implemented |
| Main bottom navigation | Implemented |
| Route listing | Implemented |
| Route search | Implemented |
| Route detail display | Implemented |
| Ticket purchase | Implemented |
| Active ticket and ticket history | Implemented |
| Wallet balance | Implemented |
| Wallet transactions | Implemented |
| Wallet top-up request | Partially implemented |
| Alerts display | Partially implemented |
| Localization | Partially implemented |
| Notifications | Dependency added; full integration ongoing |
| Payment gateway integration | Pending |
| Full testing and deployment | Pending |

## 8. Challenges Encountered

Several challenges have been encountered during development:

- Designing a clear user flow for route selection, stop selection, and ticket purchase.
- Managing authentication state and token expiry without disrupting the user experience.
- Handling API failures while still allowing UI testing to continue.
- Converting backend monetary values from minor units into user-friendly Birr values.
- Keeping the codebase organized as features such as wallet, tickets, routes, and alerts grow.
- Preparing the app for multilingual support while ensuring translated text displays correctly.
- Coordinating frontend development with backend endpoint structure and response formats.

These challenges have been handled through modular design, controller-based state management, reusable API templates, and progressive testing.

## 9. Testing and Validation

Testing is currently ongoing. The main testing activities performed so far include:

- Manual testing of screen navigation.
- Manual testing of login, registration, OTP verification, and logout flows.
- API response testing through the Flutter app.
- Validation of loading states and error messages.
- Checking ticket purchase and wallet request behavior.
- Verifying that data models correctly parse backend responses.

Further testing planned includes:

- Unit tests for controllers and data models.
- Widget tests for main screens.
- Integration tests for authentication, route search, ticket purchase, and wallet top-up.
- Network failure testing.
- Usability testing with sample users.
- Final Android build testing on physical devices.

## 10. Remaining Work

The following tasks remain before the project can be considered complete:

- Complete real payment gateway integration.
- Improve and finalize alert notification behavior.
- Fully test ticket QR code generation and validation flow.
- Clean up and verify all translations.
- Improve form validation and user-facing error messages.
- Add more automated tests.
- Optimize UI responsiveness across different screen sizes.
- Finalize backend integration for all pending endpoints.
- Prepare release build configuration.
- Conduct final usability testing and document results.

## 11. Lessons Learned

The development process has provided practical experience in mobile application development, API integration, state management, and user-centered interface design. The project has also highlighted the importance of planning data models carefully, handling errors gracefully, and designing features in small testable modules.

Working with Flutter and GetX has made it possible to build screens quickly while maintaining reactive state updates. Dio has provided flexibility for backend communication, especially for authentication headers, token refresh, and request logging. The project has also shown the importance of aligning frontend development closely with backend response structures.

## 12. Conclusion

The SmartBus application is an ongoing final year project that aims to digitize and simplify passenger interaction with bus transport services. The current implementation already provides the foundation for authentication, route discovery, digital ticketing, wallet management, and alerts. Although some parts are still incomplete, the system has reached a functional stage where the main user workflows can be demonstrated and further refined.

The next stage of development will focus on completing payment integration, improving notification behavior, strengthening testing, polishing the user interface, and preparing the application for final evaluation and deployment.


# SmartBus: Mobile Route Search Integration Guide

This guide details how the **SmartBus** Flutter mobile application can fully utilize the backend `/v1/routes/search` endpoint to deliver a premium, responsive, and fully interactive route search experience.

---

## 🗺️ 1. Backend Search API Reference

The backend exposes a highly flexible search endpoint designed to handle both keyword searches and structured origin-to-destination planning.

### Endpoint Details
* **Method:** `GET`
* **Path:** `/v1/routes/search`
* **Auth Required:** Bearer Token (`Authorization: Bearer <token>`)

### Query Parameters

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `q` | `string` | *Optional* | A general keyword search matched against the **Route Number**, **Route Name**, or **Stop Names**. |
| `departure` | `string` | *Optional* | Restricts results to routes containing stops that match the departure stop name. |
| `destination` | `string` | *Optional* | Restricts results to routes containing stops that match the destination stop name. |
| `page` | `number` | `1` | Pagination page number. |
| `limit` | `number` | `20` | Maximum items to return per page. |
| `sortBy` | `string` | `'createdAt'` | Supported database keys: `createdAt`, `updatedAt`, `name`, `routeNumber`. |
| `sortOrder` | `'asc' \| 'desc'` | `'desc'` | The sorting order direction. |

> [!NOTE]
> If both `departure` and `destination` are provided, the backend returns routes that contain both stops (directionality/sequencing is a trip-level concern and not enforced at the route definition level).

---

### 📦 Sample API Response (`200 OK`)
```json
{
  "data": {
    "items": [
      {
        "id": "7ac9986b-a25e-4efb-91cc-a035d8e7cb76",
        "routeNumber": "R-10",
        "name": "Bole to Megenagna via Edna Mall",
        "description": "High-frequency route connecting Bole airport region to Megenagna transit center",
        "isActive": true,
        "duration": 25,
        "distance": 8400,
        "startStopName": "Bole Airport",
        "endStopName": "Megenagna Hub",
        "totalStops": 6,
        "price": 15.00,
        "stops": [
          {
            "id": "e8a946-...",
            "name": "Bole Airport",
            "sequence": 1,
            "latitude": 9.001,
            "longitude": 38.784,
            "distanceFromPrevious": null,
            "distanceToNext": 1200,
            "durationFromPrevious": null,
            "durationToNext": 4
          }
          // Additional stops...
        ],
        "fares": [
          {
            "fromStopId": "e8a946-...",
            "toStopId": "f9b752-...",
            "fromStopSequence": 1,
            "toStopSequence": 6,
            "amount": 15.00
          }
        ],
        "createdAt": "2026-05-18T10:00:00.000Z",
        "updatedAt": "2026-05-19T06:00:00.000Z"
      }
    ]
  }
}
```

---

## 🔍 2. Current Implementation Gaps

Analyzing the open files shows that the search screen is currently visual-only and lacks functional data binding:

1. **Inert UI Input Fields:**
   In [route_search_screen.dart](file:///c:/flutter_dev/projects/smartbus/lib/screens/route_search_screen.dart#L97-L108), the departure and destination text fields are instantiated using standard `_SearchField` placeholder blocks. They do not have `TextEditingController`s assigned, nor do they listen to inputs (`onChanged` is not registered).
2. **Missing Search Parameter Mapping:**
   In [route_controller.dart](file:///c:/flutter_dev/projects/smartbus/lib/controllers/route_controller.dart#L184-L214), the `searchRoutes` method only supports passing a single string `q`. The structured `departure` and `destination` fields cannot currently be sent to the API.
3. **Static Filter Chips:**
   The horizontal filter chips ("Lowest Price", "Fastest", "Route Num") do not trigger sorting actions.

---

## 🛠️ 3. Step-by-Step Integration Plan

### Step 1: Upgrade `RouteController` for Advanced Searching
Modify the controller to handle separate reactive search arguments and pass them cleanly to the API.

Add the following code block to [route_controller.dart](file:///c:/flutter_dev/projects/smartbus/lib/controllers/route_controller.dart):

```dart
// Reactive properties to store search parameters
final searchDeparture = ''.obs;
final searchDestination = ''.obs;
final searchKeyword = ''.obs;

/// Trigger a search query with explicit support for all backend query parameters
Future<void> searchRoutesAdvanced({
  String? q,
  String? departure,
  String? destination,
}) async {
  // Sync state variables
  if (q != null) searchKeyword.value = q;
  if (departure != null) searchDeparture.value = departure;
  if (destination != null) searchDestination.value = destination;

  // If all fields are empty, clear search and exit
  if (searchKeyword.value.isEmpty &&
      searchDeparture.value.isEmpty &&
      searchDestination.value.isEmpty) {
    searchResults.clear();
    searchStatus.value = ApiCallStatus.holding;
    return;
  }

  isLoading.value = true;
  searchStatus.value = ApiCallStatus.loading;
  searchError.value = null;

  // Build query map dynamically (only include non-empty values)
  final Map<String, dynamic> params = {};
  if (searchKeyword.value.isNotEmpty) params['q'] = searchKeyword.value;
  if (searchDeparture.value.isNotEmpty) params['departure'] = searchDeparture.value;
  if (searchDestination.value.isNotEmpty) params['destination'] = searchDestination.value;

  await DioService.dioGet(
    path: '/v1/routes/search',
    queryParameters: params,
    onSuccess: (response) {
      final List items = response.data['data']['items'] ?? response.data['data'] ?? [];
      searchResults.value = items.map((e) => Route.fromJson(e)).toList();
      
      // OPTIONAL: Client-side sorting because backend price/duration are computed
      _applyClientSortToSearchResults();
      
      isLoading.value = false;
      searchStatus.value = searchResults.isEmpty 
          ? ApiCallStatus.empty 
          : ApiCallStatus.success;
    },
    onFailure: (error, response) async {
      isLoading.value = false;
      final err = await ErrorUtil.getErrorData(error.toString());
      searchError.value = err;
      searchStatus.value = ApiCallStatus.error;
      _handleError(error, response);
    },
  );
}

/// Dynamic client-side sorting since backend fields 'price' & 'duration' are computed 
void _applyClientSortToSearchResults() {
  final sortBy = currentSortBy.value;
  final isAsc = currentSortOrder.value == 'asc';
  
  searchResults.sort((a, b) {
    if (sortBy == 'price') {
      return isAsc 
          ? (a.price ?? 0.0).compareTo(b.price ?? 0.0) 
          : (b.price ?? 0.0).compareTo(a.price ?? 0.0);
    } else if (sortBy == 'duration') {
      return isAsc 
          ? (a.duration ?? 0.0).compareTo(b.duration ?? 0.0) 
          : (b.duration ?? 0.0).compareTo(a.duration ?? 0.0);
    } else if (sortBy == 'routeNumber') {
      final numA = a.routeNumber ?? '';
      final numB = b.routeNumber ?? '';
      return isAsc ? numA.compareTo(numB) : numB.compareTo(numA);
    }
    return 0;
  });
}
```

---

### Step 2: Bind Text Fields and Debounce Input in the UI
To deliver a high-end feel, we should update search results **automatically** as the user types, using a **debounce** pattern (waiting 500ms after the last keystroke before querying the API) to avoid spamming the backend.

Update [route_search_screen.dart](file:///c:/flutter_dev/projects/smartbus/lib/screens/route_search_screen.dart) as follows:

```dart
class RouteSearchScreen extends StatefulWidget {
  const RouteSearchScreen({super.key});

  @override
  State<RouteSearchScreen> createState() => _RouteSearchScreenState();
}

class _RouteSearchScreenState extends State<RouteSearchScreen> {
  final routeController = Get.find<RouteController>();
  final departureTextController = TextEditingController();
  final destinationTextController = TextEditingController();
  
  // Timer for debouncing requests
  Rxn<dynamic> debounceTimer = Rxn<dynamic>();

  @override
  void dispose() {
    departureTextController.dispose();
    destinationTextController.dispose();
    super.dispose();
  }

  // Trigger search on change with 500ms debounce
  void _onSearchChanged() {
    if (debounceTimer.value != null) {
      debounceTimer.value.cancel();
    }
    debounceTimer.value = Rxn<dynamic>(); // Re-trigger
    
    // Using GetX debounce helper or standard timer:
    debounce(() {
      routeController.searchRoutesAdvanced(
        departure: departureTextController.text.trim(),
        destination: destinationTextController.text.trim(),
      );
    }, time: const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // ... AppBar config remains unchanged ...
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSearchSection(context),
                    _sectionHeader(context),
                    _routeList(context, routeController),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "where_to".tr,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Positioned(
                left: 23,
                top: 30,
                bottom: 30,
                child: Container(
                  width: 2,
                  color: Theme.of(context).dividerColor,
                ),
              ),
              Column(
                children: [
                  _SearchField(
                    icon: Icons.circle,
                    hint: "departure_stop".tr,
                    context: context,
                    controller: departureTextController,
                    onChanged: (value) => _onSearchChanged(),
                  ),
                  const SizedBox(height: 12),
                  _SearchField(
                    icon: Icons.location_on,
                    hint: "destination_stop".tr,
                    context: context,
                    controller: destinationTextController,
                    onChanged: (value) => _onSearchChanged(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _filters(context),
        ],
      ),
    );
  }
}
```

---

### Step 3: Implement Sorting Filter Chips
Wire up the filter chips below the search fields so they dynamically update the UI sorting list.

Update the `_filters` widget inside `_RouteSearchScreenState` to reactively track selected sorting:

```dart
Widget _filters(BuildContext context) {
  // Mapping display text to our sorting keys
  final List<Map<String, String>> filters = [
    {"label": "filter_lowest_price".tr, "key": "price", "order": "asc"},
    {"label": "filter_fastest".tr, "key": "duration", "order": "asc"},
    {"label": "filter_route_num".tr, "key": "routeNumber", "order": "asc"},
  ];

  return SizedBox(
    height: 40,
    child: Obx(() {
      final activeSortBy = routeController.currentSortBy.value;

      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final filter = filters[i];
          final String key = filter["key"]!;
          final String order = filter["order"]!;
          final bool isActive = activeSortBy == key;

          return GestureDetector(
            onTap: () {
              // Set the sorting field and order in the controller
              routeController.currentSortBy.value = key;
              routeController.currentSortOrder.value = order;
              
              // Apply client-side sorting immediately to the visible list
              routeController._applyClientSortToSearchResults();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: isActive
                    ? null
                    : Border.all(color: Theme.of(context).dividerColor),
              ),
              alignment: Alignment.center,
              child: Text(
                filter["label"]!,
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      );
    }),
  );
}
```

---

## 📈 4. Best Practices for Mobile Search

1. **Debounce (Delay) Keystrokes:**
   Never call the server on *every* typed key. The `500ms` delay protects server resources and avoids rendering flash transitions on rapid inputs.
2. **Handle Empty Result States:**
   Verify `controller.searchStatus.value == ApiCallStatus.empty` and display a warm, user-friendly illustration (e.g. *"No routes found matching your stops."*) rather than a blank grey screen.
3. **Optimistic Local Filtering (Offline Mode):**
   If the user has zero internet connection, falls back to searching on the loaded offline routes in `controller.routes` by applying a local Dart substring search on `route.startStopName` and `route.endStopName`.

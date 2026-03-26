import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_cs_passenger/utils/wrappers/cached_image_widget_wrapper.dart';
import 'package:trip_cs_passenger/utils/wrappers/shimmer_wrapper.dart';
import 'package:trip_cs_passenger/widgets/animated_widgets/loading.dart';

import '../../constants/constants.dart';
import '../../models/trip.dart';

class TripHistoryCard extends StatelessWidget {
  final bool isShimmer;
  final Trip trip;
  const TripHistoryCard({
    super.key,
    required this.isShimmer,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: maincolor.withOpacity(0.15)),
            boxShadow: kCardShadow()),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Get the width of the container
            double containerWidth = constraints.maxWidth;
            double columnWidth =
                80; // Estimated width of each column (adjust based on content)
            double containerItemWidth =
                containerWidth * 0.05; // Width of each generated container
            double availableWidth = containerWidth - (columnWidth * 2);

            // Calculate how many containers can fit in the available space
            int numberOfContainers =
                (availableWidth / (containerItemWidth + 16))
                    .floor(); // 16 is padding between containers

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShimmerWrapper(
                isEnabled: isShimmer,
                baseColor: maincolor.withOpacity(0.2),
                highlightColor: maincolor.withOpacity(0.1),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column
                        Column(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            Text(trip.departureStop!.nameEn!),
                            Text(DateFormat('hh:mm a')
                                .format(trip.departureDateTime!)),
                          ],
                        ),
                        // Middle Row: Dynamically generate containers based on container width
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                numberOfContainers,
                                (index) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Container(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: containerItemWidth,
                                      height: 5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Right Column
                        Column(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            Text(trip.destinationStop!.nameEn!),
                            Text(DateFormat('hh:mm a')
                                .format(trip.destinationDateTime!)),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: cachedNetworkImageWrapper(
                                  imageUrl: trip.driver!.imageUrl!,
                                  imageBuilder: (context, imageProvider) =>
                                      SmallCardImageHolder(
                                          image: Image.network(
                                    trip.driver!.imageUrl!,
                                    fit: BoxFit.cover,
                                  )),
                                  placeholderBuilder: (context, string) =>
                                      Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.2),
                                        shape: BoxShape.circle),
                                    child: const Padding(
                                      padding: EdgeInsets.only(bottom: 4.0),
                                      child: Center(
                                        child: Loading(
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidgetBuilder:
                                      (context, string, error) => Icon(
                                    EneftyIcons.profile_circle_bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 50,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${trip.driver!.firstName!} ${trip.driver!.lastName!}'),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        trip.status!.badge
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

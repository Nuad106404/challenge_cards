import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

final _precachedUrls = <String>{};

/// Precaches the next [countAhead] card image URLs starting after [currentIndex].
/// Fire-and-forget — does not block the UI thread.
void precacheNextCardImages({
  required BuildContext context,
  required List<String> urls,
  required int currentIndex,
  int countAhead = 2,
}) {
  for (int i = 1; i <= countAhead; i++) {
    final idx = currentIndex + i;
    if (idx >= urls.length) break;
    final url = urls[idx];
    if (url.isEmpty || _precachedUrls.contains(url)) continue;
    _precachedUrls.add(url);
    precacheImage(CachedNetworkImageProvider(url), context);
  }
}

/// Clears the precache tracking set (call on game end to free memory).
void clearPrecacheTracking() => _precachedUrls.clear();

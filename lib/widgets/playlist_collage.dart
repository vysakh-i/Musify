/*
 *     Copyright (C) 2026 Valeri Gokadze
 *
 *     Musify is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Musify is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about Musify, including how to contribute,
 *     please visit: https://github.com/gokadzev/Musify
 */

import 'package:material_ui/material_ui.dart';
import 'package:musify/utilities/artwork_provider.dart';

/// Artwork URLs of the first distinct songs of [playlist], used to build a
/// cover when a playlist has no image of its own.
List<String> playlistCollageImages(Map? playlist, {int maxImages = 4}) {
  final songs = playlist?['list'];
  if (songs is! List) return const [];

  final images = <String>[];
  for (final song in songs) {
    if (song is! Map) continue;
    final image = (song['highResImage'] ?? song['lowResImage'])?.toString();
    if (image == null || image.isEmpty || image == 'null') continue;
    if (images.contains(image)) continue;
    images.add(image);
    if (images.length >= maxImages) break;
  }
  return images;
}

/// A cover made of up to four song artworks: one fills the cover, two split it
/// in halves, three use a large tile plus two small ones, four make a grid.
class PlaylistCollage extends StatelessWidget {
  const PlaylistCollage({
    super.key,
    required this.images,
    required this.size,
    this.fallback,
  }) : assert(images.length > 0 && images.length <= 4);

  final List<String> images;
  final double size;
  final Widget? fallback;

  Widget _tile(String image) => Image(
    image: ArtworkProvider.get(image),
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
    errorBuilder: (_, __, ___) =>
        fallback ?? const ColoredBox(color: Colors.black12),
  );

  Widget _row(List<Widget> children) =>
      Row(children: [for (final c in children) Expanded(child: c)]);

  Widget _column(List<Widget> children) =>
      Column(children: [for (final c in children) Expanded(child: c)]);

  Widget _layout() {
    final tiles = images.map(_tile).toList();
    switch (tiles.length) {
      case 1:
        return tiles[0];
      case 2:
        return _row(tiles);
      case 3:
        return _row([tiles[0], _column([tiles[1], tiles[2]])]);
      default:
        return _column([
          _row([tiles[0], tiles[1]]),
          _row([tiles[2], tiles[3]]),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: _layout());
}

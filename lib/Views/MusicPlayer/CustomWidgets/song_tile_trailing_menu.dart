/*
 *  This file is part of music_player/Views/MusicPlayer (https://github.com/Sangwan5688/music_player/Views/MusicPlayer).
 * 
 * music_player/Views/MusicPlayer is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * music_player/Views/MusicPlayer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with music_player/Views/MusicPlayer.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2021-2022, Ankit Sangwan
 */

import 'package:audio_service/audio_service.dart';
import 'package:music_player/Views/MusicPlayer/CustomWidgets/add_playlist.dart';
import 'package:music_player/Views/MusicPlayer/Helpers/add_mediaitem_to_queue.dart';
import 'package:music_player/Views/MusicPlayer/Helpers/mediaitem_converter.dart';
import 'package:music_player/Views/MusicPlayer/Screens/Common/song_list.dart';
import 'package:music_player/Views/MusicPlayer/Screens/Search/albums.dart';
import 'package:music_player/Views/MusicPlayer/Screens/Search/search.dart';
import 'package:music_player/Views/MusicPlayer/Services/youtube_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SongTileTrailingMenu extends StatefulWidget {
  final Map data;
  final bool isPlaylist;
  final Function(Map)? deleteLiked;
  const SongTileTrailingMenu({
    Key? key,
    required this.data,
    this.isPlaylist = false,
    this.deleteLiked,
  }) : super(key: key);

  @override
  _SongTileTrailingMenuState createState() => _SongTileTrailingMenuState();
}

class _SongTileTrailingMenuState extends State<SongTileTrailingMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert_rounded,
        color: Color(0xFFffab00),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      itemBuilder: (context) => [
        if (widget.isPlaylist)
          PopupMenuItem(
            value: 6,
            child: Row(
              children: [
                const Icon(
                  Icons.delete_rounded,
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Text(
                 "remove",
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(
                Icons.queue_music_rounded,
                color: Color(0xFFffab00),
              ),
              const SizedBox(width: 10.0),
              Text("playNext",style: TextStyle(color: Color(0xFFffab00)),),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(
                Icons.playlist_add_rounded,
                color:Color(0xFFffab00),
              ),
              const SizedBox(width: 10.0),
              Text("addToQueue",style: TextStyle(color: Color(0xFFffab00)),),
            ],
          ),
        ),
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              Icon(
                Icons.playlist_add_rounded,
                color: Color(0xFFffab00),
              ),
              const SizedBox(width: 10.0),
              Text("addToPlaylist",style: TextStyle(color: Color(0xFFffab00)),),
            ],
          ),
        ),
        PopupMenuItem(
          value: 4,
          child: Row(
            children: [
              Icon(
                Icons.album_rounded,
                color: Color(0xFFffab00),
              ),
              const SizedBox(width: 10.0),
              Text("viewAlbum",style: TextStyle(color: Color(0xFFffab00)),),
            ],
          ),
        ),
        PopupMenuItem(
          value: 5,
          child: Row(
            children: [
              Icon(
                Icons.person_rounded,
                color: Color(0xFFffab00),
              ),
              const SizedBox(width: 10.0),
              Text("viewArtist",style: TextStyle(color: Color(0xFFffab00)),),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(
                Icons.share_rounded,
                color: Color(0xFFffab00),
              ),
              const SizedBox(width: 10.0),
              Text("share",style: TextStyle(color: Color(0xFFffab00)),),
            ],
          ),
        ),
      ],
      onSelected: (int? value) {
        final MediaItem mediaItem =
            MediaItemConverter.mapToMediaItem(widget.data);
        if (value == 3) {
          Share.share(widget.data['perma_url'].toString());
        }
        if (value == 4) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => SongsListPage(
                listItem: {
                  'type': 'album',
                  'id': mediaItem.extras?['album_id'],
                  'title': mediaItem.album,
                  'image': mediaItem.artUri,
                },
              ),
            ),
          );
        }
        if (value == 5) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => AlbumSearchPage(
                query: mediaItem.artist.toString().split(', ').first,
                type: 'Artists',
              ),
            ),
          );
        }
        if (value == 6) {
          widget.deleteLiked!(widget.data);
        }
        if (value == 0) {
          AddToPlaylist().addToPlaylist(context, mediaItem);
        }
        if (value == 1) {
          addToNowPlaying(context: context, mediaItem: mediaItem);
        }
        if (value == 2) {
          playNext(mediaItem, context);
        }
      },
    );
  }
}

class YtSongTileTrailingMenu extends StatefulWidget {
  final Video data;
  const YtSongTileTrailingMenu({Key? key, required this.data})
      : super(key: key);

  @override
  _YtSongTileTrailingMenuState createState() => _YtSongTileTrailingMenuState();
}

class _YtSongTileTrailingMenuState extends State<YtSongTileTrailingMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert_rounded,
        color: Theme.of(context).iconTheme.color,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              Icon(
                CupertinoIcons.search,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(
                width: 10.0,
              ),
              Text(
                "searchHome",
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(
                Icons.queue_music_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text("playNext"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(
                Icons.playlist_add_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text("addToQueue"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(
                Icons.playlist_add_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text("addToPlaylist"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 4,
          child: Row(
            children: [
              Icon(
                Icons.video_library_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text("watchVideo"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 5,
          child: Row(
            children: [
              Icon(
                Icons.share_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text("share"),
            ],
          ),
        ),
      ],
      onSelected: (int? value) {
        if (value == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(
                query: widget.data.title.split('|')[0].split('(')[0],
              ),
            ),
          );
        }
        if (value == 1 || value == 2 || value == 3) {
          YouTubeServices()
              .formatVideo(
            video: widget.data,
            quality: Hive.box('settings')
                .get(
                  'ytQuality',
                  defaultValue: 'Low',
                )
                .toString(),
          )
              .then((songMap) {
            final MediaItem mediaItem =
                MediaItemConverter.mapToMediaItem(songMap!);
            if (value == 1) {
              playNext(mediaItem, context);
            }
            if (value == 2) {
              addToNowPlaying(context: context, mediaItem: mediaItem);
            }
            if (value == 3) {
              AddToPlaylist().addToPlaylist(context, mediaItem);
            }
          });
        }
        if (value == 4) {
          launch(widget.data.url);
        }
        if (value == 5) {
          Share.share(widget.data.url);
        }
      },
    );
  }
}

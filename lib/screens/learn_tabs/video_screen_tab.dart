import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kakao_farmer/widgets/shadowed_container.dart';
import 'package:kakao_farmer/widgets/video_player_widget.dart';

class VideoScreenTab extends StatefulWidget {
  const VideoScreenTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VideoScreenTabState createState() => _VideoScreenTabState();
}

class _VideoScreenTabState extends State<VideoScreenTab> {
  static const _pageSize = 5;
  final PagingController<int, String> _pagingController =
      PagingController(firstPageKey: 0);

  final List<String> videoIds = [
    'dQw4w9WgXcQ',
    '3JZ_D3ELwOQ',
    'tgbNymZ7vqY',
    'L_jWHffIx5E',
    '9bZkp7q19f0',
    'e-ORhEE9VVg',
    'nVjsGKrE6E8',
    'Pkh8UtuejGw',
    'JGwWNGJdvx8',
    'kJQP7kiw5Fk'
  ];

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          videoIds.skip(pageKey * _pageSize).take(_pageSize).toList();
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
        child: PagedListView<int, String>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<String>(
            itemBuilder: (context, videoId, index) => ShadowedContainer(
              margin: EdgeInsets.all(4),
              padding: EdgeInsets.all(4),
              content: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      VideoPlayerWidget(videoId: videoId),
                      const SizedBox(height: 10),
                      Text('Video $videoId',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  )),
            ),
            noItemsFoundIndicatorBuilder: (context) => Center(
              child: Text(
                'Aucune video disponible',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

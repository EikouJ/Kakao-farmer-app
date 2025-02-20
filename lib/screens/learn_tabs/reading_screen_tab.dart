import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kakao_farmer/widgets/post_widget.dart';
import 'package:kakao_farmer/widgets/shadowed_container.dart';

class ReadingScreenTab extends StatefulWidget {
  const ReadingScreenTab({super.key});

  @override
  State<ReadingScreenTab> createState() => _ReadingScreenTabState();
}

class _ReadingScreenTabState extends State<ReadingScreenTab> {
  static const _pageSize = 5;
  final PagingController<int, String> _pagingController =
      PagingController(firstPageKey: 0);

  final List<String> articles = [
    'Article Content 1',
    'Article Content 2',
    'Article Content 3',
    'Article Content 4',
    'Article Content 5',
    'Article Content 6',
    'Article Content 7',
    'Article Content 8',
    'Article Content 9',
    'Article Content 10'
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
          articles.skip(pageKey * _pageSize).take(_pageSize).toList();
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
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text("TEXT"); //PostWidget(image: null, description: "Description");
    /*Container(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
        child: PagedListView<int, String>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<String>(
            itemBuilder: (context, article, index) => ShadowedContainer(
              margin: EdgeInsets.all(4),
              padding: EdgeInsets.all(4),
              content: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Title $index',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 24)),
                      const SizedBox(height: 10),
                      Text(
                        article,
                        style: TextStyle(fontSize: 16),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(
                              onPressed: () {},
                              style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withAlpha(30),
                                  overlayColor: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withAlpha(120),
                                  foregroundColor:
                                      Theme.of(context).colorScheme.secondary),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.menu_book_sharp),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Text("Lire")
                                ],
                              ))
                        ],
                      )
                    ],
                  )),
            ),
          ),
        ));*/
  }
}

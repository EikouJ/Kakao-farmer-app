import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kakao_farmer/widgets/shadowed_container.dart';
import 'package:url_launcher/url_launcher.dart';

class DocScreenTab extends StatefulWidget {
  const DocScreenTab({super.key});

  @override
  _DocScreenTabState createState() => _DocScreenTabState();
}

class _DocScreenTabState extends State<DocScreenTab> {
  static const _pageSize = 5;
  final PagingController<int, String> _pagingController =
      PagingController(firstPageKey: 0);

  final List<String> documentUrls = [
    'https://example.com/document1.pdf',
    'https://example.com/document2.pdf',
    // Add more document URLs here
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
          documentUrls.skip(pageKey * _pageSize).take(_pageSize).toList();
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

  Future<void> _openPdf(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
      child: PagedListView<int, String>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<String>(
          itemBuilder: (context, documentUrl, index) => ShadowedContainer(
            margin: EdgeInsets.all(4),
            padding: EdgeInsets.all(4),
            content: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _openPdf(documentUrl),
                    child: Text('Open Document ${index + 1}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                          255, 131, 41, 41), // Updated: Background color
                      foregroundColor: Colors.white, // Text color
                      padding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20), // Padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Document ${index + 1}',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

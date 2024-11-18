import 'package:flutter/material.dart';
import 'package:familiahuecasfrontend/model/numeracion.dart';
import 'package:familiahuecasfrontend/apirest/api_service.dart';

class BasicPagination extends StatefulWidget {
  final Future<List<Numeracion>> Function(int page, int size) fetchItems;
  final Widget Function(BuildContext context, Numeracion item) itemBuilder;

  const BasicPagination({
    Key? key,
    required this.fetchItems,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  _BasicPaginationState createState() => _BasicPaginationState();
}

class _BasicPaginationState extends State<BasicPagination> {
  final ScrollController _scrollController = ScrollController();
  List<Numeracion> _items = [];
  bool _isLoading = false;
  int _currentPage = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _loadItems();
      }
    });
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final newItems = await widget.fetchItems(_currentPage, _pageSize);
      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return Center(child: CircularProgressIndicator());
        }
        return widget.itemBuilder(context, _items[index]);
      },
    );
  }
}

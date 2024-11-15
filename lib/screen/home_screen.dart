import 'package:flutter/material.dart';
import '../apirest/api_service.dart';
import '../model/user.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  HomeScreen({required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<User> users = [];
  bool _isLoading = true;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final fetchedUsers = await apiService.getUsers();
      setState(() {
        users = fetchedUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios - Familia Huecas'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : DataTable(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Roles')),
        ],
        rows: users.map((user) {
          return DataRow(cells: [
            DataCell(Text(user.id.toString())),
            DataCell(Text(user.name)),
            DataCell(Text(user.email)),
            DataCell(Text(user.roles.join(', '))),
          ]);
        }).toList(),
      ),
    );
  }
}

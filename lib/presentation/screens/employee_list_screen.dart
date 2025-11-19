import 'package:flutter/material.dart';
import 'employee_list_viewmodel.dart';
import 'employee_detail_screen.dart';
import 'employee_add_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);
  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late final viewModel = EmployeeListViewModel()..loadEmployees();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employees"), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: viewModel.loadEmployees),
      ]),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(hintText: "Search...", prefixIcon: Icon(Icons.search)),
                  onChanged: viewModel.search,
                ),
              ),
              if (viewModel.error != null)
                Container(color: Colors.orange[100], child: Text(viewModel.error!)),

              Expanded(
                child: viewModel.filtered.isEmpty
                    ? const Center(child: Text("No employees"))
                    : ListView.builder(
                  itemCount: viewModel.filtered.length,
                  itemBuilder: (context, i) {
                    final emp = viewModel.filtered[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text(emp.name[0])),
                      title: Text(emp.name),
                      subtitle: Text("${emp.position} • ${emp.department}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(emp.id),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EmployeeDetailScreen(employee: emp)),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeAddScreen()))
            .then((_) => viewModel.loadEmployees()),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              viewModel.delete(id);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/employee_list/employee_list_bloc.dart';
import '../bloc/employee_list/employee_list_event.dart';
import '../bloc/employee_list/employee_list_state.dart';
import '../widgets/employee_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'employee_form_screen.dart';
import 'employee_detail_screen.dart';
import 'attendance_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<EmployeeListBloc>().add(FetchEmployeesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AttendanceScreen(),
                ),
              );
            },
            tooltip: 'Attendance',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EmployeeListBloc>().add(FetchEmployeesEvent());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (query) {
                context
                    .read<EmployeeListBloc>()
                    .add(SearchEmployeesEvent(query));
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<EmployeeListBloc, EmployeeListState>(
              listener: (context, state) {
                if (state is EmployeeListError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is EmployeeListLoading) {
                  return const LoadingWidget();
                }

                if (state is EmployeeListError) {
                  return ErrorDisplayWidget(
                    message: state.message,
                    onRetry: () {
                      context.read<EmployeeListBloc>().add(FetchEmployeesEvent());
                    },
                  );
                }

                if (state is EmployeeListLoaded) {
                  if (state.employees.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No employees found'
                                : 'No matching employees',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.employees.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final employee = state.employees[index];
                      return EmployeeCard(
                        employee: employee,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EmployeeDetailScreen(employee: employee),
                            ),
                          ).then((_) {
                            context
                                .read<EmployeeListBloc>()
                                .add(FetchEmployeesEvent());
                          });
                        },
                        onDelete: () {
                          _showDeleteDialog(employee.id);
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmployeeFormScreen(),
            ),
          ).then((_) {
            context.read<EmployeeListBloc>().add(FetchEmployeesEvent());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to delete this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<EmployeeListBloc>().add(DeleteEmployeeEvent(id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
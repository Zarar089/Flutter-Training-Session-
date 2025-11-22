import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/injection_container.dart' as di;
import 'presentations/bloc/employee_list/employee_list_bloc.dart';
import 'presentations/bloc/employee_form/employee_form_bloc.dart';
import 'presentations/bloc/employee_detail/employee_detail_bloc.dart';
import 'presentations/bloc/attendance/attendance_bloc.dart';
import 'presentations/screens/employee_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  await di.init();
  
  runApp(const EmployeeApp());
}

class EmployeeApp extends StatelessWidget {
  const EmployeeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EmployeeListBloc>(
          create: (_) => di.sl<EmployeeListBloc>(),
        ),
        BlocProvider<EmployeeFormBloc>(
          create: (_) => di.sl<EmployeeFormBloc>(),
        ),
        BlocProvider<EmployeeDetailBloc>(
          create: (_) => di.sl<EmployeeDetailBloc>(),
        ),
        BlocProvider<AttendanceBloc>(
          create: (_) => di.sl<AttendanceBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Employee App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const EmployeeListScreen(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/bloc/employee/employee_bloc.dart';
import 'presentation/bloc/employee/employee_event.dart' as employee_event;
import 'presentation/bloc/attendance/attendance_bloc.dart';
import 'presentation/bloc/attendance/attendance_event.dart' as attendance_event;
import 'screens/employee_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("Init");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase initialized");
  
  // Initialize dependency injection
  await di.init();
  print("Dependency injection initialized");
  
  runApp(const EmployeeApp());
}

class EmployeeApp extends StatelessWidget {
  const EmployeeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.getIt<EmployeeBloc>()..add(const employee_event.LoadEmployees()),
        ),
        BlocProvider(
          create: (_) => di.getIt<AttendanceBloc>()
            ..add(const attendance_event.LoadEmployees())
            ..add(const attendance_event.LoadAttendance()),
        ),
      ],
      child: MaterialApp(
        title: 'Employee App - Clean Architecture',
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
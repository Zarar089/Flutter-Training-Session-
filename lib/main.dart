import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'bloc/attendance/attendance_bloc.dart';
import 'bloc/employee/employee_bloc.dart';
import 'injection/injection_container.dart' as di;
import 'screens/employee_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize GetIt - This registers all our dependencies
  await di.init();
  
  runApp(const EmployeeApp());
}

class EmployeeApp extends StatelessWidget {
  const EmployeeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Get BLoCs from GetIt instead of static methods
        BlocProvider(create: (_) => di.getIt<EmployeeBloc>()),
        BlocProvider(create: (_) => di.getIt<AttendanceBloc>()),
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

import 'package:employee_app_v1_spaghetti/domain/use_cases/employee_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'employee_list_events.dart';
import 'employee_list_state.dart';

class EmployeeListBloc extends Bloc<EmployeeListEvents, EmployeeListState>{
  late EmployeeUseCase employeeUseCase;
  EmployeeListBloc() : super(EmployeeListInitial())
  {
    on<EmployeeListFetchTriggered>();
    employeeUseCase = EmployeeUseCase();
    employeeUseCase.init();
  }

  _fetchEmployeeList(EmployeeListFetchTriggered event,Emitter<EmployeeListState> state){

  }
}
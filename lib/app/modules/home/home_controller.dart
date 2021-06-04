import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/app/models/todo_model.dart';

import 'package:todo_list/app/repositories/todos_repository.dart';
import 'package:collection/collection.dart';

class HomeController extends ChangeNotifier {
  final TodosRepository repository;
  int selectedTab = 1;

  DateTime daySelected;
  DateTime startFilter;
  DateTime endFilter;

  Map<String, List<TodoModel>> listTodos;
  var dateFormat = DateFormat('dd/MM/yyyy');

  HomeController({@required this.repository}) {
    // repository.saveTodo(DateTime.now(), 'Teste 1');
    // repository.saveTodo(DateTime.now().add(Duration(days: 1)), 'Teste 2');
    // repository.saveTodo(DateTime.now().add(Duration(days: 2)), 'Teste 3');
    findAllForWeek();
  }

  Future<void> changeSelectedTab(BuildContext context, int index) async {
    selectedTab = index;
    switch (index) {
      case 0:
        filterFinalized();
        break;
      case 1:
        findAllForWeek();
        break;
      case 2:
        var day = await showDatePicker(
          context: context,
          initialDate: daySelected,
          firstDate: DateTime.now().subtract(Duration(days: 360 * 3)),
          lastDate: DateTime.now().add(Duration(days: 360 * 10)),
        );

        if (day != null) {
          daySelected = day;
          findTodoBySelectedDay();
        }
        break;
    }
    notifyListeners();
  }

  Future<void> findAllForWeek() async {
    daySelected = DateTime.now();

    startFilter = DateTime.now();

    if (startFilter.weekday != DateTime.monday) {
      startFilter = startFilter.subtract(Duration(days: (startFilter.weekday - 1)));
    }
    endFilter = startFilter.add(Duration(days: 6));

    var todos = await repository.findByPeriod(startFilter, endFilter);

    if (todos.isEmpty) {
      listTodos = {dateFormat.format(DateTime.now()): []};
    } else {
      listTodos = groupBy(todos, (TodoModel todo) => dateFormat.format(todo.dataHora));
    }
    this.notifyListeners();
  }

  void checkedOrUnchecked(TodoModel todo) {
    todo.finalizado = !todo.finalizado;
    this.notifyListeners();
    repository.checkOrUncheckTodo(todo);
  }

  void filterFinalized() {
    listTodos = listTodos.map((key, value) {
      var todosFinalized = value.where((t) => t.finalizado).toList();
      return MapEntry(key, todosFinalized);
    });
    this.notifyListeners();
  }

  Future<void> findTodoBySelectedDay() async {
    var todos = await repository.findByPeriod(daySelected, daySelected);

    if (todos.isEmpty) {
      listTodos = {dateFormat.format(daySelected): []};
    } else {
      listTodos = groupBy(todos, (TodoModel todo) => dateFormat.format(todo.dataHora));
    }

    this.notifyListeners();
  }

  void update() {
    if (selectedTab == 1) {
      this.findAllForWeek();
    } else if (selectedTab == 2) {
      this.findTodoBySelectedDay();
    }
  }

  Future<void> delete(TodoModel todo) async {
    await repository.removeTodo(todo.id);
    this.update();
  }
}


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class Task {
  String title;
  bool completed;

  Task({
    required this.title,
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'completed': completed,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      completed: json['completed'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha Lista',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
        ),
      ),
      home: const TaskPage(),
    );
  }
}

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TextEditingController controller = TextEditingController();

  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final String? savedTasks = prefs.getString('tasks');

    if (savedTasks != null) {
      final List decoded = jsonDecode(savedTasks);

      setState(() {
        tasks = decoded
            .map((item) => Task.fromJson(item))
            .toList();
      });
    }
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final String encodedTasks = jsonEncode(
      tasks.map((task) => task.toJson()).toList(),
    );

    await prefs.setString('tasks', encodedTasks);
  }

  void addTask() {
    final String title = controller.text.trim();

    if (title.isEmpty) return;

    setState(() {
      tasks.add(Task(title: title));
      controller.clear();
    });

    saveTasks();
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index].completed = !tasks[index].completed;
    });

    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });

    saveTasks();
  }

  void clearCompletedTasks() {
    setState(() {
      tasks.removeWhere((task) => task.completed);
    });

    saveTasks();
  }

  int get pendingTasks =>
      tasks.where((task) => !task.completed).length;

  int get completedTasks =>
      tasks.where((task) => task.completed).length;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minha Lista de Tarefas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Organize seu dia!',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Suas tarefas em um só lugar.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: _buildCounter(
                    'Pendentes',
                    pendingTasks,
                    Colors.orange,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildCounter(
                    'Concluídas',
                    completedTasks,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => addTask(),
                    decoration: InputDecoration(
                      hintText: 'Digite uma tarefa...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                SizedBox(
                  height: 55,
                  width: 55,
                  child: ElevatedButton(
                    onPressed: addTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6750A4),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Minhas tarefas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                TextButton(
                  onPressed: completedTasks > 0
                      ? clearCompletedTasks
                      : null,
                  child: const Text('Limpar concluídas'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Expanded(
              child: tasks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 65,
                      color: Colors.grey[400],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Nenhuma tarefa cadastrada',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: tasks.length,

                itemBuilder: (context, index) {
                  final task = tasks[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: ListTile(
                      leading: Checkbox(
                        value: task.completed,
                        activeColor: Colors.green,
                        onChanged: (_) => toggleTask(index),
                      ),

                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: task.completed
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),

                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => deleteTask(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(
      String title,
      int value,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

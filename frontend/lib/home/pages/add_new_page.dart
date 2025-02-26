
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cubit/add_new_task_cubit.dart';
import 'package:frontend/features/cubit/auth_cubit.dart';
import 'package:frontend/home/pages/homepage.dart';
import 'package:intl/intl.dart';

class AddNewTaskPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => AddNewTaskPage());
  const AddNewTaskPage({super.key});

  @override
  State<AddNewTaskPage> createState() => _AddNewRState();
}

class _AddNewRState extends State<AddNewTaskPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  Color selectedColor = Color.fromRGBO(246, 222, 194, 1);
  final formKey = GlobalKey<FormState>();
  String token = "your_token_here"; // Define the token variable

  Future<void> createTask() async {
    if (formKey.currentState!.validate()) {
      AuthLoggedIn user = context.read<AuthCubit>().state as AuthLoggedIn;
      await context.read<AddNewTaskCubit>().createNewTask(
        uid: user.user.id,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          color: selectedColor,
          token: user.user.token,
          dueAt: selectedDate);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new task'),
        actions: [
          GestureDetector(
            onTap: () async {
              final _selectedDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)));
              if (_selectedDate != null) {
                setState(() {
                  selectedDate = _selectedDate;
                });
              }
            },
            child: BlocConsumer<AddNewTaskCubit, AddNewTaskState>(
              listener: (context, state) {
                if (state is AddNewTaskError) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.error)));
                } else if (state is AddNewTaskSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Task added successfully!"),
                    ),
                  );
                  Navigator.pushAndRemoveUntil(context, HomePage.route(), (_) => false);
                }
              },
              builder: (context, state) {
                if (state is AddNewTaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    DateFormat("MM-dd-y").format(selectedDate),
                  ),
                );
              },
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Title cannot be empty";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Description cannot be empty";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ColorPicker(
                heading: const Text('Pick a Color'),
                subheading: const Text('Select a different shade'),
                onColorChanged: (Color color) {
                  setState(() {
                    selectedColor = color;
                  });
                },
                color: selectedColor,
                pickersEnabled: const {ColorPickerType.wheel: true},
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: createTask,
                  child: const Text('Submit',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.amber,
                        fontSize: 18,
                      )))
            ],
          ),
        ),
      ),
    );
  }
}
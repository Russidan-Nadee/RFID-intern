import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../blocs/category_bloc.dart';

class CategoryForm extends StatefulWidget {
  final String? initialValue;
  final bool isEditing;

  const CategoryForm({Key? key, this.initialValue, this.isEditing = false})
    : super(key: key);

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Category Name',
              hintText: 'Enter category name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a category name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final categoryBloc = Provider.of<CategoryBloc>(
                      context,
                      listen: false,
                    );
                    if (widget.isEditing && widget.initialValue != null) {
                      categoryBloc.updateCategory(
                        widget.initialValue!,
                        _controller.text,
                      );
                    } else {
                      categoryBloc.addCategory(_controller.text);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.isEditing ? 'Update' : 'Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

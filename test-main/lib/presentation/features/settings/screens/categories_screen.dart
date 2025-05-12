import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../blocs/category_bloc.dart';
import '../widgets/category_form.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryBloc>(context, listen: false).loadCategories();
    });
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Category'),
            content: CategoryForm(),
          ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, String category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Category'),
            content: CategoryForm(initialValue: category, isEditing: true),
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Category'),
            content: Text('Are you sure you want to delete "$category"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<CategoryBloc>(
                    context,
                    listen: false,
                  ).deleteCategory(category);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asset Categories')),
      body: Consumer<CategoryBloc>(
        builder: (context, categoryBloc, child) {
          if (categoryBloc.status == CategoryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (categoryBloc.status == CategoryStatus.error) {
            return Center(child: Text('Error: ${categoryBloc.errorMessage}'));
          } else if (categoryBloc.status == CategoryStatus.loaded) {
            return ListView.builder(
              itemCount: categoryBloc.categories.length,
              itemBuilder: (context, index) {
                final category = categoryBloc.categories[index];
                return ListTile(
                  title: Text(category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed:
                            () => _showEditCategoryDialog(context, category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed:
                            () => _showDeleteConfirmation(context, category),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

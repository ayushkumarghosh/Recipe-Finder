import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class IngredientInput extends StatefulWidget {
  final Function(String) onIngredientAdded;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const IngredientInput({
    super.key,
    required this.onIngredientAdded,
    this.controller,
    this.focusNode,
  });

  @override
  State<IngredientInput> createState() => _IngredientInputState();
}

class _IngredientInputState extends State<IngredientInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    // Only dispose if we created these internally
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    final ingredient = _controller.text.trim();
    if (ingredient.isNotEmpty) {
      widget.onIngredientAdded(ingredient);
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    labelText: 'Add an ingredient',
                    hintText: 'e.g., tomato, chicken, pasta',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.shopping_basket),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              _focusNode.requestFocus();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _addIngredient(),
                  onChanged: (value) {
                    // Force update to show/hide clear button
                    setState(() {});
                  },
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.add),
                onPressed: _addIngredient,
                tooltip: 'Add ingredient',
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
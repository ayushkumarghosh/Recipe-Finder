import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/ingredient.dart';
import '../services/ingredient_service.dart';
import 'ingredient_suggestions.dart';

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
  late IngredientService _ingredientService;
  List<Ingredient> _suggestions = [];
  bool _isLoading = false;
  bool _isValid = true;
  String _errorMessage = '';
  
  final GlobalKey _inputKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _ingredientService = IngredientService();
    
    // Listen for text changes to update suggestions
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    // Only dispose if we created these internally
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }
  
  Future<void> _onTextChanged() async {
    final query = _controller.text.trim();
    
    // Reset validation state
    if (!_isValid) {
      setState(() {
        _isValid = true;
        _errorMessage = '';
      });
    }
    
    if (query.isEmpty) {
      if (_suggestions.isNotEmpty) {
        setState(() {
          _suggestions = [];
        });
      }
      return;
    }
    
    // Debounce the search by setting a small delay
    setState(() {
      _isLoading = true;
    });
    
    try {
      final suggestions = await _ingredientService.getSuggestions(query);
      
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addIngredient() async {
    final ingredientName = _controller.text.trim();
    if (ingredientName.isEmpty) return;
    
    // Validate input (basic validation - non-empty and no special chars)
    if (_validateInput(ingredientName)) {
      // Save to recent ingredients
      await _ingredientService.saveRecentIngredient(
        Ingredient(name: ingredientName),
      );
      
      widget.onIngredientAdded(ingredientName);
      _controller.clear();
      _focusNode.requestFocus();
      
      setState(() {
        _suggestions = [];
      });
    }
  }
  
  bool _validateInput(String input) {
    // Check for minimum length
    if (input.length < 2) {
      setState(() {
        _isValid = false;
        _errorMessage = 'Ingredient name must be at least 2 characters';
      });
      return false;
    }
    
    // Check for special characters (allow letters, numbers and spaces)
    final regex = RegExp(r'^[a-zA-Z0-9\s\-]+$');
    if (!regex.hasMatch(input)) {
      setState(() {
        _isValid = false;
        _errorMessage = 'Ingredient should only contain letters, numbers, spaces, and hyphens';
      });
      return false;
    }
    
    return true;
  }
  
  void _selectSuggestion(Ingredient ingredient) {
    _controller.text = ingredient.name;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    _addIngredient();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
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
                      key: _inputKey,
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        labelText: 'Add an ingredient',
                        hintText: 'e.g., tomato, chicken, pasta',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.shopping_basket),
                        suffixIcon: _isLoading
                            ? Container(
                                width: 20,
                                height: 20,
                                padding: const EdgeInsets.all(2.0),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : _controller.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _controller.clear();
                                      _focusNode.requestFocus();
                                      setState(() {
                                        _suggestions = [];
                                      });
                                    },
                                  )
                                : null,
                        errorText: _isValid ? null : _errorMessage,
                      ),
                      onSubmitted: (_) => _addIngredient(),
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
          
          if (_suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: IngredientSuggestions(
                suggestions: _suggestions,
                onSuggestionSelected: _selectSuggestion,
              ),
            ),
        ],
      ),
    );
  }
} 
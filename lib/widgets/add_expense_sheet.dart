import 'package:flutter/material.dart';
import 'package:harcama_takip/l10n/app_localizations.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  List<Category> _categories = [];
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _loadCategories(context);
      });
    });
  }

  Future<void> _loadCategories(BuildContext context) async {
    final data = await CategoryService.loadCategories(context);
    setState(() {
      _categories = data;
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final expense = {
      'amount': double.tryParse(_amountController.text) ?? 0,
      'category': _selectedCategory?.name ?? "Diğer",
      'note': _noteController.text,
      'date': _selectedDate,
      'icon': _selectedCategory?.icon.codePoint,
    };

    Navigator.pop(context, expense);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.addExpenseTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 💰 Tutar alanı
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.amountLabel,
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? AppLocalizations.of(context)!.amountRequired : null,
              ),
              const SizedBox(height: 12),

              // 📂 Kategori seçimi
              _categories.isEmpty
                  ? Text(
                      AppLocalizations.of(context)!.noCategories)
                  : DropdownButtonFormField<Category>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.categoryLabel,
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Row(
                                  children: [
                                    Icon(c.icon,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    const SizedBox(width: 8),
                                    Text(c.name),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val),
                    ),
              const SizedBox(height: 12),

              // 🗒️ Not alanı
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.noteLabel,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // 📅 Tarih seçimi
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      "${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kaydet butonu
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: Text(AppLocalizations.of(context)!.buttonAdd),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

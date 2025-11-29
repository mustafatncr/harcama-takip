import 'package:flutter/material.dart';
import 'package:harcama_takip/l10n/app_localizations.dart';
import 'package:harcama_takip/services/storage_service.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../utils/icon_map.dart';
import '../models/expense.dart';

class AddExpenseSheet extends StatefulWidget {
  final String currencyCode;
  final Expense? expenseToEdit; // ⭐ Düzenleme için eklendi

  const AddExpenseSheet({
    super.key,
    required this.currencyCode,
    this.expenseToEdit,
  });

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

  String _currencySymbol = "₺";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currency = await StorageService.loadCurrency();
      setState(() => _currencySymbol = _symbolForCurrency(currency));

      await _loadCategories();
      _fillFormIfEditing(); // ⭐ Düzenleme modunda alanları doldurur
    });
  }

  void _fillFormIfEditing() {
    if (widget.expenseToEdit == null) return;

    final e = widget.expenseToEdit!;

    _amountController.text = e.amount.toString();
    _noteController.text = e.note ?? "";
    _selectedDate = e.date;

    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.firstWhere(
        (c) => c.name == e.category,
        orElse: () => _categories.first,
      );
    }

    setState(() {});
  }

  String _symbolForCurrency(String code) {
    switch (code) {
      case "USD":
        return "\$";
      case "EUR":
        return "€";
      case "GBP":
        return "£";
      default:
        return "₺";
    }
  }

  Future<void> _loadCategories() async {
    final data = await CategoryService.loadCategories();
    setState(() {
      _categories = data;
      if (widget.expenseToEdit == null) {
        _selectedCategory = null;
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  surface: const Color(0xFF0F2624),
                  primary: const Color(0xFF00C6A9),
                  onSurface: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.categoryRequired),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final currency = await StorageService.loadCurrency();

    final newExpense = Expense(
      amount: double.tryParse(_amountController.text) ?? 0,
      category: _selectedCategory!.name,
      note: _noteController.text,
      date: _selectedDate,
      currency: currency,
      iconName: _selectedCategory!.iconName,
    );

    Navigator.pop(context, {
      "mode": widget.expenseToEdit == null ? "add" : "edit",
      "original": widget.expenseToEdit,
      "updated": newExpense,
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F2624),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
          border: Border.all(color: const Color(0xFF1C3A37), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 30,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.expenseToEdit == null
                        ? AppLocalizations.of(context)!.addExpenseTitle
                        : AppLocalizations.of(context)!.editExpenseTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 28),

                  _buildLabel(
                      "${AppLocalizations.of(context)!.amountLabel} ($_currencySymbol)"),
                  _buildTextField(
                    controller: _amountController,
                    hint: "0.00",
                    primary: primary,
                    keyboard: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return AppLocalizations.of(context)!.amountRequired;
                      }
                      if ((double.tryParse(v) ?? 0) == 0) {
                        return AppLocalizations.of(context)!.amountCannotBeZero;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 22),

                  _buildLabel(AppLocalizations.of(context)!.categoryLabel),
                  _categories.isEmpty
                      ? Text(
                          AppLocalizations.of(context)!.noCategories,
                          style: const TextStyle(color: Colors.white70),
                        )
                      : _buildDropdown(context, primary),

                  const SizedBox(height: 22),

                  _buildLabel(AppLocalizations.of(context)!.noteLabel),
                  _buildTextField(
                    controller: _noteController,
                    hint: AppLocalizations.of(context)!.notePlaceholder,
                    primary: primary,
                  ),

                  const SizedBox(height: 22),

                  _buildDatePicker(primary),
                  const SizedBox(height: 32),

                  _buildSubmitButton(primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFD5F3EE),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Color primary,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        filled: true,
        fillColor: const Color(0xFF0F2624),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1C3A37)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.7),
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, Color primary) {
    return DropdownButtonFormField<Category>(
      value: _selectedCategory,
      validator: (val) {
        if (val == null) {
          return AppLocalizations.of(context)!.categoryRequired;
        }
        return null;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF0F2624),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1C3A37)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.7),
        ),
      ),
      dropdownColor: const Color(0xFF0F2624),
      hint: Text(
        AppLocalizations.of(context)!.selectCategoryPlaceholder,
        style: const TextStyle(color: Colors.white54),
      ),
      icon: Icon(Icons.expand_more, color: primary),
      items: _categories.map((c) {
        return DropdownMenuItem(
          value: c,
          child: Row(
            children: [
              Icon(
                iconMap[c.iconName] ?? Icons.category,
                color: primary,
              ),
              const SizedBox(width: 12),
              Text(c.name, style: const TextStyle(color: Colors.white)),
            ],
          ),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val),
    );
  }

  Widget _buildDatePicker(Color primary) {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2624),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1C3A37)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: primary, size: 20),
            const SizedBox(width: 12),
            Text(
              "${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Color primary) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 0,
        ),
        child: Text(
          widget.expenseToEdit == null
              ? AppLocalizations.of(context)!.buttonAdd
              : AppLocalizations.of(context)!.buttonSave,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

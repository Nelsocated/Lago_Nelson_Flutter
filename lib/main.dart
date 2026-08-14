import 'package:flutter/material.dart';

void main() {
  runApp(MyApp(item: ItemCrud()));
}

// ============================================================
// APP ROOT
// ============================================================

class MyApp extends StatelessWidget {
  final ItemCrud item;

  const MyApp({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost & Found',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B9080),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F5F1),
        fontFamily: 'Georgia',
      ),
      home: MyHomePage(title: 'Lost & Found', item: item),
    );
  }
}

// ============================================================
// MODEL
// ============================================================

class Item {
  String id;
  String title;
  String? description;
  String location;
  bool found;

  Item({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    this.found = false,
  });
}

// ============================================================
// CRUD (pure data layer, no widgets in here)
// ============================================================

class ItemCrud {
  final List<Item> _items = [];

  void addItem(Item item) {
    _items.add(item);
  }

  List<Item> getItems() {
    return _items;
  }

  void updateItem(String id, Item newItem) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = newItem;
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.item});

  final String title;
  final ItemCrud item;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const double maxContentWidth = 480;

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ConstrainedSheet(
        maxWidth: maxContentWidth,
        child: ItemFormCard(
          onSubmit: (newItem) {
            setState(() => widget.item.addItem(newItem));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _openEditSheet(Item item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ConstrainedSheet(
        maxWidth: maxContentWidth,
        child: ItemFormCard(
          existingItem: item,
          onSubmit: (updatedItem) {
            setState(() => widget.item.updateItem(updatedItem.id, updatedItem));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete this item?'),
        content: Text(
          '"${item.title}" will be removed permanently. This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => widget.item.deleteItem(item.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.item.getItems();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Lost & Found',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 56,
                    color: colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nothing here yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap + to report a lost or found item',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxContentWidth),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final currentItem = items[index];
                    return ItemCard(
                      item: currentItem,
                      onEdit: () => _openEditSheet(currentItem),
                      onDelete: () => _confirmDelete(currentItem),
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
}

class _ConstrainedSheet extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const _ConstrainedSheet({required this.maxWidth, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ItemCard({super.key, required this.item, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = item.found
        ? const Color(0xFF52916B)
        : const Color(0xFFC97A2B);
    final statusLabel = item.found ? 'Found' : 'Lost';
    final statusIcon = item.found
        ? Icons.check_circle_outline
        : Icons.help_outline;

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusPill(
                        color: statusColor,
                        icon: statusIcon,
                        label: statusLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description ?? "No description",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: Colors.grey[600],
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red[300],
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _StatusPill({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemFormCard extends StatefulWidget {
  final Item? existingItem;
  final void Function(Item item) onSubmit;

  const ItemFormCard({super.key, this.existingItem, required this.onSubmit});

  bool get isEditing => existingItem != null;

  @override
  State<ItemFormCard> createState() => _ItemFormCardState();
}

class _ItemFormCardState extends State<ItemFormCard> {
  final _formKey = GlobalKey<FormState>();

  // Plain final fields, no `late` needed — they just start empty.
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _found = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingItem;
    if (existing != null) {
      _titleController.text = existing.title;
      _descriptionController.text = existing.description ?? '';
      _locationController.text = existing.location;
      _found = existing.found;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final item = Item(
      id:
          widget.existingItem?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      location: _locationController.text,
      found: _found,
    );

    widget.onSubmit(item);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Text(
              widget.isEditing ? 'Edit Item' : 'Report an Item',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _StatusToggle(
              found: _found,
              onChanged: (value) => setState(() => _found = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: _fieldDecoration('Title', colorScheme),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: _fieldDecoration(
                'Description (optional)',
                colorScheme,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: _fieldDecoration('Location', colorScheme),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Location is required'
                  : null,
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submit,
              child: Text(widget.isEditing ? 'Save Changes' : 'Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration(String label, ColorScheme colorScheme) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: colorScheme.primary.withValues(alpha: 0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
    ),
  );
}

class _StatusToggle extends StatelessWidget {
  final bool found;
  final ValueChanged<bool> onChanged;

  const _StatusToggle({required this.found, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _StatusOption(
              label: 'Lost',
              icon: Icons.help_outline,
              color: const Color(0xFFC97A2B),
              selected: !found,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _StatusOption(
              label: 'Found',
              icon: Icons.check_circle_outline,
              color: const Color(0xFF52916B),
              selected: found,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? color : Colors.grey[500]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? color : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

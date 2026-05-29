import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_error_messages.dart';
import '../../../core/providers/catalog_providers.dart';
import '../../../core/router/navigation_ext.dart';
import '../../../core/widgets/friendly_load_error.dart';
import 'widgets/catalog_item_defaults_edit_form.dart';

class ItemEditPage extends ConsumerStatefulWidget {
  const ItemEditPage({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<ItemEditPage> createState() => _ItemEditPageState();
}

class _ItemEditPageState extends ConsumerState<ItemEditPage> {
  final _formKey = GlobalKey<CatalogItemDefaultsEditFormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _hsnCtrl;
  late final TextEditingController _taxCtrl;
  late final TextEditingController _kgCtrl;
  late final TextEditingController _ipbCtrl;
  late final TextEditingController _wptCtrl;
  late final TextEditingController _landCtrl;
  late final TextEditingController _sellCtrl;
  bool _saving = false;
  bool _controllersBound = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _hsnCtrl = TextEditingController();
    _taxCtrl = TextEditingController();
    _kgCtrl = TextEditingController();
    _ipbCtrl = TextEditingController();
    _wptCtrl = TextEditingController();
    _landCtrl = TextEditingController();
    _sellCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _hsnCtrl.dispose();
    _taxCtrl.dispose();
    _kgCtrl.dispose();
    _ipbCtrl.dispose();
    _wptCtrl.dispose();
    _landCtrl.dispose();
    _sellCtrl.dispose();
    super.dispose();
  }

  void _bindControllers(Map<String, dynamic> item) {
    if (_controllersBound) return;
    _controllersBound = true;
    _nameCtrl.text = item['name']?.toString() ?? '';
    _hsnCtrl.text = item['hsn_code']?.toString() ?? '';
    _taxCtrl.text =
        item['tax_percent'] != null ? item['tax_percent'].toString() : '';
    _kgCtrl.text = item['default_kg_per_bag'] != null
        ? item['default_kg_per_bag'].toString()
        : '';
    _ipbCtrl.text = item['default_items_per_box'] != null
        ? item['default_items_per_box'].toString()
        : '';
    _wptCtrl.text = item['default_weight_per_tin'] != null
        ? item['default_weight_per_tin'].toString()
        : '';
    _landCtrl.text = item['default_landing_cost'] != null
        ? item['default_landing_cost'].toString()
        : '';
    _sellCtrl.text = item['default_selling_cost'] != null
        ? item['default_selling_cost'].toString()
        : '';
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item name is required')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final ok = await saveCatalogItemDefaults(
        ref: ref,
        itemId: widget.itemId,
        unit: form.selectedUnit,
        nameCtrl: _nameCtrl,
        hsnCtrl: _hsnCtrl,
        taxCtrl: _taxCtrl,
        kgCtrl: _kgCtrl,
        ipbCtrl: _ipbCtrl,
        wptCtrl: _wptCtrl,
        landCtrl: _landCtrl,
        sellCtrl: _sellCtrl,
      );
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item updated')),
        );
        context.popOrGo('/catalog/item/${widget.itemId}');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyApiError(e))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(catalogItemDetailProvider(widget.itemId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit item'),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: itemAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => FriendlyLoadError(
          message: 'Could not load catalog item',
          onRetry: () =>
              ref.invalidate(catalogItemDetailProvider(widget.itemId)),
        ),
        data: (item) {
          _bindControllers(item);
          return CatalogItemDefaultsEditForm(
            key: _formKey,
            pickerContext: context,
            nameCtrl: _nameCtrl,
            hsnCtrl: _hsnCtrl,
            taxCtrl: _taxCtrl,
            kgCtrl: _kgCtrl,
            ipbCtrl: _ipbCtrl,
            wptCtrl: _wptCtrl,
            landCtrl: _landCtrl,
            sellCtrl: _sellCtrl,
            initialUnit: item['default_unit']?.toString(),
            showHeader: true,
          );
        },
      ),
    );
  }
}

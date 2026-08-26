import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/history_service.dart';
import '../providers/conversion_providers.dart';
import '../providers/history_backup.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<ConversionHistoryEntry> _entries = [];
  List<ConversionHistoryEntry> _filteredEntries = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _applyFilter();
    });
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredEntries = List.from(_entries);
    } else {
      _filteredEntries = _entries
          .where(
            (e) =>
                e.originalText.toLowerCase().contains(_searchQuery) ||
                e.brailleText.toLowerCase().contains(_searchQuery),
          )
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final service = ref.read(historyServiceProvider);
    final entries = await service.loadHistory();
    setState(() {
      _entries = entries;
      _applyFilter();
      _loading = false;
    });
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa lịch sử'),
        content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử chuyển đổi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final service = ref.read(historyServiceProvider);
      await service.clearHistory();
      setState(() {
        _entries = [];
        _applyFilter();
      });
    }
  }

  Future<void> _deleteEntryAt(int filteredIndex) async {
    final entry = _filteredEntries[filteredIndex];
    final originalIndex = _entries.indexOf(entry);
    if (originalIndex < 0) return;

    final service = ref.read(historyServiceProvider);
    await service.deleteEntry(originalIndex);
    setState(() {
      _entries.removeAt(originalIndex);
      _applyFilter();
    });
  }

  /// Xuất toàn bộ lịch sử ra tệp JSON và mở hộp chia sẻ.
  Future<void> _exportHistory() async {
    final service = ref.read(historyServiceProvider);
    final exporter = ref.read(fileExporterProvider);
    try {
      final entries = await service.loadHistory();
      if (entries.isEmpty) {
        _showSnack('Chưa có lịch sử để xuất.');
        return;
      }
      final json = exportHistoryJson(entries);
      final path = await exporter.saveTemp(json, 'lich_su_bien_doi');
      await exporter.share(path);
    } catch (e) {
      _showSnack('Xuất bản sao lưu thất bại: $e');
    }
  }

  /// Chọn tệp JSON backup → kiểm tra schema → hỏi gộp/thay thế → áp dụng.
  Future<void> _importHistory() async {
    final picker = ref.read(filePickerServiceProvider);
    try {
      final result = await picker.pickFile();
      if (result == null) return;

      String raw;
      if (result.bytes != null) {
        raw = utf8.decode(result.bytes!, allowMalformed: false);
      } else if (result.path != null) {
        raw = await File(result.path!).readAsString();
      } else {
        _showSnack('Không đọc được tệp đã chọn.');
        return;
      }

      final parsed = parseHistoryJson(raw);
      if (!parsed.ok) {
        _showSnack(parsed.error!);
        return;
      }

      if (!mounted) return;
      final mode = await _askImportMode(parsed.entries.length);
      if (mode == null || !mounted) return;

      final service = ref.read(historyServiceProvider);
      final affected = mode == 'replace'
          ? await service.replaceAll(parsed.entries)
          : await service.mergeEntries(parsed.entries);

      await _loadHistory();
      _showSnack(
        mode == 'replace'
            ? 'Đã thay thế bằng $affected bản ghi.'
            : 'Đã gộp thêm $affected bản ghi mới.',
      );
    } on FormatException {
      _showSnack('Tệp không phải văn bản UTF-8 hợp lệ.');
    } catch (e) {
      _showSnack('Nhập bản sao lưu thất bại: $e');
    }
  }

  Future<String?> _askImportMode(int count) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập bản sao lưu'),
        content: Text(
          'Tệp chứa $count bản ghi. Bạn muốn gộp vào lịch sử hiện có '
          'hay thay thế hoàn toàn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('merge'),
            child: const Text('Gộp'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop('replace'),
            child: const Text('Thay thế'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    // Các caller gọi sau async-gap; widget có thể đã unmount.
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử chuyển đổi'),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              onPressed: _exportHistory,
              icon: const Icon(Icons.ios_share),
              tooltip: 'Xuất bản sao lưu (JSON)',
            ),
          IconButton(
            onPressed: _importHistory,
            icon: const Icon(Icons.file_open_outlined),
            tooltip: 'Nhập bản sao lưu (JSON)',
          ),
          if (_entries.isNotEmpty)
            IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Xóa lịch sử',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_entries.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm lịch sử...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: _filteredEntries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.history,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Không tìm thấy kết quả'
                                    : 'Chưa có lịch sử chuyển đổi',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredEntries.length,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            final entry = _filteredEntries[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(
                                  entry.originalText,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year} '
                                  '${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: 'Xóa mục này',
                                      onPressed: () => _deleteEntryAt(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy),
                                      tooltip: 'Sao chép Braille',
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(
                                            text: entry.brailleText,
                                          ),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Đã sao chép vào clipboard',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () => _showDetail(context, entry),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  void _showDetail(BuildContext context, ConversionHistoryEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Văn bản gốc',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              SelectableText(entry.originalText),
              const SizedBox(height: 24),
              const Text(
                'Braille Unicode',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              SelectableText(
                entry.brailleText,
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

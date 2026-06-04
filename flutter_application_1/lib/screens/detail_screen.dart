import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/image_saver.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.imageBase64,
    required this.description,
    required this.createdAt,
    required this.fullName,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.heroTag,
  });
  final String imageBase64;
  final String description;
  final DateTime createdAt;
  final String fullName;
  final double? latitude;
  final double? longitude;
  final String category;
  final String heroTag;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Future<void> openMap() async {
    // Validasi latitude dan longitude
    if (widget.latitude == null || widget.longitude == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lokasi tidak tersedia')));
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}',
    );
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAtFormatted = DateFormat(
      'dd MMMM yyyy, HH:mm',
    ).format(widget.createdAt);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Post')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Hero(
                tag: widget.heroTag,
                child: Image.memory(
                  base64Decode(widget.imageBase64),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 250,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImageScreen(
                          imageBase64: widget.imageBase64,
                        ),
                      ),
                    );
                  },
                  tooltip: 'Lihat gambar penuh',
                  style: IconButton.styleFrom(backgroundColor: Colors.black45),
                ),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kiri: Kategori & Waktu
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kategori
                              Row(
                                children: [
                                  const Icon(
                                    Icons.category,
                                    size: 18,
                                    color: Color.fromARGB(255, 223, 0, 0),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Kategori',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 26),
                                child: Text(
                                  widget.category,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Waktu Laporan
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 18,
                                    color: Color.fromARGB(255, 223, 0, 0),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Waktu Laporan',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 26),
                                child: Text(
                                  createdAtFormatted,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Pelapor
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 18,
                                    color: Color.fromARGB(255, 223, 0, 0),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pelapor',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 26),
                                child: Text(
                                  widget.fullName,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Kanan: Icon map
                        IconButton(
                          onPressed:
                              widget.latitude != null &&
                                  widget.longitude != null
                              ? openMap
                              : null,
                          icon: const Icon(
                            Icons.map,
                            size: 38,
                            color: Colors.lightGreen,
                          ),
                          tooltip: "Buka di Google Maps",
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Deskripsi',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImageScreen extends StatefulWidget {
  const FullScreenImageScreen({super.key, required this.imageBase64});
  final String imageBase64;

  @override
  State<FullScreenImageScreen> createState() => _FullScreenImageScreenState();
}

class _FullScreenImageScreenState extends State<FullScreenImageScreen> {
  bool _isSaving = false;

  Uint8List _decodeBase64(String src) {
    final commaIndex = src.indexOf(',');
    final base64Data = commaIndex != -1 ? src.substring(commaIndex + 1) : src;
    return base64Decode(base64Data);
  }

  Future<void> _saveImage() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final bytes = _decodeBase64(widget.imageBase64);
      final fileName = 'fasum_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedPath = await saveImageToDevice(bytes, fileName);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gambar berhasil disimpan: $savedPath'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan gambar: $error'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _decodeBase64(widget.imageBase64);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Gambar Penuh'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _isSaving
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Unduh gambar',
                    onPressed: _saveImage,
                  ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Image.memory(imageBytes, fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              heroTag: 'download_fullscreen',
              onPressed: _isSaving ? null : _saveImage,
              backgroundColor: Colors.blueAccent,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(_isSaving ? 'Menyimpan...' : 'Download'),
            ),
          ),
        ],
      ),
    );
  }
}

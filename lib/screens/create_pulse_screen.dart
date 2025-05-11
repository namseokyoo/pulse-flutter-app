import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/pulse_service.dart';
import '../routes.dart';

class CreatePulseScreen extends StatefulWidget {
  const CreatePulseScreen({super.key});

  @override
  State<CreatePulseScreen> createState() => _CreatePulseScreenState();
}

class _CreatePulseScreenState extends State<CreatePulseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isAnonymous = true;
  final PulseService _pulseService = PulseService();
  bool _isSubmitting = false;

  // 이미지 관련
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // 태그 관련
  final List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _savePulse() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요')));
      return;
    }

    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('내용을 입력해주세요')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 이미지 URL (실제 구현에서는 이미지 업로드 후 URL 획득)
      String? imageUrl;
      if (_imageFile != null) {
        // TODO: 실제 이미지 업로드 구현
        imageUrl = 'https://picsum.photos/200'; // 임시 URL
      }

      _pulseService.createPulse(
        title: title,
        content: content,
        author: _isAnonymous ? '익명' : '사용자', // 실제 사용자 정보로 대체 가능
        imageUrl: imageUrl,
        tags: _tags.isNotEmpty ? _tags : null,
      );

      Routes.goBack(true); // true는 변경이 있었음을 나타냄
    } catch (e) {
      // 에러 처리
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('펄스 작성'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: !_isSubmitting ? _savePulse : null,
            child:
                _isSubmitting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('게시'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 입력
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '제목을 입력하세요',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLength: 50,
              ),

              const SizedBox(height: 16),

              // 에디터
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _contentController,
                  maxLines: 10,
                  minLines: 5,
                  decoration: const InputDecoration(
                    hintText: '당신의 생각을 펄스에 남겨보세요...',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 이미지 첨부
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('이미지 첨부'),
                  ),
                  const SizedBox(width: 16),
                  if (_imageFile != null) ...[
                    Expanded(
                      child: Text(
                        _imageFile!.path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _imageFile = null;
                        });
                      },
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // 태그 추가
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: '태그 입력',
                        prefixText: '# ',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.add), onPressed: _addTag),
                ],
              ),

              const SizedBox(height: 8),

              // 태그 목록
              if (_tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children:
                      _tags.map((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _tags.remove(tag);
                            });
                          },
                        );
                      }).toList(),
                ),

              const SizedBox(height: 16),

              // 익명 스위치
              SwitchListTile(
                title: const Text('익명으로 게시'),
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value;
                  });
                },
              ),

              const SizedBox(height: 16),
              const Text(
                '펄스 유지 시간: 24시간',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

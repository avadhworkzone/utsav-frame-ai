import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/toast.dart';
import '../templates/template_model.dart';
import '../templates/template_repository.dart';

class MarketplaceController extends GetxController {
  final _repo = TemplateRepository();

  final isLoading = true.obs;
  final error = RxnString();
  final templates = <TemplateModel>[].obs;

  final query = TextEditingController();
  final selectedCategory = 'All'.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  List<TemplateModel> get filtered {
    final q = query.text.trim().toLowerCase();
    if (q.isEmpty) return templates;
    return templates.where((t) {
      final hay = '${t.title} ${t.ownerName}'.toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    query.addListener(() => templates.refresh());
    ever(selectedCategory, (_) => _listen());
    _listen();
  }

  void _listen() {
    isLoading.value = true;
    error.value = null;
    _sub?.cancel();
    final cat = selectedCategory.value;
    _sub = _repo.queryMarketplace(category: cat).snapshots().listen(
      (snap) {
        final list = snap.docs.map((d) => TemplateModel.fromMap(d.id, d.data())).toList();
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        templates.value = list;
        isLoading.value = false;
      },
      onError: (e) {
        error.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  void setCategory(String v) => selectedCategory.value = v;

  Future<void> seedStarterTemplates() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      error.value = 'Please login to create starter templates.';
      return;
    }
    try {
      final ownerName = (user.displayName ?? '').trim();
      final now = DateTime.now().toUtc();

      Future<void> create({
        required String title,
        required String category,
        required BackgroundGradient gradient,
        required List<Map<String, dynamic>> layers,
      }) async {
        await _repo.upsert(
          templateId: null,
          title: title,
          ownerName: ownerName,
          backgroundUrl: null,
          backgroundFit: 'contain',
          backgroundMatrix: const [
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1,
          ],
          backgroundRotationDeg: 0,
          backgroundGradient: gradient.toMap(),
          isPublic: true,
          category: category,
          layersAsMaps: layers,
        );
      }

      // 1) Birthday
      await create(
        title: 'Birthday Invitation',
        category: 'Birthday',
        gradient: const BackgroundGradient(
          enabled: true,
          color1: Color(0xFF6C63FF),
          color2: Color(0xFF22D3EE),
          angleDeg: 35,
        ),
        layers: [
          {
            'id': 't1',
            'type': 'text',
            'x': 60,
            'y': 90,
            'w': 330,
            'h': 70,
            'rotation': 0,
            'text': 'BIRTHDAY PARTY',
            'isPlaceholder': false,
            'cornerRadius': 18,
            'imageUrl': null,
            'textStyle': {'fontSize': 30, 'fontWeight': 7, 'color': 0xFFFFFFFF},
          },
          {
            'id': 't2',
            'type': 'text',
            'x': 60,
            'y': 165,
            'w': 330,
            'h': 60,
            'rotation': 0,
            'text': 'You are invited!',
            'isPlaceholder': false,
            'cornerRadius': 18,
            'imageUrl': null,
            'textStyle': {'fontSize': 20, 'fontWeight': 6, 'color': 0xEFFFFFFF},
          },
          {
            'id': 'name',
            'type': 'text',
            'x': 60,
            'y': 580,
            'w': 330,
            'h': 56,
            'rotation': 0,
            'text': 'Your Name',
            'isPlaceholder': true,
            'cornerRadius': 18,
            'imageUrl': null,
            'textStyle': {'fontSize': 22, 'fontWeight': 7, 'color': 0xFFFFFFFF},
          },
          {
            'id': 'photo',
            'type': 'image',
            'x': 120,
            'y': 260,
            'w': 210,
            'h': 250,
            'rotation': 0,
            'text': '',
            'isPlaceholder': true,
            'cornerRadius': 28,
            'imageUrl': null,
            'textStyle': null,
          },
        ],
      );

      // 2) Seminar
      await create(
        title: 'Seminar Poster',
        category: 'Seminar',
        gradient: const BackgroundGradient(
          enabled: true,
          color1: Color(0xFF0F172A),
          color2: Color(0xFF6C63FF),
          angleDeg: 65,
        ),
        layers: [
          {
            'id': 't1',
            'type': 'text',
            'x': 50,
            'y': 80,
            'w': 350,
            'h': 80,
            'rotation': 0,
            'text': 'TECH SEMINAR',
            'isPlaceholder': false,
            'cornerRadius': 18,
            'imageUrl': null,
            'textStyle': {'fontSize': 32, 'fontWeight': 7, 'color': 0xFFFFFFFF},
          },
          {
            'id': 't2',
            'type': 'text',
            'x': 50,
            'y': 165,
            'w': 350,
            'h': 70,
            'rotation': 0,
            'text': 'Sunday • 4:00 PM',
            'isPlaceholder': false,
            'cornerRadius': 18,
            'imageUrl': null,
            'textStyle': {'fontSize': 18, 'fontWeight': 6, 'color': 0xEFFFFFFF},
          },
          {
            'id': 'photo',
            'type': 'image',
            'x': 65,
            'y': 280,
            'w': 320,
            'h': 320,
            'rotation': 0,
            'text': '',
            'isPlaceholder': true,
            'cornerRadius': 28,
            'imageUrl': null,
            'textStyle': null,
          },
          {
            'id': 'name',
            'type': 'text',
            'x': 65,
            'y': 615,
            'w': 320,
            'h': 56,
            'rotation': 0,
            'text': 'Your Name',
            'isPlaceholder': true,
            'cornerRadius': 18,
            'imageUrl': null,
            'textStyle': {'fontSize': 22, 'fontWeight': 7, 'color': 0xFFFFFFFF},
          },
        ],
      );

      // 3) Festival
      await create(
        title: 'Festival Greeting',
        category: 'Festival',
        gradient: const BackgroundGradient(
          enabled: true,
          color1: Color(0xFF8B5CF6),
          color2: Color(0xFF0F172A),
          angleDeg: 25,
        ),
        layers: [
          {
            'id': 't1',
            'type': 'text',
            'x': 50,
            'y': 95,
            'w': 350,
            'h': 90,
            'rotation': 0,
            'text': 'FESTIVAL GREETINGS',
            'isPlaceholder': false,
            'cornerRadius': 18,
            'imageUrl': null,
            'textStyle': {'fontSize': 28, 'fontWeight': 7, 'color': 0xFFFFFFFF},
          },
          {
            'id': 't2',
            'type': 'text',
            'x': 50,
            'y': 190,
            'w': 350,
            'h': 70,
            'rotation': 0,
            'text': 'Wishing you joy & prosperity',
            'isPlaceholder': false,
            'cornerRadius': 18,
            'imageUrl': null,
            'textStyle': {'fontSize': 18, 'fontWeight': 5, 'color': 0xEFFFFFFF},
          },
          {
            'id': 'photo',
            'type': 'image',
            'x': 120,
            'y': 290,
            'w': 210,
            'h': 250,
            'rotation': 0,
            'text': '',
            'isPlaceholder': true,
            'cornerRadius': 999,
            'imageUrl': null,
            'textStyle': null,
          },
          {
            'id': 'name',
            'type': 'text',
            'x': 60,
            'y': 600,
            'w': 330,
            'h': 56,
            'rotation': 0,
            'text': 'Your Name',
            'isPlaceholder': true,
            'cornerRadius': 18,
            'imageUrl': null,
            'textStyle': {'fontSize': 22, 'fontWeight': 7, 'color': 0xFFFFFFFF},
          },
        ],
      );

      // 4) Corporate
      await create(
        title: 'Corporate Event',
        category: 'Corporate',
        gradient: const BackgroundGradient(
          enabled: true,
          color1: Color(0xFF111827),
          color2: Color(0xFF22D3EE),
          angleDeg: 55,
        ),
        layers: [
          {
            'id': 't1',
            'type': 'text',
            'x': 50,
            'y': 95,
            'w': 350,
            'h': 90,
            'rotation': 0,
            'text': 'CORPORATE MEET',
            'isPlaceholder': false,
            'cornerRadius': 18,
            'imageUrl': null,
            'textStyle': {'fontSize': 28, 'fontWeight': 7, 'color': 0xFFFFFFFF},
          },
          {
            'id': 't2',
            'type': 'text',
            'x': 50,
            'y': 190,
            'w': 350,
            'h': 70,
            'rotation': 0,
            'text': 'Location • Time',
            'isPlaceholder': false,
            'cornerRadius': 18,
            'imageUrl': null,
            'textStyle': {'fontSize': 18, 'fontWeight': 5, 'color': 0xEFFFFFFF},
          },
          {
            'id': 'photo',
            'type': 'image',
            'x': 80,
            'y': 300,
            'w': 290,
            'h': 250,
            'rotation': 0,
            'text': '',
            'isPlaceholder': true,
            'cornerRadius': 22,
            'imageUrl': null,
            'textStyle': null,
          },
          {
            'id': 'name',
            'type': 'text',
            'x': 80,
            'y': 575,
            'w': 290,
            'h': 56,
            'rotation': 0,
            'text': 'Your Name',
            'isPlaceholder': true,
            'cornerRadius': 18,
            'imageUrl': null,
            'textStyle': {'fontSize': 22, 'fontWeight': 7, 'color': 0xFFFFFFFF},
          },
        ],
      );

      Toast.success('Marketplace', 'Starter templates created.');
    } catch (e) {
      error.value = e.toString();
    }
  }

  @override
  void onClose() {
    query.dispose();
    _sub?.cancel();
    super.onClose();
  }
}

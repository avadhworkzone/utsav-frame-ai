import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../templates/template_model.dart';
import '../templates/template_repository.dart';

class DashboardController extends GetxController {
  final _repo = TemplateRepository();

  final isLoading = true.obs;
  final templates = <TemplateModel>[].obs;
  final error = RxnString();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  int get totalTemplates => templates.length;

  @override
  void onInit() {
    super.onInit();
    _listen();
  }

  void _listen() {
    isLoading.value = true;
    error.value = null;
    _sub?.cancel();
    try {
      _sub = _repo.queryMyTemplates().snapshots().listen(
        (snap) {
          templates.value = snap.docs.map((d) => TemplateModel.fromMap(d.id, d.data())).toList();
          isLoading.value = false;
        },
        onError: (e) {
          error.value = e.toString();
          isLoading.value = false;
        },
      );
    } catch (e) {
      error.value = e.toString();
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}

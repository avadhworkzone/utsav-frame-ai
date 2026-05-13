import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'template_model.dart';

class TemplateRepository {
  TemplateRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instanceFor(bucket: 'gs://utsavframeai.firebasestorage.app');

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _col => _firestore.collection('templates');

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseException(
        plugin: 'template_repository',
        code: 'not-authenticated',
        message: 'You must be signed in to create or edit templates.',
      );
    }
    return user.uid;
  }

  Future<TemplateModel> getById(String id) async {
    final snap = await _col.doc(id).get();
    final data = snap.data();
    if (data == null) {
      throw StateError('Template not found');
    }
    return TemplateModel.fromMap(snap.id, data);
  }

  Future<String> upsert({
    required String? templateId,
    required String title,
    required String ownerName,
    required String? backgroundUrl,
    required String backgroundFit,
    required List<double> backgroundMatrix,
    required double backgroundRotationDeg,
    required Map<String, dynamic> backgroundGradient,
    required bool isPublic,
    required String? category,
    required List<dynamic> layersAsMaps,
  }) async {
    final now = DateTime.now().toUtc();
    final doc = templateId == null ? _col.doc() : _col.doc(templateId);
    final existing = await doc.get();
    await doc.set(
      {
        'ownerUid': _uid,
        'ownerName': ownerName,
        'title': title,
        'backgroundUrl': backgroundUrl,
        'backgroundFit': backgroundFit,
        'backgroundMatrix': backgroundMatrix,
        'backgroundRotationDeg': backgroundRotationDeg,
        'backgroundGradient': backgroundGradient,
        'isPublic': isPublic,
        'category': category,
        'layers': layersAsMaps,
        'updatedAt': now.toIso8601String(),
        'createdAt': (existing.data()?['createdAt'] as String?) ?? now.toIso8601String(),
      },
      SetOptions(merge: true),
    );
    return doc.id;
  }

  Query<Map<String, dynamic>> queryMyTemplates() {
    final uid = _uid;
    return _col.where('ownerUid', isEqualTo: uid).orderBy('updatedAt', descending: true);
  }

  Query<Map<String, dynamic>> queryMarketplace({String? category, String? search}) {
    // Avoid composite-index requirements by not using orderBy with where clauses.
    // We'll sort client-side in the marketplace controller.
    Query<Map<String, dynamic>> q = _col.where('isPublic', isEqualTo: true);
    if (category != null && category.trim().isNotEmpty && category != 'All') {
      q = q.where('category', isEqualTo: category.trim());
    }
    // Firestore doesn't support contains search without extra indexing; keep client-side filter for now.
    return q;
  }

  Future<String> uploadBackgroundBytes({
    required String templateId,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref('templates/$templateId/background.jpg');
    final meta = SettableMetadata(contentType: 'image/jpeg');
    await ref.putData(bytes, meta);
    return ref.getDownloadURL();
  }

  Future<String> uploadLayerImageBytes({
    required String templateId,
    required String layerId,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref('templates/$templateId/assets/$layerId.png');
    final meta = SettableMetadata(contentType: 'image/png');
    await ref.putData(bytes, meta);
    return ref.getDownloadURL();
  }
}

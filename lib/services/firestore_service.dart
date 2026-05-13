import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:enreda_app/services/firestore_monitor.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  Future<void> addData(
      {required String path, required Map<String, dynamic> data}) async {
    final reference = FirebaseFirestore.instance.collection(path);
    FirestoreMonitor.logWrite(path);
    await reference.add(data);
  }

  Future<String> addDataFile(
      {required String path, Map<String, dynamic>? data}) async {
    final CollectionReference<Map<String, dynamic>?> reference = FirebaseFirestore.instance.collection(path);
    FirestoreMonitor.logWrite(path);
    return await reference.add(data).then((value) => value.id);
  }

  Future<void> updateData(
      {required String path, required Map<String, dynamic> data}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    FirestoreMonitor.logWrite(path);
    await reference.set(data, SetOptions(merge: true));
  }

  Future<void> deleteData({required String path}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    FirestoreMonitor.logDelete(path);
    await reference.delete();
  }

  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentId) builder,
    required Query Function(Query theQueryReceivedAsParameter) queryBuilder,
    required int Function(T lhs, T rhs) sort,
  }) {
    Query instancedQuery = FirebaseFirestore.instance.collection(path);
    Query filteredQuery = queryBuilder(instancedQuery);
    final snapshots = filteredQuery.snapshots();
    return snapshots.map((snapshot) {
      FirestoreMonitor.logRead(path, count: snapshot.docs.length);

      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data() as Map<String, dynamic>, snapshot.id))
          .where((value) => value != null)
          .toList();
      result.sort(sort);
      return result;
    });
  }

  Stream<T> documentStreamByField<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentId) builder,
    Query Function(Query query)? queryBuilder,
  }) {
    Query query = FirebaseFirestore.instance.collection(path);

    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final snapshots = query.limit(1).snapshots();
    return snapshots.map((snapshot) {
      FirestoreMonitor.logRead(path, count: snapshot.docs.length);
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data() as Map<String, dynamic>, snapshot.id))
          .where((value) => value != null)
          .toList();

      return result.first;
    });
  }

  Stream<List<T>> filteredCollectionStream<T>({
    required String path,
    required T? Function(Map<String, dynamic> data, String documentId) builder,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      FirestoreMonitor.logRead(path, count: snapshot.docs.length);
      final map = snapshot.docs
          .map((snapshot) => builder(snapshot.data(), snapshot.id));
      final List<T> result = [];
        map.toList();
        map.forEach((element) {
          if (element != null) result.add(element);
        });

      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  Stream<T> documentStream<T>({
    required String path,
    required T builder(Map<String, dynamic> data, String documentID),
  }) {
    final reference = FirebaseFirestore.instance.doc(path);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) {
      if (snapshot.exists) {
        FirestoreMonitor.logRead(path, count: 1);
        return builder(snapshot.data()!, snapshot.id);
      } else {
        throw Exception('Document $path does not exist');
      }
    });
  }

  /// Cursor-paginated one-shot fetch.
  ///
  /// Designed for browse-style pages where live updates are NOT required
  /// (e.g. participant resource browsing). Each call reads exactly [pageSize]
  /// documents from Firestore — no quadratic re-reads on scroll like the
  /// legacy `limit += 50` pattern.
  ///
  /// The caller passes a [queryBuilder] that MUST include an `orderBy(...)`
  /// clause; otherwise `startAfterDocument` cannot anchor the cursor.
  Future<({List<T> items, DocumentSnapshot<Object?>? cursor, bool hasMore})>
      paginatedFetch<T>({
    required String path,
    required Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)
        queryBuilder,
    required T? Function(Map<String, dynamic> data, String documentId) builder,
    DocumentSnapshot<Object?>? startAfter,
    int pageSize = 50,
  }) async {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection(path);
    query = queryBuilder(query).limit(pageSize);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    final snapshot = await query.get();
    FirestoreMonitor.logRead(path, count: snapshot.docs.length);
    final docs = snapshot.docs;
    final List<T> items = [];
    for (final doc in docs) {
      final built = builder(doc.data(), doc.id);
      if (built != null) items.add(built);
    }
    return (
      items: items,
      cursor: docs.isEmpty ? null : docs.last,
      hasMore: docs.length >= pageSize,
    );
  }
}

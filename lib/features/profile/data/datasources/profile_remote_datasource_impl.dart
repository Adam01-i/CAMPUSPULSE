import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart';
import 'profile_remote_datasource.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ProfileRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance;

  @override
  Future<ProfileModel> getProfile() async {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception("Utilisateur non connecté");
    }

    final doc = await firestore.collection('users').doc(user.uid).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception("Profil introuvable");
    }

    return ProfileModel.fromJson(doc.data()!);
  }
}

import './exceptions.dart';

String mapError(Object error) {
  if (error is NetworkException) {
    return 'Aucune connexion Internet';
  }

  if (error is ServerException) {
    return 'Serveur indisponible';
  }

  return 'Une erreur est survenue';
}
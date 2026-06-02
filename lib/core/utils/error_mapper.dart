import 'package:flutter_application_2/core/errors/exceptions.dart';

String mapError(Object error) {
  if (error is NetworkException) {
    return 'Aucune connexion Internet';
  }

  if (error is ServerException) {
    return 'Serveur indisponible';
  }

  return 'Une erreur est survenue';
}
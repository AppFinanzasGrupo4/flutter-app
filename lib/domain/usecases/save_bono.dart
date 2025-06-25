import 'package:flutter_finanzasapp/data/repositories/bono_repository.dart';
import 'package:flutter_finanzasapp/domain/entities/bono_entity.dart';

class SaveBono {
  final BonoRepository repository;

  SaveBono(this.repository);

  Future<void> call(BonoEntity bono) {
    return repository.saveBono(bono);
  }
}

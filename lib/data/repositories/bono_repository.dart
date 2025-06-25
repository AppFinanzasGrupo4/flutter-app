import 'package:flutter_finanzasapp/domain/entities/bono_entity.dart';

abstract class BonoRepository {
  Future<void> saveBono(BonoEntity bono);
}

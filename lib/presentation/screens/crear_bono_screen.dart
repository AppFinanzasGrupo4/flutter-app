import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/core/constants/tipo_gracia.dart';
import 'package:flutter_finanzasapp/data/datasources/bono_local_datasource.dart';
import 'package:flutter_finanzasapp/data/datasources/config_local_datasource.dart';
import 'package:flutter_finanzasapp/data/models/bono_model.dart';
import 'package:flutter_finanzasapp/data/repositories/config_repository_impl.dart';
import '../../../../../core/constants/input_decoration.dart';
import '../../../../../core/constants/monedas.dart';

class CrearBonoScreen extends StatefulWidget {
  final BonoModel? bonoExistente;

  const CrearBonoScreen({super.key, this.bonoExistente});

  @override
  State<CrearBonoScreen> createState() => _CrearBonoScreenState();
}

class _CrearBonoScreenState extends State<CrearBonoScreen> {
  final _formKey = GlobalKey<FormState>();

  String? moneda;
  String? tipoTasa;
  String? capitalizacion;

  DateTime? fechaEmision;
  DateTime? fechaVencimiento;

  TipoGracia tipoGracia = TipoGracia.ninguna;

  final _nombreCtrl = TextEditingController();
  final _valorNominalCtrl = TextEditingController();
  final _plazoCtrl = TextEditingController();
  final _tasaCtrl = TextEditingController();
  final _periodoGraciaCtrl = TextEditingController();
  final _fechaEmisionCtrl = TextEditingController();
  final _fechaVencimientoCtrl = TextEditingController();
  final _primaRedencionCtrl = TextEditingController();
  final _frecuenciaPagoCtrl = TextEditingController(text: 'Mensual');

  final capitalizaciones = [
    'Mensual',
    'Bimestral',
    'Trimestral',
    'Semestral',
    'Anual',
  ];

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _loadDefaultConfig();
    if (widget.bonoExistente != null) {
      // Si se está editando un bono existente, cargar sus datos
      _nombreCtrl.text = widget.bonoExistente!.nombre;
      _valorNominalCtrl.text = widget.bonoExistente!.valorNominal.toString();
      _plazoCtrl.text = widget.bonoExistente!.plazo.toString();
      _tasaCtrl.text = widget.bonoExistente!.tasaInteres.toString();
      moneda = widget.bonoExistente!.moneda;
      tipoTasa = widget.bonoExistente!.tipoTasa;
      capitalizacion = widget.bonoExistente!.capitalizacion;
      tipoGracia = widget.bonoExistente!.tipoGracia;
      if (tipoGracia != TipoGracia.ninguna) {
        _periodoGraciaCtrl.text =
            widget.bonoExistente!.periodoGracia.toString();
      }
      _frecuenciaPagoCtrl.text = widget.bonoExistente!.frecuenciaPago;
      _fechaEmisionCtrl.text = widget.bonoExistente!.fechaEmision.toString();
      _fechaVencimientoCtrl.text =
          widget.bonoExistente!.fechaVencimiento.toString();
      _primaRedencionCtrl.text =
          widget.bonoExistente!.primaRedencion.toString();
      fechaEmision = widget.bonoExistente!.fechaEmision;
      fechaVencimiento = widget.bonoExistente!.fechaVencimiento;
    }
  }

  Future<void> _loadDefaultConfig() async {
    final bono = widget.bonoExistente;

    if (bono != null) {
      // Cargar valores desde bono existente
      _nombreCtrl.text = bono.nombre;
      _valorNominalCtrl.text = bono.valorNominal.toString();
      _plazoCtrl.text = bono.plazo.toString();
      _tasaCtrl.text = bono.tasaInteres.toString();
      _fechaEmisionCtrl.text = bono.fechaEmision.toString();
      _fechaVencimientoCtrl.text = bono.fechaVencimiento.toString();
      _primaRedencionCtrl.text = bono.primaRedencion.toString();
      _frecuenciaPagoCtrl.text = bono.frecuenciaPago.toString();

      setState(() {
        moneda = bono.moneda;
        tipoTasa = bono.tipoTasa;
        capitalizacion = bono.capitalizacion;
        cargando = false;
      });
    } else {
      // Cargar configuración
      final configRepo = ConfigRepositoryImpl(ConfigLocalDatasource());
      final config = await configRepo.getConfig();

      if (!mounted) return;

      setState(() {
        moneda = config?.moneda ?? 'PEN';
        tipoTasa = config?.tipoTasa ?? 'Efectiva';
        capitalizacion = config?.capitalizacion;
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Bono')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: inputDecoration('Nombre del Bono'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: moneda,
                decoration: inputDecoration('Moneda'),
                items:
                    monedas
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                onChanged: (value) => setState(() => moneda = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorNominalCtrl,
                keyboardType: TextInputType.number,
                decoration: inputDecoration('Valor Nominal'),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: inputDecoration('Frecuencia de Pago'),
                value: 'Mensual', // Asignar valor por defecto
                items:
                    ['Mensual', 'Bimestral', 'Trimestral', 'Semestral', 'Anual']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                onChanged: (value) {
                  // No se necesita lógica aquí, ya que es un valor por defecto
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TipoGracia>(
                value: tipoGracia,
                decoration: inputDecoration('Tipo de Gracia'),
                items:
                    TipoGracia.values.map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo.toString().split('.').last),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      tipoGracia = value;
                      // Limpiar periodo de gracia si se cambia el tipo
                      if (tipoGracia == TipoGracia.ninguna) {
                        _periodoGraciaCtrl.clear();
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (tipoGracia != TipoGracia.ninguna)
                TextFormField(
                  controller: _periodoGraciaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: inputDecoration(
                    'Periodo de Gracia (en frecuencias)',
                  ),
                  validator: (value) {
                    if (tipoGracia != TipoGracia.ninguna &&
                        (value == null || value.isEmpty)) {
                      return 'Este campo es obligatorio si se selecciona un tipo de gracia';
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: tipoTasa,
                decoration: inputDecoration('Tipo de Tasa'),
                items:
                    ['Efectiva', 'Nominal']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    tipoTasa = value;
                    if (tipoTasa == 'Efectiva') capitalizacion = null;
                  });
                },
              ),
              if (tipoTasa == 'Nominal') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: capitalizacion,
                  decoration: inputDecoration('Capitalización'),
                  items:
                      capitalizaciones
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => capitalizacion = value),
                ),
              ],

              const SizedBox(height: 16),
              TextFormField(
                controller: _plazoCtrl,
                keyboardType: TextInputType.number,
                decoration: inputDecoration('Plazo en años'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: inputDecoration('Fecha de Emisión'),
                controller: _fechaEmisionCtrl,
                readOnly: true,
                onTap: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (fecha != null) {
                    setState(() {
                      fechaEmision = fecha;
                      _fechaEmisionCtrl.text = fecha.toIso8601String();
                      _fechaVencimientoCtrl.text =
                          fecha
                              .add(
                                Duration(
                                  days:
                                      (int.tryParse(_plazoCtrl.text) ?? 0) *
                                      360,
                                ),
                              )
                              .toIso8601String();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fechaVencimientoCtrl,
                readOnly: true,
                decoration: inputDecoration('Fecha de Vencimiento'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tasaCtrl,
                keyboardType: TextInputType.number,
                decoration: inputDecoration('Tasa de interés (%)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: inputDecoration('Prima de Redención (%)'),
                keyboardType: TextInputType.number,
                controller: _primaRedencionCtrl,
                onChanged: (value) {
                  // Validar que sea un número válido
                  if (value.isNotEmpty && double.tryParse(value) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ingrese un valor numérico válido para la prima de redención.',
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // Validar formulario antes de guardar

                  if (_formKey.currentState?.validate() ?? false) {
                    final isEditando = widget.bonoExistente != null;

                    final bono = BonoModel(
                      id: widget.bonoExistente?.id, // Mantener ID si es edición
                      nombre: _nombreCtrl.text.trim(),
                      moneda: moneda!,
                      tipoTasa: tipoTasa!,
                      capitalizacion:
                          tipoTasa == 'Nominal' ? capitalizacion : null,
                      valorNominal:
                          double.tryParse(_valorNominalCtrl.text) ?? 0,
                      plazo: int.tryParse(_plazoCtrl.text) ?? 0,
                      tasaInteres: double.tryParse(_tasaCtrl.text) ?? 0,
                      tipoGracia: tipoGracia,
                      periodoGracia:
                          tipoGracia != TipoGracia.ninguna
                              ? int.tryParse(_periodoGraciaCtrl.text) ?? 0
                              : 0,
                      frecuenciaPago: 'Mensual', // Asignar valor por defecto
                      fechaEmision: DateTime.now(),
                      fechaVencimiento: DateTime.now().add(
                        Duration(
                          days:
                              (int.tryParse(_plazoCtrl.text) ?? 0) *
                              360, // Asignar fecha de vencimiento
                        ),
                      ),
                      primaRedencion:
                          double.tryParse(_primaRedencionCtrl.text) ?? 0,
                    );

                    final db = await BonoLocalDatasource().database;
                    if (isEditando) {
                      // Actualizar bono existente
                      await db.update(
                        'bonos',
                        bono.toMap(),
                        where: 'id = ?',
                        whereArgs: [bono.id],
                      );
                    } else {
                      // Insertar nuevo bono
                      await db.insert('bonos', bono.toMap());
                    }

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditando
                              ? 'Bono actualizado exitosamente'
                              : 'Bono creado exitosamente',
                        ),
                      ),
                    );

                    // Opcional: limpiar formulario
                    _nombreCtrl.clear();
                    _valorNominalCtrl.clear();
                    _plazoCtrl.clear();
                    _tasaCtrl.clear();
                  }
                },

                child: const Text('Guardar Bono'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

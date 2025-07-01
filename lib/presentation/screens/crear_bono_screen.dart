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
  final _frecuenciaTasaCtrl = TextEditingController();
  final _periodoGraciaCtrl = TextEditingController();
  final _fechaEmisionCtrl = TextEditingController();
  final _fechaVencimientoCtrl = TextEditingController();
  final _primaRedencionCtrl = TextEditingController();
  final _frecuenciaPagoCtrl = TextEditingController();
  final _costoEstructuracionCtrl = TextEditingController();
  final _costoColocacionCtrl = TextEditingController();
  final _costoFlotacionCtrl = TextEditingController();
  final _costoCavaliCtrl = TextEditingController();

  final frecuencias = [
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
      _frecuenciaTasaCtrl.text = widget.bonoExistente!.frecuenciaTasa ?? '';
      moneda = widget.bonoExistente!.moneda;
      tipoTasa = widget.bonoExistente!.tipoTasa;
      capitalizacion = widget.bonoExistente!.capitalizacion;
      tipoGracia = widget.bonoExistente!.tipoGracia;
      if (tipoGracia != TipoGracia.ninguna) {
        _periodoGraciaCtrl.text =
            widget.bonoExistente!.periodoGracia.toString();
      }
      _frecuenciaPagoCtrl.text =
          widget.bonoExistente!.frecuenciaPago.toString();
      _fechaEmisionCtrl.text = widget.bonoExistente!.fechaEmision.toString();
      _fechaVencimientoCtrl.text =
          widget.bonoExistente!.fechaVencimiento.toString();
      _primaRedencionCtrl.text =
          widget.bonoExistente!.primaRedencion.toString();
      fechaEmision = widget.bonoExistente!.fechaEmision;
      fechaVencimiento = widget.bonoExistente!.fechaVencimiento;
      _costoEstructuracionCtrl.text =
          widget.bonoExistente!.costoEstructuracion.toString();
      _costoColocacionCtrl.text =
          widget.bonoExistente!.costoColocacion.toString();
      _costoFlotacionCtrl.text =
          widget.bonoExistente!.costoFlotacion.toString();
      _costoCavaliCtrl.text = widget.bonoExistente!.costoCavali.toString();
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
      _frecuenciaTasaCtrl.text = bono.frecuenciaTasa ?? '';
      _fechaEmisionCtrl.text = bono.fechaEmision.toString();
      _fechaVencimientoCtrl.text = bono.fechaVencimiento.toString();
      _costoEstructuracionCtrl.text = bono.costoEstructuracion.toString();
      _costoColocacionCtrl.text = bono.costoColocacion.toString();
      _costoFlotacionCtrl.text = bono.costoFlotacion.toString();
      _costoCavaliCtrl.text = bono.costoCavali.toString();
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
                value:
                    _frecuenciaPagoCtrl.text.isEmpty
                        ? null
                        : _frecuenciaPagoCtrl.text,
                items:
                    ['Mensual', 'Bimestral', 'Trimestral', 'Semestral', 'Anual']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _frecuenciaPagoCtrl.text = value ?? '';
                  });
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: inputDecoration('Frecuencia de Tasa'),
                value:
                    _frecuenciaTasaCtrl.text.isEmpty
                        ? null
                        : _frecuenciaTasaCtrl.text,
                items:
                    ['Mensual', 'Bimestral', 'Trimestral', 'Semestral', 'Anual']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _frecuenciaTasaCtrl.text = value ?? '';
                  });
                },
              ),
              if (tipoTasa == 'Nominal') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: capitalizacion,
                  decoration: inputDecoration('Capitalización'),
                  items:
                      frecuencias
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => capitalizacion = value),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _tasaCtrl,
                keyboardType: TextInputType.number,
                decoration: inputDecoration('Tasa de interés (%)'),
              ),
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
                controller: _costoEstructuracionCtrl,
                keyboardType: TextInputType.number,
                decoration: inputDecoration('Costo de Estructuración (%)'),
                onChanged: (value) {
                  // Validar que sea un número válido
                  if (value.isNotEmpty && double.tryParse(value) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ingrese un valor numérico válido para el costo de estructuración.',
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: inputDecoration('Costo de Colocación (%)'),
                keyboardType: TextInputType.number,
                controller: _costoColocacionCtrl,
                onChanged: (value) {
                  // Validar que sea un número válido
                  if (value.isNotEmpty && double.tryParse(value) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ingrese un valor numérico válido para el costo de colocación.',
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: inputDecoration('Costo de Flotación (%)'),
                keyboardType: TextInputType.number,
                controller: _costoFlotacionCtrl,
                onChanged: (value) {
                  // Validar que sea un número válido
                  if (value.isNotEmpty && double.tryParse(value) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ingrese un valor numérico válido para el costo de flotación.',
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: inputDecoration('Costo de Cavali (%)'),
                keyboardType: TextInputType.number,
                controller: _costoCavaliCtrl,
                onChanged: (value) {
                  // Validar que sea un número válido
                  if (value.isNotEmpty && double.tryParse(value) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ingrese un valor numérico válido para el costo de Cavali.',
                        ),
                      ),
                    );
                  }
                },
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
                      frecuenciaTasa: _frecuenciaTasaCtrl.text,
                      tipoGracia: tipoGracia,
                      periodoGracia:
                          tipoGracia != TipoGracia.ninguna
                              ? int.tryParse(_periodoGraciaCtrl.text) ?? 0
                              : 0,
                      frecuenciaPago: _frecuenciaPagoCtrl.text,
                      fechaEmision: DateTime.now(),
                      fechaVencimiento: DateTime.now().add(
                        Duration(
                          days:
                              (int.tryParse(_plazoCtrl.text) ?? 0) *
                              360, // Asignar fecha de vencimiento
                        ),
                      ),
                      costoEstructuracion:
                          double.tryParse(_costoEstructuracionCtrl.text) ?? 0,
                      costoColocacion:
                          double.tryParse(_costoColocacionCtrl.text) ?? 0,
                      costoFlotacion:
                          double.tryParse(_costoFlotacionCtrl.text) ?? 0,
                      costoCavali: double.tryParse(_costoCavaliCtrl.text) ?? 0,
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

import 'package:flutter/material.dart';
import 'package:flutter_finanzasapp/core/constants/tipo_gracia.dart';
import 'package:flutter_finanzasapp/core/services/session_service.dart';
import 'package:flutter_finanzasapp/data/datasources/bono_local_datasource.dart';
import 'package:flutter_finanzasapp/data/datasources/config_local_datasource.dart';
import 'package:flutter_finanzasapp/data/models/bono_model.dart';
import 'package:flutter_finanzasapp/data/repositories/config_repository_impl.dart';
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
    'Cuatrimestral',
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
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.indigo[50]!, Colors.white],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando configuración...'),
              ],
            ),
          ),
        ),
      );
    }

    final isEditando = widget.bonoExistente != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditando ? 'Editar Bono' : 'Crear Nuevo Bono'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.indigo[600]!, Colors.indigo[700]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          isEditando ? Icons.edit : Icons.add_circle,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditando ? 'Modificar Bono' : 'Nuevo Bono',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isEditando
                                    ? 'Actualiza la información del bono'
                                    : 'Complete los datos para crear un nuevo bono',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Información Básica
                _buildSectionCard(
                  'Información Básica',
                  Icons.info_outline,
                  Colors.blue,
                  [
                    _buildStyledTextField(
                      controller: _nombreCtrl,
                      label: 'Nombre del Bono',
                      icon: Icons.account_balance,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre del bono es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildStyledDropdown<String>(
                      value: moneda,
                      label: 'Moneda',
                      icon: Icons.attach_money,
                      items:
                          monedas
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                      onChanged: (value) => setState(() => moneda = value),
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      controller: _valorNominalCtrl,
                      label: 'Valor Nominal',
                      icon: Icons.monetization_on,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El valor nominal es obligatorio';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingrese un valor numérico válido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Configuración de Pagos
                _buildSectionCard(
                  'Configuración de Pagos',
                  Icons.payment,
                  Colors.green,
                  [
                    _buildStyledDropdown<String>(
                      value:
                          _frecuenciaPagoCtrl.text.isEmpty
                              ? null
                              : _frecuenciaPagoCtrl.text,
                      label: 'Frecuencia de Pago',
                      icon: Icons.schedule,
                      items:
                          [
                                'Mensual',
                                'Bimestral',
                                'Trimestral',
                                'Cuatrimestral',
                                'Semestral',
                                'Anual',
                              ]
                              .map(
                                (f) =>
                                    DropdownMenuItem(value: f, child: Text(f)),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _frecuenciaPagoCtrl.text = value ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildStyledDropdown<TipoGracia>(
                      value: tipoGracia,
                      label: 'Tipo de Gracia',
                      icon: Icons.pause_circle_outline,
                      items:
                          TipoGracia.values.map((tipo) {
                            return DropdownMenuItem(
                              value: tipo,
                              child: Text(_getTipoGraciaText(tipo)),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            tipoGracia = value;
                            if (tipoGracia == TipoGracia.ninguna) {
                              _periodoGraciaCtrl.clear();
                            }
                          });
                        }
                      },
                    ),
                    if (tipoGracia != TipoGracia.ninguna) ...[
                      const SizedBox(height: 16),
                      _buildStyledTextField(
                        controller: _periodoGraciaCtrl,
                        label: 'Período de Gracia (en períodos)',
                        icon: Icons.timer,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (tipoGracia != TipoGracia.ninguna &&
                              (value == null || value.isEmpty)) {
                            return 'Este campo es obligatorio si se selecciona un tipo de gracia';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 20),

                // Configuración de Tasa
                _buildSectionCard(
                  'Configuración de Tasa',
                  Icons.trending_up,
                  Colors.orange,
                  [
                    _buildStyledDropdown<String>(
                      value: tipoTasa,
                      label: 'Tipo de Tasa',
                      icon: Icons.percent,
                      items:
                          ['Efectiva', 'Nominal']
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          tipoTasa = value;
                          if (tipoTasa == 'Efectiva') capitalizacion = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildStyledDropdown<String>(
                      value:
                          _frecuenciaTasaCtrl.text.isEmpty
                              ? null
                              : _frecuenciaTasaCtrl.text,
                      label: 'Frecuencia de Tasa',
                      icon: Icons.access_time,
                      items:
                          [
                                'Mensual',
                                'Bimestral',
                                'Trimestral',
                                'Cuatrimestral',
                                'Semestral',
                                'Anual',
                              ]
                              .map(
                                (f) =>
                                    DropdownMenuItem(value: f, child: Text(f)),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _frecuenciaTasaCtrl.text = value ?? '';
                        });
                      },
                    ),
                    if (tipoTasa == 'Nominal') ...[
                      const SizedBox(height: 16),
                      _buildStyledDropdown<String>(
                        value: capitalizacion,
                        label: 'Capitalización',
                        icon: Icons.repeat,
                        items:
                            frecuencias
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() => capitalizacion = value),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      controller: _tasaCtrl,
                      label: 'Tasa de Interés (%)',
                      icon: Icons.show_chart,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La tasa de interés es obligatoria';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingrese un valor numérico válido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Plazos y Fechas
                _buildSectionCard(
                  'Plazos y Fechas',
                  Icons.calendar_today,
                  Colors.purple,
                  [
                    _buildStyledTextField(
                      controller: _plazoCtrl,
                      label: 'Plazo (años)',
                      icon: Icons.schedule,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El plazo es obligatorio';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Ingrese un número entero válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      controller: _fechaEmisionCtrl,
                      label: 'Fecha de Emisión',
                      icon: Icons.event,
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
                                            (int.tryParse(_plazoCtrl.text) ??
                                                0) *
                                            360,
                                      ),
                                    )
                                    .toIso8601String();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      controller: _fechaVencimientoCtrl,
                      label: 'Fecha de Vencimiento',
                      icon: Icons.event_available,
                      readOnly: true,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Costos y Comisiones
                _buildSectionCard(
                  'Costos y Comisiones',
                  Icons.account_balance_wallet,
                  Colors.red,
                  [
                    _buildStyledTextField(
                      controller: _costoEstructuracionCtrl,
                      label: 'Costo de Estructuración (%)',
                      icon: Icons.engineering,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      controller: _costoColocacionCtrl,
                      label: 'Costo de Colocación (%)',
                      icon: Icons.place,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      controller: _costoFlotacionCtrl,
                      label: 'Costo de Flotación (%)',
                      icon: Icons.waves,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      controller: _costoCavaliCtrl,
                      label: 'Costo Cavali (%)',
                      icon: Icons.security,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      controller: _primaRedencionCtrl,
                      label: 'Prima de Redención (%)',
                      icon: Icons.redeem,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Botón de Guardar
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await _guardarBono();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isEditando ? Icons.save : Icons.add_circle),
                        const SizedBox(width: 8),
                        Text(
                          isEditando ? 'Actualizar Bono' : 'Crear Bono',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para guardar el bono (extraído del código original)
  Future<void> _guardarBono() async {
    final isEditando = widget.bonoExistente != null;
    final userId = SessionService().currentUserId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Usuario no identificado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bono = BonoModel(
      id: widget.bonoExistente?.id, // Mantener ID si es edición
      userId: userId, // ID del emisor actual
      nombre: _nombreCtrl.text.trim(),
      moneda: moneda!,
      tipoTasa: tipoTasa!,
      capitalizacion: tipoTasa == 'Nominal' ? capitalizacion : null,
      valorNominal: double.tryParse(_valorNominalCtrl.text) ?? 0,
      plazo: int.tryParse(_plazoCtrl.text) ?? 0,
      tasaInteres: double.tryParse(_tasaCtrl.text) ?? 0,
      frecuenciaTasa: _frecuenciaTasaCtrl.text,
      tipoGracia: tipoGracia,
      periodoGracia:
          tipoGracia != TipoGracia.ninguna
              ? int.tryParse(_periodoGraciaCtrl.text) ?? 0
              : 0,
      frecuenciaPago: _frecuenciaPagoCtrl.text,
      fechaEmision: fechaEmision ?? DateTime.now(),
      fechaVencimiento:
          fechaVencimiento ??
          DateTime.now().add(
            Duration(days: (int.tryParse(_plazoCtrl.text) ?? 0) * 360),
          ),
      costoEstructuracion: double.tryParse(_costoEstructuracionCtrl.text) ?? 0,
      costoColocacion: double.tryParse(_costoColocacionCtrl.text) ?? 0,
      costoFlotacion: double.tryParse(_costoFlotacionCtrl.text) ?? 0,
      costoCavali: double.tryParse(_costoCavaliCtrl.text) ?? 0,
      primaRedencion: double.tryParse(_primaRedencionCtrl.text) ?? 0,
    );

    final dataSource = BonoLocalDatasource();
    if (isEditando) {
      await dataSource.updateBono(bono);
    } else {
      await dataSource.insertBono(bono);
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditando
              ? 'Bono actualizado exitosamente'
              : 'Bono creado exitosamente',
        ),
        backgroundColor: Colors.green,
      ),
    );

    if (!isEditando) {
      // Limpiar formulario solo si es creación nueva
      _nombreCtrl.clear();
      _valorNominalCtrl.clear();
      _plazoCtrl.clear();
      _tasaCtrl.clear();
      _frecuenciaTasaCtrl.clear();
      _frecuenciaPagoCtrl.clear();
      _periodoGraciaCtrl.clear();
      _fechaEmisionCtrl.clear();
      _fechaVencimientoCtrl.clear();
      _costoEstructuracionCtrl.clear();
      _costoColocacionCtrl.clear();
      _costoFlotacionCtrl.clear();
      _costoCavaliCtrl.clear();
      _primaRedencionCtrl.clear();
      setState(() {
        moneda = 'PEN';
        tipoTasa = 'Efectiva';
        capitalizacion = null;
        tipoGracia = TipoGracia.ninguna;
        fechaEmision = null;
        fechaVencimiento = null;
      });
    }
  }

  Widget _buildSectionCard(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.05), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo[600]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildStyledDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo[600]!, width: 2),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    VoidCallback? onTap,
    bool readOnly = true,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo[600]),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.indigo[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo[600]!, width: 2),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  String _getTipoGraciaText(TipoGracia tipo) {
    switch (tipo) {
      case TipoGracia.ninguna:
        return 'Sin gracia';
      case TipoGracia.total:
        return 'Gracia total';
      case TipoGracia.parcial:
        return 'Gracia parcial';
    }
  }
}

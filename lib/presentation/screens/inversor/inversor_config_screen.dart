import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/session_service.dart';
import '../../../data/models/inversor_config_model.dart';
import '../../../data/datasources/inversor_config_datasource.dart';

class InversorConfigScreen extends StatefulWidget {
  final VoidCallback? onSave;

  const InversorConfigScreen({super.key, this.onSave});

  @override
  State<InversorConfigScreen> createState() => _InversorConfigScreenState();
}

class _InversorConfigScreenState extends State<InversorConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kokController = TextEditingController();

  String _tipoTasa = 'Efectiva';
  String _frecuenciaTasa = 'Anual';
  String? _capitalizacion;

  final List<String> _tiposTasa = ['Efectiva', 'Nominal', 'Descontada'];
  final List<String> _frecuencias = [
    'Mensual',
    'Bimestral',
    'Trimestral',
    'Cuatrimestral',
    'Semestral',
    'Anual',
  ];
  final List<String> _tasasDescontadas = [
    'd30',
    'd60',
    'd90',
    'd120',
    'd180',
    'd360',
  ];

  bool _isLoading = false;
  InversorConfigModel? _configActual;

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  @override
  void dispose() {
    _kokController.dispose();
    super.dispose();
  }

  Future<void> _cargarConfiguracion() async {
    setState(() => _isLoading = true);

    try {
      final userId = SessionService().currentUserId;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final datasource = InversorConfigDatasource();
      final config = await datasource.getConfig(userId);

      if (config != null) {
        setState(() {
          _configActual = config;
          _tipoTasa = config.tipoTasa;
          _frecuenciaTasa = config.frecuenciaTasa;
          _capitalizacion = config.capitalizacion;
          _kokController.text = config.valorCOK.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar configuración: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarConfiguracion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = SessionService().currentUserId;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Usuario no identificado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final kokValue = double.parse(
        _kokController.text.trim().replaceAll(',', '.'),
      );

      final config = InversorConfigModel(
        userId: userId,
        tipoTasa: _tipoTasa,
        frecuenciaTasa: _frecuenciaTasa,
        capitalizacion: _tipoTasa == 'Nominal' ? _capitalizacion : null,
        valorCOK: kokValue,
        fechaActualizacion: DateTime.now(),
      );

      final datasource = InversorConfigDatasource();
      await datasource.saveConfig(config);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuración guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        widget.onSave?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar configuración: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetearConfiguracion() {
    setState(() {
      _tipoTasa = 'Efectiva';
      _frecuenciaTasa = 'Anual';
      _capitalizacion = null;
      _kokController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Inversor'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetearConfiguracion,
            tooltip: 'Resetear configuración',
          ),
        ],
      ),
      body:
          _isLoading
              ? Container(
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
              )
              : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.indigo[50]!, Colors.white],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
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
                                colors: [
                                  Colors.indigo[600]!,
                                  Colors.indigo[700]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Configuración del COK',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Costo de Oportunidad de Capital',
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

                        const SizedBox(height: 16),

                        // Info Card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.blue[50],
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[600],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Configure su tasa de retorno requerida para evaluar inversiones en bonos. '
                                    'Para tasas descontadas, especifique la tasa anual y el período de descuento.',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Configuration Card
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [Colors.green[50]!, Colors.green[100]!],
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
                                    Icon(
                                      Icons.tune,
                                      color: Colors.green[700],
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Parámetros del COK',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Tipo de Tasa
                                _buildStyledDropdown<String>(
                                  value: _tipoTasa,
                                  label: 'Tipo de Tasa',
                                  icon: Icons.category,
                                  items:
                                      _tiposTasa.map((tipo) {
                                        return DropdownMenuItem(
                                          value: tipo,
                                          child: Text(tipo),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _tipoTasa = value!;
                                      if (_tipoTasa == 'Efectiva') {
                                        _capitalizacion = null;
                                        if (!_frecuencias.contains(
                                          _frecuenciaTasa,
                                        )) {
                                          _frecuenciaTasa = 'Anual';
                                        }
                                      } else if (_tipoTasa == 'Nominal') {
                                        if (!_frecuencias.contains(
                                          _frecuenciaTasa,
                                        )) {
                                          _frecuenciaTasa = 'Anual';
                                        }
                                      } else if (_tipoTasa == 'Descontada') {
                                        _capitalizacion = null;
                                        if (!_tasasDescontadas.contains(
                                          _frecuenciaTasa,
                                        )) {
                                          _frecuenciaTasa = 'd30';
                                        }
                                      }
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Debe seleccionar un tipo de tasa';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Frecuencia de la Tasa o Período de Descuento
                                _buildStyledDropdown<String>(
                                  value: _frecuenciaTasa,
                                  label:
                                      _tipoTasa == 'Descontada'
                                          ? 'Período de Descuento'
                                          : 'Frecuencia de la Tasa',
                                  icon:
                                      _tipoTasa == 'Descontada'
                                          ? Icons.access_time
                                          : Icons.schedule,
                                  items:
                                      (_tipoTasa == 'Descontada'
                                              ? _tasasDescontadas
                                              : _frecuencias)
                                          .map((item) {
                                            return DropdownMenuItem(
                                              value: item,
                                              child: Text(
                                                _tipoTasa == 'Descontada'
                                                    ? '$item días'
                                                    : item,
                                              ),
                                            );
                                          })
                                          .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _frecuenciaTasa = value!;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return _tipoTasa == 'Descontada'
                                          ? 'Debe seleccionar un período de descuento'
                                          : 'Debe seleccionar una frecuencia';
                                    }
                                    return null;
                                  },
                                ),

                                if (_tipoTasa == 'Nominal') ...[
                                  const SizedBox(height: 20),
                                  _buildStyledDropdown<String>(
                                    value: _capitalizacion,
                                    label: 'Capitalización',
                                    icon: Icons.repeat,
                                    items:
                                        _frecuencias.map((frecuencia) {
                                          return DropdownMenuItem(
                                            value: frecuencia,
                                            child: Text(frecuencia),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _capitalizacion = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (_tipoTasa == 'Nominal' &&
                                          (value == null || value.isEmpty)) {
                                        return 'Debe seleccionar una capitalización para tasa nominal';
                                      }
                                      return null;
                                    },
                                  ),
                                ],

                                const SizedBox(height: 20),

                                // Valor del COK
                                _buildStyledTextField(
                                  controller: _kokController,
                                  label:
                                      _tipoTasa == 'Descontada'
                                          ? 'Tasa de Descuento (%)'
                                          : 'Valor del COK (%)',
                                  icon: Icons.percent,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  hintText:
                                      _tipoTasa == 'Descontada'
                                          ? 'Ej: 5.0 (tasa anual de descuento)'
                                          : 'Ej: 10.5',
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*'),
                                    ),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Debe ingresar el valor del COK';
                                    }
                                    final doubleValue = double.tryParse(
                                      value.trim().replaceAll(',', '.'),
                                    );
                                    if (doubleValue == null) {
                                      return 'Ingrese un valor numérico válido';
                                    }
                                    if (doubleValue < 0 || doubleValue > 100) {
                                      return 'El valor debe estar entre 0 y 100';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Información actual si existe
                        if (_configActual != null) ...[
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.blue[50],
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info,
                                        color: Colors.blue[600],
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Configuración Actual',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[800],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    'Tipo',
                                    _configActual!.tipoTasa,
                                  ),
                                  _buildInfoRow(
                                    _configActual!.tipoTasa == 'Descontada'
                                        ? 'Período'
                                        : 'Frecuencia',
                                    _configActual!.tipoTasa == 'Descontada'
                                        ? '${_configActual!.frecuenciaTasa} días'
                                        : _configActual!.frecuenciaTasa,
                                  ),
                                  if (_configActual!.capitalizacion != null)
                                    _buildInfoRow(
                                      'Capitalización',
                                      _configActual!.capitalizacion!,
                                    ),
                                  _buildInfoRow(
                                    _configActual!.tipoTasa == 'Descontada'
                                        ? 'Tasa de Descuento'
                                        : 'COK',
                                    '${_configActual!.valorCOK.toStringAsFixed(2)}%',
                                  ),
                                  _buildInfoRow(
                                    'Última actualización',
                                    _configActual!.fechaActualizacion
                                        .toString()
                                        .substring(0, 19),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Botones
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green[500]!,
                                      Colors.green[600]!,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed:
                                      _isLoading ? null : _guardarConfiguracion,
                                  icon:
                                      _isLoading
                                          ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : const Icon(
                                            Icons.save,
                                            color: Colors.white,
                                          ),
                                  label: Text(
                                    _isLoading
                                        ? 'Guardando...'
                                        : 'Guardar Configuración',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton.icon(
                              onPressed: _resetearConfiguracion,
                              icon: Icon(
                                Icons.refresh,
                                color: Colors.grey[600],
                              ),
                              label: Text(
                                'Resetear',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey[400]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
        prefixIcon: Icon(icon, color: Colors.green[600]),
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
          borderSide: BorderSide(color: Colors.green[600]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
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

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.green[600]),
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
          borderSide: BorderSide(color: Colors.green[600]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.blue[900],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

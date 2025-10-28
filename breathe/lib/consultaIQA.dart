import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ConsultaIQA extends StatefulWidget {
  const ConsultaIQA({super.key});

  @override
  _ConsultaIQAState createState() => _ConsultaIQAState();
}

class _ConsultaIQAState extends State<ConsultaIQA> {
  final TextEditingController controladorLatitud = TextEditingController();
  final TextEditingController controladorLongitud = TextEditingController();
  String resultado =
      "Ingresa las coordenadas o selecciona un punto en el mapa.";
  String mensajeComparacion = "";
  LatLng ubicacionSeleccionada = LatLng(6.292509, -75.587929);
  int aqiActual = 0;
  int? ultimoAqi;
  Map<String, double>? ultimosComponentes;

  Future<void> consultarIQA() async {
    const String apiKey = '1eb7331556ee499fcf874cc3b0c1403c';
    final lat = controladorLatitud.text.trim();
    final lon = controladorLongitud.text.trim();

    if (lat.isEmpty || lon.isEmpty) {
      setState(() {
        resultado = 'Por favor ingresa ambos valores: latitud y longitud.';
      });
      return;
    }

    final double? latitud = double.tryParse(lat);
    final double? longitud = double.tryParse(lon);

    if (latitud == null || longitud == null) {
      setState(() {
        resultado = 'Latitud o longitud no son valores válidos.';
      });
      return;
    }

    final url =
        'http://api.openweathermap.org/data/2.5/air_pollution?lat=$latitud&lon=$longitud&appid=$apiKey';

    try {
      final respuesta = await http.get(Uri.parse(url));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final int aqi = datos['list'][0]['main']['aqi'];
        final componentes = datos['list'][0]['components'];

        setState(() {
          aqiActual = aqi;

          // Comparar con el último AQI medido
          if (ultimoAqi != null) {
            if (aqi > ultimoAqi!) {
              mensajeComparacion =
                  'El índice de contaminación ha AUMENTADO de $ultimoAqi a $aqi.\n';
            } else if (aqi < ultimoAqi!) {
              mensajeComparacion =
                  'El índice de contaminación ha DISMINUIDO de $ultimoAqi a $aqi.\n';
            } else {
              mensajeComparacion =
                  'El índice de contaminación se MANTIENE igual en $aqi.\n';
            }

            // Analizar cambios en los componentes
            if (ultimosComponentes != null) {
              mensajeComparacion += '\nAnálisis de cambios en componentes:\n';
              componentes.keys.forEach((key) {
                final valorActual = componentes[key].toDouble();
                final valorAnterior = ultimosComponentes![key] ?? 0.0;
                final diferencia = valorActual - valorAnterior;

                if (diferencia > 0) {
                  mensajeComparacion +=
                      '$key: aumentó en ${diferencia.toStringAsFixed(2)} μg/m³\n';
                } else if (diferencia < 0) {
                  mensajeComparacion +=
                      '$key: disminuyó en ${diferencia.abs().toStringAsFixed(2)} μg/m³\n';
                } else {
                  mensajeComparacion += '$key: sin cambios\n';
                }
              });
            }
          } else {
            mensajeComparacion =
                'Esta es tu primera medición de calidad del aire.';
          }

          // Guardar valores actuales para la próxima comparación
          ultimoAqi = aqi;
          ultimosComponentes = Map<String, double>.from(
            componentes.map((key, value) => MapEntry(key, value.toDouble())),
          );

          resultado = '''
Coordenadas consultadas: ($latitud, $longitud)

Índice de calidad del aire (AQI): $aqi

Componentes:
CO: ${componentes['co']} μg/m³ (Monóxido de Carbono)
NO: ${componentes['no']} μg/m³ (Óxido Nítrico)
NO2: ${componentes['no2']} μg/m³ (Dióxido de Nitrógeno)
O3: ${componentes['o3']} μg/m³ (Ozono)
SO2: ${componentes['so2']} μg/m³ (Dióxido de Azufre)
PM2.5: ${componentes['pm2_5']} μg/m³ (Partículas finas)
PM10: ${componentes['pm10']} μg/m³ (Partículas gruesas)
NH3: ${componentes['nh3']} μg/m³ (Amoniaco)
          ''';
        });
      } else {
        setState(() {
          resultado = 'Error: Código ${respuesta.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        resultado = 'Error de conexión: $e';
      });
    }
  }

  void actualizarUbicacion(LatLng nuevaUbicacion) {
    setState(() {
      ubicacionSeleccionada = nuevaUbicacion;
      controladorLatitud.text = nuevaUbicacion.latitude.toStringAsFixed(6);
      controladorLongitud.text = nuevaUbicacion.longitude.toStringAsFixed(6);
    });
  }

  Color colorAQI(int aqi) {
    switch (aqi) {
      case 1:
        return Colors.green.withOpacity(0.4);
      case 2:
        return Colors.yellow.withOpacity(0.4);
      case 3:
        return Colors.orange.withOpacity(0.4);
      case 4:
        return Colors.red.withOpacity(0.4);
      case 5:
        return Colors.purple.withOpacity(0.4);
      default:
        return Colors.grey.withOpacity(0.4);
    }
  }

  void mostrarRecomendaciones(BuildContext context) {
    String recomendacion = "";
    String titulo = "";

    switch (aqiActual) {
      case 1:
        titulo = "Calidad del aire: BUENA";
        recomendacion =
            "Es seguro salir. Puedes realizar actividades al aire libre sin restricciones. ¡Disfruta del buen aire!";
        break;
      case 2:
        titulo = "Calidad del aire: MODERADA";
        recomendacion =
            "La calidad del aire es aceptable. Las personas sensibles deben considerar limitar el tiempo prolongado al aire libre.";
        break;
      case 3:
        titulo = "Calidad del aire: INSALUBRE PARA GRUPOS SENSIBLES";
        recomendacion =
            "Los grupos sensibles (niños, ancianos, personas con problemas respiratorios) deben reducir el esfuerzo al aire libre. El público en general puede continuar con sus actividades normales.";
        break;
      case 4:
        titulo = "Calidad del aire: INSALUBRE";
        recomendacion =
            "Toda la población debe reducir el esfuerzo al aire libre, especialmente los grupos sensibles. Considere permanecer en interiores.";
        break;
      case 5:
        titulo = "Calidad del aire: MUY INSALUBRE";
        recomendacion =
            "Evite toda actividad al aire libre. Permanezca en interiores con ventanas cerradas. Use mascarilla si debe salir.";
        break;
      default:
        titulo = "Calidad del aire: DESCONOCIDA";
        recomendacion =
            "No hay suficiente información para dar recomendaciones. Verifique más tarde.";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 2, 76, 52),
          title: Text(titulo, style: const TextStyle(color: Colors.white)),
          content: Text(
            recomendacion,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 2, 76, 52),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Consultar IQA',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 13, 91, 77),
              Color.fromARGB(255, 14, 158, 139),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Selecciona una ubicación tocando el mapa o ingresa las coordenadas:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: FlutterMap(
                  options: MapOptions(
                    center: ubicacionSeleccionada,
                    zoom: 5,
                    onTap: (_, point) => actualizarUbicacion(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.breathe_more',
                    ),
                    if (aqiActual > 0)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: ubicacionSeleccionada,
                            radius: 60,
                            color: colorAQI(aqiActual),
                            useRadiusInMeter: false,
                            borderColor: Colors.transparent,
                            borderStrokeWidth: 0,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: ubicacionSeleccionada,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controladorLatitud,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputDecor('Latitud'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controladorLongitud,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputDecor('Longitud'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: consultarIQA,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 76, 52),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 40,
                  ),
                ),
                child: const Text(
                  'Consultar Calidad del Aire',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              if (aqiActual > 0)
                ElevatedButton(
                  onPressed: () => mostrarRecomendaciones(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 76, 52),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 40,
                    ),
                  ),
                  child: const Text(
                    'Recomendaciones',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                mensajeComparacion,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  resultado,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _mostrarReferencia(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 76, 52),
                ),
                child: const Text(
                  'Niveles de referencia',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  void _mostrarReferencia(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color.fromARGB(255, 2, 76, 52),
            title: const Text(
              'Niveles de calidad del aire',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _nivelColor('1. Bueno', Colors.green),
                _nivelColor('2. Moderado', Colors.yellow),
                _nivelColor(
                  '3. No saludable para grupos sensibles',
                  Colors.orange,
                ),
                _nivelColor('4. No saludable', Colors.red),
                _nivelColor('5. Muy perjudicial', Colors.purple),
              ],
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  Widget _nivelColor(String texto, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 20, height: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texto, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

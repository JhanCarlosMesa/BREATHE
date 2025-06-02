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
  String resultado = "Ingresa las coordenadas o selecciona un punto en el mapa.";
  LatLng ubicacionSeleccionada = LatLng(6.292509, -75.587929);
  int aqiActual = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 2, 76, 52),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Consultar IQA', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 13, 91, 77), Color.fromARGB(255, 14, 158, 139)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Selecciona una ubicación tocando el mapa o ingresa las coordenadas:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 350,
              child: FlutterMap(
                options: MapOptions(
                  center: ubicacionSeleccionada,
                  zoom: 5,
                  onTap: (_, point) => actualizarUbicacion(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecor('Latitud'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controladorLongitud,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
              ),
              child: const Text('Consultar Calidad del Aire', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(resultado, style: const TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _mostrarReferencia(context),
              child: const Text('Niveles de referencia'),
            ),
          ],
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
      builder: (_) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 2, 76, 52),
        title: const Text('Niveles de calidad del aire', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _nivelColor('1. Bueno', Colors.green),
            _nivelColor('2. Moderado', Colors.yellow),
            _nivelColor('3. No saludable para grupos sensibles', Colors.orange),
            _nivelColor('4. No saludable', Colors.red),
            _nivelColor('5. Muy perjudicial', Colors.purple),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(),
          )
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
          Expanded(child: Text(texto, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

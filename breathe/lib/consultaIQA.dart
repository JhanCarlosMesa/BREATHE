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

  Future<void> consultarIQA() async {
    const String apiKey = '1eb7331556ee499fcf874cc3b0c1403c';

    final String latitudTexto = controladorLatitud.text.trim();
    final String longitudTexto = controladorLongitud.text.trim();

    if (latitudTexto.isEmpty || longitudTexto.isEmpty) {
      setState(() {
        resultado = 'Por favor ingresa ambos valores: latitud y longitud.';
      });
      return;
    }

    final double? latitud = double.tryParse(latitudTexto);
    final double? longitud = double.tryParse(longitudTexto);

    if (latitud == null || longitud == null) {
      setState(() {
        resultado = 'Latitud o longitud no son valores válidos. Ingresa números.';
      });
      return;
    }

    final String url =
        'http://api.openweathermap.org/data/2.5/air_pollution?lat=$latitud&lon=$longitud&appid=$apiKey';

    try {
      final respuesta = await http.get(Uri.parse(url));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);

        final int aqi = datos['list'][0]['main']['aqi'];
        final Map<String, dynamic> componentes = datos['list'][0]['components'];

        setState(() {
          resultado = '''
Coordenadas consultadas: ($latitud, $longitud)

Índice de calidad del aire (AQI): $aqi

Componentes:
CO: ${componentes['co']} μg/m³ (Monóxido de Carbono)
NO: ${componentes['no']} μg/m³ (Óxido Nítronico)
NO2: ${componentes['no2']} μg/m³ (Dióxido de Nitrógeno)
O3: ${componentes['o3']} μg/m³ (Ozono (a nivel del suelo))
SO2: ${componentes['so2']} μg/m³ (Dióxido de Azufre)
PM2.5: ${componentes['pm2_5']} μg/m³ (Partículas finas (menores a 2.5 micras))
PM10: ${componentes['pm10']} μg/m³ (Partículas gruesas (menores a 10 micras))
NH3: ${componentes['nh3']} μg/m³ (Amoniaco)
          ''';
        });
      } else {
        setState(() {
          resultado = 'Error al obtener los datos: Código ${respuesta.statusCode}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta IQA', style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center
              ),
        backgroundColor: const Color.fromARGB(255, 13, 91, 77),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 13, 91, 77), Color.fromARGB(255, 14, 158, 139)],
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
              height: 400,
              child: FlutterMap(
                options: MapOptions(
                  center: ubicacionSeleccionada,
                  zoom: 5,
                  onTap: (tapPosition, point) {
                    actualizarUbicacion(point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.breathe_more',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80,
                        height: 80,
                        point: ubicacionSeleccionada,
                        child: const Icon(Icons.location_on, size: 40, color: Colors.red),
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
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Latitud',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controladorLongitud,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Longitud',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
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
                child: Text(
                  resultado,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


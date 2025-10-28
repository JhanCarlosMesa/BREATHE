import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ConsultaTemperatura extends StatefulWidget {
  const ConsultaTemperatura({super.key});

  @override
  _ConsultaTemperaturaState createState() => _ConsultaTemperaturaState();
}

class _ConsultaTemperaturaState extends State<ConsultaTemperatura> {
  final TextEditingController _controladorLatitud = TextEditingController();
  final TextEditingController _controladorLongitud = TextEditingController();
  String _temperatura = '';
  String _mensajeComparacion = '';
  double? _ultimaTemperatura;
  LatLng ubicacionSeleccionada = LatLng(6.292509, -75.587929);

  Future<void> obtenerTemperatura(double latitud, double longitud) async {
    try {
      final respuesta = await http.get(
        Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$latitud&longitude=$longitud&current=temperature',
        ),
      );

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final temperaturaActual = datos['current']['temperature'];

        setState(() {
          _temperatura = '$temperaturaActual °C';

          // Comparar con la última temperatura medida
          if (_ultimaTemperatura != null) {
            final diferencia = (temperaturaActual - _ultimaTemperatura!).abs();
            _mensajeComparacion =
                'La temperatura actual es de $temperaturaActual°C y la medida anterior fue de ${_ultimaTemperatura!.toStringAsFixed(1)}°C, '
                'hay una diferencia de ${diferencia.toStringAsFixed(1)}°C entre estos 2 resultados.';
          } else {
            _mensajeComparacion = 'Esta es tu primera medición.';
          }

          // Guardar la temperatura actual como la última
          _ultimaTemperatura = temperaturaActual;
        });
      } else {
        setState(() {
          _temperatura = 'Error al buscar temperatura';
        });
      }
    } catch (e) {
      setState(() {
        _temperatura = '17 °C (Esta es una temperatura predeterminada)';
      });
    }
  }

  void actualizarUbicacion(LatLng nuevaUbicacion) {
    setState(() {
      ubicacionSeleccionada = nuevaUbicacion;
      _controladorLatitud.text = nuevaUbicacion.latitude.toStringAsFixed(6);
      _controladorLongitud.text = nuevaUbicacion.longitude.toStringAsFixed(6);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 2, 76, 52),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Esto regresa a la pantalla anterior
          },
        ),
        title: const Text(
          'Consultar Temperatura',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 13, 91, 77),
              Color.fromARGB(255, 14, 158, 139),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
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
                      userAgentPackageName: 'com.example.breathe',
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
              _buildTextField(_controladorLatitud, 'Latitud'),
              const SizedBox(height: 10),
              _buildTextField(_controladorLongitud, 'Longitud'),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 76, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                onPressed: () {
                  final latitud = double.tryParse(_controladorLatitud.text);
                  final longitud = double.tryParse(_controladorLongitud.text);

                  if (latitud != null && longitud != null) {
                    obtenerTemperatura(latitud, longitud);
                  } else {
                    setState(() {
                      _temperatura = 'Coordenadas inválidas';
                    });
                  }
                },
                child: const Text(
                  'Consultar Temperatura',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _temperatura.isEmpty
                    ? 'Ingresa las coordenadas para ver la temperatura actual'
                    : 'Temperatura: $_temperatura',
                style: const TextStyle(fontSize: 20, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _mensajeComparacion,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
      ),
    );
  }
}

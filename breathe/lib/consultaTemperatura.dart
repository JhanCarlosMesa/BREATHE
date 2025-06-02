import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConsultaTemperatura extends StatefulWidget {
  const ConsultaTemperatura({super.key});

  @override
  _ConsultaTemperaturaState createState() => _ConsultaTemperaturaState();
}

class _ConsultaTemperaturaState extends State<ConsultaTemperatura> {
  final TextEditingController _controladorLatitud = TextEditingController();
  final TextEditingController _controladorLongitud = TextEditingController();
  String _temperatura = '';

  Future<void> obtenerTemperatura(double latitud, double longitud) async {
    try {
      final respuesta = await http.get(
        Uri.parse(
            'https://api.open-meteo.com/v1/forecast?latitude=$latitud&longitude=$longitud&current=temperature'),
      );

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final temperaturaActual = datos['current']['temperature'];
        setState(() {
          _temperatura = '$temperaturaActual °C';
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
            colors: [Color.fromARGB(255, 13, 91, 77), Color.fromARGB(255, 14, 158, 139)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const SizedBox(height: 30),
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
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: true),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}


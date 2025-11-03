import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Coordenada {
  final double latitud;
  final double longitud;
  final String nombre;

  Coordenada({
    required this.latitud,
    required this.longitud,
    required this.nombre,
  });

  Map<String, dynamic> toJson() {
    return {'latitud': latitud, 'longitud': longitud, 'nombre': nombre};
  }

  factory Coordenada.fromJson(Map<String, dynamic> json) {
    return Coordenada(
      latitud: json['latitud'],
      longitud: json['longitud'],
      nombre: json['nombre'],
    );
  }

  @override
  String toString() {
    return '($latitud, $longitud)';
  }
}

class CoordenadasGuardadas {
  static const String _keyIQA = 'coordenadas_iqa';
  static const String _keyTemperatura = 'coordenadas_temperatura';

  // Métodos para coordenadas de IQA
  static Future<List<Coordenada>> obtenerCoordenadasIQA() async {
    final prefs = await SharedPreferences.getInstance();
    final coordenadasString = prefs.getString(_keyIQA) ?? '[]';
    final List<dynamic> coordenadasJson = json.decode(coordenadasString);
    return coordenadasJson
        .map((json) => Coordenada.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<void> guardarCoordenadaIQA(Coordenada coordenada) async {
    final coordenadas = await obtenerCoordenadasIQA();
    coordenadas.add(coordenada);
    await _guardarCoordenadasIQA(coordenadas);
  }

  static Future<void> _guardarCoordenadasIQA(
    List<Coordenada> coordenadas,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final coordenadasJson = coordenadas.map((c) => c.toJson()).toList();
    final coordenadasString = json.encode(coordenadasJson);
    await prefs.setString(_keyIQA, coordenadasString);
  }

  static Future<void> eliminarCoordenadaIQA(int index) async {
    final coordenadas = await obtenerCoordenadasIQA();
    if (index >= 0 && index < coordenadas.length) {
      coordenadas.removeAt(index);
      await _guardarCoordenadasIQA(coordenadas);
    }
  }

  // Métodos para coordenadas de Temperatura
  static Future<List<Coordenada>> obtenerCoordenadasTemperatura() async {
    final prefs = await SharedPreferences.getInstance();
    final coordenadasString = prefs.getString(_keyTemperatura) ?? '[]';
    final List<dynamic> coordenadasJson = json.decode(coordenadasString);
    return coordenadasJson
        .map((json) => Coordenada.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<void> guardarCoordenadaTemperatura(
    Coordenada coordenada,
  ) async {
    final coordenadas = await obtenerCoordenadasTemperatura();
    coordenadas.add(coordenada);
    await _guardarCoordenadasTemperatura(coordenadas);
  }

  static Future<void> _guardarCoordenadasTemperatura(
    List<Coordenada> coordenadas,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final coordenadasJson = coordenadas.map((c) => c.toJson()).toList();
    final coordenadasString = json.encode(coordenadasJson);
    await prefs.setString(_keyTemperatura, coordenadasString);
  }

  static Future<void> eliminarCoordenadaTemperatura(int index) async {
    final coordenadas = await obtenerCoordenadasTemperatura();
    if (index >= 0 && index < coordenadas.length) {
      coordenadas.removeAt(index);
      await _guardarCoordenadasTemperatura(coordenadas);
    }
  }
}

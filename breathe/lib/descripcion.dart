import 'package:flutter/material.dart';
import 'consultaPrincipal.dart';

class Descripcion extends StatelessWidget {
  const Descripcion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 180),
              const Text(
                'BIENVENIDO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Image.asset('assets/tierra.png', width: 250),
              const SizedBox(height: 30),
              const Text(
                'BREATHE+',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Desde ahora recibirás alertas de calidad del aire, tips ecológicos y retos semanales para hacer la diferencia.',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConsultaPrincipal(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

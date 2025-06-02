import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InformacionPage extends StatelessWidget {
  const InformacionPage({super.key});

  Future<void> _abrirEnlace() async {
    final url = Uri.parse('https://www.kaggle.com/datasets/hasibalmuzdadid/global-air-pollution-dataset/data');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir el enlace';
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
          Navigator.pop(context);
        },
      ),
      title: const Text(
        'Información sobre IQA',
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      elevation: 0,
    ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 13, 91, 77), Color.fromARGB(255, 14, 158, 139)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Descripción',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'La contaminación del aire es la alteración del ambiente interior o exterior por cualquier agente químico, físico o biológico que modifica las características naturales de la atmósfera. '
                'Los dispositivos de combustión domésticos, vehículos motorizados, instalaciones industriales e incendios forestales son fuentes comunes. '
                'Los contaminantes de mayor preocupación para la salud pública incluyen el material particulado, monóxido de carbono, ozono, dióxido de nitrógeno y dióxido de azufre. '
                'La contaminación del aire causa enfermedades respiratorias y otras, siendo una fuente importante de morbilidad y mortalidad.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'Contaminantes incluidos:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '- Dióxido de Nitrógeno [NO2]: Proviene de fuentes naturales como tormentas o emisiones desde la estratósfera, pero a nivel superficial se origina por vehículos y plantas eléctricas. '
                'La exposición a corto plazo puede agravar enfermedades respiratorias como el asma; la exposición prolongada puede causar infecciones respiratorias y contribuir al desarrollo del asma.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '- Ozono [O3]: A nivel del suelo, se forma por reacciones químicas entre óxidos de nitrógeno y compuestos orgánicos volátiles. '
                'Puede causar dolor en el pecho, tos, irritación en la garganta e inflamación de las vías respiratorias. También afecta la vegetación y los ecosistemas.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '- Monóxido de Carbono [CO]: Gas incoloro e inodoro, principalmente emitido por vehículos y maquinaria que queman combustibles fósiles. '
                'Reduce el transporte de oxígeno en la sangre y, en niveles muy altos, puede causar mareos, confusión, pérdida de conciencia e incluso la muerte.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '- Material Particulado [PM2.5]: Son partículas sólidas y líquidas muy pequeñas suspendidas en el aire. '
                'Pueden causar enfermedades cardíacas y pulmonares graves. Están clasificadas como carcinógenos del Grupo 1 por la IARC.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'Contenido del dataset',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '- País: Nombre del país\n'
                '- Ciudad: Nombre de la ciudad\n'
                '- Valor IQA: Valor general del índice de calidad del aire de la ciudad\n'
                '- Categoría IQA: Categoría del valor general de la ciudad\n'
                '- Valor CO: Valor del índice de calidad del Monóxido de Carbono\n'
                '- Categoría CO: Categoría del CO\n'
                '- Valor Ozono: Valor del índice del Ozono\n'
                '- Categoría Ozono: Categoría del Ozono\n'
                '- Valor NO2: Valor del índice de Dióxido de Nitrógeno\n'
                '- Categoría NO2: Categoría del NO2\n'
                '- Valor PM2.5: Valor del índice de partículas finas\n'
                '- Categoría PM2.5: Categoría del PM2.5',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 30),
              Center(
                child: TextButton(
                  onPressed: _abrirEnlace,
                  child: Text(
                    'Ver dataset en Kaggle',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

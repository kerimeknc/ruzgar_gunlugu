import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkında'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // 🌬️ Uygulama Logosu/İkonu
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.air, // Rüzgar teması için
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Rüzgar Günlüğü',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Text('v1.0.0', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),

              // 📜 Hikaye Kartı
              Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.auto_stories_outlined,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Uygulama, fotoğraflı anılarınızı kaydedebileceğiniz bir dijital günlük olarak, paylaşılan değerli anıları ölümsüzleştirmek ve her zaman hatırlamak için tasarlandı.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const Divider(height: 32),
                      Text(
                        'Motorla yapılan yolculuklar ve biriktirdiğimiz anılar, bu uygulamanın fikir aşamasında ilham kaynağı oldu. Destekleri ve verdiği ilham için M.Y.\'ye teşekkür ederim.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 💻 Teknik Bilgi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FlutterLogo(size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Flutter ile sevgiyle geliştirilmiştir.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

// Uygulama listesi boş olduğunda (henüz anı eklenmediğinde) gösterilen görsel bileşen
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        // İçeriğin ekran kenarlarından uygun mesafede durmasını sağlar
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          // Tüm öğeleri dikeyde ekranın ortasına hizalar
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🌬️ Katmanlı yapı: Arka plan dairesi ve ikonları üst üste bindirir
            Stack(
              alignment: Alignment.center,
              children: [
                // En alttaki hafif renkli yuvarlak dekorasyon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                // Merkeze yerleştirilmiş parıltı (anı) ikonu
                Icon(
                  Icons.auto_awesome,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                // Sağ üst köşeye yerleştirilmiş rüzgar efekti veren ikincil ikon
                Positioned(
                  right: 10,
                  top: 10,
                  child: Icon(
                    Icons.air,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32), // İkon seti ile metin arasındaki boşluk
            // Ana başlık: Kullanıcıya soru sorarak etkileşime davet eder
            Text(
              'Yolculuk Başlamadı mı?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            // Açıklama metni: Uygulamanın amacını ve ne yapılması gerektiğini anlatır
            Text(
              'Henüz kaydedilmiş bir anın yok. Rüzgarı hissettiğin o anları ölümsüzleştirmek için hemen bir tane ekle!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
                height:
                    1.4, // Satır arası boşluğu artırarak okunabilirliği iyileştirir
              ),
            ),
            const SizedBox(height: 32),
            // ➕ Görsel ipucu: Genellikle altta bulunan "+" (ekle) butonuna işaret eder
            Icon(
              Icons.arrow_downward_rounded,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}

# ruzgar_gunlugu

youtube video linki: https://youtu.be/jBk9Np_iqwk

##  Projenin Amacı

Rüzgar Günlüğü, kullanıcıların günlük yaşantılarındaki anılarını dijital ortamda güvenli ve düzenli bir şekilde saklayabilmelerini amaçlayan bir mobil uygulamadır.  
Uygulama, Flutter/Dart kullanılarak geliştirilmiş olup veriler SQLite veritabanında saklanmaktadır.

Bu proje, Mobil Programlama dersi kapsamında; Flutter widget kullanımı, çoklu ekran yapısı, veritabanı işlemleri, asenkron çalışma ve kullanıcı arayüzü tasarımı becerilerini göstermek amacıyla hazırlanmıştır.

---

##  Bu Uygulama Kimin İşine Yarar?

- Günlük tutmayı seven kullanıcılar  
- Anılarını tarih, fotoğraf ve konum bilgisiyle saklamak isteyenler  
- Kişisel arşiv oluşturmak isteyen mobil kullanıcılar  

---

##  Hangi Problemi Çözer?

- Anıların kağıt ortamında kaybolması problemini ortadan kaldırır  
- Günlüklerin düzensiz şekilde tutulmasını önler  
- Fotoğraf ve konum destekli kayıtlarla anıları daha anlamlı hale getirir  

---

##  Nerede ve Nasıl Kullanılır?

- Android cihazlarda çalışır  
- Kullanıcı uygulamayı açarak yeni bir günlük ekleyebilir  
- Eklenen günlükler liste halinde görüntülenir  
- Günlükler başlığa ve tarihe göre filtrelenebilir  
- Günlük detayları ayrı bir ekranda incelenebilir  

---

##  Kullanılan Teknolojiler

- **Flutter**
- **Dart**
- **SQLite (sqflite)**
- **Material Design**

---

##  Kullanılan Flutter Yapıları

- Scaffold  
- Container  
- Column & Row  
- ListView & ListTile  
- Button Widget (ElevatedButton, FloatingActionButton)  
- Stateful Widget  
- Çoklu ekran yapısı (Navigator)  
- Asenkron işlemler (Future, async/await)  

---

##  Uygulama Ekranları

Uygulama aşağıdaki ekranlardan oluşmaktadır:

- **Ana Ekran:** Günlüklerin listelendiği ekran  
- **Yeni Günlük Ekleme Ekranı:** Kullanıcının yeni anı eklediği ekran  
- **Detay Ekranı:** Seçilen günlüğün detaylarının görüntülendiği ekran  

---

##  Veritabanı Kullanımı

Uygulamada **SQLite** veritabanı kullanılmıştır.

Veritabanı üzerinde yapılan işlemler:
- Günlük ekleme  
- Günlük listeleme  
- Günlük güncelleme  
- Günlük silme  

Tüm veritabanı işlemleri **asenkron** olarak gerçekleştirilmiştir.

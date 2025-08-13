# 💳 Bank App (Flutter)

Bu proje, sanal bir banka uygulamasının Flutter ile yazılmış mobil uygulamasıdır. Kullanıcılar hesap oluşturabilir, bakiye görüntüleyebilir, para yatırabilir, çekebilir veya başka hesaplara transfer yapabilir. Uygulama, Node.js + Express.js ile yazılmış bir backend'e bağlıdır.

## 🚀 Özellikler

- Kullanıcı kayıt ve giriş
- JWT ile yetkilendirme
- Ana sayfada kullanıcı karşılama
- Banka hesabı oluşturma ve listeleme
- Para yatırma / çekme işlemleri
- Hesaplar arası para transferi
- İşlem geçmişi
- State management: Bloc (Cubit)
- Dio ile API iletişimi
- SharedPreferences ile token yönetimi

## 🔧 Kullanılan Paketler

- `flutter_bloc`
- `dio`
- `shared_preferences`
- `go_router`
- `flutter_screenutil`
- ### Test için:
  - `flutter_test`
  - `integration_test`
  - `mockito`
  - `build_runner`
  - `golden_toolkit`
  - `bloc_test`

## 🔑 Backend Bağlantısı

Uygulama, [bank_app_backend](https://github.com/tolgadirek/bank_app_backend) projesiyle çalışmaktadır. Arka uç sunucusunun çalışıyor olması gerekir.

`.env` dosyası kullanılmadığı için `DioService` içinde API adresi sabit tanımlanır:

```dart
baseUrl = "http://10.0.2.2:5000/api";
```

> Android emulator için `localhost` yerine `10.0.2.2` kullanılır. Gerçek cihazda test etmek için kendi IP adresinle değiştir.

## 📱 Uygulamayı Çalıştırma

1. Bu repoyu klonla:

   ```
   git clone https://github.com/tolgadirek/bank_app.git
   cd bank_app
   ```

2. Gerekli paketleri yükle:

   ```
   flutter pub get
   ```

3. Emulator başlat veya fiziksel cihazı bağla:

   ```
   flutter run
   ```

## 🧪 Testler

Bu projede tam test kapsamı uygulanmıştır:

### ✅ 1. Unit Test
- Cubit'lerin state yönetimi
- Repository metotları
- Test klasörü: `test/unit/`

### ✅ 2. Widget Test
- Sayfa yapılarının, form alanlarının testleri
- Test klasörü: `test/widget/`

### ✅ 3. Golden Test
- Sayfaların ekran görüntüsü karşılaştırmaları
- Bozulmaları önlemek için `golden_toolkit` kullanıldı
- Test klasörü: `test/golden/`
- Golden güncellemek için:
  ```
  flutter test --update-goldens
  ```

### ✅ 4. Integration Test
- Uygulamanın tam akış senaryoları test edildi (giriş, hesap açma, transfer vb.)
- Gerçek cihaz/emulator gerektirir
- Test klasörü: `integration_test/`
- Çalıştırmak için:
  ```
  flutter test integration_test/
  ```

## 💡 Geliştirme Notları

- Giriş yapıldığında token `SharedPreferences` içine kaydedilir.
- Cubit'ler sayfaları ayrı ayrı yönetir (LoginCubit, RegisterCubit, BankAccountsCubit, TransactionsCubit...)
- Tüm işlemler sonrası ilgili Cubit yeniden state emit eder.
- Yönlendirme sistemi `GoRouter` ile sağlanır.
- Responsive yapı için `flutter_screenutil` kullanılır.

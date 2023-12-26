# Linux Sistem İzleme ve Raporlama Scriptleri

Bu repo, Linux sistemlerinizin durumunu izlemek ve raporlamak için iki bash tabanlı script içerir: `monitoring.sh` ve `System_Report.sh`. Bu scriptler, sistem kaynaklarınızı izler, performansı değerlendirir ve potansiyel sorunları saptar.

## Özellikler
- **İnternet Bağlantısı Kontrolü:** İnternet erişiminizi sürekli kontrol eder.
- **Docker Servis Durumu İzleme:** Docker servislerinin çalışır durumda olup olmadığını izler.
- **Sistem Kaynaklarının İzlenmesi:** CPU, disk ve RAM kullanımını izler ve belirli eşik değerler aşıldığında bildirim gönderir.
- **Detaylı Sistem Raporları:** Sistem hakkında detaylı bilgiler toplar ve düzenli raporlar oluşturur.

## Yapılandırma

Bu bölümde, `monitoring.sh` ve `System_Report.sh` scriptlerini kendi sistemlerinize nasıl uyarlayacağınız açıklanmaktadır. Her iki script de, verimli çalışabilmeleri için bazı ön yapılandırmalara ihtiyaç duymaktadır.

### monitoring.sh Yapılandırması

`monitoring.sh` scripti, sistem kaynaklarını izler ve belirli koşullar altında e-posta bildirimleri gönderir. Bu scriptin doğru çalışması için aşağıdaki adımları izleyin:

1. **E-posta Alıcısını Ayarlama:**
   Script içindeki `recipient` değişkenini, bildirim almak istediğiniz e-posta adresiyle güncelleyin

```
local recipient="your-email@example.com"
```

msmtp Konfigürasyonu: msmtp aracı, e-posta bildirimleri için kullanılır. Kendi .msmtprc dosyanızı oluşturun ve script içindeki msmtp_config değişkenini bu dosyanın yoluna işaret edecek şekilde güncelleyin:

```
local msmtp_config="/home/your-username/.msmtprc"
```

- .msmtprc dosyasında, kendi SMTP sunucu detaylarınızı belirtin.

## System_Report.sh Yapılandırması
System_Report.sh scripti, sistem hakkında detaylı bilgiler toplar ve bir rapor oluşturur. Bu raporun saklanacağı yeri yapılandırmak için:

Rapor Dosyasının Konumu: Rapor dosyasının yolunu ve adını istediğiniz şekilde ayarlayın:

```
monitoring_report="/path/to/your/report.txt"
```

Önerilen yol, kullanıcıların kişisel dizinleri olabilir, örneğin /home/your-username/report.txt.

Genel Yapılandırma Notları
- Scriptler, Bash yorumlayıcısı gerektiren Linux tabanlı sistemler için tasarlanmıştır.
- Docker servis durumunu kontrol etmek için Docker'ın yüklü ve çalışır durumda olması gerekir.
- E-posta bildirimleri için msmtp'nin doğru yapılandırıldığından emin olun. Yapılandırma tamamlandıktan sonra, scriptleri çalıştırmadan önce bir test yaparak her şeyin doğru çalıştığından emin olun.

    

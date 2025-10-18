# SubKit

**SubKit** — легковесный Swift-фреймворк для iOS-разработчиков, создающих **VPN- и прокси-приложения**.  
Позволяет легко парсить **подписки** (Clash, Sing-Box, Quantumult X и др.) из HTTP-заголовков.

> 📡 Парсинг подписок · Base64-декодирование · Человекочитаемые единицы · Чистый Swift
## 📦 Установка

### Swift Package Manager

В Xcode:
1. **File → Add Package Dependency...**
2. Вставь: https://github.com/kaska0093/SubKit.git
3. Выбери версию (например, `1.0.0`)

Или в `Package.swift`:

```swift
dependencies: [
 .package(url: "https://github.com/kaska0093/SubKit.git", from: "1.0.0")
]
🧪 Пример
import SubKit

let response: HTTPURLResponse = // ... ответ от сервера подписки

let subscription = parseHeaders(from: response)

print("Профиль: \(subscription.profileTitle)")
print("Трафик: \(subscription.downloadGB) GB / \(Double(subscription.totalBytes) / 1e9) GB")
if let expire = subscription.expireTimestamp {
    print("Истекает: \(Date(timeIntervalSince1970: expire))")
}
📦 Что входит
parseHeaders(from:) — основная функция парсинга
SubscriptionInfo — структура с данными подписки
Автоматическая обработка Base64 (profile-title, announce)
Поддержка всех стандартных заголовков:
- subscription-userinfo
- profile-title
- profile-web-page-url
- support-url
- profile-update-interval
- providerid
- ping-type
- announce

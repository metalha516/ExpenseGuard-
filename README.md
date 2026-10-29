# 🛡️ ExpenseGuard

<p align="center">
  <img src="https://raw.githubusercontent.com/metalha516/ExpenseGuard-/master/web/icons/Icon-192.png" alt="ExpenseGuard Logo" width="120" height="120" />
</p>

<p align="center">
  <b>Smart Corporate Spending & Real-Time Policy Guardrails</b><br>
  <i>A production-grade enterprise expense management application built with Flutter 3.29, Dart 3, Riverpod 2.x, and the signature "Pastel Flat" Neo-brutalist design language.</i>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.29-02569B?logo=flutter" alt="Flutter 3.29"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.7-0175C2?logo=dart" alt="Dart 3"></a>
  <a href="https://riverpod.dev"><img src="https://img.shields.io/badge/State-Riverpod%202.x-black?logo=riverpod" alt="Riverpod"></a>
  <a href="https://pub.dev/packages/go_router"><img src="https://img.shields.io/badge/Router-GoRouter%2018-blue" alt="GoRouter"></a>
  <a href="https://github.com/metalha516/ExpenseGuard-/actions"><img src="https://img.shields.io/badge/Tests-142%20Passed-brightgreen?logo=github-actions" alt="142 Tests Passing"></a>
  <a href="https://github.com/metalha516/ExpenseGuard-/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
</p>

---

## 🌟 Overview

**ExpenseGuard** is an AI-augmented corporate spending and policy compliance mobile/web application designed for modern high-growth teams. By marrying high-contrast **"Pastel Flat" Neo-brutalism** with intelligent real-time policy evaluation, ExpenseGuard transforms mundane receipt scanning, corporate card provisioning, and manager approvals into an effortless, transparent workflow.

---

## ✨ Key Features

### 📸 1. Receipt Capture & OCR Flow
- **Hardware-Accelerated Camera**: Custom viewfinder overlay with framing guides, flash mode controls, and responsive camera resolution selector.
- **Automated OCR Parsing**: Instant simulation/extraction of vendor names, transaction dates, totals, itemized items, and sales tax.
- **Review & Validation Modal**: Interactive form with editable currency fields, category pickers, and live policy previews.

### ⚖️ 2. Real-Time Policy Engine
- **Pre-Submission Compliance Audits**: Evaluates corporate limits (e.g., meals under \$75, software pre-approvals, weekend travel rules) before submission.
- **AI Anomaly & Risk Scoring**: Flags duplicate claims, abnormal tip ratios, off-hours charges, and missing tax invoices.
- **Clear Explanation Callouts**: Highlights plain-language policy explanations and provides one-tap dispute/justification resolution workflows.

### ⚡ 3. Approvals Queue (Manager Suite)
- **Dismissible Swipe Gestures**: Swipe right to approve, swipe left to flag/reject with instant undo SnackBar triggers.
- **Multi-Filter & Real-Time Search**: Filter pending requests by Risk Level (All, High Risk, Standard, Cleared) or employee name.
- **Audit Trail & Timestamps**: Complete step-by-step approval history from submission through supervisor sign-off and ERP sync.

### 💳 4. Corporate Cards & Limits
- **Dual Physical & Virtual Card Carousel**: Smooth horizontal card swiper rendering Visa business card geometry with masked PAN details.
- **Instant Freeze / Lock Controls**: Interactive toggle to freeze lost physical cards or pause automated SaaS subscriptions.
- **Spend Limit Adjuster**: Bottom sheet slider for authorized card limit recalibration and spending alerts.

### 📊 5. Spend Insights & Analytics
- **Interactive Data Visualizations**: Seamless chart switching between interactive Donut breakdown and 6-month historical Bar trends using `fl_chart`.
- **Category Proportions**: Dynamic breakdown across Travel, Meals, SaaS Subscriptions, and Office Supplies.
- **Budget Pacing Indicators**: Real-time monthly spend meters and budget headroom calculations.

### 🔔 6. Notifications Center
- **Smart Grouping**: Grouped chronology (Today, Yesterday, Earlier) with read/unread visual indicators.
- **Category Filters**: Filter between Approvals, Card Limit Warnings, and System Notices.
- **Direct Deep-Link Navigation**: Tap notification items to navigate directly into associated transaction detail routes.

---

## 🎨 The "Pastel Flat" Neo-Brutalist Design System

ExpenseGuard adheres to a distinct **Pastel Flat** aesthetic—combining clean brutalist borders with soft pastel containers:

| Design Token | Hex Code | Purpose |
| :--- | :--- | :--- |
| **Mint** | `#B5EAD7` | Primary container, approved badges, submit actions |
| **Lavender** | `#E2CCF0` | Category tags, secondary actions, virtual cards |
| **Peach** | `#FFDAC1` | Pending status, warning highlights, warm accents |
| **Sky Blue** | `#C7CEEA` | Informational chips, location cards, receipt indicators |
| **Dark Stroke** | `#1A1C1E` | Signature 1.5px high-contrast structural borders |
| **Scaffold Light** | `#F8F9FA` | Light mode background surface |
| **Scaffold Dark** | `#2D2E37` | Dark mode background surface |

### 🌓 Adaptive Dark Mode
Full dark mode support with dedicated semantic tokens (`textPrimary`, `textSecondary`, `textMuted`) ensuring **WCAG AAA** contrast compliance across both light and dark themes.

---

## 🏗️ Architecture & Technical Stack

ExpenseGuard is structured around **Clean Architecture** principles and standard Dart/Flutter best practices:

```
lib/
├── core/
│   ├── errors/           # Global error boundaries, fallback UI, error handler
│   ├── repositories/     # Repository pattern (Expenses, Cards, Notifications)
│   ├── router/           # GoRouter 18 config, StatefulShellRoute, smooth transitions
│   └── theme/            # AppTheme, AppPastelColors extension, Inter typography
├── features/
│   ├── approvals/        # Approvals queue, swipe actions, risk badges
│   ├── auth/             # Biometric / SSO login screen
│   ├── cards/            # Corporate cards carousel, freeze switches, limit modal
│   ├── expenses/         # Camera capture, receipt review, policy checks, details
│   ├── home/             # MainShell with centered camera FAB, dashboard bento
│   ├── insights/         # Spend charts (fl_chart), budget analytics
│   ├── notifications/    # Notifications center, grouping, dismissibles
│   ├── onboarding/       # Multi-slide onboarding walkthrough
│   └── shared/           # Reusable pastel widgets, shimmer skeleton loaders
└── main.dart             # App entry point, ProviderScope initialization
```

### Key Libraries
- **State Management**: `flutter_riverpod: ^2.6.1`
- **Routing**: `go_router: ^18.0.2`
- **Charts & Data**: `fl_chart: ^1.2.0`
- **Typography**: `google_fonts: ^6.3.3` (Inter font family)
- **Local Storage**: `shared_preferences: ^2.5.5`
- **Camera Capture**: `camera: ^0.12.1`

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.29.0`)
- [Dart SDK](https://dart.dev/get-dart) (`>= 3.7.0`)
- Chrome / Android Studio / Xcode (depending on target platform)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/metalha516/ExpenseGuard-.git
   cd ExpenseGuard-
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   # Run in Chrome browser
   flutter run -d chrome

   # Run on connected Android / iOS device
   flutter run
   ```

---

## 🧪 Testing & Quality Assurance

ExpenseGuard features a comprehensive test suite covering unit tests, widget tests, navigation flows, and theme extensions:

```bash
# Run all automated tests
flutter test

# Verify codebase health with zero warnings
flutter analyze
```

**Test Coverage Summary:**
- ✅ **142 / 142 automated tests passing**
- ✅ **0 analyzer warnings or lint issues**
- ✅ Comprehensive widget coverage across all 8 feature modules

---

## 📱 Navigation Shell & Centered Camera

The application implements a persistent `MainShell` navigation bar with mathematically centered Floating Action Button geometry:

```
┌────────────────────────────────────────────────────────┐
│  [ Home ]   [ Approvals ]    ( 📷 )    [ Cards ]  [ Insights ]  [ Profile ] │
└────────────────────────────────────────────────────────┘
```

- **Symmetric Wings**: Balanced left and right navigation wings flanking a centered circular notch.
- **Docked Camera Button**: One-tap access to instant receipt capture from any screen.
- **Adaptive Contrast**: High-contrast pastel mint badge with deep forest slate icons in both light and dark themes.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Crafted with care using Flutter & Dart.
</p>

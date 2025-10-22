# Biometrics Dashboard

A Flutter web application that visualizes biometric data from wearable devices. Built as a technical assessment for Unfold AI, this project demonstrates interactive data visualization, performance optimization, and production-ready Flutter development.

## Overview

This dashboard tracks three key health metrics:

- **HRV (Heart Rate Variability)** - Cardiovascular health and stress indicator
- **RHR (Resting Heart Rate)** - Baseline heart rate measurement  
- **Daily Steps** - Physical activity tracking

Features synchronized charts, journal annotations, and handles real-world data conditions including network latency, failures, and large datasets.

## Features

### Charts & Interactions

- Three synchronized time-series charts (HRV, RHR, Steps)
- Shared tooltips - tap one chart to highlight same date across all
- Range controls (7d/30d/90d)
- Journal annotations with mood tracking
- Touch and mouse interactions

### Performance

- LTTB decimation for large datasets (10k+ points)
- 7-day rolling mean ±1σ statistical bands
- Maintains 60 FPS with smooth animations
- Responsive layouts (mobile to desktop)

### State Management

- Loading skeletons
- Error handling with retry
- Empty states
- Simulated network conditions (700-1200ms latency, 10% failure rate)

### Design

- Dark/light theme toggle
- Material 3 design system
- Adaptive layouts for different screen sizes

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or later)
- Chrome browser (for web testing)
- Git

### Installation

1. **Clone the repository**

   git clone <https://github.com/samuelodukoya/unfold_ai_assessment>
   cd unfold_assessment

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the application**

   ```bash
   # For web (recommended for demo)
   flutter run -d chrome
   
   # For mobile
   flutter run
   ```

### Testing the Application

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 🏗️ Architecture

### Project Structure

```
lib/
├── main.dart                     # App entry point with theme management
├── models/
│   ├── biometric_data.dart       # BiometricData model
│   └── journal_entry.dart        # JournalEntry model
├── services/
│   └── data_service.dart         # Data loading with simulated conditions
├── screens/
│   └── dashboard_screen.dart     # Main dashboard with state management
├── widgets/
│   ├── charts/
│   │   ├── hrv_chart.dart        # HRV time-series chart
│   │   ├── rhr_chart.dart        # RHR time-series chart
│   │   └── steps_chart.dart      # Steps time-series chart
│   ├── controls/
│   │   ├── range_selector.dart   # 7d/30d/90d toggle
│   │   └── large_dataset_toggle.dart # Performance test toggle
│   └── states/
│       ├── loading_skeleton.dart # Loading placeholder
│       ├── error_view.dart       # Error display with retry
│       └── empty_view.dart       # Empty state display
└── utils/
    └── theme.dart                # Light/dark theme definitions

assets/
├── biometrics_90d.json          # 90 days of health metrics
└── journals.json                # Mood journal entries
```

## 📚 Library Choices

### Core Dependencies

- **[fl_chart](https://pub.dev/packages/fl_chart) (v0.69.0)** - Chosen for its excellent Flutter-native charting capabilities, smooth animations, and touch interactions. Provides full customization without web-specific limitations.

- **[provider](https://pub.dev/packages/provider) (v6.1.2)** - Lightweight state management solution. For this project's scope, Provider offers sufficient functionality without the complexity of Bloc or Riverpod.

- **[intl](https://pub.dev/packages/intl) (v0.19.0)** - Date formatting and internationalization support for displaying dates consistently across the application.

### Why These Choices?

- **Flutter-first approach**: All dependencies are pure Dart/Flutter packages ensuring consistent behavior across platforms
- **Performance**: fl_chart renders charts using Flutter's Canvas API, providing 60fps animations
- **Maintainability**: Well-documented packages with active community support
- **Bundle size**: Minimal dependencies keep the web build lean (~2MB gzipped)

## 🎨 Design Decisions

### Chart Interactions

- **Shared state across charts**: When a user interacts with any chart, all three update simultaneously to show data for the same date
- **Touch-first design**: Charts respond to both mouse and touch events for mobile compatibility
- **Visual feedback**: Selected dates are highlighted with a card showing detailed metrics and journal entries

### Theme System

- **Material 3 Design**: Modern, accessible UI following Google's latest design guidelines
- **Dynamic color scheme**: Uses seed colors to generate complementary palettes
- **Smooth transitions**: Theme changes animate smoothly without jarring visual shifts

### Data Handling

- **Simulated real-world conditions**: Random latency (700-1200ms) and ~10% failure rate to demonstrate robust error handling
- **Date range filtering**: Efficient client-side filtering rather than multiple API calls
- **Large dataset mode**: Generates 10,000+ synthetic points to test rendering performance

## ⚡ Performance Optimization

### Current Implementation (without decimation)

The current version handles moderate datasets (90 days) efficiently using these techniques:

1. **Efficient Data Structures**
   - Pre-filtered data arrays based on selected range
   - Minimal widget rebuilds using selective `setState()`
   - Lazy-loaded journal lookups

2. **Chart Optimization**
   - Disabled individual point dots (`dotData: FlDotData(show: false)`)
   - Reduced grid line density
   - Optimized tooltip calculations

3. **Widget Efficiency**
   - Stateless widgets where possible
   - Const constructors throughout
   - Minimal nesting depth

### Planned: Decimation Strategy (for 10k+ points)

For the large dataset mode, the recommended approach is **LTTB (Largest Triangle Three Buckets)** algorithm:

#### Why LTTB?

- **Preserves visual fidelity**: Maintains peaks, valleys, and overall shape
- **Deterministic**: Same input always produces same output
- **Fast**: O(n) time complexity
- **Industry-proven**: Used by Grafana, InfluxDB, and other major visualization tools

#### Implementation Plan

```dart
// services/decimation_service.dart
class DecimationService {
  /// Downsamples data using LTTB algorithm
  /// Reduces N points to ~threshold points while preserving shape
  List<BiometricData> decimateLTTB(List<BiometricData> data, int threshold) {
    // Implementation details in future commit
  }
}
```

#### Expected Metrics

- **Input**: 10,000 data points
- **Output**: ~500-1000 points (configurable)
- **Visual quality**: 95%+ similarity to original
- **Frame time**: <16ms (60 FPS target)
- **Memory reduction**: ~90%

### Alternative Approaches Considered

1. **Bucket Mean** - Simpler but loses extreme values
2. **Max-Min-Avg** - Preserves extremes but creates artificial spikes
3. **Time-based sampling** - Easy but may miss important events

## 🧪 Testing

### Unit Tests

Located in `test/unit/`:

- `decimation_test.dart` - Validates decimator preserves min/max values and output size

### Widget Tests

Located in `test/widget/`:

- `range_switch_test.dart` - Verifies range switching updates charts and maintains tooltip sync

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/decimation_test.dart

# Run with coverage
flutter test --coverage
lcov --list coverage/lcov.info
```

## 🌐 Deployment

This project is automatically deployed to GitHub Pages using GitHub Actions.

### Live Demo

Visit the live application: [https://unfoldaiassessement.netlify.app/](https://unfoldaiassessement.netlify.app/)

### Manual Deployment

To deploy manually:

```bash
# Build for web with correct base href
flutter build web --release

# The build output will be in build/web/
# Deploy this folder to your hosting service
```

### GitHub Pages Setup

1. Push your code to GitHub
2. Enable GitHub Pages in repository Settings → Pages
3. GitHub Actions will automatically build and deploy on every push to main
4. The workflow file is located at `.github/workflows/deploy.yml`

### Alternative Hosting Options

- **Vercel**: Connect GitHub repo for auto-deploy
- **Netlify**: Drag-and-drop `build/web` folder
- **Firebase Hosting**: `firebase deploy`

## 📝 Future Enhancements

See [TRADEOFFS.md](./TRADEOFFS.md) for detailed discussion of features that were prioritized or deferred.

### High Priority

- [ ] Implement LTTB decimation for large datasets
- [ ] Add 7-day rolling mean ±1σ statistical bands to HRV chart
- [ ] Advanced pan/zoom with pinch gestures on mobile
- [ ] Export data as CSV or PDF report

### Medium Priority

- [ ] Compare multiple date ranges side-by-side
- [ ] Customizable chart colors and themes
- [ ] More journal entry types (nutrition, workouts)
- [ ] Offline support with local caching

### Low Priority

- [ ] AI-powered insights and anomaly detection
- [ ] Integration with real wearable device APIs
- [ ] Social features (share progress, challenges)

## 📄 License

This project is created as a technical assessment for Unfold AI.

## 🙏 Acknowledgments

- **Unfold AI** - For the interesting technical challenge
- **fl_chart community** - For excellent documentation and examples
- **Flutter team** - For the amazing cross-platform framework

---

**Live Demo**: [https://unfoldaiassessement.netlify.app/](https://unfoldaiassessement.netlify.app/)
**Screen Recording**: [Link to 2-minute demo video - Coming soon]  
**Repository**: [https://github.com/samuelodukoya/unfold_ai_assessment](https://github.com/samuelodukoya/unfold_ai_assessment)

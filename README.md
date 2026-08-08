# ArrowSlide 3D 🎲✨

![ArrowSlide 3D Hero Banner](https://img.shields.io/badge/ArrowSlide-3D-blueviolet?style=for-the-badge&logo=flutter)

**ArrowSlide 3D** is an incredibly addictive, premium-feeling 3D puzzle game built with Flutter. Tap glossy arrows to slide them off the grid without them colliding with one another. Complete levels before time runs out, manage your heart count (lives), and use your wits to conquer all 200 levels!

---

## 🚀 Features

- **200 Progressively Harder Levels:** The game features a bespoke neuroscience-based difficulty curve. Grids start at a simple `3x3` and ramp all the way up to a chaotic `10x10`!
- **Daily Challenges:** A fresh, highly-complex puzzle generated daily to keep players coming back.
- **Google AdMob Integration (Production Ready):**
  - **Banner Ads:** Seamlessly displayed at the bottom of gameplay.
  - **Interstitial Ads:** Full-screen ads shown strategically every few level completions or restarts.
  - **Rewarded Ads:** Watch short video ads to earn **+1 Life** or unlock **Level Hints**.
- **Immersive 3D Space Aesthetics:** Features a dark neon space theme, glassmorphic UI elements, dynamic shadows, and 3D floating animations using Flutter's powerful rendering capabilities.
- **Interactive Camera Controls:** Use pinch-to-zoom and panning to view the 3D board from any angle on harder, larger grids.
- **Haptic & Audio Feedback:** A highly tactile experience featuring custom slide/win/fail sounds and satisfying haptic vibrations (fully configurable in the Settings menu).

---

## 🛠 Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** `provider`
- **Persistence:** `shared_preferences`
- **Monetization:** `google_mobile_ads`
- **Rendering Backend:** Impeller (OpenGLES)

---

## 🎮 How to Play

1. You are presented with a grid of floating arrow cubes.
2. Each cube has a directional arrow indicating where it wants to slide.
3. Tap a cube to move it. If its path is clear, it will fly off the board successfully!
4. If another cube is blocking its path, it will crash, costing you a **heart (life)**.
5. Clear the entire board before the **Timer** runs out to win the level!
6. If you get stuck, tap the **Hint** button (requires watching a short ad) to see the next safe move.

---

## 🧠 Neuroscience-Based Progression

Levels `1` through `200` are algorithmically scaled for maximum player retention:
- **Dopamine Resets:** Every 10 levels, the game drops to a highly satisfying, easier "breather" level to reset player fatigue.
- **Adaptive Timers:** The time limit scales aggressively alongside grid size and puzzle complexity.
- **Gradual Complexity:** Block density slowly increases as the grid expands to ensure a steady learning curve.

---

## ⚙️ Running Locally

### Prerequisites
- Flutter SDK (v3.19.0+ recommended)
- Java SDK (JDK 17) for Android compilation
- An active Android Emulator or physical device

### Steps to Run
1. Clone the repository:
   ```bash
   git clone https://github.com/harshfly/ArrowSlide-3d.git
   ```
2. Navigate to the project directory:
   ```bash
   cd arrowslide_3d
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run --release
   ```

*(Note: AdMob uses live production IDs by default. If you are testing locally to test ad behavior, switch to Google's official Test IDs in `lib/config.dart` to prevent invalid traffic penalties on your AdMob account).*

---

## 📁 Project Structure

- `lib/models/`: Data models for game state (`ArrowBlock`, `UserData`, etc).
- `lib/screens/`: Flutter UI pages (`HomeScreen`, `GameplayScreen`, `SettingsScreen`, etc).
- `lib/utils/`: Core game logic (`GameEngine`), file loading, and `AdService`.
- `lib/widgets/`: Reusable, styled UI components (`AnimatedScaleButton`, `ArrowBlockWidget`).
- `assets/levels/`: 200 JSON files containing coordinate data for the puzzles.
- `tools/generate_levels.dart`: The algorithmic script used to procedurally generate the 200 levels.

---

## 🛡 License

This project is proprietary. All rights reserved.

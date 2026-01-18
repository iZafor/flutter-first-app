# Word Pair Generator

A Flutter application that generates random English word pairs with an interactive and animated user interface.

## Description

This app generates random word pairs using the `english_words` package and allows users to:

- **Generate Random Word Pairs**: Click the next button to generate new random word combinations
- **Mark Favorites**: Toggle favorites with an animated heart button that changes color
- **View History**: See all previously generated word pairs in a scrollable list
- **Manage Favorites**: View all favorited word pairs in a grid layout with scale animations
- **Responsive Design**: Adaptive navigation rail that extends on wider screens (≥600px)

### Features

- **Animations**:
    - Smooth card size animations using `AnimatedSize`
    - Color transition animations for the favorite button
    - Elastic scale animations for favorite grid items
    - Automatic scroll animations for the word history
- **Interactive Elements**:
    - Hover effects with pointer cursor on delete buttons
    - Bounce physics for smooth scrolling
    - Visual feedback for all interactive elements

- **State Management**: Uses Provider package for efficient state management across the app

## Demo

<video height="800" src="assets/demo.mp4" controls></video>

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

### Dependencies

- `english_words`: For generating random word pairs
- `provider`: For state management

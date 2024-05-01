# Recipe Finder

A Flutter app that allows users to input ingredients and fetch matching recipes from the Spoonacular API.

## Features

- Input ingredients you have on hand
- Find recipes that match your available ingredients
- View detailed recipe information including ingredients and instructions
- Save favorite recipes for later reference

## Getting Started

### Prerequisites

- Flutter SDK: ^3.7.2
- Dart SDK: ^3.0.0
- [Spoonacular API Key](https://spoonacular.com/food-api)

### Setup

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/recipe_finder.git
   cd recipe_finder
   ```

2. Create a `.env` file in the project root and add your Spoonacular API key:
   ```
   SPOONACULAR_API_KEY=your_api_key_here
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Architecture

The app follows a simple layered architecture:

- **Models**: Data models for recipes and other entities
- **Services**: API service for communicating with the Spoonacular API
- **Screens**: UI screens for the app
- **Widgets**: Reusable UI components
- **Utils**: Utility functions and helpers
- **Constants**: App-wide constants

## License

This project is licensed under the MIT License - see the LICENSE file for details.

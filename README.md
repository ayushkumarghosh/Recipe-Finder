# Recipe Finder

A Flutter application that allows users to discover recipes based on ingredients they have on hand, powered by the Spoonacular API.

![Recipe Finder App](screenshot.png)

## Features

- Search for recipes by ingredients you have available
- Filter and sort recipes by preparation time, cuisines, and dietary preferences
- View detailed recipe information including ingredients, instructions, and nutritional data
- Save favorite recipes for quick access
- Track your search history
- Ingredient suggestions to speed up search
- Cached images for faster loading and offline availability

## Getting Started

### Prerequisites

- Flutter SDK: ^3.7.2
- Dart SDK: ^3.0.0
- [Spoonacular API Key](https://spoonacular.com/food-api)

### Installation

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

## User Guide

### Searching for Recipes
1. Enter ingredients in the search bar on the home screen
2. Tap the '+' button or press enter to add an ingredient
3. Use the suggested ingredients for quicker input
4. Tap the 'Find Recipes' button to search

### Filtering Results
1. Use the filter icon in the results screen to access filtering options
2. Filter by:
   - Preparation time
   - Cuisine type
   - Dietary restrictions (vegetarian, vegan, gluten-free)
   - Meal type (breakfast, lunch, dinner)

### Saving Favorites
1. Tap the heart icon on any recipe to save it to favorites
2. Access your favorites through the favorites tab
3. Remove favorites by tapping the heart icon again

## Architecture

The app follows a layered architecture pattern:

- **Models**: Data models for recipes and other entities
- **Services**: API and storage services
- **Screens**: UI screens of the application
- **Widgets**: Reusable UI components
- **Utils**: Utility functions and helpers
- **Constants**: App-wide constants

## Deployment

### Android
1. Update the `android/app/build.gradle` file with your app details
2. Create a signing key:
   ```
   keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
   ```
3. Configure the key in `android/key.properties`
4. Build the APK:
   ```
   flutter build apk --release
   ```

### iOS
1. Update the iOS app bundle identifier in Xcode
2. Configure signing certificates in Xcode
3. Build the IPA:
   ```
   flutter build ios --release
   ```

### Web
1. Build the web version:
   ```
   flutter build web --release
   ```
2. Deploy the contents of the `build/web` directory to your web hosting service

## Testing

Run the tests with:
```
flutter test
flutter test integration_test
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [Spoonacular API](https://spoonacular.com/food-api) for providing recipe data
- [Flutter](https://flutter.dev/) for the amazing framework

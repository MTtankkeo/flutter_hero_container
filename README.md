# Introduction
A Flutter package that provides smooth animated transitions between widgets using snapshot-based animations for consistent 120fps performance regardless of widget complexity.

> Inspired by Flutter's OpenContainer from the animations package.

## Usage
The following explains the basic usage of this package.

```dart
HeroContainer(
  closedBuilder: (context, action) {
    return TextButton(
      onPressed: action,
      child: Text("Tap to expand", style: TextStyle(fontSize: 50))
    );
  }
  openedBuilder: (context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expanded View")),
      body: Center(
        child: Text("Hello, World!", style: TextStyle(fontSize: 32)),
      ),
    );
  },
)
```
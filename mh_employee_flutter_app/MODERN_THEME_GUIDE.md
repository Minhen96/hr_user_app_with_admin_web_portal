# Modern Theme Design Guide

This guide documents the modern purple gradient design system used throughout the MH HR Employee Flutter app.

## Color Palette

### Primary Purple Gradient
```dart
AppColors.gradientPurple = [Color(0xFF667EEA), Color(0xFF764BA2)]
```

### Status Colors

**Success (Green)**
```dart
[Color(0xFF10B981), Color(0xFF059669)]
```

**Warning (Orange)**
```dart
[Color(0xFFF59E0B), Color(0xFFD97706)]
```

**Error (Red)**
```dart
[Color(0xFFEF4444), Color(0xFFDC2626)]
```

**Info (Blue)**
```dart
[Color(0xFF3B82F6), Color(0xFF2563EB)]
```

### Theme-Aware Colors

**Light Mode:**
- Background: `AppColors.background` (#F8FAFC)
- Text Primary: `AppColors.textPrimary` (#1E293B)
- Text Secondary: `AppColors.textSecondary` (#64748B)

**Dark Mode:**
- Background: `AppColors.darkBackground` (#0F172A)
- Surface: `AppColors.darkSurface` (#1E293B)
- Text Primary: `AppColors.darkTextPrimary` (#F1F5F9)
- Text Secondary: `AppColors.darkTextSecondary` (#94A3B8)

## Core Components

### 1. ModernGlassCard

Glassmorphism card with subtle gradient background.

```dart
ModernGlassCard(
  padding: const EdgeInsets.all(16),
  gradient: AppColors.gradientPurple.map((c) => c.withOpacity(0.05)).toList(),
  child: // Your content
)
```

**Use Cases:**
- Main content containers
- Information cards
- Form sections
- List items

### 2. ModernLoading

Animated loading indicator with purple gradient.

```dart
ModernLoading(size: 48)

// With text
Column(
  children: [
    ModernLoading(size: 48),
    SizedBox(height: 16),
    Text('Loading...', style: TextStyle(color: AppColors.darkTextSecondary)),
  ],
)
```

### 3. Gradient Buttons

#### Primary Action (Purple Gradient)
```dart
Container(
  height: 54,
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: AppColors.gradientPurple),
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: AppColors.gradientPurple.first.withOpacity(0.4),
        blurRadius: 12,
        offset: Offset(0, 6),
      ),
    ],
  ),
  child: ElevatedButton.icon(
    onPressed: () {},
    icon: Icon(Icons.add_rounded, color: Colors.white),
    label: Text('Add Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
)
```

#### Success Action (Green Gradient)
```dart
Container(
  height: 50,
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF10B981).withOpacity(0.3),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: ElevatedButton(/* ... */)
)
```

### 4. Status Chips

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    'Approved',
    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
  ),
)
```

## Design Patterns

### Theme Detection

Always check the current theme:

```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Scaffold(
    backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
    // ...
  );
}
```

### Text Styling

```dart
// Primary text
Text(
  'Title',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
  ),
)

// Secondary text
Text(
  'Description',
  style: TextStyle(
    fontSize: 14,
    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
  ),
)
```

### Gradient Icons

```dart
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: AppColors.gradientPurple),
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: AppColors.gradientPurple.first.withOpacity(0.3),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Icon(Icons.star_rounded, color: Colors.white, size: 22),
)
```

## Animations

### List Item Entrance

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return MyListItem(item: items[index])
      .animate(delay: (index * 50).ms)
      .fadeIn()
      .slideY(begin: 0.1, end: 0);
  },
)
```

### Scale Animation

```dart
MyWidget()
  .animate()
  .scale(duration: 300.ms)
```

### Slide Animation

```dart
MyWidget()
  .animate()
  .fadeIn()
  .slideY(begin: -0.1, end: 0)
```

## Screen Layouts

### Standard Screen Structure

```dart
class MyScreen extends StatefulWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _isLoading = false;
  String? _error;
  List<MyModel> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMyData();
      setState(() => _items = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.gradientPurple),
              ),
              child: FlexibleSpaceBar(
                title: Text('My Screen', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),

          // Content
          if (_isLoading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ModernLoading(size: 48),
                    SizedBox(height: 16),
                    Text('Loading...', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(child: _buildErrorState())
          else if (_items.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildListItem(_items[index], index),
                childCount: _items.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 80, color: AppColors.error),
          SizedBox(height: 16),
          Text('Oops! Something went wrong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
          SizedBox(height: 8),
          Text(_error!, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: Icon(Icons.refresh_rounded),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 80, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          SizedBox(height: 16),
          Text('No Items Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
          SizedBox(height: 8),
          Text('Items will appear here', style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildListItem(MyModel item, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ModernGlassCard(
        padding: EdgeInsets.all(16),
        child: // Item content
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideY(begin: 0.1, end: 0);
  }
}
```

## Modal Dialogs

### Modern Dialog Structure

```dart
void _showDialog() {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gradient Header
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.gradientPurple),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.info_rounded, color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text('Dialog Title', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(24),
              child: // Your content
            ),

            // Action Buttons
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.gradientPurple),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text('Confirm', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().scale(duration: 300.ms),
    ),
  );
}
```

## Best Practices

1. **Always use theme-aware colors** - Never hardcode colors, use `isDark` check
2. **Add animations to lists** - Use staggered entrance animations with delay
3. **Use gradients consistently** - Purple for primary, Green for success, Orange for warning, Red for error
4. **Maintain spacing consistency** - Use multiples of 4 (4, 8, 12, 16, 20, 24)
5. **Apply shadows to elevated elements** - Gradient buttons, cards, icons
6. **Use rounded corners** - 12-16px for cards/buttons, 8-10px for small elements
7. **Include loading and error states** - Every screen should handle all states
8. **Add proper dark mode support** - Test all screens in both light and dark themes

## Examples in Codebase

**Reference Implementations:**
- `lib/features/equipment/presentation/screens/equipment_screen_new.dart` - Modern tab bar
- `lib/features/equipment/presentation/screens/approved_screen.dart` - Green gradient success state
- `lib/features/equipment/presentation/screens/history_screen.dart` - Status-based gradients and filters
- `lib/shared/screens/request_screen.dart` - Form with gradient button and signature
- `lib/features/documents/presentation/screens/company_updates_screen.dart` - List with pagination
- `lib/shared/widgets/signature_pad.dart` - Modern signature capture dialog

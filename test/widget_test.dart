import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codealpha_flashcard_quiz_app/models/flashcard.dart';
import 'package:codealpha_flashcard_quiz_app/screens/manage_cards_screen.dart';
import 'package:codealpha_flashcard_quiz_app/screens/splash_screen.dart';
import 'package:codealpha_flashcard_quiz_app/screens/stats_screen.dart';
import 'package:codealpha_flashcard_quiz_app/screens/study_quiz_screen.dart';
import 'package:codealpha_flashcard_quiz_app/services/flashcard_service.dart';
import 'package:codealpha_flashcard_quiz_app/services/theme_service.dart';
import 'package:codealpha_flashcard_quiz_app/services/user_profile_service.dart';
import 'package:codealpha_flashcard_quiz_app/widgets/add_edit_card_dialog.dart';
import 'package:codealpha_flashcard_quiz_app/widgets/flashcard_view.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FlashcardView displays question on front and flips to show answer', (WidgetTester tester) async {
    bool isFlipped = false;
    final testCard = Flashcard(
      id: '1',
      question: 'What is the speed of light?',
      answer: '299,792,458 m/s',
      category: 'Science & Biology',
      difficulty: CardDifficulty.easy,
      hint: 'Symbol c in physics',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return FlashcardView(
                card: testCard,
                isFlipped: isFlipped,
                onFlip: () {
                  setState(() {
                    isFlipped = !isFlipped;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    // Initial state: Front of card
    expect(find.text('What is the speed of light?'), findsOneWidget);
    expect(find.text('Show Answer'), findsOneWidget);

    // Tap Show Answer
    await tester.tap(find.text('Show Answer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Flipped state: Answer visible
    expect(find.text('299,792,458 m/s'), findsOneWidget);
    expect(find.text('Hide Answer'), findsOneWidget);
  });

  testWidgets('StudyQuizScreen renders flashcard and navigates next/previous', (WidgetTester tester) async {
    final flashcardService = FlashcardService();
    await flashcardService.init();

    await tester.pumpWidget(
      MaterialApp(
        home: StudyQuizScreen(flashcardService: flashcardService),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    // Verify study mode elements
    expect(find.text('Study'), findsOneWidget);
    expect(find.text('Quiz'), findsOneWidget);
    expect(find.text('Show Answer'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);

    // Tap Next
    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Card 2 of 50'), findsOneWidget);

    // Tap Previous
    await tester.tap(find.text('Previous'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Card 1 of 50'), findsOneWidget);
  });

  testWidgets('ManageCardsScreen lists cards and filters with search', (WidgetTester tester) async {
    final flashcardService = FlashcardService();
    await flashcardService.init();

    await tester.pumpWidget(
      MaterialApp(
        home: ManageCardsScreen(flashcardService: flashcardService),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Manage Flashcards'), findsOneWidget);
    expect(find.text('Add Flashcard'), findsOneWidget);

    // Enter search query
    await tester.enterText(find.byType(TextField), 'speed of light');
    await tester.pump(const Duration(milliseconds: 400));

    // Should find the speed of light card
    expect(find.text('What is the speed of light in a vacuum?'), findsOneWidget);
  });

  testWidgets('SplashScreen displays mascot, Cortexa title, tagline, and calls onComplete', (WidgetTester tester) async {
    bool completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          onComplete: () {
            completed = true;
          },
        ),
      ),
    );

    // Initial check: Mascot, app name, and tagline are visible
    expect(find.text('Cortexa'), findsOneWidget);
    expect(find.text('Train Your Brain to Remember.'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Advance time past the 2.8s splash duration
    await tester.pump(const Duration(milliseconds: 3000));
    expect(completed, isTrue);
  });

  testWidgets('StatsScreen displays User Profile section and allows editing', (WidgetTester tester) async {
    final flashcardService = FlashcardService();
    await flashcardService.init();
    final themeService = ThemeService();
    final profileService = UserProfileService();
    await profileService.init();

    await tester.pumpWidget(
      MaterialApp(
        home: StatsScreen(
          flashcardService: flashcardService,
          themeService: themeService,
          profileService: profileService,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    // Verify initial profile section details
    expect(find.text('Profile & Learning Stats'), findsOneWidget);
    expect(find.text('Brain Champion'), findsOneWidget);
    expect(find.text('Active Scholar'), findsWidgets);
    expect(find.text('Daily Goal'), findsOneWidget);

    // Open Edit Profile dialog
    await tester.tap(find.byTooltip('Edit Profile').first);
    await tester.pumpAndSettle();

    expect(find.text('Edit Learner Profile'), findsWidgets);
    expect(find.text('Save Profile'), findsOneWidget);

    // Change the name
    await tester.enterText(find.byType(TextFormField).first, 'Morgan Sage');
    await tester.pumpAndSettle();

    // Tap Save Profile
    await tester.ensureVisible(find.text('Save Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Profile'));
    await tester.pumpAndSettle();

    // Verify profile name updated reactively
    expect(find.text('Morgan Sage'), findsOneWidget);
  });

  testWidgets('StatsScreen renders safely without division-by-zero when dailyGoal is zero or negative and history is empty', (WidgetTester tester) async {
    final flashcardService = FlashcardService();
    await flashcardService.init();
    await flashcardService.clearAllCards();

    final themeService = ThemeService();
    final profileService = UserProfileService();
    await profileService.init();
    // Simulate invalid profile in service
    await profileService.updateProfile(dailyGoal: 0);

    await tester.pumpWidget(
      MaterialApp(
        home: StatsScreen(
          flashcardService: flashcardService,
          themeService: themeService,
          profileService: profileService,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    // Verify it renders safely without throwing an exception
    expect(find.text('Profile & Learning Stats'), findsOneWidget);
    expect(find.text('Daily Goal'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsWidgets);
  });

  testWidgets('Screens render properly across 320dp, 360dp, and 400dp widths in Light and Dark themes', (WidgetTester tester) async {
    final flashcardService = FlashcardService();
    await flashcardService.init();
    final profileService = UserProfileService();
    await profileService.init();

    final widths = [320.0, 360.0, 400.0];
    final brightnesses = [Brightness.light, Brightness.dark];

    for (final width in widths) {
      for (final brightness in brightnesses) {
        tester.view.physicalSize = Size(width * 2, 800 * 2);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: true, brightness: brightness),
            home: StudyQuizScreen(flashcardService: flashcardService),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Study mode selector and top controls render without overflow
        expect(find.text('Study'), findsOneWidget);
        expect(find.text('Quiz'), findsOneWidget);

        // Manage Cards Screen
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: true, brightness: brightness),
            home: ManageCardsScreen(flashcardService: flashcardService),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Manage Flashcards'), findsOneWidget);
      }
    }

    // Reset view
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets('AddEditCardDialog enforces character limits on question, answer, and hint', (WidgetTester tester) async {
    final flashcardService = FlashcardService();
    await flashcardService.init();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                AddEditCardDialog.show(
                  context: context,
                  existingCategories: flashcardService.categories,
                  onSave: (question, answer, category, diff, hint) {},
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(3)); // question, answer, hint

    final questionField = tester.widget<TextField>(textFields.at(0));
    final answerField = tester.widget<TextField>(textFields.at(1));
    final hintField = tester.widget<TextField>(textFields.at(2));

    expect(questionField.maxLength, 300);
    expect(answerField.maxLength, 500);
    expect(hintField.maxLength, 100);
  });
}



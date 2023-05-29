// WIDGET TEST
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_page.dart';
import 'package:flutter_testing_tutorial/news_service.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
  });

  final articlesFromService = [
    Article(title: 'Test 1', content: 'Test content 1'),
    Article(title: 'Test 2', content: 'Test content 2'),
    Article(title: 'Test 3', content: 'Test content 3'),
  ];

  void arrangeNewsSeviceReturns3Articles() {
    when(() => mockNewsService.getArticles()).thenAnswer(
      (_) async => articlesFromService,
    );
  }

  // adding delay in arrange
  void arrangeNewsSeviceReturns3ArticlesAfter2SecondsWait() {
    when(() => mockNewsService.getArticles()).thenAnswer(
      (_) async {
        await Future.delayed(const Duration(seconds: 2));
        return articlesFromService;
      },
    );
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: NewsPage(),
      ),
    );
  }

  testWidgets(
    "title is displayed",
    (WidgetTester tester) async {
      arrangeNewsSeviceReturns3Articles(); //  Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      // before executing below we need to specify which page/widget
      // we need to test. check line above this comment.
      expect(find.text('News'), findsOneWidget);
    },
  );

  testWidgets(
    "loading indicator is displayed while waiting for articles",
    (WidgetTester tester) async {
      arrangeNewsSeviceReturns3ArticlesAfter2SecondsWait();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 500));
      // pump forces a widget rebuild. this will give time
      // Consumer<NewsChangeNotifier> in news_page to run

      // expect(find.byType(CircularProgressIndicator), findsOneWidget); OR
      expect(find.byKey(Key('progress-indicator')), findsOneWidget);

      await tester.pumpAndSettle();
      // this waits until there are no more ReBuilds
      // happening like animation i.e. CircularProgressIndicator
      // when spinning ends pumpandsettle future will be completed.
    },
  );

  testWidgets(
    "articles are displayed",
    (WidgetTester tester) async {
      arrangeNewsSeviceReturns3Articles();

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.pump();

      for (final article in articlesFromService) {
        expect(find.text(article.title), findsOneWidget);
        expect(find.text(article.content), findsOneWidget);
      }
    },
  );
}

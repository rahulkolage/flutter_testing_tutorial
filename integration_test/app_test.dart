import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article_page.dart';
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
    """Tapping on the first article excerpt opens the article page,
    where the full article content is displayed""",
    (WidgetTester tester) async {
      // arrange
      arrangeNewsSeviceReturns3Articles();

      await tester.pumpWidget(createWidgetUnderTest());

      // to initalize everything, to run init state
      await tester.pump();

      await tester.tap(find.text('Test content 1'));

      // wait for all loading / animation completes and new page opens
      await tester.pumpAndSettle();

      // To check we are not on NewsPage but on ArticlePage
      expect(find.byType(NewsPage), findsNothing);
      expect(find.byType(ArticlePage), findsOneWidget);

      // find title of article
      expect(find.text('Test 1'), findsOneWidget);
      expect(find.text('Test content 1'), findsOneWidget);
    },
  );
}

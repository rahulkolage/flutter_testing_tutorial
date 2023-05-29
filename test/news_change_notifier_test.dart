import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_service.dart';

// one way to create mock service
// not good to work with , as you write your own class, implementation
// class BadMockNewsService implements NewsService {
//   @override
//   Future<List<Article>> getArticles() async {
//     return [
//       Article(title: 'Test 1', content: 'Test content 1'),
//       Article(title: 'Test 2', content: 'Test content 2'),
//       Article(title: 'Test 3', content: 'Test content 3'),
//     ];
//   }
// }

// will use Mocktail package

// UNIT TESTS
class MockNewsService extends Mock implements NewsService {}

void main() {
  // sut = system under test
  late NewsChangeNotifier sut;
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });

  test(
    'Initial values are correct',
    () {
      expect(sut.articles, []);
      expect(sut.isLoading, false);
    },
  );

  group('getArticles', () {
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

    test(
      "gets articles using the NewsService",
      () async {
        // implementation of getArticles() method which is required in verify() to run test successfully
        // .thenAnswer returns Future
        // this might fail , if we havn't implemented this method inside news_change_notifier
        // when(() => mockNewsService.getArticles()).thenAnswer((_) async => []); // Arrange
        arrangeNewsSeviceReturns3Articles();

        await sut.getArticles(); //  Act
        // verify , provided by Mocktail package
        // here checking is getArticles has been called
        verify(() => mockNewsService.getArticles()).called(1); //  Assert
      },
    );

    // Arrange-Act-Assert Pattern
    // once above test done, we verify if values assigned correctly

    // one more, test below is for implementing actual getArticles() in news_change_nofitier
    // as it Test Driven Development (TDD) approach.
    test(
      """indicates loading of data, 
      sets articles to the ones from the service,
      indicates that data is not being loaded anymore""",
      () async {
        arrangeNewsSeviceReturns3Articles();
        // we need to check above 3 steps, for that

        // indicates loading of data
        final future = sut.getArticles();
        expect(sut.isLoading, true);
        await future;

        // sets articles to the ones from the service
        expect(sut.articles, articlesFromService);

        // indicates that data is not being loaded anymore
        expect(sut.isLoading, false);
      },
    );
  });
}

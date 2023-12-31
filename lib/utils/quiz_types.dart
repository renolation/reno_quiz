import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';

final List<QuizType> quizTypes = [
  //title will be the key of localization for quizType title
  QuizType(
      title: quizZone,
      image: "quizzone_icon.svg",
      active: true,
      description: desQuizZone),
  QuizType(
      title: battleQuiz,
      image: "battle_quiz.svg",
      active: true,
      description: desBattleQuiz),
  QuizType(
      title: contest,
      image: "contests_icon.svg",
      active: true,
      description: desContest),
  QuizType(
      title: groupPlay,
      image: "groupplay_icon.svg",
      active: true,
      description: desGroupPlay),
  QuizType(
      title: guessTheWord,
      image: "Guess the word.svg",
      active: true,
      description: desGuessTheWord),
  QuizType(
      title: funAndLearn,
      image: "fun_nlearn.svg",
      active: true,
      description: desFunAndLearn),
  QuizType(
      title: dailyQuiz,
      image: "daily_quiz.svg",
      active: true,
      description: desDailyQuiz),
  QuizType(
      title: audioQuestionsKey,
      image: "audio_questions.svg",
      active: true,
      description: desAudioQuestionsKey),
  QuizType(
    title: examKey,
    image: "exam.svg",
    active: true,
    description: desExamKey,
  ),
  QuizType(
      title: mathManiaKey,
      image: "maths_quiz.svg",
      active: true,
      description: desMathManiaKey),
];

import 'package:drim_ai/models/quiz.dart';

const List<QuizQuestion> kQuizQuestions = [
  // Q1 — Interests (multi, max 3)
  QuizQuestion(
    id: 'q1',
    question: 'Which of these activities makes you lose track of time?',
    hint: 'Pick up to 3 that feel most true.',
    type: QuestionType.multiSelect,
    maxSelections: 3,
    category: 'interests',
    options: [
      'Creating or designing things',
      'Solving puzzles or problems',
      'Helping or supporting other people',
      'Learning how things work',
      'Writing, storytelling, or communicating',
      'Organising, planning, or leading',
      'Researching and exploring ideas',
      'Building or making things',
    ],
  ),

  // Q2 — Values (multi, max 2)
  QuizQuestion(
    id: 'q2',
    question: 'What matters most to you in whatever you end up doing?',
    hint: "Pick up to 2. There's no wrong answer.",
    type: QuestionType.multiSelect,
    maxSelections: 2,
    category: 'values',
    options: [
      "Making a real difference in people's lives",
      'Having creative freedom',
      'Continuously learning and growing',
      'Earning a stable, good income',
      'Being my own boss or having flexibility',
      'Working with a team toward something bigger',
      'Being recognised for my work',
      'Solving problems that actually matter',
    ],
  ),

  // Q3 — Strengths (single)
  QuizQuestion(
    id: 'q3',
    question: 'Which of these comes most naturally to you?',
    hint: 'Pick the one that feels most true.',
    type: QuestionType.singleSelect,
    category: 'strengths',
    options: [
      'Solving complex puzzles or logic games',
      'Helping others solve their problems',
      'Creating something from scratch',
      'Organising and planning events',
      'Researching and finding the right answer',
      'Explaining things clearly to others',
    ],
  ),

  // Q4 — Environment (multi, max 3)
  QuizQuestion(
    id: 'q4',
    question: 'Which environments do you thrive in?',
    hint: 'Choose up to 3.',
    type: QuestionType.multiSelect,
    maxSelections: 3,
    category: 'style',
    options: [
      'Fast-paced and dynamic',
      'Quiet and focused',
      'Collaborative and social',
      'Structured and predictable',
      'Flexible and changing',
      'Independent and self-directed',
    ],
  ),

  // Q5 — Values deeper (single)
  QuizQuestion(
    id: 'q5',
    question:
        "Imagine it's 10 years from now. What would make you feel like your work was worth it?",
    hint: 'Pick one.',
    type: QuestionType.singleSelect,
    category: 'values',
    options: [
      'I built something people use and love',
      'I helped people through a hard time in their lives',
      'I discovered or created something new',
      'I led a team that did something remarkable',
      'I earned enough to give my family a better life',
      'I became truly excellent at something difficult',
    ],
  ),

  // Q6 — Interests deeper (multi, max 2)
  QuizQuestion(
    id: 'q6',
    question:
        'Which of these topics could you talk about for hours, even without being asked?',
    hint: 'Pick up to 2.',
    type: QuestionType.multiSelect,
    maxSelections: 2,
    category: 'interests',
    options: [
      'Technology, AI, or how the future will look',
      'People — why they think, feel, and behave the way they do',
      'Business, money, or how organisations work',
      'Art, design, music, or creative expression',
      'Health, the body, or how we stay well',
      'The environment, nature, or sustainability',
      'Society, justice, or how the world should work',
      'Science, data, or how we find out what\'s true',
    ],
  ),

  // Q7 — Strengths deeper (single)
  QuizQuestion(
    id: 'q7',
    question:
        'When a group project hits a wall, what role do you usually end up in?',
    hint: 'Pick the one that rings true.',
    type: QuestionType.singleSelect,
    category: 'strengths',
    options: [
      'The one who figures out what the actual problem is',
      'The one who keeps everyone calm and moving forward',
      'The one who comes up with a creative way around it',
      'The one who researches until they find the answer',
      "The one who makes sure everyone's heard and included",
      "The one who just starts doing something so the group doesn't stall",
    ],
  ),

  // Q8 — Final confirmation (single)
  QuizQuestion(
    id: 'q8',
    question: 'Ready to see your personalized career roadmap?',
    hint: 'This is based on all your answers so far.',
    type: QuestionType.singleSelect,
    category: 'meta',
    options: ["Yes, let's do it!", 'I want to review my answers'],
  ),
];

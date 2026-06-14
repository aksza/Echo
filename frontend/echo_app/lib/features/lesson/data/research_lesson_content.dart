class ResearchLessonSection {
  final String title;
  final String text;

  const ResearchLessonSection({
    required this.title,
    required this.text,
  });
}

class ResearchLessonContent {
  final String title;
  final String subtitle;
  final String level;
  final List<String> keyVocabulary;
  final List<ResearchLessonSection> sections;
  final List<String> discussionQuestions;

  const ResearchLessonContent({
    required this.title,
    required this.subtitle,
    required this.level,
    required this.keyVocabulary,
    required this.sections,
    required this.discussionQuestions,
  });

  String get fullText {
    final buffer = StringBuffer();

    buffer.writeln(title);
    buffer.writeln(subtitle);
    buffer.writeln();

    for (final section in sections) {
      buffer.writeln(section.title);
      buffer.writeln(section.text);
      buffer.writeln();
    }

    return buffer.toString().trim();
  }
}

const researchLesson = ResearchLessonContent(
  title: 'Dealing with Technology',
  subtitle: 'Types of Malware and Online Safety',
  level: 'A2-B1',
  keyVocabulary: [
    'virus',
    'worm',
    'Trojan horse',
    'ransomware',
    'spyware',
    'keystroke logger',
    'password',
    'personal information',
    'suspicious link',
    'pop-up',
    'online safety',
  ],
  sections: [
    ResearchLessonSection(
      title: 'What is malware?',
      text:
          'Malware is a short word for malicious software. It is software that can damage a computer, steal personal information, or make a device work badly. Malware can get into a computer through suspicious links, unsafe downloads, infected email attachments, or fake pop-up messages.',
    ),
    ResearchLessonSection(
      title: 'Virus',
      text:
          'A virus is a type of malware that attaches itself to files or programs. When the infected file is opened, the virus can spread to other files. A virus can delete information, slow down the computer, or cause other problems.',
    ),
    ResearchLessonSection(
      title: 'Worm',
      text:
          'A worm is similar to a virus, but it can spread without the user opening an infected file. It often spreads through networks and can infect many computers quickly. Worms can slow down systems and create security problems.',
    ),
    ResearchLessonSection(
      title: 'Trojan horse',
      text:
          'A Trojan horse looks like a useful or safe program, but it hides harmful code inside. For example, a user may download a free game or tool, but the program may secretly steal information or give access to the computer.',
    ),
    ResearchLessonSection(
      title: 'Ransomware',
      text:
          'Ransomware is malware that locks files or the whole computer. Then it asks the user to pay money to get access again. It is important not to open suspicious links or unknown attachments because they may contain ransomware.',
    ),
    ResearchLessonSection(
      title: 'Spyware and keystroke loggers',
      text:
          'Spyware secretly watches what a user does on a computer or phone. A keystroke logger records what the user types, including passwords and personal information. This can be very dangerous because criminals can steal accounts or private data.',
    ),
    ResearchLessonSection(
      title: 'How can we stay safe online?',
      text:
          'To stay safe online, users should create strong passwords, avoid suspicious links, update their devices, and not share personal information with unknown people. It is also important to use antivirus software and think carefully before downloading files.',
    ),
  ],
  discussionQuestions: [
    'What types of malware do you know?',
    'Why is ransomware dangerous?',
    'What is a suspicious link?',
    'How can people protect their passwords?',
    'What personal information should we protect online?',
    'Have you ever seen a fake pop-up or suspicious message?',
  ],
);
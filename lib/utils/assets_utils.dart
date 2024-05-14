class AssetsUtils {
  // TODO(J): migrate these also to the assets constants.
  static String getImagePath(String imageName) => 'assets/images/$imageName';

  static String getprofileImagePath(String imageName) =>
      'assets/images/profile/$imageName';

  static String getEmojiPath(String emojiName) =>
      'assets/images/emojis/$emojiName';

  static String img(String img) => 'assets/images/$img';
}

import '../models/link.dart';

class LinkDetector {
  static LinkType detectType(String url) {
    final urlLower = url.toLowerCase();
    
    // Job links
    if (urlLower.contains('linkedin.com/jobs') ||
        urlLower.contains('indeed.com') ||
        urlLower.contains('naukri.com') ||
        urlLower.contains('monster.com') ||
        urlLower.contains('glassdoor.com')) {
      return LinkType.job;
    }
    
    // Reel links
    if (urlLower.contains('instagram.com/reel') ||
        urlLower.contains('tiktok.com') ||
        urlLower.contains('youtube.com/shorts')) {
      return LinkType.reel;
    }
    
    // Video links
    if (urlLower.contains('youtube.com') ||
        urlLower.contains('youtu.be') ||
        urlLower.contains('vimeo.com') ||
        urlLower.contains('dailymotion.com')) {
      return LinkType.video;
    }
    
    // Article links
    if (urlLower.contains('medium.com') ||
        urlLower.contains('dev.to') ||
        urlLower.contains('hashnode.com') ||
        urlLower.contains('/article') ||
        urlLower.contains('/blog') ||
        urlLower.contains('substack.com')) {
      return LinkType.article;
    }
    
    return LinkType.other;
  }

  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static String extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return '';
    }
  }
}
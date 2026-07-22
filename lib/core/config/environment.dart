enum AppEnvironment { production }

class Environment {
  const Environment._();

  static const current = AppEnvironment.production;

  static String get baseUrl {
    return switch (current) {
      AppEnvironment.production => 'https://ocupa2.ia3x.com/apix',
    };
  }
}

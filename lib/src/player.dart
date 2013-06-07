part of tilebasedwordsearch;

class Player {
  // Simple Authentication class that takes the token from the Sign-in button
  SimpleOAuth2 authenticationContext;

  // Dart Client Library for the Google+ API
  Plus plusclient;

  // Dart Client Library for the Game Playe Services API
  Games gamesclient;

  Player() {
    authenticationContext = new SimpleOAuth2(null);
    plusclient = new Plus(authenticationContext);
    gamesclient = new Games(authenticationContext);
  }

  void signedIn(SimpleOAuth2 authenticationContext) {
    plusclient.makeAuthRequests = true;
    gamesclient.makeAuthRequests = true;
    print("Player is signed in");
  }

  void signedOut() {
    print("Player is signed out");
  }
}
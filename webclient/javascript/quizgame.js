// main entry point for the quizgame client
//
// Responsibilities:
// - collect the player name and other information
// - request questions from cgi-bin/get-question.pl
// - accept player answer input and verify correctness
// - keep a running total of correct answers per game and per player
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"/>

var request = $.ajax({
        type: 'GET',
        url: '../../cgi-bin/get-configs.pl',
      });
request.done(function(res) {
  $("#mybox").html(res);
};
request.fail(function() {
  $("#mybox").html("did not work");
};

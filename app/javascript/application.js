// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
//import "controllers"
//import "bootstrap";

//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require bootstrap
//= require jquery
//= require rails-ujs
//= require_tree .

require("../chat");

$(document).ready(function () {
  $('form').on('submit', function (event) {
    event.preventDefault();
    var form = $(this);

    // Show the progress bar
    $('#progress-bar').show();

    // Make an AJAX request
    $.ajax({
      type: form.attr('method'),
      url: form.attr('action'),
      data: form.serialize(),
      beforeSend: function (xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      },
      success: function (data) {
        // Update the view with the new data (e.g., update the messages)
        // You may need to customize this part based on your application's structure
      },
      error: function (jqXHR, textStatus, errorThrown) {
        console.log('Error: ' + textStatus + ' ' + errorThrown);
      },
      complete: function () {
        // Hide the progress bar when the request is complete
        $('#progress-bar').hide();
      },
    });
  });
});

document.addEventListener("DOMContentLoaded", function () {
  const toggleConversationsButton = document.getElementById("toggle-conversations");
  const previousConversations = document.getElementById("previous-conversations");

  if (toggleConversationsButton && previousConversations) {
    previousConversations.style.display = "none";

    toggleConversationsButton.addEventListener("click", function () {
      if (previousConversations.style.display === "none") {
        previousConversations.style.display = "block";
      } else {
        previousConversations.style.display = "none";
      }
    });
  }
});



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

function copyToClipboard(text) {
  var tempInput = document.createElement('textarea');
  tempInput.style = 'position: absolute; left: -1000px; top: -1000px';
  tempInput.value = text;
  document.body.appendChild(tempInput);
  tempInput.select();
  document.execCommand('copy');
  document.body.removeChild(tempInput);
}


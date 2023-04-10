document.addEventListener("turbolinks:load", function () {
  // Hide the progress bar when the page loads
  $(".progress").hide();

  $("form").on("submit", function () {
    $(".progress").show();
  });
});


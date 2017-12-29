$(function() {
  $('[rel="js--user-name"]').keyup(function() {
    $.get(
      "/users/name_availability",
      { name: $(this).val() }
    )
    .done(function(data) {
      $("#name_available").html(data.text)
    });
  });
});

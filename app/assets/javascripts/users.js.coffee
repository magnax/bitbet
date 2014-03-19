jQuery ->
  $("#user_name").keyup ->
    jQuery.get "/users/name_availability",
      name: $(this).val()
    , (html) ->
      $("#name_available").html html
      return

    return

  return

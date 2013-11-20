$ ->
  $("#alert").hide()

  valid_url = (url)->
    pattern = new RegExp('^(https?:\\/\\/)?'+
      '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|'+
      '((\\d{1,3}\\.){3}\\d{1,3}))'+
      '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+
      '(\\?[;&a-z\\d%_.~+=-]*)?'+
      '(\\#[-a-z\\d_]*)?$','i')

    if !pattern.test(url)
      return false
    else
      return true

  slideshare_url = (url)->
    pattern = new RegExp('slideshare')
    return !!pattern.test(url)
  
  $("#form").submit ->
    input = $('#form input[type="textfield"]').val()
    if valid_url(input)
      if slideshare_url(input)
        $("#alert").removeClass("alert-danger").addClass("alert-info").html("downloading... wait a moment.").show()
        
        return true
      else
        $("#alert").html("URL must be slideshare's.")
    else
      $("#alert").html("Invalid URL.<br />"+input)

    $("#alert").show()
    false
    


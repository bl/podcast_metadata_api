$(document).ready ->
  if $('#podcast_podcast_file').length
    $('#podcast_podcast_file').fileupload
      url: $('#podcast_upload_url').val()
      dataType: 'json'
      done: (e, data) ->
        alert JSON.stringify data
        console.log "DONE: " + JSON.stringify data
      progressall: (e, data) ->
        console.log "PROGRESS: " + JSON.stringify data
        progress = parseInt data.loaded / data.total * 100, 10
        $('#progress .progress-bar').css 'width', progress + '%'

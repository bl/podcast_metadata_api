//$(document).ready(function () {
  //[> only execute if podcast_form exists (on upload.html.erb page) <]
  //if ($('#podcast_podcast_file').length) {
    //$('#podcast_podcast_file').fileupload({
      //url: $('#podcast_upload_url').val(),
      //dataType: 'json',
      //done: function(e, data) {
        //alert(JSON.stringify(data));
        //console.log("DONE: " + JSON.stringify(data));
      //},
      //progressall: function(e, data) {
        //console.log("PROGRESS:" + JSON.stringify(data));
      //}
      //[>submit: function (e, data) {
        //console.log(JSON.stringify(e));
        //console.log(JSON.stringify(data));
        ////data.jqXHR = $(this).fileupload('send', data);

        //// disable default behaviour of submit 
        //return false;
      //}*/
    //}).prop('disabled', !$.support.fileInput)
        //.parent().addClass($.support.fileInput ? undefined : 'disabled');
    //[>$('#podcast_form').bind('add', function(e, data) {
      //console.log(data.formData);
      ////data.submit();
    //});*/
    //[>$('#podcast_upload_form').submit(function() {
      //console.log(JSON.stringify($('#podcast_form').serializeArray()));
      //return false;
      //var request = $.ajax({
        //type: 'GET',
        //url: $('#podcast_post_url').val(),
        //dataType: 'json',
        //beforeSend: function(req) {
          //req.setRequestHeader("Authorization", $('#user_auth_token').val());
        //},
        //data: $('#podcast_form').serializeArray()
      //});
      //request.done(function(msg) {
        //alert("SUCCESS: " + JSON.stringify(msg));
      //});
      //request.fail(function (res) {
        //alert("FAILED: " + JSON.stringify(res));
      //});
      //// disable default behaviour of submit 
      //return false;
    //});*/
  //}

  //[> podcast upload from new.html.erb <]
  //if ($('#podcast_create_form').length) {
    //$('#podcast_create_form').fileupload({
      //type: 'POST'
    //});
    /* perform a get after the initial post (after creating), retrieve the id
     * after the post, then submit the file on that field 
     * TODO: try to avoid sending another get, but rather using the return
     * result from the post 
     * ref: https://github.com/blueimp/jQuery-File-Upload/wiki/Submit-files-asynchronously */
    //$('#podcast_create_form').bind('submit', function (e, data) {
      //$.getJSON($('#podcast_upload_url').val(), function(res) {
        //console.log(data.formData);
      //});

      //// disable default behaviour of submit 
      //return false;
    //});
  //}
//});

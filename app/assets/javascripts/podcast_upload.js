$(document).ready(function() {
  var fileSubmitData = {
    fileNotFoundHandler: function(fileElem) {
      alert("No file provided");
    },
    chunkCompleted: function(fileElem, coptions) {
      console.log(coptions);
      //$(".progress-bar").attr("aria-valuenow", coptions.progress);
      $(".progress-bar").css("width", coptions.progress+'%');
      console.log("Chunk Completed");
    },
    completed: function(fileElem) {
      alert("Finished!");
    },
    failed: function(fileElem) {
      alert("Failed!");
    }
  }

  $(".podcast_file_submit").submit(fileSubmitData, chunkedUpload.formSubmitHandler);
});

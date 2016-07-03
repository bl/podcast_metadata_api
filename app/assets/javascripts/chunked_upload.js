var chunkedUpload = {
  chunkSize: 1024 * 1024,
  // contentType & processData must be disabled when using FormData API
  contentType: false,
  processData: false,
  route: '/upload', // route type to be appended to url
  progress: 0, // number of chunkedUpload ajax sessions in progress

  /**
   * e.data:
   * fileNotFoundHandler: when invalid/no file is provided
   * chunkCompleted: when a chunk has been sucessfully submitted
   * completed: when ajax request for a given form data field has completed
   * failed: when an ajax request for a given form data field failed
   */
  formSubmitHandler: function(e) {
    e.preventDefault();
    // require data block & prevent double clicking
    var data = e.data;
    if (!data || chunkedUpload.progress > 0) {
      return;
    }

    var element = $(e.target)
    var fileElements = element.children(':input[type=file]');
    var ajaxOptions = {
      method: element.attr('method'),
      url: element.attr('action') + chunkedUpload.route,
      contentType: chunkedUpload.contentType,
      processData: chunkedUpload.processData,
    };

    fileElements.each(function(index, elem) {
      // clone data obj for each file element
      var cur_elem_data = jQuery.extend({}, data);
      cur_elem_data.formElement = elem;

      chunkedUpload.initializeSubmit(elem, ajaxOptions, cur_elem_data);
    });
  },

  initializeSubmit: function(fileElement, aoptions, callbacks) {
    var files = fileElement.files;

    if (!files[0]) {
      callbacks.fileNotFoundHandler(fileElement);
      return;
    }

    chunkedUpload.progress++;
    
    var chunkOptions = {
      chunkProgress: 0,
      contentType: fileElement.accept,
      chunkCount: 0,
      file: files[0]
    };

    chunkedUpload.chunkedFileSubmit(chunkOptions, aoptions, callbacks);
  },

  chunkedFileSubmit: function(coptions, aoptions, callbacks) {
    var file = coptions.file;
    if (coptions.chunkProgress == file.size) {
      callbacks.completed(callbacks.formElement);
      chunkedUpload.progress--;
      console.log(chunkedUpload.progress);
      return;
    }

    var chunk_name = file.name + '.part.' + coptions.chunkCount
    var currentChunkSize = ((coptions.chunkProgress + chunkedUpload.chunkSize) > file.size) ? file.size - coptions.chunkProgress : chunkedUpload.chunkSize;
    var chunk = file.slice(coptions.chunkProgress, coptions.chunkProgress + currentChunkSize, coptions.contentType);

    coptions.chunkProgress += currentChunkSize;
    coptions.chunkCount++;

    // submit using FormData API
    var fd = new FormData();
    fd.append('chunk_size', chunk.size);
    fd.append('chunk_progress', coptions.chunkProgress);
    fd.append('total_size', file.size);
    fd.append('chunk_number', coptions.chunkCount);
    fd.append('chunk_data', chunk, file.name);
    
    // final file request
    if (coptions.chunkProgress == file.size) {
      fd.append('completed', true);
    }

    aoptions.data = fd;

    $.ajax(aoptions)
      .done(function(data, status, xhr) {
        chunkedUpload.chunkedFileSubmit(coptions, aoptions, callbacks);
        callbacks.chunkCompleted(callbacks.formElement);
      })
      .fail(function(xhr, status, error) {
        callbacks.failed(callbacks.formElement);
        chunkedUpload.progress--;
      });
  }
}


var Upload = {
    
    files: {},
    count: 0,
    
    prepareSettings: function(session_id) {
      this.settings = {
        flash_url : "/flash/swfupload.swf",
        upload_url: "/upload?_partage_session_id=" + session_id,  // Relative to the SWF file
        file_types : "*.*",
        file_types_description : "All Files",
        file_upload_limit : 100,
        
        // Button settings
        button_placeholder_id: "upload_placeholder",
        button_width: 200,
        button_height: 25,
        button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
        button_cursor: SWFUpload.CURSOR.HAND,

        file_dialog_complete_handler : Upload.fileDialogComplete,
        file_queued_handler: Upload.fileQueued,
        upload_start_handler : Upload.uploadStart,
        upload_progress_handler : Upload.uploadProgress,
        upload_error_handler : Upload.uploadError,
        upload_success_handler : Upload.uploadSuccess,
        upload_complete_handler: Upload.uploadComplete,
        };
    },
    
    initialize: function(sessionId) {
        this.prepareSettings(sessionId)
        this.swfObject = new SWFUpload(this.settings)
        $('a.cancel').live('click', function() {
            li = $(this).parent('li')
            Upload.swfObject.cancelUpload(li.attr('id'))
            delete Upload.files[(li.attr('id'))]
            li.remove()
            Upload.count--
        })
    },
    
    isReadyToComplete: function() {
      if(Upload.count == 0) return false
      stats = this.swfObject.getStats()
      return !stats.in_progress && stats.files_queued == 0
    },
    
    uploadStart: function(file) {
    },
    
    fileQueued: function(file) {
        li = $('<li></li>').attr('id', file.id)
                .append($('<span></span>').addClass('filename').text(file.name))
                .append($('<span></span>').addClass('status'))
                .append($('<a href="#">cancel</a>').addClass('cancel'))
        $('#files').append(li)
        
        Upload.count++
        
        if($('#files li').length > 0) {
            $('#narrative').removeClass('hidden')
            
        }
    },
    
    fileDialogComplete: function(numFilesSelected, numFilesQueued) {
        this.startUpload()
    },
    
    uploadProgress: function(file, bytesLoaded, bytesTotal) {
      try {
        var percent = Math.ceil((bytesLoaded / bytesTotal) * 100);
      $('#' + file.id + ' .status').text( percent + '% uploaded')
      } catch (ex) {
        this.debug(ex);
      }
    },
    
    uploadComplete: function(file) {
        this.startUpload()
    },
    
    uploadError: function(file, errorCode, message) {
    },

    
    uploadSuccess: function(file, serverData) {
        $('#' + file.id + ' .status').text('completed')
        Upload.files[file.id] = eval('(' + serverData + ')')
    },
}
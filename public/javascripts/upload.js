var Upload = {
    
    files: {},
    
    initialize: function() {
        $('a.cancel').live('click', function() {
            $(this).parent('li').remove()
        })
    },
        
    uploadStart: function(file) {
        $('form#complete_upload input[type=submit]').attr('disabled', true)
    },
    
    fileQueued: function(file) {
        li = $('<li></li>').attr('id', file.id)
                .append($('<span></span>').addClass('filename').text(file.name))
                .append($('<span></span>').addClass('status'))
                .append($('<a href="#">cancel</a>').addClass('cancel'))
        $('#files').append(li)
        
        if($('#files li').length > 1) {
            $('#set_options').removeClass('hidden')
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
        stats = Upload.swfObject.getStats()
        if(!stats.in_progress && stats.files_queued == 0) {
            $('form#complete_upload input[type=submit]').attr('disabled', false)
        }
        
        this.startUpload()
    },
    
    uploadError: function(file, errorCode, message) {
    	try {
  		switch (errorCode) {
    		case SWFUpload.UPLOAD_ERROR.HTTP_ERROR:
    			this.debug("Error Code: HTTP Error, File name: " + file.name + ", Message: " + message);
    			break;
    		case SWFUpload.UPLOAD_ERROR.UPLOAD_FAILED:
    			this.debug("Error Code: Upload Failed, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
    			break;
    		case SWFUpload.UPLOAD_ERROR.IO_ERROR:
    			this.debug("Error Code: IO Error, File name: " + file.name + ", Message: " + message);
    			break;
    		case SWFUpload.UPLOAD_ERROR.SECURITY_ERROR:
    			this.debug("Error Code: Security Error, File name: " + file.name + ", Message: " + message);
    			break;
    		case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED:
    			this.debug("Error Code: Upload Limit Exceeded, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
    			break;
    		case SWFUpload.UPLOAD_ERROR.FILE_VALIDATION_FAILED:
    			this.debug("Error Code: File Validation Failed, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
    			break;
    		case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED:
    		case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
    			break;
    		default:
    			this.debug("Error Code: " + errorCode + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
    			break;
    		}
    	} catch (ex) {
            this.debug(ex);
        }
    },

    
    uploadSuccess: function(file, serverData) {
        $('#' + file.id + ' .status').text('completed')
        Upload.files[file.id] = eval('(' + serverData + ')')
    },
}
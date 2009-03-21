var Upload = {
    uploadStart: function(file) {
        $('#status').text('Starting')
    },
    
    fileDialogComplete: function(numFilesSelected, numFilesQueued) {
        $('#status').text(numFilesSelected + ' files chosen')
        this.startUpload()
    },
    
    uploadProgress: function(file, bytesLoaded, bytesTotal) {
    	try {
    		var percent = Math.ceil((bytesLoaded / bytesTotal) * 100);
            $('#status').text( percent + '% uploaded')
    	} catch (ex) {
    		this.debug(ex);
    	}
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
        $('#status').text('completed')
    },
}
package net.simplifiedcoding.imageuploader.MPS

import android.os.Handler
import android.os.Looper
import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName
import net.simplifiedcoding.imageuploader.Package.UploadRequestBody
import okio.BufferedSink
import java.io.FileInputStream

class UserRequest(
){

    @SerializedName("nargout") // value harus sama dengan data reequest ke API
    @Expose
    var nargout: Int? = null

    @SerializedName("rhs")
    @Expose
    var rhs: Array<String?>? = null

}
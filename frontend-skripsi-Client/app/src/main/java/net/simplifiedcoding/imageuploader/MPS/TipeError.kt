package net.simplifiedcoding.imageuploader.MPS

import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName

class TipeError {
    @SerializedName("id")
    @Expose
    var id: String? = null

    @SerializedName("message")
    @Expose
    var message: String? = null

    @SerializedName("stack")
    @Expose
    var stack: List<String?>? = null

    @SerializedName("type")
    @Expose
    var type: String? = null
}
package net.simplifiedcoding.imageuploader.MPS

import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName

class UserResponse {

    @SerializedName("mwdata")
    @Expose
    var mwdata: List<String?>? = null

    @SerializedName("mwsize")
    @Expose
    var mwsize: List<Int>? = null

    @SerializedName("mwtype")
    @Expose
    var mwtype: String? = null


}

package net.simplifiedcoding.imageuploader.MPS

import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName

class Error {
    @SerializedName("error") // value harus sama dengan data response dari API
    @Expose
    var error: List<TipeError?>? = null
}
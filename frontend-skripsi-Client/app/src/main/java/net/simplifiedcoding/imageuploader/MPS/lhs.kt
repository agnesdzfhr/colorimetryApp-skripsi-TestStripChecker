package net.simplifiedcoding.imageuploader.MPS

import com.google.gson.annotations.Expose

import com.google.gson.annotations.SerializedName


class lhs {
    @SerializedName("lhs") // value harus sama dengan data response dari API
    @Expose
    var lhs: List<UserResponse?>? = null


}
package net.simplifiedcoding.imageuploader.MPS

import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.POST

interface UserAPI {
    @POST("ColorimetryAllDTR")
    fun createUser(@Body req: UserRequest): Call<lhs>

}
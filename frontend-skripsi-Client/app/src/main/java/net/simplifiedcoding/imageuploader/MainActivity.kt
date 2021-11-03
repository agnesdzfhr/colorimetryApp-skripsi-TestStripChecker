package net.simplifiedcoding.imageuploader

import android.Manifest
import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import android.view.LayoutInflater
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import kotlinx.android.synthetic.main.activity_main.*
import kotlinx.android.synthetic.main.image_picker.view.*
import net.simplifiedcoding.imageuploader.MPS.UserAPI
import net.simplifiedcoding.imageuploader.MPS.UserRequest
import net.simplifiedcoding.imageuploader.MPS.UserResponse
import net.simplifiedcoding.imageuploader.MPS.lhs
import net.simplifiedcoding.imageuploader.Package.MyAPI
import net.simplifiedcoding.imageuploader.Package.UploadRequestBody
import net.simplifiedcoding.imageuploader.Package.UploadResponse
import okhttp3.MediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.net.URI
import java.text.SimpleDateFormat
import java.util.*


class MainActivity : AppCompatActivity(), UploadRequestBody.UploadCallback{


    private var selectedImageUri: Uri? = null
    private  var imageUri: URI? = null
    private lateinit var  photoPath: String
    private var photoFile: File? = null
    private val permissions = arrayOf(
        "android.permission.WRITE_EXTERNAL_STORAGE",
        "android.permission.READ_EXTERNAL_STORAGE",
        "android.permission.INTERNET",
        "android.permission.CAMERA"
    )

    val REQUEST_IMAGE_CAPTURE = 1
    private val PERMISSION_REQUEST_CODE: Int = 101

    private var mCurrentPhotoPath: String? = null;

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        if(checkPersmission()) {


            // if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            //   requestPermissions(permissions, 0)
            //}

            image_view.setOnClickListener {
                //openImageChooser()

                //inflate the dialog with custom view
                val pickerImg = LayoutInflater.from(this).inflate(R.layout.image_picker, null);
                //AllertDialogBuilder
                val mBuilder = AlertDialog.Builder(this)
                    .setView(pickerImg)
                    .setTitle("Choose")

                //show dialog
                val mAlertDialog = mBuilder.show()
                pickerImg.b_camera.setOnClickListener {
                    if (checkPersmission())
                        openCamera()
                    else requestPermission()
                    mAlertDialog.dismiss()
                }

                pickerImg.b_gallery.setOnClickListener {
                    openGallery()
                    mAlertDialog.dismiss()
                }
            }

            button_upload.setOnClickListener {
                uploadImage();
                // resultMPS()
            }

            button_hasil.setOnClickListener {
                //uploadImage();
                resultMPS()
            }

        }else requestPermission()
    }

    private fun openCamera() {
        val intent: Intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        val file: File = createFile()

        selectedImageUri = FileProvider.getUriForFile(
            this,
            "net.simplifiedcoding.android.fileprovider",
            file
        )

        Log.e("Uri", selectedImageUri.toString())

        //val mimeTypes = arrayOf("image/jpeg", "image/jpg")
        //intent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes)
        //startActivityForResult(intent, 100)

        intent.putExtra(MediaStore.EXTRA_OUTPUT, selectedImageUri)
        startActivityForResult(intent, REQUEST_IMAGE_CAPTURE)
    }


    private fun checkPersmission(): Boolean {
        return (ContextCompat.checkSelfPermission(this, android.Manifest.permission.CAMERA) ==
                PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(this,
            android.Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED)
    }

    private fun requestPermission() {
        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.CAMERA), PERMISSION_REQUEST_CODE)
    }

    @Throws(IOException::class)
    private fun createFile(): File {
        // Create an image file name
        val timeStamp: String = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
        val storageDir: File? = getExternalFilesDir(Environment.DIRECTORY_DCIM)
        return File.createTempFile(
            "IMG_${timeStamp}_", /* prefix */
            ".jpg", /* suffix */
            storageDir /* directory */
        ).apply {
            // Save a file: path for use with ACTION_VIEW intents
            mCurrentPhotoPath = absolutePath
        }
    }


    private  fun openGallery() {
        Intent(Intent.ACTION_PICK).also {
            it.type = "image/*"
            val mimeTypes = arrayOf("image/jpeg", "image/png")
            it.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes)
            startActivityForResult(it, 100)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            PERMISSION_REQUEST_CODE -> {

                if ((grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)
                    && grantResults[1] == PackageManager.PERMISSION_GRANTED) {

                    openCamera()

                } else {
                    Toast.makeText(this, "Permission Denied", Toast.LENGTH_SHORT).show()
                }
                return
            }

            else -> {

            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if(resultCode == Activity.RESULT_OK){
            when(requestCode) {
                100 ->{
                    selectedImageUri = data?.data
                    image_view.setImageURI(selectedImageUri)
                    Log.e("Img Uri", selectedImageUri.toString())
                }
                REQUEST_IMAGE_CAPTURE ->{
                    //To get the File for further usage
                   // val auxFile = File(mCurrentPhotoPath)

                //    val f = File(mCurrentPhotoPath)
                //    val yourUri = Uri.fromFile(f)

                  //  imageUri = auxFile.toURI()

                  //  selectedImageUri = yourUri

                    //selectedImageUri = auxFile.toURI()
                    Log.e("Img Uri", selectedImageUri.toString())

                    var bitmap: Bitmap = BitmapFactory.decodeFile(mCurrentPhotoPath)
                    image_view.setImageBitmap(bitmap)

                }


            }
        }
    }



    companion object{
        private  const val  REQUEST_CODE_IMAGE_PICKER = 100
    }



    private fun uploadImage() {
        if (selectedImageUri == null) {
           // layout_root.snackbar("Select an Image First")
            Toast.makeText(
                this@MainActivity,
                "Select an Image First",
                Toast.LENGTH_LONG
            ).show()
            return
        }

        Log.e("Image URI", selectedImageUri.toString())

        val parcelFileDescriptor =
           contentResolver.openFileDescriptor(selectedImageUri!!, "r", null) ?: return
       //   contentResolver.openFileDescriptor(photoFile, "r", null) ?: return


        val inputStream = FileInputStream(parcelFileDescriptor.fileDescriptor)
        val file = File(cacheDir, contentResolver.getFileName(selectedImageUri!!))
        val outputStream = FileOutputStream(file)
        inputStream.copyTo(outputStream)
        //CATATANNNNNN: IF ELSENYA BUKAN DI OUTPUT STREAM TP DI FILE

     //   val outputStream = FileOutputStream(file)
       // inputStream.copyTo(outputStream)

        //getFileName
       // val imageName = file.name
       // Log.e("ImageName", imageName.toString())

        progress_bar.progress = 0
        val body = UploadRequestBody(file, "image", this)
        MyAPI().uploadImage(
            MultipartBody.Part.createFormData(
                "image",
                file.name,
                body
            ),

           // RequestBody.create(MediaType.parse("multipart/form-data"))
            RequestBody.create(MediaType.parse("multipart/form-data"), "json")
        ).enqueue(object : Callback<UploadResponse> {
            override fun onFailure(call: Call<UploadResponse>, t: Throwable) {
                Toast.makeText(
                    this@MainActivity,
                    "No Database",
                    Toast.LENGTH_SHORT
                ).show()
                progress_bar.progress = 0
            }

            override fun onResponse(
                call: Call<UploadResponse>,
                response: Response<UploadResponse>
            ) {
                response.body()?.let {
                   // layout_root.snackbar(it.data)
                    Toast.makeText(
                        this@MainActivity,
                        it.data,
                        Toast.LENGTH_SHORT
                    ).show()
                    Log.e("Status", it.data)
                    progress_bar.progress = 100
                }
            }
        })


    }



    private fun resultMPS() {
       if (progress_bar.progress == 0) {
            // layout_root.snackbar("Select an Image First")
          Toast.makeText(
               this@MainActivity,
                "Upload Image First",
                Toast.LENGTH_LONG
            ).show()
            return
        }


        var userReq = UserRequest()

        val file = File(cacheDir, contentResolver.getFileName(selectedImageUri!!))
        val imageName = file.name.toString()
         Log.e("ImageName", imageName)
        userReq.nargout = 1
        userReq.rhs = arrayOf(imageName)
        val retro = Retro().getRetroClientInstance("http://192.168.1.11:9910/ColorimetryAllDTR/").create(
            UserAPI::class.java)

        retro.createUser(userReq).enqueue(object : Callback<lhs>{
            //kalo gagal ngambil server
            override fun onFailure(call: Call<lhs>, t: Throwable) {
               // layout_root.snackbar("No Server")
                Log.e("Failed", t.message.toString())
                Toast.makeText(
                    this@MainActivity,
                    "No Server",
                    Toast.LENGTH_LONG
                ).show()
            }

            //kalo berhasil nangkep server
            override fun onResponse(call: Call<lhs>, response: Response<lhs>) {
                val dataArray = response.body()!!.lhs as List<UserResponse>
                //val res = UserResponse().mwdata()
                for (lhs in dataArray) {
                    Log.e("Success", lhs.mwdata.toString());
                    tv_name.text = ("Chlorine Prediction: "+ lhs.mwdata.toString())

                }



            }
        })


    }

    override fun onProgressUpdate(percentage: Int) {
        progress_bar.progress = percentage
    }



}







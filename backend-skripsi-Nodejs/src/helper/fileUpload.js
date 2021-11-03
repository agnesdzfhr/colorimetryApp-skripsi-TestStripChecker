const multer = require("multer");
const { nanoid } = require("nanoid");
const path = require("path");

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "./assets");
  },
  filename: function (req, file, cb) {
    let id = nanoid()
    cb(
      null,
     // id + path.extname(file.originalname)// + 
     file.originalname
      //file.fieldname + path.extname(file.originalname)
      //file.fieldname + "-" + Date.now() + path.extname(file.originalname)
    );
  },
});

const fileUpload = multer({
  storage: storage,
  fileFilter: function (req, file, callback) {
    var ext = path.extname(file.originalname);
    if (
      ext !== ".png" &&
      ext !== ".jpg" &&
      ext !== ".gif" &&
      ext !== ".jpeg" &&
      ext !== ".PNG" &&
      ext !== ".JPEG" &&
      ext !== ".JPG"
    ) {
      return callback(new Error("Only Image Are Allowed"));
    }
    callback(null, true);
  },
  limits: {
    fileSize: 3072 * 3072,
  },
});

module.exports = fileUpload;


const express = require("express");
const Route = express.Router();
const fileUpload = require("../helper/fileUpload");
const upload = fileUpload.single("image");
const helper = require("../helper");
const multer = require("multer");
const { diskStorage } = require("multer");

const uploadFilter = (req, res) => {
  upload(req, res, (err) => {
    if (err instanceof multer.MulterError) {
      console.log(err);
      return helper.response(res, 400, "Failed");
    } else if (err) {
      return helper.response(res, 400, "Doesn't Match");
    }
    return helper.response(res, 200, "Image Uploaded");
  });
};

Route.get("/", (req, res) => {
  return helper.response(res, 200, { message: "wadidaw" });
}).post("/", uploadFilter);
module.exports = Route;

require("dotenv").config();
const express = require("express");
const app = express();
const bodyParser = require("body-parser");
const routerNav = require("./src");
const morgan = require("morgan");
const cors = require("cors");
const port = 3000;

app.use(cors());

app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: true,
  })
);

app.use(morgan("dev"));

app.use(express.static("assets/"));

app.listen(port, function () {
  console.log("Listening on Port : ", port);
});

app.use("/", routerNav);

// app.use("/", async (req, res) => {
//   return res.json({ msg: "bisa" });
// });

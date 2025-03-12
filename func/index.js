const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

admin.initializeApp();

exports.importData = functions.https.onRequest((req, res) => {
  const jsonFilePath = path.join(__dirname, "data", "readcomp.json");
  const data = JSON.parse(fs.readFileSync(jsonFilePath, "utf8"));

  const batch = admin.firestore().batch();

  data.modules.forEach((module) => {
    const docRef = admin.firestore()
        .collection("fields")
        .doc("Reading Comprehension")
        .collection("modules")
        .doc(module.title);
    batch.set(docRef, module);
  });

  return batch.commit().then(() => {
    res.send("Data imported successfully!");
  }).catch((error) => {
    console.error("Error importing data: ", error);
    res.status(500).send("Error importing data");
  });
});

const admin = require("firebase-admin");
const { onRequest } = require("firebase-functions/v2/https");
const { v4: uuidv4 } = require("uuid");

// IMPORTANT:
// This project uses the newer Firebase Storage bucket domain (`*.firebasestorage.app`).
// If we don't set this explicitly, the Admin SDK may default to the legacy `*.appspot.com` bucket.
admin.initializeApp({
  storageBucket: "utsavframeai.firebasestorage.app"
});

const allowedOrigins = [
  "https://utsavframeai.web.app",
  "https://utsavframeai.firebaseapp.com",
  "http://localhost:5000",
  "http://localhost:3000",
  "http://localhost:8080"
];

exports.uploadTemplateBackground = onRequest(
  {
    region: "asia-south1",
    cors: allowedOrigins,
    maxInstances: 10
  },
  async (req, res) => {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method not allowed" });
    }

    try {
      const { templateId, bytesBase64, contentType } = req.body || {};
      if (!templateId || typeof templateId !== "string") {
        return res.status(400).json({ error: "templateId is required" });
      }
      if (!bytesBase64 || typeof bytesBase64 !== "string") {
        return res.status(400).json({ error: "bytesBase64 is required" });
      }

      const buffer = Buffer.from(bytesBase64, "base64");
      const bucket = admin.storage().bucket();
      const objectPath = `templates/${templateId}/background.jpg`;
      const file = bucket.file(objectPath);

      const token = uuidv4();
      await file.save(buffer, {
        resumable: false,
        metadata: {
          contentType: contentType || "image/jpeg",
          metadata: {
            firebaseStorageDownloadTokens: token
          }
        }
      });

      const encodedPath = encodeURIComponent(objectPath);
      const bucketName = bucket.name;
      const downloadUrl = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodedPath}?alt=media&token=${token}`;

      return res.status(200).json({ downloadUrl });
    } catch (e) {
      console.error(e);
      return res.status(500).json({ error: String(e) });
    }
  }
);

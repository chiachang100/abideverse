// scripts/upload_to_firestore.js
const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const serviceAccount = require("../serviceAccountKey.json");

// Initialize Firebase Admin
initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();

// Your markdown content - read from files or paste directly
const resources = {
  awesome_references: {
    titleKey: "mdAwesomeReferences",
    descriptionKey: "mdAwesomeReferencesDesc",
    iconName: "stars",
    colorValue: 0xffffc107,
    displayOrder: 1,
    isActive: true,
    markdownContent: "# Awesome References\n\nYour content here...",
    updatedAt: new Date(),
  },
  about: {
    titleKey: "mdAboutAbideVerse",
    descriptionKey: "mdAboutAbideVerseDesc",
    iconName: "info_outline",
    colorValue: 0xff2196f3,
    displayOrder: 2,
    isActive: true,
    markdownContent: "# About AbideVerse\n\nYour content here...",
    updatedAt: new Date(),
  },
  acknowledgments: {
    titleKey: "mdAcknowledgments",
    descriptionKey: "mdAcknowledgmentsDesc",
    iconName: "favorite_outline",
    colorValue: 0xff4caf50,
    displayOrder: 3,
    isActive: true,
    markdownContent: "# Acknowledgments\n\nYour content here...",
    updatedAt: new Date(),
  },
  study_guides: {
    titleKey: "mdStudyGuides",
    descriptionKey: "mdStudyGuidesDesc",
    iconName: "book_outlined",
    colorValue: 0xff9c27b0,
    displayOrder: 4,
    isActive: true,
    markdownContent: "# Study Guides\n\nYour content here...",
    updatedAt: new Date(),
  },
  licenses: {
    titleKey: "mdOpenSourceLicenses",
    descriptionKey: "mdOpenSourceLicensesDesc",
    iconName: "code",
    colorValue: 0xff9e9e9e,
    displayOrder: 5,
    isActive: true,
    markdownContent: "# Open Source Licenses\n\nYour content here...",
    updatedAt: new Date(),
  },
};

async function uploadData() {
  try {
    console.log("Starting upload to Firestore...");

    for (const [id, data] of Object.entries(resources)) {
      await db.collection("resources").doc(id).set(data);
      console.log(`✓ Uploaded: ${id}`);
    }

    console.log("\n✅ All resources uploaded successfully!");
  } catch (error) {
    console.error("❌ Error uploading:", error);
  }
}

uploadData();

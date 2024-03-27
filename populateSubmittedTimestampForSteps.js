const admin = require('firebase-admin');

// Replace this with the path to your Firebase Admin SDK private key
const serviceAccount = require('/Users/jeremydaines/Documents/goals-8509a-firebase-adminsdk-6zt3m-b333cb27d0.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function populateSubmittedTimestampForSteps() {
  try {
    // Fetch steps where isSubmitted is true
    const stepsSnapshot = await db.collection('steps').where('isSubmitted', '==', true).get();

    for (const stepDoc of stepsSnapshot.docs) {
      // Fetch all evidences, since we're avoiding creating a compound index
      const evidencesSnapshot = await db.collection('evidences').get();

      // Filter evidences for the current step and sort them to find the latest one
      const relatedEvidences = evidencesSnapshot.docs
        .map(doc => ({ id: doc.id, ...doc.data() }))
        .filter(evidence => evidence.stepID === stepDoc.id)
        .sort((a, b) => b.timestamp - a.timestamp); // Sort by timestamp in descending order

      if (relatedEvidences.length > 0) {
        const latestEvidence = relatedEvidences[0]; // Take the first item after sorting as the latest

        // Update the step with the latest evidence's timestamp
        await db.collection('steps').doc(stepDoc.id).update({ submittedTimestamp: latestEvidence.timestamp });
        console.log(`Updated step ${stepDoc.id} with submittedTimestamp from evidence ${latestEvidence.id}`);
      } else {
        console.log(`No evidence found for step ${stepDoc.id}`);
      }
    }
    console.log('Completed updating submittedTimestamp for all submitted steps.');
  } catch (error) {
    console.error("Error updating steps:", error);
  }
}

populateSubmittedTimestampForSteps();

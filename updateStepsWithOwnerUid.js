const admin = require('firebase-admin');

// Replace this with the path to your Firebase Admin SDK private key
const serviceAccount = require('/Users/jeremydaines/Documents/goals-8509a-firebase-adminsdk-6zt3m-b333cb27d0.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function addOwnerUidToSteps() {
  try {
    const goalsSnapshot = await db.collection('goals').get();

    for (const goalDoc of goalsSnapshot.docs) {
      const goalData = goalDoc.data();
      const ownerUid = goalData.ownerUid;

      // Fetch related steps
      const stepsSnapshot = await db.collection('steps').where('goalID', '==', goalDoc.id).get();

      for (const stepDoc of stepsSnapshot.docs) {
        // Update each step with ownerUid
        await db.collection('steps').doc(stepDoc.id).update({ ownerUid: ownerUid });
        console.log(`Updated step ${stepDoc.id} with ownerUid ${ownerUid}`);
      }
    }
    console.log('Completed updating all steps with ownerUid.');
  } catch (error) {
    console.error("Error updating steps:", error);
  }
}

addOwnerUidToSteps();

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendUserNotification = functions.firestore
    .document('activity/{userId}/user-notifications/{notificationId}')
    .onCreate(async (snapshot, context) => {
        const { userId } = context.params;
        const activity = snapshot.data();
        const senderUid = activity.senderUid;

        // Fetch additional details: sender's name, goal's name (if applicable)
        const senderSnapshot = await admin.firestore().collection('users').doc(senderUid).get();
        const senderName = senderSnapshot.data()?.username; // Assuming the user document has a 'name' field

        let goalName = "";
        if (activity.goalId) {
            const goalSnapshot = await admin.firestore().collection('goals').doc(activity.goalId).get();
            goalName = goalSnapshot.data()?.username; // Assuming the goal document has a 'name' field
        }

        // Construct notification message based on ActivityType
        let title = "";
        let body = "";
        switch (activity.type) {
            case 'friendGoal':
                title = `${senderName} has created a new goal!`;
                body = `They started ${goalName} today`;
                break;
            case 'partnerGoal':
                title = `${senderName} has assigned you as a partner!`;
                body = `They started ${goalName} today`;
                break;
            case 'friend':
                title = `${senderName} has added you as a friend!`;
                break;
            case 'evidence':
                title = `${senderName} has uploaded evidence!`;
                body = `For ${goalName}`;
                break;
            default:
                console.log(`Unhandled activity type: ${activity.type}`);
                return null;
        }

        // Fetch the user's FCM token from the 'users' collection
        const userRef = admin.firestore().collection('users').doc(userId);
        const userSnapshot = await userRef.get();
        const fcmToken = userSnapshot.data()?.fcmToken;

        if (!fcmToken) {
            console.log(`No FCM token found for user ${userId}`);
            return null;
        }

        // Send the notification
        const message = {
            notification: { title, body },
            token: fcmToken,
        };

        try {
            const response = await admin.messaging().send(message);
            console.log('Successfully sent message:', response);
            return response;
        } catch (error) {
            console.error('Error sending message:', error);
            return null;
        }
    });

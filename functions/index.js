const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendUserNotification = functions.firestore
.document('activity/{userId}/user-notifications/{notificationId}')
.onCreate(async (snapshot, context) => {
    const userId = context.params.userId;
    const activity = snapshot.data();
    
    console.log(`Activity received: `, activity);
    
    let goalTitle = ''; // Placeholder for goal title
    if (activity.goalId) {
        try {
            // Fetch the goal document using the goalId from the activity
            const goalRef = admin.firestore().collection('goals').doc(activity.goalId);
            const goalSnapshot = await goalRef.get();
            const goal = goalSnapshot.data();
            goalTitle = goal ? goal.title : 'a goal'; // Use the goal title or a fallback string
        } catch (error) {
            console.error(`Error fetching goal: ${error}`);
            // Optionally, handle the error, for example by using a default title
            goalTitle = 'a goal';
        }
    }
    
    // Fetch the sender's user details using senderUid
    const senderRef = admin.firestore().collection('users').doc(activity.senderUid);
    const senderSnapshot = await senderRef.get();
    const sender = senderSnapshot.data();
    
    if (!sender) {
        console.log(`Sender details not found for ID ${activity.senderUid}`);
        return null;
    }
    
    console.log(`Sender username: ${sender.username}`);
    
    // Here, construct your activityMessage as before, based on the activity.type
    let activityMessage = 'You have a new notification.';
    // Adjusted switch statement with block scopes
    switch (activity.type) {
        case 0: {
            const reactionTypeText = activity.reactionType || 'Reacted';
            activityMessage = `Reacted ${reactionTypeText} to one of your goals`;
            console.log(`Activity message for friend: ${activityMessage}`);
            break;
        }
        case 1: {
            activityMessage = `Started a new goal: ${goalTitle}`;
            console.log(`Activity message for goal: ${activityMessage}`);
            break;
        }
        case 2: {
            activityMessage = `Assigned you as Phylax to their goal: ${goalTitle}`;
            console.log(`Activity message for goal: ${activityMessage}`);
            break;
        }
        case 3: {
            activityMessage = 'Added you as a friend';
            console.log(`Activity message for friend: ${activityMessage}`);
            break;
        }
        case 4: {
            activityMessage = `Submitted evidence for ${goalTitle}`;
            console.log(`Activity message for friend: ${activityMessage}`);
            break;
        }
        case 5: {
            activityMessage = `Verified evidence for ${goalTitle}`;
            console.log(`Activity message for friend: ${activityMessage}`);
            break;
        }
        case 6: {
            activityMessage = `Accepted your friend request!`;
            console.log(`Activity message for friend: ${activityMessage}`);
            break;
        }
        default: {
            console.log(`Unhandled activity type: ${activity.type}`); // Debug log for unhandled types
        }
    }
    
    const userRef = admin.firestore().collection('users').doc(userId);
    const userSnapshot = await userRef.get();
    const user = userSnapshot.data();
    
    if (!user || !user.fcmToken) {
        console.log(`No FCM token found for user ${userId}`);
        return null;
    }
    
    const message = {
    notification: {
    title: sender.username || 'New Activity', // Use the sender's username as title
    body: activityMessage,
    },
    token: user.fcmToken,
    };
    
    console.log(`Sending message: `, message);
    
    try {
        const response = await admin.messaging().send(message);
        console.log('Successfully sent message:', response);
        return response;
    } catch (error) {
        console.error('Error sending message:', error);
        throw new functions.https.HttpsError('unknown', `Failed to send notification: ${error.message}`);
    }
});



// eslint-disable-next-line no-unused-vars
exports.checkStepDeadlines = functions.pubsub.schedule('every 1 hours').onRun(async (context) => {
    // Current date and time
    const now = new Date();
    const goalsRef = admin.firestore().collection('goals');

    // Reference to the steps collection
    const stepsRef = admin.firestore().collection('steps');

    // Fetch all steps that have not been submitted
    const stepsSnapshot = await stepsRef.where('isSubmitted', '==', false).get();

    stepsSnapshot.forEach(async (doc) => {
        const step = doc.data();
        const stepDeadline = step.deadline.toDate(); // Convert Firestore Timestamp to JavaScript Date

        // Calculate the time difference between now and the step's deadline
        const timeDiff = stepDeadline.getTime() - now.getTime();
        // Convert time difference to hours
        const hoursDiff = timeDiff / (1000 * 60 * 60);

        // Check if the deadline is exactly 15 hours from now
        if (hoursDiff <= 15 && hoursDiff > 14) {
            // Fetch the goal title
            const goalSnapshot = await goalsRef.doc(step.goalID).get();
            const goal = goalSnapshot.data();

            if (!goal) {
                console.log(`Goal details not found for ID ${step.goalID}`);
                return null;
            }

            const goalTitle = goal.title;

            // Lookup the user associated with the step
            const userRef = admin.firestore().collection('users').doc(step.ownerUid);
            const userSnapshot = await userRef.get();
            const user = userSnapshot.data();

            // If the user has an FCM token, send them a notification
            if (user && user.fcmToken) {
                const message = {
                    notification: {
                        title: goalTitle,
                        body: `Last day to submit evidence for Day ${step.dayNumber}.`,
                    },
                    token: user.fcmToken,
                };

                admin.messaging().send(message).then((response) => {
                    console.log('Successfully sent message:', response);
                }).catch((error) => {
                    console.error('Error sending message:', error);
                });
            }
        }
    });
});

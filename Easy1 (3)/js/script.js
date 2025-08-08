import { auth, db } from './firebase.js';
import { onAuthStateChanged, signOut } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';

const userNameSpan = document.getElementById("user-firstname");
const userAvatar = document.getElementById("user-avatar");

onAuthStateChanged(auth, async (user) => {
    if (user) {
        try {
            const docRef = doc(db, "Users", user.uid); // ✅ Corrected collection name
            const docSnap = await getDoc(docRef);

            if (docSnap.exists()) {
                const userData = docSnap.data();
                const firstName = userData.firstName || "User";
                userNameSpan.textContent = firstName;
                userAvatar.textContent = firstName.charAt(0).toUpperCase();
            } else {
                console.log("❌ User doc not found in Firestore.");
            }
        } catch (err) {
            console.error("🔥 Error fetching Firestore user data:", err);
        }
    } else {
        console.log("ℹ️ No user signed in.");
    }
});

window.signOut = () => {
    signOut(auth).then(() => {
        location.reload();
    });
};

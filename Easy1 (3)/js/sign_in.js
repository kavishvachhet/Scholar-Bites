import { signInWithEmailAndPassword } from "firebase/auth";
import { auth } from "./firebase.js";

document.getElementById("auth-submit-btn").addEventListener("click", async () => {
  const email = document.getElementById("email").value;
  const password = document.getElementById("password").value;
  const action = document.getElementById("auth-submit-btn").textContent.trim().toLowerCase();

  if (action === "sign in") {
    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;

      // Hide login section, show user and character form
      document.getElementById("login-section").classList.add("hidden");
      document.getElementById("user-section").classList.remove("hidden");
      document.querySelector(".main-content").classList.remove("hidden");

      // Set user info
      document.getElementById("user-name").textContent = `Welcome back, ${user.email.split('@')[0]}!`;

      window.closeAuthModal(); // Close modal
    } catch (error) {
      alert("Sign-in failed: " + error.message);
    }
  }
});

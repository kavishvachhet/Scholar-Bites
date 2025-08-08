console.log("sign_up.js loaded");

import { initializeApp } from "firebase/app";
import { getAuth, createUserWithEmailAndPassword } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyCYI3WQ9-peR0HEPxhrxCrsAEg2wn9QoDY",
  authDomain: "character-generator-75fdf.firebaseapp.com",
  projectId: "character-generator-75fdf",
  storageBucket: "character-generator-75fdf.firebasestorage.app",
  messagingSenderId: "233443409399",
  appId: "1:233443409399:web:d6757f2a53db4388bc82f2",
  measurementId: "G-F8TEK5KSNV",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
console.log("Firebase initialized:", app);
const auth = getAuth(app);

// Signup Function
async function handleSignUp() {
  console.log("handleSignUp called");
  const email = document.getElementById("email").value.trim();
  const password = document.getElementById("password").value;
  const confirmPassword = document.getElementById("confirm-password").value;
  const messageContainer = document.getElementById("message-container");

  messageContainer.innerHTML = "";

  if (password !== confirmPassword) {
    messageContainer.innerHTML = "<p style='color:red;'>Passwords do not match!</p>";
    return;
  }

  try {
    const userCredential = await createUserWithEmailAndPassword(auth, email, password);
    const user = userCredential.user;
    console.log("User signed up:", user);
    messageContainer.innerHTML = `<p style="color:green;">Signup successful for ${user.email}!</p>`;
  } catch (error) {
    console.error("Signup failed:", error);
    messageContainer.innerHTML = `<p style="color:red;">${error.message}</p>`;
  }
}

// Attach event listener to form
document.addEventListener("DOMContentLoaded", () => {
  console.log("DOM loaded");
  document.getElementById("auth-form").addEventListener("submit", async (event) => {
    event.preventDefault();
    console.log("Form submitted");
    await handleSignUp();
  });
});

// Close modal function
window.closeAuthModal = function () {
  console.log("closeAuthModal called");
  document.getElementById("auth-modal").classList.remove("active");
};

// Test message container
document.getElementById("message-container").innerHTML = "<p style='color:blue;'>Test message</p>";
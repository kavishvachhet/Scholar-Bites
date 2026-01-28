import { initializeApp } from "https://www.gstatic.com/firebasejs/11.3.1/firebase-app.js";
    import { getAuth, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/11.3.1/firebase-auth.js";
    import { getFirestore, doc, getDoc } from "https://www.gstatic.com/firebasejs/11.3.1/firebase-firestore.js";

    const firebaseConfig = {
      apiKey: "AIzaSyCYI3WQ9-peR0HEPxhrxCrsAEg2wn9QoDY",
      authDomain: "character-generator-75fdf.firebaseapp.com",
      projectId: "character-generator-75fdf",
      storageBucket: "character-generator-75fdf.appspot.com",
      messagingSenderId: "233443409399",
      appId: "1:233443409399:web:d6757f2a53db4388bc82f2",
      measurementId: "G-F8TEK5KSNV"
    };

    const app = initializeApp(firebaseConfig);
    const auth = getAuth(app);
    const db = getFirestore(app);

    // Add loading state management
    let userDataLoaded = false;

    onAuthStateChanged(auth, async (user) => {
      console.log("Auth state changed:", user ? "User logged in" : "User logged out");
      
      if (user) {
        console.log("User UID:", user.uid);
        
        try {
          // Set loading state
          document.getElementById("user-firstname").innerText = "Loading...";
          document.getElementById("user-avatar").innerText = "...";
          
          const docRef = doc(db, "Users", user.uid);
          console.log("Attempting to fetch document for UID:", user.uid);
          
          const docSnap = await getDoc(docRef);
          
          if (docSnap.exists()) {
            const userDetails = docSnap.data();
            console.log("User data from Firestore:", userDetails);

            const firstName = userDetails.firstName || user.displayName || "User";
            const lastName = userDetails.lastName || "";
            
            document.getElementById("user-firstname").innerText = firstName;
            document.getElementById("user-avatar").innerText = firstName[0].toUpperCase();
            
            userDataLoaded = true;
            console.log("User data loaded successfully");
          } else {
            console.log("No document found for UID:", user.uid);
            // Fallback to auth user data
            const fallbackName = user.displayName || user.email?.split('@')[0] || "User";
            document.getElementById("user-firstname").innerText = fallbackName;
            document.getElementById("user-avatar").innerText = fallbackName[0].toUpperCase();
            
            userDataLoaded = true;
          }
        } catch (error) {
          console.error("Error getting user data:", error);
          console.error("Error details:", error.code, error.message);
          
          // Fallback to auth user data
          const fallbackName = user.displayName || user.email?.split('@')[0] || "User";
          document.getElementById("user-firstname").innerText = fallbackName;
          document.getElementById("user-avatar").innerText = fallbackName[0].toUpperCase();
          
          userDataLoaded = true;
        }
      } else {
        console.log("User not signed in - redirecting to sign in");
        // Redirect to sign in page if not authenticated
        window.location.href = "signin.html";
      }
    });

    // Enhanced sign out function
    window.signOut = async () => {
      try {
        await signOut(auth);
        console.log("User signed out successfully");
        window.location.href = "signin.html";
      } catch (error) {
        console.error("Sign-out error:", error);
        alert("Error signing out. Please try again.");
      }
    };

    // Wait for DOM to load before setting up event listeners
    document.addEventListener('DOMContentLoaded', function() {
      // Add your form submission and other event listeners here
      const characterForm = document.getElementById('character-form');
      if (characterForm) {
        characterForm.addEventListener('submit', handleFormSubmit);
      }
    });

    // Character form submission handler
    async function handleFormSubmit(e) {
      e.preventDefault();
      
      // Check if user is authenticated
      if (!auth.currentUser) {
        alert("Please sign in to create characters");
        return;
      }
      
      // Get form data
      const formData = new FormData(e.target);
      const characterData = {
        name: formData.get('name'),
        universe: formData.get('universe'),
        backstory: formData.get('backstory'),
        powers: formData.get('powers'),
        weaknesses: formData.get('weaknesses'),
        fights: formData.get('fights'),
        userId: auth.currentUser.uid,
        createdAt: new Date()
      };
      
      console.log("Character data:", characterData);
      
      // Here you would typically save to Firestore
      // For now, just show success message
      showMessage("Character created successfully!", "success");
      
      // Reset form
      e.target.reset();
    }

    // Message display function
    function showMessage(message, type = 'info') {
      const messageContainer = document.getElementById('message-container');
      if (messageContainer) {
        messageContainer.textContent = message;
        messageContainer.className = `message ${type}`;
        messageContainer.style.display = 'block';
        
        setTimeout(() => {
          messageContainer.style.display = 'none';
        }, 3000);
      }
    }

    // Make functions available globally
    window.showMessage = showMessage;
    window.handleFormSubmit = handleFormSubmit;
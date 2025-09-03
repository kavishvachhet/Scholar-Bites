import { GoogleGenAI } from 'https://esm.run/@google/genai';
import { initializeApp } from "https://www.gstatic.com/firebasejs/11.3.1/firebase-app.js";
import { getAuth, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/11.3.1/firebase-auth.js";
import { getFirestore, doc, getDoc, collection, addDoc, updateDoc, getDocs, deleteDoc } from "https://www.gstatic.com/firebasejs/11.3.1/firebase-firestore.js";

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

// Global variable to store current character data for regeneration
let currentCharacterData = null;

// Toast/Message Display
function showMessage(message, type = 'info') {
  const messageContainer = document.getElementById('message-container');
  if (messageContainer) {
    messageContainer.textContent = message;
    messageContainer.className = `message ${type}`;
    messageContainer.style.display = 'block';
    setTimeout(() => { messageContainer.style.display = 'none'; }, 5000);
  }
}
window.showMessage = showMessage;

// Loading state management
function setLoading(isLoading) {
  const submitBtn = document.getElementById('submit-btn');
  const submitText = document.getElementById('submit-text');
  if (submitBtn && submitText) {
    submitBtn.disabled = isLoading;
    submitText.textContent = isLoading ? 'Generating Story...' : 'Create Character & Generate Story';
  }
}

function setupImageUpload() {
  const imageInput = document.getElementById('image');
  const imagePreview = document.getElementById('image-preview');
  const imagePreviewImg = document.getElementById('imagePreview');
  const imageURLInput = document.getElementById('imageURL');

  if (imageInput) {
    imageInput.addEventListener('change', handleImageUpload);
  }
}

function handleImageUpload(event) {
  const file = event.target.files[0];
  const imagePreview = document.getElementById('image-preview');
  const imagePreviewImg = document.getElementById('imagePreview');
  const imageURLInput = document.getElementById('imageURL');

  if (file) {
    // Check file size (limit to 5MB)
    if (file.size > 5 * 1024 * 1024) {
      showMessage("Image size should be less than 5MB", "error");
      event.target.value = '';
      return;
    }

    // Check file type
    if (!file.type.startsWith('image/')) {
      showMessage("Please select a valid image file", "error");
      event.target.value = '';
      return;
    }

    // Create FileReader to convert image to base64
    const reader = new FileReader();
    reader.onload = function (e) {
      const base64String = e.target.result;

      // Show preview
      if (imagePreviewImg) {
        imagePreviewImg.src = base64String;
        imagePreviewImg.style.display = 'block';
      }
      if (imagePreview) {
        imagePreview.classList.remove('hidden');
      }

      // Store base64 in hidden input
      if (imageURLInput) {
        imageURLInput.value = base64String;
      }

      showMessage("Image uploaded successfully!", "success");
    };

    reader.onerror = function () {
      showMessage("Error reading image file", "error");
    };

    reader.readAsDataURL(file);
  }
}

// Auth State Listener
onAuthStateChanged(auth, async (user) => {
  if (!user) {
    console.warn("User not signed in.");
    window.location.href = "signin.html";
    return;
  }

  console.log("User signed in:", user.uid);

  try {
    const userRef = doc(db, "Users", user.uid);
    const userSnap = await getDoc(userRef);
    const fallbackName = user.displayName || user.email?.split('@')[0] || "User";
    const firstName = userSnap.exists() ? userSnap.data().firstName || fallbackName : fallbackName;

    const userFirstNameElement = document.getElementById("user-firstname");
    const userAvatarElement = document.getElementById("user-avatar");
    
    if (userFirstNameElement) {
      userFirstNameElement.innerText = firstName;
    }
    if (userAvatarElement) {
      userAvatarElement.innerText = firstName[0].toUpperCase();
    }

    // Update character statistics when user is loaded
    updateCharacterStats();
  } catch (error) {
    console.error("Error fetching user data:", error);
    showMessage("Error fetching user info", "error");
  }
});

// Sign Out
window.signOut = async () => {
  try {
    await signOut(auth);
    window.location.href = "signin.html";
  } catch (error) {
    console.error("Error signing out:", error);
    showMessage("Failed to sign out.", "error");
  }
};

// Local Story Generation Function with Gemini 2.5 Flash
const ai = new GoogleGenAI({
  apiKey: 'AIzaSyAnhRO61f0InhX7NcGxcG_0ZP0n_clcZ5w'
});

async function generateStoryLocal(name, universe, backstory, powers, weaknesses, fights) {
  const prompt = `Create an epic fantasy or sci-fi story about a character, (make sure the story is interesting and the language is in simple leman terms):
- Name: ${name}
- Universe: ${universe}
- Backstory: ${backstory}
- Powers/Abilities: ${powers}
- Weaknesses: ${weaknesses}
- Notable Conflicts: ${fights}

Make the story thrilling, emotional, and cinematic. Limit the story to exactly 75 words.`;

  try {
    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: prompt,
    });

    return response.text;
  } catch (error) {
    throw new Error(`Story generation failed: ${error.message}`);
  }
}

// Handle Form Submit
async function handleFormSubmit(e) {
  e.preventDefault();
  setLoading(true);

  if (!auth.currentUser) {
    showMessage("Please sign in.", "error");
    setLoading(false);
    return;
  }

  const formData = new FormData(e.target);
  const name = formData.get("name")?.trim();
  const title = formData.get("title")?.trim(); // Added title
  let universe = formData.get("universe")?.trim() || "";
  if (universe === "Custom") {
    universe = formData.get("customUniverse")?.trim() || "Custom Universe";
  }
  const backstory = formData.get("backstory")?.trim();
  const motivation = formData.get("motivation")?.trim(); // Added motivation
  const powers = formData.get("powers")?.trim();
  const weaknesses = formData.get("weaknesses")?.trim();
  const fights = formData.get("fights")?.trim();
  const imageURL = formData.get("imageURL")?.trim() || "";

  if (!name || !title || !universe || !backstory || !motivation || !powers || !weaknesses || !fights || !imageURL) {
    showMessage("Please fill in all required fields.", "error");
    setLoading(false);
    return;
  }

  console.log("Form data collected:", { name, title, universe, backstory, motivation, powers, weaknesses, fights, imageURL });

  try {
    const generatedStory = await generateStoryLocal(name, universe, backstory, powers, weaknesses, fights);

    const characterData = {
      name,
      title,
      universe,
      backstory,
      motivation,
      powers,
      weaknesses,
      fights,
      story: generatedStory,
      imageURL,
      userId: auth.currentUser.uid,
      createdAt: new Date(),
      storyGenerated: true,
      storyGeneratedAt: new Date()
    };

    const charRef = collection(db, "Users", auth.currentUser.uid, "characters");
    const docRef = await addDoc(charRef, characterData);
    console.log("Character saved with ID:", docRef.id);

    currentCharacterData = {
      ...characterData,
      docId: docRef.id
    };

    const storyCharacterName = document.getElementById('story-character-name');
    const storyCharacterUniverse = document.getElementById('story-character-universe');
    const storyContent = document.getElementById('story-content');
    const storySection = document.getElementById('story-section');

    if (storyCharacterName) {
      storyCharacterName.textContent = name;
    }
    if (storyCharacterUniverse) {
      storyCharacterUniverse.textContent = universe;
    }
    if (storyContent) {
      storyContent.textContent = generatedStory;
    }
    if (storySection) {
      storySection.classList.remove('hidden');
    }

    showMessage(`Character "${name}" created and story generated successfully!`, "success");
    window.location.href = "explore.html";

    resetForm();
    
    // Reset wizard to step 1 if currentStep exists
    if (typeof currentStep !== 'undefined') {
      currentStep = 1;
      if (typeof showStep === 'function') {
        showStep(currentStep);
      }
    }
    
    updateCharacterStats();

  } catch (error) {
    console.error("Error in form submission:", error);
    showMessage(`Error creating character: ${error.message}`, "error");
  } finally {
    setLoading(false);
  }
}

// Attach form submit handler
document.addEventListener('DOMContentLoaded', () => {
  setupImageUpload();

  const form = document.getElementById("character-form");
  if (form) {
    form.addEventListener("submit", handleFormSubmit);
  }
});



// Function to update character statistics
async function updateCharacterStats() {
  if (!auth.currentUser) {
    return;
  }

  try {
    const charactersRef = collection(db, "Users", auth.currentUser.uid, "characters");
    const charactersSnapshot = await getDocs(charactersRef);
    const totalCharacters = charactersSnapshot.size;

    // Count unique universes
    const universes = new Set();
    charactersSnapshot.forEach((doc) => {
      const data = doc.data();
      if (data.universe) {
        universes.add(data.universe);
      }
    });

    // Update the UI only if elements exist
    const totalCharactersElement = document.getElementById('total-characters');
    const universesCountElement = document.getElementById('universes-count');
    const charactersGrid = document.getElementById('characters-grid');

    if (totalCharactersElement) {
      totalCharactersElement.textContent = totalCharacters;
    }
    if (universesCountElement) {
      universesCountElement.textContent = universes.size;
    }

    console.log(`Total characters: ${totalCharacters}, Universes: ${universes.size}`);

    // Update characters grid if it exists
    if (charactersGrid) {
      if (totalCharacters === 0) {
        charactersGrid.innerHTML = '<div class="loading">No characters yet. Create your first character!</div>';
      } else {
        loadcharacters();
      }
    }
  } catch (error) {
    console.error("Error fetching character stats:", error);
    const charactersGrid = document.getElementById('characters-grid');
    if (charactersGrid) {
      charactersGrid.innerHTML = '<div class="loading">Error loading characters. Please try again.</div>';
    }
  }
}

// Additional utility functions
function resetForm() {
  const form = document.getElementById('character-form');
  if (form) {
    form.reset();
  }

  // Reset image preview
  const imagePreview = document.getElementById('image-preview');
  const imagePreviewImg = document.getElementById('imagePreview');
  const imageURLInput = document.getElementById('imageURL');

  if (imagePreview) {
    imagePreview.classList.add('hidden');
  }
  if (imagePreviewImg) {
    imagePreviewImg.style.display = 'none';
    imagePreviewImg.src = '';
  }
  if (imageURLInput) {
    imageURLInput.value = '';
  }
}


// Updated regenerateStory function that calls generateStoryLocal




function closeModal() {
  const characterModal = document.getElementById('character-modal');
  if (characterModal) {
    characterModal.classList.add('hidden');
  }
}

// Make functions globally available
window.resetForm = resetForm;
window.closeModal = closeModal;

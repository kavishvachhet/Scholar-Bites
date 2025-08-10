import { GoogleGenerativeAI } from 'https://esm.run/@google/generative-ai';
import { initializeApp } from "https://www.gstatic.com/firebasejs/11.3.1/firebase-app.js";
import { getAuth, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/11.3.1/firebase-auth.js";
import { getFirestore, doc, updateDoc, collection, getDocs } from "https://www.gstatic.com/firebasejs/11.3.1/firebase-firestore.js";
import { deleteDoc } from "https://www.gstatic.com/firebasejs/11.3.1/firebase-firestore.js";

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

let currentCharacterData = null;
let allCharacters = [];

// Hamburger Menu Toggle
const hamburgerBtn = document.getElementById('hamburger-btn');
const mobileMenu = document.getElementById('mobile-menu');
const desktopMenu = document.querySelector('.desktop-menu');

if (hamburgerBtn && mobileMenu) {
  hamburgerBtn.addEventListener('click', () => {
    mobileMenu.classList.toggle('show');
    hamburgerBtn.classList.toggle('active');
  });

  // Close mobile menu when clicking outside
  document.addEventListener('click', (e) => {
    if (!mobileMenu.contains(e.target) && !hamburgerBtn.contains(e.target)) {
      mobileMenu.classList.remove('show');
      hamburgerBtn.classList.remove('active');
    }
  });

  // Ensure desktop menu is not affected
  if (window.innerWidth >= 768) {
    desktopMenu.classList.add('flex');
    desktopMenu.classList.remove('hidden');
    mobileMenu.classList.remove('show');
  }

  // Handle window resize to toggle menus appropriately
  window.addEventListener('resize', () => {
    if (window.innerWidth >= 768) {
      mobileMenu.classList.remove('show');
      hamburgerBtn.classList.remove('active');
      desktopMenu.classList.add('flex');
      desktopMenu.classList.remove('hidden');
    } else {
      desktopMenu.classList.add('hidden');
      desktopMenu.classList.remove('flex');
    }
  });
}

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

function updateAuthLinks(user) {
    const authLinks = document.getElementById('auth-links');
    authLinks.innerHTML = '';

    if (user) {
        const signOutLink = document.createElement('a');
        signOutLink.href = '#';
        signOutLink.className = 'nav-link text-gray-300 hover:text-white transition-colors';
        signOutLink.textContent = 'Sign Out';
        signOutLink.addEventListener('click', async (e) => {
            e.preventDefault();
            try {
                await auth.signOut();
                updateAuthLinks(null);
                showMessage('Signed out successfully', 'success');
                
                // Clear current data
                allCharacters = [];
                currentCharacterData = null;
                
                // Update UI immediately
                document.getElementById('characters-grid').innerHTML = '<div class="loading">Please sign in to view your characters.</div>';
                updateStats();
                
                // Hide story section if it's visible
                const storySection = document.getElementById('story-section');
                if (storySection) {
                    storySection.classList.add('hidden');
                }
                
                // Redirect to home page immediately (or remove timeout completely)
                window.location.href = 'home.html'; // Change this to your home page
                
            } catch (error) {
                console.error('Sign out error:', error);
                showMessage('Error signing out: ' + error.message, 'error');
            }
        });
        authLinks.appendChild(signOutLink);
    } else {
        const signInLink = document.createElement('a');
        signInLink.href = 'signin.html';
        signInLink.className = 'nav-link text-gray-300 hover:text-white transition-colors';
        signInLink.textContent = 'Sign In';

        const signUpLink = document.createElement('a');
        signUpLink.href = 'signup.html';
        signUpLink.className = 'nav-link text-gray-300 hover:text-white transition-colors';
        signUpLink.textContent = 'Sign Up';

        authLinks.appendChild(signInLink);
        authLinks.appendChild(signUpLink);
    }
}

// Listen to auth state changes
auth.onAuthStateChanged((user) => {
    updateAuthLinks(user);
});

// Initialize Google AI
const genAI = new GoogleGenerativeAI('AIzaSyAnhRO61f0InhX7NcGxcG_0ZP0n_clcZ5w');

// Local Story Generation Function with Gemini
async function generateStoryLocal(name, universe, backstory, powers, weaknesses, fights) {
    const prompt = `Create an epic fantasy or sci-fi story about a character:
- Name: ${name}
- Universe: ${universe}
- Backstory: ${backstory}
- Powers/Abilities: ${powers}
- Weaknesses: ${weaknesses}
- Notable Conflicts: ${fights}
Make the story thrilling, emotional, and cinematic. Limit the story to exactly 75 words.`;

    try {
        const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
        const result = await model.generateContent(prompt);
        const response = await result.response;
        return response.text();
    } catch (error) {
        throw new Error(`Story generation failed: ${error.message}`);
    }
}

// Load Characters from Firebase
async function loadCharacters() {
    const charactersGrid = document.getElementById('characters-grid');
    try {
        if (!auth.currentUser) {
            charactersGrid.innerHTML = '<div class="loading">Please sign in to view your characters.</div>';
            updateStats();
            return;
        }

        showMessage("Loading characters...", "info");

        // Set a timeout to handle slow responses
        const timeoutPromise = new Promise((_, reject) => {
            setTimeout(() => {
                reject(new Error("Request timed out while loading characters"));
            }, 10000); // 10 seconds timeout
        });

        const charactersRef = collection(db, "Users", auth.currentUser.uid, "characters");
        const snapshot = await Promise.race([getDocs(charactersRef), timeoutPromise]);

        allCharacters = [];
        snapshot.forEach((doc) => {
            allCharacters.push({
                docId: doc.id,
                ...doc.data()
            });
        });

        allCharacters.sort((a, b) => {
            const timeA = a.createdAt ? (a.createdAt.toDate ? a.createdAt.toDate() : new Date(a.createdAt)) : new Date(0);
            const timeB = b.createdAt ? (b.createdAt.toDate ? b.createdAt.toDate() : new Date(b.createdAt)) : new Date(0);
            
            return timeB - timeA;
        });

        console.log("Loaded characters:", allCharacters);
        displayCharacters(allCharacters);
        updateStats();

        showMessage("Characters loaded successfully!", "success");
    } catch (error) {
        console.error("Error loading characters:", error);
        showMessage(`Error loading characters: ${error.message}`, "error");
        charactersGrid.innerHTML = '<div class="loading">Error loading characters. Please try refreshing the page.</div>';
    }
}

// Display Characters
function displayCharacters(characters) {
    const charactersGrid = document.getElementById('characters-grid');

    // Explicitly clear the loading message
    charactersGrid.innerHTML = '';

    if (characters.length === 0) {
        charactersGrid.innerHTML = '<div class="loading centered-message">No characters found. Create your first character!</div>';
        charactersGrid.classList.add('empty-state');
        return;
    }

    // Render character cards
    charactersGrid.innerHTML = characters.map(character => `
        <div class="character-card" data-character-id="${character.docId}">
            ${character.imageURL ? `
                <div class="character-image-container">
                    <img src="${character.imageURL}" 
                         alt="${character.name || 'Character'}" 
                         class="character-image" 
                         onload="this.style.opacity=1" 
                         style="opacity:0; transition: opacity 0.3s ease;" />
                </div>
            ` : `
                <div class="character-placeholder">
                    <div class="placeholder-icon">👤</div>
                </div>
            `}
            <div class="character-info">
                <h3 class="character-name">${character.name || 'Unnamed Character'}</h3>
                <div class="character-details">
                    <div class="detail-line">
                        <span class="detail-label">⚡ Powers:</span>
                        <span class="detail-value">${character.powers || 'Unknown abilities'}</span>
                    </div>
                    <div class="detail-line">
                        <span class="detail-label">🌌 Universe:</span>
                        <span class="detail-value">${character.universe || 'Unknown Universe'}</span>
                    </div>
                    <div class="detail-line">
                        <span class="detail-label">⚔️ Fights:</span>
                        <span class="detail-value">${character.fights || 'No conflicts recorded'}</span>
                    </div>
                </div>
                <div class="character-actions">
                    <button class="btn btn-primary" onclick="viewStory('${character.docId}')">
                        ${character.story ? 'View Story' : 'Generate Story'}
                    </button>
                    <button class="btn btn-secondary" onclick="editCharacter('${character.docId}')">Edit</button>
                </div>
            </div>
        </div>
    `).join('');

    // Ensure no leftover loading message
    const loadingElement = charactersGrid.querySelector('.loading');
    if (loadingElement) {
        loadingElement.remove();
    }
}

// Update Statistics
function updateStats() {
    const totalCount = allCharacters.length;
    const universesSet = new Set(allCharacters.map(char => char.universe).filter(Boolean));
    const universesCount = universesSet.size;

    document.getElementById('total-characters').textContent = totalCount;
    document.getElementById('universes-count').textContent = universesCount;
}

// View or Generate Story
async function viewStory(characterId) {
    try {
        const character = allCharacters.find(char => char.docId === characterId);
        if (!character) {
            showMessage("Character not found", "error");
            return;
        }

        currentCharacterData = character;

        // Show story section
        document.getElementById('story-section').classList.remove('hidden');
        document.getElementById('story-character-name').textContent = `${character.name}'s Story`;

        if (character.story) {
            // Display existing story
            document.getElementById('story-content').textContent = character.story;
        } else {
            // Generate new story
            document.getElementById('story-content').textContent = 'Generating story...';

            try {
                const story = await generateStoryLocal(
                    character.name || 'Unknown',
                    character.universe || 'Unknown',
                    character.backstory || 'A mysterious character',
                    character.powers || 'Unknown abilities',
                    character.weaknesses || 'Unknown weaknesses',
                    character.fights || 'Various challenges'
                );

                document.getElementById('story-content').textContent = story;

                // Save story to Firebase
                if (character.docId) {
                    const characterRef = doc(db, "Users", auth.currentUser.uid, "characters", character.docId);
                    await updateDoc(characterRef, {
                        story: story,
                        storyGenerated: true,
                        storyGeneratedAt: new Date()
                    });

                    // Update local data
                    character.story = story;
                    character.storyGenerated = true;
                    character.storyGeneratedAt = new Date();
                }

                showMessage("Story generated and saved successfully!", "success");
            } catch (error) {
                console.error("Error generating story:", error);
                document.getElementById('story-content').textContent = `Error generating story: ${error.message}`;
                showMessage(`Error generating story: ${error.message}`, "error");
            }
        }
    } catch (error) {
        console.error("Error viewing story:", error);
        showMessage(`Error: ${error.message}`, "error");
    }
}
window.viewStory = viewStory;

// Edit Character - Navigate to edit page with character docId
function editCharacter(characterId) {
    window.location.href = `edit.html?docId=${characterId}`;
}
window.editCharacter = editCharacter;

// Regenerate Story
async function regenerateStory() {
    if (!currentCharacterData) {
        showMessage("No character data available for regeneration.", "error");
        return;
    }

    const regenerateBtn = document.querySelector('.story-actions .btn-primary');
    const originalText = regenerateBtn.textContent;

    try {
        regenerateBtn.disabled = true;
        regenerateBtn.textContent = 'Regenerating...';
        showMessage("Regenerating story...", "info");

        const newStory = await generateStoryLocal(
            currentCharacterData.name || 'Unknown',
            currentCharacterData.universe || 'Unknown',
            currentCharacterData.backstory || 'A mysterious character',
            currentCharacterData.powers || 'Unknown abilities',
            currentCharacterData.weaknesses || 'Unknown weaknesses',
            currentCharacterData.fights || 'Various challenges'
        );

        document.getElementById('story-content').textContent = newStory;
        currentCharacterData.story = newStory;
        currentCharacterData.storyGeneratedAt = new Date();

        if (currentCharacterData.docId && auth.currentUser) {
            const characterRef = doc(db, "Users", auth.currentUser.uid, "characters", currentCharacterData.docId);
            await updateDoc(characterRef, {
                story: newStory,
                storyGeneratedAt: new Date()
            });
        }

        showMessage("Story regenerated and saved successfully!", "success");
    } catch (error) {
        console.error("Error regenerating story:", error);
        showMessage(`Error regenerating story: ${error.message}`, "error");
    } finally {
        regenerateBtn.disabled = false;
        regenerateBtn.textContent = originalText;
    }
}
window.regenerateStory = regenerateStory;

// Delete Story
async function delstory() {
    if (!auth.currentUser) {
        showMessage("Please sign in to delete a character.", "error");
        return;
    }

    if (!currentCharacterData || !currentCharacterData.docId) {
        showMessage("No character data available for deletion.", "error");
        return;
    }

    const confirmDelete = confirm(`Are you sure you want to delete "${currentCharacterData.name}"? This action cannot be undone.`);

    if (!confirmDelete) {
        return;
    }

    try {
        showMessage("Deleting character...", "info");

        // Reference to the character document in Firestore
        const characterRef = doc(db, "Users", auth.currentUser.uid, "characters", currentCharacterData.docId);

        // Delete the character document
        await deleteDoc(characterRef);

        // Remove the character from the local allCharacters array
        allCharacters = allCharacters.filter(char => char.docId !== currentCharacterData.docId);

        // Update the UI
        displayCharacters(allCharacters);
        updateStats();

        // Hide the story section since the character is deleted
        document.getElementById('story-section').classList.add('hidden');

        // Clear currentCharacterData
        currentCharacterData = null;

        showMessage("Character deleted successfully!", "success");
    } catch (error) {
        console.error("Error deleting character:", error);
        showMessage(`Error deleting character: ${error.message}`, "error");
    }
}
window.delstory = delstory;

// Hide Story
function hideStory() {
    document.getElementById('story-section').classList.add('hidden');
}
window.hideStory = hideStory;

// Filter Characters
function filterCharacters() {
    const searchInput = document.getElementById('search-input').value.toLowerCase();
    const universeFilter = document.getElementById('universe-filter').value.toLowerCase();
    const characterCards = document.querySelectorAll('.character-card');

    let visibleCount = 0;
    characterCards.forEach(card => {
        const characterId = card.dataset.characterId;
        const character = allCharacters.find(char => char.docId === characterId);
        if (!character) return;

        const characterName = card.querySelector('.character-name').textContent.toLowerCase();
        const characterUniverse = card.querySelector('.character-details .detail-line:nth-child(2) .detail-value').textContent.toLowerCase();
        const characterBackstory = (character.backstory || '').toLowerCase();

        const matchesSearch = searchInput === '' ||
            characterName.includes(searchInput) ||
            characterBackstory.includes(searchInput);

        const matchesUniverse = universeFilter === '' ||
            characterUniverse === universeFilter ||
            (universeFilter === 'custom' && !['marvel', 'dc', 'star wars', 'fantasy','anime'].includes(characterUniverse));

        if (matchesSearch && matchesUniverse) {
            card.style.display = 'block';
            visibleCount++;
        } else {
            card.style.display = 'none';
        }
    });

    const charactersGrid = document.getElementById('characters-grid');
    const hasCharacters = characterCards.length > 0;
    let noResultsMsg = document.getElementById('no-results-message');
    if (hasCharacters && visibleCount === 0) {
        if (!noResultsMsg) {
            noResultsMsg = document.createElement('div');
            noResultsMsg.id = 'no-results-message';
            noResultsMsg.className = 'loading';
            charactersGrid.appendChild(noResultsMsg);
        }
        noResultsMsg.textContent = 'No characters match your filter criteria.';
        noResultsMsg.style.display = 'block';
    } else if (noResultsMsg) {
        noResultsMsg.style.display = 'none';
    }
}

window.filterCharacters = filterCharacters;

// Firebase Auth State Listener
onAuthStateChanged(auth, (user) => {
    console.log("Auth state changed:", user); // Debug log

    if (user) {
        console.log("User is signed in:", user.uid); // Debug log
        // User is signed in, load their characters
        loadCharacters();
    } else {
        console.log("User is signed out"); // Debug log
        // User is signed out, clear characters and show sign-in message
        allCharacters = [];
        document.getElementById('characters-grid').innerHTML = '<div class="loading">Please sign in to view your characters.</div>';
        updateStats();
    }
});

// Initialize the page when DOM is loaded
document.addEventListener('DOMContentLoaded', function () {
    console.log("DOM loaded, checking auth state..."); // Debug log
    // The onAuthStateChanged listener will handle loading characters when auth state is determined
});

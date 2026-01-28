import { initializeApp } from "https://www.gstatic.com/firebasejs/11.3.1/firebase-app.js";
import { getAuth, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/11.3.1/firebase-auth.js";
import { getFirestore, doc, getDoc, updateDoc } from "https://www.gstatic.com/firebasejs/11.3.1/firebase-firestore.js";
import { GoogleGenerativeAI } from 'https://esm.run/@google/generative-ai';

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

let currentStep = 1;
const totalSteps = 5;
let selectedUniverse = '';
let characterId = new URLSearchParams(window.location.search).get('docId');

function showMessage(message, type) {
  const messageContainer = document.getElementById('message-container');
  if (messageContainer) {
    messageContainer.textContent = message;
    messageContainer.className = `message ${type}`;
    messageContainer.style.display = 'block';
    setTimeout(() => { messageContainer.style.display = 'none'; }, 5000);
  }
}

function setLoading(isLoading) {
  const submitBtn = document.getElementById('submit-btn');
  const submitText = document.getElementById('submit-text');
  if (submitBtn && submitText) {
    submitBtn.disabled = isLoading;
    submitText.textContent = isLoading ? 'Saving Changes...' : 'Save Changes';
  }
}

function validateImageFile(file) {
  const allowedTypes = [
    'image/jpeg', 'image/jpg', 'image/png', 'image/gif',
    'image/webp', 'image/svg+xml', 'image/bmp',
    'image/tiff', 'image/x-icon', 'image/vnd.microsoft.icon'
  ];
  const maxSize = 5 * 1024 * 1024;
  if (!allowedTypes.includes(file.type)) {
    return { valid: false, error: 'Unsupported image format. Please use JPG, PNG, GIF, WebP, SVG, BMP, TIFF, or ICO.' };
  }
  if (file.size > maxSize) {
    return { valid: false, error: 'Image size must be less than 5MB.' };
  }
  return { valid: true };
}

function setupImageUpload() {
  const imageInput = document.getElementById('image');
  if (imageInput) {
    imageInput.addEventListener('change', function (e) {
      const file = e.target.files[0];
      if (file) {
        const validation = validateImageFile(file);
        if (!validation.valid) {
          showMessage(validation.error, 'error');
          e.target.value = '';
          return;
        }
        const reader = new FileReader();
        reader.onload = function (e) {
          const preview = document.getElementById('imagePreview');
          const imageURLInput = document.getElementById('imageURL');
          if (preview && imageURLInput) {
            preview.src = e.target.result;
            preview.style.display = 'block';
            document.getElementById('image-preview').classList.remove('hidden');
            imageURLInput.value = e.target.result;
          }
        };
        reader.readAsDataURL(file);
      }
    });
  }
}

function updateProgress() {
  const progressFill = document.getElementById('progress-fill');
  const percentage = (currentStep / totalSteps) * 100;
  progressFill.style.width = percentage + '%';
  for (let i = 1; i <= totalSteps; i++) {
    const step = document.getElementById(`step-${i}`);
    step.classList.remove('active', 'completed');
    if (i < currentStep) {
      step.classList.add('completed');
    } else if (i === currentStep) {
      step.classList.add('active');
    }
  }
  document.querySelectorAll('.step-label').forEach((label, index) => {
    label.classList.toggle('active', index + 1 === currentStep);
  });
  document.getElementById('step-counter').textContent = `Step ${currentStep} of ${totalSteps}`;
}

function showStep(stepNumber) {
  document.querySelectorAll('.wizard-step').forEach(step => {
    step.classList.remove('active');
  });
  document.getElementById(`wizard-step-${stepNumber}`).classList.add('active');
  const prevBtn = document.getElementById('prev-btn');
  const nextBtn = document.getElementById('next-btn');
  const submitBtn = document.getElementById('submit-btn');
  prevBtn.disabled = stepNumber === 1;
  if (stepNumber === totalSteps) {
    nextBtn.classList.add('hidden');
    submitBtn.classList.remove('hidden');
  } else {
    nextBtn.classList.remove('hidden');
    submitBtn.classList.add('hidden');
  }
  updateProgress();
}

function validateCurrentStep() {
  switch (currentStep) {
    case 1:
      const name = document.getElementById('name').value.trim();
      const title = document.getElementById('title').value.trim();
      if (!name || !title) {
        showMessage('Please fill in all required fields', 'error');
        return false;
      }
      break;
    case 2:
      if (!selectedUniverse) {
        showMessage('Please select a universe', 'error');
        return false;
      }
      if (selectedUniverse === 'Custom' && !document.getElementById('customUniverse').value.trim()) {
        showMessage('Please enter a custom universe name', 'error');
        return false;
      }
      break;
    case 3:
      const backstory = document.getElementById('backstory').value.trim();
      const motivation = document.getElementById('motivation').value.trim();
      if (!backstory || !motivation) {
        showMessage('Please fill in all required fields', 'error');
        return false;
      }
      break;
    case 4:
      const powers = document.getElementById('powers').value.trim();
      const weaknesses = document.getElementById('weaknesses').value.trim();
      const fights = document.getElementById('fights').value.trim();
      if (!powers || !weaknesses || !fights) {
        showMessage('Please fill in all required fields', 'error');
        return false;
      }
      break;
    case 5:
      const imageURL = document.getElementById('imageURL').value.trim();
      if (!imageURL) {
        showMessage('Please upload an image', 'error');
        return false;
      }
      break;
  }
  return true;
}

function selectUniverse(universe) {
  document.querySelectorAll('.universe-card').forEach(card => {
    card.classList.remove('selected');
  });
  event.currentTarget.classList.add('selected');
  selectedUniverse = universe;
  document.getElementById('universe').value = universe;
  const customUniverseGroup = document.getElementById('custom-universe-group');
  customUniverseGroup.classList.toggle('hidden', universe !== 'Custom');
}

function removeImage() {
  document.getElementById('image').value = '';
  document.getElementById('imageURL').value = '';
  document.getElementById('image-preview').classList.add('hidden');
  document.getElementById('imagePreview').style.display = 'none';
}

async function loadCharacterData() {
  if (!auth.currentUser || !characterId) {
    showMessage("Invalid access. Please sign in or select a character.", "error");
    setTimeout(() => { window.location.href = "signin.html"; }, 2000);
    return;
  }

  try {
    const characterRef = doc(db, "Users", auth.currentUser.uid, "characters", characterId);
    const characterSnap = await getDoc(characterRef);
    if (!characterSnap.exists()) {
      showMessage("Character not found.", "error");
      setTimeout(() => { window.location.href = "index.html"; }, 2000);
      return;
    }

    const data = characterSnap.data();
    selectedUniverse = data.universe || '';

    document.getElementById('name').value = data.name || '';
    document.getElementById('title').value = data.title || '';
    document.getElementById('universe').value = data.universe || '';
    document.getElementById('customUniverse').value = (data.universe && !['Marvel', 'DC', 'Star Wars', 'Fantasy', 'Anime', 'Custom'].includes(data.universe)) ? data.universe : '';
    document.getElementById('backstory').value = data.backstory || '';
    document.getElementById('motivation').value = data.motivation || '';
    document.getElementById('powers').value = data.powers || '';
    document.getElementById('weaknesses').value = data.weaknesses || '';
    document.getElementById('fights').value = data.fights || '';
    document.getElementById('imageURL').value = data.imageURL || '';

    if (data.universe) {
      const universeCard = document.querySelector(`.universe-card[data-universe="${data.universe}"]`);
      if (universeCard) {
        universeCard.classList.add('selected');
      } else {
        document.querySelector('.universe-card[data-universe="Custom"]').classList.add('selected');
        selectedUniverse = 'Custom';
        document.getElementById('universe').value = 'Custom';
        document.getElementById('customUniverse').value = data.universe || '';
      }
      document.getElementById('custom-universe-group').classList.toggle('hidden', selectedUniverse !== 'Custom');
    }

    if (data.imageURL) {
      const preview = document.getElementById('imagePreview');
      preview.src = data.imageURL;
      preview.style.display = 'block';
      document.getElementById('image-preview').classList.remove('hidden');
    }

    showMessage("Character data loaded successfully.", "success");
  } catch (error) {
    console.error("Error loading character:", error);
    showMessage(`Error loading character data: ${error.message}`, "error");
    setTimeout(() => { window.location.href = "home.html"; }, 2000);
  }
}

const genAI = new GoogleGenerativeAI('AIzaSyAnhRO61f0InhX7NcGxcG_0ZP0n_clcZ5w');

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

async function handleFormSubmit(e) {
  e.preventDefault();
  setLoading(true);

  if (!auth.currentUser || !characterId) {
    showMessage("Please sign in and select a character.", "error");
    setLoading(false);
    return;
  }

  const formData = new FormData(e.target);
  const name = formData.get("name")?.trim();
  const title = formData.get("title")?.trim();
  let universe = formData.get("universe")?.trim() || "";
  if (universe === "Custom") {
    universe = formData.get("customUniverse")?.trim() || "Custom Universe";
  }
  const backstory = formData.get("backstory")?.trim();
  const motivation = formData.get("motivation")?.trim();
  const powers = formData.get("powers")?.trim();
  const weaknesses = formData.get("weaknesses")?.trim();
  const fights = formData.get("fights")?.trim();
  const imageURL = formData.get("imageURL")?.trim() || "";

  if (!name || !title || !universe || !backstory || !motivation || !powers || !weaknesses || !fights || !imageURL) {
    showMessage("Please fill in all required fields.", "error");
    setLoading(false);
    return;
  }

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
      updatedAt: new Date(),
      storyGenerated: true,
      storyGeneratedAt: new Date()
    };

    const characterRef = doc(db, "Users", auth.currentUser.uid, "characters", characterId);
    await updateDoc(characterRef, characterData);

    showMessage(`Character "${name}" updated successfully!`, "success");
    window.location.href = "explore.html";
    // Removed redirection to index.html, staying on the same page
    // setTimeout(() => { window.location.href = `index.html?characterId=${characterId}`; }, 1000);
  } catch (error) {
    console.error("Error updating character:", error);
    showMessage(`Error updating character: ${error.message}`, "error");
  } finally {
    setLoading(false);
  }
}

document.addEventListener('DOMContentLoaded', function () {
  // 3D Particle Background
  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
  const renderer = new THREE.WebGLRenderer({ alpha: true });
  renderer.setSize(window.innerWidth, window.innerHeight);
  document.getElementById('three-canvas').appendChild(renderer.domElement);
  const particleGroups = [];
  const colors = [0x8b45c1, 0x667eea, 0x764ba2, 0xf093fb, 0xf5576c];
  for (let g = 0; g < 3; g++) {
    const particleCount = 500;
    const particlesGeometry = new THREE.BufferGeometry();
    const posArray = new Float32Array(particleCount * 3);
    const velocityArray = new Float32Array(particleCount * 3);
    for (let i = 0; i < particleCount * 3; i++) {
      posArray[i] = (Math.random() - 0.5) * 1000;
      velocityArray[i] = (Math.random() - 0.5) * 0.02;
    }
    particlesGeometry.setAttribute('position', new THREE.BufferAttribute(posArray, 3));
    particlesGeometry.setAttribute('velocity', new THREE.BufferAttribute(velocityArray, 3));
    const material = new THREE.PointsMaterial({
      size: Math.random() * 3 + 1,
      color: colors[g % colors.length],
      transparent: true,
      opacity: 0.8,
      blending: THREE.AdditiveBlending
    });
    const particleMesh = new THREE.Points(particlesGeometry, material);
    scene.add(particleMesh);
    particleGroups.push({ mesh: particleMesh, velocities: velocityArray });
  }
  camera.position.z = 200;
  const mouse = new THREE.Vector2();
  let mouseInfluence = 0;
  window.addEventListener('mousemove', (event) => {
    mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
    mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;
    mouseInfluence = Math.min(mouseInfluence + 0.01, 0.1);
  });
  function animate() {
    requestAnimationFrame(animate);
    particleGroups.forEach((group, index) => {
      const positions = group.mesh.geometry.attributes.position.array;
      const velocities = group.velocities;
      for (let i = 0; i < positions.length; i += 3) {
        positions[i] += velocities[i] + mouse.x * mouseInfluence;
        positions[i + 1] += velocities[i + 1] + mouse.y * mouseInfluence;
        positions[i + 2] += velocities[i + 2];
        if (positions[i] > 500) positions[i] = -500;
        if (positions[i] < -500) positions[i] = 500;
        if (positions[i + 1] > 500) positions[i + 1] = -500;
        if (positions[i + 1] < -500) positions[i + 1] = 500;
        if (positions[i + 2] > 500) positions[i + 2] = -500;
        if (positions[i + 2] < -500) positions[i + 2] = 500;
      }
      group.mesh.geometry.attributes.position.needsUpdate = true;
      group.mesh.rotation.y += 0.001 * (index + 1);
      group.mesh.rotation.x += 0.0005 * (index + 1);
    });
    mouseInfluence = Math.max(mouseInfluence - 0.005, 0);
    renderer.render(scene, camera);
  }
  animate();

  // Particle Trail
  const particleContainer = document.getElementById('particle-container');
  function createParticleTrail(x, y) {
    const particle = document.createElement('div');
    particle.className = 'particle-trail';
    particle.style.left = x + 'px';
    particle.style.top = y + 'px';
    particle.style.opacity = '1';
    particleContainer.appendChild(particle);
    gsap.to(particle, {
      opacity: 0,
      scale: 0,
      x: Math.random() * 100 - 50,
      y: Math.random() * 100 - 50,
      duration: 2,
      ease: "power2.out",
      onComplete: () => particle.remove()
    });
  }
  document.addEventListener('mousemove', (e) => {
    if (Math.random() < 0.1) {
      createParticleTrail(e.clientX, e.clientY);
    }
  });

  // GSAP Letter animation
  const tl = gsap.timeline();
  tl.from('.letter', {
    opacity: 0,
    y: 20,
    duration: 0.3,
    stagger: 0.1,
    ease: "power2.out"
  })
    .from('.auth-section', { opacity: 0, scale: 0.8, duration: 1, ease: "back.out(1.7)" }, "-=0.5")
    .from('.wizard-container', { opacity: 0, x: -50, duration: 1, ease: "power2.out" }, "-=0.8");

  // Window resizer
  window.addEventListener('resize', () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
  });
  
  // Event Listeners
  setupImageUpload();
  document.querySelectorAll('.universe-card').forEach(card => {
    card.addEventListener('click', function () {
      selectUniverse(this.dataset.universe);
    });
  });

  const form = document.getElementById('edit-character-form');
  if (form) {
    form.addEventListener('submit', handleFormSubmit);
  }

  const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
  const navLinks = document.querySelector('.nav-links');
  if (mobileMenuToggle && navLinks) {
    mobileMenuToggle.addEventListener('click', () => {
      navLinks.classList.toggle('active');
    });
  }
});

document.getElementById('createBtn').addEventListener('click', (e) => {
      e.preventDefault();
      const user = auth.currentUser;
      if (user) {
        window.location.href = 'home.html';
      } else {
        showMessage('Please Sign In First', 'red');
        setTimeout(() => window.location.href = 'signin.html', 2000);
      }
    });

onAuthStateChanged(auth, async (user) => {
  if (!user) {
    window.location.href = "signin.html";
    return;
  }

  try {
    // Load character data after authentication is confirmed
    await loadCharacterData();
  } catch (error) {
    console.error("Error loading character data:", error);
    showMessage("Error loading character data", "error");
  }
});

window.signOut = async () => {
  try {
    await signOut(auth);
    window.location.href = "signin.html";
  } catch (error) {
    console.error("Error signing out:", error);
    showMessage("Failed to sign out.", "error");
  }
};

window.nextStep = () => {
  if (validateCurrentStep() && currentStep < totalSteps) {
    currentStep++;
    showStep(currentStep);
  }
};

window.previousStep = () => {
  if (currentStep > 1) {
    currentStep--;
    showStep(currentStep);
  }
};

window.removeImage = removeImage;
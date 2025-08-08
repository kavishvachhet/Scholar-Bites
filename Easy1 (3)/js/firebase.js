import { initializeApp } from "firebase/app";
import {getAuth} from "firebase/auth";
import {getFirestore} from "firebase/firestore";


  const firebaseConfig = {
    apiKey: "AIzaSyCYI3WQ9-peR0HEPxhrxCrsAEg2wn9QoDY",
    authDomain: "character-generator-75fdf.firebaseapp.com",
    projectId: "character-generator-75fdf",
    storageBucket: "character-generator-75fdf.firebasestorage.app",
    messagingSenderId: "233443409399",
    appId: "1:233443409399:web:d6757f2a53db4388bc82f2",
    measurementId: "G-F8TEK5KSNV"
  };

  // Initialize Firebase
  const app = initializeApp(firebaseConfig);

  export const auth=getAuth();
  export const db=getFirestore(app);
  export default app;

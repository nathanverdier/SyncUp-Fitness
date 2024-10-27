package services_firebase

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.UserProfileChangeRequest
import com.google.firebase.auth.ktx.auth
import com.google.firebase.ktx.Firebase
import kotlinx.coroutines.tasks.await

class AuthenticationService {
    private val auth: FirebaseAuth = Firebase.auth
    private lateinit var authStateListener: FirebaseAuth.AuthStateListener

    // User registration with email, password, and size
    suspend fun signUpWithEmailAndPassword(email: String, password: String, size: String): Boolean {
        return try {
            val authResult = auth.createUserWithEmailAndPassword(email, password).await()
            val user = authResult.user
            if (user != null) {
                val profileUpdates = UserProfileChangeRequest.Builder()
                    .setDisplayName(size) // Assuming 'size' is the display name
                    .build()
                user.updateProfile(profileUpdates).await()
                true // Sign-up successful
            } else {
                false // Sign-up failed
            }
        } catch (e: Exception) {
            println("Error during sign-up: ${e.message}") // Optional: Log the error
            false
        }
    }

    // User connection with email and password
    suspend fun signInWithEmailAndPassword(email: String, password: String): FirebaseUser? {
        return try {
            val authResult = auth.signInWithEmailAndPassword(email, password).await()
            authResult.user // Return the authenticated user
        } catch (e: Exception) {
            println("Error during sign-in: ${e.message}")
            null
        }
    }

    // Sign out the user
    fun signOut() {
        auth.signOut() // Use the instance variable for consistency
    }

    // Listen to authentication state changes using listeners
    fun startListeningToAuthChanges() {
        // Create the listener
        authStateListener = FirebaseAuth.AuthStateListener { firebaseAuth ->
            val user: FirebaseUser? = firebaseAuth.currentUser
            if (user != null) {
                println("User is signed in: ${user.email}")
            } else {
                println("User is signed out.")
            }
        }

        // Add the listener
        auth.addAuthStateListener(authStateListener)
    }

    // Remove the listener
    fun stopListeningToAuthChanges() {
        auth.removeAuthStateListener(authStateListener)
    }
}

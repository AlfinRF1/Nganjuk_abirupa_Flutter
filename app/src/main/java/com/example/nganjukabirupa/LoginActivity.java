package com.example.nganjukabirupa;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.text.InputType;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.gms.auth.api.signin.*;
import com.google.android.gms.common.SignInButton;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.*;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class LoginActivity extends AppCompatActivity {

    private static final String PREF_NAME = "user_session";
    private static final String KEY_ID_CUSTOMER = "id_customer";
    private static final String KEY_NAMA_CUSTOMER = "nama_customer";
    private static final String KEY_EMAIL_CUSTOMER = "email_customer";
    private static final String KEY_PHOTO_URL = "photo_url";

    private EditText etUsername, etPassword;
    private Button btnLogin;
    private SignInButton googleSignInButton;
    private TextView tvRegisterLink;

    private GoogleSignInClient googleSignInClient;
    private FirebaseAuth firebaseAuth;

    // -------------------------
    // GOOGLE SIGN-IN LAUNCHER
    // -------------------------
    private final ActivityResultLauncher<Intent> googleSignInLauncher =
            registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), result -> {
                if (result.getResultCode() == RESULT_OK) {
                    Intent data = result.getData();
                    Task<GoogleSignInAccount> task = GoogleSignIn.getSignedInAccountFromIntent(data);
                    try {
                        GoogleSignInAccount account = task.getResult(ApiException.class);
                        if (account != null) {
                            firebaseAuthWithGoogle(account.getIdToken());
                        }
                    } catch (ApiException e) {
                        Toast.makeText(this, "Google Sign-In gagal: " + e.getStatusCode(), Toast.LENGTH_SHORT).show();
                    }
                }
            });

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        etUsername = findViewById(R.id.et_username);
        etPassword = findViewById(R.id.et_password);
        ImageView ivTogglePassword = findViewById(R.id.iv_toggle_password);

        final boolean[] isPasswordVisible = {false};
        ivTogglePassword.setOnClickListener(v -> {
            if (isPasswordVisible[0]) {
                etPassword.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
                ivTogglePassword.setImageResource(R.drawable.ic_eye);
            } else {
                etPassword.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
                ivTogglePassword.setImageResource(R.drawable.ic_eye);
            }
            etPassword.setSelection(etPassword.getText().length());
            isPasswordVisible[0] = !isPasswordVisible[0];
        });

        btnLogin = findViewById(R.id.btn_login);
        googleSignInButton = findViewById(R.id.googleSignInButton);
        tvRegisterLink = findViewById(R.id.tv_register_link);
        tvRegisterLink.setOnClickListener(v -> {
            Intent intent = new Intent(LoginActivity.this, RegisterActivity.class);
            startActivity(intent);
        });


        firebaseAuth = FirebaseAuth.getInstance();

        GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestIdToken(getString(R.string.default_web_client_id))
                .requestEmail()
                .build();
        googleSignInClient = GoogleSignIn.getClient(this, gso);

        // Auto-login session
        SharedPreferences prefs = getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
        boolean fromRegister = getIntent().getBooleanExtra("fromRegister", false);
        if (prefs.contains(KEY_ID_CUSTOMER) && !fromRegister) {
            startActivity(new Intent(LoginActivity.this, DashboardActivity.class));
            finish();
        }

        // -------------------------
        // Login Manual
        // -------------------------
        btnLogin.setOnClickListener(v -> {
            String nama = etUsername.getText().toString();
            String password = etPassword.getText().toString();

            String namaTrimmed = nama.trim();
            String passwordTrimmed = password.trim();

            // Cek wajib isi
            if (namaTrimmed.isEmpty() || passwordTrimmed.isEmpty()) {
                Toast.makeText(this, "Nama dan password wajib diisi", Toast.LENGTH_SHORT).show();
                return;
            }

            // 🚫 Hapus semua pengecekan spasi
            // Tidak perlu cek spasi di awal/akhir atau di tengah

            LoginRequest request = new LoginRequest(namaTrimmed, passwordTrimmed);
            ApiService apiService = RetrofitClient.getClient().create(ApiService.class);

            apiService.login(request).enqueue(new Callback<LoginResponse>() {
                @Override
                public void onResponse(Call<LoginResponse> call, Response<LoginResponse> response) {
                    if (response.isSuccessful() && response.body() != null) {
                        LoginResponse res = response.body();
                        if (res.success) {
                            saveSession(
                                    res.id_customer,
                                    res.nama_customer != null ? res.nama_customer : namaTrimmed,
                                    res.email_customer != null ? res.email_customer : "",
                                    null
                            );
                            Toast.makeText(LoginActivity.this, res.message, Toast.LENGTH_SHORT).show();
                            startActivity(new Intent(LoginActivity.this, DashboardActivity.class));
                            finish();
                        } else {
                            Toast.makeText(LoginActivity.this, res.message, Toast.LENGTH_SHORT).show();
                        }
                    } else {
                        Toast.makeText(LoginActivity.this, "Login gagal", Toast.LENGTH_SHORT).show();
                    }
                }

                @Override
                public void onFailure(Call<LoginResponse> call, Throwable t) {
                    Toast.makeText(LoginActivity.this, "Gagal koneksi: " + t.getMessage(), Toast.LENGTH_SHORT).show();
                }
            });
        });

        // -------------------------
        // Google Sign-In
        // -------------------------
        googleSignInButton.setOnClickListener(v -> {
            googleSignInClient.signOut().addOnCompleteListener(this, task -> {
                Intent signInIntent = googleSignInClient.getSignInIntent();
                googleSignInLauncher.launch(signInIntent);
            });
        });
    }

    // -------------------------
    // Firebase Auth Google
    // -------------------------
    private void firebaseAuthWithGoogle(String idToken) {
        AuthCredential credential = GoogleAuthProvider.getCredential(idToken, null);
        firebaseAuth.signInWithCredential(credential)
                .addOnCompleteListener(this, task -> {
                    if (task.isSuccessful()) {
                        FirebaseUser user = firebaseAuth.getCurrentUser();
                        if (user != null) {
                            String email = user.getEmail();
                            String name = user.getDisplayName();
                            String photoUrl = user.getPhotoUrl() != null ? user.getPhotoUrl().toString() : null;

                            sendUserToBackend(email, name, photoUrl);
                        }
                    } else {
                        Toast.makeText(this, "Autentikasi Google gagal.", Toast.LENGTH_SHORT).show();
                    }
                });
    }

    // -------------------------
    // Kirim Google Login ke Backend
    // -------------------------
    private void sendUserToBackend(String email, String name, String photoUrl) {
        ApiService apiService = RetrofitClient.getClient().create(ApiService.class);
        GoogleLoginRequest request = new GoogleLoginRequest(name, email, photoUrl);

        apiService.googleLogin(request).enqueue(new Callback<LoginResponse>() {
            @Override
            public void onResponse(Call<LoginResponse> call, Response<LoginResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    LoginResponse res = response.body();

                    if (res.success) {
                        saveSession(
                                res.id_customer,
                                res.nama_customer != null ? res.nama_customer : name,
                                res.email_customer != null ? res.email_customer : email,
                                photoUrl
                        );

                        Toast.makeText(LoginActivity.this, res.message, Toast.LENGTH_SHORT).show();
                        startActivity(new Intent(LoginActivity.this, DashboardActivity.class));
                        finish();
                    } else {
                        Toast.makeText(LoginActivity.this, res.message, Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(LoginActivity.this, "Login gagal", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<LoginResponse> call, Throwable t) {
                Toast.makeText(LoginActivity.this, "Gagal koneksi: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    // -------------------------
    // Simpan Session
    // -------------------------
    private void saveSession(String id_customer, String nama, String email, String photoUrl) {
        SharedPreferences prefs = getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = prefs.edit();

        editor.clear();

        if (id_customer != null) editor.putString(KEY_ID_CUSTOMER, id_customer);
        if (nama != null) editor.putString(KEY_NAMA_CUSTOMER, nama);
        if (email != null) editor.putString(KEY_EMAIL_CUSTOMER, email);
        if (photoUrl != null) editor.putString(KEY_PHOTO_URL, photoUrl);

        editor.apply();
    }
}

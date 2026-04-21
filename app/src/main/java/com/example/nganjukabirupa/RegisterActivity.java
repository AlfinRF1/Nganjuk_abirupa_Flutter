package com.example.nganjukabirupa;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class RegisterActivity extends AppCompatActivity {

    private EditText etName, etEmail, etPhone, etPassword, etConfirmPassword;
    private Button btnCreateAccount;
    private boolean isNamaAvailable = false;

    private Retrofit retrofit;
    private ApiService apiService;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);

        etName = findViewById(R.id.etName);
        etEmail = findViewById(R.id.etEmail);
        etPhone = findViewById(R.id.etPhone);
        etPassword = findViewById(R.id.etPassword);
        etConfirmPassword = findViewById(R.id.etConfirmPassword);
        btnCreateAccount = findViewById(R.id.btnCreateAccount);

        Gson gson = new GsonBuilder().setLenient().create();
        retrofit = new Retrofit.Builder()
                .baseUrl("https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/apimobile/")
                .addConverterFactory(GsonConverterFactory.create(gson))
                .build();

        apiService = retrofit.create(ApiService.class);

        findViewById(R.id.backArrow).setOnClickListener(v -> finish());

        setupNamaValidation();
        btnCreateAccount.setOnClickListener(v -> handleRegister());
    }

    private void setupNamaValidation() {
        etName.addTextChangedListener(new TextWatcher() {
            private final Handler handler = new Handler();
            private Runnable debounceRunnable;

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) { }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (debounceRunnable != null) handler.removeCallbacks(debounceRunnable);
                isNamaAvailable = false;
                etName.setError(null);
                btnCreateAccount.setEnabled(true);
            }

            @Override
            public void afterTextChanged(Editable s) {
                String rawNama = s.toString().trim();
                
                if (rawNama.isEmpty()) return;

                // --- MAINTENANCE FIX: Real-time Notification ---
                // Jika mengandung simbol atau karakter non-Latin (seperti Phi), munculkan error
                if (!rawNama.matches("^[a-zA-Z0-9 ]*$")) {
                    etName.setError("Nama tidak boleh mengandung simbol atau karakter khusus!");
                    return; 
                }

                if (rawNama.length() < 3) {
                    etName.setError("Minimal 3 karakter");
                    return;
                }

                debounceRunnable = () -> checkNamaAvailability(rawNama);
                handler.postDelayed(debounceRunnable, 500);
            }
        });
    }

    private void checkNamaAvailability(String nama) {
        apiService.checkNama(nama).enqueue(new Callback<CheckNamaResponse>() {
            @Override
            public void onResponse(Call<CheckNamaResponse> call, Response<CheckNamaResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    isNamaAvailable = response.body().available;
                    if (!isNamaAvailable) {
                        etName.setError("⚠ Nama ini telah digunakan");
                        btnCreateAccount.setEnabled(false);
                    } else {
                        etName.setError(null);
                        btnCreateAccount.setEnabled(true);
                    }
                } else {
                    etName.setError("Cek nama gagal");
                    btnCreateAccount.setEnabled(true);
                }
            }

            @Override
            public void onFailure(Call<CheckNamaResponse> call, Throwable t) {
                etName.setError("Koneksi error");
                btnCreateAccount.setEnabled(true);
            }
        });
    }

    private void handleRegister() {
        hideKeyboard();

        String name = etName.getText().toString().trim();
        String email = etEmail.getText().toString().trim();
        String phone = etPhone.getText().toString().trim();
        String password = etPassword.getText().toString().trim();
        String confirmPassword = etConfirmPassword.getText().toString().trim();

        // --- MAINTENANCE FIX: Final Block Validation ---
        if (TextUtils.isEmpty(name)) { 
            etName.setError("Nama harus diisi"); 
            return; 
        }
        
        // Pengecekan ketat sebelum data dikirim ke server
        if (!name.matches("^[a-zA-Z0-9 ]*$")) {
            etName.setError("Perbaiki nama Anda (Hanya huruf & angka)");
            Toast.makeText(this, "Gagal: Karakter tidak diizinkan ditemukan!", Toast.LENGTH_LONG).show();
            return; 
        }

        if (!isNamaAvailable) { etName.setError("Nama telah digunakan"); return; }
        if (TextUtils.isEmpty(email)) { etEmail.setError("Email harus diisi"); return; }
        if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) { etEmail.setError("Email tidak valid"); return; }
        if (TextUtils.isEmpty(password)) { etPassword.setError("Password harus diisi"); return; }
        if (password.length() < 6) { etPassword.setError("Minimal 6 karakter"); return; }
        if (!password.equals(confirmPassword)) { etConfirmPassword.setError("Password tidak cocok"); return; }

        if (TextUtils.isEmpty(phone)) phone = "";

        RegisterRequest request = new RegisterRequest(name, email, phone, password);

        apiService.register(request).enqueue(new Callback<RegisterResponse>() {
            @Override
            public void onResponse(Call<RegisterResponse> call, Response<RegisterResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    RegisterResponse res = response.body();
                    Toast.makeText(RegisterActivity.this, res.getMessage(), Toast.LENGTH_SHORT).show();

                    if (res.isSuccess()) {
                        String idCustomer = res.getIdCustomer();
                        getSharedPreferences("user_session", MODE_PRIVATE)
                                .edit()
                                .putString("id_customer", idCustomer)
                                .apply();

                        startActivity(new Intent(RegisterActivity.this, LoginActivity.class)
                                .putExtra("fromRegister", true));
                        finish();
                    }
                } else {
                    Toast.makeText(RegisterActivity.this, "Server error", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<RegisterResponse> call, Throwable t) {
                Toast.makeText(RegisterActivity.this, "Koneksi gagal", Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void hideKeyboard() {
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        if (getCurrentFocus() != null) {
            imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
        }
    }
}
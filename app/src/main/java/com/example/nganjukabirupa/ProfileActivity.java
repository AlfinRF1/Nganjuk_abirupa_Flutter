package com.example.nganjukabirupa;

import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.util.Patterns;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

import com.bumptech.glide.Glide;
import com.yalantis.ucrop.UCrop;

import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;

import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class ProfileActivity extends AppCompatActivity {

    private EditText etNama, etEmail, etPassword;
    private ImageView imgPhoto;
    private Button btnLogout, btnUpdate;

    private static final String PREF_NAME = "user_session";
    private static final String KEY_ID_CUSTOMER = "id_customer";
    private static final String KEY_EMAIL_CUSTOMER = "email_customer";
    private static final String KEY_NAMA_CUSTOMER = "nama_customer";
    private static final String KEY_PHOTO_PATH = "foto";
    private static final String KEY_PASSWORD_CUSTOMER = "password_customer";

    private ActivityResultLauncher<Intent> galleryLauncher;
    private String id_customer;
    private SharedPreferences prefs;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);

        etNama = findViewById(R.id.tv_user_name);
        etEmail = findViewById(R.id.tv_user_email);
        etPassword = findViewById(R.id.et_user_password);
        imgPhoto = findViewById(R.id.iv_profile_photo);
        btnLogout = findViewById(R.id.btn_logout);
        btnUpdate = findViewById(R.id.btn_update);

        prefs = getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
        id_customer = prefs.getString(KEY_ID_CUSTOMER, null);
        String email_customer = prefs.getString(KEY_EMAIL_CUSTOMER, null);
        String nama_customer = prefs.getString(KEY_NAMA_CUSTOMER, null);
        String fotoCustomer = prefs.getString(KEY_PHOTO_PATH, null);
        String password_customer = prefs.getString(KEY_PASSWORD_CUSTOMER, null);

        etNama.setText(nama_customer != null ? nama_customer : "User");
        etEmail.setText(email_customer != null ? email_customer : "-");
        etPassword.setText(password_customer != null ? password_customer : "");

        if (fotoCustomer != null && !fotoCustomer.isEmpty()) {
            Glide.with(this)
                    .load(ApiClient.BASE_URL_UPLOAD + fotoCustomer)
                    .placeholder(R.drawable.default_profile_placeholder)
                    .error(R.drawable.default_profile_placeholder)
                    .into(imgPhoto);
        } else {
            imgPhoto.setImageResource(R.drawable.default_profile_placeholder);
        }

        // Gallery launcher
        galleryLauncher = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(),
                result -> {
                    if (result.getResultCode() == RESULT_OK && result.getData() != null) {
                        Uri picked = result.getData().getData();
                        if (picked != null) {
                            Uri sourceLocal = copyUriToCache(picked);
                            Uri destLocal = Uri.fromFile(new File(getCacheDir(), "crop_" + System.currentTimeMillis() + ".jpg"));
                            if (sourceLocal != null) {
                                UCrop.of(sourceLocal, destLocal)
                                        .withAspectRatio(1, 1)
                                        .withMaxResultSize(1000, 1000)
                                        .start(ProfileActivity.this);
                            } else {
                                Toast.makeText(this, "Gagal membaca gambar", Toast.LENGTH_SHORT).show();
                            }
                        }
                    }
                }
        );

        imgPhoto.setOnClickListener(v -> showFotoOptionsDialog());
        imgPhoto.setOnLongClickListener(v -> {
            showPreviewDialog();
            return true;
        });

        if (id_customer != null) {
            ambilDataProfilById(id_customer);
        }

        // 🔹 LOGOUT AMAN
        btnLogout.setOnClickListener(v -> {
            new AlertDialog.Builder(ProfileActivity.this)
                    .setTitle("Konfirmasi Logout")
                    .setMessage("Apakah kamu yakin ingin logout?")
                    .setPositiveButton("Ya", (dialog, which) -> {
                        // Hapus semua session
                        SharedPreferences.Editor editor = prefs.edit();
                        editor.clear();
                        editor.apply();

                        Toast.makeText(ProfileActivity.this, "Logout berhasil", Toast.LENGTH_SHORT).show();

                        // Start LoginActivity dan bersihkan semua activity sebelumnya
                        Intent intent = new Intent(ProfileActivity.this, LoginActivity.class);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                        startActivity(intent);
                        finish();
                    })
                    .setNegativeButton("Batal", (dialog, which) -> dialog.dismiss())
                    .show();
        });

        btnUpdate.setOnClickListener(v -> updateProfile());
    }

    private Uri copyUriToCache(Uri source) {
        try {
            File out = new File(getCacheDir(), "src_" + System.currentTimeMillis() + ".jpg");
            try (InputStream in = getContentResolver().openInputStream(source);
                 OutputStream os = new FileOutputStream(out)) {
                byte[] buf = new byte[8192];
                int len;
                while ((len = in.read(buf)) != -1) {
                    os.write(buf, 0, len);
                }
            }
            return Uri.fromFile(out);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private void showFotoOptionsDialog() {
        String[] options = {"Ganti Foto", "Hapus Foto"};
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Pilihan Foto Profil");
        builder.setItems(options, (dialog, which) -> {
            if (which == 0) openGallery();
            else if (which == 1) deleteFotoProfile();
        });
        builder.show();
    }

    private void openGallery() {
        Intent intent = new Intent(Intent.ACTION_PICK, android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        galleryLauncher.launch(intent);
    }

    private void updateProfile() {
        String newNama = etNama.getText().toString().trim();
        String newEmail = etEmail.getText().toString().trim();
        String newPass = etPassword.getText().toString().trim();

        if (!Patterns.EMAIL_ADDRESS.matcher(newEmail).matches()) {
            etEmail.setError("Format email tidak valid");
            return;
        }

        SharedPreferences prefs = getSharedPreferences("user_session", MODE_PRIVATE);
        String oldNama = prefs.getString("nama_customer", "");
        String oldEmail = prefs.getString("email_customer", "");

        //  cek apakah ada perubahan
        if (newNama.equals(oldNama) && newEmail.equals(oldEmail) && newPass.isEmpty()) {
            Toast.makeText(this, "Tidak ada perubahan data", Toast.LENGTH_SHORT).show();
            return;
        }

        ApiService api = ApiClient.getClient().create(ApiService.class);
        Call<UpdateProfileResponse> call = api.updateProfile(id_customer, newNama, newEmail, newPass);

        call.enqueue(new Callback<UpdateProfileResponse>() {
            @Override
            public void onResponse(Call<UpdateProfileResponse> call, Response<UpdateProfileResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    UpdateProfileResponse res = response.body();
                    Toast.makeText(ProfileActivity.this, res.getMessage(), Toast.LENGTH_SHORT).show();
                    if ("success".equals(res.getStatus())) ambilDataProfilById(id_customer);
                } else {
                    Toast.makeText(ProfileActivity.this, "Server error: " + response.code(), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<UpdateProfileResponse> call, Throwable t) {
                Toast.makeText(ProfileActivity.this, "Error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void uploadImageToServer(Uri imageUri, String idCustomer) {
        File file = new File(imageUri.getPath());
        if (!file.exists() || file.length() == 0) {
            Toast.makeText(this, "File crop tidak ditemukan", Toast.LENGTH_SHORT).show();
            return;
        }

        RequestBody idBody = RequestBody.create(okhttp3.MediaType.parse("text/plain"), idCustomer);
        RequestBody fileBody = RequestBody.create(okhttp3.MediaType.parse("image/*"), file);
        MultipartBody.Part fotoPart = MultipartBody.Part.createFormData("foto", file.getName(), fileBody);

        ApiService api = ApiClient.getClient().create(ApiService.class);
        api.updateFoto(idBody, fotoPart).enqueue(new Callback<ResponseBody>() {
            @Override
            public void onResponse(Call<ResponseBody> call, Response<ResponseBody> response) {
                if (response.isSuccessful()) {
                    Toast.makeText(ProfileActivity.this, "Foto berhasil diupdate", Toast.LENGTH_SHORT).show();
                    ambilDataProfilById(idCustomer);
                } else {
                    Toast.makeText(ProfileActivity.this, "Gagal update foto", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<ResponseBody> call, Throwable t) {
                Toast.makeText(ProfileActivity.this, "Error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void deleteFotoProfile() {
        ApiService api = ApiClient.getClient().create(ApiService.class);
        api.deleteFoto(id_customer).enqueue(new Callback<ResponseBody>() {
            @Override
            public void onResponse(Call<ResponseBody> call, Response<ResponseBody> response) {
                if (response.isSuccessful() && response.body() != null) {
                    try {
                        String body = response.body().string();
                        JSONObject json = new JSONObject(body);

                        String status = json.optString("status");
                        String message = json.optString("message");

                        if ("success".equals(status)) {
                            Toast.makeText(ProfileActivity.this,
                                    message.toLowerCase().contains("sudah kosong") ?
                                            "Foto memang sudah kosong" : "Foto berhasil dihapus",
                                    Toast.LENGTH_SHORT).show();

                            imgPhoto.setImageResource(R.drawable.default_profile_placeholder);
                            ambilDataProfilById(id_customer);
                        } else {
                            Toast.makeText(ProfileActivity.this, "Gagal hapus: " + message, Toast.LENGTH_SHORT).show();
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        Toast.makeText(ProfileActivity.this, "Parse response error", Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(ProfileActivity.this, "Server error: " + response.code(), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<ResponseBody> call, Throwable t) {
                Toast.makeText(ProfileActivity.this, "Error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void ambilDataProfilById(String idCustomer) {
        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(ApiClient.BASE_URL_API)
                .addConverterFactory(GsonConverterFactory.create())
                .build();

        ApiService api = retrofit.create(ApiService.class);
        ProfileRequest request = new ProfileRequest(idCustomer);

        api.getProfile(request).enqueue(new Callback<ProfileResponse>() {
            @Override
            public void onResponse(Call<ProfileResponse> call, Response<ProfileResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    ProfileResponse.Profile profile = response.body().getProfile();
                    if (profile != null) {
                        String nama = profile.getNamaCustomer() != null ? profile.getNamaCustomer() : "";
                        String email = profile.getEmailCustomer() != null ? profile.getEmailCustomer() : "";
                        etNama.setText(nama);
                        etEmail.setText(email);

                        String fotoPath = profile.getFoto();
                        if (fotoPath != null && !fotoPath.isEmpty()) {
                            Glide.with(ProfileActivity.this)
                                    .load(ApiClient.BASE_URL_UPLOAD + fotoPath)
                                    .placeholder(R.drawable.default_profile_placeholder)
                                    .error(R.drawable.default_profile_placeholder)
                                    .into(imgPhoto);
                        } else {
                            imgPhoto.setImageResource(R.drawable.default_profile_placeholder);
                        }

                        SharedPreferences prefs = getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
                        prefs.edit()
                                .putString(KEY_NAMA_CUSTOMER, nama)
                                .putString(KEY_EMAIL_CUSTOMER, email)
                                .putString(KEY_PHOTO_PATH, fotoPath)
                                .apply();
                    }
                } else {
                    Toast.makeText(ProfileActivity.this, "Response tidak valid", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<ProfileResponse> call, Throwable t) {
                Toast.makeText(ProfileActivity.this, "Gagal ambil profil: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == RESULT_OK && requestCode == UCrop.REQUEST_CROP) {
            Uri resultUri = UCrop.getOutput(data);
            if (resultUri != null) {
                File f = new File(resultUri.getPath());
                if (f.exists() && f.length() > 0) {
                    imgPhoto.setImageURI(resultUri);
                    uploadImageToServer(resultUri, id_customer);
                } else {
                    Toast.makeText(this, "Hasil crop tidak valid", Toast.LENGTH_SHORT).show();
                }
            }
        } else if (resultCode == UCrop.RESULT_ERROR) {
            Throwable cropError = UCrop.getError(data);
            Toast.makeText(this, "Crop error: " + (cropError != null ? cropError.getMessage() : "unknown"), Toast.LENGTH_SHORT).show();
        }
    }

    private void showPreviewDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        View previewView = getLayoutInflater().inflate(R.layout.dialog_preview_photo, null);
        ImageView previewImage = previewView.findViewById(R.id.preview_image);

        SharedPreferences prefs = getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
        String fotoPath = prefs.getString(KEY_PHOTO_PATH, null);

        if (fotoPath != null && !fotoPath.isEmpty()) {
            Glide.with(this)
                    .load(ApiClient.BASE_URL_UPLOAD + fotoPath)
                    .placeholder(R.drawable.default_profile_placeholder)
                    .error(R.drawable.default_profile_placeholder)
                    .into(previewImage);
        } else {
            previewImage.setImageResource(R.drawable.default_profile_placeholder);
        }

        builder.setView(previewView);
        builder.setPositiveButton("Tutup", (dialog, which) -> dialog.dismiss());
        builder.show();
    }

    // Footer navigation
    public void onHomeClicked(View view) {
        startActivity(new Intent(ProfileActivity.this, DashboardActivity.class));
        finish();
    }

    public void onRiwayatClicked(View view) {
        startActivity(new Intent(ProfileActivity.this, RiwayatActivity.class));
        finish();
    }

    public void onProfileClicked(View view) {
        // sudah di profile
    }
}

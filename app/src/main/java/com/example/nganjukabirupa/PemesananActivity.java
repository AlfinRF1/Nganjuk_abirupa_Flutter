package com.example.nganjukabirupa;

import android.app.DatePickerDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import org.json.JSONObject;

import java.util.Calendar;

import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class PemesananActivity extends AppCompatActivity {

    private static final int REQUEST_JUMLAH = 100;

    private TextView tvTotalHarga, tvLabelDewasa, tvLabelAnak, tvLabelAsuransi;
    private TextView tvHargaDewasa, tvHargaAnak, tvAsuransi;
    private EditText etTanggal, etNama, etTelepon;
    private Button btnJumlah, btnBayar;

    private int jumlahDewasa = 0;
    private int jumlahAnak = 0;
    private int hargaDewasa = 0;
    private int hargaAnak = 0;
    private int tarifAsuransi = 0;
    private int idWisata;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pemesanan);

        initViews();

        // GET DATA WISATA
        Intent intent = getIntent();
        idWisata = intent.getIntExtra("id_wisata", -1);
        hargaDewasa = intent.getIntExtra("hargaDewasa", 0);
        hargaAnak = intent.getIntExtra("hargaAnak", 0);
        tarifAsuransi = intent.getIntExtra("tarifAsuransi", 1000);

        if (idWisata == -1) {
            Toast.makeText(this, "ID Wisata tidak valid", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        setupCalendarPicker();
        setupJumlahButton();
        setupBayarButton();

        hitungTotalHarga();
        loadHargaWisata();
    }

    private void initViews() {
        tvTotalHarga = findViewById(R.id.tvTotal);
        tvLabelDewasa = findViewById(R.id.tvLabelDewasa);
        tvLabelAnak = findViewById(R.id.tvLabelAnak);
        tvLabelAsuransi = findViewById(R.id.tvLabelAsuransi);
        tvHargaDewasa = findViewById(R.id.tvHargaDewasa);
        tvHargaAnak = findViewById(R.id.tvHargaAnak);
        tvAsuransi = findViewById(R.id.tvAsuransi);
        etTanggal = findViewById(R.id.etTanggal);
        etNama = findViewById(R.id.etNama);
        etTelepon = findViewById(R.id.etTelepon);
        btnJumlah = findViewById(R.id.btnJumlah);
        btnBayar = findViewById(R.id.btnBayar);

        ImageButton btnBack = findViewById(R.id.btnBack);
        btnBack.setOnClickListener(v -> onBackPressed());
    }

    private void setupCalendarPicker() {
        ImageButton btnCalendar = findViewById(R.id.btnCalendar);
        btnCalendar.setOnClickListener(v -> {
            Calendar calendar = Calendar.getInstance();
            DatePickerDialog datePickerDialog = new DatePickerDialog(
                    PemesananActivity.this,
                    (view, year, month, day) -> {
                        String tanggal = String.format("%04d-%02d-%02d", year, month + 1, day);
                        etTanggal.setText(tanggal);
                    },
                    calendar.get(Calendar.YEAR),
                    calendar.get(Calendar.MONTH),
                    calendar.get(Calendar.DAY_OF_MONTH)
            );
            datePickerDialog.show();
        });
    }

    private void setupJumlahButton() {
        btnJumlah.setOnClickListener(v -> {
            Intent intent = new Intent(PemesananActivity.this, PilihPengunjungActivity.class);
            intent.putExtra("idWisata", idWisata);
            intent.putExtra("tiketDewasa", hargaDewasa);
            intent.putExtra("tiketAnak", hargaAnak);
            intent.putExtra("asuransi", tarifAsuransi);
            startActivityForResult(intent, REQUEST_JUMLAH);
        });
    }

    private void setupBayarButton() {
        btnBayar.setOnClickListener(v -> {
            String nama = etNama.getText().toString().trim();
            String telepon = etTelepon.getText().toString().trim();
            String tanggalDipilih = etTanggal.getText().toString().trim();
            int jumlahPengunjung = jumlahDewasa + jumlahAnak;

            // Validasi input
            if (!validasiInput(nama, telepon, tanggalDipilih)) return;
            if (jumlahPengunjung == 0) {
                Toast.makeText(this, "Pilih jumlah pengunjung dulu", Toast.LENGTH_SHORT).show();
                return;
            }

            // Ambil idCustomer dari SharedPreferences
            SharedPreferences prefs = getSharedPreferences("user_session", MODE_PRIVATE);
            String idCustomerStr = prefs.getString("id_customer", "").trim();
            if (idCustomerStr.isEmpty()) {
                Toast.makeText(this, "User belum login", Toast.LENGTH_SHORT).show();
                return;
            }

            // Hitung total harga
            int totalHarga = (jumlahDewasa * hargaDewasa)
                    + (jumlahAnak * hargaAnak)
                    + (jumlahPengunjung * tarifAsuransi);

            ProgressDialog progress = new ProgressDialog(this);
            progress.setMessage("Proses transaksi...");
            progress.setCancelable(false);
            progress.show();

            ApiService apiService = RetrofitClient.getClient().create(ApiService.class);

            // Kirim ke insert_pemesanan.php
            Call<ResponseBody> call = apiService.insertPemesanan(
                    nama,
                    telepon,
                    tanggalDipilih,
                    String.valueOf(jumlahPengunjung),
                    String.valueOf(totalHarga),
                    String.valueOf(idWisata),
                    idCustomerStr
            );

            call.enqueue(new Callback<ResponseBody>() {
                @Override
                public void onResponse(Call<ResponseBody> call, Response<ResponseBody> response) {
                    progress.dismiss();
                    if (response.isSuccessful() && response.body() != null) {
                        try {
                            String raw = response.body().string().trim();
                            JSONObject obj = new JSONObject(raw);

                            if ("success".equals(obj.optString("status"))) {
                                int total = obj.optInt("harga_total", totalHarga);

                                Intent intent = new Intent(PemesananActivity.this, QrCodeActivity.class);
                                intent.putExtra("nama", nama);
                                intent.putExtra("telepon", telepon);
                                intent.putExtra("tanggal", tanggalDipilih);
                                intent.putExtra("jumlah", jumlahPengunjung);
                                intent.putExtra("total", total);
                                intent.putExtra("idWisata", idWisata);
                                startActivity(intent);
                                finish();
                            } else {
                                Toast.makeText(PemesananActivity.this, obj.optString("message"), Toast.LENGTH_SHORT).show();
                            }

                        } catch (Exception e) {
                            e.printStackTrace();
                            Toast.makeText(PemesananActivity.this, "Error parsing response", Toast.LENGTH_SHORT).show();
                        }
                    } else {
                        Toast.makeText(PemesananActivity.this, "Gagal menyimpan transaksi", Toast.LENGTH_SHORT).show();
                    }
                }

                @Override
                public void onFailure(Call<ResponseBody> call, Throwable t) {
                    progress.dismiss();
                    Toast.makeText(PemesananActivity.this, "Error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
                }
            });
        });
    }


    private boolean validasiInput(String nama, String telepon, String tanggal) {
        if (nama.isEmpty() || telepon.isEmpty() || tanggal.isEmpty() || jumlahDewasa + jumlahAnak == 0) {
            Toast.makeText(this, "Lengkapi semua data sebelum bayar", Toast.LENGTH_SHORT).show();
            return false;
        }
        if (!nama.matches("^[a-zA-Z0-9 ]+$")) {
            Toast.makeText(this, "Nama tidak boleh mengandung karakter khusus", Toast.LENGTH_SHORT).show();
            return false;
        }
        if (!telepon.matches("^\\+?[0-9]+$")) {
            Toast.makeText(this, "Nomor telepon hanya boleh angka", Toast.LENGTH_SHORT).show();
            return false;
        }
        return true;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_JUMLAH && resultCode == RESULT_OK && data != null) {
            jumlahDewasa = data.getIntExtra("jumlahDewasa", 0);
            jumlahAnak = data.getIntExtra("jumlahAnak", 0);
            btnJumlah.setText(String.format("%02d Dewasa, %02d Anak", jumlahDewasa, jumlahAnak));
            hitungTotalHarga();
        }
    }

    private void loadHargaWisata() {
        ApiService apiService = RetrofitClient.getClient().create(ApiService.class);
        Call<ResponseBody> call = apiService.getDetailWisataRaw(idWisata);

        call.enqueue(new Callback<ResponseBody>() {
            @Override
            public void onResponse(Call<ResponseBody> call, Response<ResponseBody> response) {
                if (response.isSuccessful() && response.body() != null) {
                    try {
                        String rawStr = response.body().string().trim(); // trim spasi
                        JSONObject jsonObject = new JSONObject(rawStr);

                        hargaDewasa = jsonObject.optInt("tiketDewasa", hargaDewasa);
                        hargaAnak = jsonObject.optInt("tiketAnak", hargaAnak);
                        tarifAsuransi = jsonObject.optInt("asuransi", tarifAsuransi);

                        hitungTotalHarga();

                    } catch (Exception e) {
                        e.printStackTrace();
                        Toast.makeText(PemesananActivity.this, "Error parsing response", Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(PemesananActivity.this, "Gagal mengambil data harga", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<ResponseBody> call, Throwable t) {
                Toast.makeText(PemesananActivity.this, "Error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void hitungTotalHarga() {
        int totalTiket = (jumlahDewasa * hargaDewasa) + (jumlahAnak * hargaAnak);
        int totalAsuransi = (jumlahDewasa + jumlahAnak) * tarifAsuransi;
        int totalHarga = totalTiket + totalAsuransi;

        tvLabelDewasa.setText(jumlahDewasa + " x Rp " + hargaDewasa);
        tvLabelAnak.setText(jumlahAnak + " x Rp " + hargaAnak);
        tvLabelAsuransi.setText((jumlahDewasa + jumlahAnak) + " x Rp " + tarifAsuransi);

        tvHargaDewasa.setText("Rp " + (jumlahDewasa * hargaDewasa));
        tvHargaAnak.setText("Rp " + (jumlahAnak * hargaAnak));
        tvAsuransi.setText("Rp " + totalAsuransi);
        tvTotalHarga.setText("Rp " + totalHarga);
    }
}

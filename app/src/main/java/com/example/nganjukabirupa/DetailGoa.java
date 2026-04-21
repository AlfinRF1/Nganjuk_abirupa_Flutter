package com.example.nganjukabirupa;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class DetailGoa extends AppCompatActivity {

    private ImageView imgHeader;
    private TextView tvNamaWisata, tvLokasi, tvDeskripsi, tvHargaTiket, tvFasilitas;
    private Button btnPesan;
    private ImageButton btnBack;

    private int hargaDewasa = 0;
    private int hargaAnak = 0;
    private int idWisata = -1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_goamargotresno);

        // Inisialisasi view
        imgHeader    = findViewById(R.id.imgHeader);
        tvNamaWisata = findViewById(R.id.tvNamaWisata);
        tvLokasi     = findViewById(R.id.tvLokasi);
        tvDeskripsi  = findViewById(R.id.tvDeskripsi);
        tvHargaTiket = findViewById(R.id.tvHargaTiket);
        tvFasilitas  = findViewById(R.id.tvFasilitas);
        btnPesan     = findViewById(R.id.btnPesan);
        btnBack      = findViewById(R.id.btnBack);

        // Ambil id_wisata dari Intent
        idWisata = getIntent().getIntExtra("id_wisata", -1);
        String namaExtra = getIntent().getStringExtra("nama_wisata"); // fallback
        Log.d("DetailGoa", "Terima id_wisata: " + idWisata + ", extra nama=" + namaExtra);

        if (idWisata == -1) {
            Toast.makeText(this, "ID wisata tidak valid", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        // Ambil data dari backend sesuai id_wisata
        ApiService apiService = RetrofitClient.getClient().create(ApiService.class);
        Call<WisataModel> call = apiService.getDetailWisata(idWisata);

        call.enqueue(new Callback<WisataModel>() {
            @Override
            public void onResponse(Call<WisataModel> call, Response<WisataModel> response) {
                if (response.isSuccessful() && response.body() != null) {
                    WisataModel data = response.body();

                    // fallback nama wisata
                    String nama = data.getNamaWisata();
                    if (nama == null || nama.isEmpty()) {
                        nama = namaExtra;
                    }

                    tvNamaWisata.setText(nama != null ? nama : "Nama wisata belum tersedia");
                    tvLokasi.setText(data.getLokasi() != null ? data.getLokasi() : "Lokasi belum tersedia");
                    tvDeskripsi.setText(data.getDeskripsi() != null ? data.getDeskripsi() : "Deskripsi belum tersedia");
                    tvFasilitas.setText(data.getFasilitas() != null ? data.getFasilitas() : "Fasilitas belum tersedia");

                    // langsung ambil int dari model
                    hargaDewasa = data.getTiketDewasa();
                    hargaAnak   = data.getTiketAnak();

                    // fallback ke extras kalau API kosong
                    if (hargaDewasa == 0) {
                        hargaDewasa = getIntent().getIntExtra("hargaDewasa", 0);
                    }
                    if (hargaAnak == 0) {
                        hargaAnak = getIntent().getIntExtra("hargaAnak", 0);
                    }

                    tvHargaTiket.setText("Dewasa: Rp " + hargaDewasa + "\nAnak-anak: Rp " + hargaAnak);

                    // Pakai setImageResource langsung
                    int imageResId = getDrawableForWisata(idWisata);
                    imgHeader.setImageResource(imageResId);

                    Log.d("DetailGoa", "HargaDewasa=" + hargaDewasa + ", HargaAnak=" + hargaAnak);

                } else {
                    Toast.makeText(DetailGoa.this, "Data tidak ditemukan", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<WisataModel> call, Throwable t) {
                Toast.makeText(DetailGoa.this, "Error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });

        // Tombol Pesan
        btnPesan.setOnClickListener(v -> {
            Intent intent = new Intent(this, PemesananActivity.class);
            intent.putExtra("id_wisata", idWisata);
            intent.putExtra("hargaDewasa", hargaDewasa);
            intent.putExtra("hargaAnak", hargaAnak);
            intent.putExtra("jumlahDewasa", 0);
            intent.putExtra("jumlahAnak", 0);
            startActivity(intent);
        });

        // Tombol Back
        btnBack.setOnClickListener(v -> {
            Intent intent = new Intent(DetailGoa.this, DashboardActivity.class);
            startActivity(intent);
            finish();
        });
    }

    // Mapping gambar berdasarkan ID wisata
    private int getDrawableForWisata(int idWisata) {
        switch (idWisata) {
            case 12: return R.drawable.wisata_air_terjun_sedudo;
            case 13: return R.drawable.wisata_roro_kuning;
            case 14: return R.drawable.wisata_goa_margotresno;
            case 15: return R.drawable.wisata_sritanjung;
            case 16: return R.drawable.wisata_tral;
            default: return R.drawable.default_wisata;
        }
    }
}
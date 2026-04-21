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

import com.bumptech.glide.Glide;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class DetailWisataGeneric extends AppCompatActivity {

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
        setContentView(R.layout.activity_detail); // layout generik

        // Inisialisasi view
        imgHeader    = findViewById(R.id.imgHeader);
        tvNamaWisata = findViewById(R.id.tvNamaWisata);
        tvLokasi     = findViewById(R.id.tvLokasi);
        tvDeskripsi  = findViewById(R.id.tvDeskripsi);
        tvHargaTiket = findViewById(R.id.tvHargaTiket);
        tvFasilitas  = findViewById(R.id.tvFasilitas);
        btnPesan     = findViewById(R.id.btnPesan);
        btnBack      = findViewById(R.id.btnBack);

        // Ambil data dari Intent
        Intent intent = getIntent();
        idWisata = intent.getIntExtra("id_wisata", -1);
        String namaExtra = intent.getStringExtra("nama_wisata");
        String lokasiExtra = intent.getStringExtra("lokasi");
        String deskripsiExtra = intent.getStringExtra("deskripsi");
        String fasilitasExtra = intent.getStringExtra("fasilitas");
        String gambarExtra = intent.getStringExtra("gambar");

        Log.d("DetailGeneric", "id=" + idWisata + ", nama=" + namaExtra);

        if (idWisata == -1) {
            Toast.makeText(this, "ID wisata tidak valid", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        // Ambil data dari backend
        ApiService apiService = RetrofitClient.getClient().create(ApiService.class);
        Call<WisataModel> call = apiService.getDetailWisata(idWisata);

        call.enqueue(new Callback<WisataModel>() {
            @Override
            public void onResponse(Call<WisataModel> call, Response<WisataModel> response) {
                if (!isFinishing() && !isDestroyed()) { // amanin lifecycle
                    if (response.isSuccessful() && response.body() != null) {
                        WisataModel data = response.body();

                        // Fallback: kalau API kosong, pakai extras
                        String nama = data.getNamaWisata();
                        if (nama == null || nama.isEmpty()) nama = namaExtra;

                        tvNamaWisata.setText(nama != null ? nama : "Nama wisata belum tersedia");
                        tvLokasi.setText(data.getLokasi() != null ? data.getLokasi() : (lokasiExtra != null ? lokasiExtra : "Lokasi belum tersedia"));
                        tvDeskripsi.setText(data.getDeskripsi() != null ? data.getDeskripsi() : (deskripsiExtra != null ? deskripsiExtra : "Deskripsi belum tersedia"));
                        tvFasilitas.setText(data.getFasilitas() != null ? data.getFasilitas() : (fasilitasExtra != null ? fasilitasExtra : "Fasilitas belum tersedia"));

                        // harga tiket aman + fallback
                        hargaDewasa = data.getTiketDewasa();
                        if (hargaDewasa == 0) {
                            hargaDewasa = intent.getIntExtra("hargaDewasa", 0);
                        }

                        hargaAnak = data.getTiketAnak();
                        if (hargaAnak == 0) {
                            hargaAnak = intent.getIntExtra("hargaAnak", 0);
                        }

                        tvHargaTiket.setText("Dewasa: Rp " + hargaDewasa + "\nAnak-anak: Rp " + hargaAnak);

                        // Gambar: kalau id 12–16 pakai drawable, selain itu pakai Glide
                        int imageResId = getDrawableForWisata(idWisata);
                        if (imageResId != R.drawable.default_wisata) {
                            imgHeader.setImageResource(imageResId);
                        } else {
                            String imageUrl = data.getGambar(); // ambil dari API dulu
                            if (imageUrl == null || imageUrl.isEmpty()) {
                                imageUrl = gambarExtra; // fallback dari intent
                            }
                            Log.d("DetailGeneric", "Gambar dari API/fallback: " + imageUrl);

                            if (imageUrl != null && !imageUrl.isEmpty()) {
                                if (!imageUrl.startsWith("http")) {
                                    imageUrl = "https://nganjukabirupa.pbltifnganjuk.com/assets/images/destinasi/" + imageUrl;
                                }
                                Glide.with(DetailWisataGeneric.this) // pakai activity context
                                        .load(imageUrl)
                                        .placeholder(R.drawable.default_wisata)
                                        .error(R.drawable.default_wisata)
                                        .into(imgHeader);
                            } else {
                                imgHeader.setImageResource(R.drawable.default_wisata);
                            }
                        }

                        Log.d("DetailGeneric", "HargaDewasa=" + hargaDewasa + ", HargaAnak=" + hargaAnak);

                    } else {
                        Toast.makeText(DetailWisataGeneric.this, "Gagal ambil data", Toast.LENGTH_SHORT).show();
                    }
                }
            }

            @Override
            public void onFailure(Call<WisataModel> call, Throwable t) {
                if (!isFinishing() && !isDestroyed()) {
                    Toast.makeText(DetailWisataGeneric.this, "Error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
                }
            }
        });

        // Tombol Pesan
        btnPesan.setOnClickListener(v -> {
            Intent pesanIntent = new Intent(this, PemesananActivity.class);
            pesanIntent.putExtra("id_wisata", idWisata);
            pesanIntent.putExtra("hargaDewasa", hargaDewasa);
            pesanIntent.putExtra("hargaAnak", hargaAnak);
            pesanIntent.putExtra("jumlahDewasa", 0);
            pesanIntent.putExtra("jumlahAnak", 0);
            startActivity(pesanIntent);
        });

        // Tombol Back
        btnBack.setOnClickListener(v -> {
            finish(); // cukup finish biar balik ke activity sebelumnya
        });
    }

    // Mapping gambar untuk 5 wisata tetap
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
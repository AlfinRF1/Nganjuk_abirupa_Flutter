package com.example.nganjukabirupa;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.bumptech.glide.Glide;

public class DetailWisata extends AppCompatActivity {

    private ImageView imgHeader;
    private TextView tvNamaWisata, tvLokasi, tvDeskripsi, tvHargaTiket, tvFasilitas;
    private Button btnPesan;
    private ImageButton btnBack;

    private int idWisata;
    private int hargaDewasa;
    private int hargaAnak;

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
        idWisata    = intent.getIntExtra("id_wisata", -1);
        String namaWisata = intent.getStringExtra("nama_wisata");
        String lokasi     = intent.getStringExtra("lokasi");
        String deskripsi  = intent.getStringExtra("deskripsi");
        String fasilitas  = intent.getStringExtra("fasilitas");
        String gambar     = intent.getStringExtra("gambar");
        String tiket      = intent.getStringExtra("tiket");

        // Ambil harga dari extras (pastikan adapter kirim)
        hargaDewasa = intent.getIntExtra("hargaDewasa", 0);
        hargaAnak   = intent.getIntExtra("hargaAnak", 0);

        if (idWisata == -1) {
            Toast.makeText(this, "ID wisata tidak valid", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        // Set ke view
        tvNamaWisata.setText(namaWisata);
        tvLokasi.setText(lokasi);
        tvDeskripsi.setText(deskripsi != null ? deskripsi : "Deskripsi belum tersedia");
        tvFasilitas.setText(fasilitas != null ? fasilitas : "Fasilitas belum tersedia");
        tvHargaTiket.setText(tiket != null ? tiket : "Harga belum tersedia");

        // Load gambar: kalau 5 wisata tetap → pakai drawable, selain itu → Glide
        switch (idWisata) {
            case 12:
                imgHeader.setImageResource(R.drawable.wisata_air_terjun_sedudo);
                break;
            case 13:
                imgHeader.setImageResource(R.drawable.wisata_roro_kuning);
                break;
            case 14:
                imgHeader.setImageResource(R.drawable.wisata_goa_margotresno);
                break;
            case 15:
                imgHeader.setImageResource(R.drawable.wisata_sritanjung);
                break;
            case 16:
                imgHeader.setImageResource(R.drawable.wisata_tral);
                break;
            default:
                if (gambar != null && !gambar.isEmpty()) {
                    String imageUrl = gambar;
                    if (!imageUrl.startsWith("http")) {
                        imageUrl = "https://nganjukabirupa.pbltifnganjuk.com/apimobile/images/" + imageUrl;
                    }
                    Glide.with(this)
                            .load(imageUrl)
                            .placeholder(R.drawable.default_wisata)
                            .error(R.drawable.default_wisata)
                            .into(imgHeader);
                } else {
                    imgHeader.setImageResource(R.drawable.default_wisata);
                }
                break;
        }

        // Tombol Pesan → kirim data ke PemesananActivity
        btnPesan.setOnClickListener(v -> {
            Intent pesanIntent = new Intent(this, PemesananActivity.class);
            pesanIntent.putExtra("id_wisata", idWisata);
            pesanIntent.putExtra("nama_wisata", namaWisata);
            pesanIntent.putExtra("lokasi", lokasi);

            // kirim harga tiket & asuransi
            pesanIntent.putExtra("hargaDewasa", hargaDewasa);
            pesanIntent.putExtra("hargaAnak", hargaAnak);
            pesanIntent.putExtra("tarifAsuransi", 1000); // default atau ambil dari backend kalau ada

            // jumlah default
            pesanIntent.putExtra("jumlahDewasa", 0);
            pesanIntent.putExtra("jumlahAnak", 0);

            startActivity(pesanIntent);
        });

        // Tombol Back
        btnBack.setOnClickListener(v -> finish());
    }
}
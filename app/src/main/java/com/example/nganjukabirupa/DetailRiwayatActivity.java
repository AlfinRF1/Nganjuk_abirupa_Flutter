package com.example.nganjukabirupa;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class DetailRiwayatActivity extends AppCompatActivity {

    private View cardHistory;

    // TextView references
    private TextView tvNamaWisata, tvLokasiWisata, tvIdTransaksi, tvTanggal, tvStatus, tvMetode, tvTotal;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.bottomsheet_detailriwayat);

        // Animasi card
        cardHistory = findViewById(R.id.card_main_history);
        Animation slideUp = AnimationUtils.loadAnimation(this, R.anim.slide_up);
        cardHistory.startAnimation(slideUp);

        // Inisialisasi TextView
        tvNamaWisata = findViewById(R.id.tv_wisata_name);
        tvLokasiWisata = findViewById(R.id.tv_wisata_location);
        tvIdTransaksi = findViewById(R.id.tv_transaction_id);
        tvTanggal = findViewById(R.id.tv_transaction_date);
        tvStatus = findViewById(R.id.tv_transaction_status);
        tvMetode = findViewById(R.id.tv_payment_method);
        tvTotal = findViewById(R.id.tv_transaction_total);

        // Ambil data dari Intent
        String namaWisata = getIntent().getStringExtra("nama_wisata");
        String lokasiWisata = getIntent().getStringExtra("lokasi");
        String idTransaksi = getIntent().getStringExtra("id_transaksi");
        String tanggal = getIntent().getStringExtra("tanggal");
        String status = getIntent().getStringExtra("status");
        String metode = getIntent().getStringExtra("metode_pembayaran");
        String totalStr = getIntent().getStringExtra("total_harga");

        // Tampilkan ke UI
        tvNamaWisata.setText(namaWisata != null ? namaWisata : "-");
        tvLokasiWisata.setText(lokasiWisata != null ? lokasiWisata : "-");
        tvIdTransaksi.setText(idTransaksi != null ? idTransaksi : "-");
        tvStatus.setText(status != null ? status : "-");
        tvMetode.setText(metode != null ? metode : "QRIS");

        // Format total harga
        try {
            int totalHarga = totalStr != null ? Integer.parseInt(totalStr) : 0;
            tvTotal.setText("Rp. " + String.format("%,d", totalHarga));
        } catch (NumberFormatException e) {
            tvTotal.setText(totalStr != null ? totalStr : "Rp. 0");
        }

        // Format tanggal
        try {
            if (tanggal != null && !tanggal.isEmpty()) {
                String inputFormatStr = tanggal.contains(" ") ? "yyyy-MM-dd HH:mm:ss" : "yyyy-MM-dd";
                SimpleDateFormat inputFormat = new SimpleDateFormat(inputFormatStr);
                Date date = inputFormat.parse(tanggal);

                SimpleDateFormat outputFormat = new SimpleDateFormat("dd MMM yyyy", Locale.getDefault());
                tvTanggal.setText(date != null ? outputFormat.format(date) : tanggal);
            } else {
                tvTanggal.setText("-");
            }
        } catch (Exception e) {
            tvTanggal.setText(tanggal != null ? tanggal : "-");
        }
    }

    @SuppressLint("MissingSuperCall")
    @Override
    public void onBackPressed() {
        Animation slideDown = AnimationUtils.loadAnimation(this, R.anim.slide_down);
        cardHistory.startAnimation(slideDown);

        slideDown.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationEnd(Animation animation) {
                finish();
                overridePendingTransition(0, 0);
            }

            @Override public void onAnimationStart(Animation animation) { }
            @Override public void onAnimationRepeat(Animation animation) { }
        });
    }
}

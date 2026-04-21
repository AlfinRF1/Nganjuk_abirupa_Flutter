package com.example.nganjukabirupa;

import android.content.Intent;
import android.os.Bundle;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

public class QrCodeActivity extends AppCompatActivity {
    private TextView totalAmountText;
    private ImageView backArrow, imgBarcode;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.bottomsheet_qr_pembayaran);

        totalAmountText = findViewById(R.id.total_amount);
        backArrow = findViewById(R.id.back_arrow);
        imgBarcode = findViewById(R.id.qr_code_image);

        // Ambil data dari Intent
        int totalHarga = getIntent().getIntExtra("total", 0);
        int idWisata = getIntent().getIntExtra("idWisata", -1);

        // Tampilkan total harga
        if (totalHarga > 0) {
            totalAmountText.setText("Total : Rp. " + String.format("%,d", totalHarga));
        } else {
            totalAmountText.setText("Total : Rp. -");
            Toast.makeText(this, "Data total tidak tersedia", Toast.LENGTH_SHORT).show();
        }

        // Set barcode sesuai idWisata
        imgBarcode.setImageResource(getBarcodeDrawable(idWisata));

        // Tombol kembali
        backArrow.setOnClickListener(v -> goBackToRiwayat());
    }

    // Mapping idWisata ke drawable
    private int getBarcodeDrawable(int idWisata) {
        switch (idWisata) {
            case 12: return R.drawable.sedudo;
            case 13: return R.drawable.tral;
            case 14: return R.drawable.goa;
            case 15: return R.drawable.sritanjung;
            default: return R.drawable.barcode_default;
        }
    }

    // Custom back ke RiwayatActivity tanpa double activity
    private void goBackToRiwayat() {
        Intent intent = new Intent(QrCodeActivity.this, RiwayatActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        startActivity(intent);
        finish();
    }

    // Override tombol back fisik
    @Override
    public void onBackPressed() {
        // Navigasi ke RiwayatActivity
        Intent intent = new Intent(QrCodeActivity.this, RiwayatActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        startActivity(intent);

        // Panggil super agar warning hilang
        super.onBackPressed();
    }

}

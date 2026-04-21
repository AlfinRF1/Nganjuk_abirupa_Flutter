package com.example.nganjukabirupa;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

public class PilihPengunjungActivity extends AppCompatActivity {

    private int jumlahDewasa = 0;
    private int jumlahAnak = 0;

    private TextView tvJumlahDewasa, tvJumlahAnak;
    private ImageButton btnPlusDewasa, btnMinusDewasa;
    private ImageButton btnPlusAnak, btnMinusAnak;
    private Button btnSimpan;

    private int idWisata, tiketDewasa, tiketAnak, asuransi;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.bottomsheet_pilihpengunjung);

        // Ambil data dari intent
        Intent intent = getIntent();
        idWisata = intent.getIntExtra("idWisata", -1);
        tiketDewasa = intent.getIntExtra("tiketDewasa", 0);
        tiketAnak = intent.getIntExtra("tiketAnak", 0);
        asuransi = intent.getIntExtra("asuransi", 0);

        if (idWisata == -1) {
            Toast.makeText(this, "Data wisata tidak valid", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        // Inisialisasi view
        tvJumlahDewasa = findViewById(R.id.tvCountDewasa);
        tvJumlahAnak = findViewById(R.id.tvCountAnak);

        btnPlusDewasa = findViewById(R.id.btnPlusDewasa);
        btnMinusDewasa = findViewById(R.id.btnMinDewasa);
        btnPlusAnak = findViewById(R.id.btnPlusAnak);
        btnMinusAnak = findViewById(R.id.btnMinAnak);
        btnSimpan = findViewById(R.id.btnSimpan);

        // Tombol back (ImageView arrow_back)
        ImageView ivBackDialog = findViewById(R.id.ivBackDialog);
        if (ivBackDialog != null) {
            ivBackDialog.setOnClickListener(v -> finish());
        }

        // Tombol tambah / kurang dewasa
        btnPlusDewasa.setOnClickListener(v -> updateDewasa(jumlahDewasa + 1));
        btnMinusDewasa.setOnClickListener(v -> updateDewasa(jumlahDewasa - 1));

        // Tombol tambah / kurang anak
        btnPlusAnak.setOnClickListener(v -> updateAnak(jumlahAnak + 1));
        btnMinusAnak.setOnClickListener(v -> updateAnak(jumlahAnak - 1));

        // Tombol simpan
        btnSimpan.setOnClickListener(v -> simpanData());
    }

    private void updateDewasa(int newValue) {
        if (newValue < 0) return;
        jumlahDewasa = newValue;
        tvJumlahDewasa.setText(String.valueOf(jumlahDewasa));
    }

    private void updateAnak(int newValue) {
        if (newValue < 0) return;
        jumlahAnak = newValue;
        tvJumlahAnak.setText(String.valueOf(jumlahAnak));
    }

    private void simpanData() {
        int total = jumlahDewasa + jumlahAnak;

        if (total == 0) {
            Toast.makeText(this, "Jumlah pengunjung belum diisi", Toast.LENGTH_SHORT).show();
            return;
        }

        Intent resultIntent = new Intent();
        resultIntent.putExtra("jumlahDewasa", jumlahDewasa);
        resultIntent.putExtra("jumlahAnak", jumlahAnak);

        setResult(RESULT_OK, resultIntent);
        finish();
    }
}

package com.example.nganjukabirupa;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.google.gson.Gson;

import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class RiwayatActivity extends AppCompatActivity {

    private RecyclerView recyclerView;
    private RiwayatAdapter adapter;
    private SwipeRefreshLayout swipeRefresh;
    private static final String TAG = "RiwayatActivity";
    private int idCustomer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_riwayat);

        recyclerView = findViewById(R.id.recyclerViewRiwayat);
        swipeRefresh = findViewById(R.id.swipeRefresh);

        recyclerView.setLayoutManager(new LinearLayoutManager(this));

        // Ambil id_customer dari SharedPreferences
        SharedPreferences prefs = getSharedPreferences("user_session", MODE_PRIVATE);
        String idCustomerStr = prefs.getString("id_customer", null);

        if (idCustomerStr == null) {
            startActivity(new Intent(this, LoginActivity.class));
            finish();
            return;
        }

        try {
            idCustomer = Integer.parseInt(idCustomerStr);
        } catch (NumberFormatException e) {
            startActivity(new Intent(this, LoginActivity.class));
            finish();
            return;
        }

        // Listener refresh manual
        swipeRefresh.setOnRefreshListener(this::loadRiwayat);

        // Load pertama kali
        loadRiwayat();
    }

    // 🔹 Reload otomatis tiap balik ke activity
    @Override
    protected void onResume() {
        super.onResume();
        loadRiwayat();
    }

    private void loadRiwayat() {
        swipeRefresh.setRefreshing(true);

        ApiService apiService = RetrofitClient.getClient().create(ApiService.class);
        Call<RiwayatResponse> call = apiService.getRiwayat(idCustomer);

        call.enqueue(new Callback<RiwayatResponse>() {
            @Override
            public void onResponse(Call<RiwayatResponse> call, Response<RiwayatResponse> response) {
                swipeRefresh.setRefreshing(false);
                if (response.isSuccessful() && response.body() != null) {
                    List<RiwayatModel> riwayatList = response.body().getData();
                    Log.d(TAG, "Raw response: " + new Gson().toJson(riwayatList));
                    Log.d(TAG, "Jumlah data riwayat: " + (riwayatList != null ? riwayatList.size() : 0));

                    if (riwayatList == null || riwayatList.isEmpty()) {
                        Toast.makeText(RiwayatActivity.this, "Belum ada riwayat transaksi", Toast.LENGTH_SHORT).show();
                        recyclerView.setAdapter(null);
                    } else {
                        adapter = new RiwayatAdapter(riwayatList);
                        recyclerView.setAdapter(adapter);
                    }
                } else {
                    Log.e(TAG, "Response gagal: " + response.code());
                    Toast.makeText(RiwayatActivity.this, "Riwayat kosong atau gagal dimuat", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<RiwayatResponse> call, Throwable t) {
                swipeRefresh.setRefreshing(false);
                Log.e(TAG, "Network error: " + t.getMessage(), t);
                Toast.makeText(RiwayatActivity.this, "Error: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    public void onHomeClicked(android.view.View view) {
        startActivity(new Intent(RiwayatActivity.this, DashboardActivity.class));
        finish();
    }

    public void onRiwayatClicked(android.view.View view) {
        Toast.makeText(this, "Kamu sudah di halaman Riwayat", Toast.LENGTH_SHORT).show();
    }

    public void onProfileClicked(android.view.View view) {
        startActivity(new Intent(RiwayatActivity.this, ProfileActivity.class));
        finish();
    }
}

package com.example.nganjukabirupa;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.facebook.shimmer.ShimmerFrameLayout;

import java.util.ArrayList;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class DashboardActivity extends AppCompatActivity {

    private RecyclerView recyclerWisata;
    private WisataAdapter adapter;
    private List<WisataModel> wisataList = new ArrayList<>();
    private EditText searchInput;
    private TextView tvWelcome;
    private ShimmerFrameLayout shimmerLayout;
    private SwipeRefreshLayout swipeRefreshDashboard;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dashboard);

        // Ambil nama user dari SharedPreferences
        SharedPreferences prefs = getSharedPreferences("user_session", MODE_PRIVATE);
        String namaUser = prefs.getString("nama_customer", "Nama Kamu");

        tvWelcome = findViewById(R.id.tvWelcome);
        if (tvWelcome != null) {
            tvWelcome.setText("Selamat Datang, " + namaUser + "!");
        }

        // Setup Shimmer + RecyclerView
        shimmerLayout = findViewById(R.id.shimmerLayout);
        shimmerLayout.startShimmer();

        recyclerWisata = findViewById(R.id.recyclerWisata);
        recyclerWisata.setLayoutManager(new LinearLayoutManager(this));
        adapter = new WisataAdapter(DashboardActivity.this, wisataList);
        recyclerWisata.setAdapter(adapter);

        // Setup SwipeRefreshLayout
        swipeRefreshDashboard = findViewById(R.id.swipeRefreshDashboard);
        swipeRefreshDashboard.setOnRefreshListener(this::loadWisata);

        // Load data pertama kali
        loadWisata();

        // Search filter
        searchInput = findViewById(R.id.searchInput);
        searchInput.addTextChangedListener(new TextWatcher() {
            @Override public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (adapter != null) adapter.getFilter().filter(s.toString());
            }
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void afterTextChanged(Editable s) {}
        });

        // Footer navigation
        findViewById(R.id.navHome).setOnClickListener(v -> {});
        findViewById(R.id.navRiwayat).setOnClickListener(v ->
                startActivity(new Intent(this, RiwayatActivity.class)));
        findViewById(R.id.navProfile).setOnClickListener(v ->
                startActivity(new Intent(this, ProfileActivity.class)));
    }

    private void loadWisata() {
        shimmerLayout.startShimmer();
        shimmerLayout.setVisibility(View.VISIBLE);
        recyclerWisata.setVisibility(View.GONE);

        ApiService api = ApiClient.getClient().create(ApiService.class);
        api.getAllWisata().enqueue(new Callback<WisataResponse>() {
            @Override
            public void onResponse(Call<WisataResponse> call, Response<WisataResponse> response) {
                swipeRefreshDashboard.setRefreshing(false); // stop refresh animasi
                shimmerLayout.stopShimmer();
                shimmerLayout.setVisibility(View.GONE);
                recyclerWisata.setVisibility(View.VISIBLE);

                if (response.isSuccessful() && response.body() != null) {
                    List<WisataModel> newData = response.body().getData();
                    adapter.setData(newData); // refresh data + backup list
                    Log.d("Dashboard", "Jumlah data: " + newData.size());
                } else {
                    Log.e("Dashboard", "Response gagal / kosong");
                }
            }

            @Override
            public void onFailure(Call<WisataResponse> call, Throwable t) {
                swipeRefreshDashboard.setRefreshing(false);
                shimmerLayout.stopShimmer();
                shimmerLayout.setVisibility(View.GONE);
                recyclerWisata.setVisibility(View.VISIBLE);
                Log.e("Dashboard", "Error: " + t.getMessage());
            }
        });
    }
}
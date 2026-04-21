package com.example.nganjukabirupa;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.widget.ImageView;

import androidx.appcompat.app.AppCompatActivity;

public class SplashScreenActivity extends AppCompatActivity {

    private static final String PREF_NAME = "user_session";
    private static final String KEY_ID_CUSTOMER = "id_customer";
    private static final long SPLASH_DURATION = 2000; // 2 detik

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash_screen);

        ImageView logoImage = findViewById(R.id.logoImage);
        ImageView brandingImage = findViewById(R.id.brandingImage);

        // Animasi fade-in
        fadeInView(logoImage, SPLASH_DURATION / 2);
        fadeInView(brandingImage, SPLASH_DURATION);

        // Navigasi setelah delay tanpa deprecated Handler
        View rootView = findViewById(android.R.id.content);
        rootView.postDelayed(() -> {
            SharedPreferences prefs = getSharedPreferences(PREF_NAME, MODE_PRIVATE);
            String id_customer = prefs.getString(KEY_ID_CUSTOMER, null);

            Intent intent;
            if (id_customer != null) {
                intent = new Intent(SplashScreenActivity.this, DashboardActivity.class);
            } else {
                intent = new Intent(SplashScreenActivity.this, LoginActivity.class);
            }

            startActivity(intent);
            finish();
        }, SPLASH_DURATION);
    }

    private void fadeInView(View view, long duration) {
        Animation fadeIn = new AlphaAnimation(0, 1);
        fadeIn.setDuration(duration);
        fadeIn.setFillAfter(true);
        view.startAnimation(fadeIn);
    }
}

package com.example.nganjukabirupa;

import android.content.Context;
import android.content.SharedPreferences;

public class SessionManager {
    private static final String PREF_NAME = "user_session";
    private static final String KEY_ID_CUSTOMER = "id_customer";
    private static final String KEY_NAMA_CUSTOMER = "nama_customer";
    private static final String KEY_EMAIL_CUSTOMER = "email_customer";

    private SharedPreferences prefs;
    private SharedPreferences.Editor editor;

    public SessionManager(Context context) {
        prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
        editor = prefs.edit();
    }

    // Simpan semua data session
    public void saveSession(String id, String nama, String email) {
        editor.putString(KEY_ID_CUSTOMER, id);
        editor.putString(KEY_NAMA_CUSTOMER, nama);
        editor.putString(KEY_EMAIL_CUSTOMER, email);
        editor.apply();
    }

    // Ambil ID
    public String getIdCustomer() {
        return prefs.getString(KEY_ID_CUSTOMER, null);
    }

    // Ambil Nama
    public String getNama() {
        return prefs.getString(KEY_NAMA_CUSTOMER, "");
    }

    // Ambil Email
    public String getEmail() {
        return prefs.getString(KEY_EMAIL_CUSTOMER, "");
    }

    // Cek login
    public boolean isLoggedIn() {
        return getIdCustomer() != null;
    }

    // Hapus session
    public void logout() {
        editor.clear();
        editor.apply();
    }
}
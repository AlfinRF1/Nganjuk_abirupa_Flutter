package com.example.nganjukabirupa;

import com.google.gson.annotations.SerializedName;

public class LoginRequest {
    @SerializedName("nama_customer")
    private String nama;

    @SerializedName("password_customer")
    private String password;

    public LoginRequest(String nama, String password) {
        this.nama = nama;
        this.password = password;
    }
}
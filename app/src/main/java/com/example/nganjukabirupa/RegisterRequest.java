package com.example.nganjukabirupa;

import com.google.gson.annotations.SerializedName;

public class RegisterRequest {
    @SerializedName("nama_customer")
    public String namaCustomer;

    @SerializedName("email_customer")
    public String emailCustomer;

    @SerializedName("no_tlp")
    public String noTelp;

    @SerializedName("password_customer")
    public String passwordCustomer;

    public RegisterRequest(String namaCustomer, String emailCustomer, String noTelp, String passwordCustomer) {
        this.namaCustomer = namaCustomer;
        this.emailCustomer = emailCustomer;
        this.noTelp = noTelp;
        this.passwordCustomer = passwordCustomer;
    }
}

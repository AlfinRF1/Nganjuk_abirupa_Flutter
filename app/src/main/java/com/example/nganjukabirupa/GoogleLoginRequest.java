package com.example.nganjukabirupa;

public class GoogleLoginRequest {
    public String nama_customer;
    public String email_customer;
    public String foto;   // boleh null, backend bisa skip

    public GoogleLoginRequest(String nama_customer, String email_customer, String foto) {
        this.nama_customer = nama_customer;
        this.email_customer = email_customer;
        this.foto = foto; // URL Google, bukan dari DB
    }

    public GoogleLoginRequest() {}
}

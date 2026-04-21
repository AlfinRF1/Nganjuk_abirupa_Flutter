package com.example.nganjukabirupa;

import com.google.gson.annotations.SerializedName;

public class Profile {

    @SerializedName("id_customer")
    private String idCustomer;

    @SerializedName("nama_customer")
    private String namaCustomer;

    @SerializedName("email_customer")
    private String emailCustomer;

    @SerializedName("no_tlp")
    private String noTelp;

    @SerializedName("foto")
    private String foto; // path relatif dari backend, contoh: "uploads/nama_file.jpg"

    // Getter
    public String getIdCustomer() {
        return idCustomer;
    }

    public String getNamaCustomer() {
        return namaCustomer;
    }

    public String getEmailCustomer() {
        return emailCustomer;
    }

    public String getNoTelp() {
        return noTelp;
    }

    public String getFoto() {
        return foto;
    }

    // Setter (opsional, kalau mau update object di runtime)
    public void setIdCustomer(String idCustomer) {
        this.idCustomer = idCustomer;
    }

    public void setNamaCustomer(String namaCustomer) {
        this.namaCustomer = namaCustomer;
    }

    public void setEmailCustomer(String emailCustomer) {
        this.emailCustomer = emailCustomer;
    }

    public void setNoTelp(String noTelp) {
        this.noTelp = noTelp;
    }

    public void setFoto(String foto) {
        this.foto = foto;
    }
}
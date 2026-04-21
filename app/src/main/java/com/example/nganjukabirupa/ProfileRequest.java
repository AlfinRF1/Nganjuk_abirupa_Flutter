package com.example.nganjukabirupa;

import com.google.gson.annotations.SerializedName;

public class ProfileRequest {

    @SerializedName("id_customer")
    private String idCustomer;

    @SerializedName("nama_customer")
    private String namaCustomer;

    @SerializedName("email_customer")
    private String emailCustomer;

    @SerializedName("foto") // field backend
    private String foto;

    // Constructor 1 parameter (ambil profil by ID)
    public ProfileRequest(String idCustomer) {
        this.idCustomer = idCustomer;
    }

    // Constructor 4 parameter (update profil lengkap)
    public ProfileRequest(String idCustomer, String namaCustomer, String emailCustomer, String foto) {
        this.idCustomer = idCustomer;
        this.namaCustomer = namaCustomer;
        this.emailCustomer = emailCustomer;
        this.foto = foto;
    }

    // Constructor kosong
    public ProfileRequest() {}

    // Getter & Setter
    public String getIdCustomer() { return idCustomer; }
    public void setIdCustomer(String idCustomer) { this.idCustomer = idCustomer; }

    public String getNamaCustomer() { return namaCustomer; }
    public void setNamaCustomer(String namaCustomer) { this.namaCustomer = namaCustomer; }

    public String getEmailCustomer() { return emailCustomer; }
    public void setEmailCustomer(String emailCustomer) { this.emailCustomer = emailCustomer; }

    public String getFoto() { return foto; }
    public void setFoto(String foto) { this.foto = foto; }
}
package com.example.nganjukabirupa;

import com.google.gson.annotations.SerializedName;

public class WisataModel {

    @SerializedName("id_wisata")
    private int idWisata;

    @SerializedName("nama_wisata")
    private String namaWisata;

    @SerializedName("lokasi")
    private String lokasi;

    @SerializedName("tiket_dewasa")
    private int tiketDewasa;

    @SerializedName("tiket_anak")
    private int tiketAnak;
    @SerializedName("biaya_asuransi")
    private int asuransi;
    @SerializedName("fasilitas")
    private String fasilitas;

    @SerializedName("deskripsi")
    private String deskripsi;

    @SerializedName("nama_admin")
    private String namaAdmin;

    @SerializedName("gambar")
    private String gambar;

    // Default constructor (wajib untuk Retrofit/Gson)
    public WisataModel() {}

    // Getter & Setter
    public int getIdWisata() {
        return idWisata;
    }

    public void setIdWisata(int idWisata) {
        this.idWisata = idWisata;
    }

    public String getNamaWisata() {
        return namaWisata;
    }

    public void setNamaWisata(String namaWisata) {
        this.namaWisata = namaWisata;
    }

    public String getLokasi() {
        return lokasi;
    }

    public void setLokasi(String lokasi) {
        this.lokasi = lokasi;
    }

    public int getTiketDewasa() {
        return tiketDewasa;
    }

    public void setTiketDewasa(int tiketDewasa) {
        this.tiketDewasa = tiketDewasa;
    }

    public int getTiketAnak() {
        return tiketAnak;
    }

    public void setTiketAnak(int tiketAnak) {
        this.tiketAnak = tiketAnak;
    }

    public int getAsuransi() {
        return asuransi;
    }

    public void setAsuransi(int asuransi) {
        this.asuransi = asuransi;
    }

    public String getFasilitas() {
        return fasilitas;
    }

    public void setFasilitas(String fasilitas) {
        this.fasilitas = fasilitas;
    }

    public String getDeskripsi() {
        return deskripsi;
    }

    public void setDeskripsi(String deskripsi) {
        this.deskripsi = deskripsi;
    }

    public String getNamaAdmin() {
        return namaAdmin;
    }

    public void setNamaAdmin(String namaAdmin) {
        this.namaAdmin = namaAdmin;
    }

    public String getGambar() {
        return gambar;
    }

    public void setGambar(String gambar) {
        this.gambar = gambar;
    }
}
package com.example.nganjukabirupa;

public class HargaCalculator {

    // Hitung harga tiket dewasa
    public static int hitungHargaDewasa(WisataModel wisata, int jumlahDewasa) {
        int hargaDewasa = wisata.getTiketDewasa(); // langsung int
        return jumlahDewasa * hargaDewasa;
    }

    // Hitung harga tiket anak
    public static int hitungHargaAnak(WisataModel wisata, int jumlahAnak) {
        int hargaAnak = wisata.getTiketAnak(); // langsung int
        return jumlahAnak * hargaAnak;
    }

    // Hitung biaya asuransi
    public static int hitungAsuransi(WisataModel wisata, int jumlahDewasa, int jumlahAnak) {
        int totalOrang = jumlahDewasa + jumlahAnak;
        int biayaAsuransiPerOrang = wisata.getAsuransi(); // langsung int dari API
        return totalOrang * biayaAsuransiPerOrang;
    }

    // Hitung total keseluruhan
    public static int hitungTotal(WisataModel wisata, int jumlahDewasa, int jumlahAnak) {
        return hitungHargaDewasa(wisata, jumlahDewasa)
                + hitungHargaAnak(wisata, jumlahAnak)
                + hitungAsuransi(wisata, jumlahDewasa, jumlahAnak);
    }
}
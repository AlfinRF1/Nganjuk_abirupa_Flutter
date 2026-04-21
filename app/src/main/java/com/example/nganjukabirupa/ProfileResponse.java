package com.example.nganjukabirupa;

import com.google.gson.annotations.SerializedName;

public class ProfileResponse {

    @SerializedName("success")
    private boolean success;

    @SerializedName("message")
    private String message;

    @SerializedName("profile")
    private Profile profile;

    // Getter
    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public Profile getProfile() {
        return profile;
    }

    // Inner class untuk data profil
    public static class Profile {

        // Sesuaikan dengan field JSON yang benar-benar ada
        @SerializedName("nama_customer")
        private String namaCustomer;

        @SerializedName("email_customer")
        private String emailCustomer;

        // Tambahkan kalau backend nanti sudah kirim
        @SerializedName("id_customer")
        private String idCustomer;

        @SerializedName("foto")
        private String foto;

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

        public String getFoto() {
            return foto;
        }

        // Setter (opsional)
        public void setIdCustomer(String idCustomer) {
            this.idCustomer = idCustomer;
        }

        public void setNamaCustomer(String namaCustomer) {
            this.namaCustomer = namaCustomer;
        }

        public void setEmailCustomer(String emailCustomer) {
            this.emailCustomer = emailCustomer;
        }

        public void setFoto(String foto) {
            this.foto = foto;
        }

        @Override
        public String toString() {
            return "Profile{" +
                    "idCustomer='" + idCustomer + '\'' +
                    ", namaCustomer='" + namaCustomer + '\'' +
                    ", emailCustomer='" + emailCustomer + '\'' +
                    ", foto='" + foto + '\'' +
                    '}';
        }
    }
}
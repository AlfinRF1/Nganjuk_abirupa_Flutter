package com.example.nganjukabirupa;

import com.google.gson.annotations.SerializedName;

public class RegisterResponse {

    @SerializedName("success")
    private boolean success;

    @SerializedName("message")
    private String message;

    @SerializedName("id_customer")
    private String idCustomer;

    // Getter
    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public String getIdCustomer() {
        return idCustomer;
    }
}
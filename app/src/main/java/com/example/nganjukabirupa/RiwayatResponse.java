package com.example.nganjukabirupa;

import com.google.gson.annotations.SerializedName;
import java.util.List;

public class RiwayatResponse {

    @SerializedName("status")
    private String status;

    @SerializedName("data")
    private List<RiwayatModel> data;

    public String getStatus() {
        return status;
    }

    public List<RiwayatModel> getData() {
        return data;
    }
}
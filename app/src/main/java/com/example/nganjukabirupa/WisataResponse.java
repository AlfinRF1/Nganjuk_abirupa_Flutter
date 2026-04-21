package com.example.nganjukabirupa;

import com.google.gson.annotations.SerializedName;
import java.util.List;

public class WisataResponse {

    @SerializedName("status")
    private String status;

    @SerializedName("data")
    private List<WisataModel> data;

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public List<WisataModel> getData() {
        return data;
    }

    public void setData(List<WisataModel> data) {
        this.data = data;
    }
}
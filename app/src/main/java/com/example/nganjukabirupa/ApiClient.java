package com.example.nganjukabirupa;

import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class ApiClient {
    // Base URL untuk API (PHP di folder apimobile)
    public static final String BASE_URL_API = "https://nganjukabirupa.pbltifnganjuk.com/nganjukabirupa/apimobile/";

    // Base URL untuk file upload (folder uploads di root public_html)
    public static final String BASE_URL_UPLOAD = "https://nganjukabirupa.pbltifnganjuk.com/";

    private static Retrofit retrofit;

    public static Retrofit getClient() {
        if (retrofit == null) {
            retrofit = new Retrofit.Builder()
                    .baseUrl(BASE_URL_API)
                    .addConverterFactory(GsonConverterFactory.create())
                    .build();
        }
        return retrofit;
    }
}
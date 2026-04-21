package com.example.nganjukabirupa;

import java.util.List;

import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.Field;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.GET;
import retrofit2.http.Headers;
import retrofit2.http.Multipart;
import retrofit2.http.POST;
import retrofit2.http.Part;
import retrofit2.http.Query;

public interface ApiService {

    // REGISTER
    @Headers("Content-Type: application/json")
    @POST("register.php")
    Call<ResponseBody> registerRaw(@Body RegisterRequest request);

    @Headers("Content-Type: application/json")
    @POST("register.php")
    Call<RegisterResponse> register(@Body RegisterRequest request);

    // LOGIN
    @Headers("Content-Type: application/json")
    @POST("login.php")
    Call<LoginResponse> login(@Body LoginRequest request);

    @Headers("Content-Type: application/json")
    @POST("google_login.php")
    Call<LoginResponse> googleLogin(@Body GoogleLoginRequest request);

    // PROFILE
    @Headers("Content-Type: application/json")
    @POST("get_profile.php")
    Call<ProfileResponse> getProfile(@Body ProfileRequest request);

    @Headers("Content-Type: application/json")
    @POST("get_profile_by_email.php")
    Call<ProfileResponse> getProfileByEmail(@Body EmailRequest request);

    // DATA WISATA
    @GET("get_detail_wisata.php")
    Call<WisataModel> getDetailWisata(@Query("id") int id);

    @GET("get_detail_wisata.php")
    Call<ResponseBody> getDetailWisataRaw(@Query("id") int id);

    // CHECK NAMA USER
    @GET("check_nama.php")
    Call<CheckNamaResponse> checkNama(@Query("nama_customer") String nama_customer);

    @GET("get_riwayat.php")
    Call<RiwayatResponse> getRiwayat(@Query("id_customer") int idCustomer);

    @GET("get_all_wisata.php")
    Call<WisataResponse> getAllWisata();

    // PEMESANAN & RIWAYAT
    @FormUrlEncoded
    @POST("insert_pemesanan.php")
    Call<ResponseBody> insertPemesanan(
            @Field("nama_customer") String nama,
            @Field("tlp_costumer") String telepon,
            @Field("tanggal") String tanggal,
            @Field("jml_tiket") String jmlTiket,
            @Field("harga_total") String hargaTotal,
            @Field("id_wisata") String idWisata,
            @Field("id_customer") String idCustomer
    );
    @FormUrlEncoded
    @POST("insert_riwayat.php")
    Call<ResponseBody> insertRiwayat(
            @Field("id_customer") int idCustomer,
            @Field("id_wisata") int idWisata,
            @Field("tanggal") String tanggal,
            @Field("harga_total") int hargaTotal,
            @Field("nama_customer") String nama,
            @Field("tlp_costumer") String telepon,
            @Field("jml_tiket") int jumlahTiket
    );

    // FOTO
    @Multipart
    @POST("update_foto.php")
    Call<ResponseBody> updateFoto(
            @Part("id_customer") RequestBody idCustomer,
            @Part MultipartBody.Part foto
    );

    @FormUrlEncoded
    @POST("delete_foto.php")
    Call<ResponseBody> deleteFoto(@Field("id_customer") String idCustomer);

    // UPDATE PROFILE
    @FormUrlEncoded
    @POST("updateProfile.php")
    Call<UpdateProfileResponse> updateProfile(
            @Field("id_customer") String idCustomer,
            @Field("nama_customer") String namaCustomer,
            @Field("email_customer") String emailCustomer,
            @Field("password") String password
    );
}
package com.example.nganjukabirupa;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class RiwayatAdapter extends RecyclerView.Adapter<RiwayatAdapter.ViewHolder> {

    private final List<RiwayatModel> riwayatList;

    public RiwayatAdapter(List<RiwayatModel> riwayatList) {
        this.riwayatList = riwayatList;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView ivWisataImage;
        TextView tvTanggal, tvNamaWisata, tvLokasiWisata, tvTotalHarga;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            ivWisataImage = itemView.findViewById(R.id.iv_wisata_image);
            tvTanggal = itemView.findViewById(R.id.tv_tanggal);
            tvNamaWisata = itemView.findViewById(R.id.tv_wisata_nama);
            tvLokasiWisata = itemView.findViewById(R.id.tv_wisata_lokasi);
            tvTotalHarga = itemView.findViewById(R.id.tv_total_harga);
        }
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_riwayat_card, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        RiwayatModel model = riwayatList.get(position);
        Context context = holder.itemView.getContext();

        // Nama & lokasi wisata
        holder.tvNamaWisata.setText(!TextUtils.isEmpty(model.getNamaWisata()) ? model.getNamaWisata() : "-");
        holder.tvLokasiWisata.setText(!TextUtils.isEmpty(model.getLokasi()) ? model.getLokasi() : "-");

        // Total harga langsung dari DB (tiket + asuransi)
        holder.tvTotalHarga.setText("Total Tiket : Rp. " + String.format("%,d", model.getTotalHarga()));

        // Image: cek apakah wisata tetap atau generic
        int drawableRes = getDrawableForWisata(model.getNamaWisata());
        if (drawableRes != R.drawable.default_wisata) {
            holder.ivWisataImage.setImageResource(drawableRes);
        } else {
            // kalau generic → load dari URL API
            String imageUrl = model.getGambar();
            if (!TextUtils.isEmpty(imageUrl)) {
                if (!imageUrl.startsWith("http")) {
                    imageUrl = "https://nganjukabirupa.pbltifnganjuk.com/assets/images/destinasi/" + imageUrl;
                }
                Glide.with(context)
                        .load(imageUrl)
                        .centerCrop()
                        .placeholder(R.drawable.default_wisata)
                        .error(R.drawable.default_wisata)
                        .into(holder.ivWisataImage);
            } else {
                holder.ivWisataImage.setImageResource(R.drawable.default_wisata);
            }
        }

        // Format tanggal fleksibel
        String tanggalStr = "-";
        if (!TextUtils.isEmpty(model.getTanggal())) {
            try {
                String[] patterns = {"yyyy-MM-dd", "yyyy-MM-dd HH:mm:ss"};
                Date date = null;
                for (String p : patterns) {
                    try {
                        date = new SimpleDateFormat(p, Locale.getDefault()).parse(model.getTanggal());
                        if (date != null) break;
                    } catch (Exception ignored) {}
                }
                if (date != null) {
                    tanggalStr = new SimpleDateFormat("dd MMM yyyy", Locale.getDefault()).format(date);
                } else {
                    tanggalStr = model.getTanggal();
                }
            } catch (Exception e) {
                tanggalStr = model.getTanggal();
            }
        }
        holder.tvTanggal.setText(tanggalStr);

        // Klik item → buka DetailRiwayatBottomSheet
        holder.itemView.setOnClickListener(v -> {
            String idTransaksi = model.getIdTransaksi() != null ? model.getIdTransaksi() : "-";
            String totalStr = "Rp. " + String.format("%,d", model.getTotalHarga());

            DetailRiwayatBottomSheet bottomSheet = DetailRiwayatBottomSheet.newInstance(
                    model.getNamaWisata(),
                    model.getLokasi(),
                    model.getIdTransaksi(),
                    model.getTanggal(),
                    model.getStatus(),
                    model.getMetodePembayaran(), // pasti QRIS
                    totalStr
            );

            bottomSheet.show(((AppCompatActivity) context).getSupportFragmentManager(), "detail_riwayat");
        });
    }

    @Override
    public int getItemCount() {
        return riwayatList != null ? riwayatList.size() : 0;
    }

    // Pilih drawable sesuai nama wisata tetap
    private int getDrawableForWisata(String namaWisata) {
        if (namaWisata == null) return R.drawable.default_wisata;
        String lower = namaWisata.toLowerCase();
        if (lower.contains("sedudo")) return R.drawable.wisata_air_terjun_sedudo;
        if (lower.contains("roro kuning")) return R.drawable.wisata_roro_kuning;
        if (lower.contains("margo tresno")) return R.drawable.wisata_goa_margotresno;
        if (lower.contains("sri tanjung")) return R.drawable.wisata_sritanjung;
        if (lower.contains("anjuk ladang") || lower.contains("tral")) return R.drawable.wisata_tral;
        return R.drawable.default_wisata; // default → nanti dicek Glide
    }
}
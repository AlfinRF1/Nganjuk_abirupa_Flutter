package com.example.nganjukabirupa;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;

import java.util.ArrayList;
import java.util.List;

public class WisataAdapter extends RecyclerView.Adapter<WisataAdapter.WisataViewHolder> implements Filterable {

    private Context context;
    private List<WisataModel> wisataList;
    private List<WisataModel> wisataListFull; // backup untuk filter

    public WisataAdapter(Context context, List<WisataModel> wisataList) {
        this.context = context;
        this.wisataList = new ArrayList<>(wisataList);
        this.wisataListFull = new ArrayList<>(wisataList);
    }

    public void setData(List<WisataModel> newList) {
        wisataList.clear();
        wisataList.addAll(newList);
        wisataListFull.clear();
        wisataListFull.addAll(newList);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public WisataViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_wisata, parent, false);
        return new WisataViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull WisataViewHolder holder, int position) {
        WisataModel wisata = wisataList.get(position);

        holder.tvWisataName.setText(wisata.getNamaWisata());
        holder.tvWisataLocation.setText(wisata.getLokasi());

        // Mapping gambar
        int id = wisata.getIdWisata();
        switch (id) {
            case 12: holder.imgWisata.setImageResource(R.drawable.wisata_air_terjun_sedudo); break;
            case 13: holder.imgWisata.setImageResource(R.drawable.wisata_roro_kuning); break;
            case 14: holder.imgWisata.setImageResource(R.drawable.wisata_goa_margotresno); break;
            case 15: holder.imgWisata.setImageResource(R.drawable.wisata_sritanjung); break;
            case 16: holder.imgWisata.setImageResource(R.drawable.wisata_tral); break;
            default:
                String imageUrl = wisata.getGambar();
                if (imageUrl != null && !imageUrl.isEmpty()) {
                    if (!imageUrl.startsWith("http")) {
                        imageUrl = "https://nganjukabirupa.pbltifnganjuk.com/assets/images/destinasi/" + imageUrl;
                    }
                    Glide.with(context)
                            .load(imageUrl)
                            .centerCrop()
                            .placeholder(R.drawable.default_wisata)
                            .error(R.drawable.default_wisata)
                            .into(holder.imgWisata);
                } else {
                    holder.imgWisata.setImageResource(R.drawable.default_wisata);
                }
                break;
        }

        // Klik seluruh item → buka detail
        holder.itemView.setOnClickListener(v -> openDetail(wisata));

        // Klik tombol "Selengkapnya" → buka detail
        holder.btnDetail.setOnClickListener(v -> openDetail(wisata));
    }

    private void openDetail(WisataModel wisata) {
        Intent intent;
        switch (wisata.getIdWisata()) {
            case 12: intent = new Intent(context, DetailSedudo.class); break;
            case 13: intent = new Intent(context, DetailRoro.class); break;
            case 14: intent = new Intent(context, DetailGoa.class); break;
            case 15: intent = new Intent(context, DetailSri.class); break;
            case 16: intent = new Intent(context, DetailTral.class); break;
            default: intent = new Intent(context, DetailWisataGeneric.class); break;
        }

        intent.putExtra("id_wisata", wisata.getIdWisata());
        intent.putExtra("nama_wisata", wisata.getNamaWisata());
        intent.putExtra("lokasi", wisata.getLokasi());
        intent.putExtra("deskripsi", wisata.getDeskripsi());
        intent.putExtra("tiket", "Dewasa : " + wisata.getTiketDewasa() +
                "\nAnak-anak : " + wisata.getTiketAnak() +
                "\nAsuransi : " + wisata.getAsuransi());
        intent.putExtra("fasilitas", wisata.getFasilitas());
        intent.putExtra("gambar", wisata.getGambar());
        intent.putExtra("hargaDewasa", wisata.getTiketDewasa());
        intent.putExtra("hargaAnak", wisata.getTiketAnak());
        intent.putExtra("tarifAsuransi", wisata.getAsuransi());

        context.startActivity(intent);
    }

    @Override
    public int getItemCount() {
        return wisataList.size();
    }

    @Override
    public Filter getFilter() {
        return wisataFilter;
    }

    private final Filter wisataFilter = new Filter() {
        @Override
        protected FilterResults performFiltering(CharSequence constraint) {
            List<WisataModel> filteredList = new ArrayList<>();
            if (constraint == null || constraint.length() == 0) {
                filteredList.addAll(wisataListFull);
            } else {
                String filterPattern = constraint.toString().toLowerCase().trim();
                for (WisataModel item : wisataListFull) {
                    if (item.getNamaWisata().toLowerCase().contains(filterPattern) ||
                            item.getLokasi().toLowerCase().contains(filterPattern)) {
                        filteredList.add(item);
                    }
                }
            }
            FilterResults results = new FilterResults();
            results.values = filteredList;
            return results;
        }

        @Override
        protected void publishResults(CharSequence constraint, FilterResults results) {
            wisataList.clear();
            wisataList.addAll((List<WisataModel>) results.values);
            notifyDataSetChanged();
        }
    };

    public static class WisataViewHolder extends RecyclerView.ViewHolder {
        ImageView imgWisata;
        TextView tvWisataName, tvWisataLocation;
        Button btnDetail;

        public WisataViewHolder(@NonNull View itemView) {
            super(itemView);
            imgWisata = itemView.findViewById(R.id.imgWisata);
            tvWisataName = itemView.findViewById(R.id.tvWisataName);
            tvWisataLocation = itemView.findViewById(R.id.tvWisataLocation);
            btnDetail = itemView.findViewById(R.id.btnDetail);
        }
    }
}

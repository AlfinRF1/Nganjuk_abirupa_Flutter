package com.example.nganjukabirupa;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.material.bottomsheet.BottomSheetDialogFragment;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class DetailRiwayatBottomSheet extends BottomSheetDialogFragment {

    private String namaWisata, lokasi, idTransaksi, tanggal, status, metodePembayaran, totalHarga;

    public static DetailRiwayatBottomSheet newInstance(String namaWisata, String lokasi, String idTransaksi,
                                                       String tanggal, String status, String metodePembayaran, String totalHarga) {
        DetailRiwayatBottomSheet fragment = new DetailRiwayatBottomSheet();
        Bundle args = new Bundle();
        args.putString("nama_wisata", namaWisata);
        args.putString("lokasi", lokasi);
        args.putString("id_transaksi", idTransaksi);
        args.putString("tanggal", tanggal);
        args.putString("status", status);
        args.putString("metode_pembayaran", metodePembayaran);
        args.putString("total_harga", totalHarga);
        fragment.setArguments(args);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.bottomsheet_detailriwayat, container, false);

        if (getArguments() != null) {
            namaWisata = getArguments().getString("nama_wisata", "-");
            lokasi = getArguments().getString("lokasi", "-");
            idTransaksi = getArguments().getString("id_transaksi", "-");
            tanggal = getArguments().getString("tanggal", "-");
            status = getArguments().getString("status", "-");
            metodePembayaran = getArguments().getString("metode_pembayaran", "QRIS");
            totalHarga = getArguments().getString("total_harga", "Rp. 0");
        }

        ((TextView) view.findViewById(R.id.tv_wisata_name)).setText(namaWisata);
        ((TextView) view.findViewById(R.id.tv_wisata_location)).setText(lokasi);
        ((TextView) view.findViewById(R.id.tv_transaction_id)).setText(idTransaksi);
        ((TextView) view.findViewById(R.id.tv_transaction_status)).setText(status);
        ((TextView) view.findViewById(R.id.tv_payment_method)).setText(metodePembayaran);

        // Format tanggal
        TextView tvTanggal = view.findViewById(R.id.tv_transaction_date);
        tvTanggal.setText(formatTanggal(tanggal));

        // Format total harga
        TextView tvTotal = view.findViewById(R.id.tv_transaction_total);
        tvTotal.setText(formatTotalHarga(totalHarga));

        return view;
    }

    private String formatTanggal(String tanggal) {
        try {
            if (tanggal != null && !tanggal.isEmpty()) {
                String inputFormatStr = tanggal.contains(" ") ? "yyyy-MM-dd HH:mm:ss" : "yyyy-MM-dd";
                SimpleDateFormat inputFormat = new SimpleDateFormat(inputFormatStr);
                Date date = inputFormat.parse(tanggal);

                SimpleDateFormat outputFormat = new SimpleDateFormat("dd MMM yyyy", Locale.getDefault());
                return date != null ? outputFormat.format(date) : tanggal;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return tanggal != null ? tanggal : "-";
    }

    private String formatTotalHarga(String total) {
        try {
            if (total != null && !total.isEmpty()) {
                int amount = Integer.parseInt(total.replaceAll("[^\\d]", ""));
                return "Rp. " + String.format("%,d", amount);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return total != null ? total : "Rp. 0";
    }
}

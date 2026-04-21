package com.example.nganjukabirupa;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;

public class PilihPengunjungBottomSheet extends BottomSheetDialogFragment {

    private ImageView btnMinDewasa, btnPlusDewasa, btnMinAnak, btnPlusAnak;
    private TextView tvCountDewasa, tvCountAnak;
    private Button btnSimpan;

    private int countDewasa = 1;
    private int countAnak = 0;

    public interface PengunjungDialogListener {
        void onDataPengunjungDisimpan(int dewasa, int anak);
    }

    private PengunjungDialogListener listener;

    // set listener dari Activity sebelum show()
    public void setListener(PengunjungDialogListener listener) {
        this.listener = listener;
    }

    @Nullable
    @Override
    public View onCreateView(
            @NonNull LayoutInflater inflater,
            @Nullable ViewGroup container,
            @Nullable Bundle savedInstanceState
    ) {
        // gunakan layout khusus bottomsheet
        return inflater.inflate(R.layout.bottomsheet_pilihpengunjung, container, false);
    }

    @Override
    public void onStart() {
        super.onStart();
        View bottomSheet = getDialog().findViewById(com.google.android.material.R.id.design_bottom_sheet);
        if (bottomSheet != null) {
            BottomSheetBehavior<View> behavior = BottomSheetBehavior.from(bottomSheet);
            bottomSheet.getLayoutParams().height =
                    (int) (requireContext().getResources().getDisplayMetrics().heightPixels * 0.75);
            behavior.setState(BottomSheetBehavior.STATE_EXPANDED);
        }
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        btnMinDewasa = view.findViewById(R.id.btnMinDewasa);
        btnPlusDewasa = view.findViewById(R.id.btnPlusDewasa);
        tvCountDewasa = view.findViewById(R.id.tvCountDewasa);

        btnMinAnak = view.findViewById(R.id.btnMinAnak);
        btnPlusAnak = view.findViewById(R.id.btnPlusAnak);
        tvCountAnak = view.findViewById(R.id.tvCountAnak);

        btnSimpan = view.findViewById(R.id.btnSimpan);

        updateCountViews();

        btnPlusDewasa.setOnClickListener(v -> {
            countDewasa++;
            updateCountViews();
        });

        btnMinDewasa.setOnClickListener(v -> {
            if (countDewasa > 1) {
                countDewasa--;
                updateCountViews();
            }
        });

        btnPlusAnak.setOnClickListener(v -> {
            countAnak++;
            updateCountViews();
        });

        btnMinAnak.setOnClickListener(v -> {
            if (countAnak > 0) {
                countAnak--;
                updateCountViews();
            }
        });

        btnSimpan.setOnClickListener(v -> {
            if (listener != null) {
                listener.onDataPengunjungDisimpan(countDewasa, countAnak);
            }
            dismiss();
        });
    }

    private void updateCountViews() {
        tvCountDewasa.setText(String.format("%02d", countDewasa));
        tvCountAnak.setText(String.format("%02d", countAnak));

        btnMinDewasa.setEnabled(countDewasa > 1);
        btnMinAnak.setEnabled(countAnak > 0);
    }
}
package com.example.nganjukabirupa;

import android.content.Context;
import android.net.Uri;
import android.util.Log;
import android.webkit.MimeTypeMap;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;

public class FileUtils {

    public static String getPath(Context context, Uri uri) {
        try {
            // Ambil MIME type dari URI
            String mimeType = context.getContentResolver().getType(uri);
            String extension = MimeTypeMap.getSingleton().getExtensionFromMimeType(mimeType);

            if (extension == null) {
                extension = "tmp"; // fallback kalau tidak ketemu
            }

            // Buat file sementara dengan nama unik
            File tempFile = File.createTempFile("upload_", "." + extension, context.getCacheDir());

            // Copy data dengan try-with-resources
            try (InputStream inputStream = context.getContentResolver().openInputStream(uri);
                 OutputStream outputStream = new FileOutputStream(tempFile)) {

                if (inputStream == null) return null;

                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = inputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, bytesRead);
                }
            }

            return tempFile.getAbsolutePath();

        } catch (Exception e) {
            Log.e("FileUtils", "getPath error: " + e.getMessage(), e);
            return null;
        }
    }
}
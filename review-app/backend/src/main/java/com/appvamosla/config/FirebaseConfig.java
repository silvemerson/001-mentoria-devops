package com.appvamosla.config;

import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.FirestoreOptions;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class FirebaseConfig {

    @Bean
    public Firestore firestore() {
        String emulatorHost = System.getenv("FIRESTORE_EMULATOR_HOST");
        
        if (emulatorHost != null && !emulatorHost.isEmpty()) {
            System.out.println("📌 Conectando ao Firestore Emulator: " + emulatorHost);
            // Quando FIRESTORE_EMULATOR_HOST está setada, o FirestoreOptions automaticamente usa o emulator
        } else {
            System.out.println("✅ Usando Firestore produção");
        }
        
        return FirestoreOptions.getDefaultInstance().getService();
    }
}
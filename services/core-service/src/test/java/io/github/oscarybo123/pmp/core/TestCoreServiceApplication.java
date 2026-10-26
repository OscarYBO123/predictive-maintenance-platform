package io.github.oscarybo123.pmp.core;

import org.springframework.boot.SpringApplication;

/**
 * Runs core-service locally against a throwaway PostgreSQL container, no Compose needed.
 */
public class TestCoreServiceApplication {

    public static void main(String[] args) {
        SpringApplication.from(CoreServiceApplication::main)
                .with(TestcontainersConfiguration.class)
                .run(args);
    }
}

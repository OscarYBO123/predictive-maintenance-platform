package io.github.oscarybo123.pmp.core.ping;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.test.web.servlet.assertj.MockMvcTester;

@WebMvcTest(PingController.class)
@Import(PingControllerTest.FixedClockConfig.class)
class PingControllerTest {

    static final Instant NOW = Instant.parse("2026-01-01T12:00:00Z");

    @Autowired
    MockMvcTester mvc;

    @Test
    void returnsStatusServiceAndTimestamp() {
        assertThat(mvc.get().uri("/api/v1/ping"))
                .hasStatusOk()
                .bodyJson()
                .convertTo(PingResponse.class)
                .isEqualTo(new PingResponse("UP", "core-service", NOW));
    }

    @TestConfiguration(proxyBeanMethods = false)
    static class FixedClockConfig {

        @Bean
        Clock clock() {
            return Clock.fixed(NOW, ZoneOffset.UTC);
        }
    }
}

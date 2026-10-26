package io.github.oscarybo123.pmp.core.ping;

import java.time.Clock;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Liveness probe for clients (e.g. the frontend) to verify end-to-end connectivity.
 * Infrastructure health is exposed separately through Actuator.
 */
@RestController
@RequestMapping("/api/v1/ping")
class PingController {

    private final String serviceName;
    private final Clock clock;

    PingController(@Value("${spring.application.name}") String serviceName, Clock clock) {
        this.serviceName = serviceName;
        this.clock = clock;
    }

    @GetMapping
    PingResponse ping() {
        return new PingResponse("UP", serviceName, clock.instant());
    }
}

package io.github.oscarybo123.pmp.core.ping;

import java.time.Instant;

public record PingResponse(String status, String service, Instant timestamp) {
}

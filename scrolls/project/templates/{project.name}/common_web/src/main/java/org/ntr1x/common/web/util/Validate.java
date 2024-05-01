package org.ntr1x.common.web.util;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.Objects;

@RequiredArgsConstructor(access = AccessLevel.PRIVATE)
public class Validate {

    private final HttpStatus status;
    private final String message;

    public static Validate create(HttpStatus status, String message) {
        return new Validate(status, message);
    }

    public static Validate create(int statusCode, String message) {
        return new Validate(HttpStatus.valueOf(statusCode), message);
    }

    public void equals(Object a, Object b) {
        if (!Objects.equals(a, b)) {
            throw new ResponseStatusException(status, message);
        }
    }

    public void isTrue(boolean expression) {
        if (!expression) {
            throw new ResponseStatusException(status, message);
        }
    }

    public ResponseStatusException buildError() {
        return new ResponseStatusException(status, message);
    }
}

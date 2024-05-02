package org.ntr1x.common.web.component;

import lombok.Builder;
import lombok.Data;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.server.ResponseStatusException;

@ControllerAdvice
public class AppExceptionHandler {

    @Data
    @Builder(toBuilder = true)
    public static class ErrorData {
        private HttpStatusCode status;
        private String message;
        private String reason;
        private int code;
    }

    @ExceptionHandler(value = ResponseStatusException.class)
    protected ResponseEntity<ErrorData> handleResponseStatusException(ResponseStatusException ex) {
        HttpStatusCode status = ex.getStatusCode();

        ErrorData data = ErrorData
                .builder()
                .message(ex.getMessage())
                .reason(ex.getReason())
                .status(status)
                .code(status.value())
                .build();

        return ResponseEntity
                .status(status)
                .body(data);
    }

    @ExceptionHandler(value = AccessDeniedException.class)
    protected ResponseEntity<ErrorData> handleResponseStatusException(AccessDeniedException ex) {
        HttpStatus status = HttpStatus.UNAUTHORIZED;

        ErrorData data = ErrorData
                .builder()
                .message(ex.getMessage())
                .reason(status.getReasonPhrase())
                .status(status)
                .code(status.value())
                .build();

        return ResponseEntity
                .status(status)
                .body(data);
    }

    @ExceptionHandler(value = AuthenticationException.class)
    protected ResponseEntity<ErrorData> handleResponseStatusException(AuthenticationException ex) {
        HttpStatus status = HttpStatus.UNAUTHORIZED;

        ErrorData data = ErrorData
                .builder()
                .message(ex.getMessage())
                .reason(status.getReasonPhrase())
                .status(status)
                .code(status.value())
                .build();

        return ResponseEntity
                .status(status)
                .body(data);
    }

    @ExceptionHandler(value = Exception.class)
    protected ResponseEntity<ErrorData> handleException(Exception ex) {
        HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;

        ErrorData data = ErrorData
                .builder()
                .message(ex.getMessage())
                .reason(status.getReasonPhrase())
                .status(status)
                .code(status.value())
                .build();

        return ResponseEntity
                .status(status)
                .body(data);
    }
}

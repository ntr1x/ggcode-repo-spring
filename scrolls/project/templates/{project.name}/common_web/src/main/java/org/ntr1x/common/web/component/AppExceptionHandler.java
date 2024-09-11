package org.ntr1x.common.web.component;

import lombok.Builder;
import lombok.Data;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.BindException;
import org.springframework.web.ErrorResponse;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.server.ResponseStatusException;

import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@ControllerAdvice
public class AppExceptionHandler {

    @Data
    @Builder(toBuilder = true)
    public static class ErrorData {
        private int code;
        private HttpStatusCode status;
        private String reason;
        private String message;
        private Collection<NestedError> errors;
    }

    @Data
    @Builder(toBuilder = true)
    public static class NestedError {
        private String ref;
        private NestedErrorType type;
        private String message;

        public enum NestedErrorType {
            GLOBAL,
            FIELD
        }
    }

    @ExceptionHandler(value = ResponseStatusException.class)
    public ResponseEntity<ErrorData> handleResponseStatusException(ResponseStatusException ex) {
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
    public ResponseEntity<ErrorData> handleAccessDeniedException(AccessDeniedException ex) {
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
    public ResponseEntity<ErrorData> handleAuthenticationException(AuthenticationException ex) {
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

    @ExceptionHandler(value = BindException.class)
    public ResponseEntity<ErrorData> handleException(BindException ex) {

        HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
        String message = ex.getMessage();

        if (ex instanceof ErrorResponse errorResponse) {
            status = HttpStatus.resolve(errorResponse.getStatusCode().value());
            message = errorResponse.getBody().getDetail();
        }

        Stream<NestedError> fieldErrors = ex.getFieldErrors().stream().map(error -> NestedError
                .builder()
                .type(NestedError.NestedErrorType.FIELD)
                .ref(String.format("%s:%s", error.getObjectName(), error.getField()))
                .message(error.getDefaultMessage())
                .build());

        Stream<NestedError> globalErrors = ex.getGlobalErrors().stream().map(error -> NestedError
                .builder()
                .type(NestedError.NestedErrorType.GLOBAL)
                .ref(error.getObjectName())
                .message(error.getDefaultMessage())
                .build());

        List<NestedError> errors = Stream
                .concat(fieldErrors, globalErrors)
                .collect(Collectors.toList());

        ErrorData data = ErrorData
                .builder()
                .message(message)
                .reason(status.getReasonPhrase())
                .status(status)
                .code(status.value())
                .errors(errors)
                .build();

        return ResponseEntity
                .status(status)
                .body(data);
    }

    @ExceptionHandler(value = Exception.class)
    public ResponseEntity<ErrorData> handleException(Exception ex) {

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

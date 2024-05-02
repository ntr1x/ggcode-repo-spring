package org.ntr1x.common.web.serializer;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.SerializerProvider;
import com.fasterxml.jackson.databind.ser.std.StdSerializer;
import org.springframework.data.domain.PageImpl;

import java.io.IOException;

public class JsonPageSerializer extends StdSerializer<PageImpl> {

    public JsonPageSerializer() {
        super(PageImpl.class);
    }

    @Override
    public void serialize(PageImpl value, JsonGenerator gen, SerializerProvider provider) throws IOException {
        gen.writeStartObject();
        gen.writeNumberField("totalPages", value.getTotalPages());
        gen.writeNumberField("totalElements", value.getTotalElements());
        gen.writeNumberField("size", value.getSize());
        gen.writeNumberField("number", value.getNumber());
        gen.writeNumberField("numberOfElements", value.getNumberOfElements());
        gen.writeBooleanField("first", value.isFirst());
        gen.writeBooleanField("last", value.isLast());
        gen.writeBooleanField("empty", value.isEmpty());
        gen.writeFieldName("sort");
        provider.defaultSerializeValue(value.getSort(), gen);
        gen.writeFieldName("pageable");
        provider.defaultSerializeValue(value.getPageable(), gen);
        gen.writeFieldName("content");
        provider.defaultSerializeValue(value.getContent(), gen);
        gen.writeEndObject();
    }

}
#!/bin/sh
# shellcheck disable=SC2086
# Script to generate PHP gRPC classes with both client and server code

PROTO_PATH=${PROTO_PATH:-proto}
OUTPUT_PATH=${OUTPUT_PATH:-php}

echo "Generating PHP gRPC classes..."
echo "Proto path: ${PROTO_PATH}"
echo "Output path: ${OUTPUT_PATH}"

mkdir -p ${OUTPUT_PATH}

protoc \
  --plugin=protoc-gen-grpc=/usr/local/bin/protoc-gen-grpc \
  --plugin=protoc-gen-php-grpc=/usr/local/bin/protoc-gen-php-grpc \
  --php_out=${OUTPUT_PATH} \
  --grpc_out=generate_server:${OUTPUT_PATH} \
  --php-grpc_out=${OUTPUT_PATH} \
  --proto_path=. \
  ${PROTO_PATH}/*.proto

echo "Generation complete!"
echo ""
echo "Generated files:"
echo "  - Message classes (php_out)"
echo "  - Client classes: *Client.php, *Stub.php (grpc_out)"
echo "  - Server interfaces: *Interface.php (php-grpc_out)"

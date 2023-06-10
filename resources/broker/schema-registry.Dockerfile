FROM bitnami/schema-registry:latest

EXPOSE 9090
EXPOSE 9091

COPY registry.yaml /opt/schema-registry/etc/registry.yaml
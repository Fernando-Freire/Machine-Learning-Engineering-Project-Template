FROM bitnami/kafka:3.4.1

EXPOSE 9092

COPY server.properties /etc/kafka/server.properties
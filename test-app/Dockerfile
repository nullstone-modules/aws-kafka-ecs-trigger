FROM alpine:latest

WORKDIR /app
COPY ./dump-payload.sh .
RUN chmod +x /app/dump-payload.sh

CMD ["/app/dump-payload.sh"]

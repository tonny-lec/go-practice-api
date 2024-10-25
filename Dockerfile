FROM golang:1.22-alpine

RUN apk update && apk add git
RUN apk --update add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata && \
    rm -rf /var/cache/apk/*

WORKDIR /usr/src/app

ENV TZ /usr/share/zoneinfo/Asia/Tokyo

RUN go install github.com/swaggo/swag/cmd/swag@latest
RUN go install github.com/air-verse/air@latest

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download && go mod verify
RUN go mod tidy

COPY ./controller .
COPY ./httputil .
COPY ./model .
COPY ./docs .
COPY ./main.go .

# create swatter
# RUN swag init
# RUN swag fmt

CMD ["air", "-c", ".air.toml"]

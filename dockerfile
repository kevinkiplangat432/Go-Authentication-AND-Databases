# -- Build the binary --
FROM golang:1.23-alpine AS builder

# set the working directory inside the container 
WORKDIR /app
ENV GOTOOLCHAIN=auto

# copy dep files
COPY go.mod ./
RUN go mod download

COPY . .

# build a static binary file 
RUN CGO_ENABLED=0 GOOS=linux go build -o custodian ./cmd/custodian

# run the binary

FROM alpine:3.19 AS runner

# create a non-root user for security
RUN adduser -D appuser
USER appuser

WORKDIR /app 

# copy only the compiled binary from the builder stage
COPY --from=builder /app/custodian .

# Expose the application port
EXPOSE 8080

# run the binary 
CMD ["./custodian"]
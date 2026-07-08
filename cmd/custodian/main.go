package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/kevinkiplangat432/custodian/internal/database"
)

func main() {
    log.Println("Starting custodian AI compliance servise Engine")

    // create a structural master context that listens for the system cancellation
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    // extract the variable from the env
    dbURL := os.Getenv("DATABASE_URL")
    redisURL := os.Getenv("REDIS_URL")
    appPort := os.Getenv("PORT")

    if dbURL == "" || redisURL == "" {
        log.Fatal("Critical step erro: DATABASE_URL or REDIS_URL empty")

    }
    infra, err := database.ConnectService(ctx, dbURL, redisURL)
    if err !=nil{
        log.Fatalf("system initialization halted due to Store failure: %v ", err)
    }
    // gracefully drain pool lines before turning off power lines at termination

    defer infra.DB.Close()  
    defer infra.Redis.Close()

    log.Printf("app container is fully listening on port %s inside the Matrix", appPort)


    // keep application runnning infinitely until a safe terminatiom  event occurs
    StopSignal := make(chan os.Signal, 1)
    signal.Notify(StopSignal, os.Interrupt, syscall.SIGTERM)

    <-StopSignal
    log.Println("Graceful shutdown signal received. Emptying out the data streams")
}

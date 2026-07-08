package database

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/redis/go-redis/v9"
)

// hold the connection pools
type Infrastructure struct {
	DB *pgxpool.Pool
	Redis *redis.Client
}

// connect services initializes both postgres and redis
func ConnectService(ctx context.Context, dbURL, redisURL string) (*Infrastructure, error) {

	// confiugure postgress pooling
	config, err := pgxpool.ParseConfig(dbURL)
	if err != nil {
		return nil, fmt.Errorf("unable to parse database url: %w", err)
	}

	// configuration settings
	config.MaxConns = 25 // maximum warm connection in the pool
	config.MinConns = 5 // keep 5 connections open all time, idle and ready
	config.MaxConnIdleTime =30 * time.Minute  //automatically drop connections sitting idle too long
	config.MaxConnLifetime = 1 * time.Hour //periodically rotate connections to prevent memory leaks
	// establish the connection pool
	dbPool, err := pgxpool.NewWithConfig(ctx, config)
	if err != nil {
		return nil, fmt.Errorf("Unable to create connection poool: %w", err)
	}
	// verify the working of the pool by sending a quick ping
	if err := dbPool.Ping(ctx); err != nil {
		return nil, fmt.Errorf("Postgres ping failed: %w", err)

	}
	log.Println("Postgres pgxpool initialized successfully with stable connection nodes ")

	// redis client
	redisOpt, err:= redis.ParseURL(redisURL)
	if err != nil {
		redisOpt = &redis.Options{Addr: redisURL}
	}

	redisClient := redis.NewClient(redisOpt)

	// verify redis connedtion 
	if err := redisClient.Ping(ctx).Err(); err!= nil {
		return nil, fmt.Errorf("redis ping failed: %w", err)
	}
	log.Println("redis client connected and listening to the local highway")

	return &Infrastructure{
		DB: dbPool,
		Redis: redisClient,
	}, nil
}
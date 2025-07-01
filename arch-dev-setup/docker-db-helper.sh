#!/bin/bash

# Docker Database Helper for Development Environment

set -e

print_info() {
    echo -e "\033[1;33m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

case "${1:-help}" in
    "postgres")
        print_info "Starting PostgreSQL container..."
        docker run --name dev-postgres -d \
            -e POSTGRES_PASSWORD=devpassword \
            -e POSTGRES_USER=developer \
            -e POSTGRES_DB=development \
            -p 5432:5432 \
            -v postgres_data:/var/lib/postgresql/data \
            postgres:latest
        print_success "PostgreSQL running on localhost:5432"
        print_info "Connection details:"
        echo "  Host: localhost"
        echo "  Port: 5432"
        echo "  Database: development"
        echo "  Username: developer"
        echo "  Password: devpassword"
        print_info "Connect with: psql -h localhost -U developer -d development"
        print_info "Or use DBeaver/pgAdmin4 with the above credentials"
        ;;
    "mysql")
        print_info "Starting MySQL container..."
        docker run --name dev-mysql -d \
            -e MYSQL_ROOT_PASSWORD=rootpassword \
            -e MYSQL_DATABASE=development \
            -e MYSQL_USER=developer \
            -e MYSQL_PASSWORD=devpassword \
            -p 3306:3306 \
            -v mysql_data:/var/lib/mysql \
            mysql:latest
        print_success "MySQL running on localhost:3306"
        print_info "Connection details:"
        echo "  Host: localhost"
        echo "  Port: 3306"
        echo "  Database: development"
        echo "  Username: developer (or root)"
        echo "  Password: devpassword (root: rootpassword)"
        print_info "Connect with: mysql -h localhost -u developer -p development"
        print_info "Or use DBeaver/MySQL Workbench with the above credentials"
        ;;
    "redis")
        print_info "Starting Redis container..."
        docker run --name dev-redis -d \
            -p 6379:6379 \
            -v redis_data:/data \
            redis:latest redis-server --appendonly yes
        print_success "Redis running on localhost:6379"
        print_info "Connect with: redis-cli -h localhost -p 6379"
        ;;
    "mongo")
        print_info "Starting MongoDB container..."
        docker run --name dev-mongo -d \
            -e MONGO_INITDB_ROOT_USERNAME=developer \
            -e MONGO_INITDB_ROOT_PASSWORD=devpassword \
            -e MONGO_INITDB_DATABASE=development \
            -p 27017:27017 \
            -v mongo_data:/data/db \
            mongo:latest
        print_success "MongoDB running on localhost:27017"
        print_info "Connection details:"
        echo "  Host: localhost"
        echo "  Port: 27017"
        echo "  Database: development"
        echo "  Username: developer"
        echo "  Password: devpassword"
        print_info "Connect with: mongosh mongodb://developer:devpassword@localhost:27017/development"
        ;;
    "status")
        print_info "Database container status:"
        docker ps --filter "name=dev-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        ;;
    "stop")
        if [ -z "$2" ]; then
            print_info "Stopping all database containers..."
            docker stop $(docker ps -q --filter "name=dev-") 2>/dev/null || print_info "No database containers running"
        else
            print_info "Stopping $2 container..."
            docker stop "dev-$2"
        fi
        ;;
    "remove")
        if [ -z "$2" ]; then
            print_info "Removing all database containers..."
            docker rm $(docker ps -aq --filter "name=dev-") 2>/dev/null || print_info "No database containers to remove"
        else
            print_info "Removing $2 container and data..."
            docker rm "dev-$2"
            docker volume rm "${2}_data" 2>/dev/null || true
        fi
        ;;
    "logs")
        if [ -z "$2" ]; then
            print_error "Please specify database: postgres, mysql, redis, or mongo"
            exit 1
        fi
        docker logs "dev-$2"
        ;;
    "connect")
        case "$2" in
            "postgres")
                docker exec -it dev-postgres psql -U developer -d development
                ;;
            "mysql")
                docker exec -it dev-mysql mysql -u developer -p development
                ;;
            "redis")
                docker exec -it dev-redis redis-cli
                ;;
            "mongo")
                docker exec -it dev-mongo mongosh mongodb://developer:devpassword@localhost:27017/development
                ;;
            *)
                print_error "Please specify database: postgres, mysql, redis, or mongo"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Docker Database Helper for Development"
        echo "Usage: $0 [command] [options]"
        echo
        echo "Database Commands:"
        echo "  postgres   - Start PostgreSQL container"
        echo "  mysql      - Start MySQL container"
        echo "  redis      - Start Redis container"
        echo "  mongo      - Start MongoDB container"
        echo
        echo "Management Commands:"
        echo "  status     - Show running database containers"
        echo "  stop [db]  - Stop database container(s)"
        echo "  remove [db]- Remove database container(s) and data"
        echo "  logs [db]  - Show database container logs"
        echo "  connect [db] - Connect to database via CLI"
        echo
        echo "Examples:"
        echo "  $0 postgres          # Start PostgreSQL"
        echo "  $0 status            # Show all running databases"
        echo "  $0 stop postgres     # Stop PostgreSQL"
        echo "  $0 connect mysql     # Connect to MySQL CLI"
        echo "  $0 remove            # Remove all database containers"
        echo
        echo "Admin Tools:"
        echo "  DBeaver    - Universal database tool"
        echo "  pgAdmin4   - PostgreSQL administration"
        echo "  Insomnia   - API testing with database connections"
        echo
        echo "All databases use persistent Docker volumes for data storage."
        ;;
esac

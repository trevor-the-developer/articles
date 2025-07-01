#!/bin/bash

# Motion Service Manager for Dell 5550 (i9 10th gen) - Archcraft Linux
# Usage: ./motion-manager.sh [start|stop|restart|status|force-stop]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if motion process is running
check_motion_process() {
    if pgrep -x "motion" > /dev/null; then
        return 0  # Running
    else
        return 1  # Not running
    fi
}

# Function to get motion PID
get_motion_pid() {
    pgrep -x "motion" 2>/dev/null || echo ""
}

# Function to show status
show_status() {
    print_status "Checking motion service status..."
    
    # Check systemd service status
    systemctl status motion --no-pager -l
    
    # Check for running processes
    local pid=$(get_motion_pid)
    if [ -n "$pid" ]; then
        print_warning "Motion process found running with PID: $pid"
        ps aux | grep motion | grep -v grep
    else
        print_success "No motion processes found running"
    fi
}

# Function to start motion
start_motion() {
    print_status "Starting motion service..."
    
    if check_motion_process; then
        print_warning "Motion is already running"
        show_status
        return 0
    fi
    
    sudo systemctl start motion
    sleep 2
    
    if systemctl is-active --quiet motion; then
        print_success "Motion service started successfully"
    else
        print_error "Failed to start motion service"
        return 1
    fi
}

# Function to stop motion
stop_motion() {
    print_status "Stopping motion service..."
    
    # Try systemd first
    sudo systemctl stop motion
    sleep 2
    
    # Check if any processes are still running
    local pid=$(get_motion_pid)
    if [ -n "$pid" ]; then
        print_warning "Motion process still running, killing PID: $pid"
        sudo kill "$pid"
        sleep 1
        
        # Check again
        pid=$(get_motion_pid)
        if [ -n "$pid" ]; then
            print_warning "Force killing motion process PID: $pid"
            sudo kill -9 "$pid"
        fi
    fi
    
    if ! check_motion_process; then
        print_success "Motion service stopped successfully"
    else
        print_error "Failed to stop motion service completely"
        return 1
    fi
}

# Function to force stop motion
force_stop_motion() {
    print_status "Force stopping motion service..."
    
    sudo systemctl stop motion 2>/dev/null || true
    
    local pids=$(pgrep -x "motion" 2>/dev/null || echo "")
    if [ -n "$pids" ]; then
        print_warning "Force killing all motion processes: $pids"
        sudo pkill -9 -x "motion"
    fi
    
    sleep 1
    
    if ! check_motion_process; then
        print_success "Motion service force stopped successfully"
    else
        print_error "Failed to force stop motion service"
        return 1
    fi
}

# Function to restart motion
restart_motion() {
    print_status "Restarting motion service..."
    stop_motion
    sleep 1
    start_motion
}

# Main script logic
case "${1:-}" in
    start)
        start_motion
        ;;
    stop)
        stop_motion
        ;;
    restart)
        restart_motion
        ;;
    status)
        show_status
        ;;
    force-stop)
        force_stop_motion
        ;;
    *)
        echo "Motion Service Manager for Dell 5550"
        echo "Usage: $0 [start|stop|restart|status|force-stop]"
        echo ""
        echo "Commands:"
        echo "  start       - Start the motion service"
        echo "  stop        - Stop the motion service gracefully"
        echo "  restart     - Restart the motion service"
        echo "  status      - Show current status"
        echo "  force-stop  - Force kill all motion processes"
        echo ""
        exit 1
        ;;
esac

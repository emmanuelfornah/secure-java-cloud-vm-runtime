#!/bin/bash
# Check application health status
# Usage: ./health-check.sh [droplet-ip]

# Configuration
DROPLET_IP="${1:-YOUR_DROPLET_IP}"
APP_PORT="7071"
HEALTH_URL="http://$DROPLET_IP:$APP_PORT/actuator/health"

echo "========================================="
echo "Application Health Check"
echo "========================================="
echo "Target: $HEALTH_URL"
echo ""

# Check if curl is available
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed"
    echo "Install with: sudo apt install curl"
    exit 1
fi

# Perform health check
echo "Checking application health..."
HTTP_CODE=$(curl -s -o /tmp/health-response.json -w "%{http_code}" "$HEALTH_URL" 2>/dev/null || echo "000")

echo "HTTP Status Code: $HTTP_CODE"
echo ""

if [ "$HTTP_CODE" -eq 200 ]; then
    echo "✓ Application is HEALTHY"
    echo ""
    echo "Health Response:"
    
    # Check if jq is available for pretty printing
    if command -v jq &> /dev/null; then
        cat /tmp/health-response.json | jq .
    else
        cat /tmp/health-response.json
        echo ""
        echo "(Install jq for formatted output: sudo apt install jq)"
    fi
    
    # Cleanup
    rm -f /tmp/health-response.json
    exit 0
    
elif [ "$HTTP_CODE" -eq 503 ]; then
    echo "✗ Application is UNHEALTHY (Service Unavailable)"
    echo ""
    echo "Response:"
    cat /tmp/health-response.json
    rm -f /tmp/health-response.json
    exit 1
    
elif [ "$HTTP_CODE" -eq 000 ]; then
    echo "✗ Cannot connect to application"
    echo ""
    echo "Possible causes:"
    echo "  - Application is not running"
    echo "  - Firewall is blocking port $APP_PORT"
    echo "  - Wrong IP address or port"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check if service is running: ssh appuser@$DROPLET_IP 'sudo systemctl status myapp'"
    echo "  2. Check firewall: ssh appuser@$DROPLET_IP 'sudo ufw status'"
    echo "  3. Check logs: ssh appuser@$DROPLET_IP 'sudo journalctl -u myapp -n 50'"
    rm -f /tmp/health-response.json
    exit 1
    
else
    echo "✗ Unexpected HTTP status code: $HTTP_CODE"
    echo ""
    echo "Response:"
    cat /tmp/health-response.json 2>/dev/null || echo "(No response body)"
    rm -f /tmp/health-response.json
    exit 1
fi

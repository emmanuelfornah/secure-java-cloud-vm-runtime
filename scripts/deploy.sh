#!/bin/bash
# Deploy Java application to DigitalOcean Droplet
# Usage: ./deploy.sh

set -e  # Exit on error

# ========================================
# Configuration Variables
# ========================================
DROPLET_IP="YOUR_DROPLET_IP"
DROPLET_USER="YOUR_USERNAME"
LOCAL_JAR="build/libs/cloud-server-foundation-1.0.0.jar"
REMOTE_DIR="/opt/app/current"
SERVICE_NAME="myapp"

echo "========================================="
echo "Deploying Application to Droplet"
echo "========================================="
echo "Target: $DROPLET_USER@$DROPLET_IP"
echo "Service: $SERVICE_NAME"
echo ""

# Step 1: Build application
echo "Step 1: Building application..."
./gradlew clean build

# Check if JAR was created
if [ ! -f "$LOCAL_JAR" ]; then
    echo "Error: JAR file not found at $LOCAL_JAR"
    echo "Build may have failed. Check build output above."
    exit 1
fi

echo "✓ Build successful: $LOCAL_JAR"
echo ""

# Step 2: Transfer JAR to Droplet
echo "Step 2: Transferring JAR to Droplet..."
scp "$LOCAL_JAR" "$DROPLET_USER@$DROPLET_IP:$REMOTE_DIR/app.jar"
echo "✓ Transfer complete"
echo ""

# Step 3: Restart service
echo "Step 3: Restarting application service..."
ssh "$DROPLET_USER@$DROPLET_IP" "sudo systemctl restart $SERVICE_NAME"
echo "✓ Service restarted"
echo ""

# Step 4: Wait for application to start
echo "Step 4: Waiting for application to start..."
sleep 5

# Step 5: Check service status
echo "Step 5: Checking service status..."
ssh "$DROPLET_USER@$DROPLET_IP" "sudo systemctl status $SERVICE_NAME --no-pager" || true
echo ""

# Step 6: Verify health endpoint
echo "Step 6: Verifying application health..."
HEALTH_URL="http://$DROPLET_IP:7071/actuator/health"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_URL" || echo "000")

if [ "$HTTP_CODE" -eq 200 ]; then
    echo "✓ Application is healthy (HTTP $HTTP_CODE)"
else
    echo "✗ Health check failed (HTTP $HTTP_CODE)"
    echo "Check logs: ssh $DROPLET_USER@$DROPLET_IP 'sudo journalctl -u $SERVICE_NAME -n 50'"
    exit 1
fi

echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo "Application URL: http://$DROPLET_IP:7071"
echo "Health Check: $HEALTH_URL"
echo ""
echo "Useful commands:"
echo "  View logs: ssh $DROPLET_USER@$DROPLET_IP 'sudo journalctl -u $SERVICE_NAME -f'"
echo "  Check status: ssh $DROPLET_USER@$DROPLET_IP 'sudo systemctl status $SERVICE_NAME'"
echo "  Restart: ssh $DROPLET_USER@$DROPLET_IP 'sudo systemctl restart $SERVICE_NAME'"

#!/usr/bin/env bash
set -euo pipefail

REGION="us-east-1"
CLUSTER="minecraft-cluster"
SERVICE="minecraft-service"

TASK_ARN=$(aws ecs list-tasks \
  --region "${REGION}" \
  --cluster "${CLUSTER}" \
  --service-name "${SERVICE}" \
  --query 'taskArns[0]' \
  --output text)

if [[ "${TASK_ARN}" == "None" ]]; then
  echo "No running task yet. Wait a minute and retry." >&2
  exit 1
fi

ENI_ID=$(aws ecs describe-tasks \
  --region "${REGION}" \
  --cluster "${CLUSTER}" \
  --tasks "${TASK_ARN}" \
  --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" \
  --output text)

PUBLIC_IP=$(aws ec2 describe-network-interfaces \
  --region "${REGION}" \
  --network-interface-ids "${ENI_ID}" \
  --query 'NetworkInterfaces[0].Association.PublicIp' \
  --output text)

echo "Minecraft server address: ${PUBLIC_IP}:25565"
echo
echo "Verifying with nmap..."
nmap -sV -Pn -p T:25565 "${PUBLIC_IP}"

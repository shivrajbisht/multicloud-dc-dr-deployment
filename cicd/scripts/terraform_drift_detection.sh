#!/usr/bin/env bash
# ==============================================================================
# ENTERPRISE TERRAFORM INFRASTRUCTURE DRIFT DETECTION SCRIPT
# ==============================================================================
# Purpose:
#   Detects out-of-band manual changes (drift) in AWS & Azure cloud infrastructure
#   by comparing live cloud resources against declared Terraform state.
# Exit Codes for `terraform plan -detailed-exitcode`:
#   0 = No changes. Infrastructure is 100% in sync (No drift).
#   1 = Error executing terraform plan.
#   2 = DRIFT DETECTED! Live cloud infrastructure differs from Terraform code.
# ==============================================================================

set -eo pipefail

ENV_TARGET="${1:-dev}"
TF_DIR="terraform/environments/${ENV_TARGET}"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"

echo "=========================================================================="
echo "Starting Terraform Infrastructure Drift Detection for Environment: ${ENV_TARGET}"
echo "=========================================================================="

if [ ! -d "${TF_DIR}" ]; then
  echo "::error::Environment directory ${TF_DIR} does not exist!"
  exit 1
fi

cd "${TF_DIR}"

echo "[STEP 1] Initializing Terraform backend and providers..."
terraform init -input=false

echo "[STEP 2] Running terraform plan with -detailed-exitcode to detect drift..."
set +e
terraform plan -detailed-exitcode -no-color -out=drift.tfplan > drift_output.txt 2>&1
EXIT_CODE=$?
set -e

if [ ${EXIT_CODE} -eq 0 ]; then
  echo "=========================================================================="
  echo "SUCCESS: NO INFRASTRUCTURE DRIFT DETECTED!"
  echo "Live AWS & Azure resources match the declared Terraform state 100%."
  echo "=========================================================================="
  exit 0

elif [ ${EXIT_CODE} -eq 2 ]; then
  echo "=========================================================================="
  echo "::warning::ALERT! INFRASTRUCTURE DRIFT DETECTED IN ${ENV_TARGET}!"
  echo "Live cloud resources have been modified out-of-band."
  echo "=========================================================================="
  
  cat drift_output.txt

  # Send Slack Notification if Webhook URL is configured
  if [ -n "${SLACK_WEBHOOK_URL}" ]; then
    echo "Sending Infrastructure Drift Alert to Slack..."
    curl -X POST -H 'Content-type: application/json' \
      --data "{\"text\":\"🚨 *Terraform Infrastructure Drift Alert!* \nEnvironment: \`${ENV_TARGET}\` \nStatus: Live cloud infrastructure differs from state. \nInspect logs and apply terraform to remediate drift.\"}" \
      "${SLACK_WEBHOOK_URL}" || true
  fi

  echo "::error::Drift detection failed due to infrastructure mismatch."
  exit 2

else
  echo "=========================================================================="
  echo "::error::TERRAFORM PLAN FAILED WITH ERROR CODE ${EXIT_CODE}!"
  echo "=========================================================================="
  cat drift_output.txt
  exit 1
fi

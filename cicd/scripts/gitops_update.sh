#!/usr/bin/env bash
# ==============================================================================
# GITOPS REPO IMAGE TAG UPDATER SCRIPT
# Updates Kustomization or Helm values in the GitOps repository and pushes commit
# ==============================================================================

set -euo pipefail

APP_NAME="${1:-java-springboot-service}"
IMAGE_TAG="${2:-latest}"
TARGET_ENV="${3:-dev}"
GITOPS_DIR="${4:-gitops}"

echo "======================================================================"
echo "Updating GitOps manifest repository for app: ${APP_NAME}, env: ${TARGET_ENV}, tag: ${IMAGE_TAG}"
echo "======================================================================"

MANIFEST_DIR="${GITOPS_DIR}/environments/${TARGET_ENV}"

if [ -f "${MANIFEST_DIR}/kustomization.yaml" ]; then
  echo "Found kustomization.yaml in ${MANIFEST_DIR}. Updating image tag..."
  cd "${MANIFEST_DIR}"
  if command -v kustomize &> /dev/null; then
    kustomize edit set image "${APP_NAME}=${IMAGE_TAG}"
  else
    echo "Kustomize not found. Updating via sed..."
    sed -i "s|newTag:.*|newTag: \"${IMAGE_TAG}\"|g" kustomization.yaml
  fi
  echo "Updated kustomization.yaml successfully."
else
  echo "Warning: ${MANIFEST_DIR}/kustomization.yaml not found. Skipping file update."
fi

#!/bin/bash
. ./scripts/verify_prerequisites.sh

PROJECT=$PROJECT \
ENVIRONMENT_ID=$ENVIRONMENT_ID \
AZURE_LOCATION=$AZURE_LOCATION \
AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID \
bash -c "./scripts/deploy_infrastructure.sh"
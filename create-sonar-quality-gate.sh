#!/bin/bash

# SonarCloud Quality Gate Creation Script
# Usage: ./create-sonar-quality-gate.sh <SONAR_TOKEN> <ORGANIZATION>

SONAR_TOKEN=$1
ORGANIZATION=$2
SONAR_URL="https://sonarcloud.io/api"

if [ -z "$SONAR_TOKEN" ] || [ -z "$ORGANIZATION" ]; then
    echo "Usage: $0 <SONAR_TOKEN> <ORGANIZATION>"
    exit 1
fi

# Create Quality Gate
echo "Creating Quality Gate..."
GATE_RESPONSE=$(curl -s -X POST \
  "${SONAR_URL}/qualitygates/create" \
  -H "Authorization: Bearer ${SONAR_TOKEN}" \
  -d "name=Service Mesh Workshop Gate")

GATE_ID=$(echo $GATE_RESPONSE | jq -r '.id')
echo "Quality Gate created with ID: $GATE_ID"

# Add conditions
CONDITIONS=(
  "coverage:LT:60"
  "new_coverage:LT:70"
  "security_hotspots_reviewed:LT:100"
  "security_rating:GT:1"
  "new_security_issues:GT:0"
  "reliability_rating:GT:2"
  "new_bugs:GT:0"
  "blocker_violations:GT:0"
  "sqale_rating:GT:2"
  "sqale_debt_ratio:GT:10"
  "new_technical_debt:GT:5"
  "duplicated_lines_density:GT:5"
  "new_duplicated_lines_density:GT:3"
  "vulnerabilities:GT:0"
)

for condition in "${CONDITIONS[@]}"; do
    IFS=':' read -r metric op error <<< "$condition"
    echo "Adding condition: $metric $op $error"
    
    curl -s -X POST \
      "${SONAR_URL}/qualitygates/create_condition" \
      -H "Authorization: Bearer ${SONAR_TOKEN}" \
      -d "gateId=${GATE_ID}" \
      -d "metric=${metric}" \
      -d "op=${op}" \
      -d "error=${error}"
done

echo "Quality Gate 'Service Mesh Workshop Gate' created successfully!"
echo "Gate ID: $GATE_ID"

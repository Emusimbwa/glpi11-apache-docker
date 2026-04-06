#!/bin/bash

echo "Generating secure passwords..."

GLPI_DB_PASSWORD=$(openssl rand -base64 24)
GLPI_DB_ROOT_PASSWORD=$(openssl rand -base64 24)

echo ""
echo "GLPI_DB_PASSWORD=$GLPI_DB_PASSWORD"
echo "GLPI_DB_ROOT_PASSWORD=$GLPI_DB_ROOT_PASSWORD"
echo ""

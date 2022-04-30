#!/bin/bash

COMPOSER_BIN_PATH="/usr/bin/composer"

set -o errexit -o nounset

SCRIPT_PATH="$(realpath ${BASH_SOURCE[0]})"
PROJECT_ROOT="$(realpath $(dirname $SCRIPT_PATH)/../)"

source "$PROJECT_ROOT/docker/"functions.sh

#echo ""
#echo "============================================="
#echo Criando Rede
#echo "============================================="
#createNetwork

echo ""
echo "============================================="
echo Copiando o arquivo .env.example para .env
echo "============================================="
sudo cp .env.example .env

echo ""
echo "============================================="
echo Instalando o Composer
echo "============================================="
require_docker_composer

echo ""
echo "============================================="
echo Exectuando o arquivo docker-composer
echo "============================================="
docker-compose up --build -d

#echo ""
#echo "============================================="
#echo Criando base de Dados
#echo "============================================="
#createDatabase

echo ""
echo "============================================="
echo Criando usuário da base de Dados
echo "============================================="
createUserDb

echo ""
echo "============================================="
echo Rodando as Migrations
echo "============================================="
runMigrations

echo ""
echo "============================================="
echo Olá Jéssica
echo "============================================="
runMigrations

echo ""
echo "============================================="
echo Informações dos novos Containers
echo "============================================="
docker ps

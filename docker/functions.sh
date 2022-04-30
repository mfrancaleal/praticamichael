#!/bin/bash

#Functions carregadas em entrypoint.sh

function has_lsb_release {
  command -v lsb_release >/dev/null 2>&1
}

function is_debian {
  if is_linux; then
    if has_lsb_release; then
      lsb_release -is | grep 'Debian' > /dev/null 2>&1
    else
      cat /etc/issue | grep 'Debian' > /dev/null 2>&1
    fi
  else
    return 1
  fi
}

function is_ubuntu {
  if is_linux; then
    if has_lsb_release; then
      lsb_release -is | grep 'Ubuntu' > /dev/null 2>&1
    else
      cat /etc/issue | grep 'Ubuntu' > /dev/null 2>&1
    fi
  else
    return 1
  fi
}

function is_mint {
  if is_linux; then
    if has_lsb_release; then
      lsb_release -is | grep 'Mint' > /dev/null 2>&1
    else
      cat /etc/issue | grep 'Mint' > /dev/null 2>&1
    fi
  else
    return 1
  fi
}

function install_docker_composer {
  if is_debian || is_mint || is_ubuntu; then
    export DEBIAN_FRONTEND="noninteractive"

    sudo curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` \
      -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    echo ""
    echo "============================================="
    echo Composer Instalado
    echo "============================================="

    docker-compose --version
  else
    red ""
    red " Voce precisa instalar o docker compose e adicona-lo ao path na "
    red " sua maquina: https://docs.docker.com/compose/install"
    red ""
    exit 1
  fi
}

function require_docker_composer {
  docker_composer_installed || install_docker_composer
}

function docker_composer_installed {
  command -v docker-compose >/dev/null 2>&1
}

function docker_exists_network {
  if is_linux; then
    sudo docker network list | grep -E ".+ ${1} .+" > /dev/null 2>&1
  else
    docker network list | grep -E ".+ ${1} .+" > /dev/null 2>&1
  fi
}

function get_os {
  case "$OSTYPE" in
    solaris*) echo -n "SOLARIS" ;;
    darwin*)  echo -n "OSX" ;;
    linux*)   echo -n "LINUX" ;;
    freebsd*) echo -n "FREEBSD" ;;
    bsd*)     echo -n "BSD" ;;
    cygwin*)  echo -n "WINDOWS" ;;
    msys*)    echo -n "WINDOWS" ;;
    win32*)   echo -n "WINDOWS" ;;
    *)        echo -n "unknown: $OSTYPE" ;;
  esac
}

function is_windows {
  [[ "$(get_os)" = "WINDOWS" ]]
}

function is_linux {
  [[ "$(get_os)" = "LINUX" ]]
}

function createNetwork {
    if ! docker_exists_network michael-network; then
        if is_linux; then
          sudo docker network create -d bridge michael-network
        else
          docker network create -d bridge michael-network
        fi
         echo "########" Rede criada com sucesso! "########"
    else
        echo "########" A rede já existe. "########"
    fi
}

function createDatabase {
    if ! docker_database_exists; then
        if is_linux; then
            sudo docker exec michael_db bash -c "mysql -P 3306 --protocol=tcp -uroot -pmichaelnew -e \"CREATE DATABASE michael;\"; exit;"
        else
            docker exec michael_db bash -c "mysql -P 3306 --protocol=tcp -uroot -pmichaelnew -e \"CREATE DATABASE michael;\"; exit;"
        fi
        echo "##########" Banco de dados criado! "##########"
    else
        echo "##########" Banco de dados já existe "#############"
    fi
}

function createUserDb {
    if ! docker_user_database_exists; then
        if is_linux; then
            sudo docker exec michael_db bash -c "mysql -P 3306 --protocol=tcp -uroot -pmichaelnew -e \"GRANT ALL ON michaelnew.* TO 'userdev'@'127.0.0.1' IDENTIFIED BY 'passdev';\"; exit;"
            sudo docker exec michael_db bash -c "mysql -P 3306 --protocol=tcp -uroot -pmichaelnew -e \"FLUSH PRIVILEGES;\"; exit;"
        else
            docker exec michael_db bash -c "mysql -P 3306 --protocol=tcp -uroot -pmichaelnew -e \"GRANT ALL ON michaelnew.* TO 'userdev'@'127.0.0.1' IDENTIFIED BY 'passdev';\"; exit;"
            docker exec michael_db bash -c "mysql -P 3306 --protocol=tcp -uroot -pmichaelnew -e \"FLUSH PRIVILEGES;\"; exit;"
        fi
        echo "##########" Usuário criado! "##########"
    else
        echo "##########" Usuário já criado "#############"
    fi
}

function docker_database_exists {
  if is_linux; then
    sudo docker exec michael_db bash -c "mysql -P 3306 --protocol=tcp -uroot -pmichaelnew -e 'use michaelTaxa'; exit;"
  else
    docker docker exec michael_db bash -c "mysql -P 3306 --protocol=tcp -uroot -pmichaelnew -e 'use michaelTaxa'; exit;"
  fi
}

function docker_user_database_exists {
  if is_linux; then
    sudo docker exec michael_db bash -c "mysql -P 3306 --protocol=tcp -uroot -pmichaelnew -e \"SELECT USER FROM mysql.user WHERE user='userdev' LIMIT 1;\"; exit;"
  else
    docker docker exec michael_db bash -c "mysql -P 3306 --protocol=tcp -uroot -pmichaelnew -e \"SELECT USER FROM mysql.user WHERE user='userdev' LIMIT 1;\"; exit;"
  fi
}

function runMigrations {
    if is_linux; then
      sudo docker exec -it michael_app php artisan migrate --seed
    else
       docker exec -it michael_app php artisan migrate --seed
    fi
}

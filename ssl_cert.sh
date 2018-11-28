#!/usr/bin/env bash

source "${HOME}/.droplet/droplet.sh"
import "github.com/ggicci/droplet/droplets/env.sh"
import "github.com/ggicci/droplet/droplets/out.sh"


install_certbot_if_not_exists() {
    if env::has_command "certbot"; then return; fi

    out::printf_yellow "install certbot\n"
    sudo pip install --upgrade pip
    sudo pip install certbot
}


ensure_execution_environment() {
    install_certbot_if_not_exists
    mkdir -p "$(pwd)/letsencrypt/"{etc,lib,log,www}
}

usage() {
    echo "
Usage: ssl_cert <email> <domain>
"
    exit 1
}

main() {
    ensure_execution_environment

    if [[ $# -ne 2 ]]; then usage; fi

    local email="$1"
    local domain="$2"

    printf "  email: "
    out::printf_yellow "${email}"
    printf "  domain: "
    out::printf_yellow "${domain}\n"

    mkdir -p "$(pwd)/letsencrypt/www/${domain}"
    certbot certonly \
        --webroot \
        --config-dir "$(pwd)/letsencrypt/etc" \
        --logs-dir "$(pwd)/letsencrypt/log" \
        --work-dir "$(pwd)/letsencrypt/lib" \
        -m "${email}" \
        -w $(pwd)/letsencrypt/www/${domain} \
        -d ${domain}
}

main "$@"

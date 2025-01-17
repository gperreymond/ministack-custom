#!/bin/bash

# -----------------------
# PREPARE
# -----------------------

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -target) target="$2"; shift ;;
        *) echo "[ERROR] param is not authorized"; exit 1;;
    esac
    shift
done

if [[ -z "$target" ]]; then
    echo "[ERROR] target is mandatory"
    exit 1
fi

CLUSTER_NAME="kestra"

# -----------------------
# RESUME
# -----------------------

echo ""
echo "================================================================="
echo "[INFO] cluster............................... '${CLUSTER_NAME}'"
echo "[INFO] target............................... '${target}'"
echo "================================================================="
echo ""

reload_servers() {
    cp files/nomad/*.hcl $HOME/.ministack/$CLUSTER_NAME/nomad/
    echo "[INFO] reload nomad-server-1"
    docker exec -it nomad-server-1 service nomad restart
    echo "[INFO] reload nomad-server-2"
    docker exec -it nomad-server-2 service nomad restart
    echo "[INFO] reload nomad-server-3"
    docker exec -it nomad-server-3 service nomad restart
}

reload_clients() {
    cp files/nomad/*.hcl $HOME/.ministack/$CLUSTER_NAME/nomad/
    echo "[INFO] reload nomad client: kestra-system"
    docker exec -it kestra-system service nomad restart
    echo "[INFO] reload nomad client: kestra-runner-1"
    docker exec -it kestra-runner-1 service nomad restart
    echo "[INFO] reload nomad client: kestra-runner-2"
    docker exec -it kestra-runner-2 service nomad restart
}

reload_prometheus() {
     echo "[INFO] reload prometeus rules"
     rm $HOME/.ministack/$CLUSTER_NAME/prometheus/rules/*.* > /dev/null 2>&1
     cp files/prometheus/rules/*.* $HOME/.ministack/$CLUSTER_NAME/prometheus/rules/
     cp files/prometheus/scrape_configs/*.* $HOME/.ministack/$CLUSTER_NAME/prometheus/scrape_configs/
}

# -----------------------
# EXECUTE COMMAND
# -----------------------

case $target in
    servers)
        reload_servers
        ;;
    clients)
        reload_clients
        ;;
    prometheus)
        reload_prometheus
        ;;
    all)
        reload_servers
        reload_clients
        reload_prometheus
        ;;
    *)
        echo "[ERROR] usage: $0 {servers|clients|prometheus|all}"
        ;;
esac

echo ""

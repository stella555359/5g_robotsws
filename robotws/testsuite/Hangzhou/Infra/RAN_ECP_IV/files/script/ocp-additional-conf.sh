#!/bin/bash
usage() {
    echo "Usage: $0 [-n <string>] ..." 1>&2;
    echo "  -n, --edgedc-name   Edgedc name"
    echo "  -h, --help          Display this help message"
    exit 1;
}

OPTS=`getopt -o hn: --long help,edgedc-name: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

while true; do
  case $1 in
    -n | --edgedc-name) EDGEDC_NAME="$2"; shift ; shift ;;
    -h | --help ) usage ; shift ; break;;
    -- ) shift ; break ;;
    * ) break ;;
  esac
done

validate_args(){
    if [ "$EUID" -ne 0 ]; then
        echo "ERROR: Please run this script as root (add sudo in front of script name)!"
        exit 1
    fi
    if [ -z $EDGEDC_NAME ]; then
        echo "ERROR: Invalid options: edgedc name (-n | --edgedc-name) is mandatory."
        usage
    fi
}

copy_ssh_key_to_current_dir(){
    echo "INFO: Copy ocp-key.pem ssh key from /var/lib/ucim/wfe/workflows/environments/${EDGEDC_NAME}/ocp-config to current directory"
    cp /var/lib/ucim/wfe/workflows/environments/${EDGEDC_NAME}/ocp-config/ocp-key.pem .
}

cd_to_workspace(){
    cd /var/lib/ucim/wfe/workflows/environments/${EDGEDC_NAME}/ocp-config/
    export KUBECONFIG=/var/lib/ucim/wfe/workflows/environments/${EDGEDC_NAME}/ocp-config/kubeconfig
}

fetch_helm(){
    echo "INFO: Fetch helm from https://get.helm.sh/helm-v3.11.1-linux-amd64.tar.gz"
    export https_proxy=http://10.158.100.1:8080
    curl https://get.helm.sh/helm-v3.11.1-linux-amd64.tar.gz -o helm-v3.11.1-linux-amd64.tar.gz
    unset https_proxy

    tar xvf helm-v3.11.1-linux-amd64.tar.gz
}

copy_config(){
    echo "INFO: Copy kubeconfig, SSH private key and helm to master node/s"
    MASTER_IPS=$(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}' --selector=node-role.kubernetes.io/master=)
    for masterIp in $MASTER_IPS; do
        do_action COPY ${masterIp} "kubeconfig" "~/"
        do_action COPY ${masterIp} "ocp-key.pem" "~/"
        do_action COPY ${masterIp} "linux-amd64/helm" "~/"
        do_action SSH ${masterIp} "sudo mv ~/helm /usr/local/bin/helm"
        do_action SSH ${masterIp} "sudo mkdir -p ~/.kube ; sudo mv ~/kubeconfig ~/.kube/config ; sudo chmod 700 ~/.kube/config ; sudo chown -R core:core ~/.kube"
        do_action SSH ${masterIp} "sudo mv ~/ocp-key.pem ~/.ssh/id_rsa"
        do_action SSH ${masterIp} "sudo chmod o-r ~/.kube/config ; sudo chmod g-r ~/.kube/config"
    done
}

cleanup(){
    echo "INFO: Cleanup workspace"
    rm -r linux-amd64/
    rm helm-v3.11.1-linux-amd64.tar.gz
}

do_action(){
    action=$1
    nodeIpAddress=$2
    Param1=$3
    Param2=$4

    SSH_OPT="-i ocp-key.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=60"

    echo -e "Start ${action} ${Param1} ${Param2} to ${nodeIpAddress}"

    SECONDS=0
    exitCode=0
    while (( SECONDS < 300  )) ; do
        case "${action}" in
            SSH)
                ssh ${SSH_OPT} core@${nodeIpAddress} ${Param1}
                ;;
            COPY)
                scp ${SSH_OPT} ${Param1} core@${nodeIpAddress}:${Param2}
                ;;
        esac

        if [ $? -eq 0 ]; then
            exitCode=1
            break
        else
            echo "."
            sleep 5
        fi
    done

    case "${exitCode}" in
        1)
            echo -e "${action} ${Param1} ${Param2} to ${nodeIpAddress} executed successfully"
            ;;
        *)
            echo "ERROR: ${action} ${Param1} ${Param2} to ${nodeIpAddress} executed unsuccessfully"
            exit 1
            ;;
    esac
}


main(){
    validate_args
    copy_ssh_key_to_current_dir
    cd_to_workspace
    fetch_helm
    copy_config
    cleanup
}

main

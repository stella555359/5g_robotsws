#!/bin/bash

while getopts 'n:d:u:p:c:h:f:g:a:b:' opt; do
    case $opt in
    n)
        namespace=${OPTARG}
        echo "Input vDU container_prefix is: ${OPTARG}"
        ;;
    u)
        tenant_user_name=${OPTARG}
        echo "Input tenant_user_name is: ${OPTARG}"
        ;;
    p)
        tenant_user_passwd=${OPTARG}
        echo "Input tenant_user_passwd is: ${OPTARG}"
        ;;
    c)
        if_capture_cplane_tcpdump=${OPTARG}
        echo "Input the if_capture_cplane_tcpdump is: ${OPTARG}"
        ;;
    h)
        if_capture_uplane_tcpdump=${OPTARG}
        echo "Input the if_capture_uplane_tcpdump is: ${OPTARG}"
        ;;
    f)
        if_fetch_cplane_tcpdump=${OPTARG}
        echo "Input the if_fetch_cplane_tcpdump is: ${OPTARG}"
        ;;
    g)
        if_fetch_uplane_tcpdump=${OPTARG}
        echo "Input the if_fetch_uplane_tcpdump is: ${OPTARG}"
        ;;
    d)
        duration=${OPTARG}
        echo "Input the capture duration is: ${OPTARG}"
        ;;
    a)
        VDU_LOG_DATA_DIR_NAME=${OPTARG}
        echo "Input the vdu log and data dir name is: ${OPTARG}, used for pipeline"
        ;;
    b)
        VCU_LOG_DATA_DIR_NAME=${OPTARG}
        echo "Input the vcu log and data dir name is: ${OPTARG}, used for pipeline"
        ;;
    :)
        echo "Invalid Option: -$OPTARG requires an argument" 1>&2
        exit 1
        ;;
    ?) #当有不认识的选项的时候arg为?
        echo "-n：input vdu/vcu tenant namespace"
        echo "-u：input vdu/vcu tenant username"
        echo "-p：input vdu/vcu tenant passwd"
        echo "-c：input if capture cplane tcpdump on vdu cprt /vcu cpif"
        echo "-h：input if capture uplane tcpdump on vcu upue"
        echo "-f：input if want to fetch and upload CPLANE tcpdump from vdu/vcu to s3 server"
        echo "-g：input if want to fetch and upload UPLANE tcpdump from vdu/vcu to s3 server"
        echo "-d：input tcpdump capture duration"
        # echo "-a：input VDU_LOG_DATA_DIR_NAME, i.g: VDU_LOG_DATA_DIR_NAME_current_date"
        # echo "-b：input VCU_LOG_DATA_DIR_NAME, i.g: VCU_LOG_DATA_DIR_NAME_current_date"
        exit 1
        ;;
    esac
done

echo_line() {
    echo -e "\n"
    echo "--------------------------------------------------------------------------------------------------------"
    echo -e "\n"
}

log_error() {
    Log="\033[31m${*}\033[0m"
    echo -e $Log
}

log_info() {
    Log="\033[32m${*}\033[0m"
    echo -e $Log
}

# vdu_pod_types=(oamconfig oamasm oamcm oamfm oampm oamext cpue cpcl cpif cpnb cpnrt upue)
pod_name_get() {
    if [ $# -ne 2 ]; then
        echo "" && return 1
    else
        local namespace=$1
        local pod_type=$2
    fi

    local pod_name=$(kubectl -n ${namespace} get pod | grep ${pod_type} | awk '{print $1}')
    echo "${pod_name}"
}

container_name_get() {
    if [ $# -ne 3 ]; then
        echo "" && return 1
    else
        local namespace=$1
        local pod_name=$2
        local container_type=$3
    fi

    local container_name=$(kubectl -n ${namespace} describe pod ${pod_name} | grep "Container ID" -B1 |
        grep "\-${container_type}:" | awk -F":" '{print $1}' | sed -e 's/^[ \t]*//g')
    echo "${container_name}"
}

# Get standby pod list from healing-controller container via send commands, the command works in any one containers.
standby_pod_list_get() {
    # local namespace=$1
    local standby_pod_list
    local pod_name=$(pod_name_get "${namespace}" "healing-controller")
    if [ -z "${pod_name}" ]; then
        log_error "Get pod name failure of pod type healing-controller\n"
    else
        # Get all pods redundant role from any one container
        local pod_name_list=(${pod_name})
        local container_name=$(container_name_get "${namespace}" "${pod_name_list[0]}" "healing-controller")
        if [ -z "${container_name}" ]; then
            fatal "Get container name failure of container type healing-controller\n"
        fi
    fi
    local cmds="curl -fsSX GET http://healing-controller:50056/api/vnfcmgmt/v1/vnfcs"
    kubectl exec -n ${namespace} ${pod_name_list[0]} -c ${container_name} -- bash -c "${cmds}" >result.json 2>&1

    local data_length=$(cat result.json | jq '.data|length')
    if [ "${data_length}" != "" ]; then
        for ((i = 0; i < ${data_length}; i++)); do
            if [[ $(cat result.json | jq ".data[${i}].redundantRole") == \"standby\" ]]; then
                standby_pod_list+=($(cat result.json | jq -r ".data[${i}].name"))
            fi
        done
    else
        standby_pod_list=""
    fi
    rm -rf result.json
    echo "standby_pod_list are: ${standby_pod_list[@]}"
}

# Get active pod by pod type via send commands.
active_pod_name_get() {
    # local namespace=$1
    local active_pod_list
    local pod_name=$(pod_name_get "${namespace}" "healing-controller")
    if [ -z "${pod_name}" ]; then
        log_error "Get pod name failure of pod type healing-controller\n"
    else
        # Get all pods redundant role from any one container
        local pod_name_list=(${pod_name})
        local container_name=$(container_name_get "${namespace}" "${pod_name_list[0]}" "healing-controller")
        if [ -z "${container_name}" ]; then
            fatal "Get container name failure of container type healing-controller\n"
        fi
    fi
    local cmds="curl -fsSX GET http://healing-controller:50056/api/vnfcmgmt/v1/vnfcs"
    kubectl exec -n ${namespace} ${pod_name_list[0]} -c ${container_name} -- bash -c "${cmds}" >result.json 2>&1

    local data_length=$(cat result.json | jq '.data|length')
    if [ "${data_length}" != "" ]; then
        for ((i = 0; i < ${data_length}; i++)); do
            if [[ $(cat result.json | jq ".data[${i}].redundantRole") == \"active\" ]]; then
                active_pod_list+=($(cat result.json | jq -r ".data[${i}].name"))
            fi
        done
    else
        active_pod_list=""
    fi
    rm -rf result.json
    active_pod_list_number=${#active_pod_list[@]}
    echo "active_pod_list are: ${active_pod_list[@]}"
    echo "active_pod_list_number is: ${#active_pod_list[@]}"
}

get_container_name_for_tcpdump() {
    echo "active pods array number is: ${active_pod_list_number}"
    if ((${active_pod_list_number} == 0)); then
        echo "vdu/vcu working in single mode"
        cprt_pod_name=$(pod_name_get "${namespace}" "cprt")
        cprt_container_name=$(container_name_get "${namespace}" "${cprt_pod_name}" "cprt")

        cpif_pod_name=$(pod_name_get "${namespace}" "cpif")
        cpif_container_name=$(container_name_get "${namespace}" "${cpif_pod_name}" "cpif")

        #
        upue_pod_name=$(pod_name_get "${namespace}" "upue")
        upue_container_name=$(container_name_get "${namespace}" "${upue_pod_name}" "l2hicu")
    else
        echo "vdu/vdu working in redundancy mode"
        cpif_pod_name=$(active_pod_name_get | awk '{FS = ";"}{for (f=1; f <= NF; f+=1) {if ($f ~ /cpif/) {print $f}}}')
        cpif_container_name=$(container_name_get "${namespace}" "${cpif_pod_name}" "cpif")

        #upue working in LB mode, all upue will wokring in active mode
        # upue_pod_name=$(active_pod_name_get | awk '{FS = ";"}{for (f=1; f <= NF; f+=1) {if ($f ~ /upue/) {print $f}}}')
        # upue_container_name=$(container_name_get "${namespace}" "${upue_pod_name}" "upue")

        cprt_pod_name=$(active_pod_name_get | awk '{FS = ";"}{for (f=1; f <= NF; f+=1) {if ($f ~ /cprt/) {print $f}}}')
        cprt_container_name=$(container_name_get "${namespace}" "${cprt_pod_name}" "cprt")

    fi

    log_info "working cprt pod name is:$cprt_pod_name"
    log_info "working cprt container name is: $cprt_container_name"

    log_info "working cpif pod name is: $cpif_pod_name"
    log_info "working cpif container name is: $cpif_container_name"

    log_info "working upue pod name is: $upue_pod_name"
    log_info "working upue container name is: $upue_container_name"

}

vcu_get_container_pid() {
    log_info "$cpif_pod_name"
    log_info "$cpif_container_name"
    # cpif_working_node=$(kubectl get pods -n ${namespace} -o wide | grep ${cpif_pod_name} | awk '{print $7}')
    # log_info "cpif_working_node is: ${cpif_working_node}"

    cpif_working_node=$(kubectl get pods -n ${1} --output 'jsonpath={range .items[*]}{.spec.nodeName}{" "}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}' | grep ${2} | awk '{print $1}')
    echo "cpif_working_node is: ${cpif_working_node}"

    cpif_container_id=$(ssh -o StrictHostKeyChecking=no $cpif_working_node sudo crictl ps | grep "${cpif_container_name}" | awk '{print $1,$7}' | sed -n /cpif$/p | awk '{print $1}')
    log_info "cpif_container_id is: ${cpif_container_id}"

    cpif_container_pid=$(ssh -o StrictHostKeyChecking=no $cpif_working_node sudo crictl inspect --output yaml ${cpif_container_id} | grep 'pid:' | cut -d' ' -f4)
    log_info "cpif_container_pid is: ${cpif_container_pid}"
}

vdu_get_container_pid() {
    echo "$cprt_pod_name"
    echo "$cprt_container_name"

    # cprt_working_node=$(kubectl get pods -n ${namespace} -o wide | grep ${cprt_pod_name} | awk '{print $7}')
    cprt_working_node=$(kubectl get pods -n ${1} --output 'jsonpath={range .items[*]}{.spec.nodeName}{" "}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}' | grep ${2} | awk '{print $1}')
    echo "cprt_working_node is: ${cprt_working_node}"

    cprt_container_id=$(./sshpass -p ${tenant_user_passwd} ssh -q -o StrictHostKeyChecking=no ${tenant_user_name}@$cprt_working_node sudo crictl ps | grep "${cprt_container_name}" | awk '{print $1,$7}' | sed -n /cprt$/p | awk '{print $1}')
    echo "cprt_container_id is: ${cprt_container_id}"

    cprt_container_pid=$(./sshpass -p ${tenant_user_passwd} ssh -q -o StrictHostKeyChecking=no ${tenant_user_name}@$cprt_working_node sudo crictl inspect --output yaml ${cprt_container_id} | grep 'pid:' | cut -d' ' -f4)
    echo "cprt_container_pid is: ${cprt_container_pid}"
}

fetch_interface_mac() {
    # echo "#namespace: '$1'"
    # echo "#pods: '$2'"
    # echo "#container: '$3'"
    # echo "#interface: '$4'"
    # kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "ifconfig ${4} | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'"
    mac=$(kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "ifconfig ${4} | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'")
    echo $mac
    return $?
}

fetch_interface_ip() {
    # echo "#namespace: '$1'"
    # echo "#pods: '$2'"
    # echo "#container: '$3'"
    # echo "#interface: '$4'"
    # kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "ifconfig ${4} | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'"
    ip=$(kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "ip a l ${4} | awk '/inet/ {print \$2}' | cut -d/ -f1|sed -n 1p")
    echo ${ip}
    return $?
}

get_file_from_container() {
    echo "#namespace: '$1'"
    echo "#pods: '$2'"
    echo "#container: '$3'"
    echo "#remote file: '$4'"
    echo "#local file: '$5'"
    log_info "#####starting get the ${4} from ${2} ${3} save as ${5}"
    kubectl cp -n ${1} -c ${3} ${2}:${4} ${5}
    kubectl_cp_return=$?
    if ((${kubectl_cp_return} == 0)); then
        log_info "#####Save file ${4} to local successfully"
    else
        log_error "#####Save file ${4} failed"
        exit 1
    fi
    echo_line
}

vdu_capture_nsenter_tcpdump() {
    # echo "${6} fiter '${4}' in ${1} ${2}"
    # echo "$6 filter specific string with info:"
    echo "#namespace: '$1'"
    echo "#pods: '$2'"
    echo "#container: '$3'"
    echo "#capture time: '$4'"
    echo "#capture filter: '$5'"

    echo "download sshpass to local"
    curl -o sshpass https://gitlabe1.ext.net.nokia.com/xiaomiaz/5g_aic_toolset/-/raw/master/vdu_operation/sshpass && chmod 766 sshpass

    cprt_port_num=$(kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "ip -4 -o addr show" | grep -v -E 'eth0|127.0|tracing' | awk '{print $4}' | cut -d'/' -f1 | wc -l)
    echo "cprt port number is: ${cprt_port_num}"
    cprt_cplane_ips=$(kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "ip -4 -o addr show" | grep -v -E 'eth0|127.0|tracing' | awk '{print $4}' | cut -d'/' -f1)
    echo "cprt cplane ip are: ${cprt_cplane_ips}"

    # cprt_working_node=$(kubectl get pods -n ${1} -o wide | grep ${2} | awk '{print $7}')
    # echo "cprt_working_node is: ${cprt_working_node}"
    cprt_working_node=$(kubectl get pods -n ${1} --output 'jsonpath={range .items[*]}{.spec.nodeName}{" "}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}' | grep ${2} | awk '{print $1}')
    echo "cprt_working_node is: ${cprt_working_node}"

    cprt_container_id=$(./sshpass -p ${tenant_user_passwd} ssh -q -o StrictHostKeyChecking=no ${tenant_user_name}@$cprt_working_node sudo crictl ps | grep "${3}" | awk '{print $1,$7}' | sed -n /cprt$/p | awk '{print $1}')
    echo "cprt_container_id is: ${cprt_container_id}"

    cprt_container_pid=$(./sshpass -p ${tenant_user_passwd} ssh -q -o StrictHostKeyChecking=no ${tenant_user_name}@$cprt_working_node sudo crictl inspect --output yaml ${cprt_container_id} | grep 'pid:' | cut -d' ' -f4)
    echo "cprt_container_pid is: ${cprt_container_pid}"

    if ((${cprt_port_num} == 0)); then
        echo "port num is: ${port_num}"
        exit 1
    elif ((${cprt_port_num} == 1)); then
        echo "port num is: ${cprt_port_num}"
        ip_fiter="host ${cprt_cplane_ips}"
        echo "ip filter is: ${ip_fiter}"
        # kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "timeout ${4} tcpdump -i any -n -v -w /tmp/cprt.pcap ${ip_fiter} and not arp --print " | grep -v "invalid"
        # ssh hztt15f-nh03-rm17-ocp-worker-07 sudo nsenter -r -n -t 3735625 tcpdump -i any
        ./sshpass -p ${tenant_user_passwd} ssh -q -o StrictHostKeyChecking=no ${tenant_user_name}@$cprt_working_node sudo nsenter -r -n -t ${cprt_container_pid} "timeout ${4} tcpdump -i any -n -v -w /tmp/cprt.pcap ${ip_fiter} and not arp --print " | grep -v "invalid"
    elif ((${cprt_port_num} == 2)); then
        echo "port num is: ${cprt_port_num}"
        ip_fiter="host $(echo ${cprt_cplane_ips} | sed -n 1p) or host $(echo ${cprt_cplane_ips} | sed -n 2p)"
        echo "ip filter is: ${ip_fiter}"
        ./sshpass -p ${tenant_user_passwd} ssh -q -o StrictHostKeyChecking=no ${tenant_user_name}@$cprt_working_node sudo nsenter -r -n -t ${cprt_container_pid} "timeout ${4} tcpdump -i any -n -v -w /tmp/cprt.pcap ${ip_fiter} and not arp --print " | grep -v "invalid"
    elif ((${cprt_port_num} == 3)); then
        echo "port num is: ${cprt_port_num}"
        ip_fiter="host $(echo ${cprt_cplane_ips} | cut -d' ' -f1) or host $(echo ${cprt_cplane_ips} | cut -d' ' -f2) or host $(echo ${cprt_cplane_ips} | cut -d' ' -f3)"
        echo "ip filter is: ${ip_fiter}"
        ./sshpass -p ${tenant_user_passwd} ssh -q -o StrictHostKeyChecking=no ${tenant_user_name}@$cprt_working_node sudo nsenter -r -n -t ${cprt_container_pid} "timeout ${4} tcpdump -i any -n -v -w /tmp/cprt.pcap ${ip_fiter} and not arp --print " | grep -v "invalid"
    elif ((${cprt_port_num} == 4)); then
        echo "port num is: ${cprt_port_num}"
        ip_fiter="host $(echo ${cprt_cplane_ips} | cut -d' ' -f1) or host $(echo ${cprt_cplane_ips} | cut -d' ' -f2) or host $(echo ${cprt_cplane_ips} | cut -d' ' -f3) or host $(echo ${cprt_cplane_ips} | cut -d' ' -f4)"
        echo "ip filter is: ${ip_fiter}"
        ./sshpass -p ${tenant_user_passwd} ssh -q -o StrictHostKeyChecking=no ${tenant_user_name}@$cprt_working_node sudo nsenter -r -n -t ${cprt_container_pid} "timeout ${4} tcpdump -i any -n -v -w /tmp/cprt.pcap ${ip_fiter} ${5} --print " | grep -v "invalid"
    fi
    log_info "#####list the saved tcpdump data"
    ./sshpass -p ${tenant_user_passwd} ssh -q -o StrictHostKeyChecking=no ${tenant_user_name}@$cprt_working_node sudo nsenter -r -n -t ${cprt_container_pid} "ls -al /tmp/cprt.pcap"
    echo_line

    # kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "timeout ${4} tcpdump -n -v -w /tmp/cprt.pcap  ether host 0a:58:0a:81:08:48 --print"
}

vdu_stop_tcpdump() {
    echo "stop capture"
}

vcu_stop_tcpdump() {
    echo "stop capture"
}

vcu_capture_nsenter_tcpdump() {
    # echo "${6} fiter '${4}' in ${1} ${2}"
    # echo "$6 filter specific string with info:"
    echo "#namespace: '$1'"
    echo "#pods: '$2'"
    echo "#container: '$3'"
    echo "#capture time: '$4'"
    echo "#capture filter: '$5'"

    curl -o sshpass https://gitlabe1.ext.net.nokia.com/xiaomiaz/5g_aic_toolset/-/raw/master/vdu_operation/sshpass && chmod 766 sshpass

    cpif_port_num=$(kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "ip -4 -o addr show" | grep -v -E 'eth0|127.0|tracing' | awk '{print $4}' | cut -d'/' -f1 | wc -l)
    echo "cpif port number is: ${cpif_port_num}"
    cpif_cplane_ips=$(kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "ip -4 -o addr show" | grep -v -E 'eth0|127.0|tracing' | awk '{print $4}' | cut -d'/' -f1)
    echo "cpif cplane ip are: ${cpif_cplane_ips}"

    # cpif_working_node=$(kubectl get pods -n ${1} -o wide | grep ${2} | awk '{print $7}')
    cpif_working_node=$(kubectl get pods -n ${1} --output 'jsonpath={range .items[*]}{.spec.nodeName}{" "}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}' | grep ${2} | awk '{print $1}')
    echo "cpif_working_node is: ${cpif_working_node}"

    cpif_container_id=$(ssh -o StrictHostKeyChecking=no $cpif_working_node sudo crictl ps | grep "${3}" | awk '{print $1,$7}' | sed -n /cpif$/p | awk '{print $1}')
    echo "cpif_container_id is: ${cpif_container_id}"

    cpif_container_pid=$(ssh -o StrictHostKeyChecking=no $cpif_working_node sudo crictl inspect --output yaml ${cpif_container_id} | grep 'pid:' | cut -d' ' -f4)
    echo "cpif_container_pid is: ${cpif_container_pid}"

    if ((${cpif_port_num} == 0)); then
        echo "port num is: ${port_num}"
        exit 1
    elif ((${cpif_port_num} == 1)); then
        echo "port num is: ${cpif_port_num}"
        ip_fiter="host ${cpif_cplane_ips}"
        echo "ip filter is: ${ip_fiter}"
        # kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "timeout ${4} tcpdump -i any -n -v -w /tmp/cpif.pcap ${ip_fiter} and not arp --print " | grep -v "invalid"
        # ssh hztt15f-nh03-rm17-ocp-worker-07 sudo nsenter -r -n -t 3735625 tcpdump -i any
        ssh -o StrictHostKeyChecking=no ${cpif_working_node} sudo nsenter -r -n -t ${cpif_container_pid} "timeout ${4} tcpdump -i any -n -v -w /tmp/cpif.pcap ${ip_fiter} and not arp --print " | grep -v "invalid"
    elif ((${cpif_port_num} == 2)); then
        echo "port num is: ${cpif_port_num}"
        ip_fiter="host $(echo ${cpif_cplane_ips} | sed -n 1p) or host $(echo ${cpif_cplane_ips} | sed -n 2p)"
        echo "ip filter is: ${ip_fiter}"
        ssh -o StrictHostKeyChecking=no ${cpif_working_node} sudo nsenter -r -n -t ${cpif_container_pid} "timeout ${4} tcpdump -i any -n -v -w /tmp/cpif.pcap ${ip_fiter} and not arp --print " | grep -v "invalid"
    elif ((${cpif_port_num} == 3)); then
        echo "port num is: ${cpif_port_num}"
        ip_fiter="host $(echo ${cpif_cplane_ips} | cut -d' ' -f1) or host $(echo ${cpif_cplane_ips} | cut -d' ' -f2) or host $(echo ${cpif_cplane_ips} | cut -d' ' -f3)"
        echo "ip filter is: ${ip_fiter}"
        ssh -o StrictHostKeyChecking=no ${cpif_working_node} sudo nsenter -r -n -t ${cpif_container_pid} "timeout ${4} tcpdump -i any -n -v -w /tmp/cpif.pcap ${ip_fiter} and not arp --print " | grep -v "invalid"
    elif ((${cpif_port_num} == 4)); then
        echo "port num is: ${cpif_port_num}"
        ip_fiter="host $(echo ${cpif_cplane_ips} | cut -d' ' -f1) or host $(echo ${cpif_cplane_ips} | cut -d' ' -f2) or host $(echo ${cpif_cplane_ips} | cut -d' ' -f3) or host $(echo ${cpif_cplane_ips} | cut -d' ' -f4)"
        echo "ip filter is: ${ip_fiter}"
        ssh -o StrictHostKeyChecking=no ${cpif_working_node} sudo nsenter -r -n -t ${cpif_container_pid} "timeout ${4} tcpdump -i any -n -v -w /tmp/cpif.pcap ${ip_fiter} ${5} --print " | grep -v "invalid"
    elif ((${cpif_port_num} == 5)); then
        echo "port num is: ${cpif_port_num}"
        ip_fiter="host $(echo ${cpif_cplane_ips} | cut -d' ' -f1) or host $(echo ${cpif_cplane_ips} | cut -d' ' -f2) or host $(echo ${cpif_cplane_ips} | cut -d' ' -f3) or host $(echo ${cpif_cplane_ips} | cut -d' ' -f4) or host $(echo ${cpif_cplane_ips} | cut -d' ' -f5)"
        echo "ip filter is: ${ip_fiter}"
        ssh -o StrictHostKeyChecking=no ${cpif_working_node} sudo nsenter -r -n -t ${cpif_container_pid} "timeout ${4} tcpdump -i any -n -v -w /tmp/cpif.pcap ${ip_fiter} ${5} --print " | grep -v "invalid"
    fi
    log_info "#####list the saved tcpdump data"
    ssh -o StrictHostKeyChecking=no ${cpif_working_node} sudo nsenter -r -n -t ${cpif_container_pid} "ls -al /tmp/cpif.pcap"
    echo_line

    # kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "timeout ${4} tcpdump -n -v -w /tmp/cpif.pcap  ether host 0a:58:0a:81:08:48 --print"
}

vcu_capture_nsenter_tcpdump_uplane() {
    # used to capture vCU uplane data for vcu upue l2hi container
    echo "#namespace: '$1'"
    echo "#pods: '$2'"
    echo "#container: '$3'"
    echo "#capture time: '$4'"
    echo "#capture filter: '$5'"

    curl -o sshpass https://gitlabe1.ext.net.nokia.com/xiaomiaz/5g_aic_toolset/-/raw/master/vdu_operation/sshpass && chmod 766 sshpass

    upue_port_num=$(kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "ip -4 -o addr show" | grep -v -E 'eth0|127.0|tracing' | awk '{print $4}' | cut -d'/' -f1 | wc -l)
    echo "upue port number is: ${upue_port_num}"
    upue_cplane_ips=$(kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "ip -4 -o addr show" | grep -v -E 'eth0|127.0|tracing' | awk '{print $4}' | cut -d'/' -f1)
    echo "upue cplane ip are: ${upue_cplane_ips}"

    # upue_working_node=$(kubectl get pods -n ${1} -o wide | grep ${2} | awk '{print $7}')
    upue_working_node=$(kubectl get pods -n ${1} --output 'jsonpath={range .items[*]}{.spec.nodeName}{" "}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}' | grep ${2} | awk '{print $1}')
    echo "upue_working_node is: ${upue_working_node}"

    upue_container_id=$(ssh -o StrictHostKeyChecking=no $upue_working_node sudo crictl ps | grep "${3}" | awk '{print $1,$7}' | sed -n /l2hicu$/p | awk '{print $1}')
    echo "upue_container_id is: ${upue_container_id}"

    upue_container_pid=$(ssh -o StrictHostKeyChecking=no $upue_working_node sudo crictl inspect --output yaml ${upue_container_id} | grep 'pid:' | cut -d' ' -f4)
    echo "upue_container_pid is: ${upue_container_pid}"

    if ((${upue_port_num} == 0)); then
        echo "port num is: ${port_num}"
        exit 1
    elif ((${upue_port_num} == 1)); then
        echo "port num is: ${upue_port_num}"
        ip_fiter="host ${upue_cplane_ips}"
        echo "ip filter is: ${ip_fiter}"
        # kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "timeout ${4} tcpdump -i any -n -v -w /tmp/upue.pcap ${ip_fiter} and not arp --print " | grep -v "invalid"
        # ssh hztt15f-nh03-rm17-ocp-worker-07 sudo nsenter -r -n -t 3735625 tcpdump -i any
        ssh -o StrictHostKeyChecking=no ${upue_working_node} sudo nsenter -r -n -t ${upue_container_pid} "timeout ${4} tcpdump -i any -n -v -w /tmp/upue.pcap ${ip_fiter} and not arp --print " | grep -v "invalid"
    elif ((${upue_port_num} == 2)); then
        echo "port num is: ${upue_port_num}"
        ip_fiter="host $(echo ${upue_cplane_ips} | sed -n 1p) or host $(echo ${upue_cplane_ips} | sed -n 2p)"
        echo "ip filter is: ${ip_fiter}"
        ssh -o StrictHostKeyChecking=no ${upue_working_node} sudo nsenter -r -n -t ${upue_container_pid} "timeout ${4} tcpdump -i any -n -v -w /tmp/upue.pcap ${ip_fiter} and not arp --print " | grep -v "invalid"
    elif ((${upue_port_num} == 3)); then
        echo "port num is: ${upue_port_num}"
        ip_fiter="host $(echo ${upue_cplane_ips} | cut -d' ' -f1) or host $(echo ${upue_cplane_ips} | cut -d' ' -f2) or host $(echo ${upue_cplane_ips} | cut -d' ' -f3)"
        echo "ip filter is: ${ip_fiter}"
        ssh -o StrictHostKeyChecking=no ${upue_working_node} sudo nsenter -r -n -t ${upue_container_pid} "timeout ${4} tcpdump -i any -n -v -w /tmp/upue.pcap ${ip_fiter} and not arp --print " | grep -v "invalid"
    elif ((${upue_port_num} == 4)); then
        echo "port num is: ${upue_port_num}"
        ip_fiter="host $(echo ${upue_cplane_ips} | cut -d' ' -f1) or host $(echo ${upue_cplane_ips} | cut -d' ' -f2) or host $(echo ${upue_cplane_ips} | cut -d' ' -f3) or host $(echo ${upue_cplane_ips} | cut -d' ' -f4)"
        echo "ip filter is: ${ip_fiter}"
        ssh -o StrictHostKeyChecking=no ${upue_working_node} sudo nsenter -r -n -t ${upue_container_pid} "timeout ${4} tcpdump -i any -n -v -w /tmp/upue.pcap ${ip_fiter} ${5} --print " | grep -v "invalid"
    elif ((${upue_port_num} == 5)); then
        echo "port num is: ${upue_port_num}"
        ip_fiter="host $(echo ${upue_cplane_ips} | cut -d' ' -f1) or host $(echo ${upue_cplane_ips} | cut -d' ' -f2) or host $(echo ${upue_cplane_ips} | cut -d' ' -f3) or host $(echo ${upue_cplane_ips} | cut -d' ' -f4) or host $(echo ${upue_cplane_ips} | cut -d' ' -f5)"
        echo "ip filter is: ${ip_fiter}"
        ssh -o StrictHostKeyChecking=no ${upue_working_node} sudo nsenter -r -n -t ${upue_container_pid} "timeout ${4} tcpdump -i any -n -v -w /tmp/upue.pcap ${ip_fiter} ${5} --print " | grep -v "invalid"
    fi
    log_info "#####list the saved tcpdump data"
    ssh -o StrictHostKeyChecking=no ${upue_working_node} sudo nsenter -r -n -t ${upue_container_pid} "ls -al /tmp/upue.pcap"
    echo_line

    # kubectl exec -it -n ${1} ${2} -c ${3} -- bash -c "timeout ${4} tcpdump -n -v -w /tmp/upue.pcap  ether host 0a:58:0a:81:08:48 --print"
}

push_file_to_s3_server() {
    echo "log data file name is: ${1}"
    echo "starting to upload log data compress file to S3 server"
    timeout 300 ./sshpass -p 'ute' scp -o StrictHostKeyChecking=no -r ${1} ute@10.109.2.86:/var/www/html/log_storage/vdu_logs
    scp_return=$?
    if ((${scp_return} == 0)); then
        echo "log and data upload to S3 sever successfully"
        echo "could check or download the log from http://10.109.2.86/log_storage/vdu_logs/${1}"
    else
        echo "log and data upload to s3 failed"
        exit 1
    fi
}

current_date=$(date '+%Y-%m-%d-%H-%M-%S')
log_info "Current date time is: $current_date"

# standby_pod_list_get
active_pod_name_get
get_container_name_for_tcpdump

#trigger from pipeline or from job build

if [[ "$(kubectl get pods -n ${namespace} | grep cpif)" == *"cpif"* ]]; then
    log_info "Cluster wokring in vCU mode"
    log_info "NOTICE: return pods contains: cpif"
    cpif_saved_file_name=cpif_${current_date}.pcap
    upue_saved_file_name=upue_${current_date}.pcap

    if [[ "${if_capture_uplane_tcpdump}" == "yes" ]] && [[ "${if_capture_cplane_tcpdump}" == "yes" ]]; then
        echo "currnetly can't support capture the vcu cplane and uplane data at the same time, if want to do this execute them with separate to two job"
        exit 1
    elif [[ "${if_capture_cplane_tcpdump}" == "yes" ]]; then
        echo "starting capture the tcpdump on cpif docker container"
        vcu_capture_nsenter_tcpdump ${namespace} ${cpif_pod_name} ${cpif_container_name} ${duration} "and not arp"
    elif [[ "${if_capture_uplane_tcpdump}" == "yes" ]]; then
        echo "starting capture the tcpdump on upue docker container"
        vcu_capture_nsenter_tcpdump_uplane ${namespace} ${upue_pod_name} ${upue_container_name} ${duration} "and not arp"
    fi

    # if [[ "${if_fetch_tcpdump}" == "yes" ]]; then
    #     echo "starting fetch tcpdump and upload tcpdump file to s3 server"

    if [[ "${if_fetch_cplane_tcpdump}" == "yes" ]]; then
        if [[ -n "${VCU_LOG_DATA_DIR_NAME}" ]]; then
            log_info "script triggered by pipeline, pipeline env define VCU_LOG_DATA_DIR_NAME"
            log_info "VCU_LOG_DATA_DIR_NAME is: ${VCU_LOG_DATA_DIR_NAME}"
            get_file_from_container ${namespace} ${cpif_pod_name} ${cpif_container_name} "tmp/cpif.pcap" "${VCU_LOG_DATA_DIR_NAME}/${cpif_saved_file_name}"

        else
            VCU_LOG_DATA_DIR_NAME=vcu_log_data_${current_date}
            echo "VCU_LOG_DATA_DIR_NAME is: ${VCU_LOG_DATA_DIR_NAME}"
            echo "script triggered by single job, need to compress the log and data and push to s3 server"
            get_file_from_container ${namespace} ${cpif_pod_name} ${cpif_container_name} "tmp/cpif.pcap" "${VCU_LOG_DATA_DIR_NAME}/${cpif_saved_file_name}"
            push_file_to_s3_server ${VCU_LOG_DATA_DIR_NAME}

        fi
    elif [[ "${if_fetch_uplane_tcpdump}" == "yes" ]]; then
        if [[ -n "${VCU_LOG_DATA_DIR_NAME}" ]]; then
            log_info "script triggered by pipeline, pipeline env define VCU_LOG_DATA_DIR_NAME"
            log_info "VCU_LOG_DATA_DIR_NAME is: ${VCU_LOG_DATA_DIR_NAME}"
            get_file_from_container ${namespace} ${upue_pod_name} ${upue_container_name} "tmp/upue.pcap" "${VCU_LOG_DATA_DIR_NAME}/${upue_saved_file_name}"

        else
            VCU_LOG_DATA_DIR_NAME=vcu_log_data_${current_date}
            echo "VCU_LOG_DATA_DIR_NAME is: ${VCU_LOG_DATA_DIR_NAME}"
            echo "script triggered by single job, need to compress the log and data and push to s3 server"
            get_file_from_container ${namespace} ${upue_pod_name} ${upue_container_name} "tmp/upue.pcap" "${VCU_LOG_DATA_DIR_NAME}/${upue_saved_file_name}"
            push_file_to_s3_server ${VCU_LOG_DATA_DIR_NAME}

        fi
    fi
    # fi

else
    log_info "Cluster wokring in vDU mode"
    log_info "NOTICE: return pods contains: cprt"
    cprt_saved_file_name=cprt_${current_date}.pcap

    if [[ "${if_capture_cplane_tcpdump}" == "yes" ]]; then
        echo "starting capture the tcpdump on cprt docker container"
        vdu_capture_nsenter_tcpdump ${namespace} ${cprt_pod_name} ${cprt_container_name} ${duration} "and not arp"
    fi

    if [[ "${if_fetch_cplane_tcpdump}" == "yes" ]]; then
        echo "starting fetch tcpdump and upload tcpdump file to s3 server"

        if [[ -n "${VDU_LOG_DATA_DIR_NAME}" ]]; then
            log_info "script triggered by pipeline, pipeline env define VDU_LOG_DATA_DIR_NAME"
            log_info "VDU_LOG_DATA_DIR_NAME is: ${VDU_LOG_DATA_DIR_NAME}"
            get_file_from_container ${namespace} ${cprt_pod_name} ${cprt_container_name} "tmp/cprt.pcap" "${VDU_LOG_DATA_DIR_NAME}/${cprt_saved_file_name}"

        else
            VDU_LOG_DATA_DIR_NAME=vdu_log_data_${current_date}
            log_info "VDU_LOG_DATA_DIR_NAME is: ${VDU_LOG_DATA_DIR_NAME}"
            log_info "script triggered by single job, need to compress the log and data and push to s3 server"
            get_file_from_container ${namespace} ${cprt_pod_name} ${cprt_container_name} "tmp/cprt.pcap" "${VDU_LOG_DATA_DIR_NAME}/${cprt_saved_file_name}"

            push_file_to_s3_server ${VDU_LOG_DATA_DIR_NAME}

        fi

    fi
fi

# if [[ "$(kubectl get pods -n ${namespace} | grep upue)" == *"upue"* ]]; then
#     log_info "Cluster wokring in vCU mode"
#     log_info "NOTICE: return pods contains: upue"
#     upue_saved_file_name=upue_${current_date}.pcap

#     if [[ "${if_capture_uplane_tcpdump}" == "yes" ]]; then
#         echo "starting capture the tcpdump on upue docker container"
#         vcu_capture_nsenter_tcpdump_uplane ${namespace} ${upue_pod_name} ${upue_container_name} ${duration} "and not arp"
#     fi

#     if [[ "${if_fetch_tcpdump}" == "yes" ]]; then
#         echo "starting fetch tcpdump and upload tcpdump file to s3 server"

#         if [[ -n "${VCU_LOG_DATA_DIR_NAME}" ]]; then
#             log_info "script triggered by pipeline, pipeline env define VCU_LOG_DATA_DIR_NAME"
#             log_info "VCU_LOG_DATA_DIR_NAME is: ${VCU_LOG_DATA_DIR_NAME}"
#             get_file_from_container ${namespace} ${upue_pod_name} ${upue_container_name} "tmp/upue.pcap" "${VCU_LOG_DATA_DIR_NAME}/${upue_saved_file_name}"

#         else
#             VCU_LOG_DATA_DIR_NAME=vcu_log_data_${current_date}
#             echo "VCU_LOG_DATA_DIR_NAME is: ${VCU_LOG_DATA_DIR_NAME}"
#             echo "script triggered by single job, need to compress the log and data and push to s3 server"
#             get_file_from_container ${namespace} ${upue_pod_name} ${upue_container_name} "tmp/upue.pcap" "${VCU_LOG_DATA_DIR_NAME}/${upue_saved_file_name}"
#             push_file_to_s3_server ${VCU_LOG_DATA_DIR_NAME}

#         fi

#     fi
# fi

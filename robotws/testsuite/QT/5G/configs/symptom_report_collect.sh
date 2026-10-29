#!/bin/bash
#set -x

#-------------------------------------------------------------------------------
info() {
    echo -e $(date) '[INFO]' "$@"
}

error() {
    echo -e $(date) '[ERROR]' "$@" >&2
}

fatal() {
    echo -e  $(date)'[FATAL]' "$@" >&2
    exit 1
}

pod_name_get() {

    if [ $# -ne 2 ];then
        echo "" && return 1
    else
        local namespace=$1
        local pod_type=$2
    fi

    local pod_name=`kubectl -n ${namespace} get pod | grep ${pod_type} | awk '{print $1}'`
    echo "${pod_name}"
}

container_name_get() {

    if [ $# -ne 3 ];then
        echo "" && return 1
    else
        local namespace=$1
        local pod_name=$2
        local container_type=$3
    fi

    local container_name=`kubectl -n ${namespace} describe pod ${pod_name} | grep "Container ID" -B1 |\
                    grep "\${container_type}:" | awk -F":" '{print $1}' |sed -e 's/^[ \t]*//g'`
    echo "${container_name}"
}

# Get standby pod list from healing-controller container via send commands, the command works in any one containers.
standby_pod_list_get() {

    local namespace=$1
    local standby_pod_list
    local pod_name=$(pod_name_get "${namespace}" "healing-controller")
    if [ -z "${pod_name}" ];then
        fatal "Get pod name failure of pod type healing-controller\n"
    else
        # Get all pods redundant role from any one container
        local pod_name_list=(${pod_name})
        local container_name=$(container_name_get "${namespace}" "${pod_name_list[0]}" "healing-controller")
        if [ -z "${container_name}" ];then
            fatal "Get container name failure of container type healing-controller\n"
        fi
    fi
    local cmds="curl -fsSX GET http://healing-controller:50056/api/vnfcmgmt/v1/vnfcs"
    kubectl exec -n ${namespace} ${pod_name_list[0]} -c ${container_name} -- bash -c "${cmds}" > result.json 2>&1

    local data_length=$(cat result.json | jq '.data|length')
    if [ "${data_length}" != "" ];then
        for ((i=0;i<${data_length};i++));do
            if [[ `cat result.json | jq ".data[${i}].redundantRole"` == \"standby\" ]];then
                standby_pod_list+=(`cat result.json | jq ".data[${i}].name"`)
            fi
        done
    else
        standby_pod_list=""
    fi
    rm -rf result.json
    echo "${standby_pod_list[@]}"
}

# Get active pod by pod type via send commands.
active_pod_name_get() {

    local namespace=$1
    local pod_list=($2)
    local standby_pod_list=`standby_pod_list_get "${namespace}"`

    if [ "${standby_pod_list}" != "" ];then
        for pod in ${pod_list[@]};do
            if [[ ! "${standby_pod_list[@]}" =~ "${pod}" ]];then
                new_pod_list+=(${pod})
            fi
        done
    else
        new_pod_list=(${pod_list[*]})
    fi
    echo "${new_pod_list[@]}"
}

# Get URL list that registed to LWSD
services_get_from_lwsd() {
    local lwsd_pod_name=$(pod_name_get "${namespace}" "lwsd")

    if [ -z "${lwsd_pod_name}" ];then
        fatal "Get pod name failure of pod type lwsd\n"
    else
        if [[ "${cnf_type}" == "vCU" && "${cnf_layout}" == "redundant" ]];then
            local lwsd_pod_name_list=(${lwsd_pod_name})
            info "Start to get active lwsd pod for redundant vCU"
            local active_pod_name=$(active_pod_name_get "${namespace}" "${lwsd_pod_name_list[*]}")
        else
            local active_pod_name=${lwsd_pod_name}
        fi

        local lwsd_container_name=$(container_name_get "${namespace}" "${active_pod_name}" "lwsd")
        if [ -z "${lwsd_container_name}" ];then
            fatal "Get container name failure of container type lwsd\n"
        fi
    fi

}

# Get URL list by looking up lwsd pod.
service_url_list_get() {

    local lwsd_pod_name=$(pod_name_get "${namespace}" "lwsd")
    if [ -z "${lwsd_pod_name}" ];then
        fatal "Get pod name failure of pod type lwsd\n"
    else
        if [[ "${cnf_type}" == "vCU" && "${cnf_layout}" == "redundant" ]];then
            local lwsd_pod_name_list=(${lwsd_pod_name})
            info "Start to get active lwsd pod for redundant vCU"
            local active_pod_name=$(active_pod_name_get "${namespace}" "${lwsd_pod_name_list[*]}")
        else
            local active_pod_name=${lwsd_pod_name}
        fi

        local lwsd_container_name=$(container_name_get "${namespace}" "${active_pod_name}" "lwsd")
        if [ -z "${lwsd_container_name}" ];then
            fatal "Get container name failure of container type lwsd\n"
        fi
    fi

    if [ -n "$plugin" ]; then
        url_list=`kubectl exec -n ${namespace} ${active_pod_name} -c ${lwsd_container_name} -- lwsd get-services |grep url |grep $plugin`
    else
        url_list=`kubectl exec -n ${namespace} ${active_pod_name} -c ${lwsd_container_name} -- lwsd get-services |grep url`
    fi
    echo $url_list > ${report_dir}/plugin_list
    echo "$url_list"
}

# Collect symptom report files from different service.
symptom_files_collect() {

    info "Start symptom files collecting"
    local url_list=$(service_url_list_get)
    for url_line in ${url_list[@]};
    do
    {
        local url=`echo "$url_line"| sed -e 's/\r//g'|awk -F \" '{print $4}'`
        local service_name=$(echo $url_line| awk -F \= '{print $1}'|awk '{gsub(/^\s+|\s+$/, "");print}')
        local instance_name=`echo "$url_line"|grep instance |awk -F \" '{print $8}'`

        if [ -n "$url" ] && [ -n "$service_name" ];then
            info "Start downloading task $service_name by ${url}${timeslot}"

            local dir=${report_dir}/${service_name}/${instance_name}
            mkdir -p ${dir}

            local head_info=$(cat /proc/sys/kernel/random/uuid)
            cd $dir && { curl -m 300 -s -OJ "${url}${timeslot}" -D $head_info ; cd - > /dev/null ;}
            local http_status=$(cat ${dir}/$head_info | awk 'NR==1')
            rm -f ${dir}/$head_info

            info "Task $service_name done for $url with status:$http_status"
        fi
    } &
    done
    wait
}


# Collect all syslog files located in PV.
syslog_files_collect() {


    local syslog_dir=${report_dir}/syslog
    mkdir -p $syslog_dir

    local logservice_ip=`kubectl -n ${namespace} get pod -o wide | grep logservice | awk '{print $6}'`
    local syslog_list_url="http://${logservice_ip}:8081/api/trc/v1/log_list?logtype=syslog"
    local syslog_name_list=$(curl -m 100 -s -X GET $syslog_list_url |grep syslog)

    info "Start syslog files collecting"
    for log_name in ${syslog_name_list[@]};
    do
    {
        local syslog_url="http://${logservice_ip}:8081/api/trc/v1/log_data?logname=$log_name"
        local head_info=$(cat /proc/sys/kernel/random/uuid)
        curl -m 300 -s "${syslog_url}" -D ${syslog_dir}/$head_info -o ${syslog_dir}/$log_name
        local http_status=$(cat ${syslog_dir}/$head_info | awk 'NR==1')
        rm -f ${syslog_dir}/$head_info
        info "Task $log_name done with status:$http_status"
    } &
    done
    wait
}

# Compress  all files to *.tgz
symptom_report_save() {
    local ts=$(date -d "today" +"%Y%m%d%H%M%S")

    cd ${report_dir} && { info "Start compressing "$(ls -lR|grep "^-"|wc -l)" files to report"; cd - > /dev/null 2>&1; }
    cd $log_dir && { tar -czf symptomreport-$ts.tgz ./symptomreport > /dev/null 2>&1; cd - > /dev/null 2>&1; }

    if [ $? -eq 0 ];then
        info "Please find the collected file ${log_dir}/symptomreport-$ts.tgz"
    else
        error "Please check symptom report failure"
    fi

    rm -rf ${report_dir}
}


# Initial paramters needed for collecting
symptom_report_init() {

    if [ ! ${namespace} ]; then
        error "Namespace not provided as input parameter"
        exit 1
    fi

    if [ -n "$fromTime" ] && [ -n "$toTime" ];then
        timeslot="?fromTime=$fromTime"\&"toTime=${toTime}"
    elif [ -n "${fromTime}" ]; then
        timeslot="?fromTime=$fromTime"
    elif [ -n "${toTime}" ]; then
        timeslot="?toTime=${toTime}"
    fi

    log_dir=`pwd`/log
    report_dir=${log_dir}/symptomreport
    mkdir -p $report_dir
    info "Create work dir:$report_dir"
}

# Trigger collecting symptom report
symptom_report_trigger() {

    if [ ! $all_syslog_enabled ]; then
        symptom_files_collect
    else 
        syslog_files_collect
        symptom_files_collect
    fi
}

# Usage information
usage() {
    echo "Usage:"
    echo "`basename $0` -n [namespace]               | namespace to use"
    echo "`basename $0` -m [mode]                    | set layout mode for vCU, default is non-redundant"
    echo "`basename $0` -s                           | collect symptomreport including all syslog files"
    echo "`basename $0` -p [plugin]                  | collect symptomreport for specific plugin"
    echo "`basename $0` -f [time]                    | collected data created after time(RFC3339 format)"
    echo "`basename $0` -t [time]                    | collected data created before time(RFC3339 format)"
    echo "`basename $0` -v                           | print version"
    echo "`basename $0` -h                           | print help"
    echo ""
    echo "Example:"
    echo "./`basename $0` -n cran1"
    echo "./`basename $0` -n cran1 -m redundant"
    echo "./`basename $0` -n cran2 -f 2021-09-29T05:00:00Z -t 2021-09-30T05:00:00Z"
    echo "watch -n 300 \"./`basename $0` -n cran1\" "
    exit 1
}

while getopts "f:l:hm:n:p:st:v" opt; do
    case $opt in
        d)
            debug_mode=true
            per_task_mode=0
            ;;
        f)
            fromTime=$OPTARG
            ;;
        m)
            cnf_layout=$OPTARG
            cnf_type=vCU
            ;;
        n)
            namespace=$OPTARG
            ;;
        p)
            plugin=$OPTARG
            ;;
        s)
            all_syslog_enabled=1
            ;;
        t)
            toTime=$OPTARG
            ;;
        v)
            echo "version 0.0.1"
            exit 0
            ;;
        *)
            usage
            ;;
    esac
done

OLD_IFS="$IFS"
IFS=$'\n'

symptom_report_init
symptom_report_trigger
symptom_report_save

IFS="$OLD_IFS"

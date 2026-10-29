#!/bin/bash
# base_dir=$(cd "$(dirname $0)" && pwd)
base_dir=$(dirname $0)
log_filename=""

# Variable from arguments
args_enable_swic="false"
args_log_level="warn"
args_log_directory=${HOME}
args_remote="true"
args_retry_times=3
args_custom_image_property=""
args_enable_docker="false"
registry_url=""
registry_credentials=""

# (in a ) Common (way to get these) variables
env_platform="unknown"
env_onboard_tool="PODMAN"

# (in a ) Platform-specific (way to get these) variables
username=""
token=""
registry=""
registry_port="443"

# podman specific variables
PODMAN_image_property=""

# swic specific variables
SWIC_bin=${base_dir}/swic
SWIC_registry_cert=${base_dir}/swic.registry.cert


function usage {
    echo "Load images to registry"
    echo "Usage:"
    echo "$0 [-h] [-n <namespace>] [-v] [--remote] [--log-level <level>] [--retry <retry_times>] [--enable-swic]"
    echo ""
    echo "Options:"
    echo "-h, --help        Print help document."
    echo "-v, --version     Get version."
    echo "-n, --namespace   Specify a Kubernetes namespace in OpenShift Container Platform or remote platform."
    if [[ ${PODMAN_image_property} == "" ]]; then
        echo "-p, --properties  Specify a properties file."
    else
        echo "-p, --properties  Specify a properties file. Default is \"${PODMAN_image_property}\"."
    fi
    echo "--remote          Remote load images."
    echo "--log-level       Log messages above specified level(trace, debug, info, warn, error, fatal, panic)."
    echo "                  Default is \"warn\"."
    echo "--log-path        Specify a directory to save logs. Default is \"${HOME}\"."
    echo "--retry           Number of retries when the image on boarding failed. Default is 3. If the given retry times"
    echo "                  is less than 1 or more than 9, script will set it to default."
    echo "--registry-url    Specify the external image registry URL."
    echo "--registry-credentials  Set credentials for external image registry. Format: <username>:<password>."
    echo ""
    echo "Example:"
    echo "# Print help document:"
    echo "$0 -h"
    echo ""
    echo "# Get version:"
    echo "$0 -v"
    echo ""
    echo "# On boarding images in WebScale_CaaS, NCIR_CaaS, NCS platform:"
    echo "$0"
    echo ""
    echo "# On boarding images in OpenShift Container Platform:"
    echo "$0 -n <namespace>"
    echo ""
    echo "# On boarding images in OpenShift Container Platform with designated runtime logs level:"
    echo "$0 -n <namespace> --log-level warn"
    echo ""
    echo "# Specify a directory to save logs:"
    echo "$0 --log-path /tmp"
    echo ""
    echo "# Specify a properties file:"
    echo "$0 -p ../onBoardingApp/my.properties.OCP"
    echo ""
    echo "# On boarding images in OpenShift Container Platform with designated retry number:"
    echo "$0 -n <namespace> --retry 6"
    echo ""
    echo "# On boarding images in remote platform:"
    echo "$0 -n <namespace> --remote"
    echo ""
    echo ""
    echo "# On boarding images with swic:"
    echo "$0 -n <namespace> --enable-swic"
    echo ""
    echo ""
    echo "# On boarding images with docker:"
    echo "$0 -n <namespace> --enable-docker"
    echo ""
    echo "# On boarding images with extrenal CCR:"
    echo "$0 -n <namespace> -url <registry_url> -cred '<registry_credentials>'"
    echo ""
    exit 0
}

function print_version {
    echo "0.390.0000-operator-dev"
    $SWIC_bin version
    exit 0
}

# Print ERROR level log message in STDERR.
function error {
    local message=$1
    if [[ "${message}" == "" ]]; then
        message="unknown error"
    fi

    message="[$(datetime)][ERROR] ${message}"
    if [[ -f "${log_filename}" ]]; then
        echo "${message}" >> ${log_filename}
    fi

    if [[ "${args_log_level}" == "panic" ]]; then
        return
    elif [[ "${args_log_level}" == "fatal" ]]; then
        return
    fi
    echo -e "${message}" >&2
}

# If the value of global variable `debug` is "false", this function will do nothing.
# Otherwise it will print INFO level log message in STDOUT.
function info {
    local message=$1
    local console=$2
    if [[ "${console}" == "" ]]; then
        console="false"
    fi

    if [[ "${message}" == "" ]]; then
        message="unknown message"
    fi

    message="[$(datetime)][INFO] ${message}"
    if [[ -f "${log_filename}" ]]; then
        echo "${message}" >> ${log_filename}
    fi

    if [[ "${console}" == "false" ]]; then
        if [[ "${args_log_level}" == "panic" ]]; then
            return
        elif [[ "${args_log_level}" == "fatal" ]]; then
            return
        elif [[ "${args_log_level}" == "error" ]]; then
            return
        elif [[ "${args_log_level}" == "warn" ]]; then
            return
        fi
    fi
    echo -e "${message}"
}

# Print WARNING level log message in STDERR.
function warning {
    local message=$1
    if [[ "${message}" == "" ]]; then
        message="unknown warning"
    fi

    message="[$(datetime)][WARNING] ${message}"
    if [[ -f "${log_filename}" ]]; then
        echo "${message}" >> ${log_filename}
    fi

    if [[ "${args_log_level}" == "panic" ]]; then
        return
    elif [[ "${args_log_level}" == "fatal" ]]; then
        return
    elif [[ "${args_log_level}" == "error" ]]; then
        return
    fi
    echo -e "${message}" >&2
}

# Print current datetime. For example "2022-08-03T06:37:59".
function datetime {
    echo "$(date +%F)T$(date +%T)"
}

# This function is used to check the validity of the log level.
# If the given value of the log level is not legal, this function will reset global variable ${args_log_level} to default
# value("warn").
function check_log_level {
    local validity="false"
    local log_level_set=(trace debug info warn error fatal panic)

    for (( i=0; i<${#log_level_set[@]}; i++)) do
        if [[ ${args_log_level} == ${log_level_set[i]} ]]; then
            validity="true"
            break
        fi
    done

    if [[ "${validity}" == "false" ]]; then
        args_log_level="warn"
    fi
}

# If the value of global variable "args_retry_times" is less than 1 or more than 9, set it to default value.
# Default is 3.
function check_retry_times {
    local default_retry_times=3
    if [ ${args_retry_times} -lt 1 ]; then
        args_retry_times=${default_retry_times}
    elif [ ${args_retry_times} -gt 9  ]; then
        args_retry_times=${default_retry_times}
    fi
}

function check_log_directory {
    if [ ! -d "${args_log_directory}" ]; then
        error "cannot access log directory '${args_log_directory}': No such directory"
        exit 1
    fi
}

function parse_arguments {
    while test $# -gt 0; do
        case "$1" in
            -h|--help|-H|--HELP)
                usage
                ;;
            -n|--namespace)
                shift
                namespace=$1
                shift
                ;;
            -v|--version)
                shift
                print_version
                ;;
            -p|--properties)
                shift
                args_custom_image_property=$1
                shift
                ;;
            --remote)
                shift
                args_remote="true"
                ;;
            --log-level)
                shift
                args_log_level=$1
                shift
                check_log_level
                ;;
            --log-path)
                shift
                args_log_directory=$1
                shift
                check_log_directory
                ;;
            --retry)
                shift
                args_retry_times=$1
                shift
                check_retry_times
                ;;
            --enable-swic)
                shift
                args_enable_swic="true"
                ;;
            --enable-docker)
                shift
                args_enable_docker="true"
                ;;
            -url|--registry-url)
                shift
                registry_url=$1
                shift
                ;;
            -cred|--registry-credentials)
                shift
                registry_credentials=$1
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    # Ensure both registry_url and registry_credentials are provided together, or neither
    if { [[ -n "$registry_url" ]] && [[ -z "$registry_credentials" ]]; } || \
       { [[ -z "$registry_url" ]] && [[ -n "$registry_credentials" ]]; }; then
        error "Both --registry-url and --registry-credentials must be provided together."
        usage
        exit 1
    fi

}

function check_tools_and_config {
    if [[ $args_remote == "false" ]]; then
        oc version > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            error "Not a regular remote platform: need oc command."
            exit 1
        fi

        if [[ "${KUBECONFIG}" == "" ]] || [ ! -f "${KUBECONFIG}" ]; then
            error "Can not find kube config file."
            exit 1
        fi
    fi
}

function check_namespace {
    if [[ $namespace == "" ]]; then
        error "Missing namespace option, please use $0 -h to show more information."
        exit 1
    fi

    kubectl get ns "${namespace}" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        error "Can not find namespace: $namespace"
        exit 1
    fi
}

function check_environment {
    check_tools_and_config
    check_namespace
}

function init_platform_type {
    if [[ $args_remote == "true" ]]; then
        env_platform="OCP"
    elif [ -f "/etc/os-release" ]; then
        source /etc/os-release
        if [[ $REDHAT_BUGZILLA_PRODUCT == "OpenShift Container Platform" ]]; then
            env_platform="OCP"
        elif grep -qi "Wind River" /etc/os-release || [ -d "/etc/platform" ]; then
            # Wind River detected, treat as OCP
            env_platform="OCP"
        fi
    fi
    aws --version > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        env_platform="EKS"
    fi
}

function initialize_common_variables {
    # Set platform type in use
    init_platform_type

    # Set onboard tool in use
    if [[ "$args_enable_swic" == "true" ]]; then
        env_onboard_tool="SWIC"
    fi

    if [[ "$args_enable_docker" == "true" ]]; then
        env_onboard_tool="DOCKER"
        docker version > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            error "Docker is not installed , please install DOCKER."
            exit 1
        fi
    fi

    if [[ "$env_onboard_tool" == "PODMAN" ]]; then
        podman version > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            error "Not a regular remote platform: need podman command."
            exit 1
        fi
    fi
}

function OCP_init_registry_user_account {
    if [[ -n "$registry_url" && -n "$registry_credentials" ]]; then
        info "Using provided registry URL and credentials for onboard."
        creds_option="--creds ${registry_credentials}"
        return
    fi

    username=$(oc whoami)
    result=$(echo "${username}" | grep ":")
    if [ -n "${result}" ]; then
        old_IFS="${IFS}"
        IFS=":"
        username_array=($username)
        username=""
        for (( i=0; i<${#username_array[@]}; i++ )) do
            username="${username}""${username_array[i]}"
        done
        IFS="${old_IFS}"
    fi

    token=$(oc whoami -t 2>/dev/null)
    if [ $? -ne 0 ] || [[ -z "$token" ]] || [[ "$token" == error:* ]]; then
        error "Get token for oc user failed. Please oc login first or provide --registry-url and --registry-credentials."
        exit 1
    fi
}

function EKS_init_registry_user_account {
    region=$(aws configure get region)
    account_id=$(aws sts get-caller-identity --output text --query Account)
    token=$(aws ecr get-login-password --region $region)
    if [ $? -ne 0 ]; then
        error "Get token for aws user failed. Please aws login first"
        exit 1
    fi
}

function OCP_init_registry_hostname_and_port {
    # If registry credentials are provided, use them directly
    if [[ -n "$registry_url" && -n "$registry_credentials" ]]; then
        info "Using provided registry URL and credentials for onboard."
        registry="${registry_url}"
        if [[ "$env_onboard_tool" == "DOCKER" ]]; then
            # Parse username and password from registry_credentials
            username="${registry_credentials%%:*}"
            password="${registry_credentials#*:}"

            # Extract registry host and namespace/project
            registry_host="${registry_url%%/*}"
        fi
        return
    fi
    if [[ $args_remote == "true" ]]; then
        info "Remote mode. Get server IP address from ${KUBECONFIG} file."
        ip=""
        while read line; do
            config_line=$(eval echo "${line}")
            if [[ $config_line == server:* ]]; then
                ip_and_ports=${config_line##*/}
                ip=${ip_and_ports%:*}
                break
            fi
        done < "${KUBECONFIG}"

        if [[ $ip == "" ]]; then
            error "Can not get server ip from ${KUBECONFIG} file."
            exit 1
        fi

        # Get registry
        if [[ ! -f /etc/hosts ]]; then
            warning "Cannot find file /etc/hosts in this machine."
            touch /etc/hosts
        fi

        while IFS=' ' read host_ip hostname; do
            if [[ $host_ip == $ip ]] && [[ $hostname == default-route-openshift-image-registry* ]]; then
                registry="${hostname}"
                info "Get registry: ${registry}"
                break
            fi
        done < /etc/hosts

        if [[ $registry == "" ]]; then
            # The OC command(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}') is
            # not used to get the default route because it must add the route resource in the role.
            registry=$(oc registry info)
            info "Get registry: ${registry}"
            warning "$({ echo "${ip} ${registry}" >> /etc/hosts; } 2>&1)"
            info "Write IP address '${ip}' and registry '${registry}' mapping finished."
        fi

        if [[ $registry == "" ]]; then
            warning "Cannot get registry."
        fi
    else
        info "Local mode."
        registry="image-registry.openshift-image-registry.svc"
        registry_port="5000"
    fi
}

function EKS_init_registry_hostname_and_port {
    info "Local mode."
    registry="${account_id}.dkr.ecr.${region}.amazonaws.com"
}

function initialize_platform_specific_variables {
    # initialize registry user account info
    # init registry
    ${env_platform}_init_registry_user_account
    ${env_platform}_init_registry_hostname_and_port
}

function init_variables {
    # Set image property file in use
    if [[ $args_custom_image_property != "" ]]; then
        image_property=$args_custom_image_property
    else
        image_property="$base_dir/images.properties.$env_platform"
        if [[ $env_platform == "EKS" ]]; then
            sed -i "s#{{region}}#${region}#g" $image_property 
            sed -i "s#{{account_id}}#${account_id}#g" $image_property
        fi
    fi
}

function initialize_onboard_tool_specific_variables {
    # Initialize image property file when podman or docker in use
    if [[ "$env_onboard_tool" == "PODMAN" || "$env_onboard_tool" == "DOCKER" ]]; then
        init_variables
    fi
    info "No tool-specific variable needs to be initialized"
}

function PODMAN_login_registry {
    # If registry credentials are provided, use them directly
    if [[ -n "$registry_url" && -n "$registry_credentials" ]]; then
        info "External registry provided, skipping podman login."
        return
    fi
    info "Check podman status."
    podman_available=$(podman info --log-level ${args_log_level} 2>&1)
    if [ $? -ne 0 ]; then
        error "podman is not available: ${podman_available}"
        exit 1
    fi
    if [[ "$env_platform" == "OCP" ]]; then
        login_message=$(podman login "${registry}:${registry_port}" -u "${username}" -p "${token}" --tls-verify=true --log-level ${args_log_level} 2>&1)
    elif [[ "$env_platform" == "EKS" ]]; then
        login_message=$(aws ecr get-login-password --region $region | podman login --username AWS --password-stdin ${registry})
    fi

    if [ $? -ne 0 ]; then
        error "podman login failed: ${login_message}"
        exit 1
    fi
}


function DOCKER_login_registry {
    if [[ "$env_platform" == "OCP" && -n "$registry_url" && -n "$registry_credentials" ]]; then
        # username, password and registry_host are already set above
        login_message=$(echo "$password" | docker login "$registry_host" -u "$username" --password-stdin 2>&1)
        if [ $? -ne 0 ]; then
            error "docker login failed for $registry_host: $login_message"
            exit 1
        fi
        return
    fi
    if [[ "$env_platform" == "EKS" ]]; then
        login_message=$(aws ecr get-login-password --region $region | docker login --username AWS --password-stdin ${registry})
    fi
    if [ $? -ne 0 ]; then
        error "docker login failed: ${login_message}"
        exit 1
    fi
}

function SWIC_login_registry {
    if [[ "$args_remote" == "false" ]]; then
        info "swic in use to onboard images locally"
        return
    else
        error "SWIC does not support onboarding remotely"
        exit 1
    fi
}

function login_registry {
    ${env_onboard_tool}_login_registry
}

## Load each image
# Function load_each_image has 2 arguments: key and value
# Function load_each_image has  arguments:value according to CNI-117478

function PODMAN_load_each_image {
    # Take the common file
    tar_file=$(ls v*.tar 2>/dev/null)
    tar_path="$base_dir/$tar_file"
    if [[ -n "$tar_path" && -f "$tar_path" ]]; then
        info "Common image .tar file found : $tar_file"
        info "Loading images from $tar_path"
        info "Load images by using podman tool."
        load_result=$(podman load -i "${tar_path}" 2>/dev/null)
    # Parse and process each loaded image
        images_list=$(echo "$load_result" | grep -oP '(?<=Loaded image: ).*')
        if [[ -z "$images_list" ]]; then
            error "No images were found in the tar file."
            return 1
        fi
        for old_tag in $images_list; do
            info "Processing image: $old_tag"
            info "Old tag: ${old_tag}"
            version=$(echo ${old_tag} | sed -n 's/.*\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/p')
        # New tag generation based on environment platform
            if [ ${env_platform} = "EKS" ]; then
                local repo_name=$(echo "$1" | sed 's/:.*//')
                aws_ecr_repository_create ${repo_name}
                image_status=$(aws ecr list-images --repository-name "${repo_name}" | grep -q "\"imageTag\": \"${version}-arm64\"" && echo "present" || echo "not present")
                if [[ $image_status == "present" ]]; then
                   continue
                fi
            fi
            if [[ $args_remote == "true" ]]; then
                new_tag="${registry}/${namespace}/${old_tag##*/}"
            elif [[ -n "$registry_url" && "$env_platform" == "OCP" ]]; then
                new_tag="${registry_url}/${old_tag##*/}"
            elif [[ "$env_platform" == "OCP" ]]; then
                new_tag="${registry}:${registry_port}/${namespace}/${old_tag##*/}"
            elif [[ "$env_platform" == "EKS" ]]; then
                new_tag="${account_id}.dkr.ecr.${region}.amazonaws.com/${old_tag##*/}"
            fi
        # Tag the images from image_list
            info "new tag is : $new_tag"
            tag_message=$(podman tag "${old_tag}" "${new_tag}" --log-level ${args_log_level} 2>&1)
            if [ $? -ne 0 ]; then
                error "podman tag ${old_tag} ${new_tag} failed: ${tag_message}"
                return 1
            fi
            info "${tag_message}"
            if [[ -n "$registry_url" && -n "$registry_credentials" ]]; then
                push_message=$(podman push ${creds_option} "${new_tag}" --log-level ${args_log_level} --tls-verify=true 2>&1)
            else
                push_message=$(podman push "${new_tag}" --log-level ${args_log_level} --tls-verify=true 2>&1)
            fi
            if [ $? -ne 0 ]; then
                error "podman push ${new_tag} failed: ${push_message}"
                return 1
            fi
            info "${push_message}"
            info "Remove image: ${old_tag}"
            podman rmi "${old_tag}" --log-level ${args_log_level} > /dev/null 2>&1
        done
        return 0
    else
        while IFS= read -r value || [[ -n "$value" ]]; do
            info "Image property file in use: ${image_property}"
            info "value is : $value"
            base_dir=$(pwd)  # Store the current directory path
            tar_file=$(echo "${value##*/}" | sed 's/:/-/g').tar  # Replace ':' with '-' in the tar file name
            info "tar file is :$tar_file"
            info "Load images by using podman tool."
            load_result=$(podman load -i "${tar_file}" 2>/dev/null)
            old_tag=${load_result##* }
            info "Old tag: $old_tag"
            version=$(echo ${old_tag} | sed 's/.*:\(.*\)-.*/\1/')
            if [ ${env_platform} = "EKS" ]; then
                local repo_name=$(echo "$value" | sed 's#.*/\([^:]*\):.*#\1#')
                aws_ecr_repository_create ${repo_name}
                image_status=$(aws ecr list-images --repository-name "${repo_name}" | grep -q "\"imageTag\": \"${version}-arm64\"" && echo "present" || echo "not present")
                if [[ $image_status == "present" ]]; then
                   continue
                fi
            fi
            if [[ $args_remote == "true" ]]; then
                new_tag="${registry}:${registry_port}/${namespace}/${old_tag##*/}"
            elif [[ -n "$registry_url" && "$env_platform" == "OCP" ]]; then
                new_tag="${registry_url}/${old_tag##*/}"
            elif [[ "$env_platform" == "OCP" ]]; then
                new_tag="${registry}:${registry_port}/${namespace}/${old_tag##*/}"
            elif [[ "$env_platform" == "EKS" ]]; then
                new_tag="$"${1%%/*}"/${old_tag##*/}"
            fi
            info "new tag is : $new_tag"
            tag_message=$(podman tag "${old_tag}" "${new_tag}" --log-level ${args_log_level} 2>&1)
            if [ $? -ne 0 ]; then
                error "podman tag ${old_tag} ${new_tag} failed: ${tag_message}"
                return 1
            fi
            info "${tag_message}"

            if [[ -n "$registry_url" && -n "$registry_credentials" ]]; then
                push_message=$(podman push ${creds_option} "${new_tag}" --log-level ${args_log_level} --tls-verify=true 2>&1)
            else
                push_message=$(podman push "${new_tag}" --log-level ${args_log_level} --tls-verify=true 2>&1)
            fi
            if [ $? -ne 0 ]; then
                error "podman push ${new_tag} failed: ${push_message}"
                return 1
            fi
            info "${push_message}"

            info "Remove image: ${old_tag}"
            podman rmi "${old_tag}" --log-level ${args_log_level} > /dev/null 2>&1
        done < "$image_property"
        return 0
    fi
}
function DOCKER_load_each_image {
    # Take the common file
    tar_file=$(ls v*.tar 2>/dev/null)
    tar_path="$base_dir/$tar_file"
    if [[ -n "$tar_path" && -f "$tar_path" ]]; then
        info "Common image .tar file found : $tar_file"
        info "Loading images from $tar_path"
        info "Load images by using docker tool."
        load_result=$(docker load -i "${tar_path}" 2>/dev/null)
    # Parse and process each loaded image
        images_list=$(echo "$load_result" | grep -oP '(?<=Loaded image: ).*')
        info "$images_list"
        if [[ -z "$images_list" ]]; then
            error "No images were found in the tar file."
            return 1
        fi
        for old_tag in $images_list; do
            info "Processing image: $old_tag"
            info "Old tag: ${old_tag}"
            version=$(echo ${old_tag} | sed -n 's/.*\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/p')
        # New tag generation based on environment platform
            if [ ${env_platform} = "EKS" ]; then
                local repo_name=$(echo "$old_tag" | sed 's/:.*//')
                aws_ecr_repository_create ${repo_name}
                image_status=$(aws ecr list-images --repository-name "${repo_name}" | grep -q "\"imageTag\": \"${version}-arm64\"" && echo "present" || echo "not present")
                if [[ $image_status == "present" ]]; then
                   continue
                fi
            fi
            if [[ $args_remote == "true" ]]; then
                new_tag="${registry}:${registry_port}/${namespace}/${old_tag##*/}"
            elif [[ -n "$registry_url" && "$env_platform" == "OCP" ]]; then
                new_tag="${registry_url}/${old_tag##*/}"
            elif [[ "$env_platform" == "OCP" ]]; then
                new_tag="${registry}:${registry_port}/${namespace}/${old_tag##*/}"
            elif [[ "$env_platform" == "EKS" ]]; then
                new_tag="${account_id}.dkr.ecr.${region}.amazonaws.com/${old_tag##*/}"
            fi
        # Tag the images from image_list
            info "new tag is : $new_tag"
            tag_message=$(docker tag "${old_tag}" "${new_tag}" 2>&1)
            if [ $? -ne 0 ]; then
                error "docker tag ${old_tag} ${new_tag} failed: ${tag_message}"
                return 1
            fi
            info "${tag_message}"
            push_message=$(docker push "${new_tag}" 2>&1)
            if [ $? -ne 0 ]; then
                error "docker push ${2} failed: ${push_message}"
                return 1
            fi
            info "${push_message}"

            info "Remove image: ${old_tag}"
            docker rmi "${old_tag}" > /dev/null 2>&1
        done
        return 0
    else
        while IFS= read -r value || [[ -n "$value" ]]; do
            info "Image property file in use: ${image_property}"
            info "value is : $value"
            base_dir=$(pwd)  # Store the current directory path
            tar_file=$(echo "${value##*/}" | sed 's/:/-/g').tar  # Replace ':' with '-' in the tar file name
            info "tar file is :$tar_file"
            info "Load images by using docker tool."
            load_result=$(docker load -i "${tar_file}" 2>/dev/null)
            old_tag=${load_result##* }
            version=$(echo ${old_tag} | sed -n 's/.*\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/p')
            info "Old tag: ${old_tag}"
            if [ ${env_platform} = "EKS" ]; then
                local repo_name=$(echo "$value" | sed 's#.*/\([^:]*\):.*#\1#')
                aws_ecr_repository_create ${repo_name}
                image_status=$(aws ecr list-images --repository-name "${repo_name}" | grep -q "\"imageTag\": \"${version}-arm64\"" && echo "present" || echo "not present")
                if [[ $image_status == "present" ]]; then
                   continue
                fi
            fi
            if [[ $args_remote == "true" ]]; then
                new_tag="${registry}:${registry_port}/${namespace}/${old_tag##*/}"
            elif [[ "$env_platform" == "OCP" ]]; then
                new_tag="${registry}:${registry_port}/${namespace}/${old_tag##*/}"
            elif [[ "$env_platform" == "EKS" ]]; then
                new_tag="$"${1%%/*}"/${old_tag##*/}"
            fi
            info "new tag is : $new_tag"
            tag_message=$(docker tag "${old_tag}" "${value}" 2>&1)
            if [ $? -ne 0 ]; then
                error "docker tag ${old_tag} ${value} failed: ${tag_message}"
                return 1
            fi
            info "${tag_message}"
            push_message=$(docker push "${value}" 2>&1)
            if [ $? -ne 0 ]; then
                error "docker push ${2} failed: ${push_message}"
                return 1
            fi
            info "${push_message}"

            info "Remove image: ${old_tag}"
            docker rmi "${old_tag}" > /dev/null 2>&1



        done < "$image_property"
        return 0
    fi
}

function aws_ecr_repository_create {

    local repository_name=$1
    if ! aws ecr describe-repositories --repository-names ${repository_name} > /dev/null 2>&1; then
        if ! aws ecr create-repository --repository-name ${repository_name} > /dev/null 2>&1; then
            fatal "Create ECR repository ${repository_name} failed"
        fi
    fi
}
# load_images function parsing image.properties file line by line. If images tag/push failed, script will exit with
# code 1.
function common_onboard_images {
        local load_success="false"
        for (( i=0; i<${args_retry_times}; i++)) do
            local current_execute_times=`expr ${i} + 1`
            if [ ${current_execute_times} -gt 1 ]; then
                info "Load images ${value##*:} failed. Retry execution..."
                sleep ${current_execute_times}
            fi
            ${env_onboard_tool}_load_each_image
            if [ $? -eq 0 ]; then
                load_success="true"
                break
            fi
        done
        if [[ ${load_success} == "false" ]]; then
            error "onboard image failed"
            exit 1
        fi
}

function SWIC_onboard_images {
    if [[ "$args_remote" == "false" ]]; then
        info "swic oneshot onboarding images"
        output=$($SWIC_bin onboard -i ${base_dir} -n ${namespace} 2>&1)
    else
        error "SWIC does not support onboarding remotely"
        exit 1
    fi

    if [[ $? -eq 0 ]]; then
        info "onboard image succeeded ${output}"
    else
        error "onboard image failed: ${output}"
        exit 1
    fi
}

function onboard_images {
    if [[ "${env_onboard_tool}" == "SWIC" ]]; then
        SWIC_onboard_images
    else
        common_onboard_images
    fi
}

# main
# parse_arguments
# check_environemnt_and_initialize_variables
# loadImage
function main {
    parse_arguments $@

    # Create log file
    log_filename=${args_log_directory}/load-images-$(datetime).log
    touch "${log_filename}"

    check_environment

    initialize_common_variables
    initialize_platform_specific_variables
    initialize_onboard_tool_specific_variables

    login_registry
    onboard_images

    info "All images load success" "true"

    info "Pruning unused images"
    prune_message=$(podman image prune -af 2>&1)
    if [ $? -ne 0 ]; then
        warning "podman image prune failed: ${prune_message}"
    else
        info "podman image prune output: ${prune_message}"
    fi
}

main $@
exit 0

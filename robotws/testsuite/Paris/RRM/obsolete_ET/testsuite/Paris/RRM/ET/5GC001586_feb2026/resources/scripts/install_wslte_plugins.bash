#!/usr/bin/env bash
# set -x

#premiere artifactory is hz1 in hangzhou artifactory, will change to espoo1 in espoo1 artifactory
BACKUP_ARTIFACTORY_ESPOO="http://artifactory-espoo1.int.net.nokia.com/artifactory"
BACKUP_ARTIFACTORY_HZ="http://artifactory-hz1.int.net.nokia.com/artifactory"
MCSHARK_FOLDER="wslte5g_plugins-local/MCShark"
USER_PLUGIN_PATH="$HOME/.local/lib/wireshark/plugins"
VERSION="1.0"

function printUsage()
{
  cat <<EOF >&2
    ${S}$(basename $0) [options]

    --sbts  <build name>     | -B     The version of Center build(SBTS), used to load MCShark
                                      e.g.    --sbts SBTS00_ENB_9999_211011_000003
    --artifactory (optional) | -A     Path to ArtiFactory. Default use HZ artifactory if not set default artifactory to be used
                                      e.g.    --artifactory http://artifactory-hz1.int.net.nokia.com/artifactory
    --force (optional)       | -F     Force install. Default is "No", means not install if plugin exist.
                                      If force "Yes", check and rename existing plugins of the same type with additional extension ".deactivated",
                                      then copy plugin from ArtiFactory to Wireshark path.
                                      e.g.    --force
    --help,  -h                       Show this usage information
                                      e.g. ./install_wslte_plugins.bash -B SBTS22R1_ENB_0000_001027_000021
                                      ./install_wslte_plugins.bash -B SBTS22R1_ENB_0000_001027_000021 -A http://artifactory-espoo1.int.net.nokia.com/artifactory
EOF
  exit 1
}

function set_default_param()
{
    if [[ -z "${FORCE_INSTALL}" ]] ; then
        FORCE_INSTALL="No"
    fi
    if [[ -z "${GET_INSTALL}" ]] ; then
        GET_INSTALL="No"
    fi
    if [[ -z "${ARTIFACTORY_PATH}" ]] ; then
        ARTIFACTORY_PATH=${BACKUP_ARTIFACTORY_HZ}
    fi
}

function get_plugin_version_relate()
{
    echo "### WIRESHARK PLUGIN INSTALL START ###"
    WR_ver=$(tshark -v | grep -oE "TShark\s\(Wireshark\)\s[0-9]+\.[0-9]" | grep -oE "[0-9]+\.[0-9]")
    if [[ -z "${WR_ver}" ]] ; then
        echo "WireShark not installed, please check."
        exit 1
    fi
    echo "environment WireShark version is ${WR_ver}"
    OS_ver=$(grep -Po "^ID=+\K[^\"]+" /etc/os-release)
    OS_num=$(grep -Po "^VERSION_ID=\"+\K[^\"]+" /etc/os-release)
    OS_name=$(grep -Po "^VERSION=.*\(+\K[^\)]+" /etc/os-release)
    if [[ "${OS_ver}" !=  "debian" ]] ; then
        echo "Not Debian env, system type=[ ${OS_ver} ], please check."
        exit 1
    fi
    echo "environment system is ${OS_ver} ${OS_num}, install *+${OS_name}.so"

    USER_PLUGIN_PATH=$(tshark -G folders | grep '^Personal Lua Plugins:' | cut -d: -f2- | sed 's/^\s*//')
}

function if_plugin_installed_env()
{
    local plugin_name=$1
    tshark -G plugins > plugin.log
    if ! grep -q ${plugin_name} plugin.log ; then
        echo "NOT_INSTALL"
    else
        echo "INSTALL"
    fi
    rm -rf plugin.log
}

function plugin_exist_in_artifactory {
    local arti_url=$1
    status_code=$(curl -I -m 10 -o /dev/null -s -w %{http_code} ${arti_url})
    curl ${arti_url} > plugin_list.log
    if [[ "$status_code" == "404" ]]; then
        echo "NOT_EXIST"
    elif ! grep -q "${OS_name}.so" plugin_list.log ; then
        echo "NOT_EXIST"
    else
        echo "EXIST"
    fi
}

function plugins_download()
{
    plugin_install_path="${USER_PLUGIN_PATH}/${WR_ver}/epan"

    plugin_exist=$(plugin_exist_in_artifactory ${ARTIFACTORY_PATH}/${MCSHARK_FOLDER}/${BUILD_NAME}/)
    if [[ "${plugin_exist}" == "NOT_EXIST" ]] ; then
        if [[ "${ARTIFACTORY_PATH}" =~ "espoo" ]] ; then
            backup_artifactory=${BACKUP_ARTIFACTORY_HZ}
        else
            backup_artifactory=${BACKUP_ARTIFACTORY_ESPOO}
        fi
        echo "WARNING: no ${BUILD_NAME} in ${ARTIFACTORY_PATH}/${MCSHARK_FOLDER}/${BUILD_NAME}, Change to backup artifactory"
        download_backup_arti="Yes"
    else
        download_user_arti="Yes"
    fi

    if [[ ${download_user_arti} == "Yes" ]] ; then
        mcshark_plugin_name=$(grep -o -E "(mcshark-${WR_ver}.*+${OS_name}.so)\"" plugin_list.log | tail -1 | sed $'s/\"//g')
        rm -rf plugin_list.log
        install_check=$(if_plugin_installed_env ${mcshark_plugin_name})
        if [ "${install_check}" == "INSTALL" -a "${FORCE_INSTALL}" == "No" ] ; then
            echo "NOTICE: ${plugin_install_path}/${mcshark_plugin_name} EXIST! EXIT INSTALLATION"
            return 1
        fi
        wget ${ARTIFACTORY_PATH}/${MCSHARK_FOLDER}/${BUILD_NAME}/${mcshark_plugin_name} -O ${mcshark_plugin_name} || download_backup_arti="Yes"
    fi

    if [[ ${download_backup_arti} == "Yes" ]] ; then
        plugin_exist=$(plugin_exist_in_artifactory ${backup_artifactory}/${MCSHARK_FOLDER}/${BUILD_NAME}/)
        if [[ "${plugin_exist}" == "NOT_EXIST" ]] ; then
            echo "WARNING: no ${BUILD_NAME} in ${backup_artifactory}/${MCSHARK_FOLDER}/${BUILD_NAME}, please check"
            return 1
        else
            mcshark_plugin_name=$(grep -o -E "(mcshark-${WR_ver}.*+${OS_name}.so)\"" plugin_list.log | tail -1 | sed $'s/\"//g')
            rm -rf plugin_list.log
            install_check=$(if_plugin_installed_env ${mcshark_plugin_name})
            if [ "${install_check}" == "INSTALL" -a "${FORCE_INSTALL}" == "No" ] ; then
                echo "NOTICE: ${plugin_install_path}/${mcshark_plugin_name} EXIST! EXIT INSTALLATION"
                return 1
            fi
            wget ${backup_artifactory}/${MCSHARK_FOLDER}/${BUILD_NAME}/${mcshark_plugin_name} -O ${mcshark_plugin_name} || return 1
        fi
    fi
}

function plugins_install()
{
    if [ ! -d ${plugin_install_path} ];then
        mkdir -p ${plugin_install_path}
    fi

    if [[ "${FORCE_INSTALL}" == "Yes" ]] ; then
        echo "NOTICE: check if ${plugin_install_path}/${mcshark_plugin_name} EXIST, if Yes, do FORCE INSTALL! change existing plugins with additional extension .deactivated"
        [ -f ${plugin_install_path}/${mcshark_plugin_name} ] && mv -f ${plugin_install_path}/${mcshark_plugin_name} ${plugin_install_path}/${mcshark_plugin_name}.deactivated
    fi
    mv ${mcshark_plugin_name} ${plugin_install_path}/ || return 1
    echo "NOTICE: ${plugin_install_path}/${mcshark_plugin_name} INSTALL SUCCESS!"
}

echo $(basename $0) version $VERSION
echo Install plugins from artifactory into Wireshark 'LTE&5G' personal plugins folder
echo 

# one argument is mandatory:
if [ $# -lt 1 ] ; then
    printUsage
    exit 1
fi

while [ $# -gt 0 ] ; do
    case "${1}" in
        --sbts | -B )
            BUILD_NAME="${2}"
            if [[ -z "${BUILD_NAME}" ]] ; then
                printUsage
            fi
            shift
            ;;
        --artifactory | -A )
            ARTIFACTORY_PATH="${2}"
            if [[ -z "${ARTIFACTORY_PATH}" ]]; then
                printUsage
            elif [[ ! ${ARTIFACTORY_PATH} =~ ^https?://.*/artifactory$ ]]; then
                printUsage
            fi
            shift
            ;;
        --force | -F )
            FORCE_INSTALL="Yes"
            ;;
        --get | -G )
            GET_INSTALL="Yes"
            ;;           
        --help | -h )
            printUsage
            ;;
        * )
            printUsage
            ;;
    esac
    shift
done

set_default_param
get_plugin_version_relate

if [[ "${GET_INSTALL}" == "Yes" ]] ; then
    plugin_exist=$(plugin_exist_in_artifactory ${ARTIFACTORY_PATH}/${MCSHARK_FOLDER}/${BUILD_NAME}/)
    mcshark_plugin_name=$(grep -o -E "(mcshark-${WR_ver}.*+${OS_name}.so)\"" plugin_list.log | tail -1 | sed $'s/\"//g')
    rm -rf plugin_list.log
    install_check=$(if_plugin_installed_env ${mcshark_plugin_name})
    plugin_install_path="${USER_PLUGIN_PATH}/${WR_ver}/epan"
    if [ "${install_check}" == "INSTALL" ] ; then
        echo "mcshark plugin: ${plugin_install_path}/${mcshark_plugin_name}"
        exit 0
    else
        echo "mcshark NOT EXIST!"  
    fi
   	exit 0
    fi
    
# MCShark
if [[ -n "$BUILD_NAME" ]] ; then
  plugins_download && plugins_install || echo "ERROR: MCShark install FAILED"
fi

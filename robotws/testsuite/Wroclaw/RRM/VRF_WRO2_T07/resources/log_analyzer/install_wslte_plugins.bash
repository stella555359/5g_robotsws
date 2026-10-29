#!/usr/bin/env bash
#set -x
# This script is for wireshark plugins install. More details as page
# https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1262156447
# Install plugins from artifactory into Wireshark 'LTE&5G' personal plugins folder
# Changelog:
#  version 3.1: return value，see confluence page 1262156447#scripttoloadallplugins-returnvalues
#  version 3.0: plugins NOKIAXNAP/NOKIAF1AP installation support
#  version 2.0: plugins NSETAP/NSETAP-X installation support
#  version 1.0: script for plugin mcshark installation

# premiere artifactory is hz1 in hangzhou artifactory, will change to espoo1 in espoo1 artifactory
BACKUP_ARTIFACTORY_ESPOO="http://artifactory-espoo1.int.net.nokia.com/artifactory"
BACKUP_ARTIFACTORY_HZ="http://artifactory-hz1.int.net.nokia.com/artifactory"
PLUGIN_FOLDER="wslte5g_plugins-local"
NSETAPX_FOLDER="NSETAP_X"
NOKIAXN_FOLDER="Nokia_Xn_AP"
NOKIAF1_FOLDER="Nokia_F1_AP"
MCSHARK_N="MCShark"
NSETAP_N="NSETAP"
NSETAPX_N="NSETAPX"
NOKIAXN_N="NOKIAXNAP"
NOKIAF1_N="NOKIAF1AP"
USER_PLUGIN_PATH="$HOME/.local/lib/wireshark/plugins"
VERSION="3.1"

function printUsage()
{
  cat <<EOF >&2
    ${S}$(basename $0) [options]

    --sbts  <build name>     | -B     The version of Center build(SBTS), used to load MCShark
                                      e.g.    --sbts SBTS00_ENB_9999_211011_000003
    --nsetap (optional)      | -N     NSETAP interface version
                                      e.g.    --nsetap 2.18.0
    --nsetapx (optional)     | -S     NSETAP-X interface version
                                      e.g.    --nsetapx 1.3.2
    --nokiaxn (optional)     | -O     Nokia Xn-AP protocol version extended on top of 3GPP versions
                                      e.g.    --nokiaxn 16.6.0-1.0
    --nokiaf1 (optional)     | -K     Nokia F1-AP protocol version extended on top of 3GPP versions
                                      e.g.    --nokiaf1 16.6.0-1.0
    --artifactory (optional) | -A     Path to ArtiFactory. Default use HZ artifactory if not set default artifactory to be used
                                      e.g.    --artifactory http://artifactory-hz1.int.net.nokia.com/artifactory
    --force (optional)       | -F     Force install. Default is "No", means not install if plugin exist.
                                      If force "Yes", check and rename existing plugins of the same type with additional extension ".deactivated",
                                      then copy plugin from ArtiFactory to Wireshark path.
                                      e.g.    --force
    --help,  -h                       Show this usage information
                                      e.g.
                                      ./install_wslte_plugins.bash -B SBTS22R1_ENB_0000_001027_000021
                                      ./install_wslte_plugins.bash -B SBTS22R1_ENB_0000_001027_000021 -A http://artifactory-espoo1.int.net.nokia.com/artifactory
                                      ./install_wslte_plugins.bash -B SBTS22R1_ENB_0000_001027_000021 -N 2.19.0 -S 1.4.4
                                      ./install_wslte_plugins.bash --sbts SBTS22R1_ENB_0000_001027_000021 --nsetap 2.19.0 --force
EOF
  exit 1
}

function set_default_param()
{
    if [[ -z "${FORCE_INSTALL}" ]] ; then
        FORCE_INSTALL="No"
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
    elif ! grep -q "${WR_ver}.*+${OS_name}.so" plugin_list.log ; then
        echo "NOT_EXIST"
    else
        echo "EXIST"
    fi
}

function get_plugin_name()
{
    local plugintype=$1
    local pluginInfo=$2
    local pluginName=""
    pluginName=$(grep -o -E "(${plugintype,,}-${WR_ver}.*+${OS_name}.so)\"" plugin_list.log | tail -1 | sed $'s/\"//g')
    if [[ -z "${pluginName}" ]] ; then
        echo "Warning: No plugin for ${plugintype} ${pluginInfo} "
    else
        echo ${pluginName}
    fi
}
function plugins_download()
{
    local plugintype=$1
    local pluginInfo=$2
    local download_user_arti="No"
    local download_backup_arti="No"
    plugin_install_path="${USER_PLUGIN_PATH}/${WR_ver}/epan"
    if [[ "${plugintype}" == "${MCSHARK_N}" ]] ; then
        PLUGINPATH=${PLUGIN_FOLDER}/${MCSHARK_N}/${pluginInfo}
    elif [[ "${plugintype}" == "${NSETAP_N}" ]] ; then
        PLUGINPATH="${PLUGIN_FOLDER}/${NSETAP_N}/${NSETAP_N,,}-${pluginInfo}"
    elif [[ "${plugintype}" == "${NSETAPX_N}" ]] ; then
        PLUGINPATH="${PLUGIN_FOLDER}/${NSETAPX_FOLDER}/${NSETAPX_N,,}-${pluginInfo}"
    elif [[ "${plugintype}" == "${NOKIAXN_N}" ]] ; then
        PLUGINPATH="${PLUGIN_FOLDER}/${NOKIAXN_FOLDER}/${NOKIAXN_N,,}-${pluginInfo}"
    elif [[ "${plugintype}" == "${NOKIAF1_N}" ]] ; then
        PLUGINPATH="${PLUGIN_FOLDER}/${NOKIAF1_FOLDER}/${NOKIAF1_N,,}-${pluginInfo}"
    fi

    plugin_exist=$(plugin_exist_in_artifactory ${ARTIFACTORY_PATH}/${PLUGINPATH}/)
    if [[ "${plugin_exist}" == "NOT_EXIST" ]] ; then
        if [[ "${ARTIFACTORY_PATH}" =~ "espoo" ]] ; then
            backup_artifactory=${BACKUP_ARTIFACTORY_HZ}
        else
            backup_artifactory=${BACKUP_ARTIFACTORY_ESPOO}
        fi
        echo "WARNING: no Wireshark ${WR_ver}  ${OS_name} build in ${ARTIFACTORY_PATH}/${PLUGINPATH}, Change to backup artifactory"
        download_backup_arti="Yes"
    else
        download_user_arti="Yes"
    fi

    if [[ ${download_user_arti} == "Yes" ]] ; then
        plugin_name=$(get_plugin_name ${plugintype} ${pluginInfo})
        rm -rf plugin_list.log
        install_check=$(if_plugin_installed_env ${plugin_name})
        if [ "${install_check}" == "INSTALL" -a "${FORCE_INSTALL}" == "No" ] ; then
            echo "NOTICE: ${plugin_install_path}/${plugin_name} EXIST! EXIT INSTALLATION"
            return 1
        fi
        wget ${ARTIFACTORY_PATH}/${PLUGINPATH}/${plugin_name} -O ${plugin_name} || download_backup_arti="Yes"
    fi

    if [[ ${download_backup_arti} == "Yes" ]] ; then
        plugin_exist=$(plugin_exist_in_artifactory ${backup_artifactory}/${PLUGINPATH}/)
        if [[ "${plugin_exist}" == "NOT_EXIST" ]] ; then
            echo "WARNING: no Wireshark ${WR_ver}  ${OS_name} build in ${backup_artifactory}/${PLUGINPATH}, please check"
            return 1
        else
            plugin_name=$(get_plugin_name ${plugintype} ${pluginInfo})
            rm -rf plugin_list.log
            install_check=$(if_plugin_installed_env ${plugin_name})
            if [ "${install_check}" == "INSTALL" -a "${FORCE_INSTALL}" == "No" ] ; then
                echo "NOTICE: ${plugin_install_path}/${plugin_name} EXIST! EXIT INSTALLATION"
                return 1
            fi
            wget ${backup_artifactory}/${PLUGINPATH}/${plugin_name} -O ${plugin_name} || return 1
        fi
    fi
}

function plugins_install()
{
    if [ ! -d ${plugin_install_path} ];then
        mkdir -p ${plugin_install_path}
    fi

    if [[ "${FORCE_INSTALL}" == "Yes" ]] ; then
        echo "NOTICE: check if ${plugin_install_path}/${plugin_name} EXIST, if Yes, do FORCE INSTALL! change existing plugins with additional extension .deactivated"
        [ -f ${plugin_install_path}/${plugin_name} ] && mv -f ${plugin_install_path}/${plugin_name} ${plugin_install_path}/${plugin_name}.deactivated
    fi
    mv ${plugin_name} ${plugin_install_path}/ || return 1
    echo "NOTICE: ${plugin_install_path}/${plugin_name} INSTALL SUCCESS!"
}

function plugin_install_go()
{
    local plugin_install_No=$1
    local failed_install_counter=0
    # MCShark
    if [[ -n "${BUILD_NAME}" ]] ; then
        plugins_download ${MCSHARK_N} ${BUILD_NAME} && plugins_install || {
            echo "ERROR: ${MCSHARK_N} install FAILED"
            let failed_install_counter++
        }
    fi

    if [[ -n "${nsetap_version}" ]] ; then
        plugins_download ${NSETAP_N} ${nsetap_version} && plugins_install || {
            echo "ERROR: ${NSETAP_N} install FAILED"
            let failed_install_counter++
        }
    fi

    if [[ -n "${nsetapx_version}" ]] ; then
        plugins_download ${NSETAPX_N} ${nsetapx_version} && plugins_install || {
            echo "ERROR: ${NSETAPX_N} install FAILED"
            let failed_install_counter++
        }
    fi

    if [[ -n "${nokiaxn_version}" ]] ; then
        plugins_download ${NOKIAXN_N} ${nokiaxn_version} && plugins_install || {
            echo "ERROR: ${NOKIAXN_N} install FAILED"
            let failed_install_counter++
        }
    fi

    if [[ -n "${nokiaf1_version}" ]] ; then
        plugins_download ${NOKIAF1_N} ${nokiaf1_version} && plugins_install || {
            echo "ERROR: ${NOKIAF1_N} install FAILED"
            let failed_install_counter++
        }
    fi

    if [[ ${failed_install_counter} -eq 0 ]]; then
        exit 0
    elif [[ ${failed_install_counter} -lt ${plugin_install_No} ]]; then
        exit 1
    elif [[ "${failed_install_counter}" -ge ${plugin_install_No} ]]; then
        exit 2
    fi
}
echo $(basename $0) version $VERSION
echo Install plugins from artifactory into Wireshark 'LTE&5G' personal plugins folder
echo 

# one argument is mandatory:
if [ $# -lt 1 ] ; then
    printUsage
    exit 1
fi

plugin_install_No=0
while [ $# -gt 0 ] ; do
    case "${1}" in
        --sbts | -B )
            BUILD_NAME="${2}"
            if [[ -z "${BUILD_NAME}" ]] ; then
                printUsage
            fi
            let plugin_install_No++
            shift
            ;;
        --nsetap | -N )
            nsetap_version="${2}"
            if [[ -z "${nsetap_version}" ]] ; then
                printUsage
            fi
            let plugin_install_No++
            shift
            ;;
        --nsetapx | -S )
            nsetapx_version="${2}"
            if [[ -z "${nsetapx_version}" ]] ; then
                printUsage
            fi
            let plugin_install_No++
            shift
            ;;
        --nokiaxn | -O )
            nokiaxn_version="${2}"
            if [[ -z "${nokiaxn_version}" ]] ; then
                printUsage
            fi
            let plugin_install_No++
            shift
            ;;
        --nokiaf1 | -K )
            nokiaf1_version="${2}"
            if [[ -z "${nokiaf1_version}" ]] ; then
                printUsage
            fi
            let plugin_install_No++
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
plugin_install_go ${plugin_install_No}


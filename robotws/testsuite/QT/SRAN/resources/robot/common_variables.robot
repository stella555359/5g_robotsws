*** Settings ***
Documentation       Place for QT common variables

*** Variables ***
@{testlines_with_LMI}       4001    4005    4038
@{change_sync_testlines}    4015    4030    4027

@{testlines_with_wihajster}    4003    4028    4035    4044    5005    5009
@{UE_with_qualcomm_chip}    quectel   askey   simcom
&{class_name_dict}     5G=NRCEL    4G=LNCEL    3G=WNCEL    2G=GNCEL
&{cell_check_keys}    operationalState=enabled    proceduralStatus=configured    blockingState=Unblocked    proceduralState=OnAirDone

# Suite env variables
${QT_CONFIG_BRANCHES}    qt_configs/branches

# Logs
${LOG_PATH}          ${OUTPUT_DIR}/Additional_Execution_Logs
${collect_UE_logs}   False
${RDC_LOGS}          ${LOG_PATH}/RDC

# MRAT: connect to secondary core
${FSM_SLAVE_IP}          192.168.255.7

# ePC SIM core simulator variables
${EGATE_CUS_PATH}     ${CURDIR}/../../configs/epc_sim_files/cus.lua
${EGATE_PORT}         20000
${EDAEMON_PORT}       10000
@{4G_RF_LIST}         RF1

# Container nodes
@{ASIA_node}    11
@{ASIB_node}    11    #21
@{ASIK_node}    11    21
@{ASIL_node}    11    21
@{ASIM_node}    11
@{ASOE_node}    11
@{ABIA_node}    3D    4D    5D    6D
@{ABIL_node}    3D    4D    5D
@{ABIO_node}    3D    4D    5D
@{ABIP_node}    3D    4D

# Checking if not allowed alarm has occurred before
${not_allowed_alarm_appeared_in_previous_test_case}    ${False}

#Checking if check error message in syslog was done
${are_logs_checked}    ${False}

# COLORS
${RED}          "\\033[31m"
${GREEN}        "\\033[32m"
${BYELLOW}      "\\033[1;33m"
${COLOR_OFF}    "\\033[0m"

#Other
${rmod}             ${EMPTY}
${LMP_IP}           192.168.255.129
${asik_username}    toor4nsn
${asik_password}    oZPS0POrRieRtu

@{skip_internal_retest_regex_patterns}
...    NoIpError: A requested interface.*not found
...    Fail to get brand info from ue
...    Variable.*not found
...    No keyword with name.*found
...    Device.*is not detected in ADB
...    Ueproxy service is not available
...    ConnectionError.*HTTPConnectionPool.*Max retries exceeded with url
...    RequiredUeNotFound
...    start_data_transfer.*failed
...    AttributeError.*NoneType.*object has no attribute.*attach
...    Unable to check UE PC platform
...    List of devices attached
...    ADB recover from offline or unauthorized failed
...    taf.ue.proxy.proxy.exceptions.UeNotReserved
...    CPC connection failed
...    Interface .* not found
...    DeviceChangeStateFailure
...    UE Proxy with ID .* not found
...    The requested resource is in use
...    The last error was.*KeyError.*sid
...    ElixirException
...    PduConnectionError
...    reserve_ue
...    CommandOutputTimeoutError
...    List .*has no item in index
...    change_network_mode

#env health checker
${supported_sfp_file}    /home/ute/DSL-QT/text_files/configs/SFPs.json
${rf_sfp_mapping_file}   /home/ute/DSL-QT/text_files/configs/RF_SFP_mapping.json

#RDC
@{RDC_FID_LIST}    10

#used for netboot and yaft
&{AIRSCALE_FSMF_DUALCORE_testpc_index_map}
...    slave=0
...    master=1
&{single_board_testpc_index_map}
...    master=0

# O-RU list
@{oran_rf_list}    AXEGHA

# local CCR related info
${WRO_local_registry_url}    ccr-wl-qt-01.wroclaw.nsn-rdnet.net:443/nop
${WRO_local_registry_auth}   qt.prodzn:Bs91zgLteFvpxrhl6hC35YdebXCiUTRo
${OULU_local_registry_url}    harbor.ou-si-rhacm.dyn.nesc.nokia.net:443/nop
${OULU_local_registry_auth}   admin:Harbor12345

#Global CCR related info
${WRO_global_registry_url}    mn-cosi-scm-cran-docker-virtual.artifactory-mn-espoo3.int.net.nokia.com
${OULU_global_registry_url}    mn-cosi-scm-cran-docker-virtual.artifactory-mn-espoo3.int.net.nokia.com

${plugin_artifactory_url}    https://artifactory-espoo1.ext.net.nokia.com/artifactory/mn-android-apk
${espoo1_prodzn_API_Key}     AKCp5bBD1dczsBQQtuy5V6mDGqNtDhKrwwZCjvgssswmEKmdtcSvJtTr9zsJQHY7PuDjpigqn
${espoo2_prodzn_API_Key}     AKCp8ohoJ5wojZd9AMggM8gTCzPvfWtXhvseuYRbLXrSJr4KAAMZwkt4vPcmsu1GWvDSkk1hA
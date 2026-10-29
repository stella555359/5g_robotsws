*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    RAN_5G    RAN_5G_FDD    CRT     SBTS00    SBTS23R1

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library      ute_admin_infomodel

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AZQI_8985_4.xml
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_cb008985_AZQI_A1_2.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_SA.cfg


Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SMOD}    ASIB
${GNB_IP}    192.168.255.129
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu
${ADMIN_INFOMODEL_ALIAS}=                      infomodel_1
${ADMIN_INFOMODEL_LOG_DIR}=                    ${OUTPUT_DIR}
${ADMIN_INFOMODEL_FILENAME}=                   infomodel.ims2

*** Test Cases ***
CB008985-A_A1_FR1_TDD_SuperCell_feature_activation_and_configuration_SA
    Verify Supercell setup

*** Keywords ***
Query Infomodel And Expect Parameter Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=60
    ${out_query_result}=   ute_admin_infomodel.Query Infomodel    query=${dist_name} is [${parameter}=${value}]
    ...    timeout=${timeout}  alias=${ADMIN_INFOMODEL_ALIAS}

Start Infomodel Logging
    ute_admin_infomodel.Setup infomodel    address=192.168.255.129    port=443    alias=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Connect infomodel    alias=${ADMIN_INFOMODEL_ALIAS}

Stop Infomodel Logging
    [Arguments]    ${filename}=${ADMIN_INFOMODEL_FILENAME}
    ...            ${log_dir}=${ADMIN_INFOMODEL_LOG_DIR}
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Save Infomodel Log    filename=${log_dir}/${filename}  alias=${alias}
    ute_admin_infomodel.Disconnect Infomodel  alias=${alias}
    ute_admin_infomodel.Teardown Infomodel    alias=${alias}

Verify Supercell setup
    Start Infomodel Logging
    Query Infomodel And Expect Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/NRBTS_R-1/NRCELL_R-1
    ...    parameter=numOfSuperSubCells
    ...    value=4
    Stop Infomodel Logging

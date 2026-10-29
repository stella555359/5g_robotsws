*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Prepare QT LOLO Enviroment    TYPE=FDD
#...               AND    Common Suite Setup
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CRT    RAN_5G_FDD
#...               FR1    Owner_yalsun    PRI-High    RAN_5G
#...               SBTS00    SBTS23R1    SBTS22R4    CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#Resource          ../../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config
#${DELTA_FILE}                Delta_Conf_5GC002314_L.json
#${UE_ID}                     1
#${PROFILE_ID}                1
#${GNB_ID}                    2
#${CELL_ID}                   2
#${BEARER_ID}                 2
#@{LOG_NAME_LIST}             btslog    snapshot    tcpdump
#${COUNT}                     1
#${GNBCUTYPE}                 SA
#${PING_MATCH}                from\\s+[0-9,\.\:]+\\s+[a-z,\_\=]+\\d+\\s+[a-z,\=,0-9]+
#${WEBUI_USER}                Nemuadmin
#${WEBUI_PWD}                 nemuuser
#${SCFC_PATH}                 ${CURDIR}/resources/scfc
#${WTS_DIR}                   /opt/iphy/latest
#${RESOURCE_PATH}             ${CURDIR}/resources
#${wts_path}                  ../../CUDU_L2/sg09_squad1/WTS
#
#
#*** Test Cases ***
#
#5GC002314-L-ET-A005 support dynamic start CCE among the available PDCCH candidates allowed for MT paging.
#    ${StartCce}    ${StartCce2}    Attach 1 UE and Get StartCce from BIP log
#    Set Test Variable    ${StartCce}
#    Check If StartCce is Random
#
#
#*** Keywords ***
#Common Suite Setup
#    Set Suite Variable    ${WTS_CFG}    FDD_basic_setup.cfg
#    Suite Setup Update GNB    scf_file=${DELTA_FILE}
#   # Download MCShark To UTE    ${SW_VERSION_TOTAL}
#    Suite Setup Start WTS And Check OnAir
#
#Easy Common Suite Setup
#    Create Suite Directory
#    Kill egate and edaemon process
#    Suite Setup Start WTS And Check OnAir
#
#Kill egate and edaemon process
#    OperatingSystem.run    sudo pkill edaemon
#    OperatingSystem.run    sudo pkill egate
#
#Paging for UE from AMF
#    Log To Console    start paging for UE...
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    amf_paging_start id\=1 ue\=1    pass_regexp=Paging UE with 5G-S-TMSI    timeout=10s
#    ${output1}    String.Get Lines Matching Regexp    ${output}    Paging UE with 5G-S-TMSI    partial_match=${true}
#    sleep    3s
#    Log To Console    \n${output1}
#
#Check StartCce from wirshark
#    Convert BIP To CSV By MCShark for pdcch
#    ${startCce1}    ${startCce2}    Check startCce In PdcchSendReq
#    [Return]    ${startCce1}    ${startCce2}
#
#Attach 1 UE and Get StartCce from BIP log
#    SA 5G Attach    ${UE_ID}
#    sleep    30s
#    Start Gnb BIP Log
#    Sleep    3s
#    Paging for UE from AMF
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
#    ${StartCce1}    ${StartCce2}    Check StartCce from wirshark
#    [Return]    ${startCce1}    ${StartCce2}
#
#Check If StartCce is Random
#    FOR    ${var}    IN RANGE    10
#         SA 5G Detach    ${UE_ID}
#         sleep    5s
#         ${StartCce1}    ${StartCce2}    Attach 1 UE and Get StartCce from BIP log
#         Exit for loop if    '${StartCce}'!='${StartCce2}' or '${StartCce1}'!='${StartCce2}'
#         Log  run ${var} times, StartCce is the same    console=True
#         sleep    5s
#    END
#    should be True    '${StartCce}'!='${StartCce2}' or '${StartCce1}'!='${StartCce2}'
#
#Convert BIP To CSV By MCShark for pdcch
#    ${filter}=    Set Variable    (DlData_DciInfo.startCce) && (3gpp.rnti == 65534)
#    @{csv_title_list}=    Create List    DlData_DciInfo.startCce
#    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    5GBipL2L1_filtering_off*.pcap*    ${True}
#    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
#         Convert BIP To CSV By MCShark   ${name}    ${OUTPUT_DIR}/DlData_PdcchSendReq.csv    ${filter}    ${csv_title_list}
#    END
#
#Check startCce In PdcchSendReq
#    @{startCce_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/DlData_PdcchSendReq.csv    DlData_DciInfo.startCce    ["1", ""]    except    no
#    [Return]    @{startCce_list}[0]    @{startCce_list}[1]

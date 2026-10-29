*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Prepare QT LOLO Enviroment    TYPE=TDD
#...               AND    Common Suite Setup
#Suite Teardown    Common Suite Teardown    mode=debug
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown    mode=debug
#Force Tags        CRT    RAN_5G_TDD
#...               FR1    Owner_yalsun    PRI-High    CDRT    RAN_5G    SBTS00    SBTS23R1    SBTS22R4    SBTS22R1    SBTS22R3    SBTS22R2
#...               CN1_SQ    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#Resource          ../CUDU_L2/common_setup_teardown.robot
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config
#${DELTA_FILE}                Delta_Conf_5GC002314_L.json
#${UE_ID}                     1
#${PROFILE_ID}                1
#${GNB_ID}                    2
#${CELL_ID}                   2
#${BEARER_ID}                 2
##@{LOG_NAME_LIST}             btslog    snapshot    tcpdump
#@{LOG_NAME_LIST}             btslog
#${COUNT}                     1
#${GNBCUTYPE}                 SA
#${PING_MATCH}                from\\s+[0-9,\.\:]+\\s+[a-z,\_\=]+\\d+\\s+[a-z,\=,0-9]+
#${WEBUI_USER}                Nemuadmin
#${WEBUI_PWD}                 nemuuser
#${SCFC_PATH}                 ${CURDIR}/resources/scfc
#${WTS_DIR}                   /opt/iphy/latest
#${RESOURCE_PATH}             ${CURDIR}/resources
#
#*** Test Cases ***
#5GC002314-L-ET-A006 support dynamic start PRB for PDSCH for MT paging.
#    SA 5G Attach    ${UE_ID}
#    sleep    15s
#    Start Gnb BIP Log
#    Sleep    1s
#    Paging for UE from AMF
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
#    Check StarPrb from wirshark
#
#*** Keywords ***
#Common Suite Setup
#    Set Suite Variable    ${WTS_CFG}    TDD_basic_setup.cfg
#    Suite Setup Update GNB    scf_file=${DELTA_FILE}
#    #Suite Setup Copy WTS Config Files From QT
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
#    sleep    1s
#    Log To Console    \n${output1}
#
#Check StartCce from wirshark
#    ${pdml_entries}    PCAP.Load Pcap File
#    ...    pcap_file=${TEST_LOG_DIRECTORY}/5GBipL2L1_filtering_off.pcap0
#    ...    luashark_path=${output_dir}/generated_luashark/luashark.lua
#    ${filter_expression}=    Catenate    DlData_PdcchSendReq.dciInfo_item_15.rnti == 0xfffe || DlData_PdcchSendReq.dciInfo_item_0.rnti == 0xfffe
#    ${filtered_packets}=    PCAP.filter_packets_by_expression    pdml_list=${pdml_entries}    filter_expression=${filter_expression}
#    ${startCce_list}=    PCAP.get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...        xpath=.//DlData_PdcchSendReq.dciInfo_item_15.startCce | //DlData_PdcchSendReq.dciInfo_item_0.startCce
#    [Return]    ${startCce_list[0]}
#
#Check StarPrb from wirshark
#    #Download MCShark To UTE    ${SW_VERSION_TOTAL}
#    Convert BIP To CSV By MCShark for pdsch
#    Check startPrb In PdschSendReq
#
#Convert BIP To CSV By MCShark for pdsch
#    ${filter}=    Set Variable    dldata_pdschsendreq
#    @{csv_title_list}=    Create List    DlData_PdschGrant.startPrb
#    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    5GBipL2L1_filtering_off*.pcap*    ${True}
#    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
#         Convert BIP To CSV By MCShark   ${name}    ${OUTPUT_DIR}/DlData_PdschSendReq.csv    ${filter}    ${csv_title_list}
#    END
#
#Check startPrb In PdschSendReq
#    @{data_list_1}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/DlData_PdschSendReq.csv    DlData_PdschGrant.startPrb    ["0", ""]    except    no
#    FOR    ${i}    IN    @{data_list_1}
#         Should Be True    ${i}!=None
#    END
#
#Attach 1 UE and Get StartCce from BIP log
#    SA 5G Attach    ${UE_ID}
#    sleep    15s
#    Start Gnb BIP Log
#    Paging for UE from AMF
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
#    ${StartCce}    Check StartCce from wirshark
#    [Return]    ${startCce}
#
#Check If StartCce is Random
#    FOR    ${var}    IN RANGE    10
#         SA 5G Detach    ${UE_ID}
#         sleep    5s
#         ${StartCce2}    Attach 1 UE and Get StartCce from BIP log
#         Exit for loop if    '${StartCce1}'!='${StartCce2}'
#         Log  run ${var} times, StartCce is the same    console=True
#         sleep    5s
#    END
#    should be True    '${StartCce2}'!='${StartCce1}'

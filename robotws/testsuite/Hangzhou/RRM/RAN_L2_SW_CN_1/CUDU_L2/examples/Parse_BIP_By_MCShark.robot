*** Settings ***
Documentation
...    a2a example for check csv file
Resource         ./../common_setup_teardown.robot

*** Variables ***
${UE_ID}                1    #11 for NSA
${PROFILE_ID}          1
${GNB_ID}              2
${CELL_ID}             1
${BEARER_ID}           2
${ASP_BOARD_TYPE}    ABIO
*** Test Cases ***
Test Prepare
    Suite Setup Update GNB

MCShark_Example
    Download MCShark To UTE
    Copy Preference For MCShark    ${CURDIR}/MCShark/preferences_A_20M
    Convert BIP To CSV By MCShark For 5GC001817-A
    A2A_Check_CSV_Table    ${CURDIR}/bip_a2a/1817_bip_1.ini    ${OUTPUT_DIR}/csv_C018.csv

*** Keywords ***
Suite Setup Update GNB
    Clean Up Env
    Create Suite Directory
    Get All Testline Information And Set Suite Variable
    Print Testline Info Ahead Of Report

Download MCShark To UTE
    [Arguments]    ${sw_version}=${SW_VERSION_TOTAL}
#    ${sw_version}=    Set Variable     SBTS21B_ENB_0000_000404_000000
    Run    wget -r -np -nH ${MCSHARK_URL}/${sw_version}/
    ${MCShark}=    Run    ls ${EXECDIR}/artifactory/mcshark-local/${sw_version}/mcshark-*buster.so
    Run    sudo cp ${MCShark} ${MCSHARK_PLUGIN}/3.6/epan/

Copy Preference For MCShark
    [Arguments]    ${preference_file}
    #${preference_file}=    Set Variable    /home/ute/Downloads/preferences
    Run    sudo cp ${preference_file} /home/ute/.config/wireshark/preferences
    Run    sudo cp ${preference_file} /usr/share/wireshark/preferences

Convert BIP To CSV By MCShark
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    ${csv_title}=    Set Variable
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}

Convert BIP To CSV By MCShark For 5GC001817-A
    ${bip_file}=    Set Variable    /home/ute/Downloads/5GBipL2L1_filtering_off.pcap0
    ${filter}=    Set Variable    dci.dci01.CSIrequest == 1||uldata_puschreceivereq||uldata_puschreceiverespps
    @{csv_title_list}=    Create List    l1_common.sfn    l1_common.slot    dci.dci01.CSIrequest
    ...    UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits    l1_common_dtx_t.value    l1_common_crc_t.value
    ...    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    UlData_UePuschReceiveRespPs_t.dtxCsiPart2
    Convert BIP To CSV By MCShark    ${bip_file}    ${OUTPUT_DIR}/ACSI.csv    ${filter}    ${csv_title_list}

Convert BIP To CSV By MCShark For 5GC001817_C
    ${filter}=    Set Variable    dci.dci01.CSIrequest == 1||UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits != 0x00
    @{csv_title_list}=    Create List    l1_common.sfn    dci.dci01.CSIrequest
    ...    dci.dci01.BetaOffsetInd    UlData_puschReceiveReqGrant_t.numOfUciAckBits
    Convert BIP To CSV By MCShark    ${SUITE_LOG_DIRECTORY}/5GBipL2L1_filtering_off*.pcap*    ${OUTPUT_DIR}/csv_C018.csv
    ...    ${filter}    ${csv_title_list}

A2A_Check_CSV_Table
    [Arguments]    ${ini_file}    ${check_csv_file}    ${log_path}=${OUTPUT_DIR}
    ta_a2a.Check Log With Au2anlysis    ${ini_file}    i    ${check_csv_file}
    ...    save_log_directory=${log_path}


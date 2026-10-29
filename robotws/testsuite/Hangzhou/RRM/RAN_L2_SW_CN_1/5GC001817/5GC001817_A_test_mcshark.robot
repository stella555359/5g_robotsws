*** Settings ***
Documentation    ...
#Resource          ../CUDU_L2/common_setup_teardown.robot
#Resource          ../5GC001808/AirPhone_common_resource_UTE_CR.robot
#*** Variables ***
##please put mcshark and pcap file to current folder
##download pcap address:
##https://rep-portal.wroclaw.nsn-rdnet.net/reports/test-runs/?end_db=30&testRun=5GC001817_A005_SA_NSA
#${mcshark_name}    mcshark-3.4-0.990.3106+buster.so
#${pcap_name}       xpLog_RessourceAreaAllocationReqResp.pcap
#*** Test Cases ***
#5GC001817_test_mcshark
#    [Documentation]    The purpose
#    [Tags]    Owner_y1xin    case_A005
#    ${MCShark_newest}=    Set Variable    ${CURDIR}/${mcshark_name}
#    ${bip_names}    OperatingSystem.List Files In Directory    ${CURDIR}   ${pcap_name}    ${True}
#    Set Suite Variable    ${bip_names}
#    OperatingSystem.Run    sudo rm -f /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.4/epan/mcshark-*buster.so
#    ${rc}=    OperatingSystem.Run And Return Rc    sudo cp ${MCShark_newest} /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.4/epan/
#    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_c_20M
#    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    001
#    Check l1_common_dtx_t.value in PuschReceiveRespPs    001
#    Check csiPart1CrcCheck in PuschReceiveRespPs    001
#    Check csiPart2CrcCheck in PuschReceiveRespPs    001
#    Check dtxCsiPart1 in PuschReceiveRespPs    001
#    Check dtxCsiPart2 in PuschReceiveRespPs    001
#    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU    001
#    Check CRCNOK Rate in PuschReceiveRespHarqU    001
#
#*** Keywords ***
#Convert BIP To CSV By MCShark For 5GC001817-A
#    [Arguments]    ${tc_id}
#    ${filter}=    Set Variable    dci.dci01.CSIrequest == 1||UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits != 0x00||uldata_puschreceiverespps
#    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    dci.dci01.CSIrequest    UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits
#    ...    UlData_UePuschReceiveRespPs_t.dtx    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck
#    ...    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    UlData_UePuschReceiveRespPs_t.dtxCsiPart2
#    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
#         Convert BIP To CSV By MCShark   ${name}    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    ${filter}    ${csv_title_list}
#    END
#
#Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq
#    [Arguments]    ${tc_id}
#    Log To Console    Check A-CSI in PdcchSendReq.
#    Convert BIP To CSV By MCShark For 5GC001817-A    ${tc_id}
#    A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${tc_id}/ttitrace_1_a.ini    ${CURDIR}/Resource/TC${tc_id}/ttitrace_1_a.csv
#
#Check l1_common_dtx_t.value in PuschReceiveRespPs
#    [Arguments]    ${tc_id}
#    Log To Console    Check DTX in Ul PuschReceiveRespPs.
#    ${total_number}    Get Total l1_common_dtx_t.value Number    ${tc_id}
#    ${failed_number}    Get Total Failed l1_common_dtx_t.value Number    ${tc_id}
#    ${rate}    Evaluate    float(${failed_number})/(${total_number})
#    Log To Console    DTX Rate is ${rate}
#    Should Be True    ${rate}<0.01
#
#Get Total l1_common_dtx_t.value Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtx    ["0", "1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Get Total Failed l1_common_dtx_t.value Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtx    ["1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Check csiPart1CrcCheck in PuschReceiveRespPs
#    [Arguments]    ${tc_id}
#    Log To Console    Check csiPart1CrcCheck in Ul PuschReceiveRespPs.
#    ${total_number}    Get Total csiPart1CrcCheck Number    ${tc_id}
#    ${failed_number}    Get Total Failed csiPart1CrcCheck Number    ${tc_id}
#    ${rate}    Evaluate    float(${failed_number})/(${total_number})
#    Log To Console    CRCNOK Rate is ${rate}
#    Should Be True    ${rate}<0.01
#
#Get Total csiPart1CrcCheck Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    ["0", "1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Get Total Failed csiPart1CrcCheck Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    ["1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Check csiPart2CrcCheck in PuschReceiveRespPs
#    [Arguments]    ${tc_id}
#    Log To Console    Check csiPart2CrcCheck in Ul PuschReceiveRespPs.
#    ${total_number}    Get Total csiPart2CrcCheck Number    ${tc_id}
#    ${failed_number}    Get Total Failed csiPart2CrcCheck Number    ${tc_id}
#    ${rate}    Evaluate    float(${failed_number})/(${total_number})
#    Log To Console    CRCNOK Rate is ${rate}
#    Should Be True    ${rate}<0.01
#
#Get Total csiPart2CrcCheck Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck    ["0", "1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Get Total Failed csiPart2CrcCheck Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck    ["1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Check dtxCsiPart1 in PuschReceiveRespPs
#    [Arguments]    ${tc_id}
#    Log To Console    Check dtxCsiPart1 in Ul PuschReceiveRespPs.
#    ${total_number}    Get Total dtxCsiPart1 Number    ${tc_id}
#    ${failed_number}    Get Total Failed dtxCsiPart1 Number    ${tc_id}
#    ${rate}    Evaluate    float(${failed_number})/(${total_number})
#    Log To Console    dtxCsiPart1 Rate is ${rate}
#    Should Be True    ${rate}<0.01
#
#Get Total dtxCsiPart1 Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    ["0", "1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Get Total Failed dtxCsiPart1 Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    ["1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Check dtxCsiPart2 in PuschReceiveRespPs
#    [Arguments]    ${tc_id}
#    Log To Console    Check dtxCsiPart2 in Ul PuschReceiveRespPs.
#    ${total_number}    Get Total dtxCsiPart2 Number    ${tc_id}
#    ${failed_number}    Get Total Failed dtxCsiPart2 Number    ${tc_id}
#    ${rate}    Evaluate    float(${failed_number})/(${total_number})
#    Log To Console    dtxCsiPart2 Rate is ${rate}
#    Should Be True    ${rate}<0.01
#
#Get Total dtxCsiPart2 Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart2    ["1", "0"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Get Total Failed dtxCsiPart2 Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart2    ["1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Convert BIP To CSV By MCShark For PuschReceiveRespHarqU
#    [Arguments]    ${tc_id}
#    ${filter}=    Set Variable    uldata_puschreceiverespharqu
#    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_UePuschReceiveRespHarqU_t.crc
#    ...    UlData_UePuschReceiveRespHarqU_t.dtx
#    ${bip_names}    OperatingSystem.List Files In Directory    ${SUITE_LOG_DIRECTORY}    5GBipL2L1_filtering_off*.pcap*    ${True}
#    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
#         Convert BIP To CSV By MCShark   ${name}    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    ${filter}    ${csv_title_list}
#    END
#
#Check CRCNOK Rate in PuschReceiveRespHarqU
#    [Arguments]    ${tc_id}
#    Log To Console    CRCNOK Rate in PuschReceiveRespHarqU.
#    ${total_number}    Get Total UlDataPuschReceiveRespHarqU Message Number 1817    ${tc_id}
#    ${failed_number}    Get Total Failed UlDataPuschReceiveRespHarqU Message Number 1817    ${tc_id}
#    ${rate}    Evaluate    float(${failed_number})/(${total_number})
#    Log To Console    CRCNOK Rate in PuschReceiveRespHarqU is ${rate}
#    Should Be True    ${rate}<0.01
#
#Get Total UlDataPuschReceiveRespHarqU Message Number 1817
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    UlData_UePuschReceiveRespHarqU_t.crc    ["0", "1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Get Total Failed UlDataPuschReceiveRespHarqU Message Number 1817
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    UlData_UePuschReceiveRespHarqU_t.crc    ["1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}

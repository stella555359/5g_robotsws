*** Settings ***

*** Keywords ***
NSA UE attach and Send ULDL Traffic
    [Arguments]    ${UE_ID}    ${CELL_ID}
    NSA LTE Attach    ue_id=${UE_ID}    profile_id=1
    NSA 5G Attach    ue_id=${UE_ID}    gnb_id=2    cell_id=${CELL_ID}    bearer_id=2
    Start Gnb BIP Log
    Sleep    2s    reason=Wait for traffic stable
    NSA Start DL Traffic    ue_id=${UE_ID}    bearer_id=2    mbps=${dl_tp_set}    trf_id=1
    NSA Start UL Traffic    ue_id=${UE_ID}    bearer_id=2    mbps=${ul_tp_set}    trf_id=1
    Sleep    3s
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/1/

Delta_Commission and Setup Cells
    [Arguments]    ${Delta_Json}
    ${json_file}=    Change Delta XML File To Delta Json File    ${Delta_Json}
    Delta Commission With SCF File    ${json_file}
    Suite Setup Start WTS And Check OnAir

Get UCI bits in uldata_pucchreceiverespps
    [Arguments]    ${log_id}    ${uci_bits}
    ${filter}=    Set Variable    UlData_pucchReceiveReqPucchResource_t.numOfBitsOfUciInformation == ${uci_bits}
    @{csv_title_list}=    Create List       3gpp.sfn    3gpp.slot
    ...    UlData_pucchReceiveReqPucchResource_t.numOfBitsOfUciInformation    UlData_pucchReceiveReqPucchResource_t.nANPucch
    ${bip_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/BIP/${log_id}    5GBipL2L1_filtering_off*.pcap*    ${True}
    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
         Convert BIP To CSV By MCShark   ${name}    ${TEST_LOG_DIRECTORY}/BIP/${log_id}/uciMultiPucch.csv    ${filter}    ${csv_title_list}
    END

Check UCI bits right for Case A05 by A2A
    Log To Console    *********Begin to Get and Check UCI bits and CSI Report Period*********
    Get UCI bits in uldata_pucchreceiverespps    1    20
    A2A_Check_CSV_Table    ${CURDIR}/A2A/A05/UCIbits_A05.ini    ${TEST_LOG_DIRECTORY}/BIP/1/uciMultiPucch.csv    ${TEST_LOG_DIRECTORY}/BIP/1/

Check UCI bits right for Case A08 by A2A
    [Arguments]    ${log_id}
    Log To Console    *********Begin to Get and Check UCI bits and CSI Report Period*********
    Get UCI bits in uldata_pucchreceiverespps    ${log_id}    29
    A2A_Check_CSV_Table    ${CURDIR}/A2A/A08/UCIbits_A08.ini    ${TEST_LOG_DIRECTORY}/BIP/${log_id}/uciMultiPucch.csv
        ...    ${TEST_LOG_DIRECTORY}/BIP/${log_id}/

Collect TTITrace and check DTXCRC
    [Arguments]    ${log_id}    ${duration}
    Capture And Decode TTItrace    ${log_id}    ${duration}
    CUDU_L2 Check DTXNACK Rate    ${log_id}
    CUDU_L2 Check UL DTXCRC Rate    ${log_id}

Capture And Decode TTitrace
    [Arguments]    ${log_id}=1    ${duration}=3
    Log To Console     start ttitrace...
    Start Ttitrace With Streaming Mode
    Sleep    ${duration}s    reason=Wait for logs
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

Check SRS Slot When enable InfTddFrameMuting
    [Arguments]    ${log_id}
    ${bip_name}    Set Variable    ${TEST_LOG_DIRECTORY}/${log_id}/5GBipL2L1_filtering_off.pcap
    Convert BIP To CSV By MCShark    ${bip_name}    ${OUTPUT_DIR}/InfTddFrameMuting.csv    filter=uldata_srsreceivereq
    ...    csv_title_list=${COLUMN_NAME}
    Run    sed -i 's/"//g' ${OUTPUT_DIR}/InfTddFrameMuting.csv
    Sleep    3s    reason=Wait for csv stable
    A2A_Check_CSV_Table    ${CURDIR}/Resources/InfTddFrameMuting_slot.ini    ${OUTPUT_DIR}/InfTddFrameMuting.csv

Set UE Beamforming Profile And Activate
    ${CMD_BC_PRF_1}    Set Variable
    ...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ${CMD_BC_PRF_2}    Set Variable
    ...    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-70
    ${CMD_TESTMODE_ATTACH_1}    Set Variable
    ...    ue_testmode_set_nr id=12 testmode=beam_control action=activate profile_id=1 beamaction=attach
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_1}
    ute_wtssim.Execute Egate Command    cmd=${CMD_BC_PRF_2}
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_ATTACH_1}

UE Beamforming Switch
    [Arguments]    ${profile_id}    ${scell}
    Log To Console     ******start Beam change******
    ${CMD_TESTMODE_SWITCH}    Set Variable
    ...   ue_testmode_set_nr id=12 testmode=beam_control action=activate profile_id=${profile_id} beamaction=switch scell=${scell}
    Log To Console    ******Beam Control UE$1 Switch to Profile ${profile_id} ******
    ute_wtssim.Execute Egate Command    cmd=${CMD_TESTMODE_SWITCH}

Check PatternID From Wirshark
    [Arguments]    ${beamId}
    Log To Console     ******Check Beam ID after beam change******
    Convert BIP To CSV By MCShark For Pdcchsendreq    ${beamId}
    Check BeamID In Pdcchsendreq    ${beamId}

Convert BIP To CSV By MCShark For Pdcchsendreq
    [Arguments]    ${beamId}
    ${filter}=    Set Variable    dldata_pdcchsendreq && !(3gpp.rnti == 65535)
    @{csv_title_list}=    Create List    DlData_PdcchSendReq_t.beamId
    ${bip_names}    Set Variable    ${TEST_LOG_DIRECTORY}/BIP/2/5GBipL2L1_filtering_off.pcap*
    Convert BIP To CSV By MCShark   ${bip_names}    ${OUTPUT_DIR}/${beamId}_Pdcchsendreq.csv    ${filter}    ${csv_title_list}

Check BeamID In Pdcchsendreq
    [Arguments]    ${beamId}
    ${data_list_1}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/${beamId}_Pdcchsendreq.csv    DlData_PdcchSendReq_t.beamId    ["${beamId}"]    include    no
    ${count1}    Get Length    ${data_list_1}
    Should Be True    ${count1}!=0

Trigger Beam Change and Check After Beam Change
    Start Gnb BIP Log
    UE Beamforming Switch    2    8
    Sleep    3s
    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/2/
    NSA UE Check Throughput    12    50    10
    Collect TTITrace and check DTXCRC    2    5
    Check UCI bits right for Case A08 by A2A    2
    Check PatternID From Wirshark    2


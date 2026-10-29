*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    CRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     CONFIGURED

Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:     This user scenario describes behaviour of NBR congestion handling (PDSCH congestion)
...                               with multiple dedicated BWPs with power saving BWP feature.
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_21067


Resource       ../resources/ECEcommon/common_setup_teardown.robot
Resource         CB008227_Resource.robot
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=mBWP_NBR_scfc.xml
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces   ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report
#...                 AND     Run Keyword and Ignore Error   Stop Default Processes And Gather Logs And Compress Logs

#Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/mBWP_nbr_wts.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${IPHY_FILE}                    ${CURDIR}/config/mBWP_NBR_iphy.xml
${UE_ID}        1
${start_ue_id}    1
${end_ue_id}      4
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${QFI_ID2}    2
${QFI_ID3}    3
${QFI_ID4}    4
${QFI_ID5}    5
${TRF_ID2}    2
${Q_O_ADD2}    2
${Q_O_ADD3}    3
${Q_O_ADD4}    4
${Q_O_ADD5}    5
${epc_log_path}    /tmp/
${TEST_NAME}     E_B3_TC55
${largebwp_id}     1
${smallbwp_id}     2
${psbwp_id}        3
${CELL_ID}    1
${no_of_cells}   2

*** Test Cases ***
CB008227-E_B6_TC55_NBR_congestion_handling_with_multiBWPs_with_PowerSavingBWP
    [Documentation]   This user scenario describes behaviour of NBR congestion handling with multiple dedicated BWPs
    ...               with power saving BWP feature.
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts
    Start Log    btslog
    Attach Multi-UE and trigger nNBR/VoNR/NBR data
    Verify PSBWP through TTI trace
    Validate Throughput For UEs
    Stop Log   btslog
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
#Update counter values according to testing
    Verify Any Counters In File
    ...  M55139C03509  900  SA_DU_DRB_NBR_DL
    ...  M55300C12010  600  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    MultiUE Deregister should be Successful   1   4
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Attach Multi-UE and trigger nNBR/VoNR/NBR data
    Start Log    cprt
    log to console   UE attach trigerring now...
    #Multi UE registration and no rach validation
    ${crnti_list}       Create List
    FOR      ${ue_idx}   IN RANGE    ${1} 	  ${3}+1
    ${rnti}     UE Registered Successfully & Rach validation      ue_id=${ue_idx}
    Append To List    ${crnti_list}   ${rnti}
    END
    ${crnti}     UE Register should be Successful And Fetch RNTI    ue_id=4
    #PDU session modification for UE4
    NBR_QFI2   4
    Append To List    ${crnti_list}   ${crnti}
    set suite variable    ${crnti_list}
    Sleep    1s
    #UE1 MOVING FROM LARGE  BWP PROFILE TO POWER SAVING BWP PROFILE DUE TO LOW DATA
    MultiUE Trigger DL Traffic for SA    1   1    Traffic_rate=kbps    dl_rate=10    trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    MultiUE Trigger UL Traffic for SA    1   1    Traffic_rate=kbps    ul_rate=10    trf_id=${TRF_ID}    qfi_id=${QFI_ID}

    #UE2 MOVING FROM LARGE  BWP PROFILE TO SMALL BWP PROFILE
    MultiUE Trigger DL Traffic for SA    2   2    Traffic_rate=kbps    dl_rate=10    trf_id=${TRF_ID}    qfi_id=${QFI_ID4}
    MultiUE Trigger UL Traffic for SA    2   2    Traffic_rate=kbps    ul_rate=10    trf_id=${TRF_ID}    qfi_id=${QFI_ID4}
    MultiUE Trigger DL Traffic for SA    2   2    Traffic_rate=kbps    dl_rate=10   trf_id=${TRF_ID}    qfi_id=${QFI_ID5}
    MultiUE Trigger UL Traffic for SA    2   2    Traffic_rate=kbps    ul_rate=10    trf_id=${TRF_ID}    qfi_id=${QFI_ID5}

    #UE3 MOVING TO SBWP DUE TO HIGH DATA
    MultiUE Trigger DL Traffic for SA    3   3    Traffic_rate=mbps   dl_rate=50    trf_id=${TRF_ID}    qfi_id=${QFI_ID2}
    MultiUE Trigger UL Traffic for SA    3   3    Traffic_rate=mbps   ul_rate=50    trf_id=${TRF_ID}    qfi_id=${QFI_ID2}

    #UE4 MOVING TO LBWP
    MultiUE Trigger DL Traffic for SA    4   4    Traffic_rate=mbps     dl_rate=170     trf_id=${TRF_ID}    qfi_id=${QFI_ID2}
    MultiUE Trigger DL Traffic for SA    4   4    Traffic_rate=mbps     dl_rate=170     trf_id=${TRF_ID2}    qfi_id=${QFI_ID3}
    MultiUE Trigger UL Traffic for SA    4   4    Traffic_rate=mbps     ul_rate=100     trf_id=${TRF_ID}    qfi_id=${QFI_ID2}
    MultiUE Trigger UL Traffic for SA    4   4    Traffic_rate=mbps     ul_rate=100     trf_id=${TRF_ID2}    qfi_id=${QFI_ID3}
    sleep   5s    reason=Wait for successful BWP switch
    ${bwpid}    Create List     3    3    2    1
    Stop Log   cprt
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}

UE Registered Successfully & Rach validation
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    .*REGISTRATION COMPLETE.*    ${Timeout_SA}
    Create File	    ${OUTPUT_DIR}/regst.txt	    ${output}
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    BuiltIn.Log     ${crnti_string}
    Log to Console    --->.*REGISTRATION COMPLETE.*
    Initial Success Message for UE Register and Rere gister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    ${output}    wtsrunner.read_wtsemu_output_until_re   expected=Initial Context Setup Successful    timeout=240
    BuiltIn.Should Match Regexp     ${output}
    ...     bwp-Id\\s2.*\\n.*bwp-Common.*\\n.*\\n.*genericParameters.*\\n.*\\n.*\\n.*\\n.*\\n.*pdcch-ConfigCommon.*
    BuiltIn.Log                first_ue_register_is_ok
    Run Keyword if   ${ue_id}==2   VoNR_QFI   2
    Run Keyword if   ${ue_id}==3   NBR_QFI   3
    [Return]      ${crnti_string}

NBR_QFI
    [Arguments]    ${ue_id}
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=2   by=amf
    Sleep    1s

NBR_QFI2
    [Arguments]    ${ue_id}
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=2   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=3   by=amf

VoNR_QFI
    [Arguments]    ${ue_id}
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=2   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=3   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=4   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=5   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_del=2   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_del=3   by=amf

Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Verify PSBWP through TTI trace
    ${bwpid}    Create List     3    3    2    1
    Run keyword and continue on failure     Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    mBWP    ${crnti_list}
	...     ${bwpid}    ${Branch_22R1}

Validate Throughput For UEs
    Validate DL UL Throughput For UE   1   1   1   0.01   0.01
    Validate DL UL Throughput For UE   2   1   4   0.01   0.01
    Validate DL UL Throughput For UE   3   1   2   50   50
    Validate DL UL Throughput For UE   4   1   2   170   50
    Validate DL UL Throughput For UE   4   1   3   170   50


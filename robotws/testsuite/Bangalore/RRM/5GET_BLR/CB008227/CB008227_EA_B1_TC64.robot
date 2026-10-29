*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    CRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     CONFIGURED

Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:     This user scenario describes behaviour of NBR congestion handling with CB008954 (3 BWPs)
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   CB_FIM_45145


Resource       ../resources/ECEcommon/common_setup_teardown.robot
Resource         CB008227_Resource.robot
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=3bwp_tdd_scf.xml
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces    ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Stop Log   snapshot
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

#Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/3bwp_tdd_wts.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${IPHY_FILE}                    ${CURDIR}/config/3bwp_tdd_iphy.xml
${UE_ID}        1
${start_ue_id}    1
${end_ue_id}      3
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${QFI_ID2}    2
${QFI_ID3}    3
${epc_log_path}    /tmp/
${TEST_NAME}     EA_B1_TC64
${CELL_ID}    1
${no_of_cells}   1

*** Test Cases ***
CB008227-EA#B1_TC64_NBR_congestion_handling_IWK_with_CB008954_3BWP
    [Documentation]   This user scenario describes behaviour of NBR congestion handling with CB008954 (3 BWPs)
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts    
    Attach Multi-UE and trigger nNBR/NBR data
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    #Update counter values according to testing    
    Verify Any Counters In File
    ...  M55139C03509  1800  SA_DU_DRB_NBR_DL
    ...  M55300C12010  >1000  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  M55370C00041  >1000  ACC_DU_DRB_NBR_UL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    MultiUE Deregister should be Successful   ${start_ue_id} 	${end_ue_id}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Attach Multi-UE and trigger nNBR/NBR data
    Start Log    cprt
    log to console   UE attach trigerring now...
    ${crnti_list}       Create List
    FOR      ${ue_idx}   IN RANGE    ${start_ue_id} 	  ${end_ue_id}+${1}
    ${rnti}     UE Registered Successfully & Rach validation      ue_id=${ue_idx}
    Append To List    ${crnti_list}   ${rnti}
    MultiUE Trigger DL Traffic for SA    ${ue_idx}   ${ue_idx}    Traffic_rate=mbps     dl_rate=150     trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    Sleep    1s
    MultiUE Trigger UL Traffic for SA    ${ue_idx}   ${ue_idx}    Traffic_rate=mbps     ul_rate=100     trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    Sleep    1s
    MultiUE Trigger DL Traffic for SA    ${ue_idx}   ${ue_idx}    Traffic_rate=mbps     dl_rate=150     trf_id=${TRF_ID}    qfi_id=${QFI_ID2}
    Sleep    1s
    MultiUE Trigger UL Traffic for SA    ${ue_idx}   ${ue_idx}    Traffic_rate=mbps     ul_rate=100     trf_id=${TRF_ID}    qfi_id=${QFI_ID2}   
    Sleep    1s
    MultiUE Trigger DL Traffic for SA    ${ue_idx}   ${ue_idx}    Traffic_rate=mbps     dl_rate=150     trf_id=${TRF_ID}    qfi_id=${QFI_ID3}
    Sleep    1s
    MultiUE Trigger UL Traffic for SA    ${ue_idx}   ${ue_idx}    Traffic_rate=mbps     ul_rate=100     trf_id=${TRF_ID}    qfi_id=${QFI_ID3}
    Sleep    1s
    END
    set suite variable    ${crnti_list}
    Sleep    1s
    sleep   5s    reason=Wait for successful BWP switch
    ${bwpid}    Create List     2    1    3
    Stop Log   cprt
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    3BWP    ${crnti_list}
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
    ...     bwp-Id\\s1.*\\n.*bwp-Common.*\\n.*\\n.*genericParameters.*\\n.*\\n.*\\n.*\\n.*\\n.*pdcch-ConfigCommon.*
    BuiltIn.Log                first_ue_register_is_ok
    NBR_QFI   ${ue_id}
    [Return]      ${crnti_string}

NBR_QFI
    [Arguments]    ${ue_id}
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=2   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=3   by=amf      

Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Verify PSBWP through TTI trace
    ${bwpid}    Create List     2    1   3
    Run keyword and continue on failure     Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    mBWP    ${crnti_list}
	...     ${bwpid}    ${Branch_22R1}

Validate Throughput For UEs
    Validate DL UL Throughput For UE   1   1   1   35   25
    Validate DL UL Throughput For UE   1   1   2   35   23
    Validate DL UL Throughput For UE   1   1   3   35   25
    Validate DL UL Throughput For UE   2   1   1   33   22
    Validate DL UL Throughput For UE   2   1   2   32   25
    Validate DL UL Throughput For UE   2   1   3   31   25
    Validate DL UL Throughput For UE   3   1   1   32   25
    Validate DL UL Throughput For UE   3   1   2   31   25
    Validate DL UL Throughput For UE   3   1   3   29   25


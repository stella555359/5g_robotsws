*** Settings ***
Force Tags      CLOUD_5G_I_BOO_AP_LOO   
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED   

Resource         CB008227_Resource.robot
Resource         ../CB008285/CB008285_Resource.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     Suite setup from scratch
...                 AND     Configure UTE ETH3 IPs
...                 AND     Prepare TL with config files
...                 AND     Start Default Logging Gnb ASIL_ABIO     
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep   2s    

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO

Documentation
...
...             author:           Manasa
...             maintainer:       manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     This user scenario describes NBR interworking with A1 measurement of 
...                               P(S)Cell based SCell change for SA call - mixed mode CA (CB008015) 
...                               
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   xxxxx



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/TC47_basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${3}
${sa_ue_id2}      ${30}
${sa_ue_id3}      ${31}
${sa_ue_id4}      ${32}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC1
${CELL_ID}    1

${delta_file_name}=             Enable_NBR_TC47.json
${2CC_1T1F_SCELL}             ('1', '51', '66')
${2CC_1T1T_SCELL}             ('1', '55', '78')


*** Test Cases ***
[1]CB008227-E#B3_TC47_NBR_IWK_CB008015_A1_measurement_of_P(S)Cell_based_SCell_change_for_SA_call_mixed_mode_CA
    [Tags]     QC_xxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    Perform SCF Delta Commissioning with ${delta_file_name}
    X2AP Link Should be UP 
    Wait until the next Measurement Period starts
    log to console   "Multiple SA UE attach trigerring now"
#Step 1. Attach SA UE's
    Start Log    cprt
    MultiUE Register should be Successful    ${sa_ue_id1}     ${sa_ue_id1}
    sleep     2s
    Send A1 Measurement for Scell Addition   ${sa_ue_id1}    1     80    52
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    Run Keyword and Continue on Failure     MultiUE Trigger DL Traffic for SA  ${sa_ue_id1}    ${sa_ue_id1}   mbps   30
    Run Keyword and Continue on Failure     MultiUE Trigger UL Traffic for SA  ${sa_ue_id1}    ${sa_ue_id1}   mbps   30
    Start Log    cprt
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}   ${sa_ue_id1}    1    2
    sleep   2s
    ${path2}    Stop Log    cprt   test_scenario=bearersetup
    Run Keyword and Continue on Failure     MultiUE Trigger High DL Traffic for SA  ${sa_ue_id1}    ${sa_ue_id1}   30    1   2
    Run Keyword and Continue on Failure     MultiUE Trigger High UL Traffic for SA  ${sa_ue_id1}    ${sa_ue_id1}   30    1   2
    sleep   60s
    Get And Check Scell Infos    ${2CC_1T1F_SCELL}
    Validate UE stats for Scell Index    ${sa_ue_id1}   0   200
    Validate UE stats for Scell Index    ${sa_ue_id1}   1   70
    Validate DL Traffic For all UEs
    Validate UL Traffic For all UEs
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
#Update counter values according to testing
#    Verify Any Counters In File
#    ...  M55115C03506  4  NSA_DU_DRB_NBR_REQ
#    ...  M55300C12008  2  SA_DU_DRB_NBR_DL_FAIL_OVL
#    ...  M55370C00030  2  SA_DU_DRB_NBR_UL_FAIL_OVL
#    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
#    ...  file_path=${pm_counter_file}
#    Wait until the current Measurement Period stops
#    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter2
#    Verify Any Counters In File
#    ...  M55115C03509  600  NSA_DU_DRB_NBR_DL
#    ...  M55115C03510  600  NSA_DU_DRB_NBR_UL
#    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
#    ...  file_path=${pm_counter_file}
############# Initiate A1 measurement for Scell change from FDD to TDD     
    Send A1 Measurement for Scell Addition   ${sa_ue_id1}    1     100    52
    Get And Check Scell Infos    ${2CC_1T1T_SCELL}
    Validate UE Stats for Scell Index    ${sa_ue_id1}   0   120
    Validate UE Stats for Scell Index    ${sa_ue_id1}   2   120
    Validate DL Traffic For all UEs After Scell Change
    Validate UL Traffic For all UEs After Scell Change
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
#Update counter values according to testing    
#    Verify Any Counters In File
#    ...  M55115C03506  4  NSA_DU_DRB_NBR_REQ
#    ...  M55300C12008  2  SA_DU_DRB_NBR_DL_FAIL_OVL
#    ...  M55370C00030  2  SA_DU_DRB_NBR_UL_FAIL_OVL
#    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
#    ...  file_path=${pm_counter_file}
#    Wait until the current Measurement Period stops
#    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter2
#    Verify Any Counters In File
#    ...  M55115C03509  600  NSA_DU_DRB_NBR_DL
#    ...  M55115C03510  600  NSA_DU_DRB_NBR_UL
#    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
#    ...  file_path=${pm_counter_file}
    MultiUE Deregister should be Successful    ${sa_ue_id1}    ${sa_ue_id1}    

*** Keywords ***
Validate DL Traffic For all UEs
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id1}     dl_rate=30   pdu_id=1
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id1}     dl_rate=30   pdu_id=2


Validate UL Traffic For all UEs
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=30   pdu_id=1
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=30   pdu_id=2

Validate DL Traffic For all UEs After Scell Change
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id1}     dl_rate=30   pdu_id=1
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id1}     dl_rate=30   pdu_id=2


Validate UL Traffic For all UEs After Scell Change
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=30   pdu_id=1
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=30   pdu_id=2

Validate UE stats for Scell Index
    [Arguments]    ${ue_id}   ${scell_index}    ${tput}
    ${tput_scell_index}=    Get AVG DL DATA TRAFFIC For Given CC    ${ue_id}    ${scell_index}    
    should be equal   ${tput_scell_index_1}   ${tput}

Add new Bearer for Multiple SA UE
     [Arguments]    ${first_ue_id}    ${last_ue_id}    ${pdu_id}      ${qos_id}
     FOR   ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        UE PDU Modfication should be Successful   ${ue_id}      pdu_id=${pdu_id}      qosflows_to_add=${qos_id}
     END

MultiUE Trigger High DL Traffic for SA
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${dl_rate}    ${pdu_id}   ${qfi_id}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger High DL Traffic for SA with QFI ID   ${ue_id}     mbps     ${dl_rate}    ${pdu_id}   ${qfi_id}
    END

MultiUE Trigger High UL Traffic for SA
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${dl_rate}    ${pdu_id}   ${qfi_id}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger High UL Traffic for SA with QFI ID   ${ue_id}     mbps     ${dl_rate}    ${pdu_id}   ${qfi_id}
    END


Trigger High DL Traffic for SA with QFI ID
    [Arguments]    ${ue_id}     ${Traffic_rate}     ${dl_rate}    ${pdu_session_id}    ${qfi_id}
    [Documentation]    This keyword starts the DL Traffic for the SA variant for higher data rate
    ${dl_rate_loop}=      Evaluate      ${dl_rate}//175
    ${dl_rate_reminder}=     Evaluate      ${dl_rate}%175
    ${dl_rate_loop}=      Evaluate     ${dl_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${dl_rate_loop}
        Run Keyword if    ${loop}==0    Trigger DL Traffic for SA   ue_id=${sa_ue_id1}    Traffic_rate=${Traffic_rate}
        ...   dl_rate=${dl_rate_reminder}     pdu_id=${pdu_session_id}    trf_id=${TRF_ID}   qfi_id=${qfi_id}
        Run Keyword if    ${loop}>0     Trigger DL Traffic for SA   ue_id=${sa_ue_id1}    Traffic_rate=${Traffic_rate}
        ...   dl_rate=175     pdu_id=${pdu_session_id}    trf_id=${TRF_ID}    qfi_id=${qfi_id}
#        Run Keyword if    ${loop}==0    Log Many    ${dl_rate_reminder}   ${TRF_ID}     ${loop}
#        Run Keyword if    ${loop}>0     Log Many    ${175}   ${TRF_ID}     ${loop}
        ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END

Trigger High UL Traffic for SA with QFI ID
    [Arguments]    ${ue_id}     ${Traffic_rate}     ${ul_rate}    ${pdu_session_id}    ${qfi_id}
    [Documentation]    This keyword starts the UL Traffic for the SA variant for higher data rate
    ${ul_rate_loop}=      Evaluate      ${ul_rate}//175
    ${ul_rate_reminder}=     Evaluate      ${ul_rate}%175
    ${ul_rate_loop}=      Evaluate     ${ul_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${ul_rate_loop}
        Run Keyword if    ${loop}==0    Trigger UL Traffic for SA   ue_id=${sa_ue_id1}    Traffic_rate=${Traffic_rate}
        ...   ul_rate=${ul_rate_reminder}     pdu_id=${pdu_session_id}    trf_id=${TRF_ID}   qfi_id=${qfi_id}
        Run Keyword if    ${loop}>0     Trigger UL Traffic for SA   ue_id=${sa_ue_id1}    Traffic_rate=${Traffic_rate}
        ...   ul_rate=175     pdu_id=${pdu_session_id}    trf_id=${TRF_ID}   qfi_id=${qfi_id}
        ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END


Get And Check Scell Infos
    [Arguments]    ${scells_info}    ${egate_file}=/opt/iphy/latest/egate_console.log
    [Documentation]    This keyword is to get and check Scell Info from egate Log.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scells_info} | Yes |expected scell info with the format ('sCellIndex', 'physCellId', 'frequencyBandList') |
    ...    | ${egate_file | No | the egate Log path|
    ...    The keyword return a tuple list, then check whether it include above expected infos defined in ${scells_info}
    ...    Examples:
    ...    | Get And Check Scell Infos | ('1', '51', '2'), ('2', '52', '66')|
    ...
#    wtsrunner.sim_log_set    flush
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${regexp}    Catenate    SEPARATOR=    sCellIndex\\s+(?P<sCellIndex>\\d+),[\\s\\S]*?physCellId\\s(?P<physCellId>\\d+),
    ...    [\\s\\S]*?frequencyBandList\\s+{\\s+(?P<frequencyBandList>\\d+)\\s+},
    ${ret}    String.Get Regexp Matches    ${content}    ${regexp}    sCellIndex    physCellId    frequencyBandList
    ${ret_str}=    Convert To String    ${ret}
    ${ret}=    String.Replace String Using Regexp    ${ret_str}    u    ${EMPTY}
    Log to console    ${ret}
    Should Contain    ${ret}    ${scells_info}


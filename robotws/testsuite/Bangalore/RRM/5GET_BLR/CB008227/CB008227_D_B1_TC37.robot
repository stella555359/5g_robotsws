*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

Resource         CB008227_Resource.robot
Resource         ../CB008285/CB008285_Resource.robot
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     BuiltIn.Log     ${SCFC}
...                 AND     Prepare TL with config files
...                 AND     Suite setup from scratch
...                 AND     Configure UTE ETH3 IPs
...                 AND     Start Default Logging Gnb ASIL_ABIO
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep   2s

Suite Teardown      Run keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO

Documentation
...
...             author:           Madhukara M V
...             maintainer:       madhukara.m_v@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behavior related to NBR bearers
...                               congestion detection and congestion handling with both
...                               "PDSCH & PUSCH congeztion control" and congWeightAlg set to "arpPrioVul"
...
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20653
...             Testing method:   Enable congession detection and handling for PUSCH and PDSCH with "arpPrioVul" method
...                               1. Attach 1 SA UE with fqi 6 VONR(GBR) capabilty, add 3 more SA bearers with 5qi 7,8, and 9
...                               2. Add VONR(GBR) bearer with 5qi 5 and 1
...                               3. Set nbrdl=300 and nbrul=100 and maxnbrtrafficlimit=10 and maxnbrprbsperue=90%
...                               4. Attach 1 NSA nbr bearer with qci 9
...                               5. Verify that all the SA and NSA bearers are de prioritized and counters get pegged
...                               6. Verify no impact on GBR bearer is observed and  no call drop when nbr congession is detected
...                               7. Here nbr tput may not be achived as congession is detetected as they are de prioritized
...                               8. The validation of tput is not mandatory as it varying accroding to de/re-prio
...                               9. the tput verification is checked gbr bit rate of vonr bearer 2MBPS and other berers with > 2 MBPS


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/8227_ARP_basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${1}
${nsa_ue_id1}     101
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${QFI_ID1}     2
${QFI_ID2}     3
${QFI_ID3}     4
${QFI_ID4}     5
${QFI_ID5}     6
${UE_attach_pattern}                   reported successful RA
#${UE_attach_pattern}                   Bearer-type change from MCG to SCG-split is \nsuccessful
${timeout}    20

${TEST_NAME}     TC37
${CELL_ID}   1

${SCFC}=                        ${CURDIR}/config/8227_ARP_SCF.xml
${AP_XML}=                      ${CURDIR}/config/8227_ARP_iphy.xml



*** Test Cases ***
[1]CB008227-D#B1_TC37_NBR_congestion_detection_and_handling_Enable_combinations_of_congestion_control_pdsch_pusch_congcontrol_flag_arpPrio_SA_NSA
    [Tags]     QC_xxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    Wait until the next Measurement Period starts
    log to console   "SA UE attach with NBR Bearers are trigerring now"
#Step 1. Attach SA UE's with 1 default Bearer and 3 NBR Beareres and one VONR GBR bearer
    Link SCOUT SCF to Configuration ID for Reporting
    Start Log    cprt
#    Attach    ${nsa_ue_id1}
    UE Attach and ENDC should be Successful   ${nsa_ue_id1}  Trgt_Cell=1   Trgt_gNB4=2  Bearer_ID=2

    MultiUE Register should be Successful    ${sa_ue_id1}     ${sa_ue_id1}
    sleep     2s
#  ADd the VONR bearer and other 5QI bearers with 7,8 and 9
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID1}
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID2}
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID3}
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID4}
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID5}

# start trafiic on NSA UE
    sleep    5s
    Multiple NSA UE start and validate DL Traffic    ${nsa_ue_id1}  ${nsa_ue_id1}   dl_rate=100
    Multiple NSA UE start and validate UL Traffic    ${nsa_ue_id1}  ${nsa_ue_id1}   dl_rate=50
# start the DL and UL traffic on VONR bearer and other 5QIs
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=200   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=2   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID1}
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=2   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID2}
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=200   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID3}
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=200   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID4}
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=200   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID5}
    sleep   10s
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=100   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=2   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID1}
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=2   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID2}
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=100   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID3}
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=100   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID4}
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=100   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID5}
    sleep   10s
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
#Update counter values according to testing
    Verify Any Counters In File
    ...  M55139C03509  1200  SA_DU_DRB_NBR_DL
    ...  M55139C03510  1200  SA_DU_DRB_NBR_UL
    ...  M55115C03509  300  NSA_DU_DRB_NBR_DL
    ...  M55115C03510  300  NSA_DU_DRB_NBR_UL
    ...  M55300C12010   > 400  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  M55370C00041  1500  ACC_DU_DRB_NBR_UL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Validate DL Traffic For UEs diff QFI   197   2  2   197  197  197
    Validate UL Traffic For UEs diff QFI   37   2  2   31  37  33
# check the traffic on SA bearers and NSA and VONR .. this make sure that there is no call drop
    Validate DL Traffic For NSA with No Cap on Tput     ${nsa_ue_id1}     50
    Validate UL Traffic For NSA with No Cap on Tput     ${nsa_ue_id1}     49

    MultiUE Deregister should be Successful    ${sa_ue_id1}    ${sa_ue_id1}
    Multiple NSA UE Detach   ${nsa_ue_id1}  ${nsa_ue_id1}

*** Keywords ***
Validate DL Traffic For UEs diff QFI
    [Arguments]    ${de_qfi}   ${qfi1}   ${qfi2}   ${qfi3}   ${qfi4}  ${qfi5}
    Validate DL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     dl_rate=${de_qfi}   pdu_id=1    qfi_id=${QFI_ID}
    Validate DL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     dl_rate=${qfi1}   pdu_id=1    qfi_id=${QFI_ID1}
    Validate DL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     dl_rate=${qfi2}   pdu_id=1    qfi_id=${QFI_ID2}
    Validate DL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     dl_rate=${qfi3}   pdu_id=1    qfi_id=${QFI_ID3}
    Validate DL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     dl_rate=${qfi4}   pdu_id=1    qfi_id=${QFI_ID4}
    Validate DL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     dl_rate=${qfi5}   pdu_id=1    qfi_id=${QFI_ID5}

Validate UL Traffic For UEs diff QFI
    [Arguments]    ${qfi}   ${qfi1}   ${qfi2}   ${qfi3}   ${qfi4}  ${qfi5}
    Validate UL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     ul_rate=${qfi}   pdu_id=1    qfi_id=${QFI_ID}
    Validate UL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     ul_rate=${qfi1}   pdu_id=1    qfi_id=${QFI_ID1}
    Validate UL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     ul_rate=${qfi2}   pdu_id=1    qfi_id=${QFI_ID2}
    Validate UL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     ul_rate=${qfi3}   pdu_id=1    qfi_id=${QFI_ID3}
    Validate UL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     ul_rate=${qfi4}   pdu_id=1    qfi_id=${QFI_ID4}
    Validate UL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     ul_rate=${qfi5}   pdu_id=1    qfi_id=${QFI_ID5}

Add new Bearer for Multiple SA UE
     [Arguments]    ${first_ue_id}    ${last_ue_id}    ${pdu_id}      ${qos_id}
     FOR   ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        UE PDU Modfication should be Successful   ${ue_id}      pdu_id=${pdu_id}      qosflows_to_add=${qos_id}
        sleep   5s
     END

UE Attach and ENDC should be Successful  #NSA
    [Arguments]    ${NSA_UE_ID}  ${Trgt_Cell}   ${Trgt_gNB4}   ${Bearer_ID}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    LTE Attach should be Successful    ${nsa_ue_id1}
    sleep    10s
    wtsrunner.enb_ue_dc_start    target_gnb=${Trgt_gNB4}    target_cells=${Trgt_Cell}    ue=${NSA_UE_ID}
    ...  bearer=${Bearer_ID}    type=split_scg
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${timeout}
    [Return]      ${output}
Check Average Rate with No Cap on Tput
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}
    ${output}         Get Regexp Matches    ${bearer_stat}    Average data rate +(\\d+)    1
    ${result}         Evaluate    ( int(${output[0]}) > 2 )
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${output[0]}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${output[0]}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!
    log to console      ${mbps}

Validate DL Traffic For SA with no Cap on Tput
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${dl_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate with No Cap on Tput      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}
Validate UL Traffic For SA with no Cap on Tput
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${ue_id}     ${ul_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate with No Cap on Tput      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}
Validate UL Traffic For NSA with No Cap on Tput
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   id=${id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate with No Cap on Tput      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}
Validate DL Traffic For NSA with No Cap on Tput
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${dl_rate}     ${id}=${Bearer_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   id=${id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate with No Cap on Tput      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}


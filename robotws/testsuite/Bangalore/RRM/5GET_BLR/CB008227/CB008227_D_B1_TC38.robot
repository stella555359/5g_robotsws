*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

Resource         CB008227_Resource.robot
Resource         ../CB008285/CB008285_Resource.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     Suite setup from scratch
...                 AND     Configure UTE ETH3 IPs
...                 AND     Start Default Logging Gnb ASIL_ABIO
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep   2s

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO

Documentation
...
...             author:           Mundanad Vishnu
...             maintainer:       mundanad.vishnu@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behavior related to NBR bearers
...                               congestion detection and congestion handling with pdsch,pusch and prioritylevel
...                               SA and NSA
...
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   xxxxx



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/TC36_basic_setup.cfg
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

${delta_file_name}=             Enable_NBR_Congestion_TC36.json
#${SCFC}=                        ${CURDIR}/config/TC45_SCFC.xml
#${AP_XML}=                      ${CURDIR}/config/TC45_IPHY.xml



*** Test Cases ***
[1]CB008227-D#B1_TC36_NBR_congestion_detection_and_handling_with_pdsch_congestion_control_and_congWeightAlg_prioritylevel
    [Tags]     QC_xxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    Perform SCF Delta Commissioning with ${delta_file_name}
    X2AP Link Should be UP
    Wait until the next Measurement Period starts
    log to console   "Multiple SA UE attach trigerring now"
#Step 1. Attach SA UE's
    Start Log    cprt
    MultiUE Register should be Successful    ${sa_ue_id1}     ${sa_ue_id4}
    sleep     10s
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    Run Keyword and Continue on Failure     MultiUE Trigger DL Traffic for SA  ${sa_ue_id1}    ${sa_ue_id4}   mbps   30
    Run Keyword and Continue on Failure     MultiUE Trigger UL Traffic for SA  ${sa_ue_id1}    ${sa_ue_id4}   mbps   30
    Start Log    cprt
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}   ${sa_ue_id4}    2
    sleep   2s
    ${path2}    Stop Log    cprt   test_scenario=bearersetup
    Run Keyword and Continue on Failure     MultiUE Trigger DL Traffic for SA  ${sa_ue_id1}    ${sa_ue_id4}   mbps   30    pdu_id=2
    Run Keyword and Continue on Failure     MultiUE Trigger UL Traffic for SA  ${sa_ue_id1}    ${sa_ue_id4}   mbps   30    pdu_id=2
    sleep   60s
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
    MultiUE Deregister should be Successful    ${sa_ue_id1}    ${sa_ue_id4}

*** Keywords ***
Validate DL Traffic For all UEs
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id1}     dl_rate=30   pdu_id=1
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id2}     dl_rate=30   pdu_id=1
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id1}     dl_rate=30   pdu_id=2
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id2}     dl_rate=30   pdu_id=2


Validate UL Traffic For all UEs
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=30   pdu_id=1
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id2}     ul_rate=30   pdu_id=1
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=30   pdu_id=2
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id2}     ul_rate=30   pdu_id=3


Add new Bearer for Multiple SA UE
     [Arguments]    ${first_ue_id}    ${last_ue_id}    ${pdu_id}
     FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        UE PDU Addition should be Successful   ${ue_id}     ${pdu_id}     ${nwslice_ID}    ${gw_ID}
     END


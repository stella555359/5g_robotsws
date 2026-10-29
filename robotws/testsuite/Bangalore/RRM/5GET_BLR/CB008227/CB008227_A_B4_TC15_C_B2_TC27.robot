*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO   SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ
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
...             author:           Manasa
...             maintainer:       manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behaviour for the successful setup of
...                               Non GBR bearer with configured DL/UL Nominal Bit Rate in DRB profile which
...                               is triggered by SgNB Modification (E-RABs To Be Added) procedure.
...
...                               This user scenario describes the gNB behaviour for Admission
...                               control of NBR Non GBR DRB when NBR bearers Exceed Cell’s
...                               NBR max amount Limitation for NSA SgNB Modification
...                               (E-RABs To Be Added) procedure.
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   xxxxx



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/TC15_TC27_basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${nsa_ue_id1}      ${101}
${nsa_ue_id2}      ${102}
${nsa_ue_id3}      ${103}
${nsa_ue_id4}      ${104}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC1
${CELL_ID}    1

${delta_file_name}    Enable_NBR_TC15_TC27.json


*** Test Cases ***
[1]CB008227-A#B4_TC15_Support_NBR_nonGBR_bearers_setup_with_SgNB_Modification_NSA_both_UL_DL
    [Tags]     QC_xxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    Perform SCF Delta Commissioning with ${delta_file_name}
    X2AP Link Should be UP
    Enable ENDC for all Bearer
    Wait until the next Measurement Period starts
    log to console   "NSA UE attach trigerring now"
#Step 1. Attach NSA UE's
    Start Log    cprt
    Multiple NSA UE Register    ${nsa_ue_id1}     ${nsa_ue_id4}
    sleep     10s
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    Run Keyword and Continue on Failure    Multiple NSA UE start DL Traffic   ${nsa_ue_id1}    ${nsa_ue_id2}   100
    Start Log    cprt
    Add new LTE Bearer for Multiple UE    ${nsa_ue_id1}   ${nsa_ue_id2}    7     7
    sleep   2s
    ${path2}    Stop Log    cprt   test_scenario=bearersetup
    Run Keyword and Continue on Failure    Multiple NSA UE Start DL Traffic for new Bearer    ${nsa_ue_id1}    ${nsa_ue_id2}   7    500
    sleep   60s
    Validate DL Traffic For all UEs
    Stop Data Traffic for NSA    ${nsa_ue_id1}
    Stop Data Traffic for NSA    ${nsa_ue_id2}
    sleep   5s
    Run Keyword and Continue on Failure    Multiple NSA UE start UL Traffic   ${nsa_ue_id1}    ${nsa_ue_id2}   50
    Run Keyword and Continue on Failure    Multiple NSA UE Start UL Traffic for new Bearer    ${nsa_ue_id1}    ${nsa_ue_id2}   7    80
    sleep   60s
    Validate UL Traffic For all UEs
    Stop Data Traffic for NSA    ${nsa_ue_id1}
    Stop Data Traffic for NSA    ${nsa_ue_id2}
    Run Keyword and Continue on Failure    Multiple NSA UE start DL Traffic   ${nsa_ue_id1}    ${nsa_ue_id4}   10
    Run Keyword and Continue on Failure    Multiple NSA UE start UL Traffic   ${nsa_ue_id1}    ${nsa_ue_id4}   10
    Add new LTE Bearer for Multiple UE    ${nsa_ue_id3}   ${nsa_ue_id4}    7     7
    Run Keyword and Continue on Failure    Multiple NSA UE Start DL Traffic for new Bearer    ${nsa_ue_id1}    ${nsa_ue_id4}   7    10
    Run Keyword and Continue on Failure    Multiple NSA UE Start UL Traffic for new Bearer    ${nsa_ue_id1}    ${nsa_ue_id4}   7    10
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55115C03506  4  NSA_DU_DRB_NBR_REQ
    ...  M55115C03507  2  NSA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  M55115C03508  2  NSA_DU_DRB_NBR_ADMIT_NOT_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter2
    Verify Any Counters In File
    ...  M55115C03509  600  NSA_DU_DRB_NBR_DL
    ...  M55115C03510  600  NSA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Multiple NSA UE Detach    ${nsa_ue_id1}    ${nsa_ue_id4}
    [Teardown]  Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Enable ENDC for all Bearer
     wtsrunner.enb_param   id=1   endc_capable_qci=all

Multiple NSA UE Start DL Traffic for new Bearer
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${bearer_id}   ${dl_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger High DL Traffic for NSA   ue_id=${ue_id}     Traffic_rate=Mbps     dl_rate=${dl_rate}       bearer_id=${bearer_id}
    END

Multiple NSA UE Start UL Traffic for new Bearer
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${bearer_id}   ${ul_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger High UL Traffic for NSA   ue_id=${ue_id}     Traffic_rate=Mbps     ul_rate=${ul_rate}      bearer_id=${bearer_id}
    END

Validate DL Traffic For all UEs
    Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${nsa_ue_id1}     dl_rate=83   id=2
    Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${nsa_ue_id2}     dl_rate=82   id=2
    Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${nsa_ue_id1}     dl_rate=323   id=7
    Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${nsa_ue_id2}     dl_rate=323   id=7


Validate UL Traffic For all UEs
    Run Keyword and continue on Failure   Validate UL Traffic For NSA   ue_id=${nsa_ue_id1}     ul_rate=50   id=2
    Run Keyword and continue on Failure   Validate UL Traffic For NSA   ue_id=${nsa_ue_id2}     ul_rate=50   id=2
    Run Keyword and continue on Failure   Validate UL Traffic For NSA   ue_id=${nsa_ue_id1}     ul_rate=65   id=7
    Run Keyword and continue on Failure   Validate UL Traffic For NSA   ue_id=${nsa_ue_id2}     ul_rate=65   id=7


Add new LTE Bearer for Multiple UE
     [Arguments]    ${first_ue_id}    ${last_ue_id}    ${bearer_id}   ${precedence}
     FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        Add new LTE Bearer   ${ue_id}    ${bearer_id}   ${precedence}
        ENDC Modify for Bearer Addition   ${ue_id}    ${bearer_id}
     END


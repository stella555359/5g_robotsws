*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED   

Resource         CB008227_Resource.robot
Resource         ../CB008285/CB008285_Resource.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     BuiltIn.Log     ${SCFC}
...                 AND     Prepare TL with config files
...                 AND     Suite setup from scratch
...                 AND     Start Default Logging Gnb ASIL_ABIO     
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO

Documentation
...
...             author:           Manasa
...             maintainer:       manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behaviour for Admission
...                               control of NBR Non GBR DRB when NBR bearers Exceed Cell’s 
...                               NBR max amount Limitation for NSA SgNB Modification 
...                               (E-RABs To Be Added) procedure.
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   xxxxx



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${nsa_ue_id1}      ${1}
${nsa_ue_id2}      ${2}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC1

${SCFC}=                   ${CURDIR}/
${AP_XML}=                 ${CURDIR}/
${delta_file_name}=        ${CURDIR}/
${delta_file_name1}=        ${CURDIR}/

*** Test Cases ***
CB008227-C#B2_TC27_Support_NBR_nonGBR_bearers_setup_with_SgNB_Modification_NSA
    [Tags]     QC_xxxx
    set test variable      ${LOG_PATH}
#Perform Delta changes with maxNumOfNbrBearers set to "0"    
    Perform SCF Delta Commissioning with ${delta_file_name}
    X2AP Link Should be UP
    Enable ENDC for all Bearer
    Wait until the next Measurement Period starts
    log to console   "NSA UE attach trigerring now"
#Step 1. Attach NSA UE-1 on cell-11 and Start Data Traffic
    Multiple NSA UE Register    ${nsa_ue_id1}     ${nsa_ue_id2}
    sleep     30s
    Multiple NSA UE start and validate DL Traffic   ${nsa_ue_id1}    ${nsa_ue_id2}   2
    Multiple NSA UE start and validate UL Traffic   ${nsa_ue_id1}    ${nsa_ue_id2}   2
    Add new LTE Bearer   ${nsa_ue_id1}    7     7
    ENDC Modify for Bearer Addition   ${nsa_ue_id1}    7
    Start and Validate DL Traffic for new Bearer    ${nsa_ue_id1}    7    2
    Start and Validate UL Traffic for new Bearer    ${nsa_ue_id1}    7    2
    Wait until the current Measurement Period stops
    Collect PM Counter
##    Validate PM Counter   ### This keyword needs to be written yet based on . Below counters should incremeant
##   Number of non-GBR bearers with configured NBR admission requests for SA (SA_DU_DRB_NBR_REQ)
##   Number of Non-GBR bearers with configured NBR successfully admitted with applying NBR during RAC for SA (SA_DU_DRB_NBR_ADMIT_WITH_NBR)
##   Number of non-GBR bearers with configured NBR admitted without applying NBR during RAC for SA (SA_DU_DRB_NBR_ADMIT_NOT_NBR)
##   Cumulative number of non-GBR bearers with configured NBR in DL for SA (SA_DU_DRB_NBR_DL)
##   Cumulative number of non-GBR bearers with configured NBR in UL for SA (SA_DU_DRB_NBR_UL)
    Multiple NSA UE Detach    ${nsa_ue_id1}    ${nsa_ue_id2}
## Set maxNumOfNbrBearers to 1
    Perform SCF Delta Commissioning with ${delta_file_name1}
    Wait until the next Measurement Period starts
    log to console   "NSA UE attach trigerring now"
#Step 1. Attach NSA UE-1 on cell-11 and Start Data Traffic
    Multiple NSA UE Register    ${nsa_ue_id1}     ${nsa_ue_id2}
    sleep     30s
    Multiple NSA UE start and validate DL Traffic   ${nsa_ue_id1}    ${nsa_ue_id2}   2
    Multiple NSA UE start and validate UL Traffic   ${nsa_ue_id1}    ${nsa_ue_id2}   2
    Wait until the current Measurement Period stops
    Collect PM Counter
##    Validate PM Counter   ### This keyword needs to be written yet based on . Below counters should incremeant
##Since maxNumOfNbrBearers is "1", Only 1 UE is NBR admitted, hence below counters would be updated.
##  Number of non-GBR bearers with configured NBR admission requests for SA (SA_DU_DRB_NBR_REQ)
##  Number of Non-GBR bearers with configured NBR successfully admitted with applying NBR during RAC for SA (SA_DU_DRB_NBR_ADMIT_WITH_NBR)
##  Cumulative number of non-GBR bearers with configured NBR in DL for SA (SA_DU_DRB_NBR_DL)
##  Cumulative number of non-GBR bearers with configured NBR in UL for SA (SA_DU_DRB_NBR_UL)
##
##  No counter increament for Number of non-GBR bearers with configured NBR admitted without applying NBR during RAC for SA
##  (SA_DU_DRB_NBR_ADMIT_NOT_NBR)
##
##  Average number of NBR DRB calculations:
##
##     SA Average number of non-GBR bearers with configured NBR in DL is calculated by the formula SA_DU_DRB_NBR_DL/SA_DRB_NBR_DENOM
##     SA Average number of non-GBR bearers with configured NBR in UL is calculated by the formula SA_DU_DRB_NBR_UL/SA_DRB_NBR_DENOM
    Wait until the next Measurement Period starts
    Add new LTE Bearer   ${nsa_ue_id1}    7     7
    ENDC Modify for Bearer Addition   ${nsa_ue_id1}    7
    Start and Validate DL Traffic for new Bearer    ${nsa_ue_id1}    7    2
    Start and Validate UL Traffic for new Bearer    ${nsa_ue_id1}    7    2
    Wait until the current Measurement Period stops
    Collect PM Counter
##    Validate PM Counter   ### This keyword needs to be written yet based on . Below counters should incremeant
##UE-2 NBR configuration will be ignored, since maxNumOfNbrBearers is "1". Hence UE-2 will be admitted as normal NON-GBR Bearer.
## Number of non-GBR bearers with configured NBR admitted without applying NBR during RAC for SA (SA_DU_DRB_NBR_ADMIT_NOT_NBR)
## Number of non-GBR bearers with configured NBR admission requests for SA (SA_DU_DRB_NBR_REQ)
    Multiple NSA UE Detach    ${nsa_ue_id1}    ${nsa_ue_id2}

*** Keywords ***
Enable ENDC for all Bearer
     wtsrunner.enb_param   id=1   endc_capable_qci=all

Start and Validate DL Traffic for new Bearer
    [Arguments]    ${ue_id}    ${bearer_id}   ${dl_rate}
    Trigger DL Traffic for NSA   ${ue_id}=${ue_id}     ${Traffic_rate}="Mbps"     ${dl_rate}=${dl_rate}       ${id}=${bearer_id}
    Validate DL Traffic For NSA   ${ue_id}=${ue_id}    ${dl_rate}=${dl_rate}    ${id}=${bearer_id}

Start and Validate UL Traffic for new Bearer
    [Arguments]    ${ue_id}    ${bearer_id}   ${dl_rate}
    Trigger UL Traffic for NSA   ${ue_id}=${ue_id}     ${Traffic_rate}="Mbps"     ${dl_rate}=${dl_rate}       ${id}=${bearer_id}
    Validate UL Traffic For NSA   ${ue_id}=${ue_id}    ${dl_rate}=${dl_rate}    ${id}=${bearer_id}


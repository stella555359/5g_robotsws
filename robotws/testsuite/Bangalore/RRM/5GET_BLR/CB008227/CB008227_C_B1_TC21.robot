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
...                               control of NBR Non GBR DRB when NBR bearers Exceed Cell’s NBR 
...                               max amount Limitation for SA call FR1
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
CB008227-C#B1_TC21_NBR_bearers_Exceed_Cells_NBR_max_amount_Limitation_SA
    [Tags]     QC_xxxx
    set test variable      ${LOG_PATH}
    Perform SCF Delta Commissioning with ${delta_file_name}
    X2AP Link Should be UP 
    Wait until the next Measurement Period starts
    log to console   "SA UE attach trigerring now"
#Step 1. Attach SA UE-1 and UE-2 on cell-1 and Start Data Traffic
    MultiUE Register should be Successful    ${sa_ue_id1}    ${sa_ue_id2}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id2}   Traffic_rate=mbps     dl_rate=30
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id2}   Traffic_rate=mbps     ul_rate=30
    sleep     30s
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id2}   dl_rate=30
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id2}   ul_rate=30
    Wait until the current Measurement Period stops
    Collect PM Counter
##    Validate PM Counter   ### This keyword needs to be written yet based on . Below counters should incremeant
## 	 Number of non-GBR bearers with configured NBR admission requests for SA (SA_DU_DRB_NBR_REQ)
##	 Number of Non-GBR bearers with configured NBR successfully admitted with applying NBR during RAC for SA (SA_DU_DRB_NBR_ADMIT_WITH_NBR)
##	 Number of non-GBR bearers with configured NBR admitted without applying NBR during RAC for SA (SA_DU_DRB_NBR_ADMIT_NOT_NBR)
##	 Cumulative number of non-GBR bearers with configured NBR in DL for SA (SA_DU_DRB_NBR_DL)
##	 Cumulative number of non-GBR bearers with configured NBR in UL for SA (SA_DU_DRB_NBR_UL)
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id2}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id2}
## Set maxNumOfNbrBearers to 1
    Perform SCF Delta Commissioning with ${delta_file_name1}
## Attach UE-1
    MultiUE Register should be Successful    ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=30
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=mbps     ul_rate=30
    sleep     30s
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=30
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   ul_rate=30
    Wait until the current Measurement Period stops
    Collect PM Counter    
##    Validate PM Counter   ### This keyword needs to be written yet based on . Below counters should incremeant
##Since maxNumOfNbrBearers is "1", Only 1 UE is NBR admitted, hence below counters would be updated.
##	Number of non-GBR bearers with configured NBR admission requests for SA (SA_DU_DRB_NBR_REQ)
##	Number of Non-GBR bearers with configured NBR successfully admitted with applying NBR during RAC for SA (SA_DU_DRB_NBR_ADMIT_WITH_NBR)
##	Cumulative number of non-GBR bearers with configured NBR in DL for SA (SA_DU_DRB_NBR_DL)
##	Cumulative number of non-GBR bearers with configured NBR in UL for SA (SA_DU_DRB_NBR_UL)
##	
##	No counter increament for Number of non-GBR bearers with configured NBR admitted without applying NBR during RAC for SA 
##  (SA_DU_DRB_NBR_ADMIT_NOT_NBR)
##	
##	Average number of NBR DRB calculations:
##
##     SA Average number of non-GBR bearers with configured NBR in DL is calculated by the formula SA_DU_DRB_NBR_DL/SA_DRB_NBR_DENOM
##     SA Average number of non-GBR bearers with configured NBR in UL is calculated by the formula SA_DU_DRB_NBR_UL/SA_DRB_NBR_DENOM    
###  Attach UE-2
    MultiUE Register should be Successful    ${sa_ue_id2}    ${sa_ue_idr2}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id2}    ${sa_ue_id2}   Traffic_rate=mbps     dl_rate=30
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id2}    ${sa_ue_id2}   Traffic_rate=mbps     ul_rate=30
    sleep     30s
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id2}    ${sa_ue_id2}   dl_rate=30
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id2}    ${sa_ue_id2}   ul_rate=30
    Wait until the current Measurement Period stops
    Collect PM Counter
##    Validate PM Counter   ### This keyword needs to be written yet based on . Below counters should incremeant
##UE-2 NBR configuration will be ignored, since maxNumOfNbrBearers is "1". Hence UE-2 will be admitted as normal NON-GBR Bearer.
## Number of non-GBR bearers with configured NBR admitted without applying NBR during RAC for SA (SA_DU_DRB_NBR_ADMIT_NOT_NBR)
## Number of non-GBR bearers with configured NBR admission requests for SA (SA_DU_DRB_NBR_REQ)
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id2}

*** Keywords ***


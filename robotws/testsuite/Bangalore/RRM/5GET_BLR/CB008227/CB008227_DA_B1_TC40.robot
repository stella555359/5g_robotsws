*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behavior related to NBR bearers congestion
...                                detection and PDCCH DL congestion handling with PriorityLevel (online)
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20653



Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         CB008227_Resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=CB008227_DA_FR1_TDD_PDCCH_scf.xml
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Stop Log   snapshot
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts_DA_PDCCH_AEHC.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${sa_ue_id1}      ${1}
${sa_ue_id2}      ${2}
${sa_ue_id3}      ${3}
${sa_ue_id4}      ${4}
${nsa_ue_id1}      ${11}
${nsa_ue_id2}      ${12}
${nsa_ue_id3}      ${13}
${nsa_ue_id4}      ${14}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${CELL_ID}    1
${epc_log_path}    /tmp/
${TEST_NAME}        DA_B1_TC40
${IPHY_FILE}                    ${CURDIR}/config/iphy_AEHC.xml
${Enable_congweight_json}    Enable_congweight.json
${Disable_congweightjson}    Disable_congweight.json
${no_of_cells}    2

*** Test Cases ***

CB008227-DA#B1_TC40_NBR congestion detection and handling with PDCCH DL only SANSA
    [Documentation]   This user scenario describes the gNB behavior related to NBR bearers
    ...               congestion detection and PDCCH DL congestion handling with PriorityLevel
   log to console   UE attach trigerring now...
   X2AP Link Should be UP
   log to console   Wait for next PM to starts
   Wait until the next Measurement Period starts
   Start Log    btslog   cprt
   Attach multiple SA UEs with two NBR bearer traffic    ${sa_ue_id1}    ${sa_ue_id2}
   Perform SCF Delta Commissioning with ${Enable_congweight_json}
   Attach multiple SA UEs with two NBR bearer traffic    ${sa_ue_id3}    ${sa_ue_id4}
   Stop Log    cprt
   sleep   10s
   #Validate SA UEs Throughput
   log to console   Wait for next PM to stop
   Wait until the current Measurement Period stops
   ${pm_counter_file1}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/SA_PDCCH_Cong
   Verify Any Counters In File
    ...  M55139C03509  2400  SA_DU_DRB_NBR_DL
    ...  M55300C12010  > 800  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  M55370C00041  > 1500  ACC_DU_DRB_NBR_UL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file1}
   MultiUE Deregister should be Successful    ${sa_ue_id1}    ${sa_ue_id4}
   Stop Log    btslog
   Perform SCF Delta Commissioning with ${Disable_congweightjson}
   log to console   Wait for next PM stats
   Wait until the next Measurement Period starts
   Start Log    btslog   cprt
   X2AP Link Should be UP
   Multiple NSA UEs Register with NBR traffic   ${nsa_ue_id1}    ${nsa_ue_id2}
   Perform SCF Delta Commissioning with ${Enable_congweight_json}
   Multiple NSA UEs Register with NBR traffic   ${nsa_ue_id3}    ${nsa_ue_id4}
   Stop Log    cprt
   log to console   Wait for next PM to stop
   Wait until the current Measurement Period stops
   ${pm_counter_file2}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/NSA_PDCCH_Cong
   Verify Any Counters In File
    ...  M55115C03509  2400  NSA_DU_DRB_NBR_DL
    ...  M55300C12010  > 100  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  M55370C00041  > 1500  ACC_DU_DRB_NBR_UL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file2}
    Multiple NSA UE Detach   ${nsa_ue_id1}    ${nsa_ue_id4}
    Stop Log    btslog
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Attach multiple SA UEs with two NBR bearer traffic
    [Arguments]    ${ue_id1}    ${ue_id2}
    log to console   UE attach trigerring now...
    FOR      ${ue_idx}   IN RANGE    ${ue_id1} 	  ${ue_id2}+1
        UE Register should be Success      ue_id=${ue_idx}
        sleep   1s
        NBR_QFI2_3    ${ue_idx}
        sleep   1s
        QFI_2_3 traffic   ${ue_idx}
    END

NBR_QFI2_3
    [Arguments]    ${ue_id}
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=2   by=amf
    Sleep    1s
    wtsrunner.ue_pdu_session_modify   ue=${ue_id}   pdu=${Pdu_session_ID}  qosflows_to_add=3   by=amf

Validate SA UEs Throughput
    FOR      ${ue_idx}   IN RANGE    ${sa_ue_id1} 	  ${sa_ue_id2}+1
        QFI2_3_traffic_validation   ${ue_idx}
    END

QFI2_3_traffic_validation
   [Arguments]    ${ue_id}
   FOR    ${qfi}   IN RANGE   1   3+${1}
       ${dl}=   set variable if    ${qfi} > 1   40   30
       Validate DL UL Throughput For UE    ${ue_id}   1   ${qfi}   ${dl}   30
   END

QFI_2_3 traffic
    [Arguments]    ${ue_id}
    FOR    ${qfi}   IN RANGE   1   3+${1}
        MultiUE Trigger DL Traffic for SA   ${ue_id}  ${ue_id}  Traffic_rate=Mbps  dl_rate=150  trf_id=${TRF_ID}  qfi_id=${qfi}
        MultiUE Trigger UL Traffic for SA   ${ue_id}  ${ue_id}  Traffic_rate=Mbps  ul_rate=50  trf_id=${TRF_ID}  qfi_id=${qfi}
    END

Multiple NSA UEs Register with NBR traffic
    [Arguments]    ${ue_id1}    ${ue_id2}
    Multiple NSA UE Register    ${ue_id1} 	  ${ue_id2}
    FOR    ${ue_idx}   IN RANGE    ${ue_id1} 	  ${ue_id2}+1
        LTE_QCI3_4   ${ue_idx}
        sleep   5s
        Trigger DL & UL Traffic   ${ue_idx}
    END

LTE_QCI3_4
    [Arguments]    ${ue_id}
    FOR   ${qci}   IN RANGE   3   4+${1}
        wtsrunner.bearer_add    ue=${ue_id}   id=${qci}  filter=0  precedence=${qci}
        sleep   1s
        wtsrunner.enb_ue_dc_modify   ue=${ue_id}   bearer_to_add=${qci}   by=enb   cause=RN_CauseRadioNetwork_unspecified
        sleep   1s
    END

Trigger DL & UL Traffic
    [Arguments]    ${ue_id}
    FOR   ${qci}   IN RANGE   2   4+${1}
        Trigger DL Traffic for NSA   ${ue_id}   mbps   150    ${qci}
        sleep   2s
        Trigger UL Traffic for NSA   ${ue_id}   mbps   50    ${qci}
    END

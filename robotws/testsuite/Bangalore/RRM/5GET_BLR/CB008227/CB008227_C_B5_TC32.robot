*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO   VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED   

Resource         CB008227_Resource.robot
Resource         ../CB008285/CB008285_Resource.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     Suite setup from scratch
...                 AND     Configure UTE ETH3 IPs
...                 AND     Start Default Logging Gnb ASIL_ABIO     
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO

Documentation
...
...             author:           Manasa
...             maintainer:       manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behaviour for Admission control
...                               of NBR Non GBR DRB when NBR bearers Exceed Cell’s NBR max amount 
...                               Limitation for Intra-DU PSCell change procedure (NSA)
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   xxxxx



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/TC32_basic_setup.cfg
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

${delta_file_name}=        TC32_Enable_NBR_maxNumOfNbrBearers_0.json
${delta_file_name1}=       TC32_maxNumOfNbrBearers_2.json

${LTE_cell_id1}    1
${LTE_cell_id2}    2
${LTE_INTRA_HO_egate_message}    Intra-eNB handover from ENB-1.1 to ENB-1.2 perfo\nrmed
${CELL_ID}    1
${nbr_dl_value}    400
${nbr_ul_value}    80

*** Test Cases ***
[1]CB008227-C#B5_TC32_Support_NBR_nonGBR_bearers_for_Intra-DU_PSCell_change_procedure_NSA
    [Tags]     QC_xxxx
    set test variable      ${LOG_PATH}
#Perform Delta changes with maxNumOfNbrBearers set to "0"    
    Perform SCF Delta Commissioning with ${delta_file_name}
    X2AP Link Should be UP
    Enable ENDC for LTE cell    ${LTE_cell_id1}
    Enable ENDC for LTE cell    ${LTE_cell_id2}
    Wait until the next Measurement Period starts
    log to console   "NSA UE attach trigerring now"
#Step 1. Attach NSA UE's
    Multiple NSA UE Register    ${nsa_ue_id1}     ${nsa_ue_id4}
    sleep     2s
    Add new LTE Bearer for Multiple UE    ${nsa_ue_id1}   ${nsa_ue_id4}    7     7
    Multiple NSA UE start DL Traffic   ${nsa_ue_id1}    ${nsa_ue_id4}   10
    Multiple NSA UE start UL Traffic   ${nsa_ue_id1}    ${nsa_ue_id4}   10
    Multiple NSA UE Start DL Traffic for new Bearer    ${nsa_ue_id1}    ${nsa_ue_id4}   7    10
    Multiple NSA UE Start UL Traffic for new Bearer    ${nsa_ue_id1}    ${nsa_ue_id4}   7    10
    sleep    60s
    Validate DL UL Traffic For all UEs
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55115C03506  4  NSA_DU_DRB_NBR_REQ
    ...  M55115C03507  4  NSA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  M55115C03508  0  NSA_DU_DRB_NBR_ADMIT_NOT_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}    
    Wait until the next Measurement Period starts
    Start Log    cprt
    Perform Intra LTE HO    ${nsa_ue_id1}    ${LTE_cell_id2}
    ${path1}    Stop Log    cprt   test_scenario=LTE_INTRA_HO_max_nbr_bearer_0
##  Validate CPRT logs for UE context modification with NBR IE for sgnb modification for Inter MeNB INTRA cell HO
    Verify nbrDrbSpecificParams In usersetupreq with nbrdl and nbrul   ${path1}[cprt]/NODECPRT_GNB.pcap   sctp     ${nbr_dl_value}    ${nbr_ul_value}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter2
    Verify Any Counters In File
    ...  M55115C03509  1200  NSA_DU_DRB_NBR_DL
    ...  M55115C03510  1200  NSA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Multiple NSA UE Detach    ${nsa_ue_id1}    ${nsa_ue_id4}
## Set maxNumOfNbrBearers to 2
    Perform SCF Delta Commissioning with ${delta_file_name1}
    Wait until the next Measurement Period starts
    log to console   "NSA UE attach trigerring now"
#Step 1. Attach NSA UE's
    Change UE location    ${nsa_ue_id1}   ${1}    ${LTE_cell_id1}
    Multiple NSA UE Register    ${nsa_ue_id1}     ${nsa_ue_id4}
    sleep     2s
    Add new LTE Bearer for Multiple UE    ${nsa_ue_id1}   ${nsa_ue_id4}    7     7
    Multiple NSA UE start DL Traffic   ${nsa_ue_id1}    ${nsa_ue_id4}   10
    Multiple NSA UE start UL Traffic   ${nsa_ue_id1}    ${nsa_ue_id4}   10
    Multiple NSA UE Start DL Traffic for new Bearer    ${nsa_ue_id1}    ${nsa_ue_id4}   7    10
    Multiple NSA UE Start UL Traffic for new Bearer    ${nsa_ue_id1}    ${nsa_ue_id4}   7    10
    sleep    60s
    Validate DL UL Traffic For all UEs
    Perform Intra LTE HO    ${nsa_ue_id1}    ${LTE_cell_id2}
#    Wait until the next Measurement Period starts
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter3
    Verify Any Counters In File
    ...  M55115C03506  4  NSA_DU_DRB_NBR_REQ
    ...  M55115C03507  2  NSA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  M55115C03508  2  NSA_DU_DRB_NBR_ADMIT_NOT_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    Multiple NSA UE Detach    ${nsa_ue_id1}    ${nsa_ue_id4}
    [Teardown]  Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Change UE location
    [Arguments]    ${ue_id}   ${ue_cell_id}   ${enb_id}
    wtsrunner.ue_change_location   id=${ue_id}   enb=${enb_id}    cell=${ue_cell_id}


Enable ENDC for LTE cell
    [Arguments]    ${cell_id}
    wtsrunner.enb_cell_param   enb=1   id=${cell_id}   allow_endc=on

Perform Intra LTE HO
    [Arguments]    ${nsa_ue_id1}    ${LTE_cell_id2}
    wtsrunner.ue_ho   id=${nsa_ue_id1}   ho_mode=INTRA_LTE   enb=1   cell=${LTE_cell_id2}
    ${output}    Read WTS Output Until Pattern Matches    ${LTE_INTRA_HO_egate_message}    ${60}
    Print Matching Lines from Output File    ${output}    ${LTE_INTRA_HO_egate_message}
    Should Contain    ${output}    ${LTE_INTRA_HO_egate_message}    ignore_case=True

Multiple NSA UE Start DL Traffic for new Bearer
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${bearer_id}   ${dl_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        Trigger High DL Traffic for NSA   ue_id=${ue_id}     Traffic_rate=Mbps     dl_rate=${dl_rate}       bearer_id=${bearer_id}
        sleep   1s
    END

Multiple NSA UE Start UL Traffic for new Bearer
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${bearer_id}   ${ul_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger High UL Traffic for NSA   ue_id=${ue_id}     Traffic_rate=Mbps     ul_rate=${ul_rate}      bearer_id=${bearer_id}
    END

Add new LTE Bearer for Multiple UE
     [Arguments]    ${first_ue_id}    ${last_ue_id}    ${bearer_id}   ${precedence}
     FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        Add new LTE Bearer   ${ue_id}    ${bearer_id}   ${precedence}
        ENDC Modify for Bearer Addition   ${ue_id}    ${bearer_id}
     END

Validate DL UL Traffic For all UEs
    FOR    ${ue_id}    IN RANGE    ${nsa_ue_id1}     ${nsa_ue_id4}+${1}
        Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${ue_id}     dl_rate=10   id=2
        Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${ue_id}     dl_rate=10   id=7
        Run Keyword and continue on Failure   Validate UL Traffic For NSA   ue_id=${ue_id}     ul_rate=10   id=2
        Run Keyword and continue on Failure   Validate UL Traffic For NSA   ue_id=${ue_id}     ul_rate=10   id=7
    END

Verify nbrDrbSpecificParams In usersetupreq with nbrdl and nbrul
    [Arguments]      ${logpath}       ${filter_req}     ${nbr_dl_value}    ${nbr_ul_value}
    [Documentation]      this KW Verifies the nbrDrbSpecificParams In usersetupreq captured in CPRT logs
    log to console       Verifying nbrDrbSpecificParams In usersetupreq captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${allowNBR_DL}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_user_usersetupreq
    ...                                                path=.*nbrDl_item$
    ...                                                endPacket=${2}
    ${allowNBR_UL}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_user_usersetupreq
    ...                                                path=.*nbrUl_item$
    ...                                                endPacket=${2}
    Should Contain    ${allowNBR_DL}    ${nbr_dl_value}
    Should Contain    ${allowNBR_UL}    ${nbr_ul_value}

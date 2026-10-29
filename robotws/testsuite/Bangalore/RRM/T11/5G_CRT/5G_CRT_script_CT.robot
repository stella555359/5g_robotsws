*** Settings ***
Force Tags      CLOUD_5G_O_H_AP_LOO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Mohan
...              :contact: mohanavel.p@nokia.com
...              This user scenario describes successful configuration of Long PUCCH and verifies expansion of the
...              PUSCH region over the PRB of PUCCH in the pCSI area which are still not allocated to any UE.
...              The intention is to validate the successful reception of the UL control information (UCI) carried
...              via long PUCCH Format 1, PUCCH Format 3 and PUSCH in FDD deployment for SA (NSA is added in alternate
...              scenarios),while it is noticeable that PRB in the pCSI area not allocated to any UE are then utilized
...              by PUSCH as consequence of CB006877 activation. The PRB in the pCSI area not allocated to any UE may
...              change from  slot to slot and this difference shall be noticeable in the PUSCH as well slot per slot.
...              *REQUIREMENTS COVERAGE:
...              *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_16150

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/PM_Counters.robot
Resource         ./resources/common_Resource.robot
Resource         ./resources/common_keywords.robot
Resource         ../../../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${iphy_file_TC06}
...                 AND     fix vlan in scf and commission
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces ASOH   ${wts_cfg_file_TC06}   ${no_of_cells_TC06}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Stop Log   snapshot
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

#Suite Teardown      Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${first_sa_ue}      ${1}
${last_sa_ue}     ${5}
${first_nsa_ue}      ${11}
${last_nsa_ue}      ${15}
${nrcell}   1
${cell_subgroup_id}   0
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${epc_log_path}    /tmp/
${TEST_NAME}        A_1_TC06
${num_of_prbs_using_lower_pcsi}   0
${num_of_prbs_using_upper_pcsi}   0
${num_of_prbs_lower_pcsi}   0
${count_of_prbs_using_lower_pcsi}   0
${total_uldata_pusch}    0
${dynamic_pusch_prb}    0
@{pathlist}    startPrb
${filter}   ${EMPTY}
${startPacket}   1
${endPacket}   1000
${delta_file_name}   ${scf_folder}/TC06_CB006877_disable.json
${no_of_cells_TC06}   1


*** Test Cases ***
USCB006877-A#1_TC06_Long_PUCCH_for_FDD_Cells_Multiple_SANSA_UE_on_35MHz
    [Documentation]
    ...              This user scenario describes successful configuration of Long PUCCH and verifies expansion of the
    ...              PUSCH region over the PRB of PUCCH in the pCSI area which are still not allocated to any UE.
    ...              The intention is to validate the successful reception of the UL control information (UCI) carried
    ...              via long PUCCH Format 1, PUCCH Format 3 and PUSCH in FDD deployment for SA (NSA is added in alternate
    ...              scenarios),while it is noticeable that PRB in the pCSI area not allocated to any UE are then utilized
    ...              by PUSCH as consequence of CB006877 activation. The PRB in the pCSI area not allocated to any UE may
    ...              change from  slot to slot and this difference shall be noticeable in the PUSCH as well slot per slot.

    ${LOG_PATH1}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH1}
    ${StartPuschPrb}    ${StartDynPuschPrb}   Verify UL PUSCH PRBs In CellSetupReq ASOH    ${LOG_PATH}
    X2AP Link Should be UP
    Register multiple NSA UE to cell   ${nrcell}   ${first_nsa_ue}    ${last_nsa_ue}
    Start and validate UL and DL traffic NSA UE    ${first_nsa_ue}  ${last_nsa_ue}   dl_rate=50   ul_rate=100
    ${6877_on_cell_NSA}    Check cell level UL tput NSA   ${first_nsa_ue}    ${first_nsa_ue}
    sleep  5s
    Start Log    biptaf
    sleep  2s
    Stop Log    biptaf
    Multiple NSA UE Detach   ${first_nsa_ue}    ${last_nsa_ue}
    ${NSA_BIP_PATH}    Set Variable    ${LOG_PATH1}/gNB/biptaf
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${NSA_BIP_PATH}/BIP_L1L2.pcap
    ...                                     ${StartDynPuschPrb}   ${StartPuschPrb}    ${cell_subgroup_id}
    Attach multiple SA UE with traffic  ${first_sa_ue}    ${last_sa_ue}
    ${6877_on_cell_SA}    Check cell level UL tput SA   ${first_sa_ue}    ${last_sa_ue}
    sleep  5s
    Start Log    biptaf
    sleep  2s
    Stop Log    biptaf
    MultiUE Deregister should be Successful   ${first_sa_ue}    ${last_sa_ue}
    ${SA_BIP_PATH}    Set Variable    ${LOG_PATH1}/gNB/biptaf
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${SA_BIP_PATH}/BIP_L1L2.pcap
    ...                                     ${StartDynPuschPrb}   ${StartPuschPrb}   ${cell_subgroup_id}
    #Tput check with feature off
    Send Delta Commissioning     ${TC06_delta_file_name}
    sleep   5s
    X2AP Link Should be UP
    sleep   5s
    Register multiple NSA UE to cell   ${nrcell}   ${first_nsa_ue}    ${last_nsa_ue}
    Start and validate UL and DL traffic NSA UE    ${first_nsa_ue}  ${last_nsa_ue}   dl_rate=100   ul_rate=100
    ${6877_off_cell_NSA}    Check cell level UL tput NSA   ${first_nsa_ue}    ${first_nsa_ue}
    Multiple NSA UE Detach   ${first_nsa_ue}    ${last_nsa_ue}
    Run Keyword and Continue on Failure    Should be True    ${6877_on_cell_NSA}>${6877_off_cell_NSA}
    Attach multiple SA UE with traffic  ${first_sa_ue}    ${last_sa_ue}
    ${6877_off_cell_SA}    Check cell level UL tput SA   ${first_sa_ue}    ${last_sa_ue}
    MultiUE Deregister should be Successful   ${first_sa_ue}    ${last_sa_ue}
    Run Keyword and Continue on Failure    Should be True    ${6877_on_cell_SA}>${6877_off_cell_SA}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

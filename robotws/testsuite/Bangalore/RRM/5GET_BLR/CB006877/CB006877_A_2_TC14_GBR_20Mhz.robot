*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    CRT    5G_RAN     SBTS00

Documentation    :copyright: Nokia
...              :authors: Mohan
...              :contact: mohanavel.p@nokia.com
...              To accept a GBR 5QI [2/3/4/71/72/76] or operator defined 5QI [128..254] bearer addition
...              request there must be sufficient available GBR resources in the cell. L2RT will periodically
...              report the GBR load to C-Plane. C-Plane will use this data to determine if there is sufficient
...              GBR resources available to admit another 5QI [2/3/4/71/72/76] or [128..254] bearer with a given
...              GBR value. This user scenario describes the case in which there is not sufficient GBR resources
...              to admit another 5QI [2/3/4/71/72/76] or [128..254] bearer.
...              *REQUIREMENTS COVERAGE:
...              *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_23360

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ./CB006877_Resource.robot
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=SCF_TC14_SANSA_20Mhz.xml
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces   ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords
...                 Stop Log   snapshot
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

#Suite Teardown      Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_TC14.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${first_sa_ue}      ${1}
${last_sa_ue}     ${4}
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
${IPHY_FILE}                    ${CURDIR}/config/iphy_AHLOA_2C_TC14.xml
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
${delta_file_name}   TC06_CB006877_disable.json
${INITIAL_CONTEXT_SETUP_FAILURE} =    ngap.InitialContextSetupFailure_element && ngap.radioNetwork == 22
${gbr_load} =  (itf_l2_ps_cell_celldlgbrloadind) || (itf_l2_ps_cell_cellulgbrloadind)
${no_of_cells}   2

*** Test Cases ***
USCB006877-A#2_TC14_CB008379_GBR_Load_reporting_for_GBR_Radio_Admission_Control_with_CB006877_enabled
    [Documentation]
    ...              To accept a GBR 5QI [2/3/4/71/72/76] or operator defined 5QI [128..254] bearer addition
    ...              request there must be sufficient available GBR resources in the cell. L2RT will periodically
    ...              report the GBR load to C-Plane. C-Plane will use this data to determine if there is sufficient
    ...              GBR resources available to admit another 5QI [2/3/4/71/72/76] or [128..254] bearer with a given
    ...              GBR value. This user scenario describes the case in which there is not sufficient GBR resources
    ...              to admit another 5QI [2/3/4/71/72/76] or [128..254] bearer.

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    ${StartPuschPrb}    ${StartDynPuschPrb}   Verify UL PUSCH PRBs In CellSetupReq      ${cprt_log}
    log to console   Wait for next PM to starts
    Wait until the next Measurement Period starts
    Attach multiple SA UE with ICS nGBR,5QI1 & 2 and verify gbrload  ${first_sa_ue}    ${last_sa_ue}
    log to console   Wait for next PM to stop
    Wait until the current Measurement Period stops
    ${6877_on_GBR_RAC}=    Get Latest Unpacked Raw Pm Counters File   output_dirpath=${OUTPUT DIR}/6877_on_GBR_RAC
    Verify Any Counters In File
    ...  M55138C01001  8  SA_GBR_DRB_REQ
    ...  M55138C01002  6  SA_GBR_DRB_SUCC
    ...  M55138C01003  2  SA_GBR_REJ_LACK_DRB
    ...  M55138C01004  0  SA_GBR_DRB_REL
    ...  M55308C10002  >10000000  PRB_USED_PUSCH
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${nrcell}
    ...  file_path=${6877_on_GBR_RAC}
    MultiUE Deregister should be Successful   ${first_sa_ue}    ${last_sa_ue}
    #GBR load check with feature off
    Perform SCF Delta Commissioning with ${delta_file_name}
    sleep   5s
    log to console   Wait for next PM to starts
    Wait until the next Measurement Period starts
    Attach multiple SA UE with ICS nGBR,5QI1 & 2 and verify gbrload  ${first_sa_ue}    ${last_sa_ue}
    log to console   Wait for next PM to stop
    Wait until the current Measurement Period stops
    ${6877_off_GBR_RAC}=    Get Latest Unpacked Raw Pm Counters File   output_dirpath=${OUTPUT DIR}/6877_off_GBR_RAC
    Verify Any Counters In File
    ...  M55138C01001  8  SA_GBR_DRB_REQ
    ...  M55138C01002  6  SA_GBR_DRB_SUCC
    ...  M55138C01003  2  SA_GBR_REJ_LACK_DRB
    ...  M55138C01004  0  SA_GBR_DRB_REL
    ...  M55308C10002  >10000000  PRB_USED_PUSCH
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${nrcell}
    ...  file_path=${6877_off_GBR_RAC}
    MultiUE Deregister should be Successful   ${first_sa_ue}    ${last_sa_ue}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting   

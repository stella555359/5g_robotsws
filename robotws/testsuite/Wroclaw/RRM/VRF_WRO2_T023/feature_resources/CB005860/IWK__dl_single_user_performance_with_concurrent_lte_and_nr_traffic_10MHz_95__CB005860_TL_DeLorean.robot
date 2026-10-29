*** Settings ***
Documentation
...   contact: Igor Kleschenok

Library     ute_ue
Library     taf.sbts.oam.coam.admin  WITH NAME  admin
Library     taf.collectors.ttitrace_4g    WITH NAME    ttitrace_4g
Resource    ../../resources/ca_INTER_RAT.robot
Resource    ../../resources/ca_IWK.robot


*** Variables ***
${LTE_ANCHOR_CELL_ID}                        # ID of LTE Anchor cell for which LTE4750 will be tested
${LTE_CELL_ID}                               # ID of LTE DSS cell for which LTE4750 will be tested
${LTE_EXPECTED_DL_TPUT_MBPS}                 # [Mbit/sec] Value of expected throughput in LTE DSS cell
${NR_EXPECTED_DL_TPUT_MBPS}                  # [Mbit/sec] Value of expected throughput in NR DSS cell and LTE anchor cell
${LNRELGNBCELL_ID}                           # ID of LNRELGNBCELL_A cell for 'Set Test Variables For CB005860 Test' check
${NR_UE_CAPABILITY}                          # NR UE capability
${LTE_DL_THROUGHPUT}                         # LTE DL throughput in Mbits/sec for 'Start data transfer' KW in 'Step 4: Perform LTE DL Data Transfer'
${NR_DL_THROUGHPUT}                          # NR DL throughput in Mbits/sec for 'Start data transfer' KW in 'Step 3: Perform 5G DL Data Transfer'
${RECOMMISSIONING_TIMEOUT}      600          # Timeout for recommissioning procedure (value in seconds)
${BLANKED_PUCCH}                             # Expected value for 'blankedPucch' parameter.

*** Keywords ***
TC__IWK__dl_single_user_performance_with_concurrent_lte_and_nr_traffic_10MHz_95__CB005860_TL_DeLorean

    Set Tags    CA-INTER_RAT    AUTHOR-mariusz.makuch@nokia.com OWNER-mariusz.daniel@nokia.com
    ...         MAINTAINER-oleksandr.kulieshov@nokia.com  PHASE-CRT   SW-SBTS22R1    FEATURE-CB005860    GROUP_IN_CHARGE-WRO_3_Vrf

    Preconditions
    Step 1: Change DSS Related Parameters On eNB Side
    Step 2: Change DSS Related Parameters On gNB Side
    Step 3: Perform 5G DL Data Transfer
    Step 4: Perform LTE DL Data Transfer
    Step 5: Stop 5G Data Transfer


Preconditions
    Log  \n*** Preconditions ***  console=True

    Run Keyword If  ${SINGLE_SBTS}  Set Test Variables For CB005860 Test Single BTS  ${LNRELGNBCELL_ID}  ${CONNECTIVITY}
    ...    ELSE  Set Test Variables For CB005860 Test  ${LNRELGNBCELL_ID}
    Log  List of LTE DSS cells: ${LTE_DSS_CELL_ID_LIST}  console=True
    Log  List of NR DSS cells: ${NR_DSS_CELL_ID_LIST}  console=True
    Check Preconditions For CB005860 Test  ${BLANKED_PUCCH}
    Create Global Variables
    Require UE  LTE_UE  LTE_LOCKED
    Require UE  NR_UE  ${NR_UE_CAPABILITY}
    Log  Preconditions passed!  console=True


Create Global Variables
    ${cell_ratio_dict_dl} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_RATIO_DICTIONARY_DL}    ${cell_ratio_dict_dl}
    ${cell_min_ratio_dict_dl} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_CELL_MIN_RATIO_DICT_DL}    ${cell_min_ratio_dict_dl}
    ${cell_max_ratio_dict_dl} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_CELL_MAX_RATIO_DICT_DL}    ${cell_max_ratio_dict_dl}
    ${cell_ratio_dict_ul} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_RATIO_DICTIONARY_UL}       ${cell_ratio_dict_ul}
    ${cell_min_ratio_dict_ul} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_CELL_MIN_RATIO_DICT_UL}    ${cell_min_ratio_dict_ul}
    ${cell_max_ratio_dict_ul} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_CELL_MAX_RATIO_DICT_UL}    ${cell_max_ratio_dict_ul}

    ${cell_nr_ratio_dict_dl} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_NR_RATIO_DICTIONARY_DL}    ${cell_nr_ratio_dict_dl}
    ${cell_nr_ratio_dict_ul} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_NR_RATIO_DICTIONARY_UL}    ${cell_nr_ratio_dict_ul}
    ${nr_cell_min_ratio_dict_dl} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_NR_CELL_MIN_RATIO_DICT_DL}    ${nr_cell_min_ratio_dict_dl}
    ${nr_cell_max_ratio_dict_dl} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_NR_CELL_MAX_RATIO_DICT_DL}    ${nr_cell_max_ratio_dict_dl}
    ${nr_cell_min_ratio_dict_ul} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_NR_CELL_MIN_RATIO_DICT_UL}    ${nr_cell_min_ratio_dict_ul}
    ${nr_cell_max_ratio_dict_ul} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_NR_CELL_MAX_RATIO_DICT_UL}    ${nr_cell_max_ratio_dict_ul}

    ${cell_max_cr_pg_dl} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_CELL_MAX_CR_PG_DL}     ${cell_max_cr_pg_dl}
    ${cell_max_cr_ra_4_dl} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_CELL_MAX_CR_RA_4_DL}   ${cell_max_cr_ra_4_dl}
    ${cell_max_cr_ra_dl} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_CELL_MAX_CR_RA_DL}     ${cell_max_cr_ra_dl}
    ${cell_max_cr_ra_dl_ho} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_CELL_MAX_CR_RA_DL_HO}  ${cell_max_cr_ra_dl_ho}
    ${cell_max_cr_sib_dl} =  Create Dictionary
    Set Test Variable  ${ORIGINAL_CELL_MAX_CR_SIB_DL}    ${cell_max_cr_sib_dl}



Step 1: Change DSS Related Parameters On eNB Side
    Log  \n*** Step 1: Change DSS Related Parameters On eNB Side ***  console=True
    Change DSS Related Parameters On eNB Side  delta_name=enb_configuration


Change DSS Related Parameters On eNB Side
    [Arguments]  ${delta_name}

    Create Delta  ${delta_name}
    FOR  ${lte_dss_cell_id}  IN  @{LTE_DSS_CELL_ID_LIST}

        ${min_nr_dss_ratio_dl} =  Set Variable If  '${delta_name}' == 'enb_configuration'
        ...  95  ${ORIGINAL_CELL_MIN_RATIO_DICT_DL['${lte_dss_cell_id}']}
        ${max_nr_dss_ratio_dl} =  Set Variable If  '${delta_name}' == 'enb_configuration'
        ...  95  ${ORIGINAL_CELL_MAX_RATIO_DICT_DL['${lte_dss_cell_id}']}
        ${min_nr_dss_ratio_ul} =  Set Variable If  '${delta_name}' == 'enb_configuration'
        ...  50  ${ORIGINAL_CELL_MIN_RATIO_DICT_UL['${lte_dss_cell_id}']}
        ${max_nr_dss_ratio_ul} =  Set Variable If  '${delta_name}' == 'enb_configuration'
        ...  50  ${ORIGINAL_CELL_MAX_RATIO_DICT_UL['${lte_dss_cell_id}']}
        ${max_cr_pg_dl} =     Set Variable If  '${delta_name}' == 'enb_configuration'  50  ${ORIGINAL_CELL_MAX_CR_PG_DL['${lte_dss_cell_id}']}
        ${max_cr_ra_4_dl} =   Set Variable If  '${delta_name}' == 'enb_configuration'  50  ${ORIGINAL_CELL_MAX_CR_RA_4_DL['${lte_dss_cell_id}']}
        ${max_cr_ra_dl} =     Set Variable If  '${delta_name}' == 'enb_configuration'  50  ${ORIGINAL_CELL_MAX_CR_RA_DL['${lte_dss_cell_id}']}
        ${max_cr_ra_dl_ho} =  Set Variable If  '${delta_name}' == 'enb_configuration'  50  ${ORIGINAL_CELL_MAX_CR_RA_DL_HO['${lte_dss_cell_id}']}
        ${max_cr_sib_dl} =    Set Variable If  '${delta_name}' == 'enb_configuration'  50  ${ORIGINAL_CELL_MAX_CR_SIB_DL['${lte_dss_cell_id}']}

        Append Parameter Update To Delta  ${LTE_LNBTS_DISTNAME}/LNCEL-${lte_dss_cell_id}  maxCrPgDl    ${max_cr_pg_dl}     delta_id=${delta_name}
        Append Parameter Update To Delta  ${LTE_LNBTS_DISTNAME}/LNCEL-${lte_dss_cell_id}  maxCrRa4Dl   ${max_cr_ra_4_dl}   delta_id=${delta_name}
        Append Parameter Update To Delta  ${LTE_LNBTS_DISTNAME}/LNCEL-${lte_dss_cell_id}  maxCrRaDl    ${max_cr_ra_dl}     delta_id=${delta_name}
        Append Parameter Update To Delta  ${LTE_LNBTS_DISTNAME}/LNCEL-${lte_dss_cell_id}  maxCrRaDlHo  ${max_cr_ra_dl_ho}  delta_id=${delta_name}
        Append Parameter Update To Delta  ${LTE_LNBTS_DISTNAME}/LNCEL-${lte_dss_cell_id}  maxCrSibDl   ${max_cr_sib_dl}    delta_id=${delta_name}

        Run Keyword If  '${delta_name}' == 'enb_configuration'  Set LTE Global Dictionary
        ...  lte_dss_cell_id=${lte_dss_cell_id}  list_name=lteNrDssDlRatio
        Run Keyword If  '${delta_name}' == 'enb_configuration'  Set LTE Global Dictionary
        ...  lte_dss_cell_id=${lte_dss_cell_id}  list_name=lteNrDssUlRatio

        Append LteNrDssDlRatio/LteNrDssUlRatio To LTE Delta  delta_name=${delta_name}  list_name=lteNrDssDlRatio
        ...  min_nr_dss_ratio=${min_nr_dss_ratio_dl}  max_nr_dss_ratio=${max_nr_dss_ratio_dl}
        ...  original_ratio_dictionary=${ORIGINAL_RATIO_DICTIONARY_DL['${lte_dss_cell_id}']}
        ...  lte_dss_cell_id=${lte_dss_cell_id}
        Append LteNrDssDlRatio/LteNrDssUlRatio To LTE Delta  delta_name=${delta_name}  list_name=lteNrDssUlRatio
        ...  min_nr_dss_ratio=${min_nr_dss_ratio_ul}  max_nr_dss_ratio=${max_nr_dss_ratio_ul}
        ...  original_ratio_dictionary=${ORIGINAL_RATIO_DICTIONARY_UL['${lte_dss_cell_id}']}
        ...  lte_dss_cell_id=${lte_dss_cell_id}

    END
    ${delta}  Get Delta  delta_id=${delta_name}
    Set Test Variable  ${ENB_PARAMETERS_CHANGED}  True
    Log  Delta for eNB side is: \n${delta}  console=True
    Perform Delta Recommissioning  ${delta}  alias=${ENB_ALIAS}
    Log  \nDSS parameters changed successfully on eNB side.  console=True


Set LTE Global Dictionary
    [Arguments]  ${lte_dss_cell_id}  ${list_name}
    ${direction} =  Set Variable If  '${list_name}' == 'lteNrDssDlRatio'  DL  UL
    ${ratio_dict} =  Get LteNrDssDlRatio/LteNrDssUlRatio Dictionary From SCF   ul_dl_ratio_name=${list_name}

    Set To Dictionary  ${ORIGINAL_RATIO_DICTIONARY_${direction}}  ${lte_dss_cell_id}  ${ratio_dict}
    Set To Dictionary  ${ORIGINAL_CELL_MIN_RATIO_DICT_${direction}}  ${lte_dss_cell_id}  ${ratio_dict['minNrDssRatio']}
    Set To Dictionary  ${ORIGINAL_CELL_MAX_RATIO_DICT_${direction}}  ${lte_dss_cell_id}  ${ratio_dict['maxNrDssRatio']}

    ${max_cr_pg_dl} =  Get Parameter Value From SCF  ${PARSED_SCF_ENB}  LNCEL  LNCEL-${lte_dss_cell_id}  /p[@name='maxCrPgDl']
    ...  dist_name_substring=True
    Set To Dictionary  ${ORIGINAL_CELL_MAX_CR_PG_DL}   ${lte_dss_cell_id}  ${max_cr_pg_dl}
    ${max_cr_ra_4_dl} =  Get Parameter Value From SCF  ${PARSED_SCF_ENB}  LNCEL  LNCEL-${lte_dss_cell_id}  /p[@name='maxCrRa4Dl']
    ...  dist_name_substring=True
    Set To Dictionary  ${ORIGINAL_CELL_MAX_CR_RA_4_DL}   ${lte_dss_cell_id}  ${max_cr_ra_4_dl}
    ${max_cr_ra_dl} =  Get Parameter Value From SCF  ${PARSED_SCF_ENB}  LNCEL  LNCEL-${lte_dss_cell_id}  /p[@name='maxCrRaDl']
    ...  dist_name_substring=True
    Set To Dictionary  ${ORIGINAL_CELL_MAX_CR_RA_DL}   ${lte_dss_cell_id}  ${max_cr_ra_dl}
    ${max_cr_ra_dl_ho} =  Get Parameter Value From SCF  ${PARSED_SCF_ENB}  LNCEL  LNCEL-${lte_dss_cell_id}  /p[@name='maxCrRaDlHo']
    ...  dist_name_substring=True
    Set To Dictionary  ${ORIGINAL_CELL_MAX_CR_RA_DL_HO}   ${lte_dss_cell_id}  ${max_cr_ra_dl_ho}
    ${max_cr_sib_dl} =  Get Parameter Value From SCF  ${PARSED_SCF_ENB}  LNCEL  LNCEL-${lte_dss_cell_id}  /p[@name='maxCrSibDl']
    ...  dist_name_substring=True
    Set To Dictionary  ${ORIGINAL_CELL_MAX_CR_SIB_DL}   ${lte_dss_cell_id}   ${max_cr_sib_dl}

Append LteNrDssDlRatio/LteNrDssUlRatio To LTE Delta
    [Arguments]  ${delta_name}  ${list_name}  ${min_nr_dss_ratio}  ${max_nr_dss_ratio}  ${original_ratio_dictionary}  ${lte_dss_cell_id}
    ${parameters_dict} =  Create Dictionary   &{original_ratio_dictionary}
    ...                                       minNrDssRatio=${min_nr_dss_ratio}
    ...                                       maxNrDssRatio=${max_nr_dss_ratio}
    Append Complex Item To Delta      ${LTE_LNBTS_DISTNAME}/LNCEL-${lte_dss_cell_id}/DSSNR-0
    ...                               ${list_name}
    ...                               ${delta_name}
    ...                               &{parameters_dict}


Step 2: Change DSS Related Parameters On gNB Side
    Log  \n*** Step 2: Change DSS Related Parameters On gNB Side ***  console=True
    Change DSS Related Parameters On gNB Side  gnb_configuration
    Wait Until Keyword Succeeds  5m  10s  Verify BTS States For IWK Test  eNB_alias=${ENB_ALIAS}

Change DSS Related Parameters On gNB Side
    [Arguments]  ${delta_name}
    Create Delta  ${delta_name}
    FOR  ${nr_dss_cell_id}  IN  @{NR_DSS_CELL_ID_LIST}

        ${min_nr_dss_ratio_dl} =  Set Variable If  '${delta_name}' == 'gnb_configuration'
        ...  95  ${ORIGINAL_NR_CELL_MIN_RATIO_DICT_DL['${nr_dss_cell_id}']}
        ${max_nr_dss_ratio_dl} =  Set Variable If  '${delta_name}' == 'gnb_configuration'
        ...  95  ${ORIGINAL_NR_CELL_MAX_RATIO_DICT_DL['${nr_dss_cell_id}']}
        ${min_nr_dss_ratio_ul} =  Set Variable If  '${delta_name}' == 'gnb_configuration'
        ...  50  ${ORIGINAL_NR_CELL_MIN_RATIO_DICT_UL['${nr_dss_cell_id}']}
        ${max_nr_dss_ratio_ul} =  Set Variable If  '${delta_name}' == 'gnb_configuration'
        ...  50  ${ORIGINAL_NR_CELL_MAX_RATIO_DICT_UL['${nr_dss_cell_id}']}

        Run Keyword If  '${delta_name}' == 'gnb_configuration'  Set NR Global Dictionary
        ...  nr_dss_cell_id=${nr_dss_cell_id}  list_name=lteNrDssDlRatio
        Run Keyword If  '${delta_name}' == 'gnb_configuration'  Set NR Global Dictionary
        ...  nr_dss_cell_id=${nr_dss_cell_id}  list_name=lteNrDssUlRatio

        Append LteNrDssDlRatio/LteNrDssUlRatio To NR Delta  delta_name=${delta_name}  list_name=lteNrDssDlRatio
        ...  min_nr_dss_ratio=${min_nr_dss_ratio_dl}  max_nr_dss_ratio=${max_nr_dss_ratio_dl}
        ...  original_ratio_dictionary=${ORIGINAL_NR_RATIO_DICTIONARY_DL['${nr_dss_cell_id}']}
        ...  nr_dss_cell_id=${nr_dss_cell_id}
        Append LteNrDssDlRatio/LteNrDssUlRatio To NR Delta  delta_name=${delta_name}  list_name=lteNrDssUlRatio
        ...  min_nr_dss_ratio=${min_nr_dss_ratio_ul}  max_nr_dss_ratio=${max_nr_dss_ratio_ul}
        ...  original_ratio_dictionary=${ORIGINAL_NR_RATIO_DICTIONARY_UL['${nr_dss_cell_id}']}
        ...  nr_dss_cell_id=${nr_dss_cell_id}
    END
    ${delta}  Get Delta  delta_id=${delta_name}
    Set Test Variable  ${GNB_PARAMETERS_CHANGED}  True
    Log  Delta for gNB side is: \n${delta}  console=True
    Perform Delta Recommissioning  ${delta}  alias=gNB
    Log  \nDSS parameters changed successfully on gNB side.  console=True


Set NR Global Dictionary
    [Arguments]  ${nr_dss_cell_id}  ${list_name}
    ${direction} =  Set Variable If  '${list_name}' == 'lteNrDssDlRatio'  DL  UL
    ${ratio_dict} =  Get LteNrDssDlRatio/LteNrDssUlRatio Dictionary From SCF   ${PARSED_SCF_GNB}  NRDSSLTE
    ...  ${NR_NRCEL_DISTNAME}/NRDSSLTE-1
    ...  ul_dl_ratio_name=${list_name}
    Set To Dictionary  ${ORIGINAL_NR_RATIO_DICTIONARY_${direction}}  ${nr_dss_cell_id}  ${ratio_dict}
    Set To Dictionary  ${ORIGINAL_NR_CELL_MIN_RATIO_DICT_${direction}}  ${nr_dss_cell_id}  ${ratio_dict['minNrDssRatio']}
    Set To Dictionary  ${ORIGINAL_NR_CELL_MAX_RATIO_DICT_${direction}}  ${nr_dss_cell_id}  ${ratio_dict['maxNrDssRatio']}



Append LteNrDssDlRatio/LteNrDssUlRatio To NR Delta
    [Arguments]  ${delta_name}  ${list_name}  ${min_nr_dss_ratio}  ${max_nr_dss_ratio}  ${original_ratio_dictionary}  ${nr_dss_cell_id}
    ${parameters_dict} =  Create Dictionary   &{original_ratio_dictionary}
    ...                                       minNrDssRatio=${min_nr_dss_ratio}
    ...                                       maxNrDssRatio=${max_nr_dss_ratio}
    Append Complex Item To Delta      ${NR_NRBTS_DISTNAME}/NRCELL-${nr_dss_cell_id}/NRDSSLTE-1
    ...                               ${list_name}
    ...                               ${delta_name}
    ...                               &{parameters_dict}


Step 3: Perform 5G DL Data Transfer
    Log  \n=== Step 3: Perform 5G DL Data Transfer ===  console=True

    Prepare UE For Data Transfer  NR_UE  ${LTE_ANCHOR_CELL_ID}  connection=${ENB_ALIAS}  lte_cell=${LTE_CELL}
    Start Data Transfer  NR_DT  NR_UE  dl  throughput=${NR_DL_THROUGHPUT} Mbits/sec  protocol=tcp
    ...                  max_segment_size=1400  duration=600s  buffer=32M  apn=${APN}
    Log  \n5G Data Transfer started  console=True


Step 4: Perform LTE DL Data Transfer
    Log  \n=== Step 4: Perform LTE DL Data Transfer ===  console=True

    Prepare UE For Data Transfer  LTE_UE  ${LTE_CELL_ID}  connection=${ENB_ALIAS}
    Start Data Transfer  LTE_DT  LTE_UE  dl  throughput=${LTE_DL_THROUGHPUT} Mbits/sec  protocol=tcp
    ...                  max_segment_size=1400  duration=300s  buffer=32M  apn=${APN}
    Log  \nLTE Data Transfer started  console=True
    Log To Console  Wait 30s for stabilize t-put
    Sleep  30

    Collect 4G TTI Trace   cell_id=${LTE_CELL_ID}
    ...                    trace_time=10s
    ...                    output_path=${LOG_PATH}/tti_trace_LTE_DSS

    Run Keyword And Ignore Error  Await Data Transfer Finish  LTE_DT
    Log  \nWait until LTE Data Transfer is finished  console=True
    Run Keyword And Continue On Failure  Verify Average Throughput With Deviation  LTE_DT  ${LTE_EXPECTED_DL_TPUT_MBPS} Mbits/sec  20%  10
    Log  \nAverage T-put of LTE data transfer is OK  console=True
    Stop Datatransfer  LTE_DT


Step 5: Stop 5G Data Transfer
    Log  \n=== Step 5: Stop 5G Data Transfer ===  console=True
    Verify Average Throughput With Deviation  NR_DT  ${NR_EXPECTED_DL_TPUT_MBPS} Mbits/sec  20%  10
    Stop Datatransfer  NR_DT
    Log  \nAverage T-put of 5G data transfer is OK  console=True


Reconfiguration Teardown
    Log  \n=== Start reconfiguration teardown ===  console=True
    Stop Wireshark Log Collection For IWK Test
    Run Keyword If  ${ENB_PARAMETERS_CHANGED}  Run Keywords
    ...  Log  \nLTE site recommissioning ongoing  console=True
    ...  AND  Change DSS Related Parameters On eNB Side  enb_reconfiguration
    Run Keyword If  ${GNB_PARAMETERS_CHANGED}  Run Keywords
    ...  Log  \n5G site recommissioning ongoing  console=True
    ...  AND  Change DSS Related Parameters On gNB Side  gnb_reconfiguration
    Wait Until Keyword Succeeds  5m  10s  Verify BTS States For IWK Test  eNB_alias=${ENB_ALIAS}
    Run Keyword If  not ${SINGLE_SBTS}  Start Wireshark Log Collection For IWK Test
    ...  ELSE  Start Wireshark Log Collection For IWK Test
    ...        options=-i any host ${GNB_VM_IP} and not udp port 2152 -s 0 -W 1
    ...        replace_enb=False  replace_gnb=False
    Log  \n=== Reconfiguration Teardown successfully PASSED ===  console=True


TC Setup
    IWK Test Setup  local_enb_connection=${LOCAL_ENB_CONNECTION}  single_bts=${SINGLE_BTS}


TC Teardown
    Log  \n=== Test Specific Teardown ===  console=True

    Stop Data Transfers For All Ues
    Detach UE  LTE_UE
    Detach UE  NR_UE
    Reconfiguration Teardown
    IWK Test Teardown  delta_exists=False  local_enb_connection=${LOCAL_ENB_CONNECTION}  single_bts=${SINGLE_BTS}

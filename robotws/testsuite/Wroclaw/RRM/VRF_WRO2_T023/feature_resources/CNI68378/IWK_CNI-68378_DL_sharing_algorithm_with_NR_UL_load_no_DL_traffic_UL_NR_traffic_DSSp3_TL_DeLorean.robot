*** Settings ***
Documentation
...   contact: Igor Kleschenok

Library     ute_ue
Library     taf.sbts.oam.coam.admin  WITH NAME  admin
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/ca_INTER_RAT.robot


*** Variables ***
${LTE_ANCHOR_CELL_ID}       # ID of LTE Anchor (NSA) / NR (SA) cell for which CNI68378 will be tested
${LTE_CELL_ID}              # ID of LTE DSS cell for which CNI68378 will be tested
${LTE_UL_TPUT}              # [Mbit/sec] Value of expected throughput in LTE DSS cell
${NR_UL_TPUT}               # [Mbit/sec] Value of expected throughput in NR DSS cell and LTE anchor cell
${DEVIATION}      20        # [%] Expected throughput deviation. Deafult value: 20%
${INCREASE}       20        # [%] Value of increase in throughput with the feature enabled. It shouldn't be below 10%. Deafult value: 75%


*** Keywords ***
TC__IWK_CNI-68378_DL_sharing_algorithm_with_NR_UL_load_no_DL_traffic_UL_NR_traffic_DSSp3_TL_DeLorean
    Set Tags    CA-IWK    AUTHOR-mariusz.makuch@nokia.com  OWNER-kamila.lisztwan@nokia.com
    ...         MAINTAINER-igor.kleschenok@nokia.com  PHASE-CRT   SW-SBTS22R1    FEATURE-CNI68738    GROUP_IN_CHARGE-WRO_3_Vrf

    Preconditions DeLorean
    Step 1: Perform NR UL Data Transfer DeLorean
    Step 2: Perform LTE UL Data Transfer DeLorean
    Step 3: Verify UL Throughput DeLorean
    Step 4: Activate actDssDlShareAlgNrUlLoad On eNB DeLorean
    Step 5: Perform NR UL Data Transfer DeLorean
    Step 6: Perform LTE UL Data Transfer DeLorean
    Step 7: Verify UL Throughput With Activated Feature DeLorean


Preconditions DeLorean
    Log  \n*** Preconditions ***  console=True
    Set Test Variables For CB005860 Test Single BTS  ${LNRELGNBCELL_ID}  ${CONNECTIVITY}
    Check Preconditions For CB005860 Test  ${BLANKED_PUCCH}
    Check Element In SCF  ${PARSED_SCF_ENB}  LNBTS  MRBTS-55202/LNBTS-8623  /p[@name='actDssDlShareAlgNrUlLoad']
    ...  <p name="actDssDlShareAlgNrUlLoad">false</p>  dist_name_substring=True
    Require UE  LTE_UE  LTE_LOCKED
    Require UE  NR_UE  ${NR_UE_CAPABILITY}
    Log  Preconditions passed!  console=True


Step ${step}: Perform NR UL Data Transfer DeLorean
    Log  \n=== Step ${step}: Perform NR UL Data Transfer ===  console=True
    Prepare UE For Data Transfer  NR_UE  ${LTE_ANCHOR_CELL_ID}  connection=${ENB_ALIAS}  lte_cell=${LTE_CELL}
    Start Data Transfer  NR_DT  NR_UE  ul  throughput=50 Mbits/sec  protocol=tcp  max_segment_size=1400
    ...                                                           duration=300s  buffer=32M  apn=${APN}
    Log  \nNR Data Transfer started  console=True


Step ${step}: Perform LTE UL Data Transfer DeLorean
    Log  \n=== Step ${step}: Perform LTE UL Data Transfer ===  console=True
    Prepare UE For Data Transfer  LTE_UE  ${LTE_CELL_ID}  connection=${ENB_ALIAS}
    Start Data Transfer  LTE_DT  LTE_UE  ul  throughput=50 Mbits/sec  protocol=tcp  max_segment_size=1400
    ...                                                             duration=300s  buffer=32M  apn=${APN}
    Log  \nLTE Data Transfer started  console=True
    Log To Console  Wait 90s for stabilize t-put
    Sleep  90


Step 3: Verify UL Throughput DeLorean
    Log  \n=== Step 3: Verify UL Throughput ===  console=True
    ${lte_ul} =  ute_ue.Get Average Throughput  LTE_DT  10
    Run Keyword And Continue On Failure  Verify Average Throughput With Deviation  LTE_DT  ${LTE_UL_TPUT} Mbits/sec  ${DEVIATION}  20
    Log  \nAverage LTE UL: ${lte_ul} Kbits/sec  console=True
    ${nr_ul} =  ute_ue.Get Average Throughput  NR_DT  10
    Run Keyword And Continue On Failure  Verify Average Throughput With Deviation  NR_DT  ${NR_UL_TPUT} Mbits/sec  ${DEVIATION}  20
    Log  Average NR UL: ${nr_ul} Kbits/sec  console=True
    Stop Data Transfers For All Ues


Step 4: Activate actDssDlShareAlgNrUlLoad On eNB DeLorean
    Log  \n=== Step 4: Activate actDssDlShareAlgNrUlLoad On eNB ===  console=True
    Change actDssDlShareAlgNrUlLoad On eNB DeLorean  true


Step 7: Verify UL Throughput With Activated Feature DeLorean
    Log  \n=== Step 7: Verify UL Throughput With Activated Feature ===  console=True

    ${NR_UL_TPUT_WITH_FEATURE} =  Evaluate  ${NR_UL_TPUT} + (${NR_UL_TPUT} * ${INCREASE} / 100)

    ${lte_ul} =  ute_ue.Get Average Throughput  LTE_DT  10
    Run Keyword And Continue On Failure  Verify Average Throughput With Deviation  LTE_DT  ${LTE_UL_TPUT} Mbits/sec  ${DEVIATION}  10
    Log  \nAverage LTE UL: ${lte_ul} Kbits/sec  console=True

    ${nr_ul} =  ute_ue.Get Average Throughput  NR_DT  10
    Run Keyword And Continue On Failure  Verify Average Throughput With Deviation  NR_DT   ${NR_UL_TPUT_WITH_FEATURE} Mbits/sec  ${DEVIATION}  10
    Log  Average NR UL: ${nr_ul} Kbits/sec  console=True

    Stop Data Transfers For All Ues


Change actDssDlShareAlgNrUlLoad On eNB DeLorean
    [Arguments]  ${status}
    Create Delta
    Append Parameter Update To Delta   MRBTS-55202/LNBTS-8623    actDssDlShareAlgNrUlLoad    ${status}
    ${delta}  Get Delta
    Log  Delta contents:\n${delta}  console=True
    Perform Delta Recommissioning  ${delta}  alias=${ENB_ALIAS}
    Run Keyword If  '${status}' == 'true'  Set Test Variable  ${ENB_PARAMETERS_CHANGED}  True
    ...  ELSE  Set Test Variable  ${ENB_PARAMETERS_CHANGED}  False
    Wait Until Keyword Succeeds  2min  10s  Verify BTS States For IWK Test  eNB_alias=${ENB_ALIAS}
    Log  Changed actDssDlShareAlgNrUlLoad On eNB to ${status}  console=True
    [Teardown]  Remove Delta


TC Setup
    IWK Test Setup  local_enb_connection=${LOCAL_ENB_CONNECTION}  single_bts=${SINGLE_BTS}


TC Teardown
    Log  \n=== Test Specific Teardown ===  console=True
    Stop Data Transfers For All Ues
    Detach UE  LTE_UE
    Detach UE  NR_UE
    Run Keyword If  ${ENB_PARAMETERS_CHANGED}  Run Keyword  Change actDssDlShareAlgNrUlLoad On eNB DeLorean  false
    IWK Test Teardown  delta_exists=False  local_enb_connection=${LOCAL_ENB_CONNECTION}  single_bts=${SINGLE_BTS}

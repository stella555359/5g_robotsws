*** Settings ***
Documentation
    ...  TC for GSM RAT reset from ADMIN API.GSM RAT reset is performed (whole operation from sending trigger
    ...  request to GSM reaching OnAir again)

Resource  ../../common_resources/ca_KPI_general.robot


*** Keywords ***
TC__KPI__GSM_RAT_reset_from_ADMIN
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-19472
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  28.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19472 - Test creation
    ...  07.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19444 - Added KPI console log
    ...  20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22066 - Adapt KPI TCs for CNI-61110
    ...  22.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22843 - Adjust delta results to be collected from single runs
    ...  10.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23848 - Migrate from hran_ims to oam_kpi_calculations
    ...  10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24073 - Log delta to console
    ...  11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24107 - Save delta in json file after every TC
    ...  18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30323 - Drop ute_admin_infomodel usage from KPI test cases
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-19472.png

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-robert.susz@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  CABLING-SBTS_03_UEManager  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923
    ...  FEATURE-RP001486_RP000923  FEATURE-RP0001145_RP000923

    Step 0: Check Precondition And Set Test Variables
    Step 1: Check All Cell States - OnAir Expected
    Step 2: Perform GSM RAT Reset
    Step 3: Check All Cell States During GSM RAT Reset
    Step 4: Check All Cell States - OnAir Expected


Step 0: Check Precondition And Set Test Variables
    Setup BSC Connection
    Get BCF ID
    Log  Checking Preconditions * * *  console=true
    Check BCF States
    Check Sectors States
    Check TRX States
    ${wbts_list}  coam.Get Managed Objects  WBTS
    ${wbts}  Evaluate  len(${wbts_list}) > 0
    ${lnbts_list}  coam.Get Managed Objects  LNBTS
    ${lnbts}  Evaluate  len(${wbts_list}) > 0
    ${gnbts_list}  coam.Get Managed Objects  GNBTS
    ${gnbts}  Evaluate  len(${gnbts_list}) > 0
    Log  Is WCDMA in Configuration: ${wbts} // Is LTE in Configuration: ${lnbts} // Is GSM in Configuration: ${gnbts}  console=true
    Set Test Variable  ${WBTS}
    Set Test Variable  ${LNBTS}
    IF  '${gnbts}'=='False'  Fail  There in no GNBTS (GSM) in configuration
    Log  END of Checking Preconditions * * *  console=true


Setup BSC Connection
    Log  Setting up SSH connection to BSC: ${BSC['ip']}  console=true
    hran_bsc.Bsc SSH Connection  ${BSC['ip']}  username=${BSC['user']}  password=${BSC['password']}
    hran_bsc.Set Keepalive
    hran_bsc.Set Timeout  30s
    Log  BSC SSH connection Status: OK  console=true


Step ${n}: Check All Cell States - OnAir Expected
    Log  Step ${n}: Check All Cell States - OnAir Expected  console=true
    coam.Assert Every  GNCEL  administrativeState=${UNLOCKED}, operationalState=${ENABLED}, blockingState=${UNBLOCKED}
    IF  ${LNBTS}  coam.Assert Every  LNCEL  administrativeState=${UNLOCKED}, operationalState=${ENABLED}, blockingState=${UNBLOCKED}
    IF  ${WBTS}  coam.Assert Every  WNCEL  operationalState=${ENABLED}, blockingState=${UNBLOCKED}
    Check TRX States
    Log  All Cell states as expected - OK  console=true


Step 3: Check All Cell States During GSM RAT Reset
    Log  Checking All Cell States During GSM RAT Reset  console=true
    coam.Assert Every  GNCEL  availabilityStatus=${OFFLINE}, administrativeState=${UNLOCKED}, operationalState=${DISABLED}, blockingState=${UNBLOCKED}
    IF  ${LNBTS}  coam.Assert Every  LNCEL  administrativeState=${UNLOCKED}, operationalState=${ENABLED}, blockingState=${UNBLOCKED}
    IF  ${WBTS}  coam.Assert Every  WNCEL  operationalState=${ENABLED}, blockingState=${UNBLOCKED}]
    Log  All Cell states as expected - OK  console=true


Step 2: Perform GSM RAT Reset
    Log  Perform GSM RAT reset  console=True
    Reset Rat  GSM  timeout=300
    Log  GSM RAT reset has been performed via ADMIN API  console=true


Check BCF States
    Log  Checking BCF states  console=true
    ${bcf_administrative_state}  ${bcf_operational_state}  hran_bsc.Get BCF Status  ${BCF_ID}
    Should Be Equal As Strings  ${bcf_administrative_state}  U
    Should Be Equal As Strings  ${bcf_operational_state}  WO
    Log  BCF states as expected, administrative_state=U, operational_state=WO  console=true


Check Sectors States
    Log  Checking BCF Sectors states  console=true
    hran_bsc.Parse BCF Sectors Status  bcf_id=${BCF_ID}  expected_operational_state=WO  expected_administrative_state=U
    Log  BCF Sectors states as expected: perational_state=WO administrative_state=U  console=true


Check TRX States
    Log  Checking TRX's states  console=true
    Wait Until Keyword Succeeds  3 min  30 sec
    ...  hran_bsc.Parse BCF Trxs Status  bcf_id=${BCF_ID}  expected_operational_state=WO  expected_administrative_state=U
    Log  Checking TRX's expected: operational_state=WO administrative_state=U  console=true


Get BCF ID
    Log  Getting BCF id form iM  console=true
    ${bcf_id}  sbts_infomodel.Infomodel Get BcfId
    Set Test Variable  ${BCF_ID}
    Log  BCF id = ${BCF_ID}  console=true


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}


TC Teardown
    Close All BSC Sessions
    Common Test Teardown
    ${kpi9}  Calculate Kpi9  ${BTS_FILES}/IM/InfoModel_log.ims2
    Log Delta In Seconds  ${kpi9}[kpi9][-1][delta]  kpi9
    Save Delta Results  kpi9
    Set Log Level  TRACE

*** Settings ***

Documentation
...    author: Jakub Grela
...    contact: jakub.grela@nokia.com
...    Description: Suite description in QC

Library       ../resources/former_l2_sw1/python/traffic_handling.py
Resource      resources/CB009794_resources.robot

Force Tags    CDRT    CRT    PY39    RAN_5G    RAN_5G_FDD    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup     Run keywords    Change AP noise
...             AND    Prepare suite environment  egate_config=${cfg_file}
Suite Teardown  Clean suite environment

*** Variables ***
${cfg_file}=   /opt/wts/latest/basic_setup.cfg
${counters}=              M55369C00000-M55369C00007,M55369C00100-M55369C00107,M55369C00200-M55369C00207
@{AP_noise}=    0x70698=150
*** Test Cases ***
CB009794-NR_RTWP_increases_with_increase_in_UL_traffic_FDD_CPRI_SA

    [Setup]  Prepare BIP column for PUSCH

    Wait for next full pm interval
    Set pdu param for internal traffic  UE_ID=51  PDU_ID=1
    Register UE  UE_ID=51  CELL_ID=3
    Establish PDU session  UE_ID=51    PDU_ID=1
    Start SA traffic  ue=51  dir=ul  traffic_rate=20Mbps  pdu=1

    ${pm_counters}=  Wait for next pm interval and get counters
    Verify If Pm Counter Does Not Exist
    ...    counter_id=M55369C00000
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    filepath=${pm_counters}

    Verify If Pm Counter Does Not Exist
    ...    counter_id=M55369C00001
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    filepath=${pm_counters}

    Verify If Pm Counter Does Not Exist
    ...    counter_id=M55369C00100
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    filepath=${pm_counters}

    Verify If Pm Counter Does Not Exist
    ...    counter_id=M55369C00101
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    filepath=${pm_counters}

    Verify If Pm Counter Does Not Exist
    ...    counter_id=M55369C00200
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    filepath=${pm_counters}

    Verify If Pm Counter Does Not Exist
    ...    counter_id=M55369C00201
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    filepath=${pm_counters}

    Configure  ${CURDIR}/config/activating_rtwp_counters.yaml
    Wait for next full pm interval

    Collect BIP logs  alias=low_traffic  duration=1s
    Collect and verify RTWP PM counters for low traffic
    Increase SA traffic  ue=51  dir=ul  traffic_rate=100Mbps  pdu=1
    Wait for next full pm interval
    Collect BIP logs  alias=high_traffic  duration=1s
    Collect and verify RTWP PM counters for high traffic
    Convert BIP logs  alias=low_traffic
    Convert BIP logs  alias=high_traffic

    [Teardown]  Run keywords
    ...    Deregister UE  UE_ID=51
    ...    AND    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Keywords ***
Collect and verify RTWP PM counters for low traffic
    ${pm_counters_low_traffic}=  Wait for next pm interval and get counters
    Verify group of counters  gnb_counters=${pm_counters_low_traffic}  expected_value=-69  margin=5  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    Get counters value and report to rp  counters=${counters}  filepath=${pm_counters_low_traffic}  localmoid=NRCELL-3

Collect and verify RTWP PM counters for high traffic
    ${pm_counters_high_traffic}=  Wait for next pm interval and get counters
    Verify group of counters  gnb_counters=${pm_counters_high_traffic}  expected_value=-63  margin=5  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    Get counters value and report to rp  counters=${counters}  filepath=${pm_counters_high_traffic}  localmoid=NRCELL-3

Change AP noise
    Connect using ssh to    AP
    Modify AP swconfig file    parameters_list=@{AP_noise}    connection=AP
    Reboot AP
    Wait for testline ICMP Echo replies and SSH services
    Check radios availability

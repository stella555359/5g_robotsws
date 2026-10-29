*** Settings ***
Documentation
...   author: Adrianna Pienkowska, Jacek Kozmic, Agata Sidlo
...   contact: adrianna.pienkowska@nokia.com, jacek.kozmic@nokia.com, agata.sidlo@nokia.com
...   description: Krakow Verification Engineering team testcases for CB008746 feature

Resource    resources/common.robot
Resource    ../resources/common_configuration.robot

Variables    resources/variables.py
Variables    resources/delta_setups.py
Variables    resources/validation_dicts.py

Suite Setup      Suite Setup 8746
Test Teardown    Run Keywords    Send Configuration ID To Scout
    ...    AND    Test Teardown 8746

*** Test Cases ***
CB008746-A_B105_Slice_aware_scheduler_check_quotas_for_NSA_only_FDD
    [Setup]    Test Setup 8746
    ...    tc=A_B105_CHECK_QUOTAS_FDD
    ...    test_cell_tech=FDD
    counters__.Create Counter List
    ...    ${DL_PRB_COUNTERS}
    c_p.Prepare Resource Group Parameters Variable
    ...    ${DELTA_DYN_KEYS_A_B105_003_VALIDATION}
    common.Activate Feature And Start Basic Logs
    ...    delta=${DELTA_A_B105_003_FDD}
    ...    delta_setup=${DELTA_DYN_KEYS_A_B105_003}
    ...    wts=${WTS_3_UE_1_PLMN_FDD}
    common.Attach Multiple Ues To Plmns And Start Traffic
    ...    nr_ues=3
    ...    spid=${UE_SPID_VALUES_A_B105_003}
    ...    plmn=${THREE_UES_PLMNS_A_B105_003}
    ...    dl_mbps=${TPUT_105_003}
    ...    cell_id=${CELL_1_ID}
    common.SYSCOM Stop
    common__.Wait For Counters To Update
    wts__.Stop Data Traffic For Multiple Ues
    ...    number_of_ues=3
    ...    traffic_direction=dl
    ...    first_ue_id=11
    ...    net_arch=nsa
    ...    dl_mbps=${TPUT_105_003}
    common.SYSLOG Stop
    counters__.Collect Counters Values
    c_v.Counter C Validation
    ...    ts_margin=${UTILIZATION_MARGIN}
    ...    counter_utilization_margin=10
    Validate Bip UserSetupReq ResourceGroupId
    ...    ues=${THREE_UES_ID}
    ...    expected_nrg_ids=${EXPECTED_NRG_IDS_A_B105_003}
    Validate UE Context Setup
    ...    expected_spid_values=${UE_SPID_VALUES_A_B105_003}
    suite__.Set Tc Status To Passed
    ...    tc=A_B105_CHECK_QUOTAS_FDD


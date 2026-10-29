*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    ../resources/common_configuration.robot
Resource    CB008250_keywords.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.config.wts       WITH NAME    wts
Library     keywords_CB008250.py
Documentation
...    author: Pawel Konieczny
...    maintainer:
...    testline:
...    release:

Suite Setup    Enable Syslog Info Level Prints

Test Setup      Run Keywords    Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...              cfg_filepath_tdd_fdd=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...       AND    Change Tdd Cells To 50 Mhz
    ...       AND    Disable Actrat1alloc
    ...       AND    Set Minrcellutilperplmn And Nrg To 5min
    ...       AND    Enable Slice Aware Scheduler
    ...       AND    Enable Plmn Aware Scheduler
    ...       AND    Enable Actslicenumext
    ...       AND    Enable Plmn Spid And Resource Groups
    ...       AND    Wait For Next Full Pm Interval
Test Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs
    ...       AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
CB008250-AA_And_AB_EC2_Alt1_One_Empty_Plmn
    Register 4 Ues Per Plmn Except Plmn3
    Start High Dl And Ul Data Traffic For 3 PLMN
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Cell Statistics
    Wait For Next Full Pm Interval
    Check If Resource Groups Have Incremented Pm Counters
    Check If Plmn Pm Counters Were Incremented For All Plmns Except One Without Traffic
    Wait For Next Full Pm Interval
    Check If Plmn1 Achieved Set Target Share 50% For Ul And Dl
    Enable Allow Plmn To Share Resources
    Wait Enough Time So Next Checked Packet Will Have Whole Interval After Enable Allow Plmn To Share Resources
    Display Cell Statistics
    Check If Resource Groups Have Incremented Pm Counters
    Check If Plmn Pm Counters Were Incremented For All Plmns Except One Without Traffic
    Check If With Allow Plmn To Share Resources And Empty Plmn3 Plmn1 Achieved Bigger Share Than 50% For Ul And Dl

*** Keywords ***
Display Cell Statistics
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Check If Plmn1 Achieved Set Target Share 50% For Ul And Dl
    Check If Values Of Counters Covers Set Target Share
    Check If Values Of Counters Covers Set Target Share    pm_counter_numerator=${COUNTER_ID_PRB_USED_PDSCH_PLMN}
    ...    pm_counter_denumerator=${COUNTER_ID_DL_PRB_UTIL_RATIO_DNOM_PLMN}

Check If With Allow Plmn To Share Resources And Empty Plmn3 Plmn1 Achieved Bigger Share Than 50% For Ul And Dl
    Check If Values Of Counters Have Bigger Target Share
    Check If Values Of Counters Have Bigger Target Share    pm_counter_numerator=${COUNTER_ID_PRB_USED_PDSCH_PLMN}
    ...    pm_counter_denumerator=${COUNTER_ID_DL_PRB_UTIL_RATIO_DNOM_PLMN}

Check If Plmn Pm Counters Were Incremented For All Plmns Except One Without Traffic
    Check If Plmn Pm Counters Have Incremented Values    MCC=311    MNC=489
    Check If Plmn Pm Counters Have Incremented Values    MCC=555    MNC=10
    Check If Plmn Pm Counters Have Not Incremented Values    MCC=450    MNC=06
    Check If Plmn Pm Counters Have Incremented Values    MCC=450    MNC=05

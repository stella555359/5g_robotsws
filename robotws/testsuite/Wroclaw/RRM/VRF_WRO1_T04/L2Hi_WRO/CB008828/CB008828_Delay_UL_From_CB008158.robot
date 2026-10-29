*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    ../CB008158_NR_Latency_PM_Counters/keywords_CB008158.robot
Resource    keywords_CB008828.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ../resources/pm_counters_validator.py
Library     ta5g_pm_counters
Library     ../CB008158_NR_Latency_PM_Counters/keywords_CB008158.py
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.config.wts       WITH NAME    wts
Variables     CB008828_variables.py

Documentation
...    author: Paweł Konieczny
...    maintainer: Paweł Konieczny (Pawel.konieczny@nokia.com)
...    release: 24R2

Suite Setup     Run Keywords    Enable Syslog Info Level Prints
    ...       AND    Enable Actslicenumext
    ...       AND    Enable 25 Snssai Objects
    ...       AND    Configure Additional Slices In Cfg
    ...       AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...       AND    Configure VM interfaces For Second Gnb
    ...       AND    Choose Lue File Based On Detected Configuration And Reach Onair
    ...              lua_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              lua_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...       AND    Set Internal Traffic Type To UEs
    ...       AND    Disable Uplane Ciphering
    ...       AND    Prepare Bler Testmode In Ul
    ...       AND    Set tReorderingUl To 3000ms PDCP 2 Profile
    ...       AND    Enable Latency Pm Counters
    ...       AND    Enable Pmqap Sa 5qi6 Nsa Qci6
    ...       AND    Wait For Next Full Pm Interval

Test Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs
    ...       AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   240s

*** Test Cases ***
CB008828_Average_PDCP_re-ordering_delay_in_the_UL_with_PMQAP_and_SA_UE
    Register Ue With Default Pdu Session
    Activate Bler Testmode    ue_id=1    scell=0
    Start 180Mbps In Ul And Wait For Traffic Ends
    Display Qfi Stats    qfi_id=1
    Deactivate Bler Testmode    ue_id=1    scell=0
    Check If Cell And Pmqap Ul Delay Has Expected Value    expected_ul_delay=520    margin=25%
    Start 180Mbps In Ul And Wait For Traffic Ends
    Display Qfi Stats    qfi_id=1
    Deregister Ue   ue_id=1
    Check If Cell And Pmqap Ul Delay Has Expected Value    expected_ul_delay=0.00055    margin=25%

*** Keywords ***
Start 180Mbps In Ul And Wait For Traffic Ends
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=90 seconds=${TRAFFIC_DURATION_SEC}
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=90 trf_id=2 seconds=${TRAFFIC_DURATION_SEC}
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}

Start 60Mbps In Ul And Wait For Traffic Ends
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=ul mbps=60 seconds=${TRAFFIC_DURATION_SEC}
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}

Prepare Bler Testmode In Ul
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 ul_bler=10,10,0,0,0,0,0,0

Set tReorderingUl To 3000ms PDCP 2 Profile
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_tReorderingUl_set_to_3000ms_PDCP_2.json

Check Ul Data Traffic On Mcg And Scg Leg
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2 dir=ul dc_cell_group=mcg
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2 dir=ul dc_cell_group=scg

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
    ...       AND    Prepare Bler Testmode In Dl
    ...       AND    Disable Uplane Ciphering
    ...       AND    Enable Latency Pm Counters
    ...       AND    Enable Pmqap Sa 5qi6 Nsa Qci6
    ...       AND    Wait For Next Full Pm Interval

Test Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs
    ...       AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   240s

*** Test Cases ***
CB008828_Average_DL_PDCP_SDU_delay_in_CU-UP_with_PMQAP_and_SA_UE
    Register Ue With Default Pdu Session
    Activate Bler Testmode    ue_id=1    scell=0
    Start 450Mbps In Dl
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Display Qfi Stats    qfi_id=1
    Deactivate Bler Testmode    ue_id=1    scell=0
    Check If Cell And Pmqap Dl Delay Has Expected Value    cell_id=1    expected_dl_delay=4000    margin=25%
    Start 450Mbps In Dl
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Display Qfi Stats    qfi_id=1
    Deregister Ue    ue_id=1
    Check If Cell And Pmqap Dl Delay Has Expected Value    cell_id=1    expected_dl_delay=0.038    margin=25%

*** Keywords ***
Start 450Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 seconds=${TRAFFIC_DURATION_SEC}
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2 seconds=${TRAFFIC_DURATION_SEC}
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3 seconds=${TRAFFIC_DURATION_SEC}

Start 10Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Acitvate Bler Testmode    ue_id=11    scell=8
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=10

Activate Aes Uplane Ciphering
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Ciphering/delta_enable_aes.json

Prepare Bler Testmode In Dl
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 target_mcs=3 num_dl_pkts=1000

Check Dl GTP Delay Counters
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_GTP_PKT_F1_DLY}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_GTP_PKT_F1_DLY_PMQAP}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}

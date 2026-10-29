*** Settings ***
Documentation    TMO Automation for KPI test cases
...              Author: jasper.jiao@nokia.com
Suite Setup    UUF_Common_Suite_Setup
Test Teardown    Run Keywords    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
                 ...    run keyword and ignore error    Collect Snapshot Log in gnb and enb    timeout=${2400}
                 ...    AND    Run Keyword And Continue On Failure    Common_setup_and_teardown.Common Suite Setup
                 ...   scf_name=${tl_prefix}_KPI_Testing_${stream_version}.xml    is_commission=True
                 ...                                                    timeout_for_commission=20 min
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot

*** Test Cases ***
5603661_SA_PCELL_N41_NON-CA
    [Tags]    T077
    [Setup]    TMO_Common_Case_Setup_SISO    is_commission=True    scf_name=${tl_prefix}_KPI_Testing_${stream_version}.xml
    Sleep    20s    Wait for error log disappear after cell onair!
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${notBarred_cell_list}    Create List    301
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${notBarred_cell_list}
    ...    connection=GNB_OAM    timeout=300
    Sleep    10s
    Initial UEs of T077
    Sleep    15min
    Log to console    perform KPI test
    Sleep    60min
    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs    log_type=-o l2ps -C 301 -e -s
    ...                             bbmod_slots=1                                 duration=180
    Run Keyword And Ignore Error     Get Captured Mixed File
    Sleep    30min
    Log to console    sleep 30mins to wait KPI report sync on scout
    Sleep    30min

5603662_SA_PCELL_N25_NON-CA
    [Tags]    T077
    [Setup]    TMO_Common_Case_Setup_SISO    is_commission=True    scf_name=${tl_prefix}_KPI_Testing_${stream_version}.xm
    Sleep    20s    Wait for error log disappear after cell onair!
    Log to console    perform LTEcell lock
    Lock Or Unlock Single Cell    cell_index=11   cell_type=lte    action=lock
    Sleep    10s
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${notBarred_cell_list}    Create List    21
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${notBarred_cell_list}
    ...    connection=GNB_OAM    timeout=300
    Sleep    10s
    Initial UEs of T077
    Sleep    15min
    Log to console    perform KPI test
    Sleep    60min
    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs    log_type=-o l2ps -C 21 -e -s    bbmod_slots=3
    ...                                                               duration=180
    Run Keyword And Ignore Error     Get Captured Mixed File
    Sleep    30min
    Log to console    sleep 30mins to wait KPI report sync on scout
    Sleep    30min
    Log to console    perform LTEcell unlock
    Lock Or Unlock Single Cell    cell_index=11   cell_type=lte    action=unlock
    Sleep    10s

5603663_SA_PCELL_N71_NON-CA
    [Tags]    T077
    [Setup]    TMO_Common_Case_Setup_SISO    is_commission=True    scf_name=${tl_prefix}_KPI_Testing_${stream_version}.xml
    Sleep    20s    Wait for error log disappear after cell onair!
    Lock Or Unlock Single Cell    cell_index=61   cell_type=lte    action=lock
    Sleep    10s
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${notBarred_cell_list}    Create List    1
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${notBarred_cell_list}
    ...    connection=GNB_OAM    timeout=300
    Sleep    10s
    Initial UEs of T077
    Sleep    15min
    Log to console    perform KPI test
    Sleep    60min
    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs    log_type=-o l2ps -C 1 -e -s    bbmod_slots=2
    ...                                                               duration=180
    Run Keyword And Ignore Error     Get Captured Mixed File
    Sleep    30min
    Log to console    sleep 30mins to wait KPI report sync on scout
    Sleep    30min
    Log to console    perform LTEcell unlock
    Lock Or Unlock Single Cell    cell_index=61   cell_type=lte    action=unlock
    Sleep    10s

5603664_SA_PCELL_N41_CA
    [Tags]    T073
    [Setup]    TMO_Common_Case_Setup_SISO    is_commission=True    scf_name=${tl_prefix}_KPI_Testing_${stream_version}.xml
    Sleep    20s    Wait for error log disappear after cell onair!
    Log to console    perform GSMcell lock
    Lock Or Unlock Single Cell    cell_index=3   cell_type=gsm    action=block
    Sleep    10s
    Log to console    perform LTEcell lock
    Lock Or Unlock Single Cell    cell_index=63   cell_type=lte    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=13   cell_type=lte    action=lock
    Sleep    10s
    Log to console    perform NRcell lock
    Lock Or Unlock Single Cell    cell_index=43   cell_type=nr    action=lock
    Sleep    10s
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${notBarred_cell_list}    Create List    303
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${notBarred_cell_list}
    ...    connection=GNB_OAM    timeout=300
    Sleep    10s
    Initial UEs of T073
    Sleep    15min
    Log to console    perform KPI test
    Sleep    60min
    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs    log_type=-o l2ps -C 23,303,313,3 -e -s
    ...                             bbmod_slots=5,1,6                                 duration=120
    Run Keyword And Ignore Error     Get Captured Mixed File
    Sleep    30min
    Log to console    sleep 20mins to wait KPI report sync on scout
    Sleep    20min
    Log to console    perform GSMcell unock
    Lock Or Unlock Single Cell    cell_index=3   cell_type=gsm    action=unblock
    Sleep    10s
    Log to console    perform LTEcell unlock
    Lock Or Unlock Single Cell    cell_index=63   cell_type=lte    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=13   cell_type=lte    action=unlock
    Sleep    10s
    Log to console    perform NRcell unock
    Lock Or Unlock Single Cell    cell_index=43   cell_type=nr    action=unlock
    Sleep    10s

5603664_SA_PCELL_N41_CA_TL77
    [Tags]    T077
    [Setup]    TMO_Common_Case_Setup_SISO    is_commission=True    scf_name=${tl_prefix}_KPI_Testing_${stream_version}.xml
    Log to console    perform LTEcell lock
    Lock Or Unlock Single Cell    cell_index=61   cell_type=lte    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=11   cell_type=lte    action=lock
    Sleep    10s
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${notBarred_cell_list}    Create List    301
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${notBarred_cell_list}
    ...    connection=GNB_OAM    timeout=300
    Sleep    10s
    Initial UEs of T077
    Sleep    15min
    Log to console    perform KPI test
    Sleep    60min
    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs    log_type=-o l2ps -C 21,301,311,1 -e -s
    ...                             bbmod_slots=1,2,3                                 duration=120
    Run Keyword And Ignore Error     Get Captured Mixed File
    Sleep    30min
    Log to console    sleep 30mins to wait KPI report sync on scout
    Sleep    30min
    Log to console    perform LTEcell unlock
    Lock Or Unlock Single Cell    cell_index=61   cell_type=lte    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=11   cell_type=lte    action=unlock
    Sleep    10s

5603665_SA_PCELL_N25_CA
    [Tags]    T073
    [Setup]    TMO_Common_Case_Setup_SISO    is_commission=True    scf_name=${tl_prefix}_KPI_Testing_${stream_version}.xml
    Sleep    20s    Wait for error log disappear after cell onair!
    Log to console    perform GSMcell lock
    Lock Or Unlock Single Cell    cell_index=3   cell_type=gsm    action=block
    Sleep    10s
    Log to console    perform LTEcell lock
    Lock Or Unlock Single Cell    cell_index=63   cell_type=lte    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=13   cell_type=lte    action=lock
    Sleep    10s
    Log to console    perform NRcell lock
    Lock Or Unlock Single Cell    cell_index=43   cell_type=nr    action=lock
    Sleep    10s
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${notBarred_cell_list}    Create List    23
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${notBarred_cell_list}
    ...    connection=GNB_OAM    timeout=300
    Sleep    10s
    Initial UEs of T073
    Sleep    15min
    Log to console    perform KPI test
    Sleep    60min
    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs    log_type=-o l2ps -C 23,303,313,3 -e -s
    ...                             bbmod_slots=5,1,6                                 duration=120
    Run Keyword And Ignore Error     Get Captured Mixed File
    Sleep    30min
    Log to console    sleep 20mins to wait KPI report sync on scout
    Sleep    20min
    Log to console    perform GSMcell unock
    Lock Or Unlock Single Cell    cell_index=3   cell_type=gsm    action=unblock
    Sleep    10s
    Log to console    perform LTEcell unlock
    Lock Or Unlock Single Cell    cell_index=63   cell_type=lte    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=13   cell_type=lte    action=unlock
    Sleep    10s
    Log to console    perform NRcell unock
    Lock Or Unlock Single Cell    cell_index=43   cell_type=nr    action=unlock
    Sleep    10s

5603666_SA_PCELL_N71_CA
    [Tags]    T073
    [Setup]    TMO_Common_Case_Setup_SISO    is_commission=True    scf_name=${tl_prefix}_KPI_Testing_${stream_version}.xml
    Sleep    20s    Wait for error log disappear after cell onair!
    Log to console    perform GSMcell lock
    Lock Or Unlock Single Cell    cell_index=3   cell_type=gsm    action=block
    Sleep    10s
    Log to console    perform LTEcell lock
    Lock Or Unlock Single Cell    cell_index=63   cell_type=lte    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=13   cell_type=lte    action=lock
    Sleep    10s
    Log to console    perform NRcell lock
    Lock Or Unlock Single Cell    cell_index=43   cell_type=nr    action=lock
    Sleep    10s
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${notBarred_cell_list}    Create List    3
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${notBarred_cell_list}
    ...    connection=GNB_OAM    timeout=300
    Sleep    10s
    Initial UEs of T073
    Sleep    15min
    Log to console    perform KPI test
    Sleep    60min
    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs    log_type=-o l2ps -C 23,303,313,3 -e -s
    ...                             bbmod_slots=5,1,6                                 duration=120
    Run Keyword And Ignore Error     Get Captured Mixed File
    Sleep    30min
    Log to console    sleep 20mins to wait KPI report sync on scout
    Sleep    20min
    Log to console    perform GSMcell unock
    Lock Or Unlock Single Cell    cell_index=3   cell_type=gsm    action=unblock
    Sleep    10s
    Log to console    perform LTEcell unlock
    Lock Or Unlock Single Cell    cell_index=63   cell_type=lte    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=13   cell_type=lte    action=unlock
    Sleep    10s
    Log to console    perform NRcell unock
    Lock Or Unlock Single Cell    cell_index=43   cell_type=nr    action=unlock
    Sleep    10s

5603667_SA_intra_gnb_intra_frequcency_HO_N41
    [Tags]    T073
    [Setup]    TMO_Common_Case_Setup_SISO    is_commission=True    scf_name=${tl_prefix}_KPI_Testing_${stream_version}.xml
    Sleep    20s    Wait for error log disappear after cell onair!
    Log to console    perform GSMcell lock
    Lock Or Unlock Single Cell    cell_index=3   cell_type=gsm    action=block
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=4   cell_type=gsm    action=block
    Sleep    10s
    Log to console    perform LTEcell lock
    Lock Or Unlock Single Cell    cell_index=63   cell_type=lte    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=62   cell_type=lte    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=13   cell_type=lte    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=14   cell_type=lte    action=lock
    Sleep    10s
    Log to console    perform NRcell lock
    Lock Or Unlock Single Cell    cell_index=43   cell_type=nr    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=44   cell_type=nr    action=lock
    Sleep    10s
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${notBarred_cell_list}    Create List    302    303
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${notBarred_cell_list}
    ...    connection=GNB_OAM    timeout=300
    Sleep    10s
    Initial UEs of T073
    Sleep    15min
    Log to console    perform KPI test
    Sleep    60min
    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs    log_type=-o l2ps -C 23,24,302,303,312,313,2,3 -e -s
    ...                             bbmod_slots=5,1,6,7                                  duration=120
    Run Keyword And Ignore Error     Get Captured Mixed File
    Sleep    30min
    Log to console    sleep 20mins to wait KPI report sync on scout
    Sleep    20min
    Log to console    perform GSMcell unock
    Lock Or Unlock Single Cell    cell_index=3   cell_type=gsm    action=unblock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=4   cell_type=gsm    action=unblock
    Sleep    10s
    Log to console    perform LTEcell unlock
    Lock Or Unlock Single Cell    cell_index=63   cell_type=lte    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=62   cell_type=lte    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=13   cell_type=lte    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=14   cell_type=lte    action=unlock
    Sleep    10s
    Log to console    perform NRcell unock
    Lock Or Unlock Single Cell    cell_index=43   cell_type=nr    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=44   cell_type=nr    action=unlock
    Sleep    10s

5603668_SA_intra_gnb_intra_frequcency_HO_N25
    [Tags]    T073
    [Setup]    TMO_Common_Case_Setup_SISO    is_commission=True    scf_name=${tl_prefix}_KPI_Testing_${stream_version}.xml
    Sleep    20s    Wait for error log disappear after cell onair!
    Log to console    perform GSMcell lock
    Lock Or Unlock Single Cell    cell_index=3   cell_type=gsm    action=block
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=4   cell_type=gsm    action=block
    Sleep    10s
    Log to console    perform LTEcell lock
    Lock Or Unlock Single Cell    cell_index=63   cell_type=lte    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=62   cell_type=lte    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=13   cell_type=lte    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=14   cell_type=lte    action=lock
    Sleep    10s
    Log to console    perform NRcell lock
    Lock Or Unlock Single Cell    cell_index=43   cell_type=nr    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=44   cell_type=nr    action=lock
    Sleep    10s
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${notBarred_cell_list}    Create List    23    24
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${notBarred_cell_list}
    ...    connection=GNB_OAM    timeout=300
    Sleep    10s
    Initial UEs of T073
    Sleep    15min
    Log to console    perform KPI test
    Sleep    60min
    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs    log_type=-o l2ps -C 23,24,302,303,312,313,2,3 -e -s
    ...                             bbmod_slots=5,1,6,7                                  duration=120
    Run Keyword And Ignore Error     Get Captured Mixed File
    Sleep    30min
    Log to console    sleep 20mins to wait KPI report sync on scout
    Sleep    20min
    Log to console    perform GSMcell unock
    Lock Or Unlock Single Cell    cell_index=3   cell_type=gsm    action=unblock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=4   cell_type=gsm    action=unblock
    Sleep    10s
    Log to console    perform LTEcell unlock
    Lock Or Unlock Single Cell    cell_index=63   cell_type=lte    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=62   cell_type=lte    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=13   cell_type=lte    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=14   cell_type=lte    action=unlock
    Sleep    10s
    Log to console    perform NRcell unock
    Lock Or Unlock Single Cell    cell_index=43   cell_type=nr    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=44   cell_type=nr    action=unlock
    Sleep    10s

5603669_SA_intra_gnb_intra_frequcency_HO_N71
    [Tags]    T073
    [Setup]    TMO_Common_Case_Setup_SISO    is_commission=True    scf_name=${tl_prefix}_KPI_Testing_${stream_version}.xml
    Sleep    20s    Wait for error log disappear after cell onair!
    Log to console    perform GSMcell lock
    Lock Or Unlock Single Cell    cell_index=3   cell_type=gsm    action=block
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=4   cell_type=gsm    action=block
    Sleep    10s
    Log to console    perform LTEcell lock
    Lock Or Unlock Single Cell    cell_index=63   cell_type=lte    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=62   cell_type=lte    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=13   cell_type=lte    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=14   cell_type=lte    action=lock
    Sleep    10s
    Log to console    perform NRcell lock
    Lock Or Unlock Single Cell    cell_index=43   cell_type=nr    action=lock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=44   cell_type=nr    action=lock
    Sleep    10s
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    ${notBarred_cell_list}    Create List    2    3
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${notBarred_cell_list}
    ...    connection=GNB_OAM    timeout=300
    Sleep    10s
    Initial UEs of T073
    Sleep    15min
    Log to console    perform KPI test
    Sleep    60min
    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs    log_type=-o l2ps -C 23,24,302,303,312,313,2,3 -e -s
    ...                             bbmod_slots=5,1,6,7                                  duration=120
    Run Keyword And Ignore Error     Get Captured Mixed File
    Sleep    30min
    Log to console    sleep 20mins to wait KPI report sync on scout
    Sleep    20min
    Log to console    perform GSMcell unock
    Lock Or Unlock Single Cell    cell_index=3   cell_type=gsm    action=unblock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=4   cell_type=gsm    action=unblock
    Sleep    10s
    Log to console    perform LTEcell unlock
    Lock Or Unlock Single Cell    cell_index=63   cell_type=lte    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=62   cell_type=lte    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=13   cell_type=lte    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=14   cell_type=lte    action=unlock
    Sleep    10s
    Log to console    perform NRcell unock
    Lock Or Unlock Single Cell    cell_index=43   cell_type=nr    action=unlock
    Sleep    10s
    Lock Or Unlock Single Cell    cell_index=44   cell_type=nr    action=unlock
    Sleep    10s
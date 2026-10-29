*** Settings ***
Documentation
...    Feature 5GC001167 introduces intra-DU inter/intra-band (contiguous and non-contiguous) carrier aggregation in SA mode
...    between FDD cell as PCell and  up to two FDD DL only SCells.
...    The procedure of SCell addition is performed after the initial context setup or after successful handover.
...    Both the PCell and the SCell(s) are mapped to different 5G-L2-RT instance

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LPQ_AP_LOO
Metadata    variant    SANSA_FS_ECPRI_CMWV_FDD+TDD_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50

Variables    ${RESOURCES}/dist_names.py

Resource    ../../resources/main_resources.robot
Resource    ../../../resources/iphy/iphy.resource

# -- Setup / Teardown
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/5GC001167.resources
${LUA}    ${RESOURCES}/epc_sim.cfg
${SCFC}    ${RESOURCES}/scf.xml
${IPHY}    ${RESOURCES}/iphy.xml
${UE_ID}    ${1}
${timeout}    ${1800}
${NUMBER_OF_RMODS}    ${3}
${DATA_TRAFFIC_VOLUME_MBPS_DL}    ${150}
${DATA_TRAFFIC_VOLUME_MBPS_UL}    ${50}
${counter_ids}    M55118C07001,M55323C01006,M55323C03006
${M55118C07001_VALUE}    ${60}
${M55323C01006_VALUE}    ${140}
${M55323C03006_VALUE}    ${45}


*** Test Cases ***
5GC001167_CA_n2A-n5A-n66A_3CC_Carrier_aggregation_L3_call
    [Documentation]
    ...    This test case verifies the successful blind SCell addition for FDD 3CC inter-band.
    [Setup]    [PRE]5GC001167_CA_n2A-n5A-n66A_3CC_Carrier_aggregation_L3_call
    [Teardown]    [POST]5GC001167_CA_n2A-n5A-n66A_3CC_Carrier_aggregation_L3_call

    Attach and setup PDU for UE
    Start DL and UL traffic for UE
    Get PM counters
    Verify if 3CC interband was added correctly
    Verify DL and UL throughput for UE using PM counters


*** Keywords ***
[PRE]5GC001167_CA_n2A-n5A-n66A_3CC_Carrier_aggregation_L3_call
    Add Flag To Swconfig    0x340000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Add Flag To Swconfig    0x9D0000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Apply Iphy Configuration    ${IPHY}
    Perform Commissioning    scfc_path=${SCFC}
    Check if BTS is correctly configured    ${NUMBER_OF_RMODS}    ${timeout}
    Start WTS    ${LUA}    check_version=False
    Check if BTS is OnAir
    Wait for counters generation to be started

[POST]5GC001167_CA_n2A-n5A-n66A_3CC_Carrier_aggregation_L3_call
    Report miscellaneous KPIs
    SA 5G Detach UE"${UE_ID}"
    Stop WTS

# -- test steps --
Attach and setup PDU for UE
    [Tags]    DESIGNSTEP
    SA 5G Attach UE"${UE_ID}"
    SA Set Traffic Type For PDU"1" UE"${UE_ID}"
    SA Setup Primary PDU Session For PDU"1" UE"${UE_ID}" GW"1" NWSLICE"1"
    Sleep    5s

Start DL and UL traffic for UE
    [Tags]    DESIGNSTEP
    SA Start Traffic In SA Mode    pdu=${UE_ID}    ue=${UE_ID}    qfi=1    dir=dl    mbps=${DATA_TRAFFIC_VOLUME_MBPS_DL}
    SA Verify If Throughput Is Started    ue=${UE_ID}    pdu=${UE_ID}    qfi=1    dir=dl
    SA Start Traffic In SA Mode    pdu=${UE_ID}    ue=${UE_ID}    qfi=1    dir=ul    mbps=${DATA_TRAFFIC_VOLUME_MBPS_UL}
    SA Verify If Throughput Is Started    ue=${UE_ID}    pdu=${UE_ID}    qfi=1    dir=ul
    SLEEP    12 minutes    reason=Generating traffic

Get PM counters
    [Tags]    DESIGNSTEP
    SLEEP    60    reason=Wait for generating at least one PM counter
    ${connection}=    Set Variable    get_pm_counters
    ${log_path}=    Prepare Logs Directory Path    admin_logs/${connection}
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_path}    name=${connection}
    ${counters_info}=    admin.get_pm_counters    counter_ids=${counter_ids}    connection=${connection}
    SET SUITE VARIABLE    ${COUNTERS_INFO}    ${counters_info}

Verify if 3CC interband was added correctly
    [Tags]    DESIGNSTEP
    RUN KEYWORD AND CONTINUE ON FAILURE    Verify M55118C07001 counter


Verify DL and UL throughput for UE using PM counters
    [Tags]    DESIGNSTEP
    RUN KEYWORD AND CONTINUE ON FAILURE    Verify M55323C01006 counter
    RUN KEYWORD AND CONTINUE ON FAILURE    Verify M55323C03006 counter

# -- internals --
Wait for counters generation to be started
    comment    Waiting for distName creation for the counter (BTS/CELLS/NRCELL-1/NCAC/M55118C07001)
    Wait Until Keyword Succeeds    20x    15s    Get PM Counter "${M55118C07001_PATH}" Measurements

Verify M55118C07001 counter
    ${actual_value}=    pm_counter.get_avg_pm_counter_value    ${COUNTERS_INFO}    ${M55118C07001_PATH}   ${10}
    ${error_msg}=    Catenate
    ...    Sum of CA UEs in the current cell configured as PCell with 2 configured SCells in DL didn't meet expected amount.
    ...    Was: "${actual_value}", expected: "${M55118C07001_VALUE}".
    SHOULD BE TRUE    ${actual_value} == ${M55118C07001_VALUE}
    ...    msg=${error_msg}

Verify M55323C01006 counter
    ${actual_value}=    pm_counter.get_avg_pm_counter_value    ${COUNTERS_INFO}    ${M55323C01006_PATH}   ${10}
    ${avg_tput_mbps}=    EVALUATE    ${actual_value} * 8 / 1000 / 60
    ${error_msg}=    Catenate
    ...    DL Throughput less than expected
    ...    Was: "${avg_tput_mbps}", expected: "${M55323C01006_VALUE}".
    SHOULD BE TRUE    ${avg_tput_mbps} >= ${M55323C01006_VALUE}
    ...    msg=${error_msg}

Verify M55323C03006 counter
    ${actual_value}=    pm_counter.get_avg_pm_counter_value    ${COUNTERS_INFO}    ${M55323C03006_PATH}   ${10}
    ${avg_tput_mbps}=    EVALUATE    ${actual_value} * 8 / 1000 / 60
    ${error_msg}=    Catenate
    ...    UL Throughput less than expected
    ...    Was: "${avg_tput_mbps}", expected: "${M55323C03006_VALUE}".
    SHOULD BE TRUE    ${avg_tput_mbps} >= ${M55323C03006_VALUE}
    ...    msg=${error_msg}

*** Settings ***
Force Tags    CLOUD_ASOH_CUS    CRT    RAN_4G    SBTS00

Documentation
...
...      author:            Kshitij
...      maintainer:        Kshitij
...
...      INTRODUCTION:    : The purpose of this test is to verify that relevant parameters can be modified online
...                         successfully.
...                         UE may get good throughput where "actLdPdcch" is true compared to false when
...                         "maxNrSymPdcch" is greater than 1.


Resource          resources/DevHZ5_resource.robot
Library           resources/CB010869.py
Library           ta_emss
Resource          resources/DevHZ5_startup.robot
Library     String
Library     DateTime
Library     OperatingSystem
Library     taf.config.scf               WITH NAME    scf
Library     taf.collectors.pmcounters    WITH NAME    collect_pm
Library     taf.converters.pmtocsv       WITH NAME    pmtocsv
Library     taf.analyzer.pmcounter       WITH NAME    check_pm
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library          ta5g_pm_counters
Library          taf.sw.scout    WITH NAME     scout
Resource         testsuite/Bangalore/RRM/5GET_BLR/resources/robot/PM_Counters.robot

Suite Setup       Run Keywords
...               Test setup
...               Perform full commissioning
...               Common Suite Teardown
...               Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown

*** Variables ***
@{PARAMS_IN_SWCONFIG}
...    ${TEnbcRadLowLoadSwitchOffDelay}=3       # *10 secs shortening load measurement windows from 300/120 s to 30/30 s
...    ${TEnbcRadHighLoadSwitchOnDelay}=3     # *10 secs
${TEnbcRadLowLoadSwitchOffDelay}    0x110016    # *10 secs
${TEnbcRadHighLoadSwitchOnDelay}    0x110017    # *10 secs
${BTS_ADDRESS}    192.168.255.129
${BTS_PORT}       443
${USE_SSL}        True
${scfc}=    ${CURDIR}/resources/configuration_file/trunk/CLOUD_ASOH_CUS/14007TDD/SCFC_1.xml
${delta_update}=    ${CURDIR}/config/SBTS26R3/CB014007.json


*** Test Cases ***
[1][1.0] CB014007_TC7_LTE939
    [Tags]
    Attach ue and pump data
    ${ue1_tput}=  Store Throughput For Ue  ue_id=1  direction=dl  unit=Mbps
    Perform recommissioning with created delta
    ${ue2_tput}=  Store Throughput For Ue  ue_id=1  direction=dl  unit=Mbps
    Validate Throughput    ${ue1_tput}    ${ue2_tput}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=14007TDD    cfg=cus.yaml


Attach ue and pump data
    Log To Console    -------- Step 1 --------
    execute uex command    ue_attach id=1,2 cell=1
    execute uex command    ue_attach id=3,4 cell=2
    execute uex command    ue_attach id=5,6 cell=3
    execute uex command    trf_data_start ue=1..6 qci=9 Mbps=50 dir=dl protocol=udp size=1400 trf_id=1 interval=500

Perform full commissioning
    admin.Perform commissioning    bts_id=1    scf_file=${scfc}    skip_parameter_relation_errors=True

Test setup
    admin.Setup admin    bts_host=${BTS_ADDRESS}
    ...            bts_port=${BTS_PORT}
    ...            use_ssl=${USE_SSL}


    ${mrbts_id}=        admin.Get id for current    BTS
    ${mrbts_params}=    admin.Get parameters for    BTS    ${mrbts_id}
    Set suite variable    ${MRBTS}    ${mrbts_params}

Perform recommissioning with created delta
    Log To Console    -------- Step 2 --------
    Log To Console    --Performing Recommissioning--
    admin.Perform delta recommissioning    ${delta_update}    skip_parameter_relation_errors=True

Store Throughput For Ue
    [Arguments]  ${ue_id}  ${direction}  ${unit}
    ${ue_stats}=  Run UEx command  get_ue_stats  id=${ue_id}  type=${direction}_rlc  unit=${unit}
    ${tputs_ue}=  Get From Dictionary   ${ue_stats}  UE
    ${tputs_overall}=  Get From Dictionary   ${tputs_ue}  Overall
    ${tput_cur}=  Get From Dictionary  ${tputs_overall}  cur
    Log to console  UE ${ue_id} ${direction} current Tput: ${tput_cur} ${unit}
    [Return]  ${tput_cur}

Validate Throughput
    [Arguments]  ${tput_1}    ${tput_2}
    Should be true    ${tput_2} > ${tput_1}

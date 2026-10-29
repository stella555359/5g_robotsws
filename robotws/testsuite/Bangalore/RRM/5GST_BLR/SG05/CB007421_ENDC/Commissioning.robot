*** Settings ***
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.ccs.aashell      WITH NAME      cli
Library    Collections
Library    DateTime
Library    BuiltIn
Library    OperatingSystem     WITH NAME    os
Resource   testsuite/Bangalore/RRM/5GST_BLR/SG05/CB007421_ENDC/config_id_reporting_keyword.robot
Resource   testsuite/Bangalore/RRM/5GST_BLR/SG05/CB007421_ENDC/test.robot
Library    taf.sbts.oam.coam.admin
Library    ta5g_pm_counters
Library    testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ue
Library    taf.sw.scout    WITH NAME    scout

Suite Setup    Test setup
Suite Teardown    Test Teardown

Force Tags        CA_RAN_PZ_BLR    SBTS00    QCD_MN_RAN    QCP_RAN_VRF    PY39    CRT

*** Variables ***
@{UE_alias}=    UE_1
@{capabilities}=    REAL_UE
@{direction_dl}=    dl
@{deviation_dl}=    50
@{throughput_dl}=    250
@{direction_ul}=    ul
@{deviation_ul}=    50
@{throughput_ul}=    104
@{packet_size}=    1024B
@{bandwidth}=     200Mbits/sec
@{data_transfer_protocol}=    TCP
${Acceptable_Peak_tp_DL}=     245
${Acceptable_Peak_tp_UL}=     104
${Call_Generator}       UC
${ABSTRACT_LIB_CONFIG}=    /home/ute/robotws/config/Bangalore/IAV_BLR_TL252/ue_config.yml
&{[1][1.0] NSA Single UE NR DL throughput, FDD FR1, 20MHz, L1}       QC_ID_FL00=QC_31440
&{[1][1.0] NSA Single UE NR UL throughput, FDD FR1, 20MHz, L1}       QC_ID_FL00=QC_31439
${BTS_ADDRESS}    192.168.255.1
${BTS_PORT}       443
${USE_SSL}        True

${OUT_LOG_PATH}=      /home/ute/robotws/testsuite/Bangalore/RRM/5GST_BLR/SG05/CB007421_ENDC/Logs
${SCF_PATH}=    /home/ute/robotws/testsuite/Bangalore/RRM/5GST_BLR/SG05/CB007421_ENDC/SCF


*** Test Cases ***

[1][1.0]_NSA_Single_UE_NR_DL_throughput,_FDD_FR1,_20MHz,_L1
    [Tags]    iphy    SBTS00    5G_FDD    PY36    QCD_MN_SRAN    QCP_SRAN_SBTS   QCD_MN_RAN   QCP_RAN_ST
    [Setup]  Run Keywords    Set QC_Tag
    coam.perform_commissioning   252    ${SCF_PATH}/MRBTS-252_ASOE_DL_UL.xml  
	...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    alias=default
    sleep   100
    Start DCAP log
    BuiltIn.Sleep    5m
    log to console    Attaching!
    ue.require UE    ${UE_alias}    ${capabilities}
	ue.Detach UE     ue_alias=${UE_alias}
	BuiltIn.Sleep    5s
	ue.Attach UE     ue_alias=${UE_alias}
	BuiltIn.Sleep    30s
    ue.start_datatransfer    ${UE_alias}    ${data_transfer_protocol}     ${direction_dl}
	BuiltIn.Sleep    180s
    Stop DCAP Log
    dcap.get_results    result_id=${trace_id}    target_dir=/home/ute/logs/test1    timeout=200
    BuiltIn.Sleep    2m
    Link SCOUT SCF to Configuration ID for Reporting

[1][1.0]_NSA_Single_UE_NR_UL_throughput,_FDD_FR1,_20MHz,_L1
    [Tags]    iphy    SBTS00    5G_FDD    PY36    QCD_MN_SRAN    QCP_SRAN_SBTS   QCD_MN_RAN   QCP_RAN_ST
    [Setup]  Run Keywords    Set QC_Tag
    coam.perform_commissioning   252    ${SCF_PATH}/MRBTS-252_ASOE_DL_UL.xml  
	...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    alias=default
    BuiltIn.Sleep   100
    Start DCAP log
    BuiltIn.Sleep    5m
    log to console    Attaching!
    ue.require UE    ${UE_alias}    ${capabilities}
	ue.Detach UE     ue_alias=${UE_alias}
	BuiltIn.Sleep    5s
	ue.Attach UE     ue_alias=${UE_alias}
	BuiltIn.Sleep    20s
    ue.start_datatransfer    ${UE_alias}    ${data_transfer_protocol}     ${direction_ul}
	BuiltIn.Sleep    180s
    Stop DCAP Log
    dcap.get_results    result_id=${trace_id}    target_dir=/home/ute/logs/test1    timeout=200
    Link SCOUT SCF to Configuration ID for Reporting

####################################################################################

*** Keywords ***

Set QC_Tag
    ${QC_ID}=    Set Variable    &{${TEST_NAME}}[QC_ID_FL00]
    Set Tags    ${QC_ID}


Check Cell status
    ${celllist}=    Get Cell List
    ${a}=    Get Length    ${celllist['cells']['lte']}
    FOR    ${I}    IN RANGE    0    ${a}
          log    ${celllist['cells']['lte'][${I}]['status']['availabilityStatus']}
          log    ${celllist['cells']['lte'][${I}]}
          Run Keyword If    '${celllist['cells']['lte'][${I}]['status']['availabilityStatus']}' != 'Online'
    ...    Display Down ${celllist['cells']['lte'][${I}]}
    END

Test setup
    coam.Setup admin  bts_host=${BTS_ADDRESS}  bts_port=${BTS_PORT}  use_ssl=${USE_SSL}  alias=default
    Log To Console    CRT_CB007421_ENDC ${\n}


Test Teardown
    coam.Teardown All Aliases For Admin


Get Alarms from Admin
    coam.setup admin    alias=rss
    ${index}=    Set variable    0
    @{K2}=    Create List    61649    61524    6150    6450    4297    10
    ...    61652    4592    4655    4654    4681    7115    4298    4647    8000
    @{Alarms}=    coam.Get Active Alarms    severity=major    severity=critical    severity=minor    connection=rss
    FOR    ${i}    IN    @{Alarms}
        ${v}=    Set Variable    ${Alarms[${index}]['faultId']}
        ${a}=    Convert To String    ${v}
        Log    ${v}
        List Should Contain Value    ${K2}    ${a}
        Log    ***alada ${index}**
        ${index}=    Evaluate    ${index}+1
    END

###################################################################################################
Download and check PM counters_TC1
    ${Counter_File}=    Wait Until Keyword Succeeds    1min    10s    download_latest_pmcounter    local_path=${OUT_LOG_PATH}/TC1/
	...    source_path=/tmp/
    ...    suffix=gz
    ${C1}=    get_counter_value_from_counter_file    counter_file=${Counter_File}    counter_id=M55350C04001
    ${C2}=    get_counter_value_from_counter_file    counter_file=${Counter_File}    counter_id=M55350C06001

    Run keyword and continue on failure     Should Be True    ${C1}!=0
    Run keyword and continue on failure     Should Be True    ${C2}!=0

    log to console    ${\n}M55350C04001_Max DL PDCP data burst throughput transmitted for the cell on 5G Leg=${C1}
    log to console    M55350C06001_Max DL PDCP data burst throughput transmitted for the cell on LTE Leg=${C2}


Download and check PM counters_TC2
    ${Counter_File}=    Wait Until Keyword Succeeds    1min    10s    download_latest_pmcounter    local_path=${OUT_LOG_PATH}/TC1/
	...    source_path=/tmp/
    ...    suffix=gz
    ${C1}=    get_counter_value_from_counter_file    counter_file=${Counter_File}    counter_id=M55309C12002

    Run keyword and continue on failure     Should Be True    ${C1}!=0

    log to console    ${\n}M55309C12002_Max UL DTCH throughput in MAC layer=${C1}


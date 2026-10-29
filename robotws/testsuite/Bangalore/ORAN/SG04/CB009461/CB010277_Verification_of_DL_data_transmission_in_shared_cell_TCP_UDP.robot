*** Settings ***

Documentation
...   author: Suhas Rajesh
...   contact suhas.rajesh@nokia.com
...   Description: Test Suite for CB010277
...   This purpose of the test case is to verify that both DL and UL can be transmitted in the shared cell.
...   This user scenario also checks that the CRM increases ...   resources quickly enough when the first NR enters the cell.
...   This user scenario also checks that the CRM increases resources quickly enough when the first NR enters the cell


Force Tags      CRT  SBTS24R2    FL00    QCD_MN_RAN   QCP_RAN_ST
...             RAN_5G_TDD__WITH__SBTS00
...             RAN_5G__WITH__SBTS00
...             RAN_5G__WITH__SBTS24R1
...             FT_CB010277

Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog  WITH NAME   btslog
Library    ./testsuite/Bangalore/ORAN/resources/python/Tshark_Validation.py
Library    SSHLibrary
Library    Process
Library    taf.transport.ssh        WITH NAME    ssh
Library        OperatingSystem     WITH NAME    os
Library        String      WITH NAME   str
Library        taf.ue    WITH NAME    ue
Library      testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_uc
#Resource    ./testsuite/Bangalore/ORAN/resources/python/Macro/bts/gnb.robot
Resource    ./testsuite/Bangalore/ORAN/resources/robot/reportingportal_Keywords.robot
#Resource    ./testsuite/Bangalore/ORAN/resources/python/Macro/alarm.robot
Resource    ./testsuite/Bangalore/ORAN/resources/robot/expected_alarm.robot
Library        ute_ue
Library           OperatingSystem
Library           String
Library           Collections
Library           DateTime
#Resource    taf/rfrl/common_resources/common_step/interface.robot
Library    ./testsuite/Bangalore/ORAN/resources/python/SysValidation.py
Library     ./testsuite/Bangalore/ORAN/SG04/resources/LuaHandling.py
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/ca_IWK.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/ca_INTER_RAT.robot
Library     taf.selenium.sbts     WITH NAME    sbts
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
#Library    taf.sw.scout    WITH NAME    scout
Library    taf.collectors.pmcounters    WITH NAME    PM
Library    taf.analyzer.pmcounter    WITH NAME    analyser
#Library    ./testsuite/Bangalore/ORAN/SG04/resources/counter_benchmark.py
#Library    /home/ute/robotws/testsuite/Bangalore/SG01/resources/counter_benchmark.py
Resource          ./testsuite/Bangalore/ORAN/resources/python/Macro/bts/gnb.robot



Test Setup      Test Setup
Test Teardown   Test Teardown

*** Variables ***
${CELL_ID}          1
@{LOG_NAME_LIST}    btslog    snapshot
@{capabilities}    Legacy_2
@{throughput_dl}=   180
#@{throughput_ul}=   40   30
@{dt_name}=   iperf_dl_test
@{UE_alias}=    UE_2
#@{UE_alias1}=  UE_1    UE_1
#@{UE_alias_1}=    UE_1
#@{UE_alias2}=  UE2    UE2
#@{UE_alias_2}=    UE_2
@{direction_dl}=  dl
#@{direction_ul}=  ul
@{duration}=  230s
@{timeout}      180
#@{tcpcalltype}=    TCP    TCP
@{udpcalltype}=    UDP
@{deviation_dl}=  30
#@{deviation_ul}=  20    20
${packet_size}=  1400
${tput}=   170Mbits/sec      100Mbits/sec
${ASP_BOARD_TYPE}     ABIO0
${SCF_PATH}         /home/ute/Downloads
${DELTA_FILE}       ${CURDIR}/resources/Configuration_scf_MRBTS-990.xml
${scf_file1}=        /home/ute/Downloads/NSA/suhas/Configuration_scf_MRBTS-970_970-NSA_20240202-1024_ca_lte_2cc.xml
#${CONFIG_PATH}      /home/ute/testline_configuration_5G/Bangalore/7_2_UTE5GTLBTS9/ta_ue_config.yaml
${port_val_list}     9
${counter_initial_value_1}      M55301C
${ENB_VM_IP}=    10.58.238.71
${GNB_VM_IP}=    10.58.238.71
${host}=   192.168.255.129
${user}=   Nemuadmin
${password}=   nemuuser
${port}=    443
${counter_json_file}    /home/ute/counters/counter_data.json



*** Variables ***
${LTE_CELL_ID}=    0                                 # ID of DSS LTE cell which will be tested
${PHYS_LTE_CELL_ID}                            # Physical ID of tested LTE cells (needed for syscomdump filters)
${NR_CELL_ID}=    2                                  # ID of DSS NR cell which will be tested
${SYSCOMDUMP_FILTER}      ${NONE}              # Filetr used during collecting syscomdump, e.g. -i any msg_id=='0x761b'. Default value: ${NONE}
${LTE_MSISDN}                                  # number for volte call to dial
${BLANKED_PUCCH}                               # Value for blankedPucch
${NR_EXPECTED_DL_TPUT_MBPS}                    # [Mbit/sec] Value of expected throughput in NR DSS cell and LTE anchor cell
${LTE_EXPECTED_DL_TPUT_MBPS}                   # [Mbit/sec] Value of expected throughput in LTE DSS cell


*** Test Cases ***
CB010277_Verification of DL data transmission in shared cell-5GC002063
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
    #[Teardown]    run keywords
    # ...      Set QC_Tag     Test Teardown
    coam.setup_admin
    #Perform the Commissioning
    Step1: Start the LTE call



*** Keywords ***
Perform the Commissioning
    #coam.perform_commissioning    970    scf_file=${scf_file1}    skip_parameter_relation_errors=True    should_activate=True    timeout=600
    #Run Keyword And Continue On Failure      Verify gNB is onAir
    Wait Until Keyword Succeeds    1min    10s    Verify gNB is onAir
#    #taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
#    taf.sbts.oam.coam.admin.Setup Admin    name=admin1
#    ${allowed_alarms}=    Expected_alarm
#    Log To Console    ${allowed_alarms}
#    Watch alarms           allowed_alarms=${allowed_alarms}
#    ...                    interval=10


Test Setup
    [Tags]      4GFDD    CRT    SBTS00    QC_737698   Mark
    btslog.create_btslog_collector
    ...    name=btslog
    ...    log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.set_suite_alias      btslog
    core.start_collectors      names=btslog
    Sleep  10

Test Teardown
    Log to console   --Test teardown--
#    Link SCOUT SCF to Configuration ID for Reporting
    interface.Common step trigger
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog         target_dir=/home/ute/results/
    core.teardown_collectors      names=btslog


Step1: Start the LTE call
    ${start_date}=     Get Current Date
    ta_uc.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_uc.Detach UE    ue_alias=${UE_alias}     #UE detach step
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_uc.Attach UE    ue_alias=${UE_alias}     #UE attach step
    ta_uc.start_data_transfer    ${UE_alias}   ${udpcalltype}    ${direction_dl}
    ta_uc.await_data_transfer_finish    ${UE_alias}    ${direction_dl}
    ...    ${timeout}
    sleep    100
    ${end_date}=      Get Current Date
    Run Keyword and Continue on Failure       ta_uc.calculate_thrughtput        ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}
    ${webservice}=  Create Dictionary
    ...  host=${host}
    ...  user=${user}
    ...  password=${password}
    ...  port=${port}
#    ${interval}    ${sw_version}=     get_admin_pminterval    ${webservice}
#    ${for_last}=    wait_for_the_log    ${start_date}    ${end_date}    ${interval}
#    log    ${for_last}
#    log    ${interval}
#    PM.create PM collector
#    ...  name=gnb_pm_counters
#    ...  webservice=${webservice}
#    ...  for_last=${for_last}
#    ...  intervals=${interval}
#    PM.setup_collectors
#    ...  names=gnb_pm_counters
#    PM.collect_collectors
#    ...  names=gnb_pm_counters     target_dir=/home/ute/results
#    PM.teardown_collectors
#    ...  names=gnb_pm_counters
#    ${log_entries}=    Evaluate
#    ...    list(taf.analyzer.pmcounter.PMCounterLogReader.from_dir(dir_path="/home/ute/results/gnb_pm_counters/", file_pattern="PM*"))
#    ...    taf,taf.analyzer,taf.analyzer.pmcounter
#    ${output}=    write_counter     ${sw_version}    testrun1   ${log_entries}    ${counter_json_file}    ${start_date}    ${end_date}
#    log    ${output}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}


Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |

    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=10_2_BTS1002CRT5G
    log    ${node_id}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb


    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}


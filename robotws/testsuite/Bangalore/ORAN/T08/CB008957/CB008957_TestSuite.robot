*** Settings ***
Documentation
...   author: Challa Ravali, Sreekumar Narimuri Kumaran
...   contact: challa.ravali@nokia.com
...   Description: Test Suite for CB008957 testcases Trunk execution


Suite Setup    Run Keywords      UTE_ORAN_TL_Bringup_Precondition
...    AND    Check fault 23 and fix
...    AND    Wait Until BTS is OnAir
...    AND    Set export yml    ${VM_IP}
...    AND    Copy swconfig to BTS    ${swconfig_path}
...    AND    Suite Setup

Suite Teardown      Suite Teardown

Test Setup      Admin_setup
Test Teardown   Admin_teardown
Resource    ./resources/CB008957_Keywords.robot
Resource    testsuite/Bangalore/ORAN/T08/resources/robot/Topyoung_Attenuator_T08.robot
Resource    testsuite/Bangalore/ORAN/T08/resources/robot/Reporting_Portal_Keywords.robot
Resource    testsuite/Bangalore/ORAN/T08/resources/robot/CommonKeywordResourceFile.robot
Library    BuiltIn
Library    Collections
Library    String
Library    OperatingSystem
Library    SSHLibrary
Library    SeleniumLibrary
Library    DateTime
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    seleLib
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.sw.dcap.rd   WITH NAME   rd
Library    taf.sw.scout    WITH NAME    scout
Force Tags      QCD_MN_RAN    QCP_RAN_ST

*** Variables ***
${VM_IP}   10.58.238.125
${pva_ip}    10.45.153.212
${pva_vendor}    TOPYOUNG
${pva_model}	 TAS16T16-51-120-1N-DEJS
${scf_ofegsa_only}=   /home/ute/testline_configuration/7_2_UTE5GCLOUD1024/node1/SCF_MRBTS_1024_OFEGSA_ONLY.xml
${swconfig_path}=     testsuite/Bangalore/ORAN/T08/resources/config/swconfig.txt

*** test cases ***
ORU_lock_unlock_and_Reset_and_TCP_call
    [Tags]    QC_670706    CRT    SBTS00
    ${out}    set variable
    ...    ${SUITE_PATH}/CB008957TESTSUITE/Verification_of_TCP_call_after_ORU_Lock_Unlock
    set test variable    ${out}
    OperatingSystem.create directory     ${out}
    ORU_lock_unlock_and_Reset_and_TCP_call

Verification_of_timing_performance_of_ORU
    [Tags]    QC_664651    CRT    SBTS00
    ${out}    set variable
   ...    ${SUITE_PATH}/CB008957TESTSUITE/Verification_of_timing_performance_of_ORU
    set test variable    ${out}
    OperatingSystem.create directory     ${out}
    CB008957_netconf_message_timing_calculaton

Commissioning_of_LTE_NR_concurrent_mode_configuration_with_Band1_and_Band3
    [Tags]    QC_670748    CRT    SBTS00
    ${out}    set variable
    ...    ${SUITE_PATH}/CB008957TESTSUITE/Commissioning_of_LTE_NR_concurrent_mode_configuration_with_Band1_and_Band3
    set test variable    ${out}
    OperatingSystem.create directory     ${out}
    Verify CB008957_Commissioning of LTE+NR concurrent mode configuration with Band-1 and Band3 along with udp and tcp calls

*** Keywords ***

Suite Setup
    Log to console    \n--Suite Setup--\n
    Open_Admin_Connection
    SCF commissioning    ${scf_ofegsa_only}	  600   suite_oam
    Wait Until BTS is OnAir
    ${SUITE_PATH}    set variable    ${OUTPUT_DIR}/
    Set Suite Variable    ${SUITE_PATH}
    log to console    .....--Precondition--.....
    Wait Until Keyword Succeeds    4min    1s    Lock_Cell_for_CB008957
	PVA_Attenuator_startup    ${pva_ip}    ${pva_vendor}    ${pva_model}
    Close_Admin_Connection


Suite Teardown
    Open_Admin_Connection
	Wait Until Keyword Succeeds    4min    1s    Unlock_Cell_for_CB008957
    Close_Admin_Connection

Open_Admin_Connection
    Log To Console    connecting to BTS
    CoamAdmin.teardown_all_aliases_for_admin
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=suite_oam

Close_Admin_Connection
    CoamAdmin.teardown    suite_oam
    Log To Console    BTS IS Disconnected

Admin_setup
    Log To Console    connecting to BTS
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    alias=oam
    Log To Console    BTS is Connected
    Check BTS is OnAir
    Log to console   \n--Starting Syslogs Logs--\n
    Run     killall btslog
    ${executor_test_vm}=  Create Dictionary
    ...  host=${VM_IP}
    ...  user=ute
    ...  password=BT5l@bus3rl0g1n
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   executor=${executor_test_vm}
    ...   log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.set_suite_alias    btslog
    core.start_collectors      names=btslog
    ${allowed_alarms}=    Expected_alarm

Admin_teardown
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog    target_dir=${out}
    core.teardown_collectors      names=btslog
    Link SCOUT SCF to Configuration ID for Reporting
    CoamAdmin.teardown    oam
    Log To Console    BTS IS Disconnected

Check BTS is OnAir
    [Documentation]  ... checking BTS status
    [Arguments]  ${connection}=oam
    ${bts_status}=  CoamAdmin.get_bts_statuses  connection=${connection}
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    BTS procedural state is now: ${bts_status["proceduralState"]}${\n}
    ...    ELSE    fail

Lock_Cell_for_CB008957
    [Documentation]  ... Locking_cells
	CoamAdmin.unlock    dist_name=MRBTS-1024/NRBTS-1024/NRCELL-0    timeout=60    connection=suite_oam
    sleep    30s
    CoamAdmin.lock    dist_name=MRBTS-1024/NRBTS-1024/NRCELL-1    timeout=60    connection=suite_oam
    sleep    30s
	CoamAdmin.lock    dist_name=MRBTS-1024/LNBTS-1024/LNCEL-0    timeout=60    connection=suite_oam
    sleep    30s
    CoamAdmin.lock    dist_name=MRBTS-1024/LNBTS-1024/LNCEL-1    timeout=60    connection=suite_oam
    sleep    30s
    CoamAdmin.lock    dist_name=MRBTS-1024/LNBTS-1024/LNCEL-2    timeout=60    connection=suite_oam
    sleep    30s
    log to console    ----All other cells are locked except NRCELL-0 ----

Unlock_Cell_for_CB008957
    [Documentation]  ... unlocking_cells
    CoamAdmin.unlock    dist_name=MRBTS-1024/NRBTS-1024/NRCELL-1    timeout=60    connection=suite_oam
    sleep    30s
	CoamAdmin.unlock    dist_name=MRBTS-1024/LNBTS-1024/LNCEL-0    timeout=60    connection=suite_oam
    sleep    30s
    CoamAdmin.unlock    dist_name=MRBTS-1024/LNBTS-1024/LNCEL-1    timeout=60    connection=suite_oam
    sleep    30s
    CoamAdmin.unlock    dist_name=MRBTS-1024/LNBTS-1024/LNCEL-2    timeout=60    connection=suite_oam
    sleep    30s
    log to console    ----All cells are unlocked----

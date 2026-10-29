*** Settings ***

Documentation
...   author: Anagha Chenniga
...   contact: anagha.chenniga@nokia.com
...   Description: Test Suite for CB007814

Test Setup      Test_Setup
Test Teardown   Test_Teardown

Resource    CB007814_Testcases.robot

Library    BuiltIn
Library    Collections
Library    String
Library    OperatingSystem
Library    SSHLibrary
Library    SeleniumLibrary
Library    DateTime
Library    taf.gnb.oam.coam.admin
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    seleLib
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.transport.ssh    WITH NAME    ssh
#specify config file --> reminder
Library    taf.sw.dcap.rd   WITH NAME   rd
Library    taf.sw.scout    WITH NAME    scout
Force Tags        CRT    SBTS24R3    FL00    QCD_MN_RAN    QCP_RAN_VRF

*** Variables ***
${BTS_ADDRESS}    192.168.255.129
${BTS_PORT}       443
${USE_SSL}        True

*** Test Cases ***
#
#CB007814_5GC000638_Verification_of_Ng_lock_unlock_ABIO_reset
#    [Tags]    QC_31508    QC_692615    CRT    SBTS00    SBTS24R3
#    ${out}    set variable
#    ...    ${OUTPUT_DIR}/CB007814_5GC000638_Verification_of_Ng_lock_unlock_ABIO_reset/
#    set test variable    ${out}
#    create directory     ${out}
#    CB007814_5GC000638_5GC000723_5GC000728_To verify NG reset and setup procedure between gNB and AMF triggered by gNB_15Mhz_SA_2T2R

CB007814_5GC001875_5GC000522_Verification_of_spill_over_256QAM_feature_in_gNB_10Mhz_SA_4T4R
    [Tags]    QC_31509    QC_852736    CRT    SBTS00    SBTS24R3
    ${out}    set variable
    ...    ${OUTPUT_DIR}/CB007814_5GC001875_5GC000522_Verification_of_spill_over_256QAM_feature_in_gNB_10Mhz_SA_4T4R/
    set test variable    ${out}
    create directory     ${out}
    CB007814_5GC001875_5GC000522_Verification of spill over 256QAM feature in gNB_10Mhz_SA

#CB007814_5GC000517_5GC001796_Verification_of_downlink_and_Uplink_link_adaptation_20_MHZ_SA
#     [Tags]    QC_31507    QC_852734    CRT    SBTS00    SBTS24R3
#    ${out}    set variable
#    ...    ${OUTPUT_DIR}/CB007814_5GC000517_5GC001796_Verification_of_downlink_and_Uplink_link_adaptation_20_MHZ_SA/
#    set test variable    ${out}
#    create directory     ${out}
#    CB007814_5GC000517_5GC001796_Verification of downlink and Uplink link adaptation 20_MHZ_SA

*** Keywords ***
Admin_setup
    Log To Console    connecting to BTS
    taf.gnb.oam.coam.admin.Setup admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    alias=oam
    Log To Console    BTS is Connected


Admin_teardown
    Link SCOUT SCF to Configuration ID for Reporting
    coam.Teardown admin    alias=oam
    Log To Console    BTS IS Disconnected

Test_Setup
    Log to console   --Starting Test setup and syslog--
    coam.Teardown All Aliases For Admin
    coam.setup_admin    bts_host=192.168.255.129
    Log to console   --Test setup--
    btslog.create_btslog_collector
    ...    name=btslog
    ...    log_dir=/tmp/btslog2
    core.setup_collectors      names=btslog
    core.set_suite_alias      btslog
    core.start_collectors      names=btslog
    ${mrbts_state}=    coam.Get Mrbts State
    Log to console    \MRBTS state: ${mrbts_state}
    coam.collect_snapshot     /home/ute/robotws/${Timestamp}/pre_snapshot.zip
    #pva   1   0

Test_Teardown
    Log to console   --Test teardown--
    core.stop_collectors      names=btslog
    core.collect_collectors      names=btslog      target_dir=/home/ute/robotws/${Timestamp}
    core.teardown_collectors      names=btslog
    coam.setup_admin    bts_host=192.168.255.129   alias=MRBTSstate
    ${mrbts_state}=    coam.Get Mrbts State    alias=MRBTSstate
    Log to console    \MRBTS state: ${mrbts_state}
    coam.setup_admin    alias=snapshot
    coam.collect_snapshot     /home/ute/robotws/${Timestamp}/post_snapshot.zip     alias=snapshot
    coam.Teardown All Aliases For Admin

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=    Wait Until Keyword Succeeds    4min    10s    scout.request_scf   use_scout_internal_id=True
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

    [Arguments]    ${node_type}=gnb    ${tl_name_only}=10_2_CLOUD1236

    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

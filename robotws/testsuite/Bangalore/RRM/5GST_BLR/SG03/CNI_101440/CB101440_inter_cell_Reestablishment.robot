*** Settings ***
Documentation
...   author: Sahadeb Ghosh
...   contact sahadeb.ghosh@nokia.com
...   Description: Test Suite for CB101440
...   The purpose of the test case is to verify the PCMD records for gNB-DU are updated during the RRC re-establishment as below
...   Trace Record session of UE call in serving cell is started and reports to TCE data with serving cell c-RNTI.
...   Trace Record session of UE call continuous on same serving cell with new c-RNTI after rrc reestablishment.
Library    OperatingSystem
Library    String
Library    Collections
Library    DateTime
Library    SSHLibrary
Library    taf.collectors.core        WITH NAME   core
Library    taf.collectors.snapshot    WITH NAME   snapshot
Library    taf.collectors.btslog      WITH NAME   btslog
Library    taf.sw.dcap.rd             WITH NAME   dcap
Library    taf.transport.ssh          WITH NAME   ssh
Library    String                     WITH NAME   str
Library    taf.sw.scout               WITH NAME   scout
Library    taf.sbts.oam.coam.admin    WITH NAME   coam
Resource   ./testsuite/Bangalore/RRM/5GST_BLR/SG03/resources/CNI-101440_RESOURCE.robot


*** Variables ***
${bts_ip}           192.168.255.129
${Windows_user}     inbabtslabuser                                              		# Windows UE PC username
${Windows_pass}     BT5l@bus3rl0g1n                                                         # Windows UE PC password
@{capabilities}     Legacy_1
@{throughput_dl}=   50
@{dt_name}=         iperf_dl_test
@{UE_alias}=        UE1
@{direction_dl}=    dl
@{duration}=        500s
${timeout}          300
@{udpcalltype}=     UDP
@{deviation_dl}=    20
${packet_size}=     1400
${new_timeout}=     180s
${tput}=            100Mbits/sec
${SCF_PATH}         /home/ute/Downloads
${scf_file1}=       /home/ute/Downloads/Configuration_scf_MRBTS-11002_5G_Classical_gNB_19_20240213-1119.xml
${TC_ID}=           112493
${btslog}=           btslog
${log_dir}=          /tmp/btslog4

*** Keywords ***
CNI-101440_Verification of monitoring of PCMD records for gNB-DU during inter-cell RRC Re-establishment
    STEP 1 : Create dcap session                                          #create dcap readiness session
    STEP 2 : Dcap Start Trace
    Log to console      Configuring Ports Attenuation
    Setting Attenuator                                          #Collect 5g control plane and cell trace logs
    STEP 3 : Start the NR call                  #airplane mode on/off,attach UE, run iperf command and setting attenuation level for both cells
    STEP 4 : Dcap Stop Trace                                                 #stop dcap logs
    STEP 5 : Verify Emil logs AND Validate different messages    # EMIL celltrace for PCMD verification

STEP 1 : Create dcap session
    dcap.connect_to    host=${dcaphost}    port=${port}    username=${dcap_username}   password=${dcap_password}
    ...              rd_version=${rd_version}    secure=True

STEP 2 : Dcap Start Trace
    Log to console      \nStarting DCAP trace

    @{gnb_custom_profile}=  Create List  Tracer_5g
    @{bts}      Create List     ${bts_info}
    ${output}    dcap.start_trace    bts=${bts}    duration=10    timeout=600    force=True    gnb_custom_profile=@{gnb_custom_profile}
    Log To Console    ${output}
    ${trace_id} =   Get From Dictionary   ${output}   tracer_id
    Set Test Variable    ${trace_id}
    sleep    90

STEP 3 : Start the NR call
    ${start_date}=    Get Current Date
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}     #UE detach step
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}     #UE attach step
    Log to console    \nattach is success
    Log to console    \nStarting data transfer
    Run Keyword    ta_ultracaller.start_data_transfer      ${UE_alias}     ${udpcalltype}    direction=${direction_dl}
    Run Keyword    ta_ultracaller.await_data_transfer_finish     ${UE_alias}    ${direction_dl}     ${timeout}
    Attenuation

STEP 4 : Dcap Stop Trace
    dcap.stop_trace    ${trace_id}
    sleep    180
    Log To Console    ${trace_id}
    Create Directory    ${PATH}
    Run Keyword    OperatingSystem.Run    ${Change_Permission}
    Empty Directory    ${PATH}
    ${dcap_file_name}=   dcap.get_results    result_id=${trace_id}    target_dir=/home/ute/dcapfiles    timeout=${timeout}
    BuiltIn.sleep    3m
    LOG     DCAP logging stopped

STEP 5 : Verify Emil logs AND Validate different messages
    [Arguments]    @{values}
    @{check}=	Create list   rrcReestablishmentRequest    TimingAdvanceTraceRecord    DuDlSchedulingTraceRecord    BeamUsageTraceRecord
    ...    DuUlSchedulingTraceRecord    DuDlRadioBearerRlcMeasTraceRecord
    ...    DuUlRadioBearerRlcMeasTraceRecord    DuUlRadioBearerRlcThroughputTraceRecord
    Verify Emil logs  @{check}
    Link SCOUT SCF to Configuration ID PCMD

Link SCOUT SCF to Configuration ID PCMD
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Wait Until Keyword Succeeds    2min    10s    Link SCOUT SCF to Configuration ID for Reporting    scout_testline_name=1_2_CLOUD1002
    ...    node_id=${0}    node_type=gnb
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |

    [Arguments]    ${node_type}=gnb    ${tl_name_only}=1_2_CLOUD1002

    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb


    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF PCMD  ${scout_testline_name}
    ${TC_ID}=    Set Variable      ${external_scf_id}
    Set Suite Variable  ${TC_ID}

Request Scout SCF PCMD
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Wait Until Keyword Succeeds    2min    10s    Link SCOUT SCF to Configuration ID for Reporting
    ...    scout_testline_name=1_2_CLOUD1002 KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

*** Settings ***
Documentation
...                 author: Sahadeb Ghosh
...                 contact sahadeb.ghosh@nokia.com
...                 Description: Test Suite for CNI-91456
...                 The purpose of the test case is to verify RRC Connection Established Time

Library             OperatingSystem
Library             String
Library             Collections
Library             DateTime
Library             SSHLibrary
Library             taf.collectors.core    WITH NAME    core
Library             taf.collectors.snapshot    WITH NAME    snapshot
Library             taf.collectors.btslog    WITH NAME    btslog
Library             taf.sw.dcap.rd    WITH NAME    dcap
Library             taf.transport.ssh    WITH NAME    ssh
Library             String    WITH NAME    str
Library             taf.sw.scout    WITH NAME    scout
Library             taf.sbts.oam.coam.admin    WITH NAME    coam
Resource            ./testsuite/Bangalore/RRM/5GST_BLR/SG03/resources/CNI_91456_RESOURCE.robot



*** Variables ***
${bts_ip}           192.168.255.129
${Windows_user}     inbabtslabuser    # Windows UE PC username
${Windows_pass}     BT5l@bus3rl0g1n    # Windows UE PC password
@{capabilities}     Legacy_1
@{throughput_dl}    50
@{dt_name}          iperf_dl_test
@{UE_alias}         UE1
@{direction_dl}     dl
@{duration}         500s
${timeout}          300
@{udpcalltype}      UDP
@{deviation_dl}     20
${packet_size}      1400
${new_timeout}      180s
${tput}             100Mbits/sec
${SCF_PATH}         /home/ute/Downloads
${scf_file1}        /home/ute/Downloads/Configuration_scf_MRBTS-11002_5G_Classical_gNB_19_20240213-1119.xml
${TC_ID}            112494
${btslog}           btslog
${log_dir}          /tmp/btslog4


*** Keywords ***
CNI-94156_Verification of SA RRC call setup time in FDD or TDD cell
    Log to console    Commissioning the site with Feature Disable
    STEP 1 : Commission and Deactivate the Feature    # ueConnectionEstablishmentMode = useDedicatedBwp
    Log to console    Configuring Ports Attenuation
    Setting Attenuator
    Log to console    Attenuating other Cells
    Cell Attenuation
    Create dcap session    # create dcap readiness session
    Dcap Start Trace    # Collect 5g control plane and cell trace logs
    Start the NR call    # airplane mode on/off,attach UE, run iperf command and setting attenuation level for both cells
    Dcap Stop Trace    # stop dcap logs
    ${ueConnectionEstablishmentMode}=    Set variable    useDedicatedBwp
    Verify Emil logs AND Validate different messages    ${ueConnectionEstablishmentMode}
    Log to console    Commissioning the site Enabling CNI-94156
    STEP 2 : Commission and Activate the Feature    # ueConnectionEstablishmentMode = useInitialBwp
    Create dcap session    # create dcap readiness session
    Dcap Start Trace    # Collect 5g control plane and cell trace logs
    Start the NR call    # airplane mode on/off,attach UE, run iperf command and setting attenuation level for both cells
    Dcap Stop Trace    # stop dcap logs
    ${ueConnectionEstablishmentMode}=    Set variable    useInitialBwp
    Verify Emil logs AND Validate different messages    ${ueConnectionEstablishmentMode}
    Calulate the Time Difference
    Link SCOUT SCF to Configuration ID RRC Setup time

STEP 1 : Commission and Deactivate the Feature
    coam.teardown_all_aliases_for_admin
    coam.setup_admin    bts_host=192.168.255.129    bts_port=443    username=Nemuadmin    password=nemuuser    use_ssl=True
    coam.Perform Commissioning
    ...    1002
    ...    /home/ute/robotws/testsuite/Bangalore/RRM/5GST_BLR/SG03/resources/Configuration_scf_MRBTS-11002_CNI_disable.xml
    ...    True
    ...    timeout=1200
    sleep    300
    ${Status}=    coam.get_bts_statuses
    Should Be Equal    ${Status}[proceduralState]    OnAir
    coam.teardown_all_aliases_for_admin

STEP 2 : Commission and Activate the Feature
    coam.teardown_all_aliases_for_admin
    coam.setup_admin    bts_host=192.168.255.129    bts_port=443    username=Nemuadmin    password=nemuuser    use_ssl=True
    coam.Perform Commissioning
    ...    1002SCOUT
    ...    /home/ute/robotws/testsuite/Bangalore/RRM/5GST_BLR/SG03/resources/Configuration_scf_MRBTS-11002_CNI_enable.xml
    ...    True
    ...    timeout=1200
    sleep    300
    ${Status}=    coam.get_bts_statuses
    Should Be Equal    ${Status}[proceduralState]    OnAir
    coam.teardown_all_aliases_for_admin

Create dcap session
    dcap.connect_to    host=${dcaphost}    port=${port}    username=${dcap_username}    password=${dcap_password}
    ...    rd_version=${rd_version}    secure=True

Dcap Start Trace
    Log to console    \nStarting DCAP trace
    @{gnb_custom_profile}=    Create List    Tracer_5g
    @{bts}=    Create List    ${bts_info}
    ${output}=    dcap.start_trace    bts=${bts}    duration=10    timeout=600    force=True    gnb_custom_profile=@{gnb_custom_profile}
    Log To Console    ${output}
    ${trace_id}=    Get From Dictionary    ${output}    tracer_id
    set test variable    ${trace_id}
    sleep    90

Start the NR call
    Log to console    \nStarting Data call
    ${start_date}=    Get Current Date
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}    # UE detach step
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}    # UE attach step
    Log to console    \nattach is success
    Log to console    \nStarting data transfer
    Run Keyword    ta_ultracaller.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
    Run Keyword    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_dl}    300

Dcap Stop Trace
    Log to console    \nCollecting DCAP trace
    dcap.stop_trace    ${trace_id}
    sleep    180
    Log To Console    ${trace_id}
    Create Directory    ${PATH}
    Run Keyword    OperatingSystem.Run    ${Change_Permission}
    Empty Directory    ${PATH}
    ${dcap_file_name}=    dcap.get_results    result_id=${trace_id}    target_dir=/home/ute/dcapfiles    timeout=300
    BuiltIn.sleep    3m
    LOG    DCAP logging stopped

Verify Emil logs AND Validate different messages
    [Arguments]    ${ueConnectionEstablishmentMode}
    Verify Emil logs timestamp
    Verify Converted emil fiLE to measure time    ${ueConnectionEstablishmentMode}

Link SCOUT SCF to Configuration ID RRC Setup time
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...    |    Wait Until Keyword Succeeds    2min    10s    Link SCOUT SCF to Configuration ID for Reporting    scout_testline_name=1_2_CLOUD1002
    ...    node_id=${0}    node_type=enb
    ...    |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...    |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_type}=gnb    ${tl_name_only}=1_2_CLOUD1002

    IF    "${node_type}"=="gnb"
        ${node_type_Name}=    Set Variable    gNB
    ELSE IF    "${node_type}"=="enb"
        ${node_type_Name}=    Set Variable    eNB
    ELSE
        ${node_type_Name}=    Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    END

    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=    Request Scout SCF RRC Setup    ${scout_testline_name}
    ${TC_ID}=    Set Variable    ${external_scf_id}
    Set Suite Variable    ${TC_ID}

Request Scout SCF RRC Setup
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Wait Until Keyword Succeeds    2min    10s    Link SCOUT SCF to Configuration ID for Reporting
    ...    scout_testline_name=1_2_CLOUD1002 KW.
    [Arguments]    ${scout_testline_name}
    scout.setup_scout    scout_testline_name=${scout_testline_name}
    ${external_scf_id}=    scout.request_scf    use_scout_internal_id=True
    scout.teardown_scout_api
    RETURN    ${external_scf_id}

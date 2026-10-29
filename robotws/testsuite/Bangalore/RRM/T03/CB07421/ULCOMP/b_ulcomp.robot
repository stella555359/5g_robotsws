*** Settings ***

Documentation    Author: Hari.mada
...              Maintainer: MN RAN Pz BLR 3 SG
...              MRT
Library    Collections
Library    BuiltIn
Library    String
Library    DateTime
Library    Process
Library    SSHLibrary
Library    OperatingSystem    WITH NAME    os
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
#Library    taf.sbts.oam.coam.admin    WITH NAME    admin
# Uncomment the next line if you need admin as a separate alias
Library    taf.ue    WITH NAME    ue
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog    WITH NAME    btslog
Library    taf.sw.scout    WITH NAME    scout
Library    taf.sw.reporting_portal
#Library    taf.collectors.snapshot    WITH NAME    snapshot

Force Tags    CA_VRF_BLR1    SBTS00    SBTS24R3    SBTS25R3    QCD_MN_RAN    QCP_RAN_VRF

#Suite Setup        common_suite_setup
#Suite Teardown     common_suite_teardown

#Test Setup       Test_Setup
#Test Teardown    Test_Teardown

*** Variables ***
${OUT_LOG_PATH}           /home/ute/logs
${LOG_PATH}               /home/ute/logs/snapshot
#${snaptarget_file_name}		/home/ute/logs/snapshot
${BTSLOG}                 btslog
${BTS_ADDRESS}=      192.168.255.129
${VM_IP}=            10.43.54.117
${TIMEOUT_MAKE_SNAPSHOT}  900
${UE_ID}                  4
${duration}               600s
${protocol}               UDP
${packet_size}            1200

# Timeout value in ue_config.yml file should match the below timeout value
${timeout}                520

# Attenuation of the PVA in incremental order
${ATT_START_DB}           2
${nextAtt}                2
${eNB_source_CELL_1}      ENB_1_CELL_1

# Attenuation of the PVA in decremental order
${decAtt}                 40    # This is value from which the PVA ports start to decrement
${eNB_source_CELL_2}      ENB_1_CELL_1

# YML path for "Reserve attenuator CELL Source" keyword
# ${ABSTRACT_LIB_CONFIG}   /home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/T03/CB07421/resource/IV4_BLR_1.yml

${host}		    192.168.255.129
${user}		     Nemuadmin
${password}	    nemuuser
${port}                    443

# Cases to be marked in QC definition
${testline}               1_2_UTE4GCLOUD259
# &{CB007421_Activation, deactivation and verification of Basic UlComp for CB006501}  QC_ID_SBTS25R3=

*** Test Cases ***
CB007421 Activation deactivation and verification of Basic UlComp for CB006501
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF
    BTS SOFTWARE INFO
    Test get MRBTS state
    start Btslogs from Local machine    ${BTSLOG}
    Step1 Perform BTS Site Reset
    Site Commissioning
    Step2 ULCOMP Disabled
    Step3 ULCOMP Fixed Comp Activation
#    Step4 Repeat Step2 and Step3
#    Collect Snapshot
    Stops Btslogs From Local Machine     ${BTSLOG}
   #Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***

Test get MRBTS state
    ${mrbts_state}=    Get Mrbts State
    Log To Console    ------------------------------------------------------------
    Log To Console    Test: Get MRBTS State
    Log To Console    MRBTS State Result: ${mrbts_state}
    Log To Console    ------------------------------------------------------------

#Test_Setup
    Log To Console    \n--Start test--\n
    # Start BTS logs locally (log alias passed)
    Start Btslogs From Local Machine    ${BTSLOG}
    coam.setup_admin    bts_host=${BTS_ADDRESS}    alias=admin1

Step1 Perform BTS Site Reset
    Log To Console    Reset Site
    coam.reset    timeout=700
    Sleep    350
    Fault_Admin

Step2 ULCOMP Disabled
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    Log To Console    \nActcomp is set to disabled
    coam.perform_delta_recommissioning
    ...    /home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/T03/CB07421/ULCOMP/actcomp_disabled.json
    ...    skip_parameter_relation_errors=False
    ...    timeout=1200
    Sleep    400
    Fault_Admin

Site Commissioning

      Log to console   Start_commissioning
      coam.Connect to   bts_host=192.168.255.129   bts_port=443
      coam.perform_commissioning    skip_parameter_relation_errors=true
...		  scf_file=/home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/T03/CB07421/ULCOMP/ulcomp.xml 	   timeout=2000
      sleep    180

Step3 ULCOMP Fixed Comp Activation
    Log To Console    \nActcomp was in disabled state
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    Log To Console    \nActcomp is set to Fixed_Comp
    coam.perform_delta_recommissioning
    ...    /home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/T03/CB07421/ULCOMP/FixedComp_activation.json
    ...    skip_parameter_relation_errors=False
    ...    timeout=1200
    Sleep    400
    Fault_Admin

Step4 Repeat Step2 and Step3
    Step2 ULCOMP Disabled
    Step3 ULCOMP Fixed Comp Activation
    Fault_Admin

#Test_Teardown
    Log To Console    --End test--\n
    # Optionally get active alarms for admin1
    # Get ActiveAlarms    alias=admin1
    Stops Btslogs From Local Machine    ${BTSLOG}
    coam.Collect snapshot      ${LOG_PATH}/snapshot.zip    connection=admin1
    coam.teardown_all_aliases_for_admin
    SSHLibrary.Close All Connections

Get ActiveAlarms
    ${alr}=    coam.get_active_alarms
    Log    ${alr}
    ${alr_num}=    coam.get_active_alarms_number
    Log    ${alr_num}

Collect Snapshot
    #[Arguments]    ${snaptarget_file_name}=${LOG_PATH}/Snapshotfile.zip
    coam.Collect snapshot      ${LOG_PATH}/snapshot.zip

common_suite_setup
    coam.teardown_all_aliases_for_admin
    Log    suite
    ${rep_values}=    Create Dictionary
    Set Suite Variable    ${rep_values}

common_suite_teardown
    coam.setup_admin    alias=rp
    ${sw_release}=    coam.get_sw_release_name    connection=rp
    ${build}=    coam.get_sw_version    connection=rp
    coam.teardown_all_aliases_for_admin

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    [Arguments]    ${node_type}=enb    ${tl_name_only}=1_2_UTE4GCLOUD259
    ${node_type_Name}=    Run Keyword If    "${node_type}"=="gnb"    Set Variable    gNB
    ...    ELSE IF    "${node_type}"=="enb"    Set Variable    eNB
    ...    ELSE    Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=    Request Scout SCF    ${scout_testline_name}
    ${TC_ID}=    Set Variable    ${external_scf_id}
    Set Suite Variable    ${TC_ID}
    # If rep_values is populated, report results for each item
    FOR    ${I}    IN    @{rep_values.keys()}
        # Example call to reporting portal (adjust args per actual keyword)
        taf.sw.reporting_portal.Report To Rp
        ...    name=${I}
        ...    result=${rep_values['${I}']}ED
        ...    ca=VRF_BLR1
        ...    testline=${testline}
        ...    build=${build}
        ...    qc_domain=MN_RAN
        ...    tc_execution_id=${TC_ID}
        ...    qc_project=RAN_VRF
        ...    qc_id=${${I}}[QC_ID_${sw_release}]
    END

Request Scout SCF
    [Arguments]    ${scout_testline_name}
    [Documentation]    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout    scout_testline_name=${scout_testline_name}
    ${external_scf_id}=    scout.request_scf    use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]    ${external_scf_id}

Fault_Admin
    # Connect to admin to verify alarms and validate expected ones
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    @{K2}=    Create List    4655    4654    10    2001    6327    4681    1898    4467    49    7319    7300    61649    61524    6150
...		6450    4297    61652    4072    7311    4459    7307    7523    7107    6203    2265    6261    4321
    @{Alarms}=    coam.get_active_alarms
    FOR    ${i}    IN    @{Alarms}
        ${v}=    Set Variable    ${i['faultId']}
        ${a}=    Convert To String    ${v}
        Log    ${a}
        List Should Contain Value    ${K2}    ${a}
    END
    coam.teardown_admin

Check Onair State
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    ${Status}=    coam.get_bts_statuses
    Should Be Equal    ${Status}[proceduralState]    OnAir
    core.setup_collectors    ${BTSLOG}
    core.start_collectors    ${BTSLOG}
    core.Set Suite Alias    ${BTSLOG}

BTS SOFTWARE INFO
    coam.Connect_to    bts_host=192.168.255.129    bts_port=443
    coam.get_software_info    timeout=10

start Btslogs from Local machine
    [Arguments]    ${log_alias}
    btslog.create_btslog_collector    ${log_alias}
    core.setup_collectors     ${log_alias}
    core.start_collectors     ${log_alias}
    core.Set Suite Alias    ${log_alias}

Stops Btslogs From Local Machine
    [Arguments]    ${log_alias}
    core.stop_collectors    names=${log_alias}
    core.collect_collectors    names=${log_alias}
    core.teardown_collectors    names=${log_alias}
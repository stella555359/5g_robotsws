*** Settings ***
Documentation
...                 author:    hari
Library             String
Library             Collections
Library             DateTime
Library             BuiltIn
Library             OperatingSystem    WITH NAME    os
Library             taf.sw.dcap.rd    WITH NAME    rd
Library             taf.sw.scout    WITH NAME    scout
Library             taf.collectors.core    WITH NAME    core
Library             taf.collectors.btslog    WITH NAME    btslog
Library             taf.sbts.oam.coam.admin    WITH NAME    admin
Library             taf.hw.rf_attenuator    WITH NAME    attenuator
Library             taf.sw.reporting_portal

Test Teardown       Post condition


Force Tags          ca_vrf_blr1    sbts00    sbts24r3    sbts25r3    qcd_mn_ran    qcp_ran_vrf


*** Variables ***
${dir_name}                 /home/ute/Logs

${log_name}                 Syslog

${OUT_LOG_PATH}           /home/ute/logs

${BTSLOG}                 btslog

&{vm_dict}                  host_ip=10.43.54.117
...                         user=ute
...                         password=12345678@Nokia

${Attenuator_ip_addr}       10.45.153.211

${Attenuator_com_port}      3001

@{attenuation_ports}        15    16

${Attenuator_vendor}        TOPYOUNG

${Attenuator_model}         TAS16T16-51-120-1N-DEJS

${PVA_Port_1}               15

${PVA_Port_2}               16

${PVA_Value_1}              0dB

${PVA_Value_2}              90dB

${PVA_Value_new_1}          40dB

${PVA_Value_new_2}          40dB

@{UE_alias}                 UE_4

@{capabilities}             Legacy_4

@{udpcalltype}              FTP

${protocol}                 FTP

@{direction_dl}             ul

${timeout}                  200

${BTS_ADDRESS}              192.168.255.129

${value_true}               true

${connection}               default

&{BTS_Details}              bts_host=192.168.255.129
...                         username=Nemuadmin
...                         password=nemuuser
...                         use_ssl=True
...                         update_interval=5500
...                         bundle_path=None
...                         release=SBTS00
...                         timeout=30

&{BTS_Reset}                reset_coverage=Site
...                         wait_for_reconnection=True
...                         timeout=300
...                         connection=None
...                         detailed_output=False
${testline}               1_2_UTE4GCLOUD259


*** Test Cases ***
CB007421_CB006501Activation deactivation and verification of Basic UlComp
    [Tags]    crt    qcd_mn_ran    qcp_ran_vrf

    BTS SOFTWARE INFO
    Test get MRBTS state
    start Btslogs from Local machine    ${BTSLOG}
    Step1 Perform BTS Site Reset
    Site Commissioning
    Step2 ULCOMP Disabled
    Step3 ULCOMP Fixed Comp Activation
    Stops Btslogs From Local Machine     ${BTSLOG}
    [Teardown]  Post condition


*** Keywords ***

Test Setup
    [Documentation]    Setup environment and start log collection

    Run Keywords    Login To Admin

Post Condition
    Get Hostname
    Link SCOUT SCF to Configuration ID for Reporting



Test get MRBTS state
    ${mrbts_state}=    Get Mrbts State

    Log To Console    ------------------------------------------------------------

    Log To Console    Test: Get MRBTS State

    Log To Console    MRBTS State Result: ${mrbts_state}

    Log To Console    ------------------------------------------------------------

Login To Admin
    admin.setup_admin    bts_host=${BTS_ADDRESS}

Step1 Perform BTS Site Reset
    Log To Console    Reset Site

    admin.reset    timeout=350

    Sleep    100

    Fault_Admin

Step2 ULCOMP Disabled
    admin.Connect_to    bts_host=192.168.255.129    bts_port=443
    Log To Console    \nActcomp is set to disabled
    admin.perform_delta_recommissioning
    ...    /home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/T03/CB07421/ULCOMP/actcomp_disabled.json
    ...    skip_parameter_relation_errors=False
    ...    timeout=1200
    Sleep    400
    Fault_Admin

Site Commissioning

      Log to console   Start_commissioning
      admin.Connect to   bts_host=192.168.255.129   bts_port=443
      admin.perform_commissioning    skip_parameter_relation_errors=true
...		  scf_file=/home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/T03/CB07421/ULCOMP/ulcomp.xml 	   timeout=2000
      sleep    180

Step3 ULCOMP Fixed Comp Activation
    Log To Console    \nActcomp was in disabled state
    admin.Connect_to    bts_host=192.168.255.129    bts_port=443
    Log To Console    \nActcomp is set to Fixed_Comp
    admin.perform_delta_recommissioning
    ...    /home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/T03/CB07421/ULCOMP/FixedComp_activation.json
    ...    skip_parameter_relation_errors=False
    ...    timeout=1200
    Sleep    400
    Fault_Admin

Step4 Repeat Step2 and Step3
    Step2 ULCOMP Disabled

    Step3 ULCOMP Fixed Comp Activation

    Fault_Admin

Get ActiveAlarms
    ${alr}=    admin.get_active_alarms

    Log    ${alr}

    ${alr_num}=    admin.get_active_alarms_number

    Log    ${alr_num}

Collect Snapshot
    # [Arguments]    ${snaptarget_file_name}=${LOG_PATH}/Snapshotfile.zip

    admin.Collect snapshot    ${LOG_PATH}/snapshot.zip

Get Hostname
    ${rc}    ${hostname_tmp}=    Run And Return Rc And Output    hostname

    ${hostname_tmp}=    Replace String    ${hostname_tmp}    -    _

    ${hostname_tmp}=    Convert To String    ${hostname_tmp}

    ${hostname_part}=    Split String    ${hostname_tmp}    _

    ${hostname_combined}=    Catenate    ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}

    Set Test Variable    ${HOSTNAME}    ${hostname_combined}

Request Scout SCF
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    [Arguments]    ${scout_testline_name}

    scout.setup_scout    scout_testline_name=${scout_testline_name}

    ${external_scf_id}=    scout.request_scf    use_scout_internal_id=True

    scout.teardown_scout_api
    RETURN    ${external_scf_id}

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...    |    Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...    |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...    |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=${HOSTNAME}

    Log To Console    ${node_id}

    IF    "${node_type}"=="gnb"
        ${node_type_Name}=    Set Variable    gNB
    ELSE IF    "${node_type}"=="enb"
        ${node_type_Name}=    Set Variable    eNB
    ELSE
        ${node_type_Name}=    Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    END

    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}

    ${external_scf_id}=    Request Scout SCF    ${scout_testline_name}

    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}

    Set Tags    ${TC_ID}

Fault_Admin
    # Connect to admin to verify alarms and validate expected ones

    admin.Connect_to    bts_host=192.168.255.129    bts_port=443

    @{K2}=    Create List
    ...    4655
    ...    4654
    ...    10
    ...    2001
    ...    6327
    ...    4681
    ...    1898
    ...    4467
    ...    49
    ...    7319
    ...    7300
    ...    61649
    ...    61524
    ...    6150
    ...    6450
    ...    4297
    ...    61652
    ...    4072
    ...    7311
    ...    4459
    ...    7307
    ...    7523
    ...    7107
    ...    6203
    ...    2265
    ...    6261
    ...    4321

    @{Alarms}=    admin.get_active_alarms

    FOR    ${i}    IN    @{Alarms}
        ${v}=    Set Variable    ${i['faultId']}

        ${a}=    Convert To String    ${v}

        Log    ${a}

        List Should Contain Value    ${K2}    ${a}
    END

    admin.teardown_admin

Check Onair State
    admin.Connect_to    bts_host=192.168.255.129    bts_port=443

    ${Status}=    admin.get_bts_statuses

    Should Be Equal    ${Status}[proceduralState]    OnAir

    core.setup_collectors    ${BTSLOG}

    core.start_collectors    ${BTSLOG}

    core.Set Suite Alias    ${BTSLOG}

BTS SOFTWARE INFO
    admin.Connect_to    bts_host=192.168.255.129    bts_port=443

    admin.get_software_info    timeout=10

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
*** Settings ***
Documentation       Author: Hari.mada
...                 Maintainer:    MN RAN Pz BLR 3 SG
...                 MRT

Library             Collections
Library             BuiltIn
Library             String
Library             taf.sbts.oam.coam.admin    WITH NAME    admin
Library             DateTime
Library             SSHLibrary
Library             Process
Library             taf.transport.ssh    WITH NAME    ssh
Library             OperatingSystem    WITH NAME    os
Library             taf.ue    WITH NAME    ue
Library             taf.collectors.core    WITH NAME    core
Library             taf.sw.scout    WITH NAME    scout
Library             taf.sw.reporting_portal
Library             taf.collectors.btslog    WITH NAME    btslog


*** Variables ***
${OUT_LOG_PATH}=        /home/ute/logs
${BTS_path}=            /home/ute/cb07421
${btslog_target_dir}    /home/ute/logs
${BTS_ADDRESS}=         192.168.255.129
${VM_IP}=               10.43.54.117
@{timeout}              @{EMPTY}

${host}=                192.168.255.129
${user}=                Nemuadmin
${password}=            nemuuser
${port}=                443

# Cases to be marked in QC definition
${testline}             1_2_UTE4GCLOUD259


*** Test Cases ***
CB007421_Activation, deactivation and verification of Basic UlComp for CB006501
    [Tags]    ca_vrf_rrm    4gfdd    crt    sbts00    qc_31329

    BTS SOFTWARE INFO
    Start BTS logs
    Step1 Perform BTS Site Reset
    Step2 ULCOMP Disabled
    Step3 ULCOMP Fixed Comp Activation
    Stop BTS logs
    [Teardown]    Post condition


*** Keywords ***
Post Condition
    Get Hostname
    Link SCOUT SCF to Configuration ID for Reporting

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

BTS SOFTWARE INFO
    admin.Connect_to    bts_host=192.168.255.129    bts_port=443
    admin.get_software_info    timeout=10

Step1 Perform BTS Site Reset
    Log To Console    Reset Site
    admin.reset    timeout=350
    Sleep    100

Step2 ULCOMP Disabled
    admin.Connect_to    bts_host=192.168.255.129    bts_port=443
    Log To Console    \nActcomp is set to disabled
    admin.perform_delta_recommissioning
    ...    /home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/T03/CB07421/ULCOMP/actcomp_disabled.json
    ...    skip_parameter_relation_errors=False
    ...    timeout=1200
    Sleep    400
    Fault_Admin

Step3 ULCOMP Fixed Comp Activation
    admin.Connect_to    bts_host=192.168.255.129    bts_port=443
    Log To Console    \nActcomp is set to Fixed_Comp
    admin.perform_delta_recommissioning
    ...    /home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/T03/CB07421/ULCOMP/FixedComp_activation.json
    ...    skip_parameter_relation_errors=False
    ...    timeout=1200
    Sleep    400
    Fault_Admin

Start BTS logs
    [Documentation]    Starts BTS logs
    Run    killall btslog
    btslog.create_btslog_collector    name=btslog
    core.setup_collectors    names=btslog
    core.set_suite_alias    btslog
    core.start_collectors    names=btslog

Stop BTS logs
    [Documentation]    Stops BTS logs

    core.stop_collectors    names=btslog
    core.collect_collectors    names=btslog    target_dir=${btslog_target_dir}
    core.teardown_collectors    names=btslog

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

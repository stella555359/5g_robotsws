*** Settings ***
Documentation
...    Author: Jakub Rychlik
...    Contact: jakub.rychlik@nokia.com
...    Group in charge: 5G_PZ_1_WRO_4_SG
...    References: GATES
...    Feature Description: 5GC001227-A Basic PRB pooling

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli

Resource    ../CommonKeywords/Component_states/Component_states_resources/component_states_checker.robot
Resource    ../CommonKeywords/Specific_functionalities/PRB_pooling.robot
Resource    ../CommonKeywords/Admin_CLI/Basic_WebEM_operation.robot
Resource    ../CommonKeywords/Prepare_TL/PreparingTestline.robot
Resource    ../CommonKeywords/UE_management/Universal_UE_keywords.robot
Resource    ../CB007442/CB007442_keywords.robot

Force Tags    CA_5G_OAM   STATE_SW_UPLOADED    RAN_5G    RAN_5G_TDD    RAN_5G_FDD
...           RAN_5G_MP    RAN_5G_TDD_MP    RAN_5G_FDD_MP

Suite Setup     Run Keywords    Prepare and check TL    AND    ADMIN CLI connection
Suite Teardown    Run Keywords    ADMIN CLI disconnection    AND    Prepare and check TL

*** Variables ***
${HOST}=    192.168.255.129
${USERNAME}=     toor4nsn
${PASSWORD}=    oZPS0POrRieRtu
&{expected_statuses}    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked
${UE_SERIAL_NR}=    HZQN1876BAKC2300330
@{UE_SERIAL_NRs}=    HZQN1876BAKC2300330
${UE_control_pc}    ${tl.ues[0].ssh_connection_details.addr}
${UE_control_pc_user}    ${tl.ues[0].ssh_connection_details.username}
${UE_control_pc_password}    ${tl.ues[0].ssh_connection_details.password}
${APPSERVER_IP}    ${tl.appserver.iperf_details.ssh_connection_details.addr}
${APPS_USERNAME}    ${tl.appserver.iperf_details.ssh_connection_details.username}
${APPS_PASSWORD}    ${tl.appserver.iperf_details.ssh_connection_details.password}
${APPS_NETWORK_IF}    ${tl.appserver.iperf_details.network_interface_address}

*** Test Cases ***
[1][1.0] A5 L1 5G Loki A reset on critical failure Reset escalation procedure L3 use case
    Reset Site and wait for onAir
    FOR    ${Iteration}    IN RANGE      0    3
        Trigger LokiA recovery and check 2087 fault
    END
    Trigger LokiA escalation        BBMOD-1
    Connect to UE PC    ${UE_control_pc}  ${UE_control_pc_user}    ${UE_control_pc_password}    cpc
    Turn ONOFF Airplane Mode    ${UE_SERIAL_NRs}
    Turn ONOFF Airplane Mode    ${UE_SERIAL_NRs}
    Sleep    30s
    Return IPs      ${UE_SERIAL_NRs}     cpc     False
    [Teardown]  run keywords
    ...                         Detach all UEs    AND
    ...                         Disconnect from UE PC    AND
    ...                         run keyword if test failed    admin_cli.Reset Site    AND
    ...                         wait until keyword succeeds   900    5    Check if BTS is OnAir state

[1][2.0] L1 5G Loki reset triggered by BTS-OAM on critical failure
    Reset Site and wait for onAir
    Loki recovery triggered by OAM
    [Teardown]  run keywords
    ...                         run keyword if test failed    admin_cli.Reset Site    AND
    ...                         wait until keyword succeeds   900    5    Check if BTS is OnAir state

[1][1.0] E2 Capacity_core unit 5G L2 RT SW reset on critical failure__ reset escalation precedure
    Reset Site and wait for onAir
    FOR    ${Iteration}    IN RANGE      0    3
        Recover L2RT
    END
    Trigger L2RT escalation        BBMOD-1    Fault_name=RAT autonomous reset as recovery action
    Connect to UE PC    ${UE_control_pc}  ${UE_control_pc_user}    ${UE_control_pc_password}    cpc
    Turn ONOFF Airplane Mode    ${UE_SERIAL_NRs}
    Turn ONOFF Airplane Mode    ${UE_SERIAL_NRs}
    Sleep       30s
    Return IPs      ${UE_SERIAL_NRs}     cpc     False
    [Teardown]  run keywords
    ...                         Detach all UEs    AND
    ...                         Disconnect from UE PC    AND
    ...                         run keyword if test failed    admin_cli.Reset Site    AND
    ...                         wait until keyword succeeds   900    5    Check if BTS is OnAir state

[1][1.0] C2 Capacity core unit 5G L3 SW reset on critical failure Reset escalation procedure No L3 call instance
    Reset Site and wait for onAir
    FOR    ${Iteration}    IN RANGE      0    3
        Recover L3SW
    END
    Trigger L3SW escalation        BBMOD-1
    [Teardown]  run keywords    run keyword if test failed    admin_cli.Reset Site    AND
    ...                         wait until keyword succeeds   900    5    Check if BTS is OnAir state

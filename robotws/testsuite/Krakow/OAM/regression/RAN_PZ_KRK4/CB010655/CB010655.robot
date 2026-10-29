*** Settings ***
Documentation
...         author: Weronika Wojcik
...         contact: weronika.wojcik@nokia.com
...         BBOX5 test

Resource    testsuite/Krakow/OAM/regression/RAN_PZ_KRK4/CB010655/Resource/CB010655_common.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup         Common Suite Setup
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions
Test Teardown       Common Postconditions

*** Variables ***
${WEBUI_ADDR}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}
${TestPC_addr}         ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}     ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}     ${tl.test_pc.default_ssh_connection_details.password}
${TEST_LOG_DIRECTORY}    ${OUTPUTDIR}
${BTS_HOST_IP}    192.168.255.129
*** Test Cases ***
[1]CB010655_E_08_enhancement_the_record_of_temperature_related_dataF
    [Documentation]    This case is to verify the black box data support temperature history
    Perform commissioning on gNB to onAir state
    ...  prefix_tag=customer_scf
     Get BBOX5 file On Snapshot
     check temperature enhancement

[1]CB010655_I_11_enhancement_of_reset_counter_for_controlled_radio_reset
    [Documentation]    This case is to verify the enhancement point of reset counter
    Get BBOX5 file On Snapshot
    check Reset Counter
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=COAM
    COAM Reset Site
    sleep     300s
    Get BBOX5 file On Snapshot
    check Reset Counter after reset


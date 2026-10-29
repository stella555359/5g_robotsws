*** Settings ***
Documentation
...   CB005891-B_01_Triggering ASIRMOD reset from NetAct
...   author: Aleksandra Bialas
...   contact: aleksandra.bialas@nokia.com

Resource   taf/rfrl/bts/robot/gnb.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library    testsuite.Krakow.resources.scf.Scf    WITH NAME  scf
Library     testsuite/Krakow/OAM/regression/RAN_PZ_KRK4/CB005891_B/CB005891_B.py

Suite Setup      Common Suite Setup
Suite Teardown   Common Suite Teardown
Test Setup       Setup
Test Teardown    Teardown

*** Variables ***
${netact_address}    ${tl.nms.netact[0].ssh_connections_info[0].addr}
${netact_username}    ${tl.nms.netact[0].ssh_connections_info[0].username}
${netact_password}    ${tl.nms.netact[0].ssh_connections_info[0].password}
${KPI_name}=    kpi51a
${timeout}=    320
${measurement_point}=    NE_Terminated
${uplane_capturing}=    TRUE
${downloaded_file_pcap_gz}=    ${OUTPUT_DIR}/ipTrafficCapturing.pcap.gz

*** Test Cases ***
[1][1.0] CB005891-B_01_Triggering ASIRMOD reset from NetAct
    reset asirmod from netact  ${netact_address}  ${netact_username}  ${netact_password}
    Wait Until Keyword Succeeds   15min  15sec  Verify Setup Of All Cells
    sleep  240s
    gnblog.Collect Ims Log    log_dir=${OUTPUT_DIR}
    check reset time based on kpi  ims_dir=${OUTPUT_DIR}  kpi_name=${KPI_name}  timeout=${timeout}

*** Keywords ***
Setup
    Common Preconditions
    connect_and_start_ip_traffic_capturing  ${measurement_point}  ${uplane_capturing}

Teardown
    stop_ip_traffic_capturing_download_file_and_disconnect  ${downloaded_file_pcap_gz}
    Common Postconditions

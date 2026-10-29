*** Settings ***
Resource   ./Resource/Common.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot


# Suite Setup   Common Suite Setup
# Suite Teardown    Common Suite Teardown

*** Variables ***
${test_pc_addr}         ${tl.test_pc.default_ssh_connection_details.addr}
${test_pc_username}     ${tl.test_pc.default_ssh_connection_details.username}
${test_pc_password}     ${tl.test_pc.default_ssh_connection_details.password}

# ${ssh_addr}         ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${ssh_username}     ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
# ${ssh_password}     ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}

${ssh_addr}         ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ssh_username}     ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ssh_password}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

${webem_addr}         ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${webem_username}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${webem_password}     ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ue_index}   0


*** Test Cases ***
CNI_92456_Synchronous_L1_and_L2_log_and_snapshot_capture_upon_automatic_snapshot_trigger_occurrence_for_4G
    [Setup]   robot_common_operations.Common Case Setup
    Start Syslog Process   test_pc_addr=${test_pc_addr}   test_pc_username=${test_pc_username}   test_pc_password=${test_pc_password}
    # Start Collect L1 Journal Logs   ssh_addr=${ssh_addr}   ssh_username=${ssh_username}   ssh_password=${ssh_password}

    Configure L1 IQ   webem_addr=${webem_addr}    webem_username=${webem_username}   webem_password=${webem_password}
    Configure L1 UL Event   ssh_addr=${ssh_addr}   ssh_username=${ssh_username}   ssh_password=${ssh_password}

    Run Keyword And Ignore Error   CNI-92456 L3 Call
#    Wait Until Keyword Succeeds   3x   5min   CNI-92456 L3 Call

    Stop Syslog Process   test_pc_addr=${test_pc_addr}   test_pc_username=${test_pc_username}   test_pc_password=${test_pc_password}
    ${syslog_path}   Save Syslog Process   test_pc_addr=${test_pc_addr}   test_pc_username=${test_pc_username}   test_pc_password=${test_pc_password}

    ${output}   OperatingSystem.Run   cat ${syslog_path} | grep "Freezing TTI trace buffers!"
    Should Contain   ${output}   Freezing TTI trace buffers!
    # Stop Collect L1 Journal Logs      ssh_addr=${ssh_addr}   ssh_username=${ssh_username}   ssh_password=${ssh_password}

   [Teardown]   Siso Common Save Logs

*** Keywords ***
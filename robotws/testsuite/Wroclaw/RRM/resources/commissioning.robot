*** Settings ***
Library   OperatingSystem
Library   taf.gnb.oam.commissioning  WITH NAME   commissioner
Library   testsuite.Wroclaw.RRM.resources.webui.WebuiInterface   WITH NAME   WebUI

Resource  ./preconditions.robot

*** Variables ***
${SSH_AUTHENTICATION_TIMEOUT}          2 min
${SSH_AUTHENTICATION_RETRY_INTERVAL}   10 sec
${scf_filename}=                       ${TEMPDIR}/scf_file.xml


*** Keywords ***
recommission with given parameters
    [Arguments]    ${parameters}
    download current scf
    commissioner.modify_scf     input_scf=${scf_filename}         output_scf=${scf_filename}
    ...           parameters_lists=${parameters}
    commissioner.commission     oam_ip=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    scf_xml=${scf_filename}
    remove file    path=${scf_filename}
    wait until keyword succeeds      5 min     30 sec     Check VMs availability

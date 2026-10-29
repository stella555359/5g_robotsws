*** Settings ***
Documentation
...  keywords for handling connections
...
...  author/contact: damian.silkowski@nokia.com, I_5G_TLM_WRO_GMS <I_5G_TLM_WRO@internal.nsn.com>

Library         OperatingSystem
Library         Collections
Library         String
Library         ute_ue
Library         taf.ue  WITH NAME   taf_ue
Library         taf.transport.ssh  WITH NAME  ssh
Library         testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData

*** Keywords ***
Create COAM session
    [Arguments]  ${bts_host}=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...          ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...          ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...          ${alias}=BTS_coam
    ${release}=    testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData.get_admin_release
    coam_cli.connect_to  bts_host=${bts_host}  username=${username}
    ...              password=${password}  name=${alias}    release=${release}


Teardown COAM session
    [Arguments]  ${alias}=BTS_coam
    coam_cli.teardown  connection=${alias}


Create COAM LTE session
    [Arguments]  ${bts_host}=${tl.enbs[0].oam_ip.v4}
    ...          ${username}=Nemuadmin
    ...          ${password}=nemuuser
    ...          ${alias}=BTS_coam_LTE
    ${release}=    testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData.get_admin_release
    coam_cli.connect_to  bts_host=${bts_host}  username=${username}
    ...              password=${password}  name=${alias}    release=${release}


Teardown COAM LTE session
    [Arguments]  ${alias}=BTS_coam_LTE
    coam_cli.teardown  connection=${alias}


Connect to ASIK
    [Arguments]
    ...          ${hostname}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...          ${username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...          ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...          ${alias}=asik
    ssh.connect_to        hostname=${hostname}
    ...                   username=${username}
    ...                   password=${password}
    ...                   alias=${alias}


Force ReConnect to ASIK
    [Arguments]  ${alias}=asik
    ssh.force_reconnect  connection=${alias}


Disconnect from ASIK
    [Arguments]  ${alias}=asik
    ssh.disconnect  connection=${alias}


Connect to real core appserver
    ssh.connect_to  hostname=${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...             username=${tl.appserver.iperf_details.ssh_connection_details.username}
    ...             password=${tl.appserver.iperf_details.ssh_connection_details.password}
    ...             alias=realcore_app


Disconnect from real core appserver
    [Arguments]  ${alias}=realcore_app
    ssh.disconnect  connection=${alias}


Connect to UE PC
    [Arguments]  ${QC_PC_addr}=${tl.ues[0].ssh_connection_details.addr}
    ...          ${QC_PC_usr}=${tl.ues[0].ssh_connection_details.username}
    ...          ${QC_PC_pass}=${tl.ues[0].ssh_connection_details.password}
    ...          ${alias}=ue_pc
    ssh.connect_to  hostname=${QC_PC_addr}  username=${QC_PC_usr}
    ...             password=${QC_PC_pass}  alias=${alias}


Disconnect from UE PC
    [Arguments]  ${alias}=ue_pc
    ssh.disconnect  connection=${alias}

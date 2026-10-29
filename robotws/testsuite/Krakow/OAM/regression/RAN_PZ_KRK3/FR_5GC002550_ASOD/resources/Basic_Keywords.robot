*** Settings ***

Library  BuiltIn
Library  Collections
Library  String
Library  taf.gnb.oam.coam.admin     WITH NAME     admin_cli
Resource         taf/rfrl/bts/robot/common/gnb_cu.robot
Resource         taf/rfrl/bts/robot/common/gnb_scf.robot
Resource         taf/rfrl/bts/robot/common/gnb_bbu.robot

*** Variables ***
${webui_username}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${webui_password}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gNB_IP_MPLANE_LOCAL}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${gNB_MPLANE_IF_PORT}     443

*** Keywords ***
ADMIN connection
    [Documentation]
    ...     Common keyword to established connection with ADMIN API of tested gNB
    admin_cli.connect_to    bts_host=${gNB_IP_MPLANE_LOCAL}
    ...                     bts_port=${gNB_MPLANE_IF_PORT}
    ...                     username=${webui_username}
    ...                     password=${webui_password}

ADMIN disconnection
    [Documentation]
    ...     Disconnects connection to gNB ADMIN
    admin_cli.teardown

Prepare Setup
    [Arguments]  ${branch_scf_CU}   ${scf_DU}
    ${Release}   Fetch From Left    ${ENB_BUILD}    .
    ${scf_path}  Set Variable If  "${Release}"=="5G_0"  ${trunk_scf_CU}
    ...          "${Release}"!="5G_0"  ${branch_scf_CU}
    Perform CU Commissioning    ${scf_path}
    Wait Until Keyword Succeeds  5min  15 sec  Verify CU state is operational
    Log to console   ${scf_path_DU}
    Log to console   ${scf_path_trunk}
    Perform Full Commissioning on gNB  scf_file=${scf_DU}  skip_parameter_relation_errors=True  validate_scf=False
    Wait Until Keyword Succeeds  10min  30s  Verify Procedural and Blocking State  procedural_states=Configured

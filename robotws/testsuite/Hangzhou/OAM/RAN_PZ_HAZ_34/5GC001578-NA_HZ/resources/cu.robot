*** Settings ***
Documentation
...               Author: zma
...               Contact: zhiyuan.ma@nokia-sbell.com
...               Group: 5G_PZ_MMW_NJN_1_SG
...               Team in charge: I_NJ_MMW_SYVE_GMS

Library     OperatingSystem
Library     DateTime
Library     taf.gnb.oam.coam.cu      WITH NAME   cu_rest
Library    taf.selenium.gnb.oam.coam.cu   WITH NAME   cu_sel
Library    taf.transport.ssh  WITH NAME  ssh

*** Variables ***
${DEFAULT_SNAPSHOT_PATH}=  /tmp/snapshot
${LSS_USERNAME}=    coam
${LSS_PASSWORD}=    zO&n1W*ktp7
${LSS_HOME}=        /home/${LSS_USERNAME}
${DEFAULT_DELTA_PLAN}=  DELTA-PLAN-1
${CURRENT_PLAN}=  CURRENT_PLAN

*** Keywords ***
Connect To CU using Rest
    [Arguments]     ${version}=cuoam_19b
    cu_rest.connect to          host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...                         port=${tl.gnbs[0].cu.oam_http_connection_details.port}
    ...                         username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                         cu_version=${version}
    ...                         password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                         secure=${True}

Disconnect To CU Using Rest
    cu_rest.disconnect

Create Temporary Directory For Snapshot
    [Return]  ${dir}
    ${date}=  Get Current Date  result_format=epoch
    ${dir}=  Set Variable  /tmp/snapshot${date}
    Create Directory  ${dir}
    Directory Should Be Empty  ${dir}

Get Single File In Directory
    [Arguments]  ${dir}
    [Return]  ${file_path}
    ${files}=  List Files In Directory  ${dir}
    ${file_path}=  Set Variable  ${dir}/${files[0]}

Get CU Snapshot Using Rest
    [Return]  ${snapshot_path}
    ${tmp_dir}=  Create Temporary Directory For Snapshot
    cu_rest.get local snapshot  directory=${tmp_dir}
    ${snapshot_path}=  Get Single File In Directory  ${tmp_dir}

Connect To CU Using Selenium
    Run Keyword And Ignore Error  cu_sel.set_download_dir  ${DEFAULT_SNAPSHOT_PATH}
    cu_sel.enable_virtual_display
    Sleep  5s
    cu_sel.login   url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...               username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...               password=${tl.gnbs[0].cu.oam_http_connection_details.password}

Disconnect To CU Using Selenium
    cu_sel.logout
    cu_sel.disable_virtual_display

Trigger CU Snapshot Using Selenium
    [Arguments]    ${coverage}  ${location}  ${filter}=${None}  ${notes}=${None}
    Wait until Keyword Succeeds  10m  1m  cu_sel.snapshot_collection_settings       ${coverage}
    ...                                                                             ${location}
    ...                                                                             ${filter}
    ...                                                                             ${notes}
    Wait until Keyword Succeeds  10m  1m  cu_sel.collect_snapshot  snapshot_waiting_timeout=300

Get CU Local Snapshot Using Selenium
    [Arguments]    ${coverage}  ${filter}=${None}    ${notes}=${None}
    [Return]  ${snapshot_path}
    Create Directory  ${DEFAULT_SNAPSHOT_PATH}
    Empty Directory  ${DEFAULT_SNAPSHOT_PATH}
    Trigger CU Snapshot Using Selenium      ${coverage}
    ...                                     Local
    ...                                     ${filter}
    ...                                     ${notes}
    ${snapshot_path}=  Get Single File In Directory  ${DEFAULT_SNAPSHOT_PATH}

Clear Snapshot Floder On Lss Server For CU
    [Arguments]  ${host}
    ssh.connect_to      hostname=${host}
    ...                 username=${LSS_USERNAME}
    ...                 password=${LSS_PASSWORD}
    ...                 alias=lss
    ssh.execute  command=rm -rf ${LSS_HOME}/*  connection=lss
    ssh.disconnect    connection=lss

Check If Snapshot Exist On LSS Server For CU
    [Arguments]  ${host}
    ssh.connect_to      hostname=${host}
    ...                 username=${LSS_USERNAME}
    ...                 password=${LSS_PASSWORD}
    ...                 alias=lss
    ${files}=  ssh.execute  command=ls ${LSS_HOME}  connection=lss
    Should Match    ${files}    MRBTS*
    ssh.disconnect    connection=lss

Delete Default Delta Plan Using Selenium
    Wait until Keyword Succeeds  10m  1m  cu_sel.choose_plan  ${DEFAULT_DELTA_PLAN}
    Wait until Keyword Succeeds  10m  1m  cu_sel.delete_plan  timeout=${60}

Delete parameter lssCongig Using Selenium
    Run Keyword And Ignore Error  Delete Default Delta Plan Using Selenium
    Wait until Keyword Succeeds  10m  1m  cu_sel.create_delta_plan  ${DEFAULT_DELTA_PLAN}
    Wait until Keyword Succeeds  10m  1m  cu_sel.choose_plan  ${DEFAULT_DELTA_PLAN}
    Wait until Keyword Succeeds  10m  1m
    ...     cu_sel.set_parameter_value  object_name=TRBLCADM-1
    ...                                 filter_param=Diagnostic Snapshot destination
    ...                                 abbr=diagSnapDestination
    ...                                 new_value=netact
    Wait until Keyword Succeeds  10m  1m
    ...     cu_sel.delete_parameter  object_name=TRBLCADM-1
    ...                              filter_param=Local symptoms server configuration
    ...                              abbreviation=lssConfig
    cu_sel.activate_plan

Check LSS Server Using Selenium
    [Arguments]  ${host}  ${port}
    Wait until Keyword Succeeds  10m  30s  cu_sel.choose_plan  ${CURRENT_PLAN}
    ${lssIPaddress}=  Wait until Keyword Succeeds  10m  1m
    ...     cu_sel.get_parameter_value  object_name=TRBLCADM-1  
    ...                                 filter_param=Local symptoms server IP address
    ...                                 abbreviation=lssIPaddress
    Should Be Equal  ${lssIPaddress}  ${host}
    ${lssPortNo}=  Wait until Keyword Succeeds  10m  1m
    ...     cu_sel.get_parameter_value  object_name=TRBLCADM-1
    ...                                 filter_param=Local symptoms server IP port number
    ...                                 abbreviation=lssPortNo
    Should Be Equal  ${lssPortNo}  ${port}

Config LSS Server Using Selenium
    [Arguments]  ${host}  ${port}
     Wait until Keyword Succeeds  10m  1m  cu_sel.choose_plan  ${CURRENT_PLAN}
    ${value}=   Wait until Keyword Succeeds  10m  1m
    ...     cu_sel.get_parameter_value  object_name=TRBLCADM-1
    ...                                 filter_param=Diagnostic Snapshot destination
    ...                                 abbreviation=diagSnapDestination
    Run Keyword If  '${value}'=='lss'  Delete parameter lssCongig Using Selenium

    Run Keyword And Ignore Error  Delete Default Delta Plan Using Selenium
    Wait until Keyword Succeeds  10m  1m  cu_sel.create_delta_plan  ${DEFAULT_DELTA_PLAN}
    Wait until Keyword Succeeds  10m  1m  cu_sel.choose_plan  ${DEFAULT_DELTA_PLAN}
    Wait until Keyword Succeeds  10m  1m
    ...     cu_sel.add_element  object_name=TRBLCADM-1
    ...                         filter_param=Local symptoms server configuration
    ...                         abbreviation=lssConfig
    Wait until Keyword Succeeds  10m  1m
    ...     cu_sel.set_parameter_value  object_name=TRBLCADM-1
    ...                                 filter_param=Diagnostic Snapshot destination
    ...                                 abbr=diagSnapDestination
    ...                                 new_value=lss
    Wait until Keyword Succeeds  10m  1m
    ...     cu_sel.set_parameter_value  object_name=TRBLCADM-1
    ...                                 filter_param=Local symptoms server IP address
    ...                                 abbr=lssIPaddress
    ...                                 new_value=${host}
    Wait until Keyword Succeeds  10m  1m
    ...     cu_sel.set_parameter_value  object_name=TRBLCADM-1
    ...                                 filter_param=Local symptoms server IP port number
    ...                                 abbr=lssPortNo  new_value=${port}
    cu_sel.activate_plan

Add Coam User
    [Arguments]    ${connection}=TestPC
    ssh.connect_to     hostname=${host_lss}    username=${test_pc_name}    password=${test_pc _pass}    alias=${connection}
    ssh.execute  command=sudo userdel -r coam    connection=${connection}
    ssh.execute  command=sudo useradd -m coam -g sudo -s /bin/bash -d /home/coam    connection=${connection}
    ssh.execute  command=chmod 777 ${CURDIR}/test.sh    connection=${connection}
    ssh.execute  command=cd ${CURDIR};./test.sh   connection=${connection}
    [Teardown]  ssh.disconnect    connection=${connection}

All Case Suite Setup
    [Arguments]
    CI_interface.Common Suite Setup
    Add Coam User

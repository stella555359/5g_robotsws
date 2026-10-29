*** Settings ***
Documentation    The keyword for test mode switch of 72a/72e
...              Author: Chen Jun
...              Contact: jun.8.chen@nokia-sbell.com


*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}

*** Keywords ***
Act Ecpri Mode Switch
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${scf_path}    ${switch_to_mode}=72e    ${gnb_index}=0    ${log_path}=${TS_CASE_LOG_PATH}
    ${vendor_file_name}    Download Vendor File    gnb_index=${gnb_index}    log_path=${log_path}
    Sleep    5sec
    Modify Vendor file    vendor_file_name=${vendor_file_name}    switch_to_mode=${switch_to_mode}
    Sleep    5sec
    Load Vendor File And Commission    scf_path=${scf_path}
    ...                                vendor_file_name=${vendor_file_name}
    ...                                gnb_index=${gnb_index}
    ...                                log_path=${log_path}
    ...                                switch_to_mode=${switch_to_mode}

Download Vendor File
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM    ${gnb_index}=0
    ${vendor_file_name}    Set Variable    ${log_path}/vendor_download.xml
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    coam.download_vendor_file    target_file_name=${vendor_file_name}    connection=${connection}
    [Return]    ${vendor_file_name}
    [Teardown]    Run Keyword and Ignore Error    COAM Teardown gnb connections    connection=${connection}

Modify Vendor file
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${vendor_file_name}
    ...            ${switch_to_mode}=72e
    ...            ${alias}=test_pc
    ...            ${test_pc_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${test_pc_name}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${test_pc_password}=${tl.test_pc.default_ssh_connection_details.password}
    Log To Console    \n***start to Modify Vendor file***
    ${param_value}    Set Variable If    '${switch_to_mode}'=='72e'    Ecpri72eULDL    disabled
    ${vendor}   Set Variable    sudo sed -i 's|<p name="actEcpri72e">.*</p>|<p name="actEcpri72e">${param_value}</p>|g' ${vendor_file_name}
    csn.Connect to     hostname=${test_pc_ip}    username=${test_pc_name}    password=${test_pc_password}    alias=${alias}
    csn.execute    command=${vendor}    connection=${alias}
    [Teardown]    Run Keyword and Ignore Error    csn.disconnect    connection=${alias}

Load Vendor File And Commission
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${scf_path}    ${vendor_file_name}    ${timeout}=${120}    ${gnb_index}=${0}
    ...            ${save_location}=Local    ${log_path}=${TS_CASE_LOG_PATH}    ${switch_to_mode}=72e
    Log    ${save_location}
    Wait Until Keyword Succeeds    5min    20sec    COAM Navigate to login page via webUI    timeout=${timeout}
    ...                                                                                      gnb_index=${gnb_index}
    ...                                                                                      download_dir=${log_path}
	selenium_coam.enable_virtual_display
    ${result}   selenium_coam.load_vendor_file_and_validate    file_path=${vendor_file_name}
    Run keyword if   '${result}'=='Validation failed!'    selenium_coam.load_vendor_file_and_validate    file_path=${vendor_file_name}
    Sleep   5sec
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}   timeout=${180}
    Run Keyword If   '${switch_to_mode}'=='72e'    WA For 11026
    Log To Console    Start to validate and activate
    selenium_coam.validate_plan    timeout=300
    selenium_coam.activate_plan    timeout=300    activate_plan_despite_errors=${True}
    Sleep   60 sec
    Log To Console    activate done!wait for gnb on air......
    Wait Gnb Ready And Cell On Air    timeout=30 min    connection=GNB_OAM0
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    selenium_coam.disable_message_box    AND
    ...                           Run Keyword And Ignore Error    COAM selenium logout

WA For 11026
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                                  filter_param=Activate baseband resource pooling FR1 TDD extension
    ...                                  abbr=actBbPoolExtensionTddFr1
    ...                                  new_value=false
    ...                                  bts_configuration=Planned
    ...                                  timeout=${120}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                                  filter_param=Activate baseband resource pooling FR1 TDD
    ...                                  abbr=actBbPoolTddFr1
    ...                                  new_value=false
    ...                                  bts_configuration=Planned
    ...                                  timeout=${120}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                                  filter_param=Activate enhanced algorithm of baseband resource pooling FR1 TDD
    ...                                  abbr=actBbPoolTddFr1AlgEnh
    ...                                  new_value=false
    ...                                  bts_configuration=Planned
    ...                                  timeout=${120}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                                  filter_param=Activate baseband resource pooling FR1 TDD enhancements
    ...                                  abbr=actBbPoolTddFr1Enh
    ...                                  new_value=false
    ...                                  bts_configuration=Planned
    ...                                  timeout=${120}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                                  filter_param=Activate large baseband resource pooling FR1 TDD
    ...                                  abbr=actLargeBbPoolTddFr1
    ...                                  new_value=false
    ...                                  bts_configuration=Planned
    ...                                  timeout=${120}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                                  filter_param=Activate refinement of large BB resource pooling FR1 TDD
    ...                                  abbr=actLargeBbPoolTddFr1Enh
    ...                                  new_value=false
    ...                                  bts_configuration=Planned
    ...                                  timeout=${120}

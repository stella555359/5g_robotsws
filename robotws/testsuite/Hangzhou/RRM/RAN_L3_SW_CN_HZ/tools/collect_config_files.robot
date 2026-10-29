*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Resource          ../resources/DevHZ5_resource.robot

*** Test Cases ***
Collect Online Configuration Files
    [Tags]    t1
    [Setup]    Test Setup    online_configs
    Get Current Scf File  local_dir_path=${SAVE LOG DIRECTORY}
    ...  file_name=SCFC_1.xml
    Get Wts Config File    ${SAVE LOG DIRECTORY}/iphy.xml
    Get Enb Swconfig File    ${SAVE LOG DIRECTORY}/gnb_swconfig.txt
    Get Wts File    /rom/swconfig.txt    ${SAVE LOG DIRECTORY}/ap_swconfig.txt
    Execute Cmd On Pc    cp -r ${WTS_DIR}/*.cfg ${SAVE LOG DIRECTORY}/
    Execute Cmd On Pc    cp -r ${WTS_DIR}/AirphoneConfig.xml ${SAVE LOG DIRECTORY}/

#Copy Configs From testline init Folder
#    [Tags]    t2
#    [Setup]    Test Setup    gerrit
#    Migrate Scf    /home/ute/testline_init_results/configs/scfc.xml    ${SAVE LOG DIRECTORY}/SCFC_1.xml
#    Execute Cmd On Pc    cp /home/ute/testline_init_results/configs/iphy.xml ${SAVE LOG DIRECTORY}/iphy.xml
#    Execute Cmd On Pc    cp /home/ute/testline_init_results/configs/sm_swconfig.txt ${SAVE LOG DIRECTORY}/gnb_swconfig.txt
#    Execute Cmd On Pc    cp /home/ute/testline_init_results/configs/sim_swconfig.txt ${SAVE LOG DIRECTORY}/ap_swconfig.txt
#    Execute Cmd On Pc    cp /home/ute/testline_init_results/configs/basic_setup.cfg ${SAVE LOG DIRECTORY}/wts.cfg
#    Execute Cmd On Pc    cp /home/ute/testline_init_results/configs/AirphoneConfig.xml ${SAVE LOG DIRECTORY}/
#    ${ret1}=    Execute Cmd On Pc    cp /home/ute/testline_init_results/configs/AirphoneConfig.xml ${SAVE LOG DIRECTORY}/
#    ${status}=    Run Keyword and Return Status    Should Contain    ${ret1}    No such file
#    Run Keyword If    '${status}'=='False'    Execute Cmd On Pc    sed -i "s/file=.*.xml/file=AirphoneConfig.xml/g" ${SAVE LOG DIRECTORY}/wts.cfg


*** Keywords ***
Suite Setup
    _Create Suite Log Directory
    ${bts_port}    ${use_ssl}    Define Admin Port
    Setup Admin    bts_port=${bts_port}    use_ssl=${use_ssl}    admin_api_log_dir=${SAVE LOG DIRECTORY}
    ...   timeout=120    bts_host=${FTM_IP}
    Setup Enb Fsm Access    fallback_prompt=#    host=${FTM_IP}    prompt=>
    Setup Wts Fsm Access    fallback_prompt=#

Test Setup
    [Arguments]    ${sub_folder}
    Create Directory    ${SUITE_LOG_DIRECTORY}/${sub_folder}
    Set Suite Variable    ${SAVE LOG DIRECTORY}    ${SUITE_LOG_DIRECTORY}/${sub_folder}

Test Teardown
    Comment    Common Test Teardown And Stop Capture Logs

Suite Teardown
    Run Keyword And Ignore Error    Teardown All Aliases For Admin
    Run Keyword And Ignore Error    Teardown All Aliases For Enb Fsmaccess
    Run Keyword And Ignore Error    Teardown All Aliases For Wts Fsmaccess

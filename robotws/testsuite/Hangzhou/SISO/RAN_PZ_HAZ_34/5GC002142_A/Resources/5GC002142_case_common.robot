*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource    ../../5GC000702/Resources/5GC000702_common_ute.robot

*** Variables ***
${expected_ul_tput_64qam}          ${60}
${expected_dl_tput_64qam_rank4}    ${942}
${expected_dl_tput_256qam_rank4}   ${1270}
@{SWCONFIG_PARA_DLRANK_4_1Pol}    0x580195=0
&{actDl256Qam_param_update_cell_1}    dist_name=NRBTS-1/NRCELL-1    parameter=actDl256Qam    value=true
&{actDl256Qam_param_update_cell_2}    dist_name=NRBTS-1/NRCELL-2    parameter=actDl256Qam    value=true
@{parameters_to_update}    &{actDl256Qam_param_update_cell_1}     &{actDl256Qam_param_update_cell_2}

*** Keywords ***
5GC001451_2_subSector_1xPol_CloseLoop_4x4_256QAM_Rank4
    Change To Closeloop 256QAM And Change CHBW
    Start L3 Call And Verify Throughput    ul_data_transfer=40M
    ...                                 dl_data_transfer=800M
    ...                                 expect_ul_tput=27
    ...                                 expect_dl_tput=630
   [Teardown]    Recover Test Env In Case Teardown

5GC001451_4_subSector_OpenLoop_2x2_256QAM_Rank2
    ${modify_param}    Modify DL MIMO Mode    dlmimomode=2x2 Open Loop Spatial Multiplexing
    ${chbw_param}    Modify All Chbw Para    bandwidth=40MHz
    ${modify_param_list}    combine lists    ${chbw_param}    ${modify_param}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param_list}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min
    General_SiSo_Cell_lock_and_unlock    with_call=${False}
    Start L3 Call And Verify Throughput    ul_data_transfer=40M
    ...                                 dl_data_transfer=700M
    ...                                 expect_ul_tput=22
    ...                                 expect_dl_tput=480

Change To Closeloop 256QAM And Change CHBW
    [Arguments]    ${bandwidth}=50MHz    ${gscn}=none    ${swconfig_modify}=${SWCONFIG_PARA_DLRANK_4_1Pol}
    ...            ${modify_value}=${parameters_to_update}
    Connect to Common Unit Master    alias=ASIK Master
    swconf.Download swConfig file from asik to test pc    localFilePath=${TS_CASE_LOG_PATH}/swconfig.txt
    ...                                                   asik_alias=ASIK Master
    ...                                                   remoteFilePath=/ffs/run/swconfig.txt
    swconf.Modify swConfig file    parametersList=${swconfig_modify}    filePath=${TS_CASE_LOG_PATH}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${TS_CASE_LOG_PATH}/swconfig.txt    asik_alias=ASIK Master
    csn.disconnect    connection=ASIK Master
    ${chbw_param}    Modify All Chbw Para    bandwidth=${bandwidth}    gscn=${gscn}
    ${modify_param_list}    combine lists    ${chbw_param}    ${modify_value}
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${modify_param_list}    timeout=900
    Coam Wait For Gnb Ready And Cell Setup    timeout=15 min

Recover Test Env In Case Teardown
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    Run Keyword And Ignore Error    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=${ASIK_MASTER_ALIAS}
    Run Keyword And Ignore Error    Perform BTS Site Reset
    Run Keyword And Ignore Error    sleep    60
    Wait Until Keyword Succeeds    15 min    30 sec    connection_alias_store.Connect to Capacity Unit Master
    Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air via WebUI
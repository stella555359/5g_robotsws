*** Settings ***
Documentation
...   Author: zhuo.1.gao@nokia-sbell.com
...   Contact: zhuo.1.gao@nokia-sbell.com
...   Description: CB014730

Resource           ../../../resources/RAN_PZ_HAZ_34/lines/SG6/Module_And_KW/interface_resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot
# Suite Setup    Common MultiBTS Suite Setup For RRM Migration
# Suite Teardown    Common Suite Teardown For RRM Migration
# Test Setup        Common Test Setup For RRM Migration
# Test Teardown     Common Test Teardown For RRM Migration
# Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1    VRF_HAZ_T06
# ...    CLOUD_5G_CLASSICAL_ANDROIDX2_CA_ASIA_ABIAL_AZNC_FXEB
# Test Timeout      120 minutes

Suite Setup     TMO_Common_Suite_Setup   is_commission=${False}   ute_space=10    whether_do_prepare_ue=${False}
# ...    gnb_scf_name=CB013205
Suite Teardown   Run Keyword And Ignore Error    COAM Teardown gnb connections
Force Tags   SG_06


*** Variables ***
${SERIALS}      RFCWA0G52XE
${COUNTER_TIME}    120s
${DL_IPERF_SERVER}    10.68.254.195
${IPERF_OPTION}    -b 200M -t 1800 -u -i 1 -l 1024 -p 5504
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

*** Test Cases ***
[1]CB014730-SR-A_05_RND flag is disabled in official release
    [Documentation]
    ...    n3(AHEGB) is PCELL,N40(AKNB) is scell
    # [Setup]    Case Precondition
    # sleep      60s

    ADMIN Reset All Rad Debug Parameters 14730
    Sleep    2s
    BTS Operation    operation=bts_reset            product_type=gnb    bts_index=0    need_verify=True
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=SITE_ONAIR


*** Keywords ***
ADMIN Set RAD debug parameters OamApigwManager
    wait until keyword succeeds   3x   1min    eNB_COAM.Login
    &{rad_parameter_0}    create dictionary   name=EnableUnpublishedMode    value=true
    @{rad_parameters}   Create List   ${rad_parameter_0}
    coam.set_multiple_rad_debug_parameters
    ...    domain=OamApigwManager
    ...    persistency=Persistent
    ...    rad_parameters=${rad_parameters}
    ...    connection=ENB
    [Teardown]  Run Keyword And Ignore Error    eNB_COAM.Logout

ADMIN Set RAD debug parameters Oam
    wait until keyword succeeds   3x   1min    eNB_COAM.Login
    &{rad_parameter_0}    create dictionary   name=OAM_FEAT_RUMAG_EnableUnpublishedMode    value=1
    @{rad_parameters}   Create List   ${rad_parameter_0}
    coam.set_multiple_rad_debug_parameters
    ...    domain=Oam
    ...    persistency=Persistent
    ...    rad_parameters=${rad_parameters}
    ...    connection=ENB
    [Teardown]  Run Keyword And Ignore Error    eNB_COAM.Logout



ADMIN Reset All Rad Debug Parameters 14730
    wait until keyword succeeds   3x   1min    eNB_COAM.Login
    coam.Reset All Rad Debug Parameters   connection=ENB
    [Teardown]  Run Keyword And Ignore Error    eNB_COAM.Logout


set_testline_cell-33_status_onair
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR    distname_id=NRCELL-33

Case Setup
    Log To Console    Case Setup

Case Teardown
    Log To Console    Case Teardown
    # Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Disconnect All VM

Change AKNB to nominalBandwidth
    @{para_list}      Create List    semiDynamicBwSize
    @{mo_list}        Create List    MRBTS-6210/NRBTS-6210/NRCELL-1001
    @{value_list}     Create List    nominalBandwidth
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

Change AKNB to limitedBandwidth
    @{para_list}      Create List    semiDynamicBwSize
    @{mo_list}        Create List    MRBTS-6210/NRBTS-6210/NRCELL-1001
    @{value_list}     Create List    limitedBandwidth
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

Change CB009849_C_actDlForceRankDowng_to_dlVoNRCtrlOnly
    &{staged_dict}    create dictionary   maxMcsForDlSrb=${19}  maxMcsForDlVoNRCtrl=${19}
    @{staged_param_list}     Create List   ${staged_dict}
    @{value_list}     Create List   ${staged_param_list}    dlVoNRCtrlOnly
    @{para_list}      Create List   dlForceRankDowngCtl    actDlForceRankDowng
    @{mo_list}        Create List   MRBTS-37421/NRBTS-37421/NRCELL-21    MRBTS-37421/NRBTS-37421/NRCELL-21
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    paramter update result: ${out}



block_other_gnb_cells_1078_4001
    BTS Operation    operation=cell_block           product_type=gnb    bts_index=0    distname_id=NRCELL-1078     need_verify=True

block_other_enb_cells_88_3
    BTS Operation    operation=cell_block           product_type=enb    bts_index=0    distname_id=LNCELL-88     need_verify=True
    BTS Operation    operation=cell_block           product_type=enb    bts_index=0    distname_id=LNCELL-3     need_verify=True

unblock_all_6210_cells
    BTS Operation    operation=cell_unblock           product_type=gnb    bts_index=0    distname_id=NRCELL-1078     need_verify=True


eNB_COAM.Login
    [Arguments]    ${bts_host}=${WEBUI_IP}    ${username}=${WEBUI_USERNAME}    ${password}=${WEBUI_PASSWORD}    ${bts_port}=${443}
    ...    ${log_dir}=${OUTPUT_DIR}    ${alias}=ENB
    coam.connect_to    bts_host=${bts_host}    bts_port=${bts_port}    username=${username}    password=${password}    use_ssl=${True}
    ...    update_interval=${5000}    admin_api_log_dir=${log_dir}    name=${alias}

eNB_COAM.Logout
    [Arguments]    ${connection}=ENB
    coam.teardown    connection=${connection}
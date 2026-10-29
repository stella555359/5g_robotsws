*** Settings ***
Documentation
...   author: GAO ZHUO
...   contact: zhuo.1.gao@nokia-sbell.com
...   this is a robot case about CB012299_D

Resource          ../Resources/common_resource.robot
Force Tags        CRT    RAN_5G    STATE_SKIP_AGENT
...               SBTS00   CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG07_ST_RRM    TA_LEVEL_22
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM

*** Variables ***
${DEBUG_MODE}            ${TRUE}
# @{mo_list}               MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31
# ...                      MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31


*** Test Cases ***
CB014730-SR-A_01_support of CB014730 RND flag and sync of this RND information to relative components
    [Documentation]
    ...    n3(AHEGB) is PCELL,N40(AKNB) is scell
    # [Setup]    Case Precondition
    # sleep      60s
    ADMIN Set RAD debug parameters OamApigwManager
    Sleep    3s
    ADMIN Set RAD debug parameters Oam
    Sleep    3s
    BTS Operation    operation=bts_reset            product_type=gnb    bts_index=0    need_verify=True
    Sleep    2s
    ADMIN Reset All Rad Debug Parameters 14730
    Sleep    2s
    BTS Operation    operation=bts_reset            product_type=gnb    bts_index=0    need_verify=True

*** Keywords ***
ADMIN Set RAD debug parameters OamApigwManager
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    &{rad_parameter_0}    create dictionary   name=EnableUnpublishedMode    value=true
    @{rad_parameters}   Create List   ${rad_parameter_0}
    coam.set_multiple_rad_debug_parameters
    ...    domain=OamApigwManager
    ...    persistency=Persistent
    ...    rad_parameters=${rad_parameters}
    ...    connection=COAM
    [Teardown]  Run Keyword And Ignore Error    COAM_Admin.Logout

ADMIN Set RAD debug parameters Oam
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    &{rad_parameter_0}    create dictionary   name=OAM_FEAT_RUMAG_EnableUnpublishedMode    value=1
    @{rad_parameters}   Create List   ${rad_parameter_0}
    coam.set_multiple_rad_debug_parameters
    ...    domain=Oam
    ...    persistency=Persistent
    ...    rad_parameters=${rad_parameters}
    ...    connection=COAM
    [Teardown]  Run Keyword And Ignore Error    COAM_Admin.Logout



ADMIN Reset All Rad Debug Parameters 14730
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    coam.Reset All Rad Debug Parameters   connection=COAM
    [Teardown]  Run Keyword And Ignore Error    COAM_Admin.Logout


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

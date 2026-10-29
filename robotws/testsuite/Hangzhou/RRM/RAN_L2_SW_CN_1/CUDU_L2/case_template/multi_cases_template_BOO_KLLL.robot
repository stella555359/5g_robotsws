*** Settings ***
## Please put this file to ../../CB009169 to excute, it is not debug success
# Suite Setup     Run Keywords    Suite Setup For Common Setting    iphy_file=${iphy_file}
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCFC_601}    iphy_file=${IPHY_XML_601}
...                             swconfig_param=${swconfig_param}
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_601}
Suite Teardown    Common Suite Teardown    debug
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown    debug
Resource          ../../CUDU_L2/common_setup_teardown.robot
Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD

*** Variables ***
${SCF_PATH}                       ${CURDIR}/Config
${WTS_DIR}                        /opt/wts/latest
${EGATE_FILE}                     /opt/iphy/latest/egate_console.log
${WTS_LOCAL}                      ${CURDIR}/Resources/wts
${swconfig_param}                 0x580692=1
#AA602_603
${FULL_SCF_602}                   CB009169_Aa602_scfc.xml
${DELTA_SCF_602}                  Delta_CB009169_Aa602.json
${DELTA_SCF_603}                  Delta_CB009169_Aa603.json
${IPHY_FILE_602}                  ${CURDIR}/Resources/wts/iphy_4F_2T_Aa701.xml
${WTS_CFG_602}                    CB009169_Ab502.cfg
@{2CC_UE_LIST}                    6
@{2CC_PCELL_ID_LIST}              55
@{2CC_SCELL_PHYSICALID_1}         54
@{2CC_SCELL_PHYSICALID_LIST}      ${2CC_SCELL_PHYSICALID_1}
@{4CC_UE_LIST_2}                  8
@{4CC_PCELL_ID_LIST}              55
@{4CC_SCELL_PHYSICALID_2}         50    51    54
@{4CC_SCELL_PHYSICALID_LIST_2}    ${4CC_SCELL_PHYSICALID_2}
${LOW_A1THRESHOLD}                99
#AA302
${FULL_SCF_302}                   CB009169_Aa302_scfc.xml
${IPHY_FILE_302}                  ${CURDIR}/Resources/wts/iphy_4F_2T_Aa701.xml
${WTS_CFG_302}                    CB009169_Aa302.cfg
@{3CC_UE_LIST}                    1
@{3CC_SCELL_PHYSICALID_1}         50    51
@{3CC_SCELL_PHYSICALID_LIST}      ${3CC_SCELL_PHYSICALID_1}
#BE601+BE801
${FULL_SCFC_601}                  SCF_CB009169_ET_BE.xml
${IPHY_XML_601}                   ${CURDIR}/Resources/wts/iphy_CB009169_ET_BE.xml
${WTS_AP_XML_601}                 airphone.xml
${WTS_CFG_601}                    CB009169_ET_Reset.cfg

*** Test Cases ***
# TC1
       # [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${scf_file}    vendor_change_list=${vendor_change_list}
       # ...    iphy_file=${iphy_file}    swconfig_param=${swconfig_param}    swconfig_param_AP=${swconfig_param_ap}
       # ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_11}
       # ...    AND    Suite Setup Start WTS And Check OnAir
       # SA Multi UE Attach With Scell Blind Addition    ${3CC_UE_LIST}    ${3CC_SCELL_PHYSICALID_LIST}    3
       # SA Multi UE Start DL And UL Traffic    ${3CC_UE_LIST}    ${DL_DATA}    ${UL_DATA}
       # [Teardown]    Test Teardown Recover Env    scf_file=${scf_TEST_bak_file}    vendor_file=${vendor_test_bak_file}
       # ...    iphy_file=${iphy_test_bak_file}    GNB_swconfig_file=${gnb_swconfig_test_bak_file}    AP_swconfig_file}=${ap_swconfig_test_bak_file}

AA602
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${DELTA_SCF_602}
    ...    AND    Suite Setup Start WTS And Check OnAir
    SA Multi UE Attach With Scell A1 Addition    ${2CC_UE_LIST}    ${2CC_PCELL_ID_LIST}
    ...    ${2CC_SCELL_PHYSICALID_LIST}    ${LOW_A1THRESHOLD}    2
    [Teardown]    Test Teardown Recover Env    mode=debug    scf_file=${scf_test_bak_file}

AA603
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${DELTA_SCF_603}
    ...    AND    Suite Setup Start WTS And Check OnAir
    SA Multi UE Attach With Scell A1 Addition    ${4CC_UE_LIST_2}    ${4CC_PCELL_ID_LIST}
    ...    ${4CC_SCELL_PHYSICALID_LIST_2}    ${LOW_A1THRESHOLD}    4
    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}

AA302
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_302}
    ...    iphy_file=${IPHY_FILE_302}    swconfig_param=${swconfig_param}
    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_302}
    ...    AND    Suite Setup Start WTS And Check OnAir
    SA Multi UE Attach With Scell Blind Addition    ${3CC_UE_LIST}    ${3CC_SCELL_PHYSICALID_LIST}    3
    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}
    ...    iphy_file=${iphy_test_bak_file}  #  GNB_swconfig_file=${gnb_swconfig_TEST_bak_file}         # ${gnb_swconfig_SUITE_bak_file}

BE601
    [Setup]    Run Keywords    Test Setup Update GNB    #scf_file=${FULL_SCFC_601}    iphy_file=${IPHY_XML_601}
    # ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_601}
    ...    AND    Suite Setup Start WTS And Check OnAir
    SA Single UE Attach    1
    SA Single UE Attach    6
    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}    iphy_file=${iphy_test_bak_file}

BE801
    [Setup]    Run Keywords    Test Setup Update GNB    force_reboot=${True}    #scf_file=${FULL_SCFC_601}    iphy_file=${IPHY_XML_601}
    # ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_601}
    ...    AND    Suite Setup Start WTS And Check OnAir
    SA Single UE Attach    1
    SA Single UE Attach    6
    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}    iphy_file=${iphy_test_bak_file}



*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    CN1_SQ6    CB009855
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#### Suite level ###
#${SCF_PATH}                     ${CURDIR}/Config
#${WTS_CFG_3T3F}                 basic_B1701_IWK_PDCCH.cfg
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${3T3F_IPHY}                    ${CURDIR}/Resources/wts/iphy_B1701_3T3F.xml
#@{LOG_NAME_LIST}                snapshot    btsLog
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#### B1701 ###
#${FULL_SCF_CB009855_B1701}       FULL_SCF_CB009855_B1701_IWK_PDCCH.xml
#@{UE_LIST_B1701}                 1    2    3    4
#@{3T2F_SCELL_PCI_1}              50    51    52    53
#@{3T2F_SCELL_PCI_2}              50    52    53    54
#@{2T3F_SCELL_PCI_3}              50    51    53    54
#@{2T3F_SCELL_PCI_4}              50    51    52    54
#@{SCELL_PCI_LIST_B1701}          ${3T2F_SCELL_PCI_1}    ${3T2F_SCELL_PCI_2}    ${2T3F_SCELL_PCI_3}    ${2T3F_SCELL_PCI_4}
#${DL_DATA_BIG}                   500
#${UL_DATA_BIG}                   50
#${DL_DATA_SMALL}                 0.01
#${UL_DATA_SMALL}                 0.01
#${CC_NUM}                        5
#@{UE_LIST_BIG_DATA}              1    2    3
#@{UE_LIST_SMALL_DATA}            4
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB009855-ET-B1701_Verify_UE_3T2F_2T3F_DLCA_Interworking_With_Dynamic_PDCCH
#    [Tags]    Owner_fanjin    CRT
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_CB009855_B1701}    iphy_file=${3T3F_IPHY}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_3T3F}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    SA Multi UE Attach With Scell Blind Addition    ${UE_LIST_B1701}    ${SCELL_PCI_LIST_B1701}    ${CC_NUM}
#    SA Multi UE Start DL And UL Traffic    ${UE_LIST_BIG_DATA}    ${DL_DATA_BIG}    ${UL_DATA_BIG}
#    SA Multi UE Start DL And UL Traffic    ${UE_LIST_SMALL_DATA}    ${DL_DATA_SMALL}    ${UL_DATA_SMALL}
#    Sleep    10s    reason=wait for all UEs traffic statble
#    Verify PM Counter Decrease When 1UE Switch To PowerSavingBWP     M55335C05007
#    # [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}
#
#*** Keywords ***
#Verify PM Counter Decrease When 1UE Switch To PowerSavingBWP
#    [Arguments]    ${counter_id}
#    Display Multi UE Throughput    ${UE_LIST_B1701}
#    Wait Until PM Counter Update
#    Wait Until PM Counter Update
#    ${counter_value_before}    Get PM Counter Latest Value From Admin    ${counter_id}   counter_path=CELLS/NRCELL-6/PDCCH
#    SA Stop Data Traffic Internal    ue_id=3    pdu_id=1
#    SA Start DL Traffic Internal    ue_id=3    pdu_id=1    mbps=${DL_DATA_SMALL}
#    SA Start UL Traffic Internal    ue_id=3    pdu_id=1    mbps=${UL_DATA_SMALL}
#    Sleep    5s    reason=wait for all UEs traffic statble
#    Display Multi UE Throughput    ${UE_LIST_B1701}
#    Wait Until PM Counter Update
#    Wait Until PM Counter Update
#    ${counter_value_after}    Get PM Counter Latest Value From Admin    ${counter_id}    counter_path=CELLS/NRCELL-6/PDCCH
#    Should Be True    ${counter_value_after} < ${counter_value_before}

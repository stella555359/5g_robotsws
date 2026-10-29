*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=0x580692=1
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
...               AND    Suite Setup Start WTS And Check OnAir
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown    detach_ue_id=${4CC_UE_LIST[0]}
Force Tags        CLOUD_5G_I_BOO_AP_LOO    Owner_jshen
...               SBTS00    SBTS23R2    CN1_SQ6    CB009169    RAN_5G    RAN_5G_TDD    CRT
Resource          Resources/CB009169_Common.robot
Resource          ./../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${SCF_PATH}                     ${CURDIR}/Config
${FULL_SCF}                     CB009169_Ab502_scfc.xml
${IPHY_FILE}                    ${CURDIR}/Resources/wts/iphy_4F_2T_Aa701.xml
${WTS_LOCAL}                    ${CURDIR}/Resources/wts
${WTS_CFG}                      CB009169_Ab502.cfg
${2CC_UL_DATA}                  100
${4CC_DL_DATA_1}                50
${4CC_DL_DATA_2}                700
${NONCA_EXP_UL_TPUT}            0
@{2CC_EXP_UL_TPUT_LIST}         1    1
@{4CC_EXP_DL_TPUT_LIST}         1    1    1    1
@{4CC_UE_LIST}                  9
@{4CC_PCELL_ID_LIST}            55
@{4CC_SCELL_PHYSICALID}         50    51    54
@{4CC_SCELL_PHYSICALID_LIST}    ${4CC_SCELL_PHYSICALID}

*** Test Cases ***
CB009169_ET_AB502_T_3F_SingleUE_Scell_Selection_Based_On_DL_And_UL_Buffer_Activation_And_UL_Buffer_Deactivation
    SA Multi UE Attach With Scell Blind Addition    ${4CC_UE_LIST}    ${4CC_SCELL_PHYSICALID_LIST}    4
    SA Multi UE Start DL And UL Traffic    ${4CC_UE_LIST}    ${4CC_DL_DATA_1}    ${2CC_UL_DATA}
    Sleep    20s    reason=Wait For DLUL Transmission
    Display Multi UE Throughput    ${4CC_UE_LIST}
    Check Scell Active Status    1    activated    fail
    Check Scell Active Status    2    activated    fail
    Check Scell Active Status    3    activated    pass
    SA Multi UE Start DL And UL Traffic    ${4CC_UE_LIST}    ${4CC_DL_DATA_2}    ${2CC_UL_DATA}
    Sleep    20s    reason=Wait For DLUL Transmission
    Display Multi UE Throughput    ${4CC_UE_LIST}
    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${4CC_EXP_DL_TPUT_LIST}    4
    Check Scell Active Status    3    activated    pass
    Check Scell Active Status    2    activated    pass
    Check Scell Active Status    1    activated    pass
    Check SCellIndex Of ULCA UE From Tput    ${4CC_UE_LIST[0]}    3
    SA Multi UE Stop UL Traffic    ${4CC_UE_LIST}
    Sleep    20s    reason=Wait For UL Transmission Stop
    Display Multi UE Throughput    ${4CC_UE_LIST}
    Check Multi UE DLCA And ULnonCA L1 Cell Tput    ${4CC_UE_LIST}    ${NONCA_EXP_UL_TPUT}    ${4CC_EXP_DL_TPUT_LIST}    4
    Check Scell Active Status    3    deactivated    fail
    Check Scell Active Status    2    deactivated    fail
    Check Scell Active Status    1    deactivated    fail
    SA Multi UE Stop DL Traffic    ${4CC_UE_LIST}
    Sleep    20s    reason=Wait For DL Transmission Stop
    Display Multi UE Throughput    ${4CC_UE_LIST}
    Check Scell Active Status    3    deactivated    pass
    Check Scell Active Status    2    deactivated    pass
    Check Scell Active Status    1    deactivated    pass

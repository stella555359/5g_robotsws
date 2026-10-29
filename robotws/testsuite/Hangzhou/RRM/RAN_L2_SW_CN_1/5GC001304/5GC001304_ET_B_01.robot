*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CRT    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...               FR1    Owner_w13li    PRI-High    SBTS00    SBTS23R1
#...               SBTS22R4
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}           ${CURDIR}/config
#${DELTA_FILE}         Delta_Conf_5GC001304_B_1ssb_151.json
#${UE_ID}              1
#${PROFILE_ID}         1
#${GNB_ID}             2
#${CELL_ID}            1
#${BEARER_ID}          2
#${WTS_LOCAL}      ${CURDIR}/config/wts
#${WTS_CFG}        basic_setup.cfg
#
#*** Test Cases ***
#5GC001304_B_01_UE_Attach_With_Modified_TotalNumberOfRA_Preambles_PrachConfIndex_151_1ssb
#    ${UE_ID}=    Set Variable If    "${GNBCUTYPE}"=="SANSA"    11    ${UE_ID}
#    Set Suite Variable    ${UE_ID}    ${UE_ID}
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    #Verify Prach Config Index    output=${output}    index=151

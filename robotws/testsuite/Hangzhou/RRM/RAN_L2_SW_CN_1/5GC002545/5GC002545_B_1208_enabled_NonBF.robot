*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Set CP Debug
#...               AND    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Add Multi UE NSA    ${ue_nums}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup       Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO    CRT    RAN_5G    RAN_5G_TDD    FR1    Owner_zbu
#...               SBTS00    SBTS23R1    SBTS22R4
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./5GC002545_Resource.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/resources/config
#${FULL_SCF}         NonBF_SCFC.xml
#${IPHY_FILE}        ${CURDIR}/resources/wts/iphy_5GC002545.xml
#${UE_ID}            1
#${PROFILE_ID}       1
#${GNB_ID}           2
#${CELL_ID}          2
#${BEARER_ID}        2
#@{LOG_NAME_LIST}    btslog    snapshot
#${COUNT}            0
#${UE_NUMS}          101-132
#
#*** Test Cases ***
#5GC002545-ET-B009_Verify_FDM_of_PerCSIReporing_on_PUCCH_Without_BF_TDD_FrameStructure1208_FR1_NSA_100MHz
#    MultiUE Attach And Do Traffic With NSA    10    5    1    # Adjust ue numbers to 12 per log CSI-RS Capacity: 10, SANSA TL
#    Start And Stop Tti Trace
#    Convert Tti To Csv Mode
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/1208_nonBF_attach${/}1208_NoNBF_100M.ini    i
#    ...    save_log_directory=${output_dir}/ttitrace_streaming
#

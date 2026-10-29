*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=${SWCONFIG_PARAMS}    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Add Multi UE NSA    12-20
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    FR1    Owner_haifewan    PRI-High
#...               RAN_5G    SBTS00    SBTS23R1    SBTS22R4
#Resource          ../CUDU_L2/common_setup_teardown.robot
#Resource          5GC002537_common_keywords.robot
#Resource          ../CUDU_L2/common_admin.robot
#
#*** Variables ***
#${SCF_PATH}           ${CURDIR}/config
#${LOCAL_WTS_DIR}      ${CURDIR}/resources/wts
#${DELTA_FILE}         5GC002537_ET_03_100M_1116.json
#${WTS_CFG}            basic_fullstack_nsa_call_tdd_cmwv.cfg
#${WTS_AP_XML}         AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml
#@{UE_ID}              11    12    13    14
#${PROFILE_ID}         1
#${GNB_ID}             2
#${CELL_ID}            1
#${BEARER_ID}          2
#${SWCONFIG_PARAMS}    0x580019=1;0x580225=0;0x58019d=0;0x5801D1=2;0x5801D2=2;
#${COUNTER}            M55308C20001    # Maximum number of allocated PRBs on PDSCH per UE per slot
## @{LOG_NAME_LIST}      ${EMPTY}
#
#*** Test Cases ***
#5GC002537_ET_03_Enable_FDM_PDSCH_Counter_Max_Allocated_PRB_2_UE_Per_Slot_NSA_100M_1116
#    Attach Multiple UEs
#    Sleep    20s    reason=wait FDM function works for all UEs
#    # Start GNB TTI Trace
#    # Sleep    2s
#    # Stop GNB TTI Trace
#    # Decode TTI Trace Legacy Mode    ${output_dir}
#    Wait Until Keyword Succeeds    20min    1min    Verify 5GC002537 PM Counters    ${COUNTER}    0
#

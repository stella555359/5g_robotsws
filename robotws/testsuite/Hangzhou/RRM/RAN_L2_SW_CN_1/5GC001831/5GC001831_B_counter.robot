*** Settings ***
Documentation    ...
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource    ./resources/5GC001831_resource.robot
#Library      ./../python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb
#Suite Setup       Run Keywords    Common Suite Setup
#...               AND    Setup TL for 1831 Counter    ${1831_SCF}    ${IPHY_4CC}    ${WTS_CFG}
#Test Setup        #Common Test Setup
#Test Teardown    #Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD    SBTS00    CN1_SQ
#...                RAN_5G    RAN_5G_TDD    CRT
#*** Variables ***
#${UE_ID}               11
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${Egatelog_path}    ${CURDIR}
#${LOCAL_IPHY_DIR}    ${CURDIR}/config
#${LOCAL_WTS_DIR}    ${CURDIR}/config
#${WTS_DIR}    /opt/iphy/latest
#${SCF_DIR}    ${CURDIR}/config
#${1831_SCF}    SCF_1831.xml
#${WTS_CFG}    basic_setup_1831.cfg
#${IPHY_4CC}    iphy_1831.xml
#${gnb_swconfig}    ${CURDIR}/config/swconfig_gnb.txt
#${ap_swconfig}    ${CURDIR}/config/swconfig_ap.txt
##${file_name}    ${CURDIR}/test_pmcounter
#
#*** Test Cases ***
#5GC001831-ET-B002 Verify PM counters_UE_PSCELL_ACT_SCELL_UL
#    [Tags]    Owner_dguan
#    Check PM counter M55316C02001 UE_PSCELL_ACT_SCELL_UL
#
#5GC001831-ET-B003 Verify PM counters_PSCELL_UE_1_ACT_SCELL_UL
#    [Tags]    Owner_dguan
#    Check PM counter M55316C04001 PSCELL_UE_1_ACT_SCELL_UL
#
#5GC001831-ET-B004 Verify PM counters_MAX_PSCELL_UE_1_ACT_SCELL_UL
#    [Tags]    Owner_dguan
#    Check PM counter M55316C06001 MAX_PSCELL_UE_1_ACT_SCELL_UL
#
#5GC001831-ET-B005 Verify PM counters_RRC_RECONF_1_SCELL_UL_ATT
#    [Tags]    Owner_dguan
#    Check PM counter M55118C02001 RRC_RECONF_1_SCELL_UL_ATT
#
#5GC001831-ET-B006 Verify PM counters_RRC_RECONF_1_SCELL_UL_SUCC
#    [Tags]    Owner_dguan
#    Check PM counter M55118C03001 RRC_RECONF_1_SCELL_UL_SUCC
#
#5GC001831-ET-B007 Verify PM counters_UE_PSCELL_1_CONF_SCELL_UL
#    [Tags]    Owner_dguan
#    Check PM counter M55118C04001 UE_PSCELL_1_CONF_SCELL_UL
#
#5GC001831-ET-B008 Verify PM counters_UE_SCELL_1_CONF_SCELL_UL
#    [Tags]    Owner_dguan
#    Check PM counter M55118C05001 UE_SCELL_1_CONF_SCELL_UL
#
#5GC001831-ET-B009 Verify PM counters_SCELL_ACTIVATIONS
#    [Tags]    Owner_dguan
#    Check PM counter M55316C09000 SCELL_ACTIVATIONS
#
#5GC001831-ET-B015 Verify PM counters_SCell deactivations due to buffer status
#    [Tags]    Owner_dguan
#    Check PM counter M55316C09001 SCELL_DEACT_BUFFER_STATUS
#
#*** Keywords ***
#
#
#
#
#
#
#
#
#
#
#
#
#

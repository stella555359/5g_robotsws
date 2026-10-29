*** Settings ***
Documentation    ...
#Suite Setup       Convert TL Mode And Suite Setup DSS
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD    CRT    RAN_5G    RAN_5G_FDD    FR1    Owner_zbu
#...               SBTS00    SBTS23R1    SBTS22R4
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./CB006667_B_E_Resource.robot
#Resource          ./../CUDU_L2/common_dss_command.robot
#
#
#
#*** Variables ***
#${DELTA_FILE}              Delta_Conf_CB006667-E_1.json
#@{LOG_NAME_LIST}           btslog    snapshot
#${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
#${WTS_CFG}                 basic_6667_10M.cfg
#${WTS_AP_XML}              AirPhoneConfig_L1B_fdd_nsa_cmwv.xml
#@{OLD_PARAS_IPHY}          <cell>.*</cell>    <GSCN>.*</GSCN>
#@{NEW_PARAS_IPHY}          <cell>1.1</cell>    <GSCN>1588</GSCN>
#${UE_NUM}                  4
#
#*** Test Cases ***
#CB006667_E001_PDSCH_RS_Increasing_Per_Slot_SU_MIMO_2X2_10M_Pi_2_BPSK_SA_Without_PRB_Blanking
#    [Documentation]    This case verify per slot ue num with out blanking
#    ...  if test case failed you can  check the ue attch num
#    SANSA Ue Attach With DSS    prb_list=${PRB_LIST_10M_WITHOUT_BLANKING}
#    ...    min_dss_ratio=30    max_dss_ratio=70   min_prb_ratio=30    max_prb_ratio=70
#    Start And Stop Tti Trace
#    Check DL Per Slot Ue Numbers    ${TEST_LOG_DIRECTORY}    ${UE_NUM}

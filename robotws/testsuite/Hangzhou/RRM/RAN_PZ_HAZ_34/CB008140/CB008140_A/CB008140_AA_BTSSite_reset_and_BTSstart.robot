# #*** Settings ***
# #Resource    ./../Resources/CB008140_common_keywords.robot
# #Variables    ./Resources/CB008140_A_variables_2gnb.py
# #
# #Documentation
# #...   author: xiaodan.li
# #...   contact: xiaodan.li@nokia-sbell.com
# #...   squad group: SG_03
# #...   Feature CB008140-AA
# ##
# #Suite Setup    Common Suite Setup for COAM
# #
# #Suite Teardown    Run Keywords
# #...               robot_common_operations.Common Suite Teardown    AND
# #...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
# #...               Run Keyword And Ignore Error    COAM Teardown gnb connections
# #
# #*** Variables ***
# #${golden_scf_name}    Configuration_scf_GNB1_CB008140.xml
# #${golden_scf_name_gnb2}    Configuration_scf_GNB2_CB008140.xml
# #${filename_gnb1_002}    log_name_AA_002_gNB1.pcap
# #${filename_gnb2_002}    log_name_AA_002_gNB2.pcap
# #${filename1_gnb1_005}    log1_name_AA_005_gNB1.pcap
# #${filename2_gnb1_005}    log2_name_AA_005_gNB1.pcap
# #${filename3_gnb1_005}    log3_name_AA_005_gNB1.pcap
# #${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
# #
# #*** Test Cases ***
# #[1]CB008140-5G-AA_002_IgCA_active_on_2gnb_which_act_as_prime_and_ext_each_other_with_Xn_IgCA_setup_procedure_success
# #    [Documentation]    This user scenario describes the behaviour when both 2gnb which act as prime and extGnb each
# #    ...                other restart at the same time with plan file in which CB008140 is activated and the Xn Ignb_CA
# #    ...                Setup procedure check
# #    [Tags]     classical    CRT_TRUNK    CRT_22R4
# #    [Timeout]    2 hour
# #    [Setup]    robot_common_operations.Common Case Setup
# #    Common Case TestLine Setup    ModifySCF_Beforecommission=True    ModifySCF_Beforecommission_GNB2=True
# #    ...    golden_scf_name=${golden_scf_name}    MOsToAdd=${MOS_ADD_GNB1}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1}
# #    ...    ListToAdd=${LIST_TO_ADD_GNB1}
# #    ...    golden_scf_name_gnb2=${golden_scf_name_gnb2}    MOsToAdd_gnb2=${MOS_ADD_GNB2}
# #    ...    ParamterToModify_gnb2=${PARAMETERS_TO_MODIFY_GNB2}    ListToAdd_gnb2=${LIST_TO_ADD_GNB2}
# #    Get cell id 2gnb
# #    Get 2gnb length with HEX
# #    COAM gNB Reset site via api    gnb_index=${0}    is_need_check_cell_onair=False    wait_for_reconnection=False
# #    COAM gNB Reset site via api    gnb_index=${1}    is_need_check_cell_onair=False    wait_for_reconnection=False
# #    wait until keyword succeeds    5min    1s    Connect to gnb    gnb_index=${0}
# #    Start capture gNB log on gnb1 and gnb2    gnb1_filename=${filename_gnb1_002}    gnb2_filename=${filename_gnb2_002}
# #    wait until keyword succeeds    10 min    20s   Check the gnb1 and gnb2 cells status on air
# #    Stop and download gNB log on gnb1 and gnb2    gnb1_filename=${filename_gnb1_002}    gnb2_filename=${filename_gnb2_002}
# #    Check wireshark log for 002    logname=${filename_gnb1_002}    logname1=${filename_gnb2_002}
# #    [Teardown]    Run keywords
# #    ...    robot_common_operations.Common Case Teardown    AND
# #    ...    Run Keyword And Ignore Error    Case Teardown    Delete_Mo_Online=${PARAMETERS_TO_DELETE_GNB1}
# #    ...    Delete_Mo_Online_GNB2=${PARAMETERS_TO_DELETE_GNB2}
# #
# ##[1]CB008140-5G-AA_005_Online_modify_extGnb_scell_between_locked_then_unlock_and_check_Xn_IgNB_CA_setup_procedure
# ##    [Documentation]    This user scenario describes the behaviour when online modify candidate scell in ext_gnb with
# ##    ...                locked and unlocked status and both prime gNB and external gNB with CB008140 is activated.
# ##    ...                and the Configuration Update Indication procedure check.
# ##    [Tags]     classical    CRT_TRUNK    CRT_22R4
# ##    [Timeout]    2 hour
# ##    [Setup]    robot_common_operations.Common Case Setup
# ##    Common Case TestLine Setup    ModifySCF_Beforecommission=True    ModifySCF_Beforecommission_GNB2=True
# ##    ...    golden_scf_name=${golden_scf_name}    MOsToAdd=${MOS_ADD_GNB1}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1}
# ##    ...    ListToAdd=${LIST_TO_ADD_GNB1}
# ##    ...    golden_scf_name_gnb2=${golden_scf_name_gnb2}
# ##    ...    ParamterToModify_gnb2=${PARAMETERS_TO_LOCK_SCELL}
# ##    Get cell id 2gnb
# ##    COAM gNB Reset site via api    gnb_index=${0}    is_need_check_cell_onair=False    wait_for_reconnection=False
# ##    COAM gNB Reset site via api    gnb_index=${1}    is_need_check_cell_onair=False    wait_for_reconnection=False
# ##    wait until keyword succeeds    5min    1s    Connect to gnb    gnb_index=${0}
# ##    Start capture gNB log on master    filename=${filename1_gnb1_005}    gNB_index=${0}
# ##    Check the gnb1 and gnb2 ready
# ##    Wait Until Keyword Succeeds    10 min    20 sec    Cell Should Be Lock or Unlock    gnb_index=${1}
# ##    Stop and download the Logs    filename=${filename1_gnb1_005}    gNB_index=${0}
# ##
# ##    #####online modify the gnb cell from lock to unlock#####
# ##    Start capture gNB log on master    filename=${filename2_gnb1_005}    gNB_index=${0}
# ##    GNB Cell Lock Or Unlock And Check Status    Modify_Para_Online_GNB=${MODIFY_PARA_ONLINE_GNB2_UNLOCK}
# ##    ...    is_locked=False    gnb_index=${1}
# ##    Stop and download the Logs    filename=${filename2_gnb1_005}    gNB_index=${0}
# ##
# ##    #####online modify the gnb cell from unlock to lock#####
# ##    Start capture gNB log on master    filename=${filename3_gnb1_005}    gNB_index=${0}
# ##    GNB Cell Lock Or Unlock And Check Status    Modify_Para_Online_GNB=${MODIFY_PARA_ONLINE_GNB2_LOCK}
# ##    ...    is_locked=True    gnb_index=${1}
# ##    Stop and download the Logs    filename=${filename3_gnb1_005}    gNB_index=${0}
# ##
# ##    #####check the wireshark log#####
# ##    Check wireshark log for 005_01    logname=${filename1_gnb1_005}
# ##    Check wireshark log for 005_02    logname=${filename2_gnb1_005}
# ##    Check wireshark log for 005_03    logname=${filename3_gnb1_005}
# ##    [Teardown]    run keywords
# ##    ...    robot_common_operations.Common Case Teardown    AND
# ##    ...    Run Keyword And Ignore Error    Common Case TestLine Setup    ModifySCF_Aftercommission_for_GNB2=True
# ##    ...    Modify_Para_Online_GNB2=${MODIFY_PARA_ONLINE_GNB2_UNLOCK}    AND
# ##    ...    Run Keyword And Ignore Error    Case Teardown    Delete_Mo_Online=${PARAMETERS_TO_DELETE_GNB1}
# ##    ...    Delete_Mo_Online_GNB2=${PARAMETERS_TO_DELETE_GNB2}
# #
# #
# #
# #*** Keywords ***
# ####check wireshar log
# #Check wireshark log for 002
# #    [Arguments]    ${logname}    ${logname1}
# #    Check 1st IgNBCASetupRequest    logname=${logname}
# #    Check IgNBCASetup on 2gnb    logname=${logname}
# #    Check IgNBCAconfig on 2gnb    logname=${logname}
# #    Check IgNBCAconfigcellstatus on 2gnb    logname=${logname}
# #    Check IgNBCAResourceStatusUpdate time interval on 2gnb    logname=${logname}
# #
# #    Check XP setup procedure    logname=${logname}   prime_gnb_index=${xnap_gnb1}    gnb_ID=${gNb2Id_DEC}
# #    ...    XP_Status=${1}
# #    Check XP setup procedure    logname=${logname1}    prime_gnb_index=${xnap_gnb2}    gnb_ID=${gNb1Id_DEC}
# #    ...    XP_Status=${1}
# #
# #Check wireshark log for 005_01
# #    [Arguments]    ${logname}
# #    Check IgNBCASetup on extGnb    logname=${logname}
# #    Check IgNBCAconfig on extgnb    logname=${logname}
# #
# #Check wireshark log for 005_02
# #    [Arguments]    ${logname}
# #    Check IgNBCAconfigcellstatus on extgnb    logname=${logname}
# #    Check IgNBCAResourceStatusUpdate time interval on extgnb    logname=${logname}
# #
# #Check wireshark log for 005_03
# #    [Arguments]    ${logname}
# #    Check IgNBCAconfigcellstatus on extgnb    logname=${logname}    cell_status=0
# #    Check has no IgNBCAResourceStatusUpdate after unlock to lock    logname=${logname}
# #
# #
# #Check XP setup procedure
# #    [Arguments]    ${logname}    ${prime_gnb_index}    ${gnb_ID}    ${XP_Status}
# #    Check IgNBCAXpSetupRequest message    logname=${logname}    gnb_ID=${gnb_ID}
# #    Check IgNBCAXpSetupResponse message    logname=${logname}    gnb_ID=${gnb_ID}    XP_Status=${XP_Status}
# #    Check IgNBCAconfigurationUpdateIndication message    logname=${logname}    soure_ip=${prime_gnb_index}

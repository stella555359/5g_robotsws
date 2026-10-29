#*** Settings ***
#Force Tags    PY36
#Documentation     author: qingqing zhang
#...                 contact: qingqing.zhang@nokia-sbell.com
#...                 squad group: SG_03
#...                 feature : CB008140-HC
#
#Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
#Variables    ./Resources/CB008140_H_variables.py
#
#
#Suite Setup    Run Keywords
#...            robot_common_operations.Common Suite Setup    AND
#...            Run Keyword And Ignore Error    Common Suite Setup for COAM
#
#Suite Teardown    Run Keywords
#...               robot_common_operations.Common Suite Teardown    AND
#...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#
#*** Variables ***
#${gnb_path}    /tmp
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#${tl_scf_filename_gnb0}    Configuration_scf_GNB1_CB008140.xml
#${tl_scf_filename_gnb2}    Configuration_scf_GNB3_CB008140.xml
#${interface1}    any
#${filename_001_attach_gnb0}    log_name_HC_001_gNB1_attach.pcap
#${filename_001_attach_gnb2}    log_name_HC_001_gNB3_attach.pcap
#@{gnb_list_HC}    ${0}    ${2}
#${scell_bandwidth}    36300
#@{scell_index_list_HC001}    ${11}
#@{extgnb_index_list_HC001}    ${0}
#@{filename_HC001}    filename_001_attach_gnb
#@{branch}    SBTS23R3_ENB_0000    SBTS24R1_ENB_9999
#*** Test Cases ***
#
#[1]CB008140-5G-HC_001_IGCA_Interaction_with_bandwith25
#    [Documentation]
#    ...    SCell addition for inter-gNB CA in case SCell is FDD cell and configured with cell bandwidth of 25 MHz
#    [Tags]    classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    Case prepare for HC001
#    wait until keyword succeeds    3X    5S    Attach and check bandwidth
#    [Teardown]    run keywords
#    ...    Case Teardown    filename=${filename_HC001}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#
#*** Keywords ***
#Attach and check bandwidth
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb3_cell1_value=${0}
#    Start capture multi gNB log    filename=filename_001_attach_gnb    gnb_list=${gnb_list_HC}
#    MultiUE.Attach
#    Stop capture multi gNB log    filename=filename_001_attach_gnb    gnb_list=${gnb_list_HC}
#    Check wireshark log for HC001    logname=${filename_001_attach_gnb0}    logname1=${filename_001_attach_gnb2}
#
#Case prepare for HC001
#    @{scf_list}    Create List
#    ${release_info}    Get sagnb release
#    ${scf_gnb0}    Only Modify SCF before Perform Commission    gnb_index=${0}
#    ...    golden_scf_name=${tl_scf_filename_gnb0}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB1_HC001}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_HC001}    ListToAdd=${LIST_TO_ADD_GNB1_HC001_${release_info}}
#    ${scf_gnb2}    Only Modify SCF before Perform Commission    gnb_index=${2}
#    ...    golden_scf_name=${tl_scf_filename_gnb2}    MOsToAdd=${MOS_ADD_GNB3_HC001}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_HC001}    ListToAdd=${LIST_TO_ADD_GNB3_HC001}
#    Append to List    ${scf_list}    ${scf_gnb0}    ${scf_gnb2}
#    Multi-gNB commission    index_list=${gnb_list_HC}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_HC}
#
#Check wireshark log for HC001
#    [Arguments]    ${logname}    ${logname1}
#    ###check 2CC setup succuss
#    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname1}
#    ...    pcell_index=${1}    scell_index_list=${scell_index_list_HC001}
#    ...    Primegnb_index=${2}    extgnb_index_list=${extgnb_index_list_HC001}
#    ###check scell is 25MHZ
#    Check UEContextModificationResponse has scell bandwidth on PrimegNB    logname=${logname1}
#
#Check UEContextModificationResponse has scell bandwidth on PrimegNB
#    [Arguments]    ${logname}
#    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList
#    ...    ${xpath}=.//nr-rrc.locationAndBandwidth
#    Log    check scell's bandwidth
#    ${bandwidth}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    should be equal    ${bandwidth[-1]}    ${scell_bandwidth}

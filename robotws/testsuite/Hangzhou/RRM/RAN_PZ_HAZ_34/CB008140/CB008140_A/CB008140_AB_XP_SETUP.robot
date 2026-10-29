#*** Settings ***
#Force Tags    PY36
#Documentation     author: qingqing zhang
#...                 contact: qingqing.zhang@nokia-sbell.com
#...                 squad group: SG_03
#...                 feature : CB008140-AB
#
#Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
#Variables    ./Resources/CB008140_A_Variables.py
#
#
#Suite Setup      Run Keywords
#...               robot_common_operations.Common Suite Setup    AND
#...               Run Keyword And Ignore Error    Common Suite Setup for COAM
#
#Suite Teardown    Run Keywords
#...               robot_common_operations.Common Suite Teardown    AND
#...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#
#*** Variables ***
#${gnb_path}    /tmp/
#${golden_scf_name_gnb2}    Configuration_scf_GNB3_CB008140.xml
#${golden_scf_name_gnb3}    Configuration_scf_GNB4_CB008140.xml
#${logname_AB01_gnb1}       XP_setup_gnb1.pcap
#${logname_AB01_gnb2}       XP_setup_gnb2.pcap
#${logname_AB03_gnb2}       XP_unvailable_gnb3.pcap
#${logname_AB03_gnb3}       XP_unvailable_gnb4.pcap
#${logname1_AB03_gnb2}       XP_unvailable_to_vailable_gnb3.pcap
#${logname1_AB03_gnb3}       XP_unvailable_to_vailable_gnb4.pcap
#${interface1}    any
#@{gnb_list}    ${2}    ${3}
#@{scell_index_list_cell2}    ${2}
#@{extgnb_index_gnb4}    ${3}
#*** Test Cases ***
##[1]CB008140-5G-AB_001_Successful_XP_setup_procedure_for_IgNB_CA_with_BTS_Startup
##    [Documentation]
##    ...    This case is the successful XP setup procedure for the inter-gNB CA between gNB-DUs which can act as
##    ...    both prime gNB-DU and external gNB-DU
##    [Tags]    classical    CRT_TRUNK    CRT_22R4
##    [Setup]    Get 2gnb length with HEX
##    Common Case TestLine Setup    ModifySCF_Beforecommission=True    ModifySCF_Beforecommission_GNB2=True
##    ...    golden_scf_name=${tl_scf_filename_gnb1}    MOsToAdd=${MOS_ADD_GNB1}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1}
##    ...    ListToAdd=${LIST_TO_ADD_GNB1}
##    ...    golden_scf_name_gnb2=${tl_scf_filename_gnb2}    MOsToAdd_gnb2=${MOS_ADD_GNB2}
##    ...    ParamterToModify_gnb2=${PARAMETERS_TO_MODIFY_GNB2}    ListToAdd_gnb2=${LIST_TO_ADD_GNB2}
##    COAM gNB Reset site via api    is_need_check_cell_onair=False    wait_for_reconnection=False
##    COAM gNB Reset site via api    gnb_index=${1}    is_need_check_cell_onair=False    wait_for_reconnection=False
##    Wait until keyword succeeds    5min    1s    Connect to gnb    gnb_index=${0}
##    Wait until keyword succeeds    5min    2s    Start capture gNB log on gnb1 and gnb2    gnb1_filename=${logname_AB01_gnb1}
##    ...    gnb2_filename=${logname_AB01_gnb2}
##    Wait until keyword succeeds    10 min    20s   Check the gnb1 and gnb2 cells status on air
##    Stop and download gNB log on gnb1 and gnb2    gnb1_filename=${logname_AB01_gnb1}    gnb2_filename=${logname_AB01_gnb2}
##    Check wireshark log for 001    logname_gnb1=${logname_AB01_gnb1}    logname_gnb2=${logname_AB01_gnb2}
##    [Teardown]    Run Keyword And Ignore Error    Case Teardown    parameters_to_update_gnb1=${PARAMETERS_TO_DELETE_GNB1}
##    ...    parameters_to_update_gnb2=${PARAMETERS_TO_DELETE_GNB2}    ModifySCF_Aftercommission=True
##    ...    ModifySCF_Aftercommission_for_GNB2=True
#
#[1]CB008140-5G-AB_003_XP_setup_procedure_for_IgNB_CA_with_SCTP_association_status_notification_by_online_parameter_modify
#    [Documentation]
#    ...    This case is check SCTP association status notification received by the gNB-DUs which can act as both prime
#    ...    gNB-DU and external gNB-DU
#    [Tags]    classical    CRT_TRUNK    CRT_22R4
#    [Setup]    robot_common_operations.Common Case Setup
#    Get 2gnb length with HEX
#    Common Case TestLine Setup for AB003
#    COAM gNB Reset site via api    gnb_index=${2}    is_need_check_cell_onair=False    wait_for_reconnection=False
#    COAM gNB Reset site via api    gnb_index=${3}    is_need_check_cell_onair=False    wait_for_reconnection=False
#    Wait until keyword succeeds    5min    1s    Connect to gnb    gnb_index=${2}
#    Wait until keyword succeeds    5min    2s    Start capture multi gNB log    filename=logname_AB03_gnb    gnb_list=${gnb_list}
#    Wait until keyword succeeds    10 min    20s   Check the MultiBTS cells status on air    gnb_list=${gnb_list}
#    Stop capture multi gNB log    filename=logname_AB03_gnb    gnb_list=${gnb_list}
#    Check wireshark log for 003_01    logname_gnb1=${logname_AB03_gnb2}    logname_gnb2=${logname_AB03_gnb3}
#    Start capture multi gNB log    filename=logname1_AB03_gnb    gnb_list=${gnb_list}
#    Modify Parameters for Cases   gnb_index=${2}    Modify_Para_Online=${Modify_Para_Online_GNB3_XP_IP}
#    Stop capture multi gNB log    filename=logname1_AB03_gnb    gnb_list=${gnb_list}
#    Check wireshark log for 003_02    logname_gnb1=${logname1_AB03_gnb2}    logname_gnb2=${logname1_AB03_gnb3}
#    [Teardown]     run keywords    Case recover for AB003    AND
#    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM    gnb_list=${gnb_list}
#
#*** Keywords ***
#Common Case TestLine Setup for AB003
#    @{scf_list}    Create List
#    ${scf_gnb2}    Only Modify SCF before Perform Commission    gnb_index=${2}
#    ...    golden_scf_name=${golden_scf_name_gnb2}
#    ...    MOsToAdd=${MOS_ADD_GNB3}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_AB003}
#    ...    ListToAdd=${LIST_TO_ADD_GNB3}
#    ${scf_gnb3}    Only Modify SCF before Perform Commission    gnb_index=${3}
#    ...    golden_scf_name=${golden_scf_name_gnb3}
#    ...    MOsToAdd=${MOS_ADD_GNB4}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB4_AB003}
#    ...    ListToAdd=${LIST_TO_ADD_GNB4}
#    Append to List    ${scf_list}    ${scf_gnb2}    ${scf_gnb3}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list}
#
#Case recover for AB003
#    Modify Parameters for Cases   gnb_index=${2}    Modify_Para_Online=${PARAMETERS_TO_recover_GNB3_AB003}
#    Modify Parameters for Cases   gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_recover_GNB4_AB003}
#
#Check wireshark log for 001
#    [Arguments]    ${logname_gnb1}    ${logname_gnb2}
#    Check XP setup procedure    logname=${logname_gnb1}   prime_gnb_index=${xnap_gnb1}    gnb_ID=${gNb2Id_DEC}
#    ...    XP_Status=${1}
#    Check XP setup procedure    logname=${logname_gnb2}    prime_gnb_index=${xnap_gnb2}    gnb_ID=${gNb1Id_DEC}
#    ...    XP_Status=${1}
#
#Check wireshark log for 003_01
#    [Arguments]    ${logname_gnb1}    ${logname_gnb2}
#    Check XP is unvailable    logname=${logname_gnb1}    gnb_ID=${gNb4Id_DEC}    XP_Status=${0}
#    Check XP is unvailable    logname=${logname_gnb2}    gnb_ID=${gNb3Id_DEC}    XP_Status=${0}
#    ###check UPD007
#    Check IgNBCAconfigurationUpdateIndication which Primegnb send    logname=${logname_gnb1}    soure_ip=${xnap_gnb3}
#    Check IgNBCAconfigurationUpdateIndication which Extergnb send    logname=${logname_gnb1}    soure_ip=${xnap_gnb4}
#
#Check wireshark log for 003_02
#    [Arguments]    ${logname_gnb1}    ${logname_gnb2}
#    Get cell id multignb    lcrid_pcell=${1}    scell_index_list=${scell_index_list_cell2}
#    ...    PrimegNB_index=${2}    extgnb_index_list=${extgnb_index_gnb4}
#    Check XP unvailable to vailable    logname=${logname_gnb1}    gnb_ID=${gNb4Id_DEC}
#    ...    XP_Status=${1}
#    Check XP unvailable to vailable    logname=${logname_gnb2}    gnb_ID=${gNb3Id_DEC}
#    ...    XP_Status=${1}
#    Check IgNBCAconfigcellstatus on 2gnb    logname=${logname_gnb1}
#    ...    message_filter1=nokiaxnap.cell_Availability and ip.src == ${xnap_gnb3}
#    ...    message_filter2=nokiaxnap.cell_Availability and ip.src == ${xnap_gnb4}
#    Check IgNBCAResourceStatusUpdate time interval on 2gnb    logname=${logname_gnb1}
#    ...    message1_filter1=nokiaxnap.procedureCode == 139 and ip.src == ${xnap_gnb3}
#    ...    message1_filter2=nokiaxnap.cell_Availability and ip.src == ${xnap_gnb3}
#    ...    message2_filter1=nokiaxnap.procedureCode == 139 and ip.src == ${xnap_gnb4}
#    ...    message2_filter2=nokiaxnap.cell_Availability and ip.src == ${xnap_gnb4}
#
#Check XP setup procedure
#    [Arguments]    ${logname}    ${prime_gnb_index}    ${gnb_ID}    ${XP_Status}
#    Check IgNBCAXpSetupRequest message    logname=${logname}    gnb_ID=${gnb_ID}
#    Check IgNBCAXpSetupResponse message    logname=${logname}    gnb_ID=${gnb_ID}    XP_Status=${XP_Status}
#    Check IgNBCAconfigurationUpdateIndication message    logname=${logname}    soure_ip=${prime_gnb_index}
#
#Check XP is unvailable
#    [Arguments]    ${logname}    ${gnb_ID}    ${XP_Status}
#    Check IgNBCAXpSetupRequest message    logname=${logname}    gnb_ID=${gnb_ID}
#    Check IgNBCAXpSetupResponse message    logname=${logname}    gnb_ID=${gnb_ID}    XP_Status=${XP_Status}
#
#Check XP unvailable to vailable
#    [Arguments]    ${logname}    ${gnb_ID}    ${XP_Status}
#    Check XpConnectionStatusNotification message    logname=${logname}    gnb_ID=${gnb_ID}    XP_Status=${XP_Status}
#
#Get 2gnb length with HEX
#    ${gNb3Id_DEC}    Gnb id conversion    WEBUI_COAM=${WEBUI_host2}
#    set suite variable    ${gNb3Id_DEC}
#    ${gNb4Id_DEC}    Gnb id conversion    WEBUI_COAM=${WEBUI_host3}
#    set suite variable    ${gNb4Id_DEC}
#
#Check IgNBCAconfigurationUpdateIndication which Primegnb send
#    [Arguments]    ${logname}    ${soure_ip}
#    ${CA_allow}    Check wireshark log    logname=${logname}
#    ...    message_filter=nokiaxnap.procedureCode == 138 and ip.src == ${soure_ip}
#    ...    xpath=.//nokiaxnap.id
#    Should Contain    ${CA_allow}    24683
#    ${CellLoadReportingPeriodicity}    Check wireshark log    logname=${logname}
#    ...    message_filter=nokiaxnap.procedureCode == 138 and ip.src == ${soure_ip}
#    ...    xpath=.//nokiaxnap.CellLoadReportingPeriodicity
#    Should be equal    ${CellLoadReportingPeriodicity[0]}    2000
#
#Check IgNBCAconfigurationUpdateIndication which Extergnb send
#    [Arguments]    ${logname}    ${soure_ip}
#    ${CA_allow}    Check wireshark log    logname=${logname}
#    ...    message_filter=nokiaxnap.procedureCode == 138 and ip.src == ${soure_ip}
#    ...    xpath=.//nokiaxnap.id
#    Should Contain    ${CA_allow}    24683
#    ${CellLoadReportingPeriodicity}    Check wireshark log    logname=${logname}
#    ...    message_filter=nokiaxnap.procedureCode == 138 and ip.src == ${soure_ip}
#    ...    xpath=.//nokiaxnap.CellLoadReportingPeriodicity
#    Should be equal    ${CellLoadReportingPeriodicity[0]}    2000
#    ${Resource_update}    Check wireshark log    logname=${logname}
#    ...    message_filter=nokiaxnap.procedureCode == 22 and ip.src == ${soure_ip}
#    ...    xpath=.//nokiaxnap.procedureCode
#    should not contain    ${Resource_update[0]}    139
#
#Check XpConnectionStatusNotification message
#    [Arguments]    ${logname}    ${gnb_ID}    ${XP_Status}
#    ${gnb_ID_log}    Check wireshark log    logname=${logname}    attribute_name=value
#    ...    message_filter=nokiaf1ap.procedureCode == 14
#    ...    xpath=.//nokiaf1ap.gnb_ID
#    ${gnb_ID_transition_DEC}    Evaluate    list(map(lambda x: int(x, 16), ${gnb_ID_log}))
#    should be equal    ${gnb_ID_transition_DEC[0]}    ${gnb_ID}
#    ${XpConnectionStatus}    Check wireshark log    logname=${logname}
#    ...    message_filter=nokiaf1ap.procedureCode == 14
#    ...    xpath=.//nokiaf1ap.XpConnectionStatus
#    ${XpStatus}    Convert to Integer     ${XpConnectionStatus[0]}
#    should be equal    ${XpStatus}    ${XP_Status}

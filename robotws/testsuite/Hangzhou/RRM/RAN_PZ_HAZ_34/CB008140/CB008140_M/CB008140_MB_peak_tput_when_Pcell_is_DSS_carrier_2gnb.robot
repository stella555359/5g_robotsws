*** Settings ***
Force Tags    PY36
Documentation     author: qingqing zhang
...                 contact: qingqing.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB008140-MB

Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
Variables    ./Resources/CB008140_M_variables.py


Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup    AND
...            Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
...            SCF Commission with gnb1 and gnb2    AND
...            Enable DSS configuration


Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               SCF Commission with gnb1 and gnb2    AND
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${gnb_path}    /tmp/
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${scf_path}    /opt/workspace/SCF/
${tl_scf_gnb0}    SCF_GNB1_
${tl_scf_gnb1}    SCF_GNB2_
${interface1}    any
${filename_DA001_gnb0}       XP_setup_gnb1.pcap
${filename_DA001_gnb3}       XP_setup_gnb4.pcap
${filename_005_attach_gnb0}    log_name_HC_005_gNB0_attach.pcap
${filename_005_attach_gnb1}    log_name_HC_005_gNB3_attach.pcap
${filename_010_attach_gnb0}    log_name_HC_010_gNB0_attach.pcap
${filename_010_attach_gnb1}    log_name_HC_010_gNB3_attach.pcap
@{gnb_list}    ${0}    ${1}
@{gnb_ips}    ${bts_host0}    ${bts_host1}
${Send_Tput_DL_T_T}    500
${Send_Tput_UL}    100
${expected_tput_ul_F_38611}    74
${expected_tput_ul_F_38711}    60
${expected_tput_dl_T}    1300
${expected_tput_dl_F_DSS}    241
@{filename_MB005}    filename_005_attach_gnb
@{filename_MB010}    filename_010_attach_gnb
*** Test Cases ***
[1]CB008140-5G-MB_005_igNB-CA_DL_peak_tput_when_Pcell_is_DSS_carrier_3CC_F_F_T_BF
    [Documentation]    This user scenario intends to verify that whether inter-gNB CA would work as expected in case DSS
    ...    is enabled in pcell 3CC 2FDD+TDD case
    [Tags]    classical    CRT_TRUNK
    [Setup]    robot_common_operations.Common Case Setup
    Modify Parameters for Cases   gnb_index=${0}    Add_Mo_Online=${PARAMETERS_TO_ADD_MO_GNB1_MB005_2gnb}
    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1}
#    Test for CB008140 DA001
    Wait until keyword succeeds    4x   10s    Start traffic and check TPUT
    Hanging resource test    gnb_ips=@{gnb_ips}    gnb_list=${gnb_list}
    [Teardown]    run keywords
    ...    MultiUE.Stop DLUL traffic    AND
    ...    Case Teardown    filename=${filename_MB005}    AND
    ...    Modify Parameters for Cases   gnb_index=${0}    Delete_Mo_Online=${PARAMETERS_TO_DELETE_GNB1_MB005}    AND
    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation for 2gnb

#[1]CB008140-5G-MB_010_igNB-CA_DL_peak_tput_when_both_Pcell_and_Scell_are_DSS_carrier_2CC
#    [Documentation]    This user scenario intends to verify that whether inter-gNB CA would work as expected in case DSS is enabled
#    ...    both in pcell and scell 2CC FDD case.
#    [Tags]    classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    Modify Parameters for Cases   gnb_index=${0}    Add_Mo_Online=${PARAMETERS_TO_ADD_MO_GNB1_MB010}
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}
#    Start capture multi gNB log    filename=filename_010_attach_gnb    gnb_list=${gnb_list}
#    MultiUE.Attach
#    Stop capture multi gNB log    filename=filename_010_attach_gnb    gnb_list=${gnb_list}
#    Adjust gNB_RU Attenuation    gnb1_cell2_value=${0}    gnb4_cell1_value=${0}
#    MultiUE.Start DLUL traffic and check 2CC tput    scellid=1    pcellid=2    tput_dl_pcell=${expected_tput_dl_F_DSS}
#    ...    tput_dl_scell=${expected_tput_dl_F_DSS}    tput_ul_pcell=${expected_tput_ul_F}
#    ...    gnb_prime=${0}    gnb_external=${3}
#    ...    dl_throughput=${Send_Tput_DL_T_T}    ul_throughput=${Send_Tput_UL}
#    MultiUE.Stop DLUL traffic
#    [Teardown]    run keywords
#    ...    MultiUE.Stop DLUL traffic    AND
#    ...    Case Teardown    filename=${filename_MB010}    AND
#    ...    Modify Parameters for Cases   gnb_index=${0}    Delete_Mo_Online=${PARAMETERS_TO_DELETE_GNB1_MB010}
#    ...    AND    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation

*** Keywords ***
SCF Commission with gnb1 and gnb2
    ${release_info}    Get sagnb release
    @{scf_list}    Create List
    Append to List    ${scf_list}    ${scf_path}${tl_scf_gnb0}${release_info}.xml    ${scf_path}${tl_scf_gnb1}${release_info}.xml
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list}    scf_list=${scf_list}
    Check the MultiBTS cells status on air    gnb_list=${gnb_list}

Start traffic and check TPUT
    MultiUE.Prepare UE
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell2_value=${0}
    Start capture multi gNB log    filename=filename_005_attach_gnb    gnb_list=${gnb_list}
    MultiUE.Attach
    Stop capture multi gNB log    filename=filename_005_attach_gnb    gnb_list=${gnb_list}
    MultiUE.Start UE DLUL traffic   dl_throughput=${Send_Tput_DL_T_T}    ul_throughput=${Send_Tput_UL}    duration=1200
    ...    process_num=${5}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}    gnb2_cell3_value=${0}
    Sleep    60s
    Check 3CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F_DSS}    tput_dl_scell1=${expected_tput_dl_F_DSS}
    ...    tput_dl_scell2=${expected_tput_dl_T}    tput_ul_pcell=${expected_tput_ul_F_${gnb_instance0}}     scellid1=11
    ...    scellid2=31    pcellid=2    gnb_prime=${0}    gnb_external=${1}    ue_type=${tl.ues[0].capabilities[0]}
    MultiUE.Stop DLUL traffic
    MultiUE.Detach

Enable DSS configuration
     Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_DSS}
     Modify Parameters for Cases   gnb_index=${1}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB2_DSS}

Test for CB008140 DA001
    COAM gNB Reset site via api    is_need_check_cell_onair=False    wait_for_reconnection=False
    COAM gNB Reset site via api    gnb_index=${3}    is_need_check_cell_onair=False    wait_for_reconnection=False
    Wait until keyword succeeds    5min    1s    Connect to gnb    gnb_index=${0}
    Wait until keyword succeeds    5min    2s    Start capture multi gNB log    filename=filename_DA001_gnb    gnb_list=@{gnb_list}
    Check the MultiBTS cells status on air    gnb_list=@{gnb_list}
    Stop capture multi gNB log    filename=filename_DA001_gnb    gnb_list=@{gnb_list}
    Check wireshark log for DA001    logname_gnb1=${filename_DA001_gnb0}    logname_gnb2=${filename_DA001_gnb3}
    Check only default Fault Present    gnb_list=@{gnb_list}

Check wireshark log for DA001
    [Arguments]    ${logname_gnb1}    ${logname_gnb2}
    ${gNb1Id_DEC}    Gnb id conversion    WEBUI_COAM=${WEBUI_host0}
    set suite variable    ${gNb1Id_DEC}
    ${gNb2Id_DEC}    Gnb id conversion    WEBUI_COAM=${WEBUI_host4}
    set suite variable    ${gNb2Id_DEC}
    Check XP setup procedure    logname=${logname_gnb1}   prime_gnb_index=${xnap_gnb1}    gnb_ID=${gNb2Id_DEC}
    ...    XP_Status=${1}
    Check XP setup procedure    logname=${logname_gnb2}    prime_gnb_index=${xnap_gnb5}    gnb_ID=${gNb1Id_DEC}
    ...    XP_Status=${1}

Check XP setup procedure
    [Arguments]    ${logname}    ${prime_gnb_index}    ${gnb_ID}    ${XP_Status}
    Check IgNBCAXpSetupRequest message    logname=${logname}    gnb_ID=${gnb_ID}
    Check IgNBCAXpSetupResponse message    logname=${logname}    gnb_ID=${gnb_ID}    XP_Status=${XP_Status}
    Check IgNBCAconfigurationUpdateIndication message    logname=${logname}    soure_ip=${prime_gnb_index}

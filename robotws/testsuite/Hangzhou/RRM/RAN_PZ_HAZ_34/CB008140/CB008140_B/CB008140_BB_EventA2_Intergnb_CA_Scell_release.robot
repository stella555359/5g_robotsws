#*** Settings ***
#Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
#Variables    ./Resources/CB008140_B_variables.py
#
#Documentation
#...   author: xiaodan.li
#...   contact: xiaodan.li@nokia-sbell.com
#...   squad group: SG_03
#...   Feature CB008140-BB
#
#Suite Setup    Run Keywords    Common Suite Setup for COAM    AND
#...               Adjust gNB_RU Attenuation    AND
#...               Get sagnb release    AND
#...               get_release_check_result
#
#Suite Teardown    Run Keywords
#...               Common Suite Teardown for COAM   gnb_list=${gnb_list_BB}    AND
#...               Run Keyword And Ignore Error    COAM Teardown gnb connections
#
#*** Variables ***
#${golden_scf_name_gnb0}    Configuration_scf_GNB1_CB008140.xml
#${golden_scf_name_gnb2}    Configuration_scf_GNB3_CB008140.xml
#${golden_scf_name_gnb3}    Configuration_scf_GNB4_CB008140.xml
#${filename_BA002_gnb2}    log_name_BA_002_gNB3.pcap
#${filename_BA002_gnb3}    log_name_BA_002_gNB4.pcap
#${filename_BA002_AND_BB001_gnb2}    log_name_BA_002_AND_BB001_gNB3.pcap
#${filename_BA002_AND_BB001_gnb3}    log_name_BA_002_AND_BB001_gNB4.pcap
#${filename1_BA005_AND_BB003_gnb2}    log_name_BA_005_AND_BB003_gNB3.pcap
#${filename1_BA005_AND_BB003_gnb3}    log_name_BA_005_AND_BB003_gNB4.pcap
#${filename_BA005_gnb2}    log_name_BA_005_gNB3.pcap
#${filename_BA005_gnb3}    log_name_BA_005_gNB4.pcap
#${filename_BA011_gnb2}    log_name_BA_011_gNB3.pcap
#${filename_BA011_gnb3}    log_name_BA_011_gNB4.pcap
#${filename1_BA011_gnb2}    log1_name_BA_011_gNB3.pcap
#${filename1_BA011_gnb3}    log1_name_BA_011_gNB4.pcap
#${filename_BB007_gnb2}    log_name_BB_007_gNB3.pcap
#${filename_BB007_gnb3}    log_name_BB_007_gNB4.pcap
#${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
#${scf_path}    /opt/workspace/SCF/
#@{counter_gnb3_M55118C05507}    ${1}
#@{counter_gnb3_M55118C05507_and_M55118C07507}    ${1}    ${1}
#@{expected_value_BA002_And_AE005_gnb4}    ${1}    ${1}    ${1}    ${1}
#@{expected_value_AE005_gnb3}    ${1}    ${1}
#@{expected_value_BA002_and_AC003_and_AD001_gnb3}    ${1}    ${1}    ${1}    ${1}    ${1}    ${1}    ${1}    ${1}    ${1}
#@{expected_value_BA002_and_BB001_gnb3}    ${1}    ${1}    ${1}    ${1}    ${1}    ${1}    ${1}    ${5}    ${5}
#@{expected_value_BA002_and_AC003_gnb4}    ${1}    ${1}    ${1}    ${1}    ${1}
#@{cell_id_001_gnb1}    ${0}
#@{gnb2_ip}    ${bts_host1}
#@{gnb_ips_BB}    ${bts_host2}    ${bts_host3}
#@{gnb_ips_BB_Exter-gNB}    ${bts_host2}
#${Send_Tput_DL_T_T}    2500M
#${Send_Tput_DL_F_F}    800M
#${Send_Tput_DL_T_F}    1800
#${expected_tput_dl_T_100MHz}    1400
#${expected_tput_dl_T_40MHz}    540
#${expected_tput_dl_F}    390
#${expected_tput_dl_F_10MHz_GK001}    0
#${filter_param_timerOverheat}    Overheat indication prohibit timer
#${abbr_timerOverheat}     timerOverheatIndProhibit
#${dist_name_timerOverheat}    MRBTS-${gnb_instance2}/NRBTS-${gnb_instance2}
#${ue_apn}    dxdata1
#@{gnb_list_BB}    ${2}    ${3}
#@{gnb_list_BB_all}    ${0}    ${2}    ${3}
#@{gnb_list_BB_Exter-gNB}    ${2}
#@{filename_BB001}    filename_BA002_gnb    filename_BA002_AND_BB001_gnb
#@{filename_BB003}    filename_BA002_gnb    filename_BA002_AND_BB001_gnb
#@{filename_BB007}    filename_BA011_gnb    filename_BB007_gnb
#@{scell_index_list_BB001}    ${2}
#@{extgnb_index_list_BB001}    ${3}
#@{scell_index_list_BB003}    ${1}
#@{extgnb_index_list_BB003}    ${2}
#@{expected_value_AC003_gnb4}    ${1}    ${1}
#@{expected_value_KG001_gnb3}    ${1}
#@{AC003_and_BA002_and_AE005_gnb4}    ${1}    ${1}    ${1}    ${1}    ${1}    ${1}    ${1}    ${1}    ${1}
#@{expected_value_AC003_and_BA002_AE005_gNB3}    ${1}    ${1}    ${1}    ${1}    ${1}    ${1}
#@{expected_value_BB001_And_AD001_gNB4}    ${6}    ${6}    ${6}    ${12}    ${12}    ${6}
#${enb_cell_BB001_38611}    366
#${enb_cell_BB001_38711}    376
#${enb_cell_BB001_38511}    356
#${gnb4_cell3_value_38711}    ${5}
#${gnb3_cell3_value_38711}    ${0}
#${gnb4_cell3_value_38611}    ${20}
#${gnb3_cell3_value_38611}    ${32}
#${gnb3_cell3_value_release_38611}    ${50}
#${gnb3_cell3_value_release_38711}    ${35}
#
#*** Test Cases ***
#[1]CB008140-BB_001_Event_A2_measurement_rsrp_based_triggered_IgCA_Scell_release_for_SA_2CC_CA_UE
#    [Documentation]    This user scenario describes the gNB behaviour, when a UE for which FDD-FDD carrier aggregation
#    ...                has been configured (2CC CA) moves towards the cell edge and as the SCell degrades UE sends
#    ...                measurement report for A2 RSRP(associated with external SCell) to trigger inter-gNB CA SCell release.
#    ...                the case add the 8140-BA002 and 8140-AD and 8140-GE checkpoint
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for BB001
#    MultiUE.Prepare UE
#    ##trigger with rsrq F+F
#    Adjust gNB_RU Attenuation    gnb3_cell1_value=${0}    gnb4_cell2_value=${0}
#    Prepare with PM counter time to caculate    period=start
#    Start capture multi gNB log    filename=filename_BA002_gnb    gnb_list=${gnb_list_BB}
#    MultiUE.Attach
#    sleep    5s
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_F_F}    duration=1200
#    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell=${expected_tput_dl_F}
#    ...    scellid=2    pcellid=1    gnb_prime=${2}    gnb_external=${3}
#    MultiUE.Stop DL Traffic
#    MultiUE.Detach
#    sleep    5s
#    Stop capture multi gNB log    filename=filename_BA002_gnb    gnb_list=${gnb_list_BB}
#    sleep    5s
#    Prepare with PM counter time to caculate    period=end
#    comment    check the counter
#    Check counter for BA002 and AC003 and AD001
#    Hanging resource test    gnb_ips=@{gnb_ips_BB}    gnb_list=@{gnb_list_BB}
#    ##trigger with rsrp
#    Modify Parameters for Cases    gnb_index=${2}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB3_BA002_1}
#    Wait Until Keyword Succeeds    20 min    30 sec    Cell Should Be Lock or Unlock
#    ...    gnb_index=${2}    cell_idx=${11}    cell_group_idx=${11}
#    Adjust gNB_RU Attenuation    gnb3_cell1_value=${0}    gnb4_cell2_value=${0}
#    Prepare with PM counter time to caculate    period=start
#    Start capture multi gNB log    filename=filename_BA002_AND_BB001_gnb    gnb_list=${gnb_list_BB}
#    MultiUE.Attach
#    sleep    5s
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_F_F}    duration=1200
#    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell=${expected_tput_dl_F}
#    ...    scellid=2    pcellid=1    gnb_prime=${2}    gnb_external=${3}
#    MultiUE.Stop DL Traffic
#    Adjust gNB_RU Attenuation    gnb3_cell1_value=${30}    gnb4_cell2_value=${50}
#    sleep    5s
#    Stop capture multi gNB log    filename=filename_BA002_AND_BB001_gnb    gnb_list=${gnb_list_BB}
#    MultiUE.Detach
#    Prepare with PM counter time to caculate    period=end
#    Check counter for BA002 and BB001 and GE001
#    comment    check the wireshark log
#    Check wireshark log for BA   logname=${filename_BA002_gnb2}    logname1=${filename_BA002_gnb3}
#    ...    rsrp=117    rsrq=64    pcell_index=${1}    Primegnb_index=${2}    A2_release_detach=False
#    ...    scell_index_list=${scell_index_list_BB001}    extgnb_index_list=${extgnb_index_list_BB001}    event_id=${3}
#    Check wireshark log for BA   logname=${filename_BA002_AND_BB001_gnb2}    logname1=${filename_BA002_AND_BB001_gnb3}
#    ...    rsrp=90    rsrq=70    pcell_index=${1}    Primegnb_index=${2}    A2_release_detach=True
#    ...    scell_index_list=${scell_index_list_BB001}    extgnb_index_list=${extgnb_index_list_BB001}    event_id=${2}
#    Check wireshark log for BB001   logname=${filename_BA002_AND_BB001_gnb2}    logname1=${filename_BA002_AND_BB001_gnb3}
#    Check wireshark log for GE001   logname=${filename_BA002_AND_BB001_gnb2}
#    Hanging resource test    gnb_ips=@{gnb_ips_BB}    gnb_list=@{gnb_list_BB}
#    [Teardown]    run keywords
#    ...    Case Recover BB001    AND
#    ...    Case Teardown    filename=${filename_BB001}    gnb_list=${gnb_list_BB}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#[1]CB008140-BB_003_Event_A2_measurement_rsrq_based_triggered_IgCA_Scell_release_for_SA_2CC_CA_UE
#    [Documentation]    This user scenario describes the gNB behaviour, when a UE for which FDD-FDD carrier aggregation
#    ...                has been configured (2CC CA) moves towards the cell edge and as the SCell degrades UE sends measurement
#    ...                report for A2(rsrq), associated with external SCell to trigger inter-gNB CA SCell release..
#    ...                the case add the 8140-BA005 and 8140-GK001 checkpoint
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for BB003
#    MultiUE.Prepare UE
#    ##ADD BA005 checkpoint, trigger BA003 with rsrqCombined T+F
#    Adjust gNB_RU Attenuation    gnb4_cell3_value=${0}    gnb3_cell1_value=${0}
#    Start capture multi gNB log    filename=filename1_BA005_AND_BB003_gnb    gnb_list=${gnb_list_BB}
#    MultiUE.Attach
#    sleep    5s
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_T_F}    duration=1200
#    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_T_100MHz}    tput_dl_scell=${expected_tput_dl_F}
#    ...    scellid=1    pcellid=31    gnb_prime=${3}    gnb_external=${2}
#    MultiUE.Stop DL Traffic
#    Adjust gNB_RU Attenuation    gnb4_cell3_value=${30}    gnb3_cell1_value=${0}
#    Adjust gNB_RU Attenuation    gnb4_cell3_value=${30}    gnb3_cell1_value=${70}
#    Stop capture multi gNB log    filename=filename1_BA005_AND_BB003_gnb    gnb_list=${gnb_list_BB}
#    Hanging resource test    gnb_ips=@{gnb_ips_BB_Exter-gNB}    gnb_list=@{gnb_list_BB_Exter-gNB}
#    MultiUE.Detach
#    Hanging resource test    gnb_ips=@{gnb_ips_BB}    gnb_list=@{gnb_list_BB}
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_MODIFY_GNB4_BB003_1}
#    ##adujst PA not trigger A1 ###
#    Adjust gNB_RU Attenuation    gnb4_cell3_value=${30}
#    Start capture multi gNB log    filename=filename_BA005_gnb    gnb_list=${gnb_list_BB}
#    MultiUE.Attach
#    sleep    5s
#    MultiUE.Detach
#    Stop capture multi gNB log    filename=filename_BA005_gnb    gnb_list=${gnb_list_BB}
#    ##ADD GK001 checkpoint
#    Online modify NIDD on gnb    gnb_index=${2}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB3_GK001}
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_GK001}
#    Adjust gNB_RU Attenuation    gnb4_cell3_value=${0}    gnb3_cell1_value=${0}
#    Prepare with PM counter time to caculate    period=start
#    MultiUE.Attach
#    sleep    5s
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_T_F}    duration=1200
#    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_T_100MHz}    tput_dl_scell=${expected_tput_dl_F_10MHz_GK001}
#    ...    scellid=1    pcellid=31    gnb_prime=${3}    gnb_external=${2}
#    MultiUE.Stop DL Traffic
#    MultiUE.Detach
#    Prepare with PM counter time to caculate    period=end
#    comment    check the counter
#    Check counter for AC003 and GK001
#    comment    check the wireshark log
#    Check wireshark log for BA   logname=${filename1_BA005_AND_BB003_gnb3}    logname1=${filename1_BA005_AND_BB003_gnb2}
#    ...    rsrq=64    pcell_index=${31}    Primegnb_index=${3}    A2_release_detach=True
#    ...    scell_index_list=${scell_index_list_BB003}    extgnb_index_list=${extgnb_index_list_BB003}    event_id=${2}
#    ...    UEContextModificationResponse_nums=${2}
#    Check wireshark log for BA Not addition   logname=${filename_BA005_gnb3}
#    Check wireshark log for BB003   logname=${filename1_BA005_AND_BB003_gnb3}    logname1=${filename1_BA005_AND_BB003_gnb2}
#    Hanging resource test    gnb_ips=@{gnb_ips_BB}    gnb_list=@{gnb_list_BB}
#    [Teardown]    run keywords
#    ...    Case Teardown    filename=${filename_BB003}    gnb_list=${gnb_list_BB}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#[1]CB008140-BB_007_Handling_of_ping_pong_between_Scell_addition_and_Scell_release_for_SA_2CC_CA_UE_with_T_T_data_check
#    [Documentation]   This user scenario describes the gNB behavior, when a UE for which carrier aggregation has been
#    ...               configured sends immediately (within A2 timeToTrigger + 1 sec (R&D timer: rdA2SCellRelWaitTimer)
#    ...               measurement report for A2 to trigger SCell release. User scenario covers the case of continuous
#    ...               ping-pong between SCell addition and SCell release when A1 threshold for SCell addition is set to
#    ...               a too low value, and also check the Data transfer is still normal for TDD_TDD 2CC.
#    ...               the case add the 8140-BA011  checkpoint
#    [Tags]     classical    CRT_TRUNK
#    [Timeout]    2 hour
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for BB007
#    Lock/Unlock other cell    cell=Lock
#    ##ADD BA011 checkpoint
#    MultiUE.Prepare UE
#    MultiUE.Change APN    APN=${ue_apn}
#    Adjust gNB_RU Attenuation    gnb4_cell3_value=${20}
#    Wait Until Keyword Succeeds    3X    10s     Attach and check succeed    filename=filename_BA011_gnb
#    ...    logname=${filename_BA011_gnb3}
#    Start capture multi gNB log    filename=filename1_BA011_gnb    gnb_list=${gnb_list_BB}
#    Modify Parameters for Cases    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_BA011}
#    Adjust gNB_RU Attenuation    gnb4_cell3_value=${0}
#    sleep    5s
#    Stop capture multi gNB log    filename=filename1_BA011_gnb    gnb_list=${gnb_list_BB}
#    MultiUE.Detach
#    Check wireshark log for BA011    logname=${filename1_BA011_gnb3}
#    ##BB007 checkpoint
#    Modify Parameters for Cases    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_BA011_1}
#    Adjust gNB_RU Attenuation    gnb4_cell3_value=${0}
#    Prepare with PM counter time to caculate    period=start
#    MultiUE.Attach
#    sleep    5s
#    Adjust gNB_RU Attenuation
#    ...    gnb4_cell3_value=${gnb4_cell3_value_${gnb_instance0}}    gnb3_cell3_value=${gnb3_cell3_value_${gnb_instance0}}
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_T_T}    duration=1200
#    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_T_100MHz}    tput_dl_scell=${expected_tput_dl_T_40MHz}
#    ...    scellid=3    pcellid=31    gnb_prime=${3}    gnb_external=${2}
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
#    Prepare with PM counter time to caculate    period=end
#    Check counter for AC001 and BA002 and AE005
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_T_T}    duration=2400
#    Prepare with PM counter time to caculate    period=start
#    Start capture multi gNB log    filename=filename_BB007_gnb    gnb_list=${gnb_list_BB}
#    Adjust gNB_RU Attenuation    gnb4_cell3_value=${0}    gnb3_cell3_value=${gnb3_cell3_value_release_${gnb_instance0}}
#    sleep    2min
#    Stop capture multi gNB log    filename=filename_BB007_gnb    gnb_list=${gnb_list_BB}
#    Prepare with PM counter time to caculate    period=end
#    Check counter for BB001
#    Adjust gNB_RU Attenuation
#    ...    gnb4_cell3_value=${gnb4_cell3_value_${gnb_instance0}}    gnb3_cell3_value=${gnb3_cell3_value_${gnb_instance0}}
#    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_T_100MHz}    tput_dl_scell=${expected_tput_dl_T_40MHz}
#    ...    scellid=3    pcellid=31    gnb_prime=${3}    gnb_external=${2}
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
#    MultiUE.Detach
#    Check wireshark log for BB007    logname=${filename_BB007_gnb3}
#    Hanging resource test    gnb_ips=@{gnb_ips_BB}    gnb_list=@{gnb_list_BB}
#    [Teardown]    run keywords
#    ...    Lock/Unlock other cell    cell=UnLock    AND
#    ...    Check Unexpect Alarm whether exist    AND
#    ...    Case Teardown    filename=${filename_BB007}    gnb_list=${gnb_list_BB}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation
#
#*** Keywords ***
#Common Case TestLine Setup for BB001
#    @{scf_list}    Create List
#    ${scf_gnb3}    Only Modify SCF before Perform Commission    gnb_index=${2}
#    ...    golden_scf_name=${golden_scf_name_gnb2}    MOsToAdd=${MOS_ADD_GNB4_BB001}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_BA002}
#    ...    ListParamterToModify=${LIST_TO_MODIFY_GNB3_BB001}    ListToAdd=${LIST_TO_ADD_GNB3_BB001}
#    Append to List    ${scf_list}    ${scf_gnb3}
#    ${scf_gnb4}    Only Modify SCF before Perform Commission    gnb_index=${3}
#    ...    golden_scf_name=${golden_scf_name_gnb3}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB4_BB001}
#    ...    ListParamterToModify=${LIST_TO_MODIFY_GNB4_BB001}    ListToAdd=${LIST_TO_ADD_GNB4_BB001}
#    Append to List    ${scf_list}    ${scf_gnb4}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_BB}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_BB}
#    Modify Parameters for Cases    gnb_index=${2}    Modify_Para_Online=${PARAMETERS_TO_MODIFY_GNB3_BA002_LOCK}
#    Wait Until Keyword Succeeds    20 min    30 sec    Cell Should Be Lock or Unlock
#    ...    gnb_index=${2}    cell_idx=${11}    cell_group_idx=${11}
#    Modify Parameters for Cases    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_MODIFY_GNB4_BA002_LOCK}
#    Wait Until Keyword Succeeds    20 min    30 sec    Cell Should Be Lock or Unlock
#    ...    gnb_index=${3}    cell_idx=${21}    cell_group_idx=${21}
#    Connect and Modify the parameter on enblte
#    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_cell_BB001_${gnb_instance0}}
#    ...    parameter=administrativeState     value=locked
#
#Common Case TestLine Setup for BB003
#    @{scf_list}    Create List
#    ${scf_gnb3}    Only Modify SCF before Perform Commission    gnb_index=${2}
#    ...    golden_scf_name=${golden_scf_name_gnb2}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_BB003}
#    ...    ListParamterToModify=${LIST_TO_MODIFY_GNB3_BB003}    ListToAdd=${LIST_TO_ADD_GNB3_BB003}
#    Append to List    ${scf_list}    ${scf_gnb3}
#    ${scf_gnb4}    Only Modify SCF before Perform Commission    gnb_index=${3}
#    ...    golden_scf_name=${golden_scf_name_gnb3}    MOsToAdd=${MOS_ADD_GNB4_BB003}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB4_BA005_and_BB003_and_GK001}
#    ...    ListParamterToModify=${LIST_TO_MODIFY_GNB4_BB003}    ListToAdd=${LIST_TO_ADD_GNB4_BB003}
#    Append to List    ${scf_list}    ${scf_gnb4}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_BB}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_BB}
#
#Common Case TestLine Setup for BB007
#    @{scf_list}    Create List
#    Append to List    ${scf_list}    ${scf_path}${golden_scf_name_gnb0}
#    ${scf_gnb3}    Only Modify SCF before Perform Commission    gnb_index=${2}
#    ...    golden_scf_name=${golden_scf_name_gnb2}    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_BB007}
#    ...    ListParamterToModify=${LIST_TO_MODIFY_GNB3_BB007}    ListToAdd=${LIST_TO_ADD_GNB3_BB007}
#    Append to List    ${scf_list}    ${scf_gnb3}
#    ${scf_gnb4}    Only Modify SCF before Perform Commission    gnb_index=${3}
#    ...    golden_scf_name=${golden_scf_name_gnb3}    MOsToAdd=${MOS_ADD_GNB4_BB007}
#    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB4_BB007}
#    ...    ListParamterToModify=${LIST_TO_MODIFY_GNB4_BB007}    ListToAdd=${LIST_TO_ADD_GNB4_BB007}
#    Append to List    ${scf_list}    ${scf_gnb4}
#    Log to console    Start to modify scf files and commission, please wait...
#    Multi-gNB commission    index_list=${gnb_list_BB_all}    scf_list=${scf_list}
#    Check the MultiBTS cells status on air    gnb_list=${gnb_list_BB_all}
#
#Case Recover BB001
#    Online modify NIDD on gnb    gnb_index=${2}    Modify_Para_Online=${PARAMETERS_TO_MODIFY_GNB3_BA002_UNLOCK}
#    Online modify NIDD on gnb    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_MODIFY_GNB4_BA002_UNLOCK}
#    Connect and Modify the parameter on enblte
#    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_cell_BB001_${gnb_instance0}}
#    ...    parameter=administrativeState     value=unlocked
#
#Check counter for BA002 and AC003 and AD001
#    sleep    40s
#    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be greater than 1
#    ...    gnb_index=${2}    counter_id=${counter_id_BA002_gNB3_M55118C05507}
#    ...    dic_path=${counter_dic_path_gNB3_M55118C05507_Trunk}    value=${counter_gnb3_M55118C05507}
#    ...    ELSE    Check the PM counter should be greater than 1
#    ...    gnb_index=${2}    counter_id=${counter_id_BA002_gNB3_M55118C05507}
#    ...    dic_path=${counter_dic_path_gNB3_M55118C05507}    value=${counter_gnb3_M55118C05507}
#    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be value
#    ...    gnb_index=${2}    counter_id=${counter_id_BA002_and_AC003_and_AD001_gNB3}
#    ...    dic_path=${counter_dic_path_BA002_and_AC003_and_AD001_gNB3_Trunk}
#    ...    value=${expected_value_BA002_and_AC003_and_AD001_gnb3}
#    ...    ELSE    Check the PM counter should be value
#    ...    gnb_index=${2}    counter_id=${counter_id_BA002_and_AC003_and_AD001_gNB3}
#    ...    dic_path=${counter_dic_path_BA002_and_AC003_and_AD001_gNB3}
#    ...    value=${expected_value_BA002_and_AC003_and_AD001_gnb3}
#    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be value
#    ...    gnb_index=${3}    counter_id=${counter_id_BA002_and_AC003_gNB4}
#    ...    dic_path=${counter_dic_path_BA002_and_AC003_gNB4_Trunk}    value=${expected_value_BA002_and_AC003_gnb4}
#    ...    ELSE     Check the PM counter should be value
#    ...    gnb_index=${3}    counter_id=${counter_id_BA002_and_AC003_gNB4}
#    ...    dic_path=${counter_dic_path_BA002_and_AC003_gNB4}    value=${expected_value_BA002_and_AC003_gnb4}
#
#Check counter for BA002 and BB001 and GE001
#    sleep    40s
#    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be greater than 1
#    ...    gnb_index=${2}    counter_id=${counter_id_gNB3_M55118C05507_and_M55118C07507}
#    ...    dic_path=${counter_dic_path_gNB3_M55118C05507_and_M55118C07507_Trunk}
#    ...    value=${counter_gnb3_M55118C05507_and_M55118C07507}
#    ...    ELSE    Check the PM counter should be greater than 1
#    ...    gnb_index=${2}    counter_id=${counter_id_gNB3_M55118C05507_and_M55118C07507}
#    ...    dic_path=${counter_dic_path_gNB3_M55118C05507_and_M55118C07507}    value=${counter_gnb3_M55118C05507_and_M55118C07507}
#    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be value
#    ...    gnb_index=${2}    counter_id=${counter_id_BA002_and_BB001_gNB3}
#    ...    dic_path=${counter_dic_path_BA002_and_BB001_gNB3_Trunk}    value=${expected_value_BA002_and_BB001_gnb3}
#    ...    ELSE    Check the PM counter should be value
#    ...    gnb_index=${2}    counter_id=${counter_id_BA002_and_BB001_gNB3}    dic_path=${counter_dic_path_BA002_and_BB001_gNB3}
#    ...    value=${expected_value_BA002_and_BB001_gnb3}
#    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be value
#    ...    gnb_index=${3}    counter_id=${counter_id_BA002_and_AC003_gNB4}
#    ...    dic_path=${counter_dic_path_BA002_and_AC003_gNB4_Trunk}    value=${expected_value_BA002_and_AC003_gnb4}
#    ...    ELSE    Check the PM counter should be value
#    ...    gnb_index=${3}    counter_id=${counter_id_BA002_and_AC003_gNB4}    dic_path=${counter_dic_path_BA002_and_AC003_gNB4}
#    ...    value=${expected_value_BA002_and_AC003_gnb4}
#
#Check counter for AC003 and GK001
#    sleep    40s
#    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be value
#    ...    gnb_index=${3}    counter_id=${counter_id_AC003_gNB4}    dic_path=${counter_dic_path_AC003_gNB4_Trunk}
#    ...    value=${expected_value_AC003_gnb4}
#    ...    ELSE    Check the PM counter should be value
#    ...    gnb_index=${3}    counter_id=${counter_id_AC003_gNB4}    dic_path=${counter_dic_path_AC003_gNB4}
#    ...    value=${expected_value_AC003_gnb4}
#    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be value
#    ...    gnb_index=${2}    counter_id=${counter_id_GK001_gNB3}    dic_path=${counter_dic_path_GK001_gNB3_Trunk}
#    ...    value=${expected_value_KG001_gnb3}
#    ...    ELSE    Check the PM counter should be value
#    ...    gnb_index=${2}    counter_id=${counter_id_GK001_gNB3}    dic_path=${counter_dic_path_GK001_gNB3}
#    ...    value=${expected_value_KG001_gnb3}
#
#Check counter for AC001 and BA002 and AE005
#    sleep    40s
#    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be greater than 1
#    ...    gnb_index=${3}    counter_id=${counter_id_BA002_And_AE005_gNB4}
#    ...    dic_path=${counter_dic_path_BA002_And_AE005_gNB4_Trunk}    value=${expected_value_BA002_And_AE005_gnb4}
#    ...    ELSE    Check the PM counter should be greater than 1
#    ...    gnb_index=${3}    counter_id=${counter_id_BA002_And_AE005_gNB4}
#    ...    dic_path=${counter_dic_path_BA002_And_AE005_gNB4}    value=${expected_value_BA002_And_AE005_gnb4}
#    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be value
#    ...    gnb_index=${3}    counter_id=${counter_id_AC003_and_BA002_and_AE005_gNB4}
#    ...    dic_path=${counter_dic_path_AC003_and_BA002_and_AE005_gNB4_Trunk}
#    ...    value=${AC003_and_BA002_and_AE005_gnb4}
#    ...    ELSE    Check the PM counter should be value
#    ...    gnb_index=${3}    counter_id=${counter_id_AC003_and_BA002_and_AE005_gNB4}
#    ...    dic_path=${counter_dic_path_AC003_and_BA002_and_AE005_gNB4}
#    ...    value=${AC003_and_BA002_and_AE005_gnb4}
#    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be greater than 1
#    ...    gnb_index=${2}    counter_id=${counter_id_AE005_gNB3}
#    ...    dic_path=${counter_dic_path_AE005_gNB3_trunk}    value=${expected_value_AE005_gnb3}
#    ...    ELSE    Check the PM counter should be greater than 1
#    ...    gnb_index=${2}    counter_id=${counter_id_AE005_gNB3}
#    ...    dic_path=${counter_dic_path_AE005_gNB3}    value=${expected_value_AE005_gnb3}
#    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be value
#    ...    gnb_index=${2}    counter_id=${counter_id_AC003_and_BA002_AE005_gNB3_Trunk}
#    ...    dic_path=${counter_dic_path_AC003_and_BA002_AE005_gNB3_Trunk}
#    ...    value=${expected_value_AC003_and_BA002_AE005_gNB3}
#    ...    ELSE    Check the PM counter should be value
#    ...    gnb_index=${2}    counter_id=${counter_id_AC003_and_BA002_AE005_gNB3}
#    ...    dic_path=${counter_dic_path_AC003_and_BA002_AE005_gNB3}
#    ...    value=${expected_value_AC003_and_BA002_AE005_gNB3}
#
#Check counter for BB001
#    sleep    40s
#    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be value
#    ...    gnb_index=${3}    counter_id=${counter_id_BB001_And_AD001_gNB4}
#    ...    dic_path=${counter_dic_path_BB001_And_AD001_gNB4_Trunk}
#    ...    value=${expected_value_BB001_And_AD001_gNB4}
#    ...    ELSE    Check the PM counter should be value
#    ...    gnb_index=${3}    counter_id=${counter_id_BB001_And_AD001_gNB4}    dic_path=${counter_dic_path_BB001_And_AD001_gNB4}
#    ...    value=${expected_value_BB001_And_AD001_gNB4}
#
#Check wireshark log for BA
#    [Arguments]    ${logname}    ${logname1}    ${event}=0    ${rsrp}=NULL    ${rsrq}=NULL
#    ...    ${pcell_index}=${1}    ${Primegnb_index}=${0}    ${A2_release_detach}=False
#    ...    ${scell_index_list}=${scell_index_list}    ${extgnb_index_list}=${extgnb_index_list}    ${event_id}=${3}
#    ...    ${UEContextModificationResponse_nums}=${2}
#    Check wireshark log for Measurement EventA1/A2    logname=${logname}    event=${event}
#    ...    rsrp=${rsrp}    rsrq=${rsrq}    pcell_index=${1}    gnb_index=${2}    event_id=${event_id}
#    Check IgNBCAAdditionRequest message has scellAdditionMethodIndicator    logname=${logname}    MethodIndicator=0
#    Check attach and detach wireshark log    logname=${logname}    logname1=${logname1}
#    ...    Primegnb_index=${Primegnb_index}    extgnb_index_list=${extgnb_index_list}
#    ...    pcell_index=${pcell_index}    scell_index_list=${scell_index_list}
#    ...    UEContextModificationResponse_nums=${UEContextModificationResponse_nums}    A2_release_detach=${A2_release_detach}
#
#Check wireshark log for BA Not addition
#    [Arguments]    ${logname}    ${event}=0    ${rsrp}=NULL    ${rsrq}=NULL
#    Check RRC Reconfiguration message on PrimegNB    logname=${logname}    event=${event}    rsrp=${rsrp}    rsrq=${rsrq}
#    Check Measurement message on PrimegNB    logname=${logname}    event_id=${1}    cell_index=${31}
#    ...    gnb_index=${3}    meas_lengths=${4}
#    Check has no IgnbCAUeContextModificationRequest and IgNBCAAdditionRequest message    logname=${logname}
#
#Check wireshark log for BB001
#    [Arguments]    ${logname}    ${logname1}
#    Check wireshark log for Measurement EventA1/A2    logname=${logname}    event=0
#    ...    rsrp=90    pcell_index=${1}    gnb_index=${2}    event_id=${2}
#    Check wireshark log for Measurement EventA1/A2    logname=${logname}    event=1
#    ...    rsrp=66    pcell_index=${2}    gnb_index=${3}    event_id=${4}
#    Get cell id multignb
#    ...    lcrid_pcell=${1}    scell_index_list=${scell_index_list_BB001}
#    ...    PrimegNB_index=${2}    extgnb_index_list=${extgnb_index_list_BB001}
#    Check IgNBCAUeContextModificationRequest message has scell ToBeRemoved    logname=${logname}    release_cell=${extcell_id[0]}
#    Check IgNBCAUeContextModificationResponse message has scell ToBeRemoved    logname=${logname}    scelllcird=1
#    Check IgNBCAReleaseRequest message on PrimegNB    logname=${logname}
#    Check IgNBCAGnbDuConfigurationIndication message has release scellid on Prime gNB    logname=${logname}
#    Check IgNBCAReleaseRequestAcknowledge message on PrimegNB    logname=${logname1}
#
#Check wireshark log for BB003
#    [Arguments]    ${logname}    ${logname1}
#    Check wireshark log for Measurement EventA1/A2    logname=${logname}    event=1
#    ...    rsrq=66    pcell_index=${1}    gnb_index=${2}    event_id=${2}
#    Get cell id multignb
#    ...    lcrid_pcell=${31}    scell_index_list=${scell_index_list_BB003}
#    ...    PrimegNB_index=${3}    extgnb_index_list=${extgnb_index_list_BB003}
#    Check IgNBCAUeContextModificationRequest message has scell ToBeRemoved    logname=${logname}    release_cell=${extcell_id[0]}
#    Check IgNBCAUeContextModificationResponse message has scell ToBeRemoved    logname=${logname}    scelllcird=1
#    Check IgNBCAReleaseRequest message on PrimegNB    logname=${logname}
#    Check IgNBCAReleaseRequestAcknowledge message on PrimegNB    logname=${logname1}
#
#Check wireshark log for GE001
#    [Arguments]    ${logname}
#    Get value of parameter from WEBEM    dist_name=${dist_name_timerOverheat}
#    ...    filter_param=${filter_param_timerOverheat}    abbr=${abbr_timerOverheat}    value=1s    WEBUI_COAM=${WEBUI_host2}
#    Check overheatingAssistanceConfig in RRC Reconfiguration when CA setup    logname=${logname}
#    Check overheatingAssistanceConfig in RRC Reconfiguration when scell release    logname=${logname}
#
#Check overheatingAssistanceConfig in RRC Reconfiguration when CA setup
#    [Arguments]    ${logname}
#    ...    ${message_filter}=nokiaf1ap.procedureCode == 12 and nr-rrc.overheatingAssistanceConfig and nr-rrc.overheatingIndicationProhibitTimer
#    ...    ${xpath}=.//nr-rrc.overheatingAssistanceConfig
#    ...    ${xpath1}=.//nr-rrc.overheatingIndicationProhibitTimer
#    Log    Check overheatingAssistanceConfig in RRC Reconfiguration when CA setup
#    ${overheatingAssistanceConfig}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    should be equal    ${overheatingAssistanceConfig[0]}    1
#    ${overheatingIndicationProhibitTimer}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
#    should be equal    ${overheatingIndicationProhibitTimer[0]}    2
#
#Check overheatingAssistanceConfig in RRC Reconfiguration when scell release
#    [Arguments]    ${logname}
#    ...    ${message_filter}=nokiaf1ap.procedureCode == 12 and nr-rrc.overheatingAssistanceConfig and nr-rrc.SCellIndex
#    ...    ${xpath}=.//nr-rrc.overheatingAssistanceConfig
#    ...    ${xpath1}=.//nr-rrc.SCellIndex
#    Log    Check overheatingAssistanceConfig in RRC Reconfiguration when scell release
#    ${overheatingAssistanceConfig}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    should be equal    ${overheatingAssistanceConfig[0]}    0
#    ${SCellIndex}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
#    should be equal    ${SCellIndex[0]}    1
#
#Check wireshark log for BA011
#    [Arguments]    ${logname}
#    Check Measurement message on PrimegNB    logname=${logname}    event_id=${1}    cell_index=${31}
#    ...    gnb_index=${3}    meas_lengths=${4}
#    Check has no IgnbCAUeContextModificationRequest and IgNBCAAdditionRequest message    logname=${logname}
#
#Check wireshark log for BB007
#    [Arguments]    ${logname}
#    ...    ${message_filter_A1}=nokiaf1ap.procedureCode == 13 and nr-rrc.measResultServingMOList == 1
#    ...    ${message_filter_A2}=nokiaf1ap.procedureCode == 13 and nr-rrc.measResultServingMOList == 2
#    ...    ${message_filter_A2release}=nokiaxnap.Nokia_XnAP_PDU == 0 and nokiaxnap.procedureCode == 142
#    ${timelist_A1}=    Get message time list    logname=${logname}    message_filter=${message_filter_A1}
#    ${timelist_A2}=    Get message time list    logname=${logname}    message_filter=${message_filter_A2}
#    ${timelist_A2release}=    Get message time list    logname=${logname}    message_filter=${message_filter_A2release}
#    ${A1_length}=    Get Length    ${timelist_A1}
#    ${A2_length}=    Get Length    ${timelist_A2}
#    ${A2release_length}=    Get Length    ${timelist_A2release}
#    Should Be Equal As Integers    ${A1_length}    6
#    Should Be Equal As Integers    ${A2_length}    10
#    Should Be Equal As Integers    ${A2release_length}    6
#
#    ${A1PP_list}    Get Slice from List    ${timelist_A1}    0    5
#    ${A2PP_list}    Get Slice from List    ${timelist_A2}    1    6
#    ${A2releasePP_list}    Get Slice from List    ${timelist_A2release}    1    6
#    : FOR    ${index}    IN RANGE    ${0}    ${5}
#    \    ${A1_time}    Convert To Number    ${A1PP_list[${index}]}
#    \    ${A2_time}    Convert To Number    ${A2PP_list[${index}]}
#    \    ${A2release_time1}    Convert To Number    ${A2releasePP_list[${index}]}
#    \    should be true    ${A1_time}<${A2_time}<${A2release_time1}
#    \    Run keyword if    ${index}==4    exit for loop
#    \    ${A1_time_next}=    Convert To Number    ${A1PP_list[${index}+${1}]}
#    \    should be true    ${A2release_time1}<${A1_time_next}
#
#Lock/Unlock other cell
#    [Arguments]    ${cell}=Lock
#    Modify Parameters for Cases    gnb_index=${3}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_CELl${cell}}
#    Modify Parameters for Cases    gnb_index=${2}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB3_CELl${cell}}
#    sleep    20s
#
#Attach and check succeed
#    [Arguments]    ${filename}    ${logname}
#    Start capture multi gNB log    filename=${filename}    gnb_list=${gnb_list_BB}
#    MultiUE.Detach
#    MultiUE.Attach
#    sleep    120s
#    Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list_BB}
#    Check RRC Reconfiguration message on PrimegNB    logname=${logname}    event=0    rsrp=97
#    [Teardown]    Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list_BB}

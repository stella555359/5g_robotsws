*** Settings ***
Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
Variables    ./Resources/CB008140_G_variables_2gnb.py

Documentation
...   author: qingqing.zhang
...   contact: qingqing.zhang@nokia-sbell.com xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB008140-GH+CB008140-HI

Suite Setup    Run Keywords
...               robot_common_operations.Common Suite Setup
...               AND    Common Suite Setup for COAM
...               AND    Get sagnb release
...               AND    Adjust gNB_RU Attenuation for 2gnb

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${tl_scf_gnb0}    SCF_GNB1_
${tl_scf_gnb1}    SCF_GNB2_
${scf_path}    /opt/workspace/SCF/
${filename_003_attach_gnb0}    log_name_GH_003_gNB1_attach.pcap
${filename1_003_HO_gnb0}    log_name1_GH_003_gNB1_source.pcap
${filename1_003_HO_gnb1}    log_name1_GH_003_gNB2_target.pcap
${filename2_003_HO_gnb0}    log_name2_GH_003_gNB1_target.pcap
${filename2_003_HO_gnb1}    log_name2_GH_003_gNB2_source.pcap
${filename1_003_attach_gnb0}    log_name1_GH_003_gNB1_attach.pcap
${filename3_003_HO_gnb0}    log_name3_GH_003_gNB1_source.pcap
${filename3_003_HO_gnb1}    log_name3_GH_003_gNB2_target.pcap
@{filename_GH003}    filename1_003_HO_gnb    filename2_003_HO_gnb
${filename_006_attach_gnb0}    log_name_GH_006_gNB1_attach.pcap
${filename_006_gnb0}    log_name_GH_006_gNB1_pcell_VONR.pcap
${filename_006_gnb1}    log_name_GH_006_gNB2_scell_VONR.pcap
${filename1_006_gnb0}    log_name_GH_006_gNB1_pcell_release_VONR.pcap
${filename1_006_gnb1}    log_name_GH_006_gNB2_scell_release_VONR.pcap
${filename_HI005_attach_gnb0}    log_name_HI_005_gNB1_attach.pcap
${filename_HI005_gnb0}    log_name_HI_005_gNB1_pcell_VONR.pcap
${filename_HI005_gnb1}    log_name_HI_005_gNB2_scell_VONR.pcap
${filename1_HI005_gnb0}    log_name_HI_005_gNB1_pcell_release_VONR.pcap
${filename1_HI005_gnb1}    log_name_HI_005_gNB2_scell_release_VONR.pcap
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/

${Send_Tput_DL_T_T}    500
${expected_tput_dl_T}    1400
${expected_tput_dl_F}    400
${ue_type}    ${tl.ues[0].capabilities[-1]}
${OndurationTimer_defaut}    ${10}
${OndurationTimer_VONR}    ${6}
${drxLongCycle_default}    ms160
@{DRX_ANR}    8    14    11
@{DRX_default}    7    14    9
@{DRX_VONR}    5    4    3
${drxLongCycle_vonr}    ms40
${OndurationTimer_defaut_HI005}    ${10}
${OndurationTimer_VONR_HI005}    ${10}
@{DRX_default_HI005}    7    3     3
@{DRX_VONR_HI005}    7    3    1
${drxLongCycle_default_HI005}    ms40
${drxLongCycle_vonr_HI005}    ms20

@{gnb_list}    ${0}    ${1}
@{gnb_ips}    ${bts_host0}    ${bts_host1}
@{gnb_list_GH0013}    ${0}
@{scell_index_list_cell1}    ${1}
@{extgnb_index_gnb1}    ${0}
@{scell_index_list_cell31}    ${31}
@{extgnb_index_gnb2}    ${1}

${UEContextModificationResponse_nums_38711}    ${2}
${UEContextModificationResponse_nums_38611}    ${2}

@{branch}    SBTS24R1_ENB_0000    SBTS24R2_ENB_0000
*** Test Cases ***
[1]CB008140-5G-GH_003_Inter-gNB_Handover_over_NG_of_a_UE_connection_in_IgNB_CA_mode_inte_Freaquency
    [Documentation]    This user scenario describes the inter-gNB handover over NG of a UE context in IgNB-CA mode.
    [Tags]     classical    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Common Case TestLine Setup with NRREl for GH003
    MultiUE.Prepare UE
    ###trigger inter NGHO
    GNB1 NGHO to GNB2    logname=${filename_003_attach_gnb0}    logname1=filename1_003_HO_gnb
    Comment    check the wireshark log
    Check wireshark log for GH003   logname=${filename1_003_HO_gnb0}    logname1=${filename1_003_HO_gnb1}
    Start capture multi gNB log    filename=filename2_003_HO_gnb    gnb_list=${gnb_list}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell2_value=${20}    gnb1_cell1_value=${20}
    sleep    3s
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell2_value=${30}    gnb1_cell1_value=${0}
    Sleep    3s
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell2_value=${35}    gnb1_cell1_value=${0}
    Sleep    3s
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell2_value=${40}    gnb1_cell1_value=${0}
    Sleep    3s
    Run keyword if    '${gnb_instance0}' == '${gnb_id}[2]'
    ...    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${0}    gnb2_cell3_value=${5}
    ...    ELSE    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${0}    gnb2_cell3_value=${32}
    Sleep    3s
    Stop capture multi gNB log    filename=filename2_003_HO_gnb    gnb_list=${gnb_list}
    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell=${expected_tput_dl_T}
        ...    scellid=31    pcellid=1    gnb_prime=${0}    gnb_external=${1}    ue_type=${tl.ues[0].capabilities[0]}
    Comment    check the wireshark log
    Check wireshark log for GH003_02   logname=${filename2_003_HO_gnb0}    logname1=${filename2_003_HO_gnb1}
    MultiUE.Stop DL Traffic
    MultiUE.Detach
    ###ADD check CB0130552 with actSliceSwitchToDefault=true
    Run keyword if    '${release_info}' != 'SBTS24R2_ENB_0000'    Run Keywords
    ...    Modify Parameters for Cases   gnb_index=${1}    Delete_Para_Online=${PARAMETERS_TO_DELETE_GNB2_CB0130552}
    ...    Add_Para_Online=${LIST_TO_ADD_GNB2_CB0130552}    Modify_Para_Online=${PARAMETERS_TO_enable_GNB2_CB0130552}
    ...    AND     Modify Parameters for Cases   gnb_index=${0}     Modify_Para_Online=${PARAMETERS_TO_enable_GNB1_CB0130552}
    ...    AND    GNB1 NGHO to GNB2    logname=${filename1_003_attach_gnb0}    logname1=filename3_003_HO_gnb
    ...    AND    Check wireshark log for CB0130552    logname=${filename3_003_HO_gnb0}    logname1=${filename3_003_HO_gnb1}
    MultiUE.Stop DL Traffic
    MultiUE.Detach
    Run Keyword And Ignore Error    Hanging resource test    gnb_ips=@{gnb_ips}    gnb_list=${gnb_list}
    [Teardown]    run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation for 2gnb    AND
    ...    Run Keyword And Ignore Error    Case Teardown    filename=${filename_GH003}    gnb_list=${gnb_list}


[1]CB008140-5G-GH_006_Scell_addition_after_DRX_setup_5QI1_and_5QI7
    [Documentation]    This user scenario verifies the case that UE is configured with DRX while SCell addition is triggered.
    ...    In this case, DRX configuration impacts SCell’s resource allocation procedure
    ...    add [1] CB008140-5G-HI_005_DRX_state synchronization_for_UE configured_with_IGCA_VONR_drxLongCycle_20ms checkpoint
    [Tags]     classical    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Common Case TestLine Setup with NRREl for GH006
    Attach and start-end vonr call and grab all log    filename_attach=${filename_006_attach_gnb0}
    ...    filename_vonr=filename_006_gnb    filename_vonrend=filename1_006_gnb
    Comment    ADD 8140-HI check point
    Run keyword if    '${gnb_instance0}' == '${gnb_id}[1]'
    ...    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_GH006_DRX_HI}
    ...    ELSE    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_GH006_DRX_HI_trunk}
    Attach and start-end vonr call and grab all log    filename_attach=${filename_HI005_attach_gnb0}
    ...    filename_vonr=filename_HI005_gnb   filename_vonrend=filename1_HI005_gnb
    Comment    check the wireshark log with GH006
    Check wireshark log for GH006   logname=${filename_006_attach_gnb0}   logname1=${filename_006_gnb0}
    ...    logname2=${filename_006_gnb1}    logname3=${filename1_006_gnb0}
    Comment    check the wireshark log with HI005
    Check wireshark log for GH006   logname=${filename_HI005_attach_gnb0}    logname1=${filename_HI005_gnb0}
    ...    logname2=${filename_HI005_gnb1}    logname3=${filename1_HI005_gnb0}
    ...    DRX_default=${DRX_default_HI005}    DRX_VONR=${DRX_VONR_HI005}
    ...    drxLongCycle_default=${drxLongCycle_default_HI005}    drxLongCycle_vonr=${drxLongCycle_vonr_HI005}
    ...    cycle_attach=40    cycle_VONR=20
    MultiUE.Detach
    Hanging resource test    gnb_ips=@{gnb_ips}    gnb_list=${gnb_list}
    [Teardown]    run keywords
    ...    MultiUE.Detach    AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation for 2gnb    AND
    ...    Run Keyword And Ignore Error    Case Teardown    filename=${filename_GH006}    gnb_list=${gnb_list}

*** Keywords ***
Common Case TestLine Setup with NRREl for GH003
    @{scf_list}    Create List
    ${scf_gnb0}    Only Modify SCF before Perform Commission    gnb_index=${0}
    ...    golden_scf_name=${tl_scf_gnb0}${release_info}.xml    MOsToAdd=${MOS_ADD_GNB1_GH003}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_GH003}    ListToAdd=${LIST_TO_ADD_GNB1_GH003}
    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${1}
    ...    golden_scf_name=${tl_scf_gnb1}${release_info}.xml     MOsToAdd=${MOS_ADD_GNB2_GH003}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB2_GH003}    ListToAdd=${LIST_TO_ADD_GNB2_GH003}
    Append to List    ${scf_list}    ${scf_gnb0}    ${scf_gnb1}
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list}    scf_list=${scf_list}
    Check the MultiBTS cells status on air    gnb_list=${gnb_list}
    ##NG inter Frequency HO Preparation###
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_GH003_inter_HO}
    ...    Add_Mo_Online=${PARAMETERS_TO_ADD_GNB1_GH003_inter_HO}
    Modify Parameters for Cases   gnb_index=${1}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB2_GH003_inter_HO}


Common Case TestLine Setup with NRREl for GH006
    @{scf_list}    Create List
    ${scf_gnb0}    Only Modify SCF before Perform Commission    gnb_index=${0}
    ...    golden_scf_name=${tl_scf_gnb0}${release_info}.xml    MOsToAdd=${MOS_ADD_GNB1_GH006}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_GH006}    ListToAdd=${LIST_TO_ADD_GNB1_GH006}
    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${1}
    ...    golden_scf_name=${tl_scf_gnb1}${release_info}.xml    ParameterToDelete=${Parameter_Delete_GNB2_GH006}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB2_GH006}    ListToAdd=${LIST_TO_ADD_GNB2_GH006}
    Append to List    ${scf_list}    ${scf_gnb0}    ${scf_gnb1}
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list}    scf_list=${scf_list}
    Check the MultiBTS cells status on air    gnb_list=${gnb_list}
    #DRX Preparation###
    Run keyword if    '${gnb_instance0}' == '${gnb_id}[1]'    Modify Parameters for Cases
    ...    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_GH006_DRX}    ELSE
    ...    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_GNB1_GH006_DRX_trunk}

UE detech and collect log
    [Arguments]    ${ue_index}    ${filename}    ${gNB_index}=${0}
    Start capture gNB log on master    filename=${filename}   gNB_index=${gNB_index}
    power_ue.UE Detach
    ...   ue_type=${tl.ues[1].capabilities[-1]}    ue_index=${ue_index}    power_reset=True
    sleep    10s
    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}

UE attach and collect log
    [Arguments]     ${filename}    ${gNB_index}=${0}
    Start capture gNB log on master    filename=${filename}   gNB_index=${gNB_index}
    MultiUE.Attach
    sleep    5s
    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
    [Teardown]    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}

GNB1 NGHO to GNB2
    [Arguments]    ${logname}    ${logname1}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${0}
    UE attach and collect log     filename=${logname}
    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_T_T}    duration=1200    process_num=${5}
    ####trigger inter NGHO
    Start capture multi gNB log    filename=${logname1}    gnb_list=${gnb_list}
    Sleep    2s
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${0}    gnb2_cell2_value=${0}
    Sleep    2s
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${30}    gnb2_cell2_value=${0}
    Sleep    3s
    Stop capture multi gNB log    filename=${logname1}    gnb_list=${gnb_list}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${0}    gnb2_cell2_value=${0}
    sleep    3s
    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell=${expected_tput_dl_F}
    ...    scellid=1    pcellid=2    gnb_prime=${1}    gnb_external=${0}    ue_type=${tl.ues[0].capabilities[0]}

Check wireshark log for GH003
    [Arguments]    ${logname}    ${logname1}
    Check intergNB NGHO process on source gNB    logname=${logname}
    Check intergNB NGHO process on target gNB    logname=${logname1}
    ###check target CA setup succuss
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname1}
    ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell1}
    ...    Primegnb_index=${1}    extgnb_index_list=${extgnb_index_gnb1}
    ...    UEContextModificationResponse_nums=${UEContextModificationResponse_nums_${gnb_instance0}}
    ###check source CA release
    Check pscell and scell release wireshark log    logname=${logname}    logname1=${logname1}

Check wireshark log for CB0130552
    [Arguments]    ${logname}    ${logname1}
    Check intergNB NGHO process on source gNB    logname=${logname}
    Check intergNB NGHO process on target gNB    logname=${logname1}
    ###check target CA setup succuss
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname1}
    ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell1}
    ...    Primegnb_index=${1}    extgnb_index_list=${extgnb_index_gnb1}
    ...    UEContextModificationResponse_nums=${UEContextModificationResponse_nums_${gnb_instance0}}

Check wireshark log for GH003_02
    [Arguments]    ${logname}    ${logname1}
    Check intergNB NGHO process on source gNB    logname=${logname1}
    Check intergNB NGHO process on target gNB    logname=${logname}
    ###check target CA setup succuss
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
    ...    pcell_index=${1}    scell_index_list=${scell_index_list_cell31}
    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb2}
    ...    UEContextModificationResponse_nums=${UEContextModificationResponse_nums_${gnb_instance0}}
    ###check source CA release
    Check pscell and scell release wireshark log    logname=${logname1}    logname1=${logname}

Check wireshark log for GH006
    [Arguments]    ${logname}    ${logname1}    ${logname2}    ${logname3}    ${cycle_attach}=160    ${cycle_VONR}=40
    ...    ${DRX_default}=${DRX_default}    ${DRX_VONR}=${DRX_VONR}
    ...    ${drxLongCycle_default}=${drxLongCycle_default}    ${drxLongCycle_vonr}=${drxLongCycle_vonr}
    ###check DRX when attach
    Check DRX enable on PrimegNB or Externgnb    logname=${logname}
    ...    milliSeconds=${DRX_default[0]}    InactivityTimer=${DRX_default[1]}    StartOffset=${DRX_default[2]}
    Check CSIRS and CSI-reporting in onduration in UEContextModificationResponse    logname=${logname}
    ...    xpath2=.//nr-rrc.${drxLongCycle_default}    cycle=${cycle_attach}
#    Check 2200 enable with Scell when attach    logname=${logname}    xpath=.//nr-rrc.${drxLongCycle_default}
    ###check DRX when make VONR in pcell
    Check UEContextModificationRequest message has Drx release on PrimegNB    logname=${logname1}
    Check IgNBCAModificationRequest message has Drx release on PrimegNB    logname=${logname1}
    Check VONR DRX enable on PrimegNB    logname=${logname1}        milliSeconds2=${DRX_default}[0]
    ...    milliSeconds1=${DRX_VONR[0]}    InactivityTimer=${DRX_VONR[1]}    StartOffset=${DRX_VONR[2]}
    Check CSIRS and CSI-reporting in onduration in UEContextModificationResponse    logname=${logname1}
    ...    xpath2=.//nr-rrc.${drxLongCycle_vonr}    cycle=${cycle_VONR}
    ###check DRX when make VONR in scell
    Check DRX enable on PrimegNB or Externgnb    logname=${logname2}    milliSeconds=${DRX_VONR[0]}
    ...    milliSeconds2=${DRX_default}[0]   InactivityTimer=${DRX_VONR[1]}    StartOffset=${DRX_VONR[2]}
    ###check DRX after VONR release in pcell
    Check UEContextModificationRequest message has Drx release on PrimegNB    logname=${logname3}
    Check IgNBCAModificationRequest message has Drx release on PrimegNB    logname=${logname3}
    Check DRX recover as attach on PrimegNB    logname=${logname3}
    ...    milliSeconds=${DRX_default[0]}    InactivityTimer=${DRX_default[1]}    StartOffset=${DRX_default[2]}

Attach and start-end vonr call and grab all log
    [Arguments]    ${filename_attach}    ${filename_vonr}
    ...    ${filename_vonrend}    ${ue_index}=${ue_index_${gnb_instance0}}
    MultiUE.Prepare UE
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell2_value=${0}
    UE attach and collect log    filename=${filename_attach}
    ###trigger VONR
    Start capture multi gNB log    filename=${filename_vonr}   gnb_list=${gnb_list}
    spark.send AT command CPE     param=ATD006688;     ue_alias=UE_${ue_index}
    Sleep    30s
    Stop capture multi gNB log    filename=${filename_vonr}   gnb_list=${gnb_list}
    Start capture multi gNB log    filename=${filename_vonrend}   gnb_list=${gnb_list}
    Sleep    3s
    wait until keyword succeeds    10 min    20s    spark.send AT command CPE     param=ATH     ue_alias=UE_${ue_index}
    Sleep    10s
    Stop capture multi gNB log    filename=${filename_vonrend}   gnb_list=${gnb_list}

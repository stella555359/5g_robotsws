*** Settings ***
Suite Setup      Suite Setup 7403
Suite Teardown    Suite Teardown 7403

Documentation    author：Shanshan Zhang
...              contact: shanshan.zhang@nokia-sbell.com
...              squad group: mmw_SG_04

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          ./Resources/CB007403_common_keyword.robot
Resource          ../CB007306_OTA/Resources/CB007306_common_keyword.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library           ../CB007306_OTA/Resources/CB007306_common.py
Library           ./Resources/CB007403_common.py
Library           ../CB007306_OTA/Resources/hbtePositioner/positionerDemo.py
Library           ute_syslog
Library           taf.hw.rf_attenuator    WITH NAME    att
Variables         ./Resources/CB007403_modify_para.py


*** Variables ***
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB2_ip}                ${tl.gnbs[1].dus[0].f1_m_ip_addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${enb_ip}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb2_ip}                ${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
${eventA3}                     eventA3
${TEST_PC_IP}                  ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}            ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}            ${tl.test_pc.default_ssh_connection_details.password}
${ul_port}                     ${tl.ues[0].iperf_details.ssh_connection_details.port}
${dl_port}                     ${tl.ues[0].iperf_details.port}
${luashark_path}                /opt/ute/luashark/luashark_script/generated_luashark
${filter}                           x2ap
${filter_enb}                       x2ap || s1ap
${PositionMotion_ip1}           10.71.216.4
${PositionMotion_ip2}           10.71.216.6


*** Test Cases ***
[1]CB007403-C_5GC000573_001_Successful_intra_freq_inter_SgNB_PSCell_change_with_DL_and_UL_with_enable_CDRX
    [Tags]       CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
    Adjust the HBTE attenuation value for 7403    value_1=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}   end_Y=${0}      exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}    end_Y=${270}    exceed=${360}
    ${Lock_RMOD_List_1}    Create List    RMOD-2    RMOD-3
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_1}    gnb_index=0
    Modify ENB and GNB parameter for 573
    Start tcpdump log attach UE for 7403     logname=573
    Start tcpdump and send DL or UL traffic for 573 001    NUM=${0}   if_ul=${False}
    Start tcpdump and send DL or UL traffic for 573 001    NUM=${1}   if_dl=${False}
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    Wait for counter to be gathered after guard peroid
    Check DL and UL counter for 573 001
    Check sum counter for 573
    Check counter number on gNB1 and gNB2 for 573
    Check wiresgark log for 573 001
#    Compare HO TP with initial TP for 573     avg_DL_GNB1=${avg_DL_GNB1_cell_50}    avg_UL_GNB1=${avg_UL_GNB1_cell_50}
#    ...    avg_DL_GNB2=${avg_DL_GNB2_cell_70}    avg_UL_GNB2=${avg_UL_GNB2_cell_70}
#    ...    sourceCellList=${GNB1_cell_List}    targetCellList=${GNB2_cell_List}
    Compare HO TP with initial TP for 573    sourceCellList=${GNB1_cell_List}    targetCellList=${GNB2_cell_List}
    [Teardown]       Case Teardown for 573

[1]CB007539-5G-B_5GC000573_001_Successful_intra_freq_inter_SgNB_PSCell_change_with_DL_and_UL
    [Tags]       CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
    Adjust the HBTE attenuation value for 7403    value_1=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}   end_Y=${0}      exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}    end_Y=${270}    exceed=${360}
    ${Lock_RMOD_List_1}    Create List    RMOD-2    RMOD-3
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_1}    gnb_index=0
    Modify ENB and GNB parameter for 573
    Start tcpdump log attach UE for 7403     logname=573
    Start tcpdump and send DL or UL traffic for 573 001    NUM=${0}   if_ul=${False}
    Start tcpdump and send DL or UL traffic for 573 001    NUM=${1}   if_dl=${False}
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    Wait for counter to be gathered after guard peroid
    Check DL and UL counter for 573 001
    Check sum counter for 573
    Check counter number on gNB1 and gNB2 for 573
    Check wiresgark log for 573 001
#    Compare HO TP with initial TP for 573     avg_DL_GNB1=${avg_DL_GNB1_cell_50}    avg_UL_GNB1=${avg_UL_GNB1_cell_50}
#    ...    avg_DL_GNB2=${avg_DL_GNB2_cell_70}    avg_UL_GNB2=${avg_UL_GNB2_cell_70}
#    ...    sourceCellList=${GNB1_cell_List}    targetCellList=${GNB2_cell_List}
    Compare HO TP with initial TP for 573    sourceCellList=${GNB1_cell_List}    targetCellList=${GNB2_cell_List}
    [Teardown]       Case Teardown for 573

[1]CB007403-C_5GC000573_005_Unuccessful_intra_Freq_inter_SgNB_PSCell_change_refused_by_target_SgNB
    [Tags]         CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
    Adjust the HBTE attenuation value for 7403
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}   end_Y=${0}      exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}    end_Y=${270}    exceed=${360}
    Modify ENB and GNB parameter for 573_005
    Start tcpdump log attach UE for 7403     logname=573_005
    Start tcpdump and send DL or UL traffic for 573_005
    Check wiresgark log and btslog for 573_005
    [Teardown]       Case Teardown for 573_005

[1]CB007539-5G-B_5GC000573_004_Unuccessful_intra_Freq_inter_SgNB_PSCell_change_refused_by_target_SgNB
    [Tags]         CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
    Adjust the HBTE attenuation value for 7403
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}   end_Y=${0}      exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}    end_Y=${270}    exceed=${360}
    Modify ENB and GNB parameter for 573_005
    Start tcpdump log attach UE for 7403     logname=573_005
    Start tcpdump and send DL or UL traffic for 573_005
    Check wiresgark log and btslog for 573_005
    [Teardown]       Case Teardown for 573_005

[1]CB007403-C_5GC000574_A_004_without_change_SCG_DL_and_UL
    [Tags]        CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
    Adjust the HBTE attenuation value for 7403 574
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}   end_Y=${0}       exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}   end_Y=${270}     exceed=${360}
    ${Lock_RMOD_List_1}    Create List    RMOD-2    RMOD-3
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_1}    gnb_index=0
    ${Lock_RMOD_List_2}    Create List    RMOD-1
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_2}    gnb_index=1
    Modify ENB and GNB parameter for 574
    Start tcpdump log attach UE for 7403       logname=574
    FOR    ${NUM}    IN RANGE    ${2}
        Start tcpdump and send DL or UL traffic for 574    NUM=${NUM}
        sleep    10s
    END
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${True}    if_dl=${True}
    Wait for counter to be gathered after guard peroid
    check counter for 574
    Check wiresgark log and btslog for 574
    [Teardown]       Case Teardown and Reconver_Parameter for 574

[1]CB007539-5G-B_5GC000574_A_002_without_change_SCG_DL_and_UL
    [Tags]        CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
    Adjust the HBTE attenuation value for 7403 574
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}   end_Y=${0}       exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}   end_Y=${270}     exceed=${360}
    ${Lock_RMOD_List_1}    Create List    RMOD-2    RMOD-3
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_1}    gnb_index=0
    ${Lock_RMOD_List_2}    Create List    RMOD-1
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_2}    gnb_index=1
    Modify ENB and GNB parameter for 574
    Start tcpdump log attach UE for 7403       logname=574
    FOR    ${NUM}    IN RANGE    ${2}
        Start tcpdump and send DL or UL traffic for 574    NUM=${NUM}
        sleep    10s
    END
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${True}    if_dl=${True}
    Wait for counter to be gathered after guard peroid
    check counter for 574
    Check wiresgark log and btslog for 574
    [Teardown]       Case Teardown and Reconver_Parameter for 574

[1]CB007403-C_5GC000575_007_SgNB_Modification_support_for_Intra-MeNB_Inter-Cell_handover_without_change_in_SCG_configuration_DL_and_UL
    [Tags]        CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
    Adjust the HBTE attenuation value for 7403 575
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}     end_Y=${0}       exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}   end_Y=${270}     exceed=${360}
    ${Lock_RMOD_List_1}    Create List    RMOD-2    RMOD-3
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_1}    gnb_index=0
    ${Lock_RMOD_List_2}    Create List    RMOD-1
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_2}    gnb_index=1
    ${M55112C04001}    Check NX2CC PM counter result    counter_id=M55112C04001
    ${M55112C04002}    Check NX2CC PM counter result    counter_id=M55112C04002
    ${M55112C00003}    Check NX2CC PM counter result    counter_id=M55112C00003
    ${M55112C00004}    Check NX2CC PM counter result    counter_id=M55112C00004
    ${M55112C04001_sum}    Get sum counter value    ${M55112C04001}
    ${M55112C04002_sum}    Get sum counter value    ${M55112C04002}
    ${M55112C00003_sum}    Get sum counter value    ${M55112C00003}
    ${M55112C00004_sum}    Get sum counter value    ${M55112C00004}
    Modify ENB and GNB parameter for 575
    Start tcpdump log attach UE for 7403       logname=575
    FOR    ${NUM}    IN RANGE    ${2}
        Start tcpdump and send DL or UL traffic for 575    NUM=${NUM}
        sleep    10s
    END
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${True}    if_dl=${True}
    Wait for counter to be gathered after guard peroid
    check counter for 575     M55112C04001=${M55112C04001_sum}    M55112C04002=${M55112C04002_sum}
    ...    M55112C00003=${M55112C00003_sum}    M55112C00004=${M55112C00004_sum}
    Check wiresgark log and btslog for 575
    [Teardown]       Case Teardown and Reconver_Parameter for 575

[1]CB007539-5G-B_5GC000575_001_Intra-MeNB_Inter-Cell_handover_without_change_in_SCG_configuration_DL_and_UL
    [Tags]        CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
    Adjust the HBTE attenuation value for 7403 575
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}     end_Y=${0}       exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}   end_Y=${270}     exceed=${360}
    ${Lock_RMOD_List_1}    Create List    RMOD-2    RMOD-3
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_1}    gnb_index=0
    ${Lock_RMOD_List_2}    Create List    RMOD-1
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_2}    gnb_index=1
    ${M55112C04001}    Check NX2CC PM counter result    counter_id=M55112C04001
    ${M55112C04002}    Check NX2CC PM counter result    counter_id=M55112C04002
    ${M55112C00003}    Check NX2CC PM counter result    counter_id=M55112C00003
    ${M55112C00004}    Check NX2CC PM counter result    counter_id=M55112C00004
    ${M55112C04001_sum}    Get sum counter value    ${M55112C04001}
    ${M55112C04002_sum}    Get sum counter value    ${M55112C04002}
    ${M55112C00003_sum}    Get sum counter value    ${M55112C00003}
    ${M55112C00004_sum}    Get sum counter value    ${M55112C00004}
    Modify ENB and GNB parameter for 575
    Start tcpdump log attach UE for 7403       logname=575
    FOR    ${NUM}    IN RANGE    ${2}
        Start tcpdump and send DL or UL traffic for 575    NUM=${NUM}
        sleep    10s
    END
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${True}    if_dl=${True}
    Wait for counter to be gathered after guard peroid
    check counter for 575     M55112C04001=${M55112C04001_sum}    M55112C04002=${M55112C04002_sum}
    ...    M55112C00003=${M55112C00003_sum}    M55112C00004=${M55112C00004_sum}
    Check wiresgark log and btslog for 575
    [Teardown]       Case Teardown and Reconver_Parameter for 575

[1]CB007403-5G-C-5GC001094+5GC001829_spillover_from_5GC001094_PSCell_change_A3_and_A5_with_SRB3
    [Tags]      CRT_22R2    CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
#    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${90}     end_X=${90}     start_Y=${0}   end_Y=${0}    exceed=${360}
#    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${90}     end_X=${90}     start_Y=${360}    end_Y=${360}    exceed=${360}
#    ${avg_DL_GNB_cell_80}    ${avg_UL_GNB_cell_80}    Get initial UL and DL TP       cell=${gnb1_pci2}
#    ...    control_cell_Parameter=${ENB_defaultLnRelGnbCellId_GNB1_cell_80}     ul_throughput=500M     dl_throughput=4000M
#    ...    attached_pci=${attached_pci_80}    sourceCellList=${GNB1_cell_List_group3}
#    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}     end_X=${0}       start_Y=${0}   end_Y=${0}    exceed=${360}
#    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}     end_X=${0}    start_Y=${270}    end_Y=${270}    exceed=${360}
#    ${avg_DL_GNB_cell_50}    ${avg_UL_GNB_cell_50}    Get initial UL and DL TP       cell=${gnb1_pci}
#    ...    control_cell_Parameter=${ENB_defaultLnRelGnbCellId_GNB1_cell_50}    ul_throughput=500M     dl_throughput=4000M
#    ...    attached_pci=${attached_pci_50}    sourceCellList=${GNB1_cell_List}
#    Set Test Variable    ${avg_DL_GNB_cell_50}
#    Set Test Variable    ${avg_UL_GNB_cell_50}
#    Set Test Variable    ${avg_DL_GNB_cell_80}
#    Set Test Variable    ${avg_UL_GNB_cell_80}
    ${Lock_RMOD_List_1}    Create List    RMOD-2
    ${Lock_RMOD_List_2}    Create List    RMOD-1
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_1}    gnb_index=0
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_2}    gnb_index=1
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB_Reconver_Parameter}     gNB_ip=${enb_ip}
    Adjust the HBTE attenuation value for 7403
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}   end_Y=${0}       exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}   end_Y=${270}     exceed=${360}
    Modify ENB and GNB parameter for 1094
    Start tcpdump log attach UE for 7403       logname=1094
    FOR    ${NUM}    IN RANGE    ${1}
        CB007403_common_keyword.Start tcpdump and send DL or UL traffic for 1094    NUM=${NUM}
        sleep    10s
    END
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${True}    if_dl=${True}
    Wait for counter to be gathered after guard peroid
    check counter for 1094
    CB007403_common_keyword.Check wiresgark log and btslog for 1094
    [Teardown]       Case Teardown and Reconver_Parameter     Reconver_Parameter=${GNB1_Reconver_Parameter_1094}

[1]CB007539-5G-B-5GC001094_001_Successful_intra_freq_intra_SgNB_PSCell_change_A3_and_A5_withoutSRB3
    [Tags]      CRT_22R2    CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
#    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${90}     end_X=${90}     start_Y=${0}   end_Y=${0}    exceed=${360}
#    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${90}     end_X=${90}     start_Y=${360}    end_Y=${360}    exceed=${360}
#    ${avg_DL_GNB_cell_80}    ${avg_UL_GNB_cell_80}    Get initial UL and DL TP       cell=${gnb1_pci2}
#    ...    control_cell_Parameter=${ENB_defaultLnRelGnbCellId_GNB1_cell_80}     ul_throughput=500M     dl_throughput=4000M
#    ...    attached_pci=${attached_pci_80}    sourceCellList=${GNB1_cell_List_group3}
#    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}     end_X=${0}       start_Y=${0}   end_Y=${0}    exceed=${360}
#    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}     end_X=${0}    start_Y=${270}    end_Y=${270}    exceed=${360}
#    ${avg_DL_GNB_cell_50}    ${avg_UL_GNB_cell_50}    Get initial UL and DL TP       cell=${gnb1_pci}
#    ...    control_cell_Parameter=${ENB_defaultLnRelGnbCellId_GNB1_cell_50}    ul_throughput=500M     dl_throughput=4000M
#    ...    attached_pci=${attached_pci_50}    sourceCellList=${GNB1_cell_List}
#    Set Test Variable    ${avg_DL_GNB_cell_50}
#    Set Test Variable    ${avg_UL_GNB_cell_50}
#    Set Test Variable    ${avg_DL_GNB_cell_80}
#    Set Test Variable    ${avg_UL_GNB_cell_80}
    ${Lock_RMOD_List_1}    Create List    RMOD-2
    ${Lock_RMOD_List_2}    Create List    RMOD-1
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_1}    gnb_index=0
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_2}    gnb_index=1
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB_Reconver_Parameter}     gNB_ip=${enb_ip}
    Adjust the HBTE attenuation value for 7403
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}   end_Y=${0}       exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}   end_Y=${270}     exceed=${360}
    Modify ENB and GNB parameter for 1094
    Start tcpdump log attach UE for 7403       logname=1094
    FOR    ${NUM}    IN RANGE    ${1}
        CB007403_common_keyword.Start tcpdump and send DL or UL traffic for 1094    NUM=${NUM}
        sleep    10s
    END
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${True}    if_dl=${True}
    Wait for counter to be gathered after guard peroid
    check counter for 1094
    CB007403_common_keyword.Check wiresgark log and btslog for 1094
    [Teardown]       Case Teardown and Reconver_Parameter     Reconver_Parameter=${GNB1_Reconver_Parameter_1094}

[1]CB007403-C_5GC000710_A_008_Successful_removal_of_inter-frequency_A3A5_and_configuration_A2_after_receipt_A1_RSRPCombine_Measurement_report
    [Tags]      CRT_22R2    CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
    ${GNB1_cell}    create list    ${GNB1_cell_List}[0]
    ${avg_DL_cell_50}     ${avg_UL_cell_50}     Get UL and DL TP due to cell ID     btslog_name=btslog_50.log    CellList=${GNB1_cell}
    Adjust the HBTE attenuation value for 7403
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}   end_Y=${0}       exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}   end_Y=${270}     exceed=${360}
    ${M55157C00002_1}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
    ${M55157C00002_sum1}    Get sum counter value     list_input=${M55157C00002_1}
    Modify ENB and GNB parameter for 710
    Start tcpdump and send DL or UL traffic for 710
    Wait for counter to be gathered after guard peroid
    ${M55157C00002_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
    ${M55157C00002_sum2}    Get sum counter value     list_input=${M55157C00002_2}
    ${dif}      Evaluate     ${M55157C00002_sum2}-${M55157C00002_sum1}
    run keyword and continue on failure     should be true       ${dif}==${1}
    CB007403_common_keyword.Check wiresgark log and btslog for 710
    Compare HO TP with initial TP with one gnb    btslog_name=btslog_710.log     is_lte_ho=${True}
    ...    avg_DL_GNB=${avg_DL_cell_50}     avg_UL_GNB=${avg_UL_cell_50}    CellList=${GNB1_cell}
    [Teardown]       Case Teardown and Reconver_Parameter     Reconver_Parameter=${GNB1_Reconver_Parameter_710}

[1]CB007539-5G-B_5GC000710_A_002_Successful_removal_of_inter-frequency_A3A5_and_configuration_A2_after_receipt_A1_Measurement_report
    [Tags]      CRT_22R2    CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
    ${GNB1_cell}    create list    ${GNB1_cell_List}[0]
    ${avg_DL_cell_50}     ${avg_UL_cell_50}     Get UL and DL TP due to cell ID     btslog_name=btslog_50.log    CellList=${GNB1_cell}
    Adjust the HBTE attenuation value for 7403
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}   end_Y=${0}       exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}   end_Y=${270}     exceed=${360}
    ${M55157C00002_1}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
    ${M55157C00002_sum1}    Get sum counter value     list_input=${M55157C00002_1}
    Modify ENB and GNB parameter for 710
    Start tcpdump and send DL or UL traffic for 710
    Wait for counter to be gathered after guard peroid
    ${M55157C00002_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP
    ${M55157C00002_sum2}    Get sum counter value     list_input=${M55157C00002_2}
    ${dif}      Evaluate     ${M55157C00002_sum2}-${M55157C00002_sum1}
    run keyword and continue on failure     should be true       ${dif}==${1}
    CB007403_common_keyword.Check wiresgark log and btslog for 710
    Compare HO TP with initial TP with one gnb    btslog_name=btslog_710.log     is_lte_ho=${True}
    ...    avg_DL_GNB=${avg_DL_cell_50}     avg_UL_GNB=${avg_UL_cell_50}    CellList=${GNB1_cell}
    [Teardown]       Case Teardown and Reconver_Parameter     Reconver_Parameter=${GNB1_Reconver_Parameter_710}

[1]CB007403-C_5GC000710_A_001_Successful_Intra-gNB_PSCell_change_with_inter-frequency_A3_without_SRB3
    [Tags]        CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
    ${distName_list}     Get distname due to cell list
    ${distName_list}    Create list    ${distName_list}[4]    ${distName_list}[5]     ${distName_list}[6]     ${distName_list}[7]
    ${cell_distname}    Create list    ${GNB1_NRCELL_5}    ${GNB1_NRCELL_6}   ${GNB1_NRCELL_7}    ${GNB1_NRCELL_8}
    FOR   ${Num}    IN RANGE   ${4}
        Block Cell    dist_name=${distName_list}[${Num}]    cell_dist_name=${cell_distname}[${Num}]
    END
    ${Lock_RMOD_List_1}    Create List    RMOD-3
    ${Lock_RMOD_List_2}    Create List    RMOD-1
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_1}    gnb_index=0
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_2}    gnb_index=1
#    ${avg_DL_GNB_cell_50}     ${avg_UL_GNB_cell_50}     Get UL and DL TP due to cell ID     btslog_name=btslog_50.log    CellList=${GNB1_cell_50}
#    Set Test Variable    ${avg_DL_GNB_cell_50}
#    Set Test Variable    ${avg_UL_GNB_cell_50}
    Adjust the HBTE attenuation value for 7403    value_1=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}   end_Y=${0}       exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}   end_Y=${270}     exceed=${360}
    ${M55157C00002_cell1}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-1
    ${M55157C00002_sum1}    Get sum counter value     list_input=${M55157C00002_cell1}
    ${M55157C00002_cell11}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-11
    ${M55157C00002_sum11}    Get sum counter value     list_input=${M55157C00002_cell11}
    Modify ENB and GNB parameter for 710
    Start tcpdump log attach UE for 7403       logname=710_001
    FOR    ${NUM}    IN RANGE    ${1}
        CB007403_common_keyword.Start tcpdump and send DL or UL traffic cell 50 to cell 60    NUM=${NUM}    case_name=710_001    ul_throughput=50M
    END
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${True}    if_dl=${True}
    Wait for counter to be gathered after guard peroid
    ${M55157C00002_cell1_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-1
    ${M55157C00002_sum1_2}    Get sum counter value     list_input=${M55157C00002_cell1_2}
    ${M55157C00002_cell11_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-11
    ${M55157C00002_sum11_2}    Get sum counter value     list_input=${M55157C00002_cell11_2}
    ${dif1}      Evaluate     ${M55157C00002_sum1_2}-${M55157C00002_sum1}
    ${dif11}      Evaluate     ${M55157C00002_sum11_2}-${M55157C00002_sum11}
    run keyword and continue on failure     should be true       ${dif1}==${2}
    run keyword and continue on failure     should be true       ${dif11}==${1}
    CB007403_common_keyword.Check wiresgark log and btslog for 710_001
    [Teardown]       Case Teardown and Reconver_Parameter for 710_001     distName_list=${distName_list}     cell_distname=${cell_distname}

[1]CB007539-5G-B_5GC000710_A_001_Successful_Intra-gNB_PSCell_change_with_inter-frequency_A3
    [Tags]        CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
    ${distName_list}     Get distname due to cell list
    ${distName_list}    Create list    ${distName_list}[4]    ${distName_list}[5]     ${distName_list}[6]     ${distName_list}[7]
    ${cell_distname}    Create list    ${GNB1_NRCELL_5}    ${GNB1_NRCELL_6}   ${GNB1_NRCELL_7}    ${GNB1_NRCELL_8}
    FOR   ${Num}    IN RANGE   ${4}
        Block Cell    dist_name=${distName_list}[${Num}]    cell_dist_name=${cell_distname}[${Num}]
    END
    ${Lock_RMOD_List_1}    Create List    RMOD-3
    ${Lock_RMOD_List_2}    Create List    RMOD-1
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_1}    gnb_index=0
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_2}    gnb_index=1
#    ${avg_DL_GNB_cell_50}     ${avg_UL_GNB_cell_50}     Get UL and DL TP due to cell ID     btslog_name=btslog_50.log    CellList=${GNB1_cell_50}
#    Set Test Variable    ${avg_DL_GNB_cell_50}
#    Set Test Variable    ${avg_UL_GNB_cell_50}
    Adjust the HBTE attenuation value for 7403    value_1=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}   end_Y=${0}       exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}   end_Y=${270}     exceed=${360}
    ${M55157C00002_cell1}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-1
    ${M55157C00002_sum1}    Get sum counter value     list_input=${M55157C00002_cell1}
    ${M55157C00002_cell11}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-11
    ${M55157C00002_sum11}    Get sum counter value     list_input=${M55157C00002_cell11}
    Modify ENB and GNB parameter for 710
    Start tcpdump log attach UE for 7403       logname=710_001
    FOR    ${NUM}    IN RANGE    ${1}
        CB007403_common_keyword.Start tcpdump and send DL or UL traffic cell 50 to cell 60    NUM=${NUM}    case_name=710_001    ul_throughput=50M
    END
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${True}    if_dl=${True}
    Wait for counter to be gathered after guard peroid
    ${M55157C00002_cell1_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-1
    ${M55157C00002_sum1_2}    Get sum counter value     list_input=${M55157C00002_cell1_2}
    ${M55157C00002_cell11_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-11
    ${M55157C00002_sum11_2}    Get sum counter value     list_input=${M55157C00002_cell11_2}
    ${dif1}      Evaluate     ${M55157C00002_sum1_2}-${M55157C00002_sum1}
    ${dif11}      Evaluate     ${M55157C00002_sum11_2}-${M55157C00002_sum11}
    run keyword and continue on failure     should be true       ${dif1}==${2}
    run keyword and continue on failure     should be true       ${dif11}==${1}
    CB007403_common_keyword.Check wiresgark log and btslog for 710_001
    [Teardown]       Case Teardown and Reconver_Parameter for 710_001     distName_list=${distName_list}     cell_distname=${cell_distname}

[1]CB007403-C_5GC000710_A_014_Successful_inter_gNB_PSCell_change_with_inter-frequency_A5_RSRP_without_SRB3
    [Tags]        CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
    ${distName_list}     Get distname due to cell list
    ${distName_list}    Create list    ${distName_list}[4]    ${distName_list}[5]     ${distName_list}[6]     ${distName_list}[7]
    ${cell_distname}    Create list    ${GNB1_NRCELL_5}    ${GNB1_NRCELL_6}   ${GNB1_NRCELL_7}    ${GNB1_NRCELL_8}
    FOR   ${Num}    IN RANGE   ${4}
        Block Cell    dist_name=${distName_list}[${Num}]    cell_dist_name=${cell_distname}[${Num}]
    END
    ${Lock_RMOD_List_1}    Create List    RMOD-1    RMOD-3
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_1}    gnb_index=0
    Adjust the HBTE attenuation value for 7403    value_1=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${90}   end_Y=${90}       exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${360}   end_Y=${360}     exceed=${360}
    ${M55157C00002_cell1}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-1    index=${1}
    ${M55157C00002_sum1}    Get sum counter value     list_input=${M55157C00002_cell1}
    ${M55157C00002_cell11}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-11
    ${M55157C00002_sum11}    Get sum counter value     list_input=${M55157C00002_cell11}
    Modify ENB and GNB parameter for 710 014
    Start tcpdump log attach UE for 7403       logname=710_014    gnb_index=${1}
    FOR    ${NUM}    IN RANGE    ${1}
        Start tcpdump and send DL or UL traffic for 710_014     NUM=${NUM}
    END
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${True}    if_dl=${True}
    Wait for counter to be gathered after guard peroid
    ${M55157C00002_cell1_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-1    index=${1}
    ${M55157C00002_sum1_2}    Get sum counter value     list_input=${M55157C00002_cell1_2}
    ${M55157C00002_cell11_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-11
    ${M55157C00002_sum11_2}    Get sum counter value     list_input=${M55157C00002_cell11_2}
    ${dif1}      Evaluate     ${M55157C00002_sum1_2}-${M55157C00002_sum1}
    ${dif11}      Evaluate     ${M55157C00002_sum11_2}-${M55157C00002_sum11}
    run keyword and continue on failure     should be true       ${dif1}==${1}
    run keyword and continue on failure     should be true       ${dif11}==${1}
    CB007403_common_keyword.Check wiresgark log and btslog for 710_014
    [Teardown]       Case Teardown and Reconver_Parameter for 710_014     distName_list=${distName_list}     cell_distname=${cell_distname}

[1]CB007539-5G-B_5GC000710_A_003_Successful_inter_gNB_PSCell_change_with_inter-frequency_A5
    [Tags]        CRT_TRUNK    CRT_22R4
    [Setup]     Case Setup
    ${distName_list}     Get distname due to cell list
    ${distName_list}    Create list    ${distName_list}[4]    ${distName_list}[5]     ${distName_list}[6]     ${distName_list}[7]
    ${cell_distname}    Create list    ${GNB1_NRCELL_5}    ${GNB1_NRCELL_6}   ${GNB1_NRCELL_7}    ${GNB1_NRCELL_8}
    FOR   ${Num}    IN RANGE   ${4}
        Block Cell    dist_name=${distName_list}[${Num}]    cell_dist_name=${cell_distname}[${Num}]
    END
    ${Lock_RMOD_List_1}    Create List    RMOD-1    RMOD-3
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_1}    gnb_index=0
    Adjust the HBTE attenuation value for 7403    value_1=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${90}   end_Y=${90}       exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${360}   end_Y=${360}     exceed=${360}
    ${M55157C00002_cell1}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-1    index=${1}
    ${M55157C00002_sum1}    Get sum counter value     list_input=${M55157C00002_cell1}
    ${M55157C00002_cell11}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-11
    ${M55157C00002_sum11}    Get sum counter value     list_input=${M55157C00002_cell11}
    Modify ENB and GNB parameter for 710 014
    Start tcpdump log attach UE for 7403       logname=710_014    gnb_index=${1}
    FOR    ${NUM}    IN RANGE    ${1}
        Start tcpdump and send DL or UL traffic for 710_014     NUM=${NUM}
    END
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${True}    if_dl=${True}
    Wait for counter to be gathered after guard peroid
    ${M55157C00002_cell1_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-1    index=${1}
    ${M55157C00002_sum1_2}    Get sum counter value     list_input=${M55157C00002_cell1_2}
    ${M55157C00002_cell11_2}    Check PM counter result    counter_id=M55157C00002    counter_object=NRMOP    NRCELL=NRCELL-11
    ${M55157C00002_sum11_2}    Get sum counter value     list_input=${M55157C00002_cell11_2}
    ${dif1}      Evaluate     ${M55157C00002_sum1_2}-${M55157C00002_sum1}
    ${dif11}      Evaluate     ${M55157C00002_sum11_2}-${M55157C00002_sum11}
    run keyword and continue on failure     should be true       ${dif1}==${1}
    run keyword and continue on failure     should be true       ${dif11}==${1}
    CB007403_common_keyword.Check wiresgark log and btslog for 710_014
    [Teardown]       Case Teardown and Reconver_Parameter for 710_014     distName_list=${distName_list}     cell_distname=${cell_distname}

[1]CB007403-5G-C-5GC001416_BB_1_Successful_A3_intra-SgNB_Intra-freq_PSCell_change_UE_uses_alt_bands_SRB3
    [Tags]        CRT_TRUNK    CRT_22R3
    [Setup]     Case Setup
#    ${avg_DL_GNB_cell_50}     ${avg_UL_GNB_cell_50}     Get UL and DL TP due to cell ID     btslog_name=btslog_50.log    CellList=${GNB1_cell_50}
#    Set Test Variable    ${avg_DL_GNB_cell_50}
#    Set Test Variable    ${avg_UL_GNB_cell_50}
    Adjust the HBTE attenuation value for 7403    value_1=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}   end_Y=${0}       exceed=${360}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}   end_Y=${270}     exceed=${360}
    Modify ENB and GNB parameter for 1416
    ${Lock_RMOD_List_1}    Create List    RMOD-3
    ${Lock_RMOD_List_2}    Create List    RMOD-1
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_1}    gnb_index=0
    RMODs_Lock_and_Unlock     Lock_RMOD_List=${Lock_RMOD_List_2}    gnb_index=1
    Start tcpdump log attach UE for 7403       logname=1416
    FOR    ${NUM}    IN RANGE    ${1}
        CB007403_common_keyword.Start tcpdump and send DL or UL traffic cell 50 to cell 60    NUM=${NUM}    case_name=1416
        sleep    10s
    END
    CB007306_common_keyword.stop multi power ue traffic ul and dl     ue_num=${1}    if_ul=${True}    if_dl=${True}
    run keyword and continue on failure    CB007306_common_keyword.check cell band    cell_id=${GNB1_NRCELL_1}
    run keyword and continue on failure    CB007306_common_keyword.check cell band    cell_id=${GNB1_NRCELL_11}
#    run keyword and continue on failure    check counter for 1416
    CB007403_common_keyword.Check wiresgark log and btslog for 1416
    [Teardown]       Case Teardown and Reconver_Parameter for 1416

#[1]CB007608-A-5GC002083-004_Check_all_phases
#    [Tags]      CRT_22R2
#    [Setup]      Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
#    Adjust the HBTE attenuation value for 7403
#    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}    start_Y=${0}     end_Y=${0}       exceed=${360}
#    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}    end_X=${0}    start_Y=${270}   end_Y=${270}     exceed=${360}
#    Modify SCF file create new and Commission for 2083
#    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}   alias=ute
#    log to console    start syslog...
#    ute_syslog.Start Syslog    log_dir=${OUTPUT_DIR}/${TEST NAME}      log_name=btslog_2083.log
#    ...      host_ip=${TEST_PC_IP}    ssh_username=${TEST_PC_USERNAME}    ssh_password=${TEST_PC_PASSWORD}    alias=ute
#    Wait Until Keyword Succeeds    10 min    10 s    check fault
#    Wait Until Keyword Succeeds    10 min    30 s     check counter phase1 increase
#    Wait Until Keyword Succeeds    15 min    10 s    check fault
#    Wait Until Keyword Succeeds    10 min    10 s    Verify BBMOD Reset
#    Wait Until Keyword Succeeds    10 min    30 s    check counter phase2 increase
#    Wait Until Keyword Succeeds    15 min    10 s    Verify BBMOD normal
#    Wait Until Keyword Succeeds    10 min    10 s    check fault
#    Wait Until Keyword Succeeds    15 min    10 s    gNB.CheckBTSReset
#    Wait Until Keyword Succeeds    10 min    10 s    Connect gnb and Check cell on air
#    Wait Until Keyword Succeeds    15 min    3 min   check counter phase3 increase
#    Stop syslog    alias=ute
#    check case4 counter from BTSLog
#    [Teardown]       Case Teardown and Reconver_Paramet    Reconver_Parameter=${GNB2_Reconver_Parameter_2083}    bts_ip=${gNB2_ip}

*** Keywords ***
Case Setup
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    robot_common_operations.Common case Setup
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_SYSLOG_Disable}     gNB_ip=${gNB2_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_SYSLOG_Enable}     gNB_ip=${gNB2_ip}

Suite Setup 7403
    CB007403_common_keyword.Only Setup Commission SCF     gnbnumber=${1}    BTS_Host=${gNB_ip}
    CB007403_common_keyword.Only Setup Commission SCF     gnbnumber=${2}    BTS_Host=${gNB2_ip}
    CB007403_common_keyword.Only Setup Commission SCF     gnbnumber=${1}    BTS_Host=${enb_ip}     if_gnb=${False}
    CB007403_common_keyword.Only Setup Commission SCF     gnbnumber=${2}    BTS_Host=${enb2_ip}    if_gnb=${False}
    Connect gnb and Check cell on air    BTS_Host=${gNB_ip}
    Connect gnb and Check cell on air    BTS_Host=${gNB2_ip}
    Connect gnb and Check cell on air    BTS_Host=${enb_ip}
    Connect gnb and Check cell on air    BTS_Host=${enb2_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_SETUP_Paramemeters}     gNB_ip=${gNB_ip}
    #run keyword and continue on failure    CB007306_common_keyword.Connect gnb and Check Unexpect Alarm      BTS_Host=${gNB_ip}
    #run keyword and continue on failure    CB007306_common_keyword.Connect gnb and Check Unexpect Alarm      BTS_Host=${gNB2_ip}
    Adjust the HBTE attenuation value for 7403
    CB007306_common_keyword.Iptables UDP destination port ACCEPT    port1=${51000}    port2=${51001}
    ${GNB1_cell_List}    Get nrcellid with the lcrid   bts_host=${gNB_ip}   cell_group_index=${0}
    ${GNB1_cell_List_group2}    Get nrcellid with the lcrid   bts_host=${gNB_ip}   cell_group_index=${1}
    ${GNB1_cell_List_group3}    Get nrcellid with the lcrid   bts_host=${gNB_ip}   cell_group_index=${2}
    ${GNB2_cell_List}    Get nrcellid with the lcrid   bts_host=${gNB2_ip}   cell_group_index=${0}
    Set Suite Variable    ${GNB1_cell_List}
    Set Suite Variable    ${GNB1_cell_List_group2}
    Set Suite Variable    ${GNB1_cell_List_group3}
    Set Suite Variable    ${GNB2_cell_List}
    ${GNB1_cell_50}    create list    ${GNB1_cell_List}[0]
    ${GNB1_cell_60}    create list    ${GNB1_cell_List_group2}[0]
    ${GNB2_cell_70}    create list    ${GNB2_cell_List}[0]
    Set Suite Variable     ${GNB1_cell_50}
    Set Suite Variable     ${GNB1_cell_60}
    Set Suite Variable     ${GNB2_cell_70}
#    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}     end_X=${0}       start_Y=${0}   end_Y=${0}    exceed=${360}
#    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}     end_X=${0}    start_Y=${270}    end_Y=${270}    exceed=${360}
#    ${avg_DL_GNB1_cell_50}    ${avg_UL_GNB1_cell_50}    Get initial UL and DL TP       cell=${gnb1_pci}
#    ...    control_cell_Parameter=${ENB_defaultLnRelGnbCellId_GNB1_cell_50}
#    ...    attached_pci=${attached_pci_50}    sourceCellList=${GNB1_cell_List}
#    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${90}     end_X=${90}       start_Y=${0}   end_Y=${0}    exceed=${360}
#    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}     end_X=${0}     start_Y=${360}    end_Y=${360}    exceed=${360}
#    ${avg_DL_GNB1_cell_60}    ${avg_UL_GNB1_cell_60}    Get initial UL and DL TP       cell=${gnb1_pci2}
#    ...    control_cell_Parameter=${ENB_defaultLnRelGnbCellId_GNB1_cell_60}
#    ...    attached_pci=${attached_pci_60}    sourceCellList=${GNB1_cell_List_group2}
#    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     start_X=${0}    end_X=${0}       start_Y=${90}    end_Y=${90}    exceed=${360}
#    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     start_X=${0}     end_X=${0}   start_Y=${360}    end_Y=${360}    exceed=${360}
#    ${avg_DL_GNB2_cell_70}    ${avg_UL_GNB2_cell_70}    Get initial UL and DL TP       cell=${gnb2_pci}    gnb_index=${1}
#    ...    control_cell_Parameter=${ENB_defaultLnRelGnbCellId_GNB2_cell_70}
#    ...    attached_pci=${attached_pci_70}    sourceCellList=${GNB2_cell_List}
#    ${avg_DL_GNB_cell_60}     ${avg_UL_GNB_cell_60}     Get UL and DL TP due to cell ID     btslog_name=btslog_60.log    CellList=${GNB1_cell_60}
#    ${avg_DL_GNB_cell_70}     ${avg_UL_GNB_cell_70}     Get UL and DL TP due to cell ID     btslog_name=btslog_70.log    CellList=${GNB2_cell_70}
#    Set Suite Variable    ${avg_DL_GNB1_cell_50}
#    Set Suite Variable    ${avg_UL_GNB1_cell_50}
#    Set Suite Variable    ${avg_DL_GNB1_cell_60}
#    Set Suite Variable    ${avg_UL_GNB1_cell_60}
#    Set Suite Variable    ${avg_DL_GNB2_cell_70}
#    Set Suite Variable    ${avg_UL_GNB2_cell_70}
#    Set Suite Variable    ${avg_DL_GNB_cell_60}
#    Set Suite Variable    ${avg_UL_GNB_cell_60}
#    Set Suite Variable    ${avg_DL_GNB_cell_70}
#    Set Suite Variable    ${avg_UL_GNB_cell_70}
    robot_common_operations.Common Suite Setup
    [Teardown]    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB_Reconver_Parameter}     gNB_ip=${enb_ip}

Suite Teardown 7403
    robot_common_operations.Common Suite Teardown
    CB007403_common_keyword.Only Setup Commission SCF    gnbnumber=${1}    BTS_Host=${gNB_ip}
    CB007403_common_keyword.Only Setup Commission SCF     gnbnumber=${2}    BTS_Host=${gNB2_ip}
    Connect to gnb coam via ssl    gnb_index=${0}
    Wait Until Keyword Succeeds    16min    2min    COAM Check GNB cell on air
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Modify SCF file create new and Commission for 2083
    [Arguments]    ${gnbnumber}=${2}     ${BTS_Host}=${gNB2_ip}
    ${default_scf}    CB007403_common_keyword.Get BTS Version And Perare SCF     gnbnumber=${gnbnumber}
    ...    gNB_ip=${BTS_Host}   CURDIR_path=${CURDIR_path}    gnbnumber=${gnbnumber}
    scf.load_scf       file_path=${default_scf}
    modify_scf_element     value=true      dist_name=${GNB2_FMCADM}        p_name=actForceUnitAutoReset
    modify_scf_element     value=true      dist_name=${GNB2_FMCADM}        p_name=actForceAutoReset
    modify_scf_element     value=${180}    dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellDetHCheckFreq
    modify_scf_element     value=${0}      dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRachAtmpThr
    modify_scf_element     value=${0}      dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRachMsg3Thr
    modify_scf_element     value=${200}    dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPh1Timer
    modify_scf_element     value=${200}    dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPh2Timer
    modify_scf_element     value=${200}    dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPh3Timer
    modify_scf_element     value=true      dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase2Act
    modify_scf_element     value=true      dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase3Act
    modify_scf_element     value=true      dist_name=${TRBLCADM_1_NAME}    p_name=autRachBasedSlCellRecPhase1Act
    modify_scf_element     value=${1}      dist_name=${TRBLCADM_1_NAME}    p_name=maxNumSlCellRecActForBbuPerDay
    modify_scf_element     value=${1}      dist_name=${TRBLCADM_1_NAME}    p_name=maxNumSlCellRecActForBtsPerDay
    modify_scf_element     value=true      dist_name=${FEATCADM_1_NAME}    p_name=actAutRachBasedSlCellDetRec
    scf.save_scf        file_path=${OUTPUT_DIR}/new_scf_2083.xml
    log to console      modify successful,${OUTPUT_DIR}/new_scf_2083.xml will be commissioned.
    Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
    COAM Commission with scf file    scf_file_path=${OUTPUT_DIR}/new_scf_2083.xml
    Wait Until Keyword Succeeds   16min   2min     COAM Check GNB cell on air
    [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections

Modify ENB and GNB parameter for 573
    CB007306_common_keyword.Connect gnb and Reset Site            BTS_Host=${gNB_ip}
    CB007306_common_keyword.Connect gnb and Reset Site            BTS_Host=${gNB2_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB1_MODIFY_Parameter_573}     gNB_ip=${enb_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_573}     gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_MODIFY_Parameter_573}     gNB_ip=${gNB2_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${enb_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${gNB_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${gNB2_ip}

Modify ENB and GNB parameter for 573_005
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB1_MODIFY_Parameter_573}     gNB_ip=${enb_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_573}     gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_MODIFY_Parameter_573}     gNB_ip=${gNB2_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_MODIFY_Parameter_573_005}     gNB_ip=${gNB2_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${enb_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${gNB_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${gNB2_ip}

Modify ENB and GNB parameter for 574
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB1_MODIFY_Parameter_574}     gNB_ip=${enb_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB2_MODIFY_Parameter_574}     gNB_ip=${enb2_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_574}     gNB_ip=${gNB_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${enb_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${gNB_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${enb2_ip}

Modify ENB and GNB parameter for 575
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB1_MODIFY_Parameter_574}     gNB_ip=${enb_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_575}     gNB_ip=${gNB_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${enb_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${gNB_ip}

Modify ENB and GNB parameter for 1094
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_1094}      gNB_ip=${gNB_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${gNB_ip}

Modify SCF file create new and Commission for 1416
    [Arguments]     ${value1}=true    ${value2}=257    ${gnbnumber}=${1}     ${BTS_Host}=${gNB_ip}
    ${default_scf}    CB007306_common_keyword.Get BTS Version And Perare SCF     gnbnumber=${gnbnumber}
    ...    gNB_ip=${BTS_Host}   CURDIR_path=${CURDIR_path}    gnbnumber=${gnbnumber}
    scf.load_scf       file_path=${default_scf}
    modify_scf_element     dist_name=${MR_NR_BTS_NAME}    p_name=actMultiFrequencyBandIndicatorNRSupport      value=${value1}
    modify_scf_element     dist_name=${MR_NR_BTS_NAME}    p_name=actIntraFreqIntraGnbMobilityNSA      value=${value1}
    modify_scf_element     dist_name=${MR_NR_BTS_NAME}    p_name=actInterFreqInterGnbMobilityNSA      value=false
    modify_scf_element     dist_name=${MR_NR_BTS_NAME}    p_name=actInterFreqIntraGnbMobilityNSA      value=false
    modify_scf_element     dist_name=${MR_NR_BTS_NAME}    p_name=actA1HoPrefNRLayer      value=none
    modify_scf_element     dist_name=${MR_NR_BTS_NAME}    p_name=actHigherPrioFreqHo      value=none
    modify_scf_element     dist_name=${GNB1_NRCELL_1}    p_name=freqBandIndicatorNR     value=${value2}
    modify_scf_element     dist_name=${GNB1_NRCELL_11}    p_name=freqBandIndicatorNR     value=${value2}
    modify_scf_element     dist_name=${GNB1_NRCELL_11}    p_name=gscnOrSsPbchArfcn     value=22446
    modify_scf_element     dist_name=${GNB1_NRCELL_12}    p_name=gscnOrSsPbchArfcn     value=22452
    modify_scf_element     dist_name=${GNB1_NRCELL_13}    p_name=gscnOrSsPbchArfcn     value=22458
    modify_scf_element     dist_name=${GNB1_NRCELL_14}    p_name=gscnOrSsPbchArfcn     value=22464
    modify_scf_element     dist_name=${GNB1_NRCELL_11}    p_name=nrarfcn     value=2071665
    modify_scf_element     dist_name=${GNB1_NRCELL_12}    p_name=nrarfcn     value=2073331
    modify_scf_element     dist_name=${GNB1_NRCELL_13}    p_name=nrarfcn     value=2074997
    modify_scf_element     dist_name=${GNB1_NRCELL_14}    p_name=nrarfcn     value=2076663
    modify_scf_element     dist_name=${GNB1_NRCELL_14}    p_name=type0CoresetConfigurationIndex     value=0
    scf.save_scf        file_path=${OUTPUT_DIR}/new_scf_1416.xml
    log to console      modify successful,${OUTPUT_DIR}/new_scf_1416.xml will be commissioned.
    Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
    COAM Commission with scf file    scf_file_path=${OUTPUT_DIR}/new_scf_1416.xml
    Wait Until Keyword Succeeds   16min   2min     COAM Check GNB cell on air
    [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections

Modify ENB and GNB parameter for 1416
    Modify SCF file create new and Commission for 1416
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${gNB_ip}

Modify ENB and GNB parameter for 710
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB1_MODIFY_Parameter_710}     gNB_ip=${enb_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_710}     gNB_ip=${gNB_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${enb_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${gNB_ip}

Modify ENB and GNB parameter for 710 014
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${ENB1_MODIFY_Parameter_710}     gNB_ip=${enb_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_MODIFY_Parameter_710_014}     gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_MODIFY_Parameter_710_014}     gNB_ip=${gNB2_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${enb_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${gNB_ip}
    CB007306_common_keyword.Connect gnb and Check cell on air     BTS_Host=${gNB2_ip}

Case Teardown and Reconver_Parameter
    [Arguments]     ${Reconver_Parameter}    ${bts_ip}=${gNB_ip}
    ${unLock_RMOD_List_1}    Create List    RMOD-1    RMOD-2    RMOD-3
    ${unLock_RMOD_List_2}    Create List    RMOD-1
    RMODs_Lock_and_Unlock     unLock_RMOD_List=${unLock_RMOD_List_1}    gnb_index=0
    RMODs_Lock_and_Unlock     unLock_RMOD_List=${unLock_RMOD_List_2}    gnb_index=1
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${Reconver_Parameter}     gNB_ip=${bts_ip}
    run keyword and ignore error     csn.Disconnect    connection=ute
    run keyword and ignore error     stop syslog     alias=ute
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown

Case Teardown for 573
    ${unLock_RMOD_List_1}    Create List    RMOD-2    RMOD-3
    RMODs_Lock_and_Unlock     unLock_RMOD_List=${unLock_RMOD_List_1}    gnb_index=0
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_Reconver_Parameter_573}     gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_Reconver_Parameter_573}     gNB_ip=${gNB2_ip}
    run keyword and ignore error     csn.Disconnect    connection=ute
    run keyword and ignore error     stop syslog     alias=ute
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown

Case Teardown for 573_005
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_Reconver_Parameter_573}     gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_Reconver_Parameter_573}     gNB_ip=${gNB2_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_Reconver_Parameter_573_005}     gNB_ip=${gNB2_ip}
    run keyword and ignore error     csn.Disconnect    connection=ute
    run keyword and ignore error     stop syslog     alias=ute
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown

Case Teardown and Reconver_Parameter for 1416
    ${unLock_RMOD_List_1}    Create List    RMOD-3
    ${unLock_RMOD_List_2}    Create List    RMOD-1
    RMODs_Lock_and_Unlock     unLock_RMOD_List=${unLock_RMOD_List_1}    gnb_index=0
    RMODs_Lock_and_Unlock     unLock_RMOD_List=${unLock_RMOD_List_2}    gnb_index=1
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    run keyword and ignore error     csn.Disconnect    connection=ute
    run keyword and ignore error     stop syslog     alias=ute
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown

Case Teardown and Reconver_Parameter for 710_014
    [Arguments]    ${distName_list}    ${cell_distname}
    FOR   ${Num}    IN RANGE   ${4}
        UnBlock Cell    dist_name=${distName_list}[${Num}]    cell_dist_name=${cell_distname}[${Num}]
    END
    ${unLock_RMOD_List_1}    Create List    RMOD-1    RMOD-3
    RMODs_Lock_and_Unlock     unLock_RMOD_List=${unLock_RMOD_List_1}    gnb_index=0
    power_ue.Prepare UE    ue_index=${0}    ue_type=samsung
    CB007306_common_keyword.detach multi power ue     ue_num=${1}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB1_Reconver_Parameter_710_014}     gNB_ip=${gNB_ip}
    CB007306_common_keyword.Modify Common parameter via Coam      input_list=${GNB2_Reconver_Parameter_710_014}     gNB_ip=${gNB2_ip}
    run keyword and ignore error     csn.Disconnect    connection=ute
    run keyword and ignore error     stop syslog     alias=ute
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown

Case Teardown and Reconver_Parameter for 710_001
    [Arguments]    ${distName_list}    ${cell_distname}
    FOR   ${Num}    IN RANGE   ${4}
        UnBlock Cell    dist_name=${distName_list}[${Num}]    cell_dist_name=${cell_distname}[${Num}]
    END
    ${unLock_RMOD_List_1}    Create List    RMOD-3
    ${unLock_RMOD_List_2}    Create List    RMOD-1
    RMODs_Lock_and_Unlock     unLock_RMOD_List=${unLock_RMOD_List_1}    gnb_index=0
    RMODs_Lock_and_Unlock     unLock_RMOD_List=${unLock_RMOD_List_2}    gnb_index=1
    Case Teardown and Reconver_Parameter     Reconver_Parameter=${GNB1_Reconver_Parameter_710}
    robot_common_operations.Common case Teardown

Case Teardown and Reconver_Parameter for 574
    Case Teardown and Reconver_Parameter    Reconver_Parameter=${GNB1_Reconver_Parameter_574}
    ${unLock_RMOD_List_1}    Create List    RMOD-2    RMOD-3
    RMODs_Lock_and_Unlock     unLock_RMOD_List=${unLock_RMOD_List_1}    gnb_index=0
    ${unLock_RMOD_List_2}    Create List    RMOD-1
    RMODs_Lock_and_Unlock     unLock_RMOD_List=${unLock_RMOD_List_2}    gnb_index=1
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown

Case Teardown and Reconver_Parameter for 575
    Case Teardown and Reconver_Parameter    Reconver_Parameter=${GNB1_Reconver_Parameter_575}
    ${unLock_RMOD_List_1}    Create List    RMOD-2    RMOD-3
    RMODs_Lock_and_Unlock     unLock_RMOD_List=${unLock_RMOD_List_1}    gnb_index=0
    ${unLock_RMOD_List_2}    Create List    RMOD-1
    RMODs_Lock_and_Unlock     unLock_RMOD_List=${unLock_RMOD_List_2}    gnb_index=1
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown

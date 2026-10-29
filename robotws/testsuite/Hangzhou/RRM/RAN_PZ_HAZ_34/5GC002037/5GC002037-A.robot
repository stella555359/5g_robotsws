# *** Settings ***
# Documentation     author: Li Yajie
# ...               contact: yajie.li@nokia-sbell.com
# ...               squad group: SG_01
# ...               feature : 5GC002037-A
# Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup    AND    Suite Setup For 2037-A
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND   Teardown Suite
# Force Tags
# ...    PY36
# Resource          Resources/5GC002037_Resources.robot
# 
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]5GC002037_A_06_Add 20 slices to single PLMN
#     [Documentation]     Main test Steps:
#     ...   1)configure gNB with 20 NSA slice
#     ...   2)3 of 20 slice is configured with vlan
#     ...   3)check 20 slice and 1 vlan info
# 
#     [Tags]    CRT_TRUNK    CIT_20B    CRT_21A    CIT_21B    CRT_22R1    CRT_22R3    CRT_22R4
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    Case Setup For 2037
#     TC.5GC002037_A_06_Add 20 slices to single PLMN
# #    Run Keyword And Continue On Failure    GNB Commission For 2037 Case    SCF=2037_A6_SCF.xml    ParameterToDelete=${PARAMS_TO_DELETE_2037_A6}
# #    ...    ParamterToModify=${PARAMS_TO_MODIFY_2037_A6}    MOsToAdd=${ADD_MOs_2037_A6}    ListToAdd=${ADD_TO_List_2037_A6}
# #    Run Keyword And Continue On Failure    WEBUI.Check NSA Slice And Vlan Info
# 
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    Case Teardown For 2037
# 
# 
# [1]5GC002037_A_08_Delete and modify slices successful
#     [Documentation]     contain [1]5GC002037_A_09_Active feature flag with configed slices is successful
#     ...    Main test Steps:
#     ...   1)configure gNB with NSA QCI 128 in PLMN1 and NSA QCI 129 in PLMN2
#     ...   2)modify flag actNsaSlice from flase to true
#     ...   3)modify NSA QCI 128 in PLMN1 to QCI 130
#     ...   4)delete NSA QCI 129 in PLMN2
#     ...   5)activing plan passed and cell is onAir
# 
#     [Tags]    CRT_TRUNK    CIT_20B    CRT_21A    CIT_21B     CRT_22R1    CRT_22R3    CRT_22R4
#     [Setup]    Run Keywords    Run Keywords    robot_common_operations.Common Case Setup    AND    Case Setup For 2037
#     TC.5GC002037_A_08_Delete and modify slices successful
# #    Run Keyword And Continue On Failure    GNB Commission For 2037 Case    SCF=2037_A8_SCF.xml    ParameterToDelete=${PARAMS_TO_DELETE_2037_A8}
# #    ...    ParamterToModify=${PARAMS_TO_MODIFY_2037_A8}    MOsToAdd=${ADD_MOs_2037_A8}    ListToAdd=${ADD_TO_List_2037_A8}
# #    Run Keyword And Continue On Failure    WEBUI.Modify 2037 Feature Flag    new_value=true
# #    Run Keyword And Continue On Failure    WEBUI.Delete And Modify Slices
# 
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND    Case Teardown For 2037
# 
# #
# #[1]5GC002037_A_12_Ongoing call is released when corresponding slice is deleted
# #    [Documentation]
# #    ...    Main test Steps:
# #    ...   1)configure gNB with NSA QCI 129 in PLMN1
# #    ...   2)prepare IPSL server
# #    ...   3)attach NSA UE which belong to added slice (QCI129) and start UL/DL traffic
# #    ...   4)check DL and UL traffic
# #    ...   5)Delete NSA QCI 129 in PLMN1 via webui
# #    ...   6)NSA call is released
# #
# #    [Tags]    CIT_20B    CRT_21A    CIT_21B
# #    [Setup]    Case Setup For 2037
# #     TC.5GC002037_A_12_Ongoing call is released when corresponding slice is deleted_ASIB
# ##    Run Keyword And Continue On Failure    GNB Commission For 2037 Case    SCF=2037_A12_SCF.xml    ParameterToDelete=${PARAMS_TO_DELETE_2037_A12}
# ##    ...    ParamterToModify=${PARAMS_TO_MODIFY_2037_A12}    MOsToAdd=${ADD_MOs_2037_A12}    ListToAdd=${ADD_TO_List_2037_A12}
# ##    Run Keyword And Continue On Failure    CheckX2StatusUntilReady
# ##    Run Keyword And Continue On Failure    IPSL server preparation without replace files    ipsl_config_dir=${IPSL_CONFIG_CPC}
# ##    Run Keyword And Continue On Failure    COAM_WebEM.Login
# ##    Run Keyword And Continue On Failure    Start to collect the X2 log on eNB    x2_log_name=2037_A12_ENB.pcap
# ##    Run Keyword And Continue On Failure    UE.UE attach with DL traffic    ue_type=${UE_TYPE}    ue_index=${1}
# ##    ...    apn_address=${NSA_APN}   ue_mode=NSA
# ##    Run Keyword And Continue On Failure    WEBUI.Delete NSA Slice    NSA_Slice=NRNWSLICE_NSA-1
# ##    sleep    30s
# ##    Run Keyword And Continue On Failure    Stop and download X2 Logs on eNB    x2_log_name=2037_A12_ENB.pcap
# ##    Run Keyword And Continue On Failure    Wireshark.Analyse ENDCPartialReset    filename=2037_A12_ENB.pcap
# ##    Run Keyword And Ignore Error    UE.Detach UE with Stop traffic    ue_type=${UE_TYPE}    ue_index=${1}
# ##    ...    apn_address=${NSA_APN}   ue_mode=NSA
# ##    Run Keyword And Ignore Error    COAM_WebEM.Logout
# #
# #    [Teardown]    Case Teardown For 2037 IPSL
# #
# #
# #[1]5GC002037_A_14_Ongoing call is released when the QCI of corresponding slice is changed
# #    [Documentation]
# #    ...    Main test Steps:
# #    ...   1)configure gNB with NSA QCI 129 in PLMN1
# #    ...   2)prepare IPSL server
# #    ...   3)attach NSA UE which belong to added slice (QCI129) and start UL/DL traffic
# #    ...   4)check DL and UL traffic
# #    ...   5)Modify NSA QCI 129 to value 130 in PLMN1 via webui
# #    ...   6)NSA call is released
# #    [Tags]    CRT_20B     CRT_21B
# #    [Setup]    Case Setup For 2037
# #    TC.5GC002037_A_14_Ongoing call is released when the QCI of corresponding slice is changed_ASIB
# ##    Run Keyword And Continue On Failure    GNB Commission For 2037 Case    SCF=2037_A14_SCF.xml    ParameterToDelete=${PARAMS_TO_DELETE_2037_A12}
# ##    ...    ParamterToModify=${PARAMS_TO_MODIFY_2037_A12}    MOsToAdd=${ADD_MOs_2037_A12}    ListToAdd=${ADD_TO_List_2037_A12}
# ##    Run Keyword And Continue On Failure    CheckX2StatusUntilReady
# ##    Run Keyword And Continue On Failure    IPSL server preparation without replace files    ipsl_config_dir=${IPSL_CONFIG_CPC}
# ##    Run Keyword And Continue On Failure    COAM_WebEM.Login
# ##    Run Keyword And Continue On Failure    Start to collect the X2 log on eNB    x2_log_name=2037_A14_ENB.pcap
# ##    Run Keyword And Continue On Failure    UE.UE attach with DL traffic    ue_type=${UE_TYPE}    ue_index=${1}
# ##    ...    apn_address=${NSA_APN}   ue_mode=NSA
# ##    Run Keyword And Continue On Failure    WEBUI.Modify NSA Slice   NSA_Slice=NRNWSLICE_NSA-1    new_value=${130}    except_value=130
# ##    sleep    30s
# ##    Run Keyword And Continue On Failure    Stop and download X2 Logs on eNB    x2_log_name=2037_A14_ENB.pcap
# ##    Run Keyword And Continue On Failure    Wireshark.Analyse ENDCPartialReset    filename=2037_A14_ENB.pcap
# ##    Run Keyword And Ignore Error    UE.Detach UE with Stop traffic    ue_type=${UE_TYPE}    ue_index=${1}
# ##    ...    apn_address=${NSA_APN}   ue_mode=NSA
# ##    Run Keyword And Ignore Error    COAM_WebEM.Logout
# #
# #    [Teardown]    Case Teardown For 2037 IPSL
# #
# #
# #[1]5GC002037_A_27_Counter update checking for VLAN
# #    [Documentation]   contain [1]5GC002037_A_18_One slice of one UE without IPsec for one operator is successfu
# #    ...    Main test Steps:
# #    ...   1)configure gNB with NSA QCI 129 in PLMN1 and U-plane IP is IP1 on vlan
# #    ...   2)prepare IPSL server
# #    ...   3)capture X2ap pcap
# #    ...   4)attach NSA UE which belong to slice(QCI129) and start UL/DL traffic
# #    ...   5)check DL and UL traffic
# #    ...   6)check S1 Uplane IP in SgNBAdditionRequestAcknowledge message
# #    ...   7)check traffic counters: M51302C2 and M51302C4 increased a lot on VLAN IF
# #
# #    [Tags]    CRT_20B      CRT_21B
# #    [Setup]    Case Setup For 2037
# #    TC.5GC002037_A_27_Counter update checking for VLAN_ASIB
# ##    Run Keyword And Continue On Failure    GNB Commission For 2037 Case    SCF=2037_A27_SCF.xml    ParameterToDelete=${PARAMS_TO_DELETE_2037_A27}
# ##    ...    ParamterToModify=${PARAMS_TO_MODIFY_2037_A27}    MOsToAdd=${ADD_MOs_2037_A27}    ListToAdd=${ADD_TO_List_2037_A27}
# ##    Run Keyword And Continue On Failure    CheckX2StatusUntilReady
# ##    Run Keyword And Continue On Failure    IPSL server preparation without replace files    ipsl_config_dir=${IPSL_CONFIG_CPC}
# ##    Run Keyword And Continue On Failure    Start to collect the X2 log on eNB    x2_log_name=2037_A27_ENB.pcap
# ##    Run Keyword And Continue On Failure    UE.UE attach with ULDL traffic    ue_type=${UE_TYPE}    ue_index=${1}
# ##    ...    apn_address=${NSA_APN}   ue_mode=NSA
# ##    Run Keyword And Continue On Failure    Stop and download X2 Logs on eNB    x2_log_name=2037_A27_ENB.pcap
# ##    Run Keyword And Continue On Failure    Wireshark.Analyse ENB pcap for A27    filename=2037_A27_ENB.pcap    localIpAddr=IPIF-2/IPADDRESSV4-2
# ##    wait until keyword succeeds    7x    2min    Process.Check Counters of 2037 A27    VLANIF=VLANIF-${vlanId}
# ##    Run Keyword And Ignore Error    UE.Detach UE with Stop traffic    ue_type=${UE_TYPE}    ue_index=${1}
# ##    ...    apn_address=${NSA_APN}   ue_mode=NSA
# #
# #    [Teardown]    Case Teardown For 2037 IPSL
# 
# 
# *** Keywords ***

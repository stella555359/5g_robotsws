*** Settings ***
Documentation
...   author: Dong tony
...   contact: tony.1.dong@nokia-sbell.com
...   this is a robot case about CB008126_PCF.

Resource          ../Resources/common_resource.robot
#Resource          ../../HAZ5/Resources/pet_all.robot
Force Tags        CRT    RAN_5G    CLOUD_5G_CLASSICAL_ANDROID_SA_CA_ASIBL_ABIOB1_AHEH    STATE_SKIP_AGENT
...               SBTS00   CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG07_ST_RRM    TA_LEVEL_22
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM

*** Variables ***
${step_cmd}    proc node pcf 1 policy-update-notify all
#${dl_server1}   10.56.221.13
#${DEBUG_MODE}            ${TRUE}
${dn1}     MRBTS-306/NRBTS-306/NRCELL-1/PLMN-PLMN/NRPMQAP-1
${dn2}     MRBTS-306/NRBTS-306/NRCELL-1/PLMN-PLMN/NRPMQAP-2
${dn3}     MRBTS-306/NRBTS-306/NRCELL-1/PLMN-PLMN/NRPMQAP-3
${dn4}     MRBTS-306/NRBTS-306/NRCELL-1
${parameter}           maxNumOfNonGBRBearersSA
${dist_name}           MRBTS-306/NRBTS-306/NRCELL-1


*** Test Cases ***

Case2_Successful 5QI Modification initiated by 5GC for an existing non-GBR QoS Flow_single non-GBR for 5QI modification with different DRB profile
  ##[Tags]    CRT    QC_722661
    [Documentation]
    ...    author: tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTE5GTL306    SCF_10_5_UTE5GTL306_CB008126_case2_14_17_18    CB008126_1
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    ${pcf_simulator}=  Pet Pcf Simulator Setup  host=10.56.218.70   username=ute   password=Nokia123!   appname=sim-5g-new
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/service_on.pcf
    ADB.Prepare UE
    ADB.UE Attach
    sleep    30s
    Log To Console    senddata
    ${dl_server1}    Connect To IperfServer From Appservers
    Start DL traffic By Iperf    time=3600    traffic=100.00M    dl_server=${dl_server1}
    ...    DL_port=${5001}

	Sleep    6 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Check    starttime=${start_time}    endtime=${end_time}    dn=${dn3}

    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

	Sleep    6 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Check    starttime=${start_time}    endtime=${end_time}    dn=${dn1}

    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9_to_5QI8.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    Sleep    6 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Check    starttime=${start_time}    endtime=${end_time}    dn=${dn2}


Case4_Successful 5QI Modification initiated by 5GC for an existing non-GBR QoS Flow_VoNR established before QoS modification
  ##[Tags]    CRT    QC_722661
    [Documentation]
    ...    author: tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTE5GTL306    SCF_10_5_UTE5GTL306_CB008126_case4    CB008126_2
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    ${pcf_simulator}=  Pet Pcf Simulator Setup  host=10.56.218.70   username=ute   password=Nokia123!   appname=sim-5g-new
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/service_on.pcf

    ADB.Prepare UE
    ADB.UE Attach
    sleep    30s
    ADB.Make A Call    number=+6688

    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    sleep    30s
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9_to_5QI8.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    Sleep    6 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Check1    starttime=${start_time}    endtime=${end_time}    dn=${dn3}
    Counter Check1    starttime=${start_time}    endtime=${end_time}    dn=${dn1}
    Counter Check1    starttime=${start_time}    endtime=${end_time}    dn=${dn2}

Case9_Successful 5QI Modification initiated by 5GC for an existing non-GBR QoS Flow_single non-GBR for 5QI modification with same DRB profile
  ##[Tags]    CRT    QC_722661
    [Documentation]
    ...    author: tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTE5GTL306    SCF_10_5_UTE5GTL306_CB008126_case9    CB008126_3
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    ${pcf_simulator}=  Pet Pcf Simulator Setup  host=10.56.218.70   username=ute   password=Nokia123!   appname=sim-5g-new
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/service_on.pcf
    ADB.Prepare UE
    ADB.UE Attach
    sleep    30s

    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    sleep    30s
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9_to_5QI8.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    Sleep    6 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Check1    starttime=${start_time}    endtime=${end_time}    dn=${dn3}
    Counter Check1    starttime=${start_time}    endtime=${end_time}    dn=${dn1}
    Counter Check1    starttime=${start_time}    endtime=${end_time}    dn=${dn2}

Case10_Feature flag-NRBTS.act5qiAndUlNguTnlQosFlowModification off reject QoS modification request
    [Documentation]
    ...    author: tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTE5GTL306    SCF_10_5_UTE5GTL306_CB008126_case10_21    CB008126_4
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    ${pcf_simulator}=  Pet Pcf Simulator Setup  host=10.56.218.70   username=ute   password=Nokia123!   appname=sim-5g-new
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/service_on.pcf
    ADB.Prepare UE
    ADB.UE Attach
    sleep    30s
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    sleep    30s
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9_to_5QI8.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    Sleep    6 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Check1    starttime=${start_time}    endtime=${end_time}    dn=${dn3}
    Counter Check1    starttime=${start_time}    endtime=${end_time}    dn=${dn1}
    Counter Check2    starttime=${start_time}    endtime=${end_time}    dn=${dn2}

Case14_ Fail to perform 5QI Modification initiated by 5GC for an existing non-GBR QoS Flow_Change 5QI value from NonVoNR GBR to NonVoNR GBR
    [Documentation]
    ...    author: tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTE5GTL306    SCF_10_5_UTE5GTL306_CB008126_case14    CB008126_5
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    ${pcf_simulator}=  Pet Pcf Simulator Setup  host=10.56.218.70   username=ute   password=Nokia123!   appname=sim-5g-new
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/service_on.pcf
    ADB.Prepare UE
    ADB.UE Attach
    sleep    30s
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI2.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    sleep    30s
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI2_to_5QI3.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    Sleep    6 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Check1    starttime=${start_time}    endtime=${end_time}    dn=${dn3}
    Counter Check1    starttime=${start_time}    endtime=${end_time}    dn=${dn1}
    Counter Check2    starttime=${start_time}    endtime=${end_time}    dn=${dn2}

Case17_Fail to perform 5QI Modification initiated by 5GC for an existing non-GBR QoS Flow_Admission control failure in CU-CP
    [Documentation]
    ...    author: tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTE5GTL306    SCF_10_5_UTE5GTL306_CB008126_case4    CB008126_6
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    ${pcf_simulator}=  Pet Pcf Simulator Setup  host=10.56.218.70   username=ute   password=Nokia123!   appname=sim-5g-new
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/service_on.pcf
    ADB.Prepare UE
    ADB.UE Attach
    sleep    30s

    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    Change CB008126_maxNumOfNonGBRBearersSA

    sleep    30s
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9_to_5QI8.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    Sleep    6 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Counter Check1    starttime=${start_time}    endtime=${end_time}    dn=${dn3}
    Counter Check1    starttime=${start_time}    endtime=${end_time}    dn=${dn1}
    Counter Check2    starttime=${start_time}    endtime=${end_time}    dn=${dn2}

Case18_Counter for 5QI modification success used by USCB008126-SR-A-B1
    [Documentation]
    ...    author: tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTE5GTL306    SCF_10_5_UTE5GTL306_CB008126_case2_14_17_18    CB008126_7
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    ${pcf_simulator}=  Pet Pcf Simulator Setup  host=10.56.218.70   username=ute   password=Nokia123!   appname=sim-5g-new
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/service_on.pcf
    ADB.Prepare UE
    ADB.UE Attach
    sleep    30s

    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9_to_5QI8.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    Sleep    6 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Check Counter M55125C and M55163C for case18    starttime=${start_time}    endtime=${end_time}    dn=${dn4}
    Check Counter M55125C and M55163C for case18    starttime=${start_time}    endtime=${end_time}    dn=${dn2}

Case21_Counter for 5QI modification failure used by USCB008126-SR-A-B7
    [Documentation]
    ...    author: tony.1.dong@nokia-sbell.com
    [Tags]    10_5_UTE5GTL306    SCF_10_5_UTE5GTL306_CB008126_case10_21    CB008126_8
    Delete before PM counter file
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    5 minutes
    ${pcf_simulator}=  Pet Pcf Simulator Setup  host=10.56.218.70   username=ute   password=Nokia123!   appname=sim-5g-new
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/service_on.pcf
    ADB.Prepare UE
    ADB.UE Attach
    sleep    30s

    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9_to_5QI8.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    Sleep    6 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Check Counter M55125C and M55163C for case21    starttime=${start_time}    endtime=${end_time}    dn=${dn4}
    Check Counter M55125C and M55163C for case21    starttime=${start_time}    endtime=${end_time}    dn=${dn2}

*** Keywords ***
Case Setup
    Log To Console    Case Setup

Case Teardown
    Log To Console    Case Teardown
    # Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Disconnect All VM

Counter Check
    [Arguments]    ${starttime}    ${endtime}    ${dn}    ${equation}=!=
    Log To Console    ${equation}
    PM_counters_collector
#   ${pi_list}    Create List    M55125C00044    M55163C00022
    ${pi_list}    Create List    M55363C00001
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log To Console    ${value1}
#   ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00044
#   ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55163C00022
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55363C00001    ${dn}
   # Should be true    ${sum_1_val}>=${1}
   # Should be true    ${sum_2_val}>=${1}
	Should be true    ${sum_1_val}>${0}

Counter Check1
    [Arguments]    ${starttime}    ${endtime}    ${dn}    ${equation}=!=
    Log To Console    ${equation}
    PM_counters_collector
    ${pi_list}    Create List    M55161C00009
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log To Console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55161C00009    ${dn}
	Should be true    ${sum_1_val}>${0}

Run Script File On PCF Simulator
    [Arguments]  ${pcf_simulator}    ${cmdfile}
    Call Method    ${pcf_simulator}    exec_cli_command_file    ${cmdfile}

Run Command On PCF Simulator
   [Arguments]  ${pcf_simulator}    ${cmd}
   Call Method    ${pcf_simulator}    exec_cli_command    ${cmd}

Pet PCF Simulator Teardown
    [Arguments]  ${pcf_simulator}
    Call Method    ${pcf_simulator}    teardown

Counter Check2
    [Arguments]    ${starttime}    ${endtime}    ${dn}    ${equation}=!=
    Log To Console    ${equation}
    PM_counters_collector
    ${pi_list}    Create List    M55161C00009
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log To Console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55161C00009    ${dn}
	Should be true    ${sum_1_val}==${0}

Change CB008126_maxNumOfNonGBRBearersSA
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${value}    Set Variable    2
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...    value=${value}    operation=update    connection=commission
    [Teardown]    COAM_Admin.Logout    connection=commission


Check Counter M55125C and M55163C for case18
    [Arguments]    ${starttime}    ${endtime}    ${dn}    ${equation}=!=
    Log To Console    ${equation}
    PM_counters_collector
    ${pi_list}    Create List    M55125C00044    M55125C00045    M55125C00047    M55163C00023    M55163C00024    M55163C00025
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00044    ${dn}
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00045    ${dn}
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00047    ${dn}
    ${sum_4_val}    Sum Counter Value Of Pi Value List    ${value1}    M55163C00023    ${dn}
    ${sum_5_val}    Sum Counter Value Of Pi Value List    ${value1}    M55163C00024    ${dn}
    ${sum_6_val}    Sum Counter Value Of Pi Value List    ${value1}    M55163C00025    ${dn}
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${0}
    Should be true    ${sum_3_val}==${1}
    Should be true    ${sum_4_val}==${1}
    Should be true    ${sum_5_val}==${1}
    Should be true    ${sum_6_val}==${0}

Check Counter M55125C and M55163C for case21
    [Arguments]    ${starttime}    ${endtime}    ${dn}    ${equation}=!=
    Log To Console    ${equation}
    PM_counters_collector
    ${pi_list}    Create List    M55125C00044    M55125C00045    M55125C00047    M55163C00023    M55163C00024    M55163C00025
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log to console    ${value1}
    ${sum_1_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00044    ${dn}
    ${sum_2_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00045    ${dn}
    ${sum_3_val}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00047    ${dn}
    ${sum_4_val}    Sum Counter Value Of Pi Value List    ${value1}    M55163C00023    ${dn}
    ${sum_5_val}    Sum Counter Value Of Pi Value List    ${value1}    M55163C00024    ${dn}
    ${sum_6_val}    Sum Counter Value Of Pi Value List    ${value1}    M55163C00025    ${dn}
    Should be true    ${sum_1_val}==${1}
    Should be true    ${sum_2_val}==${1}
    Should be true    ${sum_3_val}==${0}
    Should be true    ${sum_4_val}==${1}
    Should be true    ${sum_5_val}==${0}
    Should be true    ${sum_6_val}==${1}
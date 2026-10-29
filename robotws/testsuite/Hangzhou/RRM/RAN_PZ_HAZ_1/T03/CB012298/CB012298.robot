*** Settings ***
Documentation
...    Author: Chen Jiahao
...    Contact: Jiahao.chen@nokia-sbell.com
...    this file is for CB012298.
...    Please do not modify the file without notification to author


Resource           ../Resources/vran_resource.robot
Suite Setup       Common Suite Setup For AIC
Test Setup        Run keywords    Common Test Setup For AIC    AND    Case Setup
Test Teardown     Common Test Teardown For AIC
Suite Teardown    Common Suite Teardown For AIC
Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

*** Variables ***
${PA_MaxValue}           ${63}
${PA_NormalValue}        ${1}
${PA_MinValue}           ${0}

# ${DEBUG_MODE}         ${True}

*** Test Cases ***
Upgrade
    AIC Upgrade vCU And vDu by Kuafu For All
# CB009175-CR_01_Configure new MAA NRCELL with using similfied method

#     Load Golden SCF for vDU
#     Load Golden SCF for vCU
#     Sleep    1 minute
#     wait until keyword succeeds    10 min    30 sec    Check All Cells On Air In Multiple vCU
#     wait until keyword succeeds    20 min    30 sec    vDU Check All Cells Status Should Be Onair

#     Delete MO and modify parameter
#     wait until keyword succeeds    10 min    30 sec    Check All Cells On Air In Multiple vCU
#     wait until keyword succeeds    10 min    30 sec    vDU Check All Cells Status Should Be Onair
#     ADB.Prepare UE
#     # Start Wireshark Log In vCU   gnb_index=${0}
#     # ...                          container_name=nwmgmt
#     # ...                          pod_name=cpif
#     # ...                          timeout=${10}
#     # ...                          protocol=sctp
#     # ...                          interface=any
#     Modify Attenuation For One RRU Of One Site
#     ADB.UE Attach
#     Sleep    200s    reason=Wait For Attach

#     Check CB009175 VoNR call counter

#     # ${wireshark_local_file_path_1}    Stop Wireshark Log And Download To K8s Master In vCU   gnb_index=${0}
#     # ...    container_name=nwmgmt
#     # ...    pod_name=cpif
#     # ...    timeout=${10}
#     # ...    log_name=test_tcpdump
#     # Check PDU session establishment accept In Wireshark Log    ${wireshark_local_file_path_1}

#     # Load Golden SCF for vDU
#     # Load Golden SCF for vCU

CB012298-CR-C_01_Indication for cross configuration parameters in online vDU WebEM - Parameter Editor tabs
    wait until keyword succeeds    10 min    30 sec    Check All Cells On Air In Multiple vCU
    wait until keyword succeeds    10 min    30 sec    vDU Check All Cells Status Should Be Onair
    ${check_parameters}    Create Dictionary    lteNrDssMode=LTE-NR dynamic spectrum sharing mode
    ...    drxControl=Special DRX profile usability selector
    ...    actPRBBlanking=Activate PRB blanking
    ${checked_keys}    Get Dictionary Keys    ${check_parameters}
    FOR     ${abbreviation}    IN    @{checked_keys}
        ${ret}    Get Parameter Detail By Selenium    object_name=MRBTS-11074/NRBTS-11074/NRCELL-1
        ...    filter_param=${check_parameters}[${abbreviation}]    abbreviation=${abbreviation}
        ...    product_type=vdu
        should be equal     ${ret}[Inter-NE constraints:]    Yes
    END

CB012298-CR-C_02_Indication for cross configuration parameters in online vCU WebEM - Parameter Editor tabs
    wait until keyword succeeds    10 min    30 sec    Check All Cells On Air In Multiple vCU
    wait until keyword succeeds    10 min    30 sec    vDU Check All Cells Status Should Be Onair
    ${check_parameters}    Create Dictionary    lteNrDssMode=LTE-NR dynamic spectrum sharing mode
    ...    drxControl=Special DRX profile usability selector
    ...    actPRBBlanking=Activate PRB blanking
    ${checked_keys}    Get Dictionary Keys    ${check_parameters}
    FOR     ${abbreviation}    IN    @{checked_keys}
        ${ret}    Get Parameter Detail By Selenium    object_name=MRBTS-11074/NRBTS-11074/NRCELL-1
        ...    filter_param=${check_parameters}[${abbreviation}]    abbreviation=${abbreviation}
        ...    product_type=vcu
        should be equal     ${ret}[Inter-NE constraints:]    Yes
    END

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Online Set vDU Parameters For CB009175
    Parameter Operation    operation=delta_plan_update   product_type=vdu
    ...    delta_file_path=${CURDIR}/vdu_delta_plan_11074.xml

Check PDU session establishment accept In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Analysis Wireshark Log    ${capture_file_path}
    ...    filter_expression=ngap
    Should Contain    ${output}    PDUSessionResourceSetupResponse

Load Golden SCF for vDU
    Parameter Operation    operation=full_commission   product_type=vdu
    ...    scf_path=${CURDIR}/vdu_Golden_SCF_11074.xml

Load Golden SCF for vCU
    Parameter Operation    operation=full_commission   product_type=vcu
    ...    scf_path=${CURDIR}/vcu_Golden_SCF_11074.xml

Delete MO and modify parameter
    Log To Console    Delete MO and modify parameter
    ${out}            Parameter Operation    operation=delta_plan_update   product_type=vdu
    ...    delta_file_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T03/CB009175/delete_MO.json
    Log To Console    VDU delta plan update result: ${out}

Check CB009175 VoNR call counter
    Log To Console    Check CB009175 VoNR call counter
    # NG_FLOW_SETUP_SUCC_TOT_5QI1:    M55125C09518

    ${rule1}    Catenate
    ...         Distname: MRBTS-37152/NRBTS-11074/NRCELL-1;
    ...         Counter: M55125C09518;
    ...         Counter rule: max(M55125C09518)==1
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${rule_list}

    Log To Console    VoNR call sleep 8min
    AT Operation    operation=start_call    number=6688
    sleep    8 minutes
    ADB.UE Detach
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    cudu_index=0
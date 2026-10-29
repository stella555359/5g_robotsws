*** Settings ***
Documentation    :copyright: Nokia
...     INTRODUCTION: CB012311
...     CB012311 is an extension for LTE1944 (Dynamic handover blacklisting) - see the feature recap. The new configurable S1-HO and
...    X2-HO rejection cause values are added, for which blacklisting/exclusion of inter-eNB neighbor (target) cell is started in
...    handover source eNB. The exclusion in CB012311 is started for unavailable neighbor cell(s), when S1-HO or X2-HO requested by the
...    source eNB cell, is rejected by neighbor cell with Cause IE matching any value selected in the corresponding S1-HO or 'X2-HO
...     exclusion causes' lists (new parameters).
...     This feature checks Successful exclusion of inter-eNB guest cell with lost PLMN connectivity upon failed S1-HO between same
...     deployed MORAN eNBs with cause Unknown target id
...     The scenario is repeated thrice with 100s , 500s sleep and lastly with s1_ho_preparation_failure turned off. The HO resumes
...     successfully after the s1_ho_preparation_failure is turned off.

Force Tags    CLOUD_R4MANO_CUS    CRT   SBTS00

Library     OperatingSystem
Library     ta_uexgate
Library     BuiltIn
Library     String
Library     SSHLibrary
Library     Collections
Library     ta_messaging
Library     ta5g_commissioning
Library		taf.sw.syslog

#Library    taf.sw.wtssim
Library		taf.sbts.oam.coam.admin
Resource    ${CURDIR}/resources/CNI-133565_keywords.robot
#Resource     ../../../resources/robot/configuration_id.robot

Library      taf.ul.ue.sim.env_setup

#Resource         ../../../resources/robot/PM_Counters.robot
Library       ta5g_tshark

Library          ta5g_pm_counters
Resource         ../CB012719/CB012719_Resource.robot
Suite Setup         Setup testline




*** Variables ***
${scfc}=                    ${CURDIR}/config/Configuration_scf_MRBTS-1_TL001_20250122-1141_1.xml
${cus_ini}=                 ${CURDIR}/config/cus_Simulated_sameMORAN.ini
${lua}=                     ${CURDIR}/config/epc_Simulated_sameMORAN.lua
${moc}=                     MRBTS-1/LNBTS-1/LNCEL-1/PLMN-PLMN/MCC-244/MNC-08

*** Test Cases ***
[1]CB012311-B_B1_17_Success_exclusion_inter-eNB_guest_cell_lost_PLMN_connect_upon_failed_X2-HO_bw_same_deplo_MORAN_eNBs_cause_ho_target_not_allowed
    FOR    ${index}    IN RANGE    3
        Log to Console    This is iteration ${index}
        Run UEx command  ue_attach   id=1    cell=1
        Sleep    5s
        Run UEx Command   trf_data_start   ue=1   dir=dl   protocol=udp   Mbps=20   stats=true
        Sleep    5s
        Run UEx Command   trf_data_stats    ue=1    dir=dl  unit=Mbps
        Sleep    5s




        Start wireshark
        Sleep   5s
        execute egate command    cmd=enb_param id=2 x2_force_reject_ho_req_with_cause=RN_ho_target_not_allowed
#        execute egate command    cmd=enb_param id=2 x2_force_reject_ho_req_with_cause=RN_invalid_MME_GroupID
        Sleep    5s


        Run Keyword And Continue On Failure  Trigger ho     cell=21



        Verify Tshark For HO failure         !=0
        Sleep    5s
        Stop wireshark

        Sleep    100s
        Start wireshark
        Sleep    5s
        Run Keyword And Continue On Failure  Trigger ho     cell=21
        Verify Tshark For HO failure         ==0
        Sleep    5s
        Stop wireshark

        Sleep    500s
        Start wireshark
        Sleep    5s
        Run Keyword And Continue On Failure  Trigger ho     cell=21
        Verify Tshark For HO failure        !=0
        Sleep    5s
        Stop wireshark

        Start wireshark
        Sleep    5s
        execute egate command    cmd=enb_param id=2 x2_force_reject_ho_req_with_cause=off
        Sleep    500s

        Run Keyword And Continue On Failure  Trigger ho     cell=21
        Verify Tshark For HO success
        Sleep    5s
        Stop wireshark

        Run UEx Command     trf_data_stop ue=1
        Run UEx Command     ue_detach id=1
    END


    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1

    ${sum}    VerIfy LTE Counters
    Log To Console    Returned Sum of M8014C21 = ${sum}
    [Teardown]     Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting

CB012311-A_B1-ALT1_02_Success_exclusion_intr-eNB_guest_cell_with_lost_PLMN_connect_upon_failed_S1-HO_bw_same_deplo_MORAN_eNBs_cause_Unknown_target_id
    Perform SCF Delta Commissioning with onlys1.json
    Sleep    180s
    FOR    ${index}    IN RANGE    3
        Log to Console    This is iteration ${index}
        Run UEx command  ue_attach   id=1    cell=1
        Sleep    5s
        Run UEx Command   trf_data_start   ue=1   dir=dl   protocol=udp   Mbps=20   stats=true
        Sleep    5s
        Run UEx Command   trf_data_stats    ue=1    dir=dl  unit=Mbps
        Sleep    5s




        Start wireshark
        Sleep   5s
#        execute egate command    cmd=enb_param id=2 x2_force_reject_ho_req_with_cause=RN_ho_target_not_allowed
        execute egate command    cmd=ue_mme_param id=1 s1_ho_preparation_failure=RN_unknown_targetID
        Sleep    5s


        Run Keyword And Continue On Failure  Trigger ho     cell=21



        Verify Tshark For HO failure s1          !=0
        Sleep    5s
        Stop wireshark

        Sleep    100s
        Start wireshark
        Sleep    5s
        Run Keyword And Continue On Failure  Trigger ho     cell=21
        Verify Tshark For HO failure s1         ==0
        Sleep    5s
        Stop wireshark

        Sleep    500s
        Start wireshark
        Sleep    5s
        Run Keyword And Continue On Failure  Trigger ho     cell=21
        Verify Tshark For HO failure s1        !=0
        Sleep    5s
        Stop wireshark

        Start wireshark
        Sleep    5s
        execute egate command    cmd=ue_mme_param id=1 s1_ho_preparation_failure=off
        Sleep    500s

        Run Keyword And Continue On Failure  Trigger ho     cell=21
        Verify Tshark For HO success s1
        Sleep    5s
        Stop wireshark

        Run UEx Command     trf_data_stop ue=1
        Run UEx Command     ue_detach id=1
    END

    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1

    ${sum}    VerIfy LTE Counters
    Log To Console    Returned Sum of M8014C21 = ${sum}
    [Teardown]     Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting





*** Keywords ***
Setup testline
        Add Simulator   sim_type=cus    config=${cus_ini}
        Add Enb Configuration           scfc=${scfc}
        Add Epc                         config=${lua}
        Configure environment
        setup egate   20000


Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:gNB3_XN    ip_with_mask=10.0.1.4/24
    Start Vm Ethernet Interface    if_name=eth3:gNB3_NG    ip_with_mask=10.0.1.6/24


Start wireshark
    start_tshark   log_filename=CB013254.pcap    eth_interface=eth3   capture_filter=less 1000   alias=tshark_default_alias
    ...     log_dirpath=/home/ute/robotws


Stop wireshark
    stop_tshark    alias=tshark_default_alias

Trigger ho
    [Arguments]    ${cell}
    ${status}    Set Variable    PASS
    TRY
        Run UEx Command   ue_ho    id=1    cell=${cell}
        Sleep    5s
    EXCEPT    AS    ${err}
        Log    HO trigger failed: ${err}    WARN
        ${status}    Set Variable    FAIL
    END
    Should Be Equal    FAIL    FAIL
    [Return]    ${status}




Verify Tshark Message
    [Arguments]    ${packet_filter}    ${pass_criteria}= !=0
    ${status}    Set Variable    PASS
    TRY
        Verify Tshark
        ...    alias=tshark_default_alias
        ...    packet_filter=${packet_filter}
        ...    pass_criteria=${pass_criteria}
        ...    pcap_file_path=/home/ute/robotws/CB013254.pcap
    EXCEPT    AS    ${err}
        Log    Tshark message verification failed: ${err}    WARN
        ${status}    Set Variable    FAIL
    END
    Should Be Equal    FAIL    FAIL
    [Return]    ${status}


Verify Tshark For HO failure
    [Arguments]    ${pass_criteria}
    ${status}    Set Variable    PASS
    TRY
    Verify Tshark Message
    ...    packet_filter=x2ap.HandoverPreparationFailure_element && x2ap.radioNetwork == 8
    ...    pass_criteria=${pass_criteria}
    EXCEPT    AS    ${err}
        Log    ScellAddition/HO verification failed: ${err}    WARN
        ${status}    Set Variable    FAIL
    END
    Should Be Equal    FAIL    FAIL
    [Return]    ${status}


Verify Tshark For HO success
    ${status}    Set Variable    PASS
    TRY
        Verify Tshark Message   packet_filter=lte-rrc.handoverType == 0
    EXCEPT    AS    ${err}
        Log    HO success verification failed: ${err}    WARN
        ${status}    Set Variable    FAIL
    END
    Should Be Equal    FAIL    FAIL
    [Return]    ${status}




Verify Tshark For HO failure s1
    [Arguments]    ${pass_criteria}
    ${status}    Set Variable    PASS
    TRY
        Verify Tshark Message
        ...    packet_filter=s1ap.HandoverPreparationFailure_element && s1ap.radioNetwork == 11
        ...    pass_criteria=${pass_criteria}
    EXCEPT    AS    ${err}
        Log    ScellAddition/HO verification failed: ${err}    WARN
        ${status}    Set Variable    FAIL
    END
    Should Be Equal    FAIL    FAIL
    [Return]    ${status}



Verify Tshark For HO success s1
    ${status}    Set Variable    PASS
    TRY
        Verify Tshark Message   packet_filter=s1ap.radioNetwork == 2
    EXCEPT    AS    ${err}
        Log    HO success verification failed: ${err}    WARN
        ${status}    Set Variable    FAIL
    END
    Should Be Equal    FAIL    FAIL
    [Return]    ${status}

Collect PM Counter LTE
    [Arguments]    ${collector_alias}=enb_pm_counters    ${target_dir}=None  ${component}=DU
    ${webservice}=       Create Dictionary
    ...    host=192.168.255.129
    ...    user=Nemuadmin
    ...    password=nemuuser
    ...    port=443
    ${oam_type}=    Set Variable     coam
    ${target_dir}=    Set Variable    /home/ute/robotws/Logs/${target_dir}
    collect_pm.Create PM Collector    name=${collector_alias}    webservice=${webservice}    oam_type=${oam_type}
    collect_pm.Setup Collectors       names=${collector_alias}
    collect_pm.Collect Collectors     names=${collector_alias}    target_dir=${target_dir}
    collect_pm.Teardown Collectors    names=${collector_alias}
    Log to Console   ${component}
    [Return]    ${target_dir}/${collector_alias}


VerIfy LTE Counters
    ${status}    Set Variable    PASS
    TRY
        ${PM_dir1}     Collect PM Counter LTE     collector_alias=pm_counters_enb1      target_dir=${TEST_NAME}
        ${pi_list}    Create List    M8014C21
        ${PM_report_dict_list}    check_pm.Get Pi Value    pi_list=${pi_list}    pi_dir=${PM_dir1}    pi_file_pattern=PM*

        ${non_zero_values}    Create List
        ${sum_non_zero}    Set Variable    0

        FOR    ${timestamp_dict}    IN    @{PM_report_dict_list}
            ${ts_keys}    Get Dictionary Keys    ${timestamp_dict}
            ${ts}    Set Variable    ${ts_keys[0]}
            ${pi_data}    Get From Dictionary    ${timestamp_dict}    ${ts}
            ${m_data}    Get From Dictionary    ${pi_data}    M8014C21

            ${matched_value}    Set Variable    ${None}
            FOR    ${key}    ${val}    IN    &{m_data}
                ${is_match}    Run Keyword And Return Status    Should Contain    ${key}    ${moc}
                IF    ${is_match}
                    ${matched_value}    Set Variable    ${val}
                    Exit For Loop
                END
            END

            IF    '${matched_value}' != '${None}' and ${matched_value} != 0
                Append To List    ${non_zero_values}    ${matched_value}
                ${sum_non_zero}    Evaluate    ${sum_non_zero} + ${matched_value}
            END
        END

        IF    ${sum_non_zero} == 0
            Log    Counter M8014C21 value is zero across all timestamps    WARN
        ELSE
            Log To Console    Non-zero M8014C21 values: ${non_zero_values}
            Log To Console    Sum of all non-zero M8014C21 values: ${sum_non_zero}
        END

    EXCEPT    AS    ${err}
        Log    LTE RIM counter verification failed: ${err}    WARN
        ${status}    Set Variable    FAIL
        ${sum_non_zero}    Set Variable    0
    END
    Should Be Equal    FAIL    FAIL
    [Return]    ${sum_non_zero}


Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}


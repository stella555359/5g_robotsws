*** Settings ***
Documentation     This file contains all common keywords required for the Feature CB008187.
Library           taf.sbts.oam.coam.admin    WITH NAME    admin
Library           Collections
Library           String
Library           ute_fsmaccess
Library           ta5g_pm_counters
Library           ${CURDIR}/../../../resources/PythonLib/UTILS.py
Variables         ta5g_global_var
Resource          ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource          ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource          ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource          ${CURDIR}/../../../resources/Keywords/PCMD_Related_KW.robot
Resource          ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource          ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource          ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource          ${CURDIR}/../../../resources/Variables/common_variables.robot
Resource          ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${TOPOLOGY}                      CLOUD_5G_O_E_AP_LOOO
${DeltaConfigDir}                ${CURDIR}/../../config/scf/
${AP_CONFIG_BASIC}               ${CURDIR}/../../config/wts
${dummy4_uecapinfo}              nr-rrc.ueCapabilityInformation_element
${uecap_d4}                      nr-rrc.mAC_ParametersCommon.dummy -e nr-rrc.burstLength -e nr-rrc.maxSimultaneousResourceSetsPerCC
...                              -e nr-rrc.maxConfiguredResourceSetsPerCC -e nr-rrc.maxConfiguredResourceSetsAllCC
${APCONFIGDIR}                   ${CURDIR}/../../config/ap_iphy/
${eutra_fields}                  nr-rrc.bandEUTRA -e nr-rrc.ca_BandwidthClassDL_EUTRA -e nr-rrc.ca_BandwidthClassUL_EUTRA
${dummy4_ueradioacesscapinfo}    ngap.id == 117
${filter_for_uecapenq}           nr-rrc.ueCapabilityEnquiry_element
${rd_parametrs}                  0x890073 = 0;0x60001F = 1


*** Keywords ***
Prepare For Test Case CB009173
    [Documentation]    Setup environment for Test Case CB009173.
    Link SCOUT SCF To Configuration ID For Reporting
    Update BSR Package For RJIO
    ${log_path}    Create Log Directory    CB009173
    GNB Delta Commission    ${DeltaConfigDir}/Delta_9173_enable.json
    Sleep    30s
    Add RD Parameters Directly On GNB    ${rd_parametrs}
    GNB Reboot
    Sleep    360s
    Wait Coam Site To Be Ready
    Start UTE WTS    basic_setup.cfg
    Basic Bring Up For RJIO
    [Return]    ${log_path}

Tear Down For Test Case 9173
    [Documentation]    Revert changes made for Test Case CB009173.
    Collect Logs For The Test    ${log_path}
    Copy Files    ${WTS_WORKING_DIR}/egate_console.log    ${log_path}
    Snapshot Collection    ${log_path}    Snapshot.zip
    Run    zip -r ${OUTPUTDIR}/CB009173.zip ${log_path}
    RAT BLOCK UNBLOCK
    Wait Coam Site To Be Ready

Basic Bring Up for RJIO
    [Documentation]       This keyword is for basic Ng and AP cell setup
    NG Link Should Be UP
    Sleep   90s

Get Chipset And RAN ID Info From UEcapinfo
    [Documentation]    Extract chipset and RAN info from pcap file.
    [Arguments]    ${pcap_file}    ${dummy4_filter}=${dummy4_uecapinfo}
    ${d4_values}    Get Fields From Pcap    ${pcap_file}    ${dummy4_filter}    ${uecap_d4}
    @{d4_value_list}    Split String And Return Multiple List    ${d4_values}
    Extract First Values    @{d4_value_list}

Get EUTRA Information From UEcapinfo
    [Documentation]    Extract EUTRA info from pcap file.
    [Arguments]    ${pcap_file}    ${eutra_filter}=${dummy4_uecapinfo}
    ${eutra_op}    Get Fields From Pcap    ${pcap_file}    ${eutra_filter}    ${eutra_fields}
    Extract And Compare EUTRA Lists    ${eutra_op}

Check For Dummy4 UE Radio Access Cap Information
    [Documentation]    Extract chipset and RAN info from UE Radio Access Cap info pcap.
    [Arguments]    ${pcap_file}    ${dummy4_filter}=${dummy4_ueradioacesscapinfo}
    ${d4_values}    Get Fields From Pcap    ${pcap_file}    ${dummy4_filter}    ${uecap_d4}
    @{d4_value_list}    Split String And Return Multiple List    ${d4_values}
    Extract First Values    @{d4_value_list}

Check If UE Cap Enquiry Is Not Sent By GNB
    [Documentation]    Verify UE Capability Enquiry is not sent by gNB.
    [Arguments]    ${pcap_file}    ${uecap_enq}=${filter_for_uecapenq}
    Msg Should Not Be Present In PCAP    ${pcap_file}    ${uecap_enq}

Extract And Compare EUTRA Lists
    [Documentation]    Compare extracted EUTRA band values.
    [Arguments]    ${eutra_op}
    @{eutra_list1}    Create List    200    0    3
    @{eutra_list2}    Create List    201    0    3
    @{eutra_list3}    Create List    202    0    0
    @{eutra_groups}    Split String    ${eutra_op}
    @{list1_group}    Split String    ${eutra_groups[0]}    ,
    @{list2_group}    Split String    ${eutra_groups[1]}    ,
    @{list3_group}    Split String    ${eutra_groups[2]}    ,
    ${list1}    Create List    ${list1_group[0]}    ${list2_group[0]}    ${list3_group[0]}
    ${list2}    Create List    ${list1_group[1]}    ${list2_group[1]}    ${list3_group[1]}
    ${list3}    Create List    ${list1_group[2]}    ${list2_group[2]}    ${list3_group[2]}

    IF    ${list1} == ${eutra_list1}
        Log    List ${list1} matches expected EUTRA List ${eutra_list1}
    ELSE
        Log    List ${list1} does not match expected EUTRA List ${eutra_list1}
    END

    IF    ${list2} == ${eutra_list2}
        Log    List ${list2} matches expected EUTRA List ${eutra_list2}
    ELSE
        Log    List ${list2} does not match expected EUTRA List ${eutra_list2}
    END

    IF    ${list3} == ${eutra_list3}
        Log    List ${list3} matches expected EUTRA List ${eutra_list3}
    ELSE
        Log    List ${list3} does not match expected EUTRA List ${eutra_list3}
    END

Split String And Return Multiple List
    [Documentation]    Split a string and return a list of lists.
    [Arguments]    ${data}
    ${split_by_space}    Split String    ${data}
    ${list_of_lists}    Create List
    FOR    ${item}    IN    @{split_by_space}
        ${list}    Split String    ${item}    ,
        Append To List    ${list_of_lists}    ${list}
    END
    [Return]    ${list_of_lists}

Register And Establish Non-GBR Call
    [Documentation]    Register UE and establish Non-GBR data call.
    [Arguments]    ${UE_ID}=${UE_ID}    ${Pdu_session_ID}=${Pdu_session_ID}
    ...            ${traffic_dl_rate}=${traffic_dl_rate}    ${traffic_ul_rate}=${traffic_ul_rate}
    Enable Internal TG    ${UE_ID}    ${Pdu_session_ID}
    UE Register Should Be Successful
    Sleep    10s
    Traffic Should Be Successful For SA    ${traffic_dl_rate}    ${traffic_ul_rate}    ${UE_ID}
    Sleep    10s

Stop PCAP Collection In GNB CU
    [Documentation]    Stop PCAP logs collection on gNB.
    [Arguments]    ${name}=gnbTcpdump    ${log_path}=${log_path}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${log_path}
    core.teardown_collectors    names=${name}
    ${pcap_file}    Join Path    ${log_path}    ${name}    ${name}.pcap
    Log To Console    PCAP capture stopped.
    [Return]    ${pcap_file}

Extract First Values
    [Documentation]    Extract first values from each inner list and compare.
    [Arguments]    @{d4_value_list}
    @{expected_values}    Create List    0    1    5    37    12
    FOR    ${index}    IN RANGE    0    5
        ${first_value}    Get From List    ${d4_value_list[${index}]}    0
        ${expected_value}    Get From List    ${expected_values}    ${index}
        IF    '${first_value}' == '${expected_value}'
            Log    ${first_value} matches ${expected_value}
        ELSE
            Log    ${first_value} does not match ${expected_value}
        END
    END

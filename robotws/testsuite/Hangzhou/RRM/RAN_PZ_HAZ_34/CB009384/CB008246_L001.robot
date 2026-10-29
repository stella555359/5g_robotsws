*** Settings ***
Force Tags    PY36
Documentation     author: yayun.zhang
...                 contact: yayun.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB008246-L

Resource    ./Resources/CB009384_common_keywords.robot
Variables    ./Resources/CB009384_variables.py
Library    ./Resources/CB009384_common_keywords.py


Suite Setup    Run Keywords
...            Common Suite Setup for COAM    AND
...            Common Case TestLine Setup for CB008246

Suite Teardown    Run Keywords
...               Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${gnb_path}    /tmp
${golden_scf_name}    golden_TDD
${scf_path}    /opt/workspace/CRT/Master/SCF_file/
#${tl_scf_SBTS24R3_ENB_9999}    golden_TDD.xml
#${tl_scf_SBTS24R2_ENB_0000}    golden_TDD_24R1.xml
#${tl_scf_SBTS24R1_ENB_0000}    golden_TDD_24R1.xml
${log_name_L_001_1}    log_name_L_001_1.pcap
${interface1}    any
${Send_Tput_DL}    10M
${expected_tput_dl}   8
${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"(ngap or e1ap or f1ap or xnap or s1ap or x2ap)\"  -T pdml
*** Test Cases ***
[1]CB008246_L01_High_reliability_DRB_IWK_with_RedCap_UE_ATTACH
    [Documentation]
    ...    This case checks IWK redcap
    [Tags]    classical    CRT_TRUNK    CRT_24R1
    [Setup]
    robot_common_operations.Common Case Setup
    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${PARAM_8246_gnb1_L_001}
    Adjust gNB_RU Attenuation    gnb1_cell3_value=${40}
#    Andriod UE adb reboot    ue_index=${2}
    MTK prepare UE    ue_type=${ue_type}    ue_index=${2}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}
    Start capture gNB log on master    filename=${log_name_L_001_1}    gNB_index=${0}
    MTK UE Attach    ue_type=${ue_type}    ue_index=${2}
    Stop and download the Logs    filename=${log_name_L_001_1}   gNB_index=${0}
    Analysis wireshark for L001_1    logname=${log_name_L_001_1}
    Check wireshark log for 8246_L_UE_RNTI_ID    logname=${log_name_L_001_1}
    Start DLUL traffic and check throughput    cellid=3    ue_index=${2}    ul_throughput=NULL    tput_ul=NULL
    sleep    10s
    ${pci}=    get required cell info   required_info=physicalCellId    cell_index=${3}   gnb_index=${0}
    Capture Ttitrace With Admin Mode and Convert format    names=l2stream3_ttitrace_1    nr_phy_cell_ids=${pci}
    sleep    10s
    Analysis tti for L001_1
    Stop UE DLUL traffic    ue_index=${2}    ul_port=NULL
    [Teardown]    run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}    AND
    ...    Run Keyword And Ignore Error    Case Teardown


*** Keywords ***
Check wireshark log for 8246_L_UE_RNTI_ID
    [Arguments]    ${logname}
    ${UE_RNTI_ID}=    Get RNTI-ID message    logname=${logname}
    Set Suite Variable    ${SA_UE_RNTI_ID}    ${UE_RNTI_ID}

Get RNTI-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####InitialULRRCMessageTransfer, RRC Setup Request
    ${RRC_Setup_request}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11 and f1ap.C_RNTI)
    ${RRC_Setup_request_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Setup_request}
    ${UE_RNTI_ID}=     cap.get_field_value_by_xpath    pdml_list=${RRC_Setup_request_packets}
    ...                                                xpath=.//f1ap.C_RNTI
    [Return]    ${UE_RNTI_ID}[-1]

Analysis tti for L001_1
    Analysis tti for L001_1 UL    names=l2stream3_ttitrace_1
    Analysis tti for L001_2 DL    names=l2stream3_ttitrace_1

Analysis wireshark for L001_1
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    Log To Console    check 5QI5 qam256 F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.uplinkBWP_ToAddModList == 1
    ...                                    and nr-rrc.mcs_Table ==0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Contain X Times    ${nr_rrc_mcs_Table}    0   1
    Log To Console    check 5QI5 cqitable2 F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12 and f1ap.F1AP_PDU == 0 and nr-rrc.cqi_Table == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_cqi_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.cqi_Table    pcap_parser=test6
    Should Contain X Times     ${nr_rrc_cqi_Table}    1  2
    Log To Console    Check DL_UE_No_MCS_table_Capbility:64QAMLowSE
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.downlinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Not Contain    ${nr_rrc_mcs_Table}    1
    Log To Console    check 5QI 7 No cqi-table1 F1AP DLRRCMessageTransfer RRC Reconfiguration,DL NAS transport,PDU session establishent accept
    ${filter_expression}=     Catenate    (f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.dedicatedNAS_MessageList == 1
    ...    and nr-rrc.cqi_Table ==0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.cqi_Table    pcap_parser=test6
    Should Not Contain    ${nr_rrc_mcs_Table}    0

Analysis tti for L001_1 UL
    [Arguments]    ${names}
    log to console    analysis L01 UL tti file from Case_Logs file...
    ${ulFdSchedData_laMode}    get_ulFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_laMode}
        should be equal      ${i}    BASICRELIABILITY
    END
    ${ulFdSchedData_mcsTable}    get_ulFdSchedData_mcsTable_value    csv_file=${epc_log_path}/${names}_ul.csv
    ...    filter_name1=rnti     filter_name2=ulFdSchedData.mcsTable    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{ulFdSchedData_mcsTable}
        should be equal      ${i}    QAM64
    END

Analysis tti for L001_2 DL
    [Arguments]    ${names}
    log to console    analysis L01 DL  tti file from Case_Logs file...
    ${dlFdSchedData_laMode}    get_dlFdSchedData_laMode_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=rnti     filter_name2=dlFdSchedData.laMode    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{dlFdSchedData_laMode}
        should be equal      ${i}    BASICRELIABILITY
    END
    ${dlFdSchedData_mcsTable}    get_dlFdSchedData_mcsTable_value    csv_file=${epc_log_path}/${names}_dl.csv
    ...    filter_name1=rnti     filter_name2=dlFdSchedData.mcsTable    filter_name3=${SA_UE_RNTI_ID}
    FOR  ${i}    IN    @{dlFdSchedData_mcsTable}
        should be equal      ${i}    QAM256
    END

Common Case TestLine Setup for CB008246
    ${release}=    Get sagnb release title
    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${golden_scf_name}_${release}.xml
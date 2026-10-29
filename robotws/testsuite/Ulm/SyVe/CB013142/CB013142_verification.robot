*** Settings ***
Documentation   covers the verifcation of the TCs for CB013142
...             2 parts - verification for each TC
...                     - keywords to verify the trace
...             Team: 'MN RAN RD VRF ULM 1'
...             Email: 'ou_mn_ran_rd_vrf_ulm_1_53028392@internal.nsn.com'
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource    ../../resources/Common/coam_ulm.robot
Resource    ../resources/pcap_analysis.robot

*** Keywords ***

Verify Test Case
   [Arguments]   ${test_name}

   Run Keyword  Verify Test Case ${test_name}

Verify Test Case CB013142 A ST TC01 B2 SA A2 Meas Reconfig On PCell For PCell Change Using Meas Profile Based On UE PC Upon SCell Change
    Log To Console    \nStarting TC Verification
    Log To Console    \n Verify TC checks on gNB${gnb_id}

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${A2Thres_MEASPR_2}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a2ThresholdhoSsbRsrp
    ...  list_name=a2MeashoSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2
    ...  alias=${oam_alias}

    Log To Console  \nverify attach
    Run Keyword And Continue On Failure  Check A2Measurment In RRC Reconfiguration Message
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/attach_pcell_traces_gnb${gnb_id}.pcap
    ...  a2ThresPcellSwitch_Measpr=${A2Thres_MEASPR_2}

    Log To Console  \nverify scell addition
    Run Keyword And Continue On Failure  Check A2Measurment In RRC Reconfiguration Message
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_0/scell_addition_traces_gnb0.pcap
    ...  a2ThresPcellSwitch_Measpr=${A2THRESPCELLSWITCH_MEASPR_1}

    Log To Console  \nverify scell change
    Run Keyword And Continue On Failure  Check A2Measurment In RRC Reconfiguration Message
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_0/scell_change_traces_gnb0.pcap
    ...  a2ThresPcellSwitch_Measpr=${A2THRESPCELLSWITCH_MEASPR_2}


Verify Test Case CB013142 C ST TC01 B3 NSA Target Cell Radio Quality Evaluation During A2 Based PSCell Change Using Meas Profile
    Log To Console    \nStarting TC Verification
    Log To Console    \n Verify TC checks on gNB${gnb_id}

    ${physCellId_pcell}  ${physCellId_scell}  Get PhysCellId For Scell And Pcell  p_cell=${p_cell_1}  s_cell=${s_cell_1}

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${A2Thres_MEASPR_1}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a2ThresholdhoSsbRsrp
    ...  list_name=a2MeashoSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    ...  alias=${oam_alias}

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${A2Thres_MEASPR_2}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a2ThresholdReleaseSsbRsrp
    ...  list_name=a2MeasReleaseSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2
    ...  alias=${oam_alias}

    Log To Console  \nverify attach
    Run Keyword And Continue On Failure  Check Physical Cell Id Of Pcell
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/attach_pcell_traces_gnb${gnb_id}.pcap
    ...  physCellId=${physCellId_pcell}

    Log To Console  \nverify scell addition
    Run Keyword And Continue On Failure  Check Scell Addition
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/attach_pcell_traces_gnb${gnb_id}.pcap
    ...  physCellId=${physCellId_scell}
    ...  packet_filter=x2ap.procedureCode == 30
    Run Keyword And Continue On Failure  Check A2Measurment In RRC Reconfiguration Message
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/attach_pcell_traces_gnb${gnb_id}.pcap
    ...  a2ThresPcellSwitch_Measpr=${A2Thres_MEASPR_1}
    ...  packet_filter=x2ap.procedureCode == 30

    Log To Console  \nverify pcell change
    Run Keyword And Continue On Failure  Check Physical Cell Id Of Pcell
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/pcell_change_traces_gnb${gnb_id}.pcap
    ...  physCellId=${physCellId_scell}
    ...  packet_filter=x2ap.procedureCode == 30
    Run Keyword And Continue On Failure  Check A2Measurment In RRC Reconfiguration Message
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/pcell_change_traces_gnb${gnb_id}.pcap
    ...  a2ThresPcellSwitch_Measpr=${A2Thres_MEASPR_2}
    ...  packet_filter=x2ap.procedureCode == 30


Verify Test Case CB013142 D ST TC03 B4 NSA A1 Meas Config On SCell For PSCell Change Using NRCELL Config When Matching Profile Mapping Not Found
    Log To Console    \nStarting TC Verification
    Log To Console    \n Verify TC checks on gNB${gnb_id}

    ${physCellId_pcell}  ${physCellId_scell}  Get PhysCellId For Scell And Pcell  p_cell=${p_cell_1}  s_cell=${s_cell_1}

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${A1Thres_MEASPR}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a1ThresholdPCellSwitchSsbRsrp
    ...  list_name=a1MeasPCellSwitchSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1
    ...  alias=${oam_alias}

    ${A1TimeToTrigger_MEASPR}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a1TimeToTriggerPCellSwitchSsbRsrp
    ...  list_name=a1MeasPCellSwitchSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-1
    ...  alias=${oam_alias}

    ${A1Thres_NRCELL}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a1ThresholdPCellSwitchSsbRsrp
    ...  list_name=a1MeasPCellSwitchSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${s_cell_1}
    ...  alias=${oam_alias}

    ${A1TimeToTrigger_NRCELL}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a1TimeToTriggerPCellSwitchSsbRsrp
    ...  list_name=a1MeasPCellSwitchSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${s_cell_1}
    ...  alias=${oam_alias}

    Get Measurement Mapping  pcap_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/measprof_not_used_traces_gnb${gnb_id}.pcap

    ${scell_freq}  Get From Dictionary  ${phys_freq}  ${physCellId_scell}
    ${found}  Get Matches  ${meas_mapping}  *${scell_freq}*eventA1
    @{words}  Split String  ${found[0]}  -
    Set Test Variable    ${reportConfigId}  ${words[3]}

    Log To Console  \nverify attach
    Run Keyword And Continue On Failure  Check Physical Cell Id Of Pcell
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/measprof_not_used_traces_gnb${gnb_id}.pcap
    ...  physCellId=${physCellId_pcell}

    Log To Console  \nverify scell addition
    Run Keyword And Continue On Failure  Check Scell Addition
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/measprof_not_used_traces_gnb${gnb_id}.pcap
    ...  physCellId=${physCellId_scell}
    ...  packet_filter=x2ap.procedureCode == 30

    Log To Console  \nverify scell addition
    Run Keyword And Continue On Failure  Check A1Measurment In RRC Reconfiguration Message
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/measprof_not_used_traces_gnb${gnb_id}.pcap
    ...  a1ThresPcellSwitch=${A1Thres_NRCELL}
    ...  packet_filter=nr-rrc.reportConfigId == ${reportConfigId}

    Run Keyword And Continue On Failure   Should Contain    ${phycell_events}[${physCellId_scell}]  eventA1

#### mit measprof
    Get Measurement Mapping  pcap_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/measprof_used_traces_gnb${gnb_id}.pcap

    ${scell_freq}  Get From Dictionary  ${phys_freq}  ${physCellId_scell}
    ${found}  Get Matches  ${meas_mapping}  *${scell_freq}*eventA1
    @{words}  Split String  ${found[0]}  -
    Set Test Variable    ${reportConfigId}  ${words[3]}

    Log To Console  \nverify attach
    Run Keyword And Continue On Failure  Check Physical Cell Id Of Pcell
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/measprof_used_traces_gnb${gnb_id}.pcap
    ...  physCellId=${physCellId_pcell}

    Log To Console  \nverify scell addition
    Run Keyword And Continue On Failure  Check Scell Addition
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/measprof_used_traces_gnb${gnb_id}.pcap
    ...  physCellId=${physCellId_scell}
    ...  packet_filter=x2ap.procedureCode == 30

    Log To Console  \nverify scell addition
    Run Keyword And Continue On Failure  Check A1Measurment In RRC Reconfiguration Message
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/measprof_used_traces_gnb${gnb_id}.pcap
    ...  a1ThresPcellSwitch=${A1Thres_MEASPR}
    ...  packet_filter=nr-rrc.reportConfigId == ${reportConfigId}

    Run Keyword And Continue On Failure   Should Contain    ${phycell_events}[${physCellId_scell}]  eventA1

Verify Test Case CB013142 F ST TC01 B1 SA A1 And A4 Config Meas For SCell Addition Using Selected Meas Profile Based On One Or More Criteria
    Log To Console    \nStarting TC Verification
    Log To Console    \n Verify TC checks on gNB${gnb_id}

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${A1ThresFDD_MEASPR}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a1ThresholdSCellAddSsbRsrpFDD
    ...  list_name=a1MeasSCellAddSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    ...  alias=${oam_alias}

    ${A1TimeToTrigger_MEASPR}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a1TimeToTriggerSCellAddSsbRsrp
    ...  list_name=a1MeasSCellAddSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    ...  alias=${oam_alias}

    ${A1ThresTDD_MEASPR}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a1ThresholdSCellAddSsbRsrpTDD
    ...  list_name=a1MeasSCellAddSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    ...  alias=${oam_alias}

    ${A4Thres_MEASPR}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a4ThresholdSCellAddSsbRsrp
    ...  list_name=a4MeasSCellAddSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1
    ...  alias=${oam_alias}

    ${A4TimeToTrigger_MEASPR}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a4TimeToTriggerSCellAddSsbRsrp
    ...  list_name=a4MeasSCellAddSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1
    ...  alias=${oam_alias}

    ${arfcnSsbPbch_scell}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=arfcnSsbPbch
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${s_cell_2}
    ...  alias=${oam_alias}
    ...  config_type=runtimeObjects

    ${arfcnSsbPbch_pcell}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=arfcnSsbPbch
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${p_cell_1}
    ...  alias=${oam_alias}
    ...  config_type=runtimeObjects

    Get Measurement Mapping  pcap_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/attach_pcell_traces_gnb${gnb_id}.pcap

    ${found}  Get Matches  ${meas_mapping}  *${arfcnSsbPbch_scell}*eventA4
    @{words}  Split String  ${found[0]}  -
    Set Test Variable    ${reportConfigId_eventA4}  ${words[3]}

    ${found}  Get Matches  ${meas_mapping}  *${arfcnSsbPbch_pcell}*eventA1
    @{words}  Split String  ${found[0]}  -
    Set Test Variable    ${reportConfigId_eventA1}  ${words[3]}

    Run Keyword And Continue On Failure  Check A1Measurment In RRC Reconfiguration Message
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/attach_pcell_traces_gnb${gnb_id}.pcap
    ...  a1ThresPcellSwitch=${A1ThresFDD_MEASPR}
    ...  packet_filter=nr-rrc.reportConfigId == ${reportConfigId_eventA1}

    Run Keyword And Continue On Failure  Check A4Measurment In RRC Reconfiguration Message
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/attach_pcell_traces_gnb${gnb_id}.pcap
    ...  a4Thres=${A4Thres_MEASPR}
    ...  packet_filter=nr-rrc.reportConfigId == ${reportConfigId_eventA4}

Verify Test Case CB013142 G ST TC01 B2 SA Reconfig Of A1 Meas On PCell For SCell Change Using Meas Profile Upon Setup Of VoNR
    Log To Console    \nStarting TC Verification
    Log To Console    \n Verify TC checks on gNB${gnb_id}

    ${physCellId_pcell}  ${physCellId_scell}  Get PhysCellId For Scell And Pcell  p_cell=${p_cell_1}  s_cell=${s_cell_1}

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${A1ThresTDD_MEASPR_IAF_1}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a1ThresholdSCellAddSsbRsrpTDD
    ...  list_name=a1MeasSCellAddSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    ...  alias=${oam_alias}

    ${A1ThresTDD_MEASPR_IAF_2}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a1ThresholdSCellAddSsbRsrpTDD
    ...  list_name=a1MeasSCellAddSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2
    ...  alias=${oam_alias}

    ${arfcnSsbPbch_pcell}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=arfcnSsbPbch
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${p_cell_1}
    ...  alias=${oam_alias}
    ...  config_type=runtimeObjects

    Run Keyword And Continue On Failure  Check Physical Cell Id Of Pcell
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/attach_traces_gnb${gnb_id}.pcap
    ...  physCellId=${physCellId_pcell}

    Run Keyword And Continue On Failure  Check Scell Addition
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/attach_traces_gnb${gnb_id}.pcap
    ...  physCellId=${physCellId_scell}

    Run Keyword And Continue On Failure  Check A1Measurment In RRC Reconfiguration Message
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/vonr_traces_gnb${gnb_id}.pcap
    ...  a1ThresPcellSwitch=${A1ThresTDD_MEASPR_IAF_1}
    ...  packet_filter=nr-rrc.measIdToAddModList

    Run Keyword And Continue On Failure  Check A1Measurment In RRC Reconfiguration Message
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/attach_traces_gnb${gnb_id}.pcap
    ...  a1ThresPcellSwitch=${A1ThresTDD_MEASPR_IAF_2}
    ...  packet_filter=nr-rrc.measIdToAddModList

    Run Keyword And Continue On Failure  Check VoNr
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/vonr_traces_gnb${gnb_id}.pcap

Verify Test Case CB013142 I ST TC01 B6 NSA A1 Based SCell Addition Based On Mobility Meas Results During PSCell Change Using Meas Profile
    Log To Console    \nStarting TC Verification
    Log To Console    \n Verify TC checks on gNB${gnb_id}

    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}

    ${physCellId_pcell}  ${physCellId_scell}  Get PhysCellId For Scell And Pcell  p_cell=${p_cell_1}  s_cell=${s_cell_2}
    ${physCellId_pcell_source}   coam_ulm.Get SCF Single Value From Current Xml File  dist_name=NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${s_cell_1}
    ...                          parameter=physCellId  alias=${oam_alias}

    ${A1ThresFDD_MEASPR_IAF_1}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a1ThresholdSCellAddSsbRsrpFDD
    ...  list_name=a1MeasSCellAddSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    ...  alias=${oam_alias}

    ${A1ThresScellAddFdd_NRCELL}  coam_ulm.Get SCF Single Value From Current Xml File
    ...  parameter=a1ThresholdSCellAddSsbRsrpFDD
    ...  list_name=a1MeasSCellAddSsbRsrp
    ...  dist_name=MRBTS-${nrbts_id_${gnb_id}}/NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${s_cell_1}
    ...  alias=${oam_alias}

    Run Keyword And Continue On Failure  Check Physical Cell Id Of Pcell
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/attach_pscell_traces_gnb${gnb_id}.pcap
    ...  physCellId=${physCellId_pcell_source}

    Run Keyword And Continue On Failure  Check A1Measurment In RRC Reconfiguration Message
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/attach_pscell_traces_gnb${gnb_id}.pcap
    ...  a1ThresPcellSwitch=${A1ThresScellAddFdd_NRCELL}
    ...  packet_filter=nr-rrc.measIdToAddModList

    Run Keyword And Continue On Failure  Check A1Measurment In RRC Reconfiguration Message
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/pcell_change_traces_gnb${gnb_id}.pcap
    ...  a1ThresPcellSwitch=${A1ThresFDD_MEASPR_IAF_1}
    ...  packet_filter=nr-rrc.measIdToAddModList

    Run Keyword And Continue On Failure  Check Physical Cell Id Of Pcell
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/scell_addition_traces_gnb${gnb_id}.pcap
    ...  physCellId=${physCellId_pcell}

    Run Keyword And Continue On Failure  Check Scell Addition
    ...  tcp_file=${P_resultTestDir}/tcpdump_gnb_${gnb_id}/scell_addition_traces_gnb${gnb_id}.pcap
    ...  physCellId=${physCellId_scell}
    ...  packet_filter=${F1AP_WS_DISPLAY_FILTER}.procedureCode ==7|| x2ap.procedureCode ==30


#keywords section

Get PhysCellId For Scell And Pcell
    [Arguments]   ${p_cell}  ${s_cell}
    ${oam_alias}=   connect.Setup OAM Http Session   node_id=${gnb_id}
    ${physCellId_scell}  coam_ulm.Get SCF Single Value From Current Xml File  dist_name=NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${scell}
    ...         parameter=physCellId  alias=${oam_alias}
    ${physCellId_pcell}  coam_ulm.Get SCF Single Value From Current Xml File  dist_name=NRBTS-${nrbts_id_${gnb_id}}/NRCELL-${p_cell}
    ...            parameter=physCellId  alias=${oam_alias}
    RETURN  ${physCellId_pcell}  ${physCellId_scell}

Check A2Measurment In RRC Reconfiguration Message
    [Arguments]   ${tcp_file}  ${a2ThresPcellSwitch_Measpr}  ${packet_filter}=${F1AP_WS_DISPLAY_FILTER}.procedureCode == 12
    ${output}    ute_tshark.Read Pcap    packet_filter=${packet_filter}  output_type=pdml  pcap_file_path=${tcp_file}
    ${rsrp}    Get Elements    ${output}    .//field[@name='nr-rrc.eventA2_element']
    ${rsrp_list}  Create List
    FOR  ${i}  IN   @{rsrp}
        ${rsrp_value}    Get Element  ${i}  .//field[@name='nr-rrc.measTriggerQuantity.rsrp']
        ${show}  Get Element Attribute  ${rsrp_value}  show
        Log To Console  \na2Thresholds in RRC reconfiguration ${show}
        Append To List  ${rsrp_list}  ${show}
    END
    List Should Contain Value  ${rsrp_list}  ${a2ThresPcellSwitch_Measpr}

Check A1Measurment In RRC Reconfiguration Message
    [Arguments]   ${tcp_file}  ${a1ThresPcellSwitch}  ${packet_filter}=${F1AP_WS_DISPLAY_FILTER}.procedureCode == 12
    ${output}    ute_tshark.Read Pcap    packet_filter=${packet_filter}  output_type=pdml  pcap_file_path=${tcp_file}
    ${rsrp}    Get Elements    ${output}    .//field[@name='nr-rrc.eventA1_element']
    ${rsrp_list}  Create List
    FOR  ${i}  IN   @{rsrp}
        ${rsrp_value}    Get Element  ${i}  .//field[@name='nr-rrc.measTriggerQuantity.rsrp']
        ${show}  Get Element Attribute  ${rsrp_value}  show
        Log To Console  \na1Thresholds in RRC reconfiguration ${show}
        Append To List  ${rsrp_list}  ${show}
    END
    List Should Contain Value  ${rsrp_list}  ${a1ThresPcellSwitch}

Check A4Measurment In RRC Reconfiguration Message
    [Arguments]   ${tcp_file}  ${a4Thres}  ${packet_filter}=${F1AP_WS_DISPLAY_FILTER}.procedureCode == 12
    ${output}    ute_tshark.Read Pcap    packet_filter=${packet_filter}  output_type=pdml  pcap_file_path=${tcp_file}
    ${rsrp}    XML.Get Elements    ${output}    .//field[@name='nr-rrc.eventA4_element']
    ${rsrp_list}  Create List
    FOR  ${i}  IN   @{rsrp}
        ${rsrp_value}    Get Element  ${i}  .//field[@name='nr-rrc.measTriggerQuantity.rsrp']
        ${show}  Get Element Attribute  ${rsrp_value}  show
        Log To Console  \na1Thresholds in RRC reconfiguration ${show}
        Append To List  ${rsrp_list}  ${show}
    END
    List Should Contain Value  ${rsrp_list}  ${a4Thres}


Check Physical Cell ID Of Pcell
    [Arguments]    ${tcp_file}  ${physCellId}  ${packet_filter}=${F1AP_WS_DISPLAY_FILTER}.procedureCode ==7
    ${output}    ute_tshark.Read Pcap    packet_filter=${packet_filter}  output_type=pdml  pcap_file_path=${tcp_file}
    ${PcellAdd_elem}    Get Elements    ${output}     .//field[@name='nr-rrc.spCellConfig_element']//field[@name='nr-rrc.physCellId']
    Should Not Be Empty  ${PcellAdd_elem}

    Log To Console   The PCell is:
    FOR  ${i}   IN   @{PcellAdd_elem}
         ${showname}     Get Element Attribute    ${i}    showname
         Log To Console   PCell ${showname}
         Should Contain Any  ${showname}  ${physCellId}  msg=Wrong physCellId
    END

Check Scell Addition
    [Arguments]    ${tcp_file}  ${physCellId}  ${packet_filter}=${F1AP_WS_DISPLAY_FILTER}.procedureCode ==7
    ${output}       ute_tshark.Read Pcap    packet_filter=${packet_filter}  output_type=pdml  pcap_file_path=${tcp_file}
    ${ScellAdd_elem}   Get Elements  ${output}  .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.physCellId']
    Should Not Be Empty  ${ScellAdd_elem}

    Log To Console   Checking SCell addition
    FOR  ${i}   IN   @{ScellAdd_elem}
       ${showname}    Get Element Attribute    ${i}    showname
       Log To Console  found scell: ${showname}
       Should Contain Any  ${showname}  ${physCellId}  msg=Wrong physCellId
    END

Check VoNr
    [Arguments]    ${tcp_file}  ${packet_filter}=ngap.procedureCode == 26
    ${output}       ute_tshark.Read Pcap    packet_filter=${packet_filter}  output_type=pdml  pcap_file_path=${tcp_file}
    ${fiveQI_value}   Get Elements  ${output}  .//field[@name='ngap.qosFlowLevelQosParameters_element']//field[@name='ngap.fiveQI']
    Should Not Be Empty  ${fiveQI_value}

    Log To Console   Checking fiveQi value
    FOR  ${i}   IN   @{fiveQI_value}
       ${showname}    Get Element Attribute    ${i}    showname
       Log To Console  found fiveQi value: ${showname}
       Should Contain Any  ${showname}  fiveQI: 1  msg=VoNr not successful
    END

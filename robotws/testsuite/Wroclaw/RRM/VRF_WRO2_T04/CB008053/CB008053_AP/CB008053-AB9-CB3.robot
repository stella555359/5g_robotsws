*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation
...        maintainer:   Lukasz Klimowicz, lukasz.klimowicz@nokia.com
...        authors:      Lukasz Klimowicz, lukasz.klimowicz@nokia.com

Resource   ../resources/CB008053_AP_resources.robot
Library     ../resources/CB008053_tti_trace_keywords.py
Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    taf/ul/ettf/main.robot
Resource     ../../../WRO_2/keywords/messaging.robot
Resource     ../../../WRO_2/keywords/traffic.robot
Resource     ../../../WRO_2/keywords/L3_Call.robot
Resource     ../../resources/common_airphone_keywords.robot
Resource     ../../resources/common_keywords.robot
Resource     ../../resources/ute_report.robot
Resource     ta_messaging/flow.robot
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_iphy


Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
    ...            AND             Update And Put Iphy Xml    input_filepath=${ap_xml}
    ...            AND             With Gnb Configuration    commissioning=${scfc}
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             With Simulator Configuration    config=${egate_config}
    ...            AND             Add Scout Data Info To Testcase

*** Variables ***
${KEEP_ALIVE}=  ${True}
${LOGS_COMPRESSION}=    ${False}
${LOGGING_POLICY}=    NO_LOGS
${egate_config}=  ${CURDIR}/config/wts_3cells_FDD_4cells_TDD_A-B9.cfg
${scfc}=          SCF_CB008053-A-B9.xml
${ap_xml}=        ${CURDIR}/config/iphy_CB008053-A-B9.xml

@{UE2_trf_ids_dl}=    1    2    3    4    5
@{UE2_mbps_dl}=    175    175    175    175    150
@{UE2_qfi_ids_dl}=    1    1    1    1    1
@{UE2_trf_ids_ul}=    6
@{UE2_mbps_ul}=    100
@{UE2_qfi_ids_ul}=    1
@{PCell_id}=    0
@{SCell_id}=    0    1    2    3

*** Test Cases ***
CB008053-A-B9_2_Interaction_with_CNI-80224_-_CB007827_release_and_visibility_change_with_simultaneousCSI-ReportsAllCC_12

    Create UE Alias    alias=UE_2    ue_id=2    id_type=wts_5g
    Create gNB Alias
    Register 4CC DL CA capable NR-UE2 to gNB-2 Cell-4
    Establish PDU session to trigger blind SCell addition for NR-UE2

    Verify NR-UE2 successfully attached to the PCell and gNB obtained UE capabilities and contains simultaneousCSI-ReportsAllCC eq 12
    Verify SCell-ToBeSetupMod-List IE whether 2TDD Cells and 1FDD Cell were selected to 4CC DL CA for NR-UE2
    Verify resourceSetToAddModList IE whether PUCCH resources were allocated correctly for BF enabled for TTTF 4CC CA NR-UE2
    Verify SCellToAddModList IE whether each SCell has CSI-RS configuration for NR-UE2


    Collect TTI Traces during 2s seconds and save to directory pCSI_BM_reported_in_a_bundle




    Start Data Traffic    ue_id=2   pdu_id=2    qfi_id_list=${UE2_qfi_ids_dl}
    ...    trf_id_list=${UE2_trf_ids_dl}
    ...    dir=dl
    ...    mbps_list=${UE2_mbps_dl}
    ...    protocol=udp
    ...    size=1350
    Start Data Traffic    ue_id=2   pdu_id=2    qfi_id_list=${UE2_qfi_ids_ul}
    ...    trf_id_list=${UE2_trf_ids_ul}
    ...    dir=ul
    ...    mbps_list=${UE2_mbps_ul}
    ...    protocol=tcp
    ...    size=1350

    Wait for Traffic to Stabilize    inactive_timer=10



    Verify HARQ-AN for PDSCH transmission can be decoded correctly when multiplexed with pCSI (bundled or separate) for NR-UE2
    Verify That Throughput Is Reached On Specific Cells    ue_id=2    cells_list=${PCell_id}
    ...    expected_throughput=100Mbps    direction=ul    margin=5%    selection_type=Maximum
    Verify DL throughput in SA mode on SCell-0,1,2,3 is over 500Mbps for NR-UE2

    Trigger Beam change on the TDD FR1 SCells based on SSB beam measurements received from UE for NR-UE2
    Collect TTI Traces during 2s seconds and save to directory beam_switch

    Verify That Throughput Is Reached On Specific Cells    ue_id=2    cells_list=${PCell_id}
    ...    expected_throughput=100Mbps    direction=ul    margin=5%    selection_type=Maximum
    Verify DL throughput in SA mode on SCell-0,1,2,3 is over 500Mbps for NR-UE2

    Trigger DL BLER Test Mode to achieve Target MCS for NR-UE2
    Collect TTI Traces during 2s seconds and save to directory Bler_MCS


    Verify That Throughput Is Reached On Specific Cells    ue_id=2    cells_list=${PCell_id}
    ...    expected_throughput=100Mbps    direction=ul    margin=5%    selection_type=Maximum
    Verify DL throughput in SA mode on SCell-0,1,2,3 is about 110Mbps for NR-UE2
    Stop data traffic for UE
    Convert TTI Traces

    Verify if csi rs is present after scell activation   expected_csi_rs_config=3.0   cell_id=53   directory=pCSI_BM_reported_in_a_bundle
    Verify if csi rs is present after scell activation   expected_csi_rs_config=4.0   cell_id=54   directory=pCSI_BM_reported_in_a_bundle
    Verify if csi rs is present after scell activation   expected_csi_rs_config=4.0   cell_id=55   directory=pCSI_BM_reported_in_a_bundle
    Verify if csi rs is present after scell activation   expected_csi_rs_config=4.0   cell_id=56   directory=pCSI_BM_reported_in_a_bundle
    Verify if pCSI and beam report are reported in a bundle for TDD scell    cell_id=54   directory=pCSI_BM_reported_in_a_bundle
    Verify if pCSI and beam report are reported in a bundle for TDD scell    cell_id=55   directory=pCSI_BM_reported_in_a_bundle
    Verify if pCSI and beam report are reported in a bundle for TDD scell    cell_id=56   directory=pCSI_BM_reported_in_a_bundle
    Verify if pCSI is reported either on PUCCH or multiplexed with ULSCH on PUSCH  pcell=54  scells=53,55,56   directory=pCSI_BM_reported_in_a_bundle

    Verify if beam has changed    directory=beam_switch



    Verify if pCSI and beam report are reported in a bundle for TDD scell    cell_id=54   directory=Bler_MCS
    Verify if pCSI and beam report are reported in a bundle for TDD scell    cell_id=55   directory=Bler_MCS
    Verify if pCSI and beam report are reported in a bundle for TDD scell    cell_id=56   directory=Bler_MCS
    Verify if pCSI is reported either on PUCCH or multiplexed with ULSCH on PUSCH    pcell=54    scells=53,55,56   directory=Bler_MCS


    [Teardown]  Run keywords
    ...    Stop data traffic for UE
    ...    AND    Deactivate and remove UE beam control testmodes for NR-UE2
    ...    AND    Deactivate and remove UE bler testmodes for NR-UE2
    ...    AND    Release UE    ue_id=2    pdu_id=2

*** Keywords ***
Verify DL throughput in SA mode on SCell-0,1,2,3 is over 500Mbps for NR-UE${UE_ID}
    Execute Egate Command And Wait For Data
    ...          cmd=ue_stats_nr id=${UE_ID} type=pdsch scell=0-3
    ...          pass_regexp=(4[\\s]cells[\\s]{6}[5-8][0-9][0-9].*\\n){1}

Verify DL throughput in SA mode on SCell-0,1,2,3 is about 110Mbps for NR-UE${UE_ID}
    Execute Egate Command And Wait For Data
    ...          cmd=ue_stats_nr id=${UE_ID} type=pdsch scell=0-3
    ...          pass_regexp=(4[\\s]cells[\\s]{6}.*(1[0-4][0-9]|[89][0-9]).*\\n){1}

Stop data traffic for UE
    Execute Egate Command
    ...          cmd=trf_data_stop ue=2 pdu=2 qfi=1 dir=bi trf_id=1-21

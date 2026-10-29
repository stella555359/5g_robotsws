*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    NoResUsage
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation   :copyright: Nokia
...             :author: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/logging.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/tshark_verifying.robot
Resource    feature_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/traffic.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/L3_Call.robot

Library     KeywordsCB008717.py
Library     ta5g_file_system
Library     ta5g_testline_management
Library     ta5g_enb
Library     ta5g_iphy
Library     ute_wtssim
Library     ta5g_ue_mobility
Library     testsuite/Wroclaw/RRM/resources/airphone/wro_2/resources/CplaneOverloadSetter.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py

Suite Setup    Run Keywords
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}

Suite Teardown    Compress Test Logs

Test Teardown      Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
...    AND         Find Errors
...    AND         Add Scout Scf Id To Test Data
...    AND         Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...    AND         Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...    AND         Collect Selected Debug Files
...                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...                omit_collectors=sos_report

*** Variables ***
${IPHY_FK}=                ${CURDIR}/config/CB008717_K/iphy_n78_n257_8CC_BOO_LOO.xml
${SCFC_FK}=                scfc_FK_n78A_n257M_BOO_LOO.xml
${cfg_FK}=                 ${CURDIR}/config/CB008717_FK/cfg_FK_n78A_n257M.cfg
${IPHY_K_B21a}=            ${CURDIR}/config/CB008717_K/iphy_n1A_n257M_8CC_BOLO.xml
${SCFC_K_B21a}=            scfc_K_B21a.xml
${cfg_K_B21a}=             ${CURDIR}/config/CB008717_K/FDD_n1A_n257M_K_B21a.cfg
${IPHY_K_B3a}=             ${CURDIR}/config/CB008717_K/iphy_n78_n257_8CC_BOO_LOO.xml
${SCFC_K_B3a}=             scfc_K_B3a_n78A_n257M_BOO_LOO.xml
${cfg_K_B3a}=              ${CURDIR}/config/CB008717_K/TDD_n78A_n257M_K_B3a.cfg
${IPHY_JB}=                ${CURDIR}/config/CB008717_K/iphy_n1A_n257M_8CC_BOLO.xml
${SCFC_JB}=                scfc_n78A_n257I_JB_B7a.xml
${cfg_JB}=                 ${CURDIR}/config/CB008717_K/FDD_n1A_n257M_K_B21a.cfg
${ue_id}=                  1
${gnb_id}=                 2
${amf_id}=                 1
${capabilityRequestFilter_hex_n1_n257}=     '0x800C00082000'
${capabilityRequestFilter_hex_n78_n257}=    '0x800C04D82000'
${Cplane_overload_state_enabled}=           f1ap.uACReductionIndication == 100
@{FAULT_IDS}=                               6450    4383

*** Test Cases ***
CB008717_FK_B1a_ALT1_NR-DC_Bearer_Takeback_Triggered_Due_To_Deletion_of_Non-Last_QoS_Flow_in_PDU_Session_with_aCSI_on_PCell_With_Dynamic_BetaOffsets
    [Documentation]    :copyright: Nokia
    ...                :author: Joanna Kutrowska-Girzycka
    ...                :contact: joanna.kutrowska-girzycka@nokia.com

    [Setup]            Run Keywords    Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND         Prepare Test Setup For One Real Gnb And Enable Tshark Verification CB008717    FK
    ...    AND         Setup devices aliases
    ...    AND         Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Reach Onair    lua_cfg=${cfg_FK}
    ...    AND         Enforce Protocol    nr-rrc

    Set expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1 with 2-DRB & 9*UECtxMod
    Attach Ue    ue_id=1
    Set Scg UL Dist Percent
    Set Internal Traffic Type To UE    ue_id=1    pdu_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Trigger PDU Session Modify Procedure By Addition of QoS Flow
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition for UE1, gNB2 and AMF1 with 2-DRB & 9*UECtxMod
    Verify that PDU session is established with one QoS flow
    Verify successful addition od second QoS flow
    Verify successful A4-based NR-DC etsablishment with FR2 8CC CA
    Verify correct traffic distribution
    Verify successful NR-DC takeback by deletion of second QoSflow
    Verify correct traffic distribution after NR-DC takeback
    Verify that UE was not released for 60 seconds    ue_id=1

CB008717_K_B2.1a_Unsuccessful_SCell_Addition_For_FR2_PSCell_During_NR-DC_Establishment_SCells_All_Are_Failed_To_The_Admission_Control_On_gNB_CU_Main
    [Documentation]    :copyright: Nokia
    ...                :authors: Marta Klukas
    ...                :contact: marta.klukas@nokia.com

    [Setup]            Run Keywords    Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND         Reset Wts
    ...    AND         Wait For Environment To Be Ready
    ...    AND         Prepare Test Setup For One Real Gnb And Enable Tshark Verification CB008717    K_B21a
    ...    AND         Setup devices aliases
    ...    AND         Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Reach Onair    lua_cfg=${cfg_K_B21a}
    ...    AND         Enforce Protocol    nr-rrc

    Set expected messages flows for A4 measurement based PSCell addition

    Attach UE And Establish PDU Session    ue_id=1    cell_id=1    enb_id=2    gw_id=1
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n1, band:n257
    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify Succesful NRDC and SCell Addition for 8CC for UE1
    Attach UE And Establish PDU Session    ue_id=2    cell_id=1    enb_id=2    gw_id=2
    Verify that UECapabilityEnquiry was completed successfully for UE2 and band:n1, band:n257
    UE2 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected messages flows for A4 measurement based PSCell addition
    Verify Succesful NRDC and Unsuccesful SCell Addition for UE2

CB008717_K_B3a_ALT2_Co-ordination_Of_UE_Capabilities_Between_MCG_And_SCG_in_NR-DC
    [Documentation]    :copyright: Nokia
    ...                :authors: Maciej Grzeszczak
    ...                :contact: dominik.chalupczynski@nokia.com

    [Setup]            Run Keywords    Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND         Reset Wts
    ...    AND         Wait For Environment To Be Ready
    ...    AND         Prepare Test Setup For One Real Gnb And Enable Tshark Verification CB008717    K_B3a
    ...    AND         Setup devices aliases
    ...    AND         Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Reach Onair    lua_cfg=${cfg_K_B3a}
    ...    AND         Enforce Protocol    nr-rrc

    Set expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod

    Attach Ue    ue_id=1
    Set Scg UL Dist Percent
    Establish Pdu Session With Traffic    ue_id=1    pdu_id=1    gw_id=1

    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions with only non-GBR QoS flows
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n78, band:n257

    UE1 sends A4 measurement id=1 for NR-DC PSCell addition
    Verify expected A4 measurement based PSCell addition messages flows for UE1, gNB2, AMF1 & 6*UECtxMod

    Verify that BearerCtxModReq_2 out of 3 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for SN context
    Verify that BearerCtxModResp_2 out of 3 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for SN context

    Verify that UECtxSetupReq_2 out of 2 was send for 7-SCells with 1 DRB, BandCombIdx=1 for gNB2

    Verify that UECtxSetupResp_2 out of 2 with 1 DRB, BandCombIdx=1, 4-SCells, MIMO-2 for gNB2
    Verify that UECtxSetupResp_2 out of 2 has sCellFailedTBStpList with 3 elements for gNB2 with start NRCellID-16391

    Verify that BearerCtxModReq_3 out of 3 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for MN context
    Verify that BearerCtxModResp_3 out of 3 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for MN context

    Verify that UECtxModReq_5 out of 6 was completed with BandCombinationIndex=1, allowedFeatureSetsList=1 for gNB2
    Verify that UECtxModResp_5 out of 6 that 2 MIMO in UL and 2 MIMO in DL for gNB2

    Verify that RRCReconfiguration_3 out of 3 was completed for gNB2, UE1, 4-SCells, 2-MIMO and 1 DRB

    Send Data Traffic In Direction    ue_id=1    pdu_id=1    dir=dl    mbps=160
    Send Data Traffic In Direction    ue_id=1    pdu_id=1   dir=ul    mbps=28
    Verify That Throughput Is Reached On Cell Group    ue_id=1    expected_throughput=30     cell_index_min=0
        ...       direction=dl    cell_group=MCG    selection_type=average    margin=50%
    Verify That Throughput Is Reached On Cell Group    ue_id=1    expected_throughput=30     cell_index_min=0
        ...       direction=ul    cell_group=MCG    selection_type=average    margin=50%
    Verify That Throughput Is Reached On Cell Group    ue_id=1    expected_throughput=30   cell_index_min=1
        ...    cell_index_max=4    direction=dl    cell_group=SCG    selection_type=average    margin=50%
    Verify That Throughput Is Reached On Cell Group    ue_id=1    expected_throughput=30    cell_index_min=1
        ...    cell_index_max=1    direction=ul    cell_group=SCG    selection_type=average    margin=50%

    [Teardown]    Run Keywords    Deregister Ue    ue_id=1
    ...    AND                    Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND                    Find Errors
    ...    AND                    Add Scout Scf Id To Test Data
    ...    AND                    Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND                    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND                    Collect Selected Debug Files
    ...                           output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                           omit_collectors=sos_report

CB008717-JB_B7a_Restart_a4RetryTimer_when_a4RetryTimer_expires_while_gNB_is_overloaded
    [Documentation]    :copyright: Nokia
    ...                :authors: Edyta Rudnik
    ...                :contact: edyta.rudnik@nokia.com

    [Setup]            Run Keywords    Backup And Modify Swconfig File    parameters_list=@{8717_SWCONFIG_FLAGS_overload}
    ...    AND         Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND         Reset Wts
    ...    AND         Wait For Environment To Be Ready
    ...    AND         Prepare Test Setup For One Real Gnb And Enable Tshark Verification CB008717    JB
    ...    AND         Setup devices aliases
    ...    AND         Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Reach Onair    lua_cfg=${cfg_JB}
    ...    AND         Enforce Protocol    nr-rrc

    Set expected messages flow for A4 measurement configuration and deconfiguration for UE1, gNB2, AMF1
    Attach Ue    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Wait Until Supervision Timer Expires And Check A4 Meas Is Deconfigured
    Set Overload High Threshold to 0 for ABIO 1
    Set Overload High Threshold to 0 for ABIO 2
    Verify expected messages flow for A4 measurement configuration and deconfiguration for UE1, gNB2, AMF1
    Verify CPlane Overload State Enabled    ${Cplane_overload_state_enabled}
    Set expected messages flow for A4 measurement configuration for UE1, gNB2, AMF1
    Dectivate GNB C-plane Overloaded State
    Deregister UE    ue_id=1
    Verify expected messages flow for A4 measurement configuration for UE1, gNB2, AMF1
    Verify A4 measurement report configuration in UECtxtModReq_1 out of 2 for gNB2
    Verify in UECtxtModReq_1 out of 2 that freq n1 is present
    Verify in UECtxtModReq_1 out of 2 that freq n257 is present
    Verify in UECtxtModReq_1 out of 2 that measID 2 is present
    Verify in UECtxModResp_1 out of 2 that measGapConfigIE is present for gNB2
    Verify in RRCReconfig_1 out of 1 if A4 report id 1 configured for measObjId 2 and measId 2
    Verify in UECtxModReq_2 out of 2 that GNB-DUConfigurationQuery is set to true for gNB2
    [Teardown]         Run Keywords
    ...                Verify If Admin Faults Are Down    fault_id_list=${FAULT_IDS}
    ...    AND         Find Errors
    ...    AND         Add Scout Scf Id To Test Data
    ...    AND         Set Overload High Threshold to 20 for ABIO 1
    ...    AND         Set Overload High Threshold to 20 for ABIO 2
    ...    AND         Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Collect Selected Debug Files
    ...                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                omit_collectors=sos_report

*** Keywords ***
#FK
Verify that PDU session is established with one QoS flow
    Verify that AMF1 NGAP InitialContextSetup does not contain UERadioCapability
    Verify that AMF1 NGAP InitialContextSetup contains 1 PDU sessions with only non-GBR QoS flows
    Verify that UECapabilityEnquiry was completed successfully for UE1 and band:n78, band:n257
    Verify that RRCReconfiguration_1 out of 4 was sent for band n78, UE1, 1 DRB, aperCSi and dynamic betaOffsets
    Verify that RRCReconfigurationcomplete_1 out of 4 was send for UE1 in step-by-step message flow
    Verify that BearerCtxSetupReq_1 out of 1 was sent with setup of first DRB for gNB2
    Verify that BearerCtxSetupResp_1 out of 1 was sent with setup of first DRB for gNB2
    Verify that RRCReconfiguration_2 out of 4 was completed for band n257 and UE1
    Verify that RRCReconfigurationcomplete_2 out of 4 was send for UE1 in step-by-step message flow

Verify successful addition od second QoS flow
    Verify that AMF1 PDUSessionResModReq_1 out of 1 was sent with pDUSessionID=1 with fiveQI=5
    Verify that BearerCtxModReq_2 out of 5 was sent with setup of second DRB for gNB2
    Verify that BearerCtxModResp_2 out of 5 was sent with setup of second DRB for gNB2
    Verify that AMF1 PDUSessionResModResp_1 out of 1 was sent with pDUSessionID=1

Verify successful A4-based NR-DC etsablishment with FR2 8CC CA
    Verify that BearerCtxModReq_4 out of 5 for PDU-Session-ID-1 with 2 DRB was success for gNB2 for SN context
    Verify that BearerCtxModResp_4 out of 5 for PDU-Session-ID-1 with 2 DRB was success for gNB2 for SN context
    Verify that UECtxSetupReq_2 out of 2 was send for 7-SCells with 2 DRB, BandCombIdx=1 for gNB2
    Verify that UECtxSetupResp_2 out of 2 with 2 DRB, BandCombIdx=1, 7-SCells, MIMO-2 for gNB2
    Verify that BearerCtxModReq_5 out of 5 for PDU-Session-ID-1 with 2 DRB was success for gNB2 for MN context
    Verify that BearerCtxModResp_5 out of 5 for PDU-Session-ID-1 with 2 DRB was success for gNB2 for MN context
    Verify that UECtxModReq_8 out of 9 was completed with BandCombinationIndex=1, allowedFeatureSetsList=1 for gNB2
    Verify that UECtxModResp_8 out of 9 was completed succesfully for gNB2 for aperCSI and semiStatic betaOffsets
    Verify that RRCReconfiguration_4 out of 4 was sent for UE1 7-SCells 2-DRBs aperCSI release semiStatic betaOffsets
    Verify that RRCReconfigurationComplete_4 out of 4 for UE1 that message contains nr-SCG response

Verify correct traffic distribution
    Send Data Traffic In Direction    ue_id=1   pdu_id=1    dir=dl    mbps=160
    Send Data Traffic In Direction    ue_id=1   pdu_id=1    dir=ul    mbps=28
    Verify That Throughput Is Reached On Cell Group    ue_id=1    expected_throughput=1     cell_index_min=0
        ...       direction=dl    cell_group=MCG    selection_type=minimum    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=1    expected_throughput=1     cell_index_min=0
        ...       direction=ul    cell_group=MCG    selection_type=minimum    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=1    expected_throughput=1     cell_index_min=1
        ...    cell_index_max=8    direction=dl    cell_group=SCG    selection_type=minimum
    Verify That Throughput Is Reached On Cell Group    ue_id=1    expected_throughput=1    cell_index_min=1
        ...    cell_index_max=1    direction=ul    cell_group=SCG    selection_type=minimum

Verify successful NR-DC takeback by deletion of second QoSflow
    Successfull NR-DC Takeback By Deletion of QoS Flow    UeCtxModReq_id=9
    Verify in PDUSessionResModReq that PDUSessionResourceModifyRequestTransfer contains cause:unspecified
    Verify that UECtxModReq_1 out of 1 was send to stop UL and DL DRB data transmission for gNB2 for SN
    Verify that UECtxModResp_1 out of 1 was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify that BearerCtxModReq_1 out of 4 for pDUSessionID=1 with 2 DRBs were send for gNB2 for MN
    Verify that BearerCtxModResp_1 out of 4 for pDUSessionID=1 with 2 DRBs were send for gNB2 for MN
    Verify that UECtxModReq_1 out of 4 was send with adjustment of MCG configuration upon SCG release for the UE1 for MN
    Verify that UECtxModResp_1 out of 4 was sent with modification of MCG for the UE1 for MN with aperCSI and dynamic betaOffsets
    Verify that RRCReconfiguration_1 out of 1 was sent for UE1 for 2-DRBs with aperCSI and dynamic betaOffsets
    Verify that RRCReconfigurationComplete_1 out of 1 was send for UE1
    Verify that UECtxModReq_2 out of 4 was send with request to provide full MCG configuration for gNB2 for MN
    Verify that UECtxModResp_2 out of 4 was send with confirmation of MCG reconfiguration for gNB2 for MN
    Verify that BearerCtxModReq_2 out of 4 was send to release SCG leg with CellGroupID=1 for 2-DRBs for gNB2 for MN
    Verify that BearerCtxModResp_2 out of 4 was send with SCG leg deletion for 2-DRBs for gNB2 for MN
    Verify that UECtxReleaseCommand_1 out of 1 was send with cause:radioNetwork:normal-release for gNB2
    Verify that UECtxReleaseComplete_1 out of 1 was send with confirmation of SCG context deletion for gNB2
    Verify that PDUSessionResModResp was send with pDUSessionID=1

Verify correct traffic distribution after NR-DC takeback
    Verify That Throughput Is Reached On Cell Group    ue_id=1    expected_throughput=100    cell_index_min=0
        ...       direction=dl    cell_group=MCG    selection_type=average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=1    expected_throughput=10      cell_index_min=0
        ...       direction=ul    cell_group=MCG    selection_type=average    margin=10%

Trigger PDU Session Modify Procedure By Addition of QoS Flow
    [Arguments]     ${ue_id}=1     ${qosflows}=3
    Wait For Data
    Execute Egate Command     cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosflows}
    Wait For Data

Trigger PDU Session Modify Procedure By Deletion of QoS Flow
    [Arguments]     ${ue_id}=1     ${qosflows}=3
    Wait For Data
    Execute Egate Command     cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qosflows}
    Wait For Data

Wait For Data
    Sleep    3s

#K_B21a
Set expected messages flows for A4 measurement based PSCell addition
    Set expected message flow    timeout=60     ueCapaEnq=1    ueCapaInfo=1    bearerCtxSet=2    bearerCtxMod=6    uECtxSet=4    uECtxMod=18
        ...    rrcReconf=3    rrcReconfCompl=3
    Set expected message flow    ue_id=2    timeout=60     ueCapaEnq=1    ueCapaInfo=1    rrcReconf=3    rrcReconfCompl=3

Verify expected messages flows for A4 measurement based PSCell addition
    Verify expected message flow    timeout=60     ueCapaEnq=1    ueCapaInfo=1    bearerCtxSet=2    bearerCtxMod=6    uECtxSet=4    uECtxMod=18
        ...    rrcReconf=3    rrcReconfCompl=3
    Verify expected message flow    ue_id=2    timeout=60     ueCapaEnq=1    ueCapaInfo=1    rrcReconf=3    rrcReconfCompl=3

Verify Succesful NRDC and SCell Addition for 8CC for UE1
    Verify that UECtxSetupResp_2 out of 4 with 1 DRB, BandCombIdx=3, 7-SCells, MIMO-2 for gNB2
    Verify that RRCReconfiguration_3 out of 3 was completed for gNB2, UE1, 7-SCells, 2-MIMO and 1 DRB

Verify Succesful NRDC and Unsuccesful SCell Addition for UE2
    Verify that UECtxSetupReq_4 out of 4 is with expected content for PSCELL and no SCells for gNB2 with 1 DRB
    Verify that UECtxSetupResp_4 out of 4 for 1 PDU session has 1 DRB and no SCells for gNB2
    Verify that BearerCtxModReq_6 out of 6 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for MN context
    Verify that BearerCtxModResp_6 out of 6 for PDU-Session-ID-1 with 1 DRB was success for gNB2 for MN context
    Verify that UECtxModReq_14 out of 18 was completed with BandCombinationIndex=3, allowedFeatureSetsList=1 for gNB2
    Verify that UECtxModResp_14 out of 18 that 2 MIMO in UL and 2 MIMO in DL for gNB2
    Verify that RRCReconfiguration_3 out of 3 was completed for gNB2 and UE2 and 0-SCells and 1 DRB

#JB_B7a
Wait Until Supervision Timer Expires And Check A4 Meas Is Deconfigured
    Wait One A4Supervisiontimer Cycle
    Verify in RRCReconfiguration_3 out of 4 for UE1 that A4 measurement related to measid-1 is removed

Activate GNB C-plane Overloaded State
    Find Scfc and Send Delta Commissioning    scfc_filename=activate_overload.json
    Wait One A4retrytimer Cycle

Dectivate GNB C-plane Overloaded State
    Find Scfc and Send Delta Commissioning    scfc_filename=deactivate_overload.json    skip_relation_errors=True
    Wait One A4retrytimer Cycle

Wait One A4retrytimer Cycle
    Sleep    60s

Wait One A4Supervisiontimer Cycle
    Sleep    10s

Verify CPlane Overload State Enabled
    [Arguments]    ${Cplane_overload_state}
    Verify Tcpdump Log    packet_filter=${Cplane_overload_state}    number_of_messages=0  relation_symbol= >

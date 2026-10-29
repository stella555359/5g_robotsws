*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BLLL_AP_LOO    VARIANT_PRIVATE_SANSA_FS_ECPRI_CMWV_FDD_2CELLS
    ...    NoResUsage

Documentation    :copyright: Nokia

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     ../keywords/tshark_verifying.robot
Resource     ../keywords/logging.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_pm_counters
Resource     feature_keywords.robot
Variables    testsuite/Wroclaw/RRM/resources/airphone/tshark_filters/ngap.py
Variables    testsuite/Wroclaw/RRM/resources/airphone/tshark_filters/f1ap.py

Suite Setup     With Retry Context    3
...                                   Custom Setup

*** Variables ***
@{SWCONFIG_FLAGS_LIST}=         ${DISABLE_HWF_READING}    ${rdMergedMeasGapSetupAndDrxRelease}
${rdMergedMeasGapSetupAndDrxRelease}=        0x890046=1 # rdMergedMeasGapSetupAndDrxRelease
${DISABLE_HWF_READING}=         0x4F0214=0 #DISABLE HWFREADING
${LOGGING_POLICY}=    BASIC_POLICY
${5GC001167_A_b_CONFIG_DIRECTION}=       ${CURDIR}/config/5GC001167-A3/5GC001167_A3_b_Succesfull_3CC_CA_PCell_2L_MIMO_and_SCells_4L_MIMO
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=               f1ap.SCell_ToBeSetupMod_List == 2
${F1AP_SCELL_TO_ADD_MOD_LIST}=                    nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 51 && nr-rrc.physCellId == 52
${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE}=      ngap.pDUSessionResourceModifyResponseTransfer && ngap.qosFlowIdentifier == 1
${F1AP_SCELL_MAXMIMOLAYER_CONFIG}=    nr-rrc.sCellToAddModList&&nr-rrc.physCellId==51&&nr-rrc.physCellId==52
    ...                               &&nr-rrc.maxMIMO_Layers==4&&!nr-rrc.maxMIMO_Layers==2


*** Test Cases ***
5GC001167_A3_b_and_E_a_Succesfull_3CC_CA_PCell_2L_MIMO_and_SCells_4L_MIMO_with_PM_counters_check
    [Setup]    Run Keywords    Wait For Next Full Pm Interval
    ...        AND             Enable Tshark Verification

    Attach_UE1_With_PDU_Session_Setup
    Verify_Successful_3CC_On_NGAP_And_F1AP_Messages
    Verify_MaxMIMO_Layer_Configuration
    Wait For Next Full Pm Interval
    Verify PM Counters After SCell addition

    [Teardown]    Run Keywords   Deregister Ue    ue_id=1
    ...    AND    Wait For Next Full Pm Interval
    ...    AND    Wait For Next Full Pm Interval
    ...    AND    Verify If PM Counters After Release UE Equal Zero

*** Keywords ***
Custom Setup
    With Swconfig Flags             flags=@{SWCONFIG_FLAGS_LIST}
    Update And Put Iphy Xml         input_filepath=${5GC001167_A_b_CONFIG_DIRECTION}/ap/iphy_APoABIO.xml
    Enable C-Plane Debug Logs       with_reboot=${FALSE}
    With Gnb Configuration          commissioning=fdd_3CC_n5_n66_n2_4DL_MIMO_APoABIO.xml
    With Simulator Configuration    config=${5GC001167_A_b_CONFIG_DIRECTION}/basic_fs_sa_call_fdd_cmwv_3CC_capa_poprawione_wg_miloszowych.cfg

Attach_UE1_With_PDU_Session_Setup
    Set Internal Traffic Type To UEs    ue_id=1
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1    nwslice=1

Verify_Successful_3CC_On_NGAP_And_F1AP_Messages
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}    continue_on_failure=False
    tshark_verifying.Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}        continue_on_failure=False
    tshark_verifying.Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST}             number_of_messages=3   continue_on_failure=False

Verify_MaxMIMO_Layer_Configuration
    tshark_verifying.Verify Tcpdump Log    packet_filter=${F1AP_SCELL_MAXMIMOLAYER_CONFIG}    continue_on_failure=False

Verify PM Counters After SCell Addition
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify PM Counters After SCell Addition From Cell1    pm_counter_file=${pm_counter_file}
    Verify PM Counters After SCell Addition From Cell2    pm_counter_file=${pm_counter_file}
    Verify PM Counters After SCell Addition From Cell3    pm_counter_file=${pm_counter_file}

Verify PM Counters After SCell Addition From Cell1
    [Arguments]  ${pm_counter_file}
    Verify Any Counters In File
        ...    M55138C01501    0       GNB_SCELL_1_ADMI_REQ_SA
        ...    M55138C02501    +1      GNB_SCELL_2_ADMI_REQ_SA
        ...    M55138C01502    0       GNB_SCELL_1_ADMI_SUCC_SA
        ...    M55138C02502    +1      GNB_SCELL_2_ADMI_SUCC_SA
        ...    M55138C01503    0       GNB_SCELL_ADMI_UNSUCC_SA
        ...    M55139C01003    0       GNB_DU_SCELL_1_ADMI_REQ_SA
        ...    M55139C01501    +1      GNB_DU_SCELL_2_ADMI_REQ_SA
        ...    M55139C01004    0       GNB_DU_SCELL_1_ADMI_SUCC_SA
        ...    M55139C01502    +1      GNB_DU_SCELL_2_ADMI_SUCC_SA
        ...    M55118C05505    0       RRC_RECONF_ADD1DLSCELL_ATT_SA
        ...    M55118C07004    +1      RRC_RECONF_ADD2DLSCELL_ATT_SA
        ...    M55118C05506    0       RRC_RECONF_ADD1DLSCELL_SUCC_SA
        ...    M55118C07003    +1      RRC_RECONF_ADD2DLSCELL_SUCC_SA
        ...    M55118C05507    0       UE_PCELL_1_CONF_SCELL_DL_SA
        ...    M55118C05508    0       UE_SCELL_1_CONF_SCELL_DL_SA
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

Verify PM Counters After SCell Addition From Cell2
    [Arguments]  ${pm_counter_file}
    Verify Any Counters In File
        ...    M55139C01001    +1      GNB_DU_SCELL_ADMI_REQ_SA
        ...    M55139C01002    +1      GNB_DU_SCELL_ADMI_SUCC_SA
        ...    M55138C01501    0       GNB_SCELL_1_ADMI_REQ_SA
        ...    M55138C01502    0       GNB_SCELL_1_ADMI_SUCC_SA
        ...    M55138C01503    0       GNB_SCELL_ADMI_UNSUCC_SA
        ...    M55139C01003    0       GNB_DU_SCELL_1_ADMI_REQ_SA
        ...    M55139C01004    0       GNB_DU_SCELL_1_ADMI_SUCC_SA
        ...    M55118C05505    0       RRC_RECONF_ADD1DLSCELL_ATT_SA
        ...    M55118C05506    0       RRC_RECONF_ADD1DLSCELL_SUCC_SA
        ...    M55118C05507    0       UE_PCELL_1_CONF_SCELL_DL_SA
        ...    M55118C05508    0       UE_SCELL_1_CONF_SCELL_DL_SA
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
        ...    file_path=${pm_counter_file}

Verify PM Counters After SCell Addition From Cell3
    [Arguments]  ${pm_counter_file}
    Verify Any Counters In File
        ...    M55139C01001    +1      GNB_DU_SCELL_ADMI_REQ_SA
        ...    M55139C01002    +1      GNB_DU_SCELL_ADMI_SUCC_SA
        ...    M55138C01501    0       GNB_SCELL_1_ADMI_REQ_SA  #ok
        ...    M55138C01502    0       GNB_SCELL_1_ADMI_SUCC_SA
        ...    M55138C01503    0       GNB_SCELL_ADMI_UNSUCC_SA
        ...    M55139C01003    0       GNB_DU_SCELL_1_ADMI_REQ_SA
        ...    M55139C01004    0       GNB_DU_SCELL_1_ADMI_SUCC_SA
        ...    M55118C05505    0       RRC_RECONF_ADD1DLSCELL_ATT_SA
        ...    M55118C05506    0       RRC_RECONF_ADD1DLSCELL_SUCC_SA
        ...    M55118C05507    0       UE_PCELL_1_CONF_SCELL_DL_SA
        ...    M55118C05508    0       UE_SCELL_1_CONF_SCELL_DL_SA
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
        ...    file_path=${pm_counter_file}

Verify If PM Counters After Release UE Equal Zero
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55138C02501    0      GNB_SCELL_2_ADMI_REQ_SA
        ...    M55138C02502    0      GNB_SCELL_2_ADMI_SUCC_SA
        ...    M55139C01501    0      GNB_DU_SCELL_2_ADMI_REQ_SA
        ...    M55139C01502    0      GNB_DU_SCELL_2_ADMI_SUCC_SA
        ...    M55118C07004    0      RRC_RECONF_ADD2DLSCELL_ATT_SA
        ...    M55118C07003    0      RRC_RECONF_ADD2DLSCELL_SUCC_SA
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}
    Verify Any Counters In File
        ...    M55139C01001    0      GNB_DU_SCELL_ADMI_REQ_SA
        ...    M55139C01002    0      GNB_DU_SCELL_ADMI_SUCC_SA
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
        ...    file_path=${pm_counter_file}
    Verify Any Counters In File
        ...    M55139C01001    0      GNB_DU_SCELL_ADMI_REQ_SA
        ...    M55139C01002    0      GNB_DU_SCELL_ADMI_SUCC_SA
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
        ...    file_path=${pm_counter_file}

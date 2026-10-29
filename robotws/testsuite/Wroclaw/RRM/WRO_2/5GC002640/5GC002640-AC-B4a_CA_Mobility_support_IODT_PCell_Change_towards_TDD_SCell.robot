*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource    ../5GC001167/feature_keywords.robot
Variables   ../5GC001167/feature_variables.py
Library      ta5g_delta
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      ta5g_iphy
Library      taf.ul.ettf.setups

Suite Setup       Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_H_B2a.xml
...               AND             With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}
...               AND             With Gnb Configuration    commissioning=${scfc}

*** Variables ***
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=               f1ap.SCell_ToBeSetupMod_List == 2
${F1AP_SCELL_TO_ADD_MOD_LIST}=                    nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 51 &&
                                             ...  nr-rrc.physCellId == 52
${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE}=      ngap.pDUSessionResourceModifyResponseTransfer &&
                                             ...  ngap.qosFlowIdentifier == 1
${F1AP_SCELL_MAXMIMOLAYER_CONFIGURATION}=         nr-rrc.sCellToAddModList && nr-rrc.physCellId == 51 &&
                                             ...  nr-rrc.physCellId == 52 && nr-rrc.maxMIMO_Layers == 4 &&
                                             ...  !nr-rrc.maxMIMO_Layers ==2

${F1AP_SCELL_TO_BE_REMOVED}=         ((f1ap.id == 51) && (f1ap.nRCellIdentity == 00:00:04:00:20)) &&
                                ...  (f1ap.nRCellIdentity == 00:00:04:00:30)
${F1AP_SCELL_TO_BE_RELEASE}=         ((nr-rrc.sCellToReleaseList == 2) && (nr-rrc.SCellIndex == 1)) &&
                                ...  (nr-rrc.SCellIndex == 2)

${UE_ID}=                   1
${3CC_A1_MEAS_ID}=          4
${PC_CHANGE_A1_MEAS_ID}=    5
${A1_RSRP}=                 90
${scfc}=                    scfc_H_B2a.xml
@{SWCONFIG_FLAGS_LIST}=       ${rdMergedMeasGapSetupAndDrxRelease}

*** Test Cases ***
5GC002640-AC-B4a_CA_Mobility_support_IODT_PCell_Change_towards_TDD_SCell
    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    Activate A1 PCell Switch
    Reach Onair    lua_cfg=${CURDIR}/config/config_AC_B4a.cfg
    Attach UE1 With PDU Session Setup
    Send A1 Measurement To PCell For 3CC
    Verify Successful 3CC On NGAP And F1AP Messages
    Send A1 Measurement To Trigger HO
    Verify Successful SCell Release
    [Teardown]     Run Keywords    Deregister UE   ue_id=${UE_ID}
       ...               AND       Stop Default Logging
       ...               AND       Reset Egate
       ...               AND       Roll Delta Back
       ...  initial_scf_filename=${scfc}
       ...  delta_scf_filename=delta_AC_B4a.json
       ...               AND       Stop Default Processes And Gather Logs And Compress Logs

*** Keywords ***
Activate A1 PCell Switch
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=delta_AC_B4a.json    retries=10    retry_timer=90

Attach UE1 With PDU Session Setup
    Set Internal Traffic Type To UEs    ue_id=${UE_ID}
    Attach Ue    ue_id=${UE_ID}
    Establish Pdu Session    ue_id=${UE_ID}    pdu_id=1    gw_id=1    nwslice=1

Verify Successful 3CC On NGAP And F1AP Messages
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}    continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}        continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST}             number_of_messages=3
                                                                               ...  continue_on_failure=False
Send A1 Measurement To PCell For 3CC
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${UE_ID}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${3CC_A1_MEAS_ID} srsrp_nr=${A1_RSRP} event=A1
    ...    pass_regexp=message c1 : rrcReconfigurationComplete

Send A1 Measurement To Trigger HO
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${UE_ID}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_disp id=${UE_ID} type=cell
    ...    pass_regexp=cell${SPACE*7}1
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${PC_CHANGE_A1_MEAS_ID} event=A1 scell=2 srsrp_nr=${A1_RSRP}
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-*.* to EXT_ENB-*.* performed
    Execute Egate Command And Wait For Data
    ...    cmd=ue_disp id=${UE_ID} type=cell
    ...    pass_regexp=cell${SPACE*7}3

Verify Successful SCell Release
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_REMOVED}        continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_RELEASE}        number_of_messages=2
                                                                        ...  continue_on_failure=False

Reset Egate
    Execute Egate Command    cmd=sim_reset

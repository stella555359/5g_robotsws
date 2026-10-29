*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    PY39
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: George Medesan
...              :contact: george.medesan@nokia.com


Resource          ../CB012277_keywords_and_variables.robot

Suite Setup    Run Keywords       Start Default Logging         output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...    AND                        Get Scfc File    output_filepath=/home/ute/initial_commissioning.xml
...    AND                        Run    ${VM_ETH_IFACES}
...    AND                        Get Iphy Xml File    output_filepath=${CURDIR}/config/backup/new_iphy.xml
...    AND                        Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/iphy.xml
...    AND                        Find Scfc and Send Delta Commissioning    scfc_filename=Delta_Configuration_scf_CB012277_A_B4.json
...    AND                        Reset Testline
...    AND                        Check Radios Availability
...    AND                        Reach Onair    lua_cfg=${CURDIR}/config/egate_CB012277_A_B4.lua
...    AND                        Setup X2 Link    initiator_device=1     complementary_device=3
...    AND                        Stop Default Logging     output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup       Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Send Full Commissioning    input_filepath=/home/ute/initial_commissioning.xml

*** Variables ***

${filter}      x2ap.SgNBChangeRequired_element && nr-rrc.cgi_Info_element && nr-rrc.PLMN_Identity_element &&
        ...    nr-rrc.cellIdentity && nr-rrc.cellReservedForOperatorUse

${MEAS_GAP_RELEASE}=    x2ap.SgNBModificationRequest_element && nr-rrc.measGapConfig == 0
${DRX_SETUP}=    x2ap.SgNBModificationRequired_element && nr-rrc.drx_Config == 1
${EXPECTED_NRADJNRCELL_OBJECTID}=    12288
${FAILED_HO_REGEXP}=    Bearer-type change from SCG-split to MCG is successful
${SUCCESSFUL_HO_REGEXP}=    Proxy \\(eNB 2 cell 2\\) reported successful RA

*** Test Cases ***
TC07_CB012277_A_B4_Inter_Frequency_inter_en_gNB_PSCell_change_with_CGI_provisioning_with_ANR_for_NSA_Opt_3x
    [Documentation]
    ...    This user scenario describes the cgi-Info provisioning in the successful Inter-Frequency inter en-gNB PSCell change
    ...    preparation and execution of a NSA call from a source en-gNB to a target en-gNB
    ...    when Intra-NR Inter-Frequency UE based ANR for EN-DC is enabled

    Turn Off Drx And Turn On Measurement Gap On Ue    ue_id=${UE_ID_A_B4}
    Attach Ue To Enb                 ue_id=${UE_ID_A_B4}
    Start Gnb Addition Procedure     ue=${UE_ID_A_B4}    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                              pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Send Custom Ue Measurement Nr    id=${UE_ID_A_B4}    meas_id=1    event=A2    srsrp_nr=30
    ...                              pass_regexp=Sending SgNB Modification Confirm
    Send Custom Ue Measurement Nr    id=${UE_ID_A_B4}    meas_id=4    event=A5    srsrp_nr=19    phycell_id=52    nrsrp_nr=68
    ...                              pass_regexp=Proxy \\(eNB 3 cell 1\\) reported successful RA
    Verify Tcpdump Log               packet_filter=${filter}
    Verify Ngap Messages             packet_filter=${MEAS_GAP_RELEASE}
    Verify Ngap Messages             packet_filter=${DRX_SETUP}    number_of_messages=1    relation_symbol=>=
    Verify Existing NRREL
    Wait For Object To Exist    object_name=NRADJNRCELL_A-${EXPECTED_NRADJNRCELL_OBJECTID}    moc=NRADJNRCELL_A
    ...                         timeout=${NRREL_OBJECT_CREATION_TIME}

    [Teardown]    Run Keywords      Detach Ue    ue_id=${UE_ID_A_B4}
    ...           AND               Find Scfc and Send Delta Commissioning    scfc_filename=delta_remove_NRREL.json
    ...           AND               Find Scfc and Send Delta Commissioning    scfc_filename=delta_remove_NRADJNRCELL.json
    ...           AND               Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/backup/new_iphy.xml
    ...           AND               Stop Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Settings ***
Documentation     These are feature specific keywords

Library         BuiltIn
Library         String
Library         Collections
Library         OperatingSystem
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         ute_fsmaccess
Library         ta5g_pm_counters
Library         taf.analyzer.pcap    WITH NAME    cap
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${VLAN_ID}               ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}        MRBTS-1
${vlanif_distname}       ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${DeltaConfigDir}        ${CURDIR}/../../config/gnb_scf/
${APConfigDir}           ${CURDIR}/../../config/ap_iphy/
${TOPOLOGY}     		 CLOUD_5G_I_LO_AP_LO
${AP_CONFIG_BASIC}       ${CURDIR}/../../config/wts


*** Keywords ***
CB009215 Backup TL Config
    [Documentation]    This Keyword is to backup gNB SCF, AP iphy.xml and gNB swconfig file
    ...     Modified Date:  13-September-2023
    ...     Last Modified by:   tom.toby@nokia.com
    Get Swconfig File From GNB      ${OUTPUT_DIR}
    Backup Scf      ${OUTPUT_DIR}       gNB
    Get IPHY File From AP       ${OUTPUT_DIR}

CB009215 Restore TL Config
    [Documentation]    This Keyword is to restore gNB SCF, AP iphy.xml and gNB swconfig file
    ...     Modified Date:  13-September-2023
    ...     Last Modified by:   tom.toby@nokia.com
    Send Swconfig File To GNB        ${OUTPUT_DIR}/swconfig_gnb.txt
    Full Commision scf and iphy      ${OUTPUT_DIR}/SCF_gNB.xml      ${OUTPUT_DIR}/iphy.xml

CB009215-IA MeNB configured measurement gap setup
    [Documentation]    This Keyword is to register multiple NSA UEs with MeNB configured measurement gap setup
    ...     during SgNB modification procedure
    ...     Modified Date:  13-September-2023
    ...     Last Modified by:   tom.toby@nokia.com
    [Arguments]             ${UE_ID}=${UE_ID}    ${measurement_gap}=${measurement_gap}  ${mgta}=${mgta}
    ...     ${gap_purpose}=${gap_purpose}   ${drx_config}=${drx_config}
    log to console                              Starting MeNB configured measurement gap setup for UE: ${UE_ID}
    ${measID}   Display Measurement Configuration for UE    ${UE_ID}  A2
    Sleep   5s
    NSA Inter Frequency Intra gNB HO With Measurement Gap   ${UE_ID}  ${measID}     ${measurement_gap}
    ...     ${mgta}     ${gap_purpose}       ${drx_config}
    Sleep   10s
    ${measID}   Display Measurement Configuration for UE    ${UE_ID}  A3
    Sleep   5s
    NSA Inter Frequency A3 measurement  ${UE_ID}  ${measID}   53
    Sleep   10s

NSA Inter Frequency Intra gNB HO With Measurement Gap
    [Documentation]    This Keyword is to trigger NSA Inter Frequency Intra gNB HO with measurement gap arguments
    ...     Modified Date:  13-September-2023
    ...     Last Modified by:   tom.toby@nokia.com
    [Arguments]     ${ue_id}=${ue_id}    ${meas_id}=${meas_id}      ${measurement_gap}=${measurement_gap}
    ...     ${mgta}=${mgta}    ${gap_purpose}=${gap_purpose}   ${drx_config}=${drx_config}
    wtsrunner.ue_enb_param      id=${ue_id}     drx_config=${drx_config}      measurement_gap=${measurement_gap}
    ...     gap_trigger=gnb_triggered   mgta=${mgta}    gap_purpose=${gap_purpose}
    wtsrunner.ue_measurement_send_nr    event=A2    id=${ue_id}     meas_id=${meas_id}     rs_type=ssb      srsrp_nr=30
    Sleep   10s
    wtsrunner.ue_enb_param      id=${ue_id}      drx_config=${drx_config}     measurement_gap=off
    ...     mgta=${mgta}        gap_purpose=${gap_purpose}
    Sleep   10s
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=${NSA_HO_IAFR_Pattern_Check}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    SgNB Modification Confirm   partial_match=${TRUE}
    Log to Console    ${output}

Get physCellId value
   [Documentation]      this keyword helps to get "nr-rrc.physCellId" from the pcap file
    ...                  Modified Date:  13-September-2023
    ...                  Last Modified by:   tom.toby@nokia.com
    [Arguments]          ${pcap_file}
    ${CellId}          Get Fields from Pcap     ${pcap_file}        ((f1ap.procedureCode == 7) && (nr-rrc.reestablishRLC == 0))
    ...                        nr-rrc.physCellId
    [return]             ${CellId}

Full Commision scf and iphy
    [Documentation]    This keyword is used to change SCF and IPHY file
    [Arguments]    ${scf}=${EMPTY}       ${iphy}=${EMPTY}
    Run Keyword If    '${iphy}' != '${EMPTY}'    Update And Put Iphy XML
    ...      input_filepath=${iphy}
    Run Keyword If    '${scf}' != '${EMPTY}'     Full Commission With SCF File For UTE
    ...    ${scf}

Register Multiple NSA UEs
    [Arguments]             ${Start_UE}     ${End_UE}      ${Target_Cells}
    [Documentation]    This Keyword is to register multiple NSA UEs and start ENDC
    ...                Modified Date: 13-September-2023
    ...                Last Modified by: tom.toby@nokia.com
    ${End_UE}=    Evaluate   ${End_UE}+1
    FOR    ${UE_ID}    IN RANGE    ${Start_UE}     ${End_UE}
        Log to Console  	\n  Starting UE attach for UE: ${UE_ID} \n
        LTE Attach should be Successful for NSA     ${UE_ID}
        sleep   5s
        UE Attach should be Successful for NSA      ${UE_ID}   ${Target_Cells}
        sleep   5s
        Traffic should be Successful for NSA    ${UE_ID}  50   20
        sim log set
    END

Make SA calls to all the cells
    [Arguments]    ${UEID}=${UEID}    ${gw_ID}=${gw_ID}
    [Documentation]    This keyword shall register UE and establish GBR and Non-GBR data calls
    Start pcap collection in gNB CU     gnbTcpdump_UE ${UE_ID}
    Enable Internal TG   ${UEID}      1
    wtsrunner.ue_register   id=${UEID}
    sleep   20s
    wtsrunner.ue_pdu_session_setup    pdu=1    ue=${UEID}   nwslice=1   gw=${gw_ID}
    Sleep   10s
    Pass Lua File       ${LUA_FILE}
    wtsrunner.ue_deregister    id=${UE_ID}    ue_deregister_type=switch_off
    Stop pcap collection in gNB     gnbTcpdump_UE ${UE_ID}      ${Log_Path}

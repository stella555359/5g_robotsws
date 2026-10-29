*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta5g_testline_management
Library      ta5g_tshark
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library      ta5g_iphy
Library      ta5g_enb
Library      taf.transport.ssh           WITH NAME    taf_ssh
Library      taf.sw.scout    WITH NAME     scout
Library      ute_wtssim
Library      OperatingSystem
Library      taf.sbts.oam.coam.admin    WITH NAME   coam

*** Variable ***
${MAXIMUM_DATA_RATE}=    ngap.MaximumIntegrityProtectedDataRate == 1
${64KBPS_UE_RATE}=    ngap.MaximumIntegrityProtectedDataRate == 0

${INTEGRITY_PROTECTION_INDICATION_PREFERRED}=    ngap.integrityProtectionIndication == 1
${ICS_PREFERRED_MAXIMUM_UE_RATE}=    ${NGAP_INITIAL_CONTEXT_SETUP_REQUEST}
...                                  && ${MAXIMUM_DATA_RATE} && ${INTEGRITY_PROTECTION_INDICATION_PREFERRED}
${PDU_SESSION_RESOURCE_SETUP_REQUEST_PREFERRED_MAXIMUM_UE_RATE}=    ${NGAP_PDU_SESSION_RESOURCE_SETUP_REQUEST}
...                                                                 && ${MAXIMUM_DATA_RATE} && ${INTEGRITY_PROTECTION_INDICATION_PREFERRED}
${E1AP_BEARER_CONTEXT_MODIFICATION_REQ_NEW_UL_INFO_REQ}=    ${E1AP_BEARER_CONTEXT_MODIFICATION_REQUEST} && e1ap.New_UL_TNL_Information_Required == 0
${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_INTEGRITY_PROTECTION}=    ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST} && (nr-rrc.c1 == 0)
...                                                              && (f1ap.TransmissionActionIndicator == 0) && (nr-rrc.integrityProtection == 0)
@{CB007208_OFF_FLAG}=    0x890073=0
${ICS_PREFERRED_64KBPS_UE_RATE}=    ${NGAP_INITIAL_CONTEXT_SETUP_REQUEST}
...                                 && ${64KBPS_UE_RATE} && ${INTEGRITY_PROTECTION_INDICATION_PREFERRED}
${PDU_SESSION_RESOURCE_SETUP_REQUEST_PREFERRED_64KBPS_UE_RATE}=    ${NGAP_PDU_SESSION_RESOURCE_SETUP_REQUEST}
...                                                                && ${64KBPS_UE_RATE} && ${INTEGRITY_PROTECTION_INDICATION_PREFERRED}
${RRC_REESTABLISHMENT_REQUEST_OTHER_FAILURE}=    (nr-rrc.rrcReestablishmentRequest_element) && (nr-rrc.reestablishmentCause == 2)

*** Keywords ***
Set Internal Traffic Type With Qfi
    [Arguments]    ${ue}=1    ${pdu}=1
    Execute Egate Command    cmd=set_pdu_param ue=${ue} pdu=${pdu} qfi=1 trf_type=internal

Set Smf Param Maximum UE Rate
    ${command} =  catenate  SEPARATOR=
    ...           smf_param security_indication=pdu_session_setup:preferred:required max_data_rate=4000000kbps
    ...           \ max_ip_data_rate_dl=maximum_UE_rate id=1
    Execute Egate Command    cmd=${command}

Set Smf Param 64kbps
    ${command} =  catenate  SEPARATOR=
    ...           smf_param security_indication=pdu_session_setup:preferred:required max_data_rate=64kbps
    ...           \ max_ip_data_rate_dl=bitrate64kbs id=1
    Execute Egate Command    cmd=${command}

Start Data Traffic With Qfi
    [Arguments]    ${ue}=1    ${pdu}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue} pdu=${pdu} qfi=1 trf_id=1 mbps=150 dir=dl seconds=300

Perform HO Meas Type A3
    [Arguments]      ${pass_regexp}=pass
    Execute Egate Command And Wait For Data    cmd=ue_ho_nr ue_id=1 meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=634080
    ...                                        pass_regexp=${pass_regexp}
    ...                                        timeout=15

Pdu Session Ue Release
    [Arguments]    ${ue}=1    ${pdu}=1
    Execute Egate Command    cmd=pdu_session_ue_release ue=${ue} pdu=${pdu}

Waiting For Messages Collection
    Sleep    5s    reason=Waiting for Messages Collection

Update bsr package
    Log To Console    BSR package uploading...
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Download And Update BSR Package
    ...    filepath_url=${dllink}/${filename}
    ...    download_filepath=${OUTPUT_DIR}/${filename}

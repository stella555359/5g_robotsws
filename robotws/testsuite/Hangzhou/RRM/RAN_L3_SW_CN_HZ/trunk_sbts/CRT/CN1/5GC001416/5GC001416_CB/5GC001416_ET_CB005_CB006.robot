*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-DevHZ5_SG2
...  owner-yili.chen@nokia-sbell.com  release-20B
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{AS_ALGORITHM}
...    @{NRHOIF}
...    @{MFBI_activation}
...    @{MFBI_NRCONNECTEDMODE_Profile}
...    @{MFBI_NRCELL}
...    @{MFBI_NRMULTIBANDINFO_PROFILE}
...    @{MFBI_NRNSPMAX_Profile}

@{AS_ALGORITHM}
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
@{NRHOIF}
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasEnabled=rsrp
@{MFBI_activation}
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true
@{MFBI_NRCONNECTEDMODE_Profile}
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=48
@{MFBI_NRCELL}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
@{MFBI_NRMULTIBANDINFO_PROFILE}
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78|nrBandPriority=0
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=78|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=77|nrBandPriority=1
...    MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList:freqBandIndicatorNR=77|nrNsPmaxProfileDN=MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1
@{MFBI_NRNSPMAX_Profile}
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalPmax=4
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:additionalSpectrumEmission=5
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-1:nrNsPmaxList:nrNsPmaxPriority=6
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2:nrNsPmaxList:additionalPmax=0
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2:nrNsPmaxList:additionalSpectrumEmission=6
...    MRBTS-1/NRBTS-1/NRNSPMAX_PROFILE-2:nrNsPmaxList:nrNsPmaxPriority=7

@{delta_para1}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
@{delta_para2}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0

${UE1_NR_Capa}  #CB05_06_07_08
...    SEPARATOR=
...    E1A00000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C101010
...    70EF1C39061C00103278FAB80027800E0009E00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E001
...    51B0BF582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C043D6C10101070EF1C
...    39061C00103278FAA8000028000001041C4C0000001070BC00000000809A0A02C0402201107B058060005038180703005807000683E0000000
...    000000E54D000100000965950034AAA8081C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA1280
${UE1_RESULT}    Initial Context Setup Successful
#RESULT1': '',
#RESULT2': '',
#Description': 'supportedBandListNR:n77,n48,supportedBandCombinationList:n77,n48'},

${GNB_SA_HO_ADMISSION_MFBI_REQ}    M55138C00503
${GNB_SA_HO_ADMISSION_MFBI_SUCC}    M55138C00504
@{PM_Counters_Check_1}
...    NRCELL-2:${GNB_SA_HO_ADMISSION_MFBI_REQ}=0
...    NRCELL-2:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=0

@{PM_Counters_Check_2}
...    NRCELL-1:${GNB_SA_HO_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=1
...    NRCELL-2:${GNB_SA_HO_ADMISSION_MFBI_REQ}=1
...    NRCELL-2:${GNB_SA_HO_ADMISSION_MFBI_SUCC}=1

*** Test Cases ***
5GC001416-ET-CB006-CB005-Check_Intra-gNB_Intra-DU_HO_should_be_failed_when_different_alternative_bands_configured_for_source_and_target_cell
    [Documentation]
    ...    This case is to verify intra DU ho should be failed when different alternative bands are configured in source and target cells
    ...    UE supports n77 and n48, not n78
    ...    Verify intra DU HO should be successful when the same alternative bands are configured in source and target cells
    ...    UE supports n77, not n78
    [Tags]    QC_60809
    online modify CELL2 alternative band from n77 to n48
    register ue with ue_cap for CB
    trigger A3 event but HO not triggered
    Check Counters    ${PM_Counters_Check_1}
    online modify CELL2 alternative band from n48 to n77
    register ue with ue_cap for CB    ue_id=2
    HO from PCI50 to PCI51
    HO from PCI51 to PCI50
    Check Counters    ${PM_Counters_Check_2}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

register ue with ue_cap for CB
    [Arguments]   ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE1_NR_Capa}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...    pass_regexp=${UE1_RESULT}
    traffic should be ok    ue_id=${ue_id}    type=sa
    Clear Counter files

trigger A3 event but HO not triggered
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=31 nrsrq_nr=31
    ...    pass_regexp=measResultNeighCells measResultListNR
    should not contain    ${ret1}    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

online modify CELL2 alternative band from n77 to n48
    Delta Commission Parameters    ${delta_para1}
    Cells Should Be Onair    check_sib=${False}

online modify CELL2 alternative band from n48 to n77
    Delta Commission Parameters    ${delta_para2}
    Cells Should Be Onair    check_sib=${False}

HO from PCI50 to PCI51
    ${a3_rsrp_cmd}    Set Variable
    ...    ue_measurement_send_nr id=2 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=31 nrsrq_nr=31
    Execute Egate Command    ${a3_rsrp_cmd}    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    traffic should be ok    ue_id=2    type=sa

HO from PCI51 to PCI50
    ${a3_rsrp_cmd}    Set Variable
    ...    ue_measurement_send_nr id=2 meas_id=2 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=31 nrsrq_nr=31
    Execute Egate Command    ${a3_rsrp_cmd}    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    traffic should be ok    ue_id=2    type=sa
	

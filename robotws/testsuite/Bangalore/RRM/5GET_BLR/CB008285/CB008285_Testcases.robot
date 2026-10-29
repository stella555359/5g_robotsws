*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED   VARIANT_SA_FS_ECPRI_MMWV_TDD

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../ET_Performance/Performance_keywords.resource
Resource         ../CB007039/gNB_TTI_Sharpa_start_and_stop.resource
Resource         ./basic_resource.robot
Resource         CB008285_Resource.robot
Resource         ../CB007145/resources/common/CB007145_Resource.robot
Resource         ../CB008541/resources/CB008541_Keywords.robot

Documentation
...
...             author:           Manasa
...             maintainer:       manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     This user scenario describes how to configure a gNB with FR2 SA Cell with Single SSB
...             TEST SET NAME:    CB008285
...             TESTING SPLIT:    Refer CB008285 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008285 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20099



*** Variables ***

${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${1}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${TRF_ID2}    2
${QFI_ID}     1
${r&d_parameter}      0x5A00A1=2;0x5A00A3=300

&{ciph}         nea0=1      nea1_128=2  nea2_128=3  nea3_128=4
&{intgr}        nia0=1      nia1_128=4  nia2_128=2  nia3_128=3
${ip_prof}      null
${ip_prof1}      zuc
${ip_prof2}      aes
${ip_prof3}      snow3g
&{ue_profile}    ${1}=${ip_prof3}

&{ip_ie}    ${1}=required
&{ip_result}      ${1}=performed
&{max_ip_rate}    ${1}=maximum-UE-rate
&{max_ip_rate_dl}    ${1}=maximum-UE-rate
${st_ue_id}      ${1}
${en_ue_id}      ${1}
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

#Make sure VONR Traffic profile should in kbps for 5QI128 and 5QI 129 i.e QFI 2 and 3
@{QOS_Prof7}               1
@{QOS_Prof7_speed_ul}      5
@{QOS_Prof7_speed_dl}      5
@{QOS_Prof7_unit}          mbps


${SCFC_TC1}=                   ${CURDIR}/config/A_TC1/SCF_8285_A_TC1.xml
${AP_XML_TC1}=                 ${CURDIR}/config/A_TC1/IPHY_8285_A_TC1.xml
${wts_cfg_file_TC1}     ${CURDIR}/config/basic_setup_4cell_2CG.cfg

${wts_cfg_file_TC2}=                ${CURDIR}/config/A_TC2/32_SSB_BASIC_CONFIG_FILE.cfg
${SCFC_TC2}=                   ${CURDIR}/config/A_TC2/SCF_32SSB_4cell_2CG.xml
${AP_XML_TC2}=                 ${CURDIR}/config/A_TC2/iphy_32SSB_4cell_2CG.xml

${wts_cfg_file_TC4}=                ${CURDIR}/config/A_TC4/32_SSB_BASIC_CONFIG_FILE_AB7.cfg
${SCFC_TC4}=                   ${CURDIR}/config/A_TC4/SCF_32SSB_4cells_2CG_AB7xml
${AP_XML_TC4}=                 ${CURDIR}/config/A_TC4/iphy_32_SSB_4Cells_2CG_AB7.xml

${wts_cfg_file_ETC1}=                ${CURDIR}/config/E_TC1/32_SSB_BASIC_CONFIG_FILE.cfg
${SCFC_ETC1}=                   ${CURDIR}/config/E_TC1/SCF_Max_tput_GMC.xml
${AP_XML_ETC1}=                 ${CURDIR}/config/E_TC1/iphy_32SSB_4cell_2CG.xml

${wts_cfg_file_BTC1}=                ${CURDIR}/config/A_TC2/15_UE_32_SSB_BASIC_CONFIG_FILE.cfg
${SCFC_BTC1}=                   ${CURDIR}/config/E_TC1/SCF_Max_tput_GMC.xml
${AP_XML_BTC1}=                 ${CURDIR}/config/A_TC2/iphy_32SSB_4cell_2CG.xml

${SCFC_BTC2}=                   ${CURDIR}/config/B_8116/SCF_Integrity_FR2.xml
${AP_XML_BTC2}=                 ${CURDIR}/config/B_8116/Iphy_B_8116.xml
${wts_cfg_file_BTC2}     ${CURDIR}/config/B_8116/basic_32_8116.cfg

*** Test Cases ***
CB008285-A#B1#TC1_FR2_Standalone_deployment_For_Single_SSB
    [Documentation]
    ...             author:           Sruthi Jacob
    ...             maintainer:       sruthi.jacob@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes how to configure a gNB with FR2 SA Cell with Single SSB
    ...             TEST SET NAME:    CB008285
    ...             TESTING SPLIT:    Refer CB008285 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008285 CFAM
    ...             Requirement ID:   5G_RAN_USR_RRM_20099

    [Setup]        Run keywords     Log to console      "Suite Setup started"
    ...            AND     Prepare TL with all config files New      ${SCFC_TC1}      ${AP_XML_TC1}
    ...            AND     Suite setup from scratch
    ...            AND     Start Default Logging Gnb ASIL_ABIO
    ...            AND     Start WTS Using WTS_Runner      ${wts_cfg_file_TC1}
    ${TEST_NAME}    Set Variable   A_B1_TC1
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   "UE attach trigerring now"
#Step 1. Attach SA UE-1 on cell-1 and Start Data Traffic
    Run Keyword And Continue On Failure      Link SCOUT SCF to Configuration ID for Reporting
    MultiUE Register should be Successful    ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=30
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=mbps     ul_rate=30
    sleep     30s
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=30
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   ul_rate=30
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}
    [Teardown]      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Stop Default Logging Gnb ASIL_ABIO

CB008285-A#B4_TC2_RRC_connection_establishment_release_FR2_32_SSB_CELL
    [Documentation]
    ...             author:           Madhukara M V
    ...             maintainer:       madhukara.m_v@nokia.co
    ...
    ...             INTRODUCTION:     This user scenario describes how to configure a gNB with FR2 SA Cell with 32 SSB
    ...             TEST SET NAME:    CB008285
    ...             TESTING SPLIT:    Refer CB008285 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008285 CFAM
    ...             Requirement ID:   5G_RAN_USR_RRM_20140

    [Setup]        Run keywords     Log to console      "Suite Setup started"
    ...            AND     Prepare TL with all config files New      ${SCFC_TC2}     ${AP_XML_TC2}
    ...            AND     Suite setup from scratch
    ...            AND     Start Default Logging Gnb ASIL_ABIO
    ...            AND     Start WTS Using WTS_Runner      ${wts_cfg_file_TC2}
    ${TEST_NAME}    Set Variable   A_B4_TC2
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   "UE attach trigerring now"
#Step 1. Attach SA UE-1 on cell-1 and Start Data Traffic
    Run Keyword And Continue On Failure     Link SCOUT SCF to Configuration ID for Reporting
    MultiUE Register should be Successful    ${sa_ue_id1}    ${sa_ue_id1}
    Trigger High DL Traffic for SA    ${sa_ue_id1}    Traffic_rate=mbps     dl_rate=500
    Trigger High UL Traffic for SA    ${sa_ue_id1}    Traffic_rate=mbps     ul_rate=150
    sleep     30s
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=468
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   ul_rate=140
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}
    [Teardown]      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Stop Default Logging Gnb ASIL_ABIO

CB008285-A#B7_Beam_Group_configuration_and_change_with_32_SSB
    [Documentation]
    ...             author:           Sruthi
    ...             maintainer:       sruthi.jacob@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes how to configure Beam Group to UE and how Beam Group
    ...                               change works in FR2 SA Cell.
    ...             TEST SET NAME:    CB008285
    ...             TESTING SPLIT:    Refer CB008285 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008285 CFAM
    ...             Requirement ID:   5G_RAN_USR_RRM_20452

    [Setup]        Run keywords     Log to console      "Suite Setup started"
    ...            AND     Prepare TL with all config files New     ${SCFC_TC4}        ${AP_XML_TC4}
    ...            AND     Suite setup from scratch
    ...            AND     Start Default Logging Gnb ASIL_ABIO
    ...            AND     Start WTS Using WTS_Runner      ${wts_cfg_file_TC4}

    ${TEST_NAME}    Set Variable   A_B4_TC2
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
#    Start Log    cprt
    Create Beamforming Profile
    Activate Beamforming Profile
    log to console   "UE attach trigerring now"
    Run Keyword And Continue On Failure      Link SCOUT SCF to Configuration ID for Reporting
    MultiUE Register should be Successful    ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=30
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=mbps     ul_rate=30
    sleep     30s
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=30
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   ul_rate=30
    Trigger Beam switch
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=30
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   ul_rate=30
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}
    [Teardown]      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Stop Default Logging Gnb ASIL_ABIO

USCB008285_E_TC1_UE_Attach_and_Detach_in_FR2_Standalone_deployment_with_B4_PRACH_format
    [Documentation]
    ...             author:           Manasa
    ...             maintainer:       manasa.shankarappa@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes how to configure a gNB with FR2 SA Cell with 32 SSB with B4 Prach format
    ...             TEST SET NAME:    CB008285
    ...             TESTING SPLIT:    Refer CB008285 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008285 CFAM
    ...             Requirement ID:   5G_RAN_USR_RRM_20594

    [Setup]        Run keywords     Log to console      "Suite Setup started"
    ...            AND     Prepare TL with all config files New     ${SCFC_ETC1}       ${AP_XML_ETC1}
    ...            AND     Suite setup from scratch
    ...            AND     Start Default Logging Gnb ASIL_ABIO
    ...            AND     Start WTS Using WTS_Runner      ${wts_cfg_file_ETC1}
    ${TEST_NAME}    Set Variable   E_TC1
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   "UE attach trigerring now"
#Step 1. Attach SA UE-1 on cell-1 and Start Data Traffic
    Wait Until Keyword Succeeds    20x    10s    Check MIB_SIB status of GNB cell   ${1}
    MultiUE Register should be Successful    ${sa_ue_id1}    ${sa_ue_id1}
    Trigger High DL Traffic for SA    ${sa_ue_id1}    Traffic_rate=mbps     dl_rate=550
    Trigger High UL Traffic for SA    ${sa_ue_id1}    Traffic_rate=mbps     ul_rate=150
    sleep     30s
    Run Keyword And Continue On Failure      Link SCOUT SCF to Configuration ID for Reporting
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=420
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id1}   ul_rate=130
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id1}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id1}
    [Teardown]      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Stop Default Logging Gnb ASIL_ABIO

USCB008285-B#B1#CB007039#TC1_L2HI_Sherpa_OVL_Indication_Validation_Suspend_State
    [Documentation]
    ...              :authors: Manasa
    ...              :contact: manasa.shankarappa@nokia.com
    ...              CB008285 covers parity of CB007039 FR1 feature to FR2.
    ...              CB007039 helps to validate Overload Trigger for L2-Hi.
    ...              Whenever Threshold overcomes the configured value in RADParamter Suspend Streaming will be triggered by L2Hi.
    ...              Start/Suspend/Stop Streaming will be validated only via Syslog collected.
    ...             TEST SET NAME:    CB008285
    ...             TESTING SPLIT:    Refer CB008285 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008285 CFAM
    ...             Requirement ID:   5G_RAN_USR_RRM_20146

    [Setup]        Run keywords    Run Keyword and Ignore Error      Log to console      "Suite Setup started"
    ...                 AND     Update GNB R&D Parameter
    ...                 AND     Prepare TL with all config files New     ${SCFC_BTC1}        ${AP_XML_BTC1}
    ...                 AND     Suite setup from scratch
    ...                 AND     Log to console    "sleep for 100s"
    ...                 AND     sleep     100s
    ...                 AND     Log to console    "starting WTS"
    ...                 AND     sleep     1s
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file_ETC1}

    ${TEST_NAME}    Set Variable   B_TC1
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log    btslog    cprt
    Run Keyword And Continue On Failure     Link SCOUT SCF to Configuration ID for Reporting
    Start TTITrace and Sherpa
    log to console   Streaming started
	Sleep  2s  reason=wait to start trace
	Wait Until Keyword Succeeds   5 min   2 sec   Validate activation msg in syslog
    Log to console       "check UE register"
    sleep    10s
    Register Multiple UE and Send the Data     1    130     Traffic_rate=mbps   DL_Rate=8   UL_Rate=2
	Stop TTITrace and Sherpa
	Sleep  2s  reason=wait to stop trace
	Wait Until Keyword Succeeds   5 min   2 sec   Validate deactivation msg in syslog
    [Teardown]  Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Stop Default Logging Gnb ASIL_ABIO

USCB008285-B#B1#CB008116#TC5_US2_UPIP_traffic_anyDataRate_UPIPInd-Req-ZUC_maxUERate_5QI6-3_DLUL_TDD_LN
    [Documentation]
    ...             author:            Mundanad Vishnu
    ...             maintainer:        mundanad.vishnu@nokia.com
    ...
    ...             INTRODUCTION:     CB008285 covers parity of CB008116 FR1 feature to FR2.
    ...                               This user scenario describes the behaviour of Nokia gNB in SA mode for the successful setup
    ...                               and operation of integrity protection(SNOW-3G) for user plane traffic up to maximum-UE-rate.

    ...             TEST SET NAME:    CB008285
    ...             TESTING SPLIT:    See CB008285 testplan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008285 CFAM
    ...             Requirement ID:   5G_RAN_USR_RRM_20146

    [Setup]        Run keywords     Log to console      "Suite Setup started"
    ...            AND     Prepare TL with all config files New     ${SCFC_BTC2}        ${AP_XML_BTC2}
    ...            AND     Suite setup from scratch
    ...            AND     update_delta_and_create.update_cfg  ${CURDIR}/config/B_8116/basic_setup_2CC_tdd_ref.cfg      ${ue_profile}
    ...            AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...            AND     Start WTS Using WTS_Runner      ${wts_cfg_file_BTC2}
    ${TEST_NAME}    Set Variable   B_TC2
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    ${ue_profile}       Create Dictionary   ${1}=${ip_prof3}
    Set Suite Variable    ${ip_ie}      &{ip_ie}
    Set Suite Variable    ${max_ip_rate}      &{max_ip_rate}
    Set Suite Variable    ${max_ip_rate_dl}      &{max_ip_rate_dl}
    Set Suite Variable    ${ip_result}      &{ip_result}
    Set Suite Variable    ${ue_profile}      &{ue_profile}

    basic_resource.Increase Buffer Size for VM and IPHY
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof7}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof7_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof7_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof7_unit}
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom      ${st_ue_id}    ${en_ue_id}   pdu_session_setup
    ... 	${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1

    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    180
    ${trf_id}      Set Variable    ${1}
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${duration}s

   Check Integrity failure count
   ${nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr    ${st_ue_id}    ${en_ue_id}    ${duration}    both   ${trf_id}
    ...    ${qos_profile_unit}    ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}

   MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
   [Teardown]  Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Stop Default Logging Gnb ASIL_ABIO

*** Keywords ***
Trigger Beam switch
    Run keyword and ignore error     Start Collecting Syslog     NAME=beamswitch
    sleep    30s
    log to console    Trigger beam Switch...
    Perform Beam Switch   ue_id=1        beam_profile_id=2
    sleep    30s
    Stop Collecting Syslog       NAME=beamswitch
    Run keyword and ignore error     Verify Beam Switch in Syslog      NAME=beamswitch

Create SSB Beam profile
   [Arguments]   ${profile_id}    ${beamType}    ${ueBeamIndexInitial}     ${ssbeam_bestbeam}   ${ssbeam_rsrp_best}  ${ssbeam_rsrp_avg}
   Log to Console    Setting Beamcontrol Test Mode
   wtsrunner.beam_control_testmode_nr      profile_id=${profile_id}   beamType=${beamType}   ueBeamIndexInitial=${ueBeamIndexInitial}
   ...    ssbeam_bestbeam=${ssbeam_bestbeam}    ssbeam_rsrp_best=${ssbeam_rsrp_best}     ssbeam_rsrp_avg=${ssbeam_rsrp_avg}

Perform Beam Switch
    [Arguments]    ${ue_id}=1     ${beam_profile_id}=2
    Log to Console    Changing Beam
    wtsrunner.ue_testmode_set_nr     id=${ue_id}      testmode=beam_control   profile_id=${beam_profile_id}     action=activate
    ...      beamaction=switch

Create Beamforming Profile
    Log to Console    Setting Beamcontrol Test Mode
    Create SSB Beam profile    profile_id=1    beamType=Analog    ueBeamIndexInitial=0,1,2,3,7,8,9,10    ssbeam_bestbeam=0
    ...    ssbeam_rsrp_best=-44     ssbeam_rsrp_avg=-44
    sleep  10s
    Create SSB Beam profile    profile_id=2    beamType=Analog    ueBeamIndexInitial=0,1,2,3,7,8,9,10    ssbeam_bestbeam=9,10
    ...    ssbeam_rsrp_best=-45     ssbeam_rsrp_avg=-55
    sleep  10s

Activate Beamforming Profile
    [Arguments]   ${ue_id}=1   ${profile}=1
    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=beam_control   profile_id=${profile}   action=activate   beamaction=attach
    Log to console    UE ${ue_id} beamforming profile is attached

Verify Beam Switch in Syslog
     [Arguments]     ${NAME}
    log to console     Verifying syslog
    ${status} =   run    command=sudo cat ${LOG_PATH}/syslog_${NAME}.log | grep -i "Recv BeamGroupChangeInd"
    Log to Console    ${status}
    Should contain    ${status}     Recv BeamGroupChangeInd
    Log to Console    Beam Switch verified in syslog

Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Update GNB R&D Parameter
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

Register Multiple UE and Send the Data
    [Arguments]   ${Start_UE}    ${MAX_UE}   ${DL_Rate}   ${UL_Rate}   ${Traffic_rate}=mbps
    [Documentation]   Use This keyword to Register multiple UE.. Pass the Arguments StartUE, EndUE, DLRate, ULRate and Traffic_rate
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${MAX_UE}+1
         log to console   UE attach triggering now...${UE}
         UE Register should be Successful     ${UE}
         Trigger DL Data Traffic for SA    ue_id=${UE}     Traffic_rate=${Traffic_rate}   dl_rate=${DL_Rate}      pdu_id=${Pdu_session_ID}
         ...    trf_id=${TRF_ID}
         sleep    1s
         Trigger UL Data Traffic for SA    ue_id=${UE}     Traffic_rate=${Traffic_rate}    ul_rate=${UL_Rate}      pdu_id=${Pdu_session_ID}
         ...    trf_id=${TRF_ID}
         sleep    1s
         BuiltIn.Log    UE Registration Done...${UE}    WARN
		 ${Suspend}    check suspend msg in syslog
         Run keyword if   ${Suspend}==${TRUE}   Run Keywords    Check suspendresp and release ue    ${UE}
         ...    AND    Exit for loop
    END

Validate activation msg in syslog
    ${Reqmsg}   run    command=sudo cat ${LOG_PATH}/tmp/syslog_gnb.log | grep -i "StreamActivationReq" -m 1
    Builtin.Log   ${Reqmsg}
    ${Req}   Run keyword and return status   Should Not Be Empty    ${Reqmsg}
    ${Respomsg}   Run Keyword if    ${Req}==${TRUE}   run
    ...    command=sudo cat ${LOG_PATH}/tmp/syslog_gnb.log | grep -i "StreamActivationResp" -m 1
    Should Not Be Empty    ${Respomsg}

Validate deactivation msg in syslog
    ${Reqmsg}   run    command=sudo cat ${LOG_PATH}/tmp/syslog_gnb.log | grep -i "StreamDeactivationReq" -m 1
    Builtin.Log   ${Reqmsg}
    ${Req}   Run keyword and return status   Should Not Be Empty    ${Reqmsg}
    ${Respomsg}   Run Keyword if   ${Req}==${TRUE}   run
    ...    command=sudo cat ${LOG_PATH}/tmp/syslog_gnb.log | grep -i "StreamDeactivationResp" -m 1
    Should Not Be Empty    ${Respomsg}

Check suspend msg in syslog
    ${Reqmsg}   run    command=sudo cat ${LOG_PATH}/tmp/syslog_gnb.log | grep -i "SuspendStreamingReq" -m 1
    Builtin.Log   ${Reqmsg}
    ${Req}   Run keyword and return status    Should Not Be Empty    ${Reqmsg}
    [Return]    ${Req}

Check suspendresp and release ue
    [Arguments]   ${Max_ue}
    ${Respomsg}   run   command=sudo cat ${LOG_PATH}/tmp/syslog_gnb.log | grep -i "SuspendStreamingResp" -m 1
	Should Not Be Empty    ${Respomsg}
	Stop Traffic and Dettach Multiple UE    1    ${Max_ue}

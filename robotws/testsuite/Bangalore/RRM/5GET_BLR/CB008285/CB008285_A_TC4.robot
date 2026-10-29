*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED     VARIANT_SA_FS_ECPRI_MMWV_TDD

Resource         CB008285_Resource.robot
Resource         ../CB007145/resources/common/CB007145_Resource.robot
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     BuiltIn.Log     ${SCFC}
...                 AND     Prepare TL with config files
...                 AND     Suite setup from scratch
...                 AND     Start Default Logging Gnb ASIL_ABIO
...                 AND     Start WTS Using WTS_Runner      ${LUA_CFG}



Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO


Documentation
...
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



*** Variables ***
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${1}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC4

${LUA_CFG}=                ${CURDIR}/config/A_TC4/32_SSB_BASIC_CONFIG_FILE_AB7.cfg
${SCFC}=                   ${CURDIR}/config/A_TC4/SCF_32SSB_4cells_2CG_AB7_GMC.xml
${AP_XML}=                 ${CURDIR}/config/A_TC4/iphy_32_SSB_4Cells_2CG_AB7.xml


*** Test Cases ***
[1][2.0] CB008285-A#B7_Beam_Group_configuration_and_change_with_32_SSB
    [Tags]   QC_304497
    sleep   30s
    set test variable      ${LOG_PATH}
#    Start Log    cprt
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    Create Beamforming Profile
    Activate Beamforming Profile
    log to console   "UE attach trigerring now"
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
#    ${log_path}    Stop Log    cprt      test_scenario=beamswitch


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

*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
...             CONFIGS_Bangalore/RRM/ET/CNI_99270/CB008985_beamswitch_CA.yml
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Varun
...              :contact:varun.khokhar@nokia.com
...         This CNI supports NR FR1 TDD super cell RRM part. The super cell is a logical cell created by several sub-cells.
...         The same Physical Cell ID (PCI) is assigned to each sub-cell of the super cell.
...         Each sub-cell of the super cell operates on the same carrier frequency without resource multiplexing
...         This case checks TDD FR1 supercell, when UE specific CSI-RS multiplexing is activated (actCsirsMultiplexing = true),
...         it is allowed that 2 UE specific CSI-RS resources are allocated in the same symbol.


Resource         ../CB008541/resources/CB008541_Keywords.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
#Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
#Resource         ../resources/robot/Common_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
#Resource         resources/load_based_validation_keywords.resource
Resource         ../resources/robot/TTI_Traces.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ../resources/python/avg_dl_data.py
Library           ta5g_enb

#Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
#...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file}
#...                 AND     Check gNB Bulid

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=C1_SCF_CA.xml
...                 AND     gnb.Perform gNB reboot
...                 AND     Configure UTE ETH3 IPs
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep      300

Suite Teardown      Run keywords    Kill WTS processes Using WTS_Runner
...                 AND     Stop Log      btslog     cprt
#...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report

*** Variables ***
${IPHY_FILE}        ${CURDIR}/config/wts/C1_IPHY_CA.xml
${TEST_NAME}        Cell_setup
#${DELTA_FILE}              Delta_Conf_CB007859_A_3_007_10ue.json
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${wts_cfg_file}      ${CURDIR}/config/basic_setup_ASOE_4cell_F_CA.cfg
${iphy}              ${CURDIR}/resources/config/AHPF_iphy_working.xml
@{LOG_NAME_LIST}           btslog    snapshot
${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
${WTS_CFG}                 basic_setup_ASOE_4cell_F_CA.cfg
${WTS_AP_XML}              AirphoneConfig_multiue_fdd.xml
@{OLD_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>.*</GSCN>
@{NEW_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>7880</GSCN>
&{UE_INFO}                 profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=30M    ul_traffic=30M
${UE_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${UE_NUM}                  1
${nwslice_ID}   1
${gw_ID}     1
${UE_PER_SLOT}              4
${UE_NUM_CHANGE}            2
${start_ue_id}         1
${end_ue_id}       1
${no_of_ue}        1
${UE_NUM_CHANGE_Dl_1}            5
#${PM_PCELL_COUNTER1}    M55305C03009




*** Test Cases ***
[1]CB008985_C1_2_UE_specific_CSI_RS_frequency_multiplexing_in_TDD_FR1_super_cell_and_CA_RRCreestablishment_to_other_supercell
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log     cprt      btslog
    Create BeamForming profile attach UE and scell addition trigger data

    Run Keyword and continue on failure      Validate DL Traffic For MultiUE for SA      1       1      170
    wtsrunner.ue_testmode_set_nr     id=1      testmode=beam_control      action=activate      profile_id=1
    ...      beamaction=switch    scell=2
    wtsrunner.ue_testmode_set_nr     id=2      testmode=beam_control      action=activate      profile_id=1
    ...      beamaction=switch    scell=2
#    wtsrunner.ue_testmode_set_nr     id=3      testmode=beam_control      action=activate      profile_id=2
#    ...      beamaction=switch    scell=2
#    wtsrunner.ue_testmode_set_nr     id=4      testmode=beam_control      action=activate      profile_id=2
#    ...      beamaction=switch    scell=2
    Run Keyword and continue on failure       Validate DL Traffic For MultiUE for SA      1       1      170
  #  Validate PM Counters_pcell_1
	Stop Log      cprt      btslog       test_scenario=Scenario_1
    MultiUE Deregister should be Successful     1       1
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Create BeamForming profile attach UE and scell addition trigger data
    log to console   Create BeamForming Profile...
    Create Beamforming Profile
    wtsrunner.ue_testmode_set_nr    id=1    testmode=beam_control     action=activate     profile_id=1      beamaction=attach
    Log to console    UE 1 beamforming profile is attached
    wtsrunner.ue_testmode_set_nr    id=2    testmode=beam_control     action=activate     profile_id=1      beamaction=attach
    Log to console    UE 2 beamforming profile is attached
#    wtsrunner.ue_testmode_set_nr    id=3    testmode=beam_control     action=activate     profile_id=2      beamaction=attach
#    Log to console    UE 3 beamforming profile is attached
#    wtsrunner.ue_testmode_set_nr    id=4    testmode=beam_control     action=activate     profile_id=2      beamaction=attach
#    Log to console    UE 4 beamforming profile is attached
    log to console   UE attach trigerring now...
    FOR   ${UE}   IN RANGE  ${1}   ${5}
          UE Register should be Successful   ${UE}
          Send High and verify scell addition    ${UE}
    END
    wtsrunner.ue_testmode_set_nr    id=1    testmode=beam_control     action=activate     profile_id=2      beamaction=attach
    Log to console    UE 1 beamforming profile is attached
    wtsrunner.ue_testmode_set_nr    id=2    testmode=beam_control     action=activate     profile_id=2      beamaction=attach
    Log to console    UE 2 beamforming profile is attached
#    wtsrunner.ue_testmode_set_nr    id=3    testmode=beam_control     action=activate     profile_id=1      beamaction=attach
#    Log to console    UE 3 beamforming profile is attached
#    wtsrunner.ue_testmode_set_nr    id=4    testmode=beam_control     action=activate     profile_id=1      beamaction=attach
#    Log to console    UE 4 beamforming profile is attached
    Sleep    5s

Send High and verify scell addition
    [Arguments]   ${UE}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=.*activated successfully.*  timeout=30
    Get Lines Matching Regexp    ${output}    CellIndex 1 activated successfully partial_match=${TRUE}
    Log to Console    ${output}
    Trigger DL Data Traffic for SA    ue_id=${UE}  Traffic_rate=mbps   dl_rate=170

Create Beamforming Profile
    [Arguments]    ${ue_id}=1
    Log to Console    Setting Beamcontrol Test Mode
    wtsrunner.beam_control_testmode_nr     profile_id=1     ueBeamIndexInitial=0,1,2,3,4,5,6,7     ssbeam_bestbeam=0      ssbeam_rsrp_best=-44
    ...   ssbeam_rsrp_avg=-50
#    wtsrunner.beam_control_testmode_nr     profile_id=2     ueBeamIndexInitial=1,0,2,3,4,5,6,7     ssbeam_bestbeam=1      ssbeam_rsrp_best=-45
#    ...   ssbeam_rsrp_avg=-50

Activate Beamforming Profile
    [Arguments]    ${ue_id}=1    ${profile}=1
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=beam_control     action=activate     profile_id=${profile}      beamaction=attach
    Log to console    UE ${ue_id} beamforming profile is attached

Beamcontrol Beam Switch 2
    [Arguments]    ${ue_id}=1     ${beam_profile_id}=2     ${scell_idx}=0     ${best_beam}=1
    Log to Console    Changing Beam
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr     id=${ue_id}      testmode=beam_control      action=activate      profile_id=${beam_profile_id}
    ...      beamaction=switch    scell=${scell_idx}
    Run Keyword and continue on failure    Check best beam     beam_profile_id=${beam_profile_id}    best_beam=${best_beam}

#Validate PM Counters_pcell_1
 #Wait until the next Measurement Period starts
 #${PM_dir_1}=    PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb0
  PM_Counters.Check PM counter value equal     expected_value=1   pm_files_location=${PM_dir_1}      #pi_id=M55305C03009   moc=NRCELL-1
  #PM_Counters.Check PM counter value equal     expected_value=1   pm_files_location=${PM_dir_1}   #pi_id=M55118C04000   moc=NRCELL-1
  #PM_Counters.Check PM counter value equal     expected_value=1   pm_files_location=${PM_dir_1}      #pi_id=M55118C04001   moc=NRCELL-1

Modify IPHY File And Send to Airphone Custom
    [Arguments]    ${iphy_path}    ${frag}=${-1}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML Custom   ${iphy_path}    ${frag}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
    ${RRU_Version}    Get RRU Version From TargetBD File Custom    ${RRU_type}    ${OUTPUT_DIR}
    Modify RRU Version Of IPHY XML Custom    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
    Send IPHY XML To Airphone custom    ${iphy_path}
    END

Send IPHY XML To Airphone custom
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} rm -f /ffs/run/simmode/*.xml
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy_modify.xml
    Should Be Equal As Integers    ${rc}    0
    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} ${soft_link}
    Should Be Equal As Integers    ${rc}    0

Get RRU Type From Local IPHY XML Custom
    [Arguments]    ${iphy_path}    ${frag}=${-1}
    ${content}=    OperatingSystem.Get File    path=${iphy_path}
    ${x}  Set Variable      <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>\\n\\s+(?=<\\/RE>)
    ${f1}   Set Variable
    ...     <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>\\n\\s+(?=<fragmentationCapabilities>)
    ${x}    set variable if    ${frag}==${1}     ${f1}     ${x}
    @{RRU_type_for_version}    String.Get Regexp Matches    ${content}    ${x}    RRU_type    Ecpri_tag
    @{RRU_type_list}    String.Get Regexp Matches    ${content}    ${x}    RRU_type
    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
    Set Suite Variable    ${RRU_TYPE}    ${RRU_type_list[0]}
    Log To Console   RRU Type List from local iphy.xml: ${RRU_type_list}
     Log To Console    RRU Type from local iphy.xml: ${RRU_TYPE}
    [Return]    @{RRU_type_for_version}

Get RRU Version From TargetBD File Custom
    [Arguments]    ${RRU_type}    ${save_dir}
    ${RRU_type}=    Set Variable If    "${RRU_type[0]}"=="AAHF"    AAHF_C1
    ...    "${RRU_type[0]}"=="AEUB"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEQE"    ${RRU_type[0]}_E1
    ...    "${RRU_type[0]}"=="AHLOA"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWEUA"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AHFII"    ${RRU_type[0]}
    ...    "${RRU_type[1]}"=="ecpri"    ${RRU_type[0]}_E1
    ...    ${RRU_type[0]}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD*.xml ${save_dir}/TargetBD.xml
    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
    [Return]    ${RRU_Version}[0]

Modify RRU Version Of IPHY XML Custom
    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
    ${content}    OperatingSystem.Get File    path=${iphy_path}
    ${bldVersion}=    String.Get Regexp Matches    ${content}
    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
    ...    bldVersion
    Log Many    ${bldVersion[0]}    ${RRU_Version}
    ${new_content}    String.Replace String    ${content}    ${bldVersion[0]}    ${RRU_Version}
    Log To Console    ${new_content}
    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}













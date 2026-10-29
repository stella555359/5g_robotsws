*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
...             CONFIGS_Bangalore/RRM/ET/CNI_99270/CB008985_intra_gnb.yml
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Varun
...              :contact:varun.khokhar@nokia.com
...         This CNI supports NR FR1 TDD super cell RRM part. The super cell is a logical cell created by several sub-cells.
...         The same Physical Cell ID (PCI) is assigned to each sub-cell of the super cell.
...         Each sub-cell of the super cell operates on the same carrier frequency without resource multiplexing
...         This case checks TDD FR1 supercell, when UE specific CSI-RS multiplexing is activated (actCsirsMultiplexing = true),
...         it is allowed that 2 UE specific CSI-RS resources are allocated in the same symbol.

Library 		 ../CB008983/resources/verify_reconfig.py
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


Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=C1_SCF_intra_gNB.xml
...                 AND     gnb.Perform gNB reboot
...                 AND     Configure UTE ETH3 IPs
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep      300


Suite Teardown      Run keywords    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

*** Variables ***
${TLConfig.isUTE}       True
#${DELTA_FILE}              Delta_Conf_CB007859_A_3_007_10ue.json
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
#${WTS_CFG}                 ${CURDIR}/config/basic_setup_ASOE_4cell_F_CA.cfg
${wts_cfg_file}     ${CURDIR}/config/basic2SupercellAZQP_setup_HO.cfg
#${iphy}              ${CURDIR}/resources/config/AHPF_iphy_working.xml
@{LOG_NAME_LIST}           btslog    snapshot_AirphoneConfig_multiue_fdd.xml
#@{OLD_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>.*</GSCN>
#@{NEW_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>7880</GSCN>
&{UE_INFO}                 profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=30M    ul_traffic=30M
${UE_ID}        1
${UE}        1
${Pdu_session_ID}       1
${Timeout_SA}    40
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
${PM_PCELL_COUNTER1}    M55305C03009
${file_path}    /opt/iphy/latest/egate_console.log
${UE_HO}     Handover will be triggered using CBRA
${UE_HO1}     Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
${IPHY_FILE}                    ${CURDIR}/config/wts/C1_IPHY_intra.gNB.xml
${AP_XML}                    ${CURDIR}/config/wts/C1_IPHY_intra.gNB.xml


*** Test Cases ***
[1]CB008985_C_01_UE_specific_CSIRS_SuperCell_intragNB_HO_return
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log     cprt      btslog
    Create BeamForming profile attach UE and trigger data
	Perform handover and validate

    Run Keyword and continue on failure       Validate DL Traffic For MultiUE for SA      1       1      170
    Run Keyword and continue on failure       Validate DL Traffic For MultiUE for SA      1       1      170
    Stop Log      cprt      btslog       test_scenario=Scenario_1
    UE Deregister should be Successful   ue_id=${UE_ID}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Create BeamForming profile attach UE and trigger data
    log to console   Create BeamForming Profile...
    Create Beamforming Profile
    wtsrunner.ue_testmode_set_nr    id=1    testmode=beam_control     action=activate     profile_id=1      beamaction=attach
    Log to console    UE 1 beamforming profile is attached
    log to console   UE attach trigerring now...
    #UE Register should be Successful   ${UE}
    UE Register should be Successful     ue_id=${UE_ID}
	Trigger DL Data Traffic for SA    ue_id=${UE}  Traffic_rate=mbps   dl_rate=170

Perform handover and validate
    Sleep    5s
	wtsrunner.ue_measurement_send_nr    id=1    meas_id=1    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=51
    ...   nrsrp_nr=30    nrsrq_nr=20
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=30
	${output1}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output1}
    ${output2}         Get Lines Matching Regexp    ${output}    Handover will be triggered using CBRA   partial_match=${TRUE}
    Log to Console    ${output2}
    ${output3}         Get Lines Matching Regexp    ${output}    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2  partial_match=${TRUE}
    Log to Console    ${output3}

Create Beamforming Profile
    [Arguments]    ${ue_id}=1
    Log to Console    Setting Beamcontrol Test Mode
    wtsrunner.beam_control_testmode_nr     profile_id=1     ueBeamIndexInitial=0,1,2,3,4,5,6,7     ssbeam_bestbeam=0      ssbeam_rsrp_best=-44
    ...   ssbeam_rsrp_avg=-50
    Log to console    UE ${ue_id}

Activate Beamforming Profile
    [Arguments]    ${ue_id}=1    ${profile}=1
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=beam_control     action=activate     profile_id=${profile}      beamaction=attach
    Log to console    UE ${ue_id} beamforming profile is attached

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













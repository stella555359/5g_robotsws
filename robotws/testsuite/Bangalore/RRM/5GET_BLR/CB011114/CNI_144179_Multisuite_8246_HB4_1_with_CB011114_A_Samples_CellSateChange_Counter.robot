*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R3    CONFIGURED

Documentation
...             author:                 rahul.kumar_singh@nokia.com
...             maintainer:             rahul.kumar_singh@nokia.com
...
...             INTRODUCTION:      CB008246_HB4_TC1_UL_Fallback_Recovery_with_64QAMLowSETable
...             TEST SET NAME:     CB008246_HB4_TC1_UL_Fallback_Recovery_with_64QAMLowSETable
...             TESTING SPLIT:     See CB008246-HB4 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008246-H CFAM

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          taf.rfrl.utilities.utf_lab.ute_utf_lab.UteUtfLab  WITH NAME  ute_utf_lab
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
#Resource         ../CB008246/CB008246_resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library         ../CB008246/python/CB008246_validation.py

Resource         ./resources/CB011114_common_resources.robot

*** Variables ***
${SCFC_HB4}=        ${CURDIR}${/}../CB008246/config/SCF/CB008246_HB4_TC1_ASOH_SCF.xml
${IPHY_FILE_HB4}          ${CURDIR}${/}../CB008246/config/SCF/8246_HB4_TC1_Gmc_IPHY.xml
${wts_cfg_file_HB4}    ${CURDIR}${/}../CB008246/config/wts/basic_setup_HB4_TC1_ASOH_SAUE1HRcapable.cfg

&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}     /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}        1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${TEST_NAME}        test_case
${pathloss_start_dB}        75
${pathloss_end_dB}      130
${st_ue_id}      1
${en_ue_id}      1
@{Component1}   L2PS

#TC_02&03_variables

#${wts_cfg_file}     ${CURDIR}/config/wts/AHPCA_1CELL_WTS.cfg
${wts_cfg_file}         ${CURDIR}/config/wts/asoh_basic_setup.cfg
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${scell_idx}    0
#${iphy_xml}         ${CURDIR}/config/wts/Cell_Addition_AVQE_iphy.xml
${pdu_id}    1
${nw_id}     1
${iphy_xml}         ${CURDIR}/config/iphy.xml
${gscn_value}   1
${st_ue_id_2}      51
${en_ue_id_2}      51
${highMuting}         --db 3 set_temp_rating HIGH
${normalMuting}       --db 3 set_temp_rating NORMAL
${increasedMuting}    --db 3 set_temp_rating INCREASED
${highExp}            set_temp_rating HIGH successfully proceed
${normalExp}          set_temp_rating NORMAL successfully proceed
${increasedExp}       set_temp_rating INCREASED successfully proceed
${trigger_alarm}     --db 3 trigger_rf_fault 1936 module CRI
${cancel_alarm}     --db 3 cancel_rf_fault 1936 module
#${SCFC}     ${CURDIR}/config/SBTS24R2/AHPCA_1CELL_SCF.xml
#${AP_XML}     ${CURDIR}/config/SBTS24R2/AHPCA_1CELL_IPHY.xml
${SCFC}         ${CURDIR}/config/SBTS24R3/multicell_ahfib.xml
${AP_XML}       ${CURDIR}/config/wts/iphy_asoh_fdd_multicell.xml
${TEST_NAME_2}     CB011114_MultiCell
${startMutingParam}    --db 3 set_temp_rating HIGH
${noMutingParam}       --db 3 set_temp_rating INCREASED
${stopMutingParam}     --db 3 set_temp_rating NORMAL

*** Test Cases ***
[1][1.0] [1]CB008246_HB4_TC1_UL_Fallback_Recovery_with_64QAMLowSETable
    [Tags]  TC_01
    [Setup]    Run keywords
    ...                 Log To console  SuiteSetup
    ...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE_HB4}
    ...                 AND     Perform SCF Delta Commissioning with 8246_hb4_gmc.json
    ...                 AND     sleep    180
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    #...                 AND    ute_utf_lab.Update Utf Lab
    ...                 AND    operatingSystem.Run        export {http,https}_proxy=http://10.158.100.6:8080
    #...		            AND	    Initiate Dcap
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND    Sleep   500s    reason=wait for RMOD to comeup
    ...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file_HB4}
    ...                 AND    sleep  60s   reason=wait for mib sib
    #...					AND		DCAP Connect To gNB

    [Documentation]
       ...    1. This user scenario validates HR to BR Switch in UL is done.
       ...    2. Configuration
       ...    a.NSA TDD cells are configured with frequency NRF1 in band n78 with 100MHz bandwidths.
       ...    b.NRF1 cell has NRCELL-cellDepType set to NSA or both
       ...    3. Test Case Steps:
       ...    a.UE attach and CQi changes are done.
       ...	  b.HR to BR Switch is done and verified.
       ...    c.UE detach.

    set test variable   ${LOG_PATH}
    log to console   UE attach trigerring now...

    Introduce csi_override_cqi      4
    Activate csi_override_for_UE        1       1
    Introduce pathloss      1       1
    Activate pathloss_for_UE        1       1
    sleep       1s

    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRPUSCHHRLA-1       update      ulHRBlerRecoverPeriod     20
    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRPUSCHHRLA-1       update      ulHRBlerOutagePeriod     20
    sleep   5s
    Log To Console          check bts state
    sleep           30s

#    Start Log Via DCAP  ttitrace  component=${Component1}

    ${crnti_list1}=      MultiUE Register should be Successful    1      1
    MultiUE PDU Modfication should be Successful     1    1      pdu_id=1      qosflows_to_add=4

    MultiUE Trigger DL Traffic for SA   1       1    Traffic_rate=mbps   dl_rate=1   trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA   1       1    Traffic_rate=mbps   ul_rate=1   trf_id=${TRF_ID}
    MultiUE Trigger DL Traffic for SA   1       1    Traffic_rate=mbps   dl_rate=1   trf_id=${TRF_ID}       qfi_id=2
    MultiUE Trigger UL Traffic for SA   1       1    Traffic_rate=mbps   ul_rate=1   trf_id=${TRF_ID}       qfi_id=2

    sleep       3s
    Start Log      ttitrace
    Introduce csi_override_cqi      1
    Activate csi_override_for_UE         1      1

    Vary pathloss       pathloss_start_dB=${pathloss_start_dB}+${1}     pathloss_end_dB=${pathloss_end_dB}     pathloss_step_dB=1
    #Vary pathloss       pathloss_start_dB=${pathloss_end_dB}    pathloss_end_dB=${pathloss_start_dB}    pathloss_step_dB=-1
#    Start Log Via DCAP  ttitrace  component=${Component1}
    sleep       2s
    ${path_ttitrace_UE1_cqi4_1}    Stop log      ttitrace    test_scenario=ttitrace_UE1_cqi4_1
#    ${path_ttitrace_UE1_cqi4_1}    Stop Log Via DCAP  ttitrace  test_scenario=ttitrace_UE1_cqi4_1

    Start Log      ttitrace
#    Start Log Via DCAP  ttitrace  component=${Component1}
    Introduce csi_override_cqi      13
    Activate csi_override_for_UE        1       1
    #Vary pathloss       pathloss_start_dB=${pathloss_start_dB}+${1}     pathloss_end_dB=${pathloss_end_dB}     pathloss_step_dB=1
    Vary pathloss       pathloss_start_dB=${80}   pathloss_end_dB=${pathloss_start_dB}    pathloss_step_dB=-1
    sleep       3s
    ${path_ttitrace_UE1_cqi13}    Stop log      ttitrace    test_scenario=ttitrace_UE1_cqi13
#    ${path_ttitrace_UE1_cqi13}    Stop Log Via DCAP  ttitrace  test_scenario=ttitrace_UE1_cqi13

    sleep       3s
    Decode TTI Trace    ttitrace_UE1_cqi13
    Decode TTI Trace    ttitrace_UE1_cqi4_1

# HR to BR switch
    ${chk_attrs}   Create List  laMode  event  pdcchMetric.nbSamples  pdcchMetric.nbSamplesThreshold  pdcchMetric.ratio
    ...     puschMetric.nbSamples  puschMetric.nbSamplesThreshold  sfn  slot  cqiAlSelection   aggregationLevel   puschMetric.ratio
    ${rc}   verify_pdcch_outage_ul   ${path_ttitrace_UE1_cqi4_1}[ttitrace]/output_ul_formated.csv   ulLaSwitchBetweenHrAndBr
    ...          ulFdSchedData   ${20}    ${20}      @{chk_attrs}
    Should Contain	${rc}	pass

#BR to HR switch
    ${rc}   verify_pdcch_recovery_ul   ${path_ttitrace_UE1_cqi13}[ttitrace]/output_ul_formated.csv   ulLaSwitchBetweenHrAndBr
    ...          ${30}    ${60}      @{chk_attrs}
#    Should Contain	${rc}	pass

    MultiUE Deregister should be Successful   ${st_ue_id}   ${en_ue_id}

   [Teardown]  Run Keywords   Log To console  TCTeardown
   ...          AND     Link SCOUT SCF to Configuration ID for Reporting
   ...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
   #...                 AND     DCAP Disconnect To gNB

[1][1.0] CB011114_A_Validate_NrCell_Samples_cellStateChange_Counters_At_Level1and3
    [Tags]  TC_02
    [Setup]    Run keywords     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     Perform SCF Delta Commissioning with CB011114_Enable_PmInterval.json
    ...                 AND     Perform SCF Delta Commissioning with Create_PMMNL.json
#    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
    ...                 AND     Gnb.Perform gNB reboot
    ...                 AND     Sleep       500s      reason=wait for RMOD to comeup
    ...                 AND     WTS_Runner_Keywords.Start WTS Using WTS_Runner      ${wts_cfg_file}


    Set test variable     ${LOG_PATH}
#    Perform SCF Delta Commissioning with CB011114_Activation.json
#    Configure ETH And Load CFG      ${wts_cfg_file}
    Sleep    30s
    Wait until the next Measurement Period starts
    Slot Muting    ${highMuting}    ${highExp}
    Slot Muting    ${highMuting}    ${highExp}
    Slot Muting    ${highMuting}    ${highExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${increasedMuting}    ${increasedExp}
    Slot Muting    ${highMuting}    ${highExp}
    Slot Muting    ${increasedMuting}    ${increasedExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${highMuting}    ${highExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Slot Muting    ${normalMuting}    ${normalExp}
    Wait until the current Measurement Period stops
    ${pm_files1}     Collect RD Counters

    Validate NR CELL RF COOL MODE0 SAMPLES     ${pm_files1}
    Validate NR CELL RF COOL MODE0 STATE CHANGE     ${pm_files1}
    Validate NR CELL RF COOL MODE1 SAMPLES     ${pm_files1}
    Validate NR CELL RF COOL MODE1 STATE CHANGE     ${pm_files1}
    Validate NR CELL RF COOL MODE2 SAMPLES     ${pm_files1}
    Validate NR CELL RF COOL MODE2 STATE CHANGE     ${pm_files1}
    Validate NR CELL RF COOL MODE3 SAMPLES     ${pm_files1}
    Validate NR CELL RF COOL MODE3 STATE CHANGE     ${pm_files1}

    Validate NR RMOD RF TEMP NORMAL SAMPLES     ${pm_files1}
    Validate NR RMOD RF TEMP INCREASED SAMPLES     ${pm_files1}
    Validate NR RMOD RF TEMP HIGH SAMPLES     ${pm_files1}
    [Teardown]    Run keyword and Ignore Error      Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] CB011114_B_Validate_startSlotBlanking_For_highPrioritizedTraffic_VoNR_multiNR_Cells
    [Tags]  TC_03
    [Setup]   		Run keywords    Suite setup from scratch
	#...                 AND     Suite setup from scratch
#    ...                 AND     Prepare TL with IPHY file change
    ...                 AND     Perform SCF Delta Commissioning with Asoh_fdd_multicell.json
    ...                 AND     Sleep   20s
	...					 AND    Perform SCF Delta Commissioning with VoNR_GBR.json
    ...					AND     Sleep   20s
	...                 AND     Add RadParam to swconfig     "0x580627=1"     "0x5901F5=8"    "0x590204=7"
	...                 "0x590205=9"     IP=192.168.255.129
    ...                 AND     Prepare TL with IPHY file change
	...                 AND     Gnb.Perform gNB reboot
	...                 AND     Sleep       500s      reason=wait for RMOD to comeup
	...                 AND     WTS_Runner_Keywords.Start WTS Using WTS_Runner      ${wts_cfg_file}

#	Perform SCF Delta Commissioning with VoNR_GBR.json
 #   Sleep   20s
    set test variable     ${LOG_PATH}
    log to console   UE attach trigerring now...

    start log     cprt    btslog
    MultiUE Register should be Successful     ${st_ue_id_2}    ${en_ue_id_2}    pdu_id=1    nw_id=1
    MultiUE PDU Modfication should be Successful     ${st_ue_id_2}    ${en_ue_id_2}    pdu_id=1   qosflows_to_add=2
    Sleep   2s
    MultiUE Trigger DL Traffic for SA    ${st_ue_id_2}    ${en_ue_id_2}    Traffic_rate=mbps     dl_rate=140
    ...                                  pdu_id=1    trf_id=1       qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${st_ue_id_2}    ${en_ue_id_2}    Traffic_rate=mbps     ul_rate=30
    ...                                  pdu_id=1    trf_id=1       qfi_id=2
    MultiUE PDU Modfication should be Successful     ${st_ue_id_2}    ${en_ue_id_2}      pdu_id=1      qosflows_to_add=3
    Trigger MultiUE VoNR DL Traffic with multiple trfids    ${st_ue_id_2}    ${en_ue_id_2}
    ...     pdu_id=1     num_trf_id=3     qfi_id=3    rtp_codec=custom
    ${scene1}    Stop log      cprt     btslog      test_scenario=UE_Attach
    sleep       3s

#    start log     btslog     cprt
#    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-3       update      disableSchedAssistRfCooling        false
#    Modify NIDD parameters        MRBTS-1/NRBTS-1/NRCELL-3       update      allowGBRMutingForRfCooling     On
#    ${scene2}    Stop log      cprt     btslog     test_scenario=Feature_Activation
#    sleep       3s

    start log     cprt      btslog     ttitrace
    Start Slot Muting    ${startMutingParam}
    sleep   5s
    ${scene3}    Stop log     ttitrace    cprt    btslog     test_scenario=Level1_HIGH_Slot_muting
    sleep       3s

    start log     cprt     btslog     ttitrace
    Start Slot Muting    ${startMutingParam}
    sleep   5s
    ${scene4}    Stop log     ttitrace    cprt    btslog     test_scenario=Level2_HIGH_Slot_muting


    sleep       3s

    start log     cprt     btslog     ttitrace
    Start Slot Muting    ${startMutingParam}
    sleep   5s
    ${scene5}    Stop log     ttitrace    cprt    btslog    test_scenario=Level3_HIGH_Slot_muting
    sleep       3s

    Stop Slot Muting    ${stopMutingParam}
    Stop Slot Muting    ${stopMutingParam}
    Stop Slot Muting    ${stopMutingParam}
    start log     cprt     btslog     ttitrace
    sleep   5s
    ${scene6}   Stop log    ttitrace    cprt    btslog    test_scenario=Level0_Normal_Slot_muting
    sleep   3s
#
#    Validate DL Traffic For MultiUE for SA    ${st_ue_id_2}    ${en_ue_id_2}     dl_rate=140     pdu_id=1     qfi_id=1
#    Validate UL Traffic For MultiUE for SA    ${st_ue_id_2}    ${en_ue_id_2}     ul_rate=30     pdu_id=1     qfi_id=1
    MultiUE Deregister should be Successful      ${st_ue_id_2}    ${en_ue_id_2}

    Decode TTI Trace    Level1_HIGH_Slot_muting
    Decode TTI Trace    Level2_HIGH_Slot_muting
    Decode TTI Trace    Level3_HIGH_Slot_muting
    Decode TTI Trace    Level0_Normal_Slot_muting

    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${scene3}[ttitrace]/output_dl_formated.csv
    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${scene4}[ttitrace]/output_dl_formated.csv
    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${scene5}[ttitrace]/output_dl_formated.csv
    Verify slotMutedForRfCooling for nonUeSpecificPriorityInSlot     ${scene6}[ttitrace]/output_dl_formated.csv
    Verify targetMutingRatio for blankedSlots in ttitrace     ${scene3}[ttitrace]/output_dl_formated.csv     24
    Verify targetMutingRatio for blankedSlots in ttitrace     ${scene4}[ttitrace]/output_dl_formated.csv     43
    Verify targetMutingRatio for blankedSlots in ttitrace     ${scene5}[ttitrace]/output_dl_formated.csv     59

    [Teardown]    Run keyword and Ignore Error      Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Modify IPHY File And Send to Airphone Custom
    [Arguments]    ${iphy_path}    ${frag}=${-1}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML Custom   ${iphy_path}    ${frag}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
    ${RRU_Version}    Get RRU Version From TargetBD File Custom    ${RRU_type}    ${OUTPUT_DIR}
    Modify RRU Version Of IPHY XML Custom    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
    Send IPHY XML To Airphone custom local    ${iphy_path}
    END

Send IPHY XML To Airphone custom local
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
    ...    "${RRU_type[0]}"=="AHEH"    ${RRU_type[0]}
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


Introduce pathloss
    [Arguments]    ${start_ue_id}    ${end_ue_id}	${loss}=75
    FOR  ${ue_idx}   IN RANGE   ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ul_sinr_testmode_nr    profile_id=3    pathloss=${loss}
    END

Activate pathloss_for_UE
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR  ${ue_idx}   IN RANGE   ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr        id=${ue_idx}     testmode=ul_sinr        profile_id=3        action=activate
    END

Introduce csi_override_cqi
    [Documentation]    This keyword introduces csi_override testmode command
    [Arguments]    ${cqi}
    wtsrunner.csi_override_testmode_nr    profile_id=2    cqi=${cqi}     cqi_mode=fixed
    wtsrunner.csi_override_testmode_nr      profile_id=2
    sleep    5s

Activate csi_override_for_UE
    [Documentation]    This keyword activate csi_override testmode for n UEs
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_testmode_set_nr        id=${ue_idx}        scell=0       testmode=csi_override       profile_id=2        action=activate
    END

Vary pathloss
    [Arguments]    ${pathloss_start_dB}=75    ${pathloss_end_dB}=130    ${pathloss_step_dB}=1
    FOR    ${pathloss}    IN RANGE    ${pathloss_start_dB}    ${pathloss_end_dB}    ${pathloss_step_dB}
    wtsrunner.ul_sinr_testmode_nr    profile_id=3    pathloss=${pathloss}
    END

*** Settings ***
Documentation    Scenario specific keywords for feature CB005935 "Inter band FDD UL CA 2CCs"
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.wts                                                   WITH NAME  wts
Resource   ./../resources/CB005935_initial_commissioning.robot
Resource   ./../resources/CB005935_initial_commissioning_BB001.robot
Resource   ./../resources/CB005935_initial_commissioning_BB_B2_and_BB_B3.robot
Resource   ./../resources/CB005935_initial_commissioning_C001.robot
Resource   ./../resources/CB005935_initial_commissioning_BD_B3.robot
Resource   ./../resources/CB005935_test_cases.robot



*** Keywords ***


#-----------For Test Execution ------------------------------------------------------------------------------------------------------[150 characters]

Run Scenario specific Keywords before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    run keyword and continue on failure    run keywords    @{scenario_specific_keywords}
    log    The following Keywords were Run: ${scenario_specific_keywords}


Run Feature specific keywords before attach
    RETURN


Run Feature specific keywords after attach before traffic is started
    IF    'BB_B2' in '${scenario_name}'      CB005935-BB-B2_Single_F+F_UL_2CCs_CA_UE_call_with_NACK_flood_triggered
    IF    'BB_B3' in '${scenario_name}'      CB005935_BB_B3_Interworking_with_uplink_closed_loop_power_control
    IF    'BB001' in '${scenario_name}'      CB005935-ET-BB001_FF ULCA IWK with overheating UAI
    IF    'C001' in '${scenario_name}'       CB005935_C001_FF_ULCA_IWK_with_9059
    IF    'BD_B3' in '${scenario_name}'      CB005935-BD-B3_1_Interworking_with_CB008246_Link_Adaptation_for_HR_DRB_on_all_cells


Run Feature specific keywords during traffic before detach
    [Arguments]  ${traffic_duration}
    Sleep  ${traffic_duration}


Run Feature specific keywords after traffic before detach
    RETURN


Run Feature specific keywords after detach
    RETURN



#-----------For Suite Setup----------------------------------------------------------------------------------------------------------[150 characters]

Make necessary changes to SCF
    IF  'C B4' in '${SUITE_NAME}'   RETURN
    Change RD Parameters in swconfig File for CB005935
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    scf.load_scf    ${original_gnb_scf}
        Change Reporting Interval  interval_duration=${pm_reporting_interval}
        IF                'BB001' in '${SUITE_NAME}'    Enable some Functionality according to CFAM for BB001
        ...    ELSE IF    'BB B2 and BB B3' in '${SUITE_NAME}'    Enable some Functionality according to CFAM for BB_B2_and_BB_B3
        ...    ELSE IF    'C001' in '${SUITE_NAME}'     Enable some Functionality according to CFAM for C001
        ...    ELSE IF    'BD_B3' in '${SUITE_NAME}'     Enable some Functionality according to CFAM for BD_B3
        IF                'BB001' in '${SUITE_NAME}'    Cfg CB005935 for FDD Cells for BB001
        ...    ELSE IF    'BB B2 and BB B3' in '${SUITE_NAME}'    Cfg CB005935 for FDD Cells for BB_B2_and_BB_B3
        ...    ELSE IF    'C001' in ' ${SUITE_NAME}'    Cfg CB005935 for FDD Cells for C001
        ...    ELSE IF    'BD_B3' in ' ${SUITE_NAME}'    Cfg CB005935 for FDD Cells for BD_B3
        IF                'BB001' in '${SUITE_NAME}'    Cfg CB005935 for NRREL for PCell for BB001    ${sCellAdditionMethod}
        ...    ELSE IF    'BB B2 and BB B3' in '${SUITE_NAME}'    Cfg CB005935 for NRREL for PCell for BB_B2_and_BB_B3    ${sCellAdditionMethod}
        ...    ELSE IF    'C001' in ' ${SUITE_NAME}'    Cfg CB005935 for NRREL for PCell for C001    ${sCellAdditionMethod}
        ...    ELSE IF    'BD_B3' in ' ${SUITE_NAME}'    Cfg CB005935 for NRREL for PCell for BD_B3    ${sCellAdditionMethod}
        IF    'BB001' in '${SUITE_NAME}'   Cfg CB005935 NRHOIF for BB001
        IF    'C001' in '${SUITE_NAME}'
            Configure new NRDRB-16
            Configure new 5QI-7 and set it to 2 and connect it to NRDRB-16
            Configure new MAC-5
        END
        Cfg FDD Cells with 4DL4UL
        Activate CB009267
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
    scf.save_scf    ${configuration_directory}/SCF_updated.xml
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${oam_alias}=    connect.Setup OAM http session
    admin.perform_commissioning  scf_file=${configuration_directory}/SCF_updated.xml  connection=${oam_alias}
    ...  skip_parameter_relation_errors=True  timeout=600
    connect.Teardown OAM http session



#-----------For swconfig.txt Changes-------------------------------------------------------------------------------------------------[150 characters]

Change RD Parameters in swconfig File for CB005935
    @{5935_rd_params}=  create list
    ...    0x580161=5   # rdMinCrcNackIndUlEnhanced for Pcell
    Update SW Config file on System Module  param_list=${5935_rd_params}



#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Update Basic Configuration File
    wts.Load Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}
      wts.Insert    ue_param id=1 nr_usage_setting=voice_centric                                         after    ue_param id=1
      wts.Insert    set_qosflow id=2 5qi=5                                                               after    set_qosflow id=1
      wts.Insert    set_qosflow id=3 5qi=1                                                               after    set_qosflow id=2
      wts.Insert    set_qosflow id=4 5qi=2 gfbr_dl=30720 gfbr_ul=29696 mfbr_dl=30720 mfbr_ul=29696       after    set_qosflow id=3
      wts.Insert    set_qosflow id=5 5qi=3                                                               after    set_qosflow id=4
      wts.Insert    set_qosflow id=6 5qi=71 gfbr_dl=30720 gfbr_ul=29696 mfbr_dl=30720 mfbr_ul=29696      after    set_qosflow id=5
      wts.Insert    set_qosflow id=7 5qi=9                                                               after    set_qosflow id=6
      wts.Insert    set_qosflow id=8 5qi=7                                                               after    set_qosflow id=7
      wts.Insert    set_qosflow id=9 5qi=80                                                              after    set_qosflow id=8
      wts.Insert    set_qosrule id=1 proto=udp qos_flow=1                                                after    set_qosflow id=9
      wts.Insert    set_qosrule id=2 proto=udp qos_flow=2                                                after    set_qosrule id=1
      wts.Insert    set_qosrule id=3 proto=udp qos_flow=3                                                after    set_qosrule id=2
      wts.Insert    set_qosrule id=4 proto=udp qos_flow=4                                                after    set_qosrule id=3
      wts.Insert    set_qosrule id=5 proto=udp qos_flow=5                                                after    set_qosrule id=4
      wts.Insert    set_qosrule id=6 proto=udp qos_flow=6                                                after    set_qosrule id=5
      wts.Insert    set_qosrule id=7 proto=udp qos_flow=7                                                after    set_qosrule id=6
      wts.Insert    set_qosrule id=8 proto=udp qos_flow=8                                                after    set_qosrule id=7
      wts.Insert    set_qosrule id=9 proto=udp qos_flow=9                                                after    set_qosrule id=8
      wts.Modify    nwslice_set id=1    modification=qos_flows=1,2,3,4,5,6,7,8,9 qos_rules=1,2,3,4,5,6,7,8,9
      wts.Insert    amf_param id=1 empty_pdu_session_list=on send_ics_registration=on                    after    nwslice_set id=1
      #------------------------------------------------------------------------------------------------------------------------------[150 characters]
      ${SUITE PATH}=  tools.get_directory   ${SUITE SOURCE}
    wts.Save Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

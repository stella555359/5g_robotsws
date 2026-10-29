*** Settings ***
Documentation    Scenario specific keywords for subfeature CB008246-G of "LA for HR DRBs"

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.wts                                       WITH NAME   wts
Library    taf.sbts.oam.coam.admin                              WITH NAME   admin
Library    ../libraries/tools_8246.py                           WITH NAME   tools_8246
Resource   ../../../../resources/Common/gnb.robot
Resource   ../resources/CB008246_initial_commissioning.robot
Resource   ../resources/CB008246_test_cases.robot



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
    IF    'TC01' in '${scenario_name}'
        TC01_HrDrbPdsch_SA_multiDRB_nonGBR_MultiUE
    ELSE IF    'TC02' in '${scenario_name}'
        TC02_HrDrbPdsch_SA_multiDRB_nonGBR_FDD
    ELSE IF    'TC03' in '${scenario_name}'
        TC03_HrDrbPdsch_SA_multiDRB_nonGBR_OnlineModify_multiUE
    ELSE IF    'TC04_1' in '${scenario_name}'
        TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance1
    ELSE IF    'TC04_2' in '${scenario_name}'
        TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance2
    ELSE IF    'TC04_3' in '${scenario_name}'
        TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance3
    ELSE IF    'TC04_4' in '${scenario_name}'
        TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance4
    ELSE IF    'TC07' in '${scenario_name}'
        TC07_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_FDD
    ELSE IF    'TC08' in '${scenario_name}'
        TC08_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_OnlineModify_NRCELL_multiUE
    ELSE IF    'TC09' in '${scenario_name}'
        TC09_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_OnlineModify_NRBTS_multiUE
    ELSE IF    'TC10' in '${scenario_name}'
        TC10_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_IWK_NACKflood_DLFB_BRDRB_PMC
    ELSE IF    'TC11' in '${scenario_name}'
        TC11_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_HRDRB_PMC
    ELSE IF    'TC12' in '${scenario_name}'
        TC12_HrDrbPdsch_SA_multiDRB_GBR_FDD
    ELSE IF    'TC13' in '${scenario_name}'
        TC13_HrDrbPdsch_SA_multiDRB_GBR_PDCCH_AL_Dynamic_multiUE
    ELSE IF    'TC14' in '${scenario_name}'
        TC14_HrDrbPdsch_SA_multiDRB_DiffGBR_mixedUEtype
    ELSE IF    'TC15' in '${scenario_name}'
        TC15_HrDrbPdsch_SA_multiDRB_GBR_noLowSeUe
    END


Run Feature specific keywords during traffic before detach
    [Arguments]  ${traffic_duration}
    Sleep  ${traffic_duration}


Run Feature specific keywords after traffic before detach
    RETURN


Run Feature specific keywords after detach
    RETURN



#-----------For Suite Setup----------------------------------------------------------------------------------------------------------[150 characters]

Make necessary changes to SCF
    Change RD Parameters in swconfig File for CB008246
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    IF    'FDD' in '${SUITE_NAME}'
        Set Suite Variable    ${NRCELL_ID}    2
    ELSE
        Set Suite Variable    ${NRCELL_ID}    0
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    scf.load_scf    ${original_gnb_scf}
        Set SW POSTFIX Variable to FDD or TDD or ASOH
        Change Reporting Interval for CB008246  interval_duration=${pm_reporting_interval}
        Configure new NRDRB-17
        Configure new NRDRB-16
        Configure new NRDRB-18
        Configure new NRDRB-19
        Activate CB008246    dllaBlerTargetHR_1=${dllaBlerTargetHR_1}
        ...                  dllaBlerTargetHR_2=${dllaBlerTargetHR_2}
        ...                  NRPDSCHHRLA_1_5QI6=${NRPDSCHHRLA_1_5QI6}
        ...                  NRPDSCHHRLA_2_5QI2=${NRPDSCHHRLA_2_5QI2}
        ...                  NRPDSCHHRLA_3_5QI3=${NRPDSCHHRLA_3_5QI3}
        ...                  NRPDSCHHRLA_4_5QI9=${NRPDSCHHRLA_4_5QI9}
        ...                  NRPDSCHHRLA_5_5QI7=${NRPDSCHHRLA_5_5QI7}
        ...                  NRPDSCHHRLA_6_5QI71=${NRPDSCHHRLA_6_5QI71}
        ...                  NRPDSCHHRLA_7_5QI80=${NRPDSCHHRLA_7_5QI80}
        Configure SCF File for dciDedicatedAggregationLevelHR
        IF    'AL Dynamic' in '${SUITE_NAME}'    Configure SCF File for subfeature CB008246-B
        Configure GBR for SA UEs in SCF File
        Configure new 5QI-7 and set it to 2 and connect it to NRDRB-16
        Configure new 5QI-8 and set it to 3 and connect it to NRDRB-17
        Configure new 5QI-9 and set it to 71 and connect it to NRDRB-18
        Configure new 5QI-10 and set it to 80 and connect it to NRDRB-19
        Configure new MAC-5
        IF    not 'ASOH' in '${SUITE_NAME}'    Activate 5GC002271
    scf.save_scf    ${configuration_directory}/SCF_updated.xml
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${oam_alias}=    connect.Setup OAM http session
    admin.Perform Commissioning  scf_file=${configuration_directory}/SCF_updated.xml  connection=${oam_alias}
    ...  skip_parameter_relation_errors=False  timeout=300
    connect.Teardown OAM http session



#-----------For swconfig.txt Changes-------------------------------------------------------------------------------------------------[150 characters]

Change RD Parameters In Swconfig File For CB008246
    @{8246_rd_params}=  Create List
    ...    0x58071F=5 #L2PS_CB008246_Default:_0xa_rdMinHarqNackIndDlHR
    IF    'OLLA' in '${SUITE_NAME}'    Collections.Set List Value    ${8246_rd_params}    1    0x58071F=0xa
    gnb.Update SW Config File On System Module  param_list=${8246_rd_params}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Update Basic Configuration File
    wts.Load Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}
      run keyword and ignore error    wts.Delete    ue_param id=1 nr_usage_setting=voice_centric
      run keyword and ignore error    wts.Delete    set_qosflow id=4
      run keyword and ignore error    wts.Delete    set_qosflow id=5
      run keyword and ignore error    wts.Delete    set_qosflow id=6
      run keyword and ignore error    wts.Delete    set_qosflow id=7
      run keyword and ignore error    wts.Delete    set_qosflow id=8
      run keyword and ignore error    wts.Delete    set_qosflow id=9
      run keyword and ignore error    wts.Delete    set_qosrule id=1
      run keyword and ignore error    wts.Delete    set_qosrule id=2
      run keyword and ignore error    wts.Delete    set_qosrule id=3
      run keyword and ignore error    wts.Delete    set_qosrule id=4
      run keyword and ignore error    wts.Delete    set_qosrule id=5
      run keyword and ignore error    wts.Delete    set_qosrule id=6
      run keyword and ignore error    wts.Delete    set_qosrule id=7
      run keyword and ignore error    wts.Delete    set_qosrule id=8
      run keyword and ignore error    wts.Delete    set_qosrule id=9
      run keyword and ignore error    wts.Delete    amf_param id=1 empty_pdu_session_list=on send_ics_registration=on
      wts.Insert    ue_param id=1 nr_usage_setting=voice_centric                                         after    ue_param id=1
      wts.Insert    set_qosflow id=4 5qi=2 gfbr_dl=30720 gfbr_ul=29696 mfbr_dl=30720 mfbr_ul=29696       after    set_qosflow id=3
      wts.Insert    set_qosflow id=5 5qi=3 gfbr_dl=30720 gfbr_ul=29696 mfbr_dl=30720 mfbr_ul=29696       after    set_qosflow id=4
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
      ${ue_nr_capabilities}=  tools.read_dictionary_from_json   ${SUITE PATH}/resources/CB008246_UE_NR_Capability.json
      IF    '${SW_POSTFIX}'=='FDD'
            wts.Modify    ue_param id=1    ue_nr_capabilities=${ue_nr_capabilities['FDD']}
      ELSE
            wts.Modify    ue_param id=1    ue_nr_capabilities=${ue_nr_capabilities['TDD']}
      END
    wts.Save Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}


Set SW POSTFIX Variable to FDD or TDD or ASOH
    IF    'FDD' in '${SUITE_NAME}'
        Set Suite Variable    ${SW_POSTFIX}    FDD
    ELSE
        Set Suite Variable    ${SW_POSTFIX}    TDD
    END
    IF    'ASOH' in '${SUITE_NAME}'    Set Suite Variable    ${SW_POSTFIX}    ASOH


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

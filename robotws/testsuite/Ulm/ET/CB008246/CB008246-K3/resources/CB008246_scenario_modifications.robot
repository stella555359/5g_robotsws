*** Settings ***
Documentation    Scenario specific keywords for subfeature CB008246-K#3 of "LA for HR DRBs"

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.wts                                                   WITH NAME  wts
Resource   ./../resources/CB008246_initial_commissioning.robot
Resource   ./../resources/CB008246_test_cases.robot



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
    IF    'TC03' in '${scenario_name}'      TC03_HR_IWK_CA_UL_SA_2CC_FDDTDD_HRDRB_after_SCell_Addition
    IF    'TC04' in '${scenario_name}'      TC04_HR_IWK_CA_UL_SA_2CC_FDDTDD_SCell_Addition_after_HRDRB
    IF    'TC07_TC09' in '${scenario_name}'    TC07_TC09_HR_IWK_CA_UL_SA_2CC_FDDTDD_HRDRB_ACSI_DFT-s-OFDM


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
    scf.load_scf    ${original_gnb_scf}
        Set SW POSTFIX Variable to FDD or TDD
        Change Reporting Interval for CB008246  interval_duration=${pm_reporting_interval}
        Disable some Functionality according to CFAM
        Configure new NRDRB-17
        Configure new NRDRB-16
        Configure new NRDRB-18
        Configure new NRDRB-19
        Configure new NRDRB_PDCP-2
        Configure new NRDRB_RLC_UM-1
        Activate CB008246    ullaBlerTargetHR_1=${ullaBlerTargetHR_1}
        ...                  ullaBlerTargetHR_2=${ullaBlerTargetHR_2}
        ...                  NRPUSCHHRLA_2_5QI3=${NRPUSCHHRLA_2_5QI3}
        ...                  NRPUSCHHRLA_3_5QI9=${NRPUSCHHRLA_3_5QI9}
        ...                  NRPUSCHHRLA_4_5QI7=${NRPUSCHHRLA_4_5QI7}
        ...                  NRPUSCHHRLA_5_5QI71=${NRPUSCHHRLA_5_5QI71}
        ...                  NRPUSCHHRLA_6_5QI80=${NRPUSCHHRLA_6_5QI80}
        Configure GBR for SA UEs in SCF File
        Configure new 5QI-7 and set it to 2 and connect it to NRDRB-16
        Configure new 5QI-8 and set it to 3 and connect it to NRDRB-17
        Configure new 5QI-9 and set it to 71 and connect it to NRDRB-18
        Configure new 5QI-10 and set it to 80 and connect it to NRDRB-19
        Configure new MAC-5
        IF    'K7' in '${SUITE_NAME}' or 'K9' in '${SUITE_NAME}'    Activate ACSI and DFT-S-OFDM Functionality
        Activate CB009267
    scf.save_scf    ${configuration_directory}/SCF_updated.xml
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${oam_alias}=    connect.Setup OAM http session
    admin.perform_commissioning  scf_file=${configuration_directory}/SCF_updated.xml  connection=${oam_alias}
    ...  skip_parameter_relation_errors=False  timeout=300
    connect.Teardown OAM http session


#-----------For swconfig.txt Changes-------------------------------------------------------------------------------------------------[150 characters]

Change RD Parameters in swconfig File for CB008246
    @{8246_rd_params}=  create list
    ...    0x5806F2=0x1f  # L2PS,  CB008246, Default: 0x1, rdEnableAndDisableSubFeatures8246,
                          #    LSB bit1: activates(1)/deactivate(0) CB008246-H
                          #        bit2: consider(1)/ignore(0) PUSCH criteria in UL-PDCCH switch algo to recover from BR to HR
                          #        bit3: consider(1)/ignore(0) PDSCH criteria in DL-PDCCH switch algo to recover from BR to HR
                          #        bit4: activates(1)/deactivate(0) CB008246-G
                          #        bit5: activates(1)/deactivate(0) CB008246-I (not yet implemented)
    ...    0x58071F=5      # L2PS, CB008246, Default: 0xa, rdMinHarqNackIndDlHR
    Update SW Config file on System Module  param_list=${8246_rd_params}


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


Set SW POSTFIX Variable To FDD Or TDD
    ${exists}=    Run Keyword And Return Status    Variable Should Exist    ${SW_DUPLEX}
    IF    ${exists}    Set Suite Variable    ${SW_POSTFIX}    ${SW_DUPLEX}
    ...       ELSE    Set SW POSTFIX Variable To FDD Or TDD In OFFLINE


Set SW POSTFIX Variable to FDD or TDD in OFFLINE
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${path_to_scf_xml}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    scf.load_scf    ${path_to_scf_xml}
    ${cellTechnology}=    scf.get_value_from_scf    p_name=cellTechnology    dist_name=${distName_NRCELL}[0]
    ${SW_POSTFIX}=    set variable if    '${cellTechnology}'=='FDD'    FDD    TDD
    set suite variable    ${SW_POSTFIX}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

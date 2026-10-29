*** Settings ***
Documentation    Scenario specific keywords for CB011006 subfeatures

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.wts                      WITH NAME    wts
Library    ./../libraries/CB011006_tools.py    WITH NAME    CB011006_tools

Resource   ./../resources/CB011006_initial_commissioning.robot
Resource   ./../resources/CB011006_initial_commissioning_CA.robot
Resource   ./../resources/CB011006_initial_commissioning_B03.robot
Resource   ./../resources/CB011006_initial_commissioning_B05.robot
Resource   ./../resources/CB011006_initial_commissioning_B12.robot
Resource   ./../resources/CB011006_initial_commissioning_B13.robot
Resource   ./../resources/CB011006_initial_commissioning_B16.robot
Resource   ./../resources/CB011006_initial_commissioning_B17.robot
Resource   ./../resources/CB011006_initial_commissioning_B19.robot
Resource   ./../resources/CB011006_common_keywords.robot
Resource  ../../L2/resources/TEAL_additional_keywords.robot



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
    IF    'B13' in '${SUITE_NAME}'    Send measurement report for NRDC initialization


Run Feature specific keywords during traffic before detach
    [Arguments]  ${traffic_duration}
    sleep    ${traffic_duration}    reason=wait for traffic



Run Feature specific keywords after traffic before detach
    RETURN


Run Feature specific keywords after detach
    RETURN



#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]

Make necessary changes to SCF
    IF    'B13' in '${SUITE_NAME}'    Change RD Parameters in swconfig File for IWK13
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${is_variable_exist}    run keyword and return status    variable should exist    ${gscn_fdd_cell_1}
    IF    not ${is_variable_exist}    set suite variable    ${gscn_fdd_cell_1}    6636
    ${is_variable_exist}    run keyword and return status    variable should exist    ${gscn_fdd_cell_2}
    IF    not ${is_variable_exist}    set suite variable    ${gscn_fdd_cell_2}    4604
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    IF    'B11' in '${SUITE_NAME}'    Modify iphy.xml for 1FDD+3TDD Setup
    ...    ELSE IF    'B12' in '${SUITE_NAME}'    Modify iphy.xml for 3FDD+4TDD Setup
    ...    ELSE IF    'B13' in '${SUITE_NAME}'    Modify iphy.xml for 1FDD Setup
    ...    ELSE IF    'B17' in '${SUITE_NAME}'    Modify iphy.xml for 3FDD Setup
    ...    ELSE IF    'ABIP' in '${SUITE_NAME}'   Modify iphy.xml for 2FDD Setup
    ...    ELSE                                   Modify iphy.xml for 2TDD+2FDD Setup
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    scf.load_scf    ${original_gnb_scf}
    IF    'B11' in '${SUITE_NAME}'    Modify scf.xml for 1FDD+3TDD Setup
    ...    ELSE IF    'B13' in '${SUITE_NAME}'    Modify scf.xml for 1FDD Setup
    ...    ELSE IF    'B16' in '${SUITE_NAME}'    Modify scf.xml for 2TDD+2FDD only n7 Setup
    ...    ELSE                                   Modify scf.xml for 2TDD+2FDD Setup
        #--- sub-feature specific changes: ------------------------------------------------------------------------------------------[150 characters]
        IF    'B05' in '${SUITE_NAME}'    Initial commissioning for IWK05
        ...    ELSE IF    'B06' in '${SUITE_NAME}'    Activate DL CA for 2TDD+2FDD Setup
        ...    ELSE IF    'B07' in '${SUITE_NAME}'    Activate DL CA for 2TDD+2FDD Setup
        ...    ELSE IF    'B08' in '${SUITE_NAME}'    Activate DL CA for 2TDD+2FDD Setup
        ...    ELSE IF    'B09' in '${SUITE_NAME}'    Activate UL CA for 2TDD+2FDD Setup
        ...    ELSE IF    'B12' in '${SUITE_NAME}'    Initial commissioning for IWK12
        ...    ELSE IF    'B13' in '${SUITE_NAME}'    Initial commissioning for IWK13
        ...    ELSE IF    'B16' in '${SUITE_NAME}'    Initial commissioning for IWK16
        ...    ELSE IF    'B17' in '${SUITE_NAME}'    Initial commissioning for IWK17
        ...    ELSE IF    'B19' in '${SUITE_NAME}'    Initial commissioning for IWK19
        ...    ELSE IF    'TranRob Endurance CA FDD TDD' in '${SUITE_NAME}'    Activate UL CA for 2TDD+2FDD Setup
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
    scf.save_scf    ${configuration_directory}/SCF_updated.xml
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Perform Commissioning On Classical BTS    ${configuration_directory}/SCF_updated.xml


Perform Commissioning On Classical BTS
    [Arguments]  ${scf_file}
    ${oam_alias}=  connect.Setup OAM HTTP Session
    admin.Perform Commissioning    scf_file=${scf_file}
    ...                              connection=${oam_alias}
    ...                              skip_parameter_relation_errors=False
    ...                              timeout=300
    connect.Teardown OAM HTTP Session


Change Reporting Interval
    [Arguments]    ${interval_duration}
    ${distName_NRPMRNL}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    @{list_of_pm_groups}=  create list  miNrCellAvailability  miNrCellUtilization  miNrTimingAdvance  miNrUlSignalQuality  miNrXnInterface
    ...                                 miNrHighRlcReport     miNrLowRlcReport     miNrMacPduTput     miNrPDCP1Report      miNrPDCP2Report
    ...                                 miNrPDCPCell          miNrRlfPerCell       miNrX2CB           miNrX2CC             miNrX2UInterface
    ...                                 miNrUlHarq            miNrDlHarq           miNrXnCCInterface
    FOR   ${pname}  IN   @{list_of_pm_groups}
        scf.modify scf element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=${pname}
    END
    ${distName_PMCADM}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_PMCADM[0]}   p_name=reportingIntervalPm



#-----------For basic_setup.cfg Changes----------------------------------------------------------------------------------------------[150 characters]

Update Basic Configuration File
    wts . Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
        IF    'B11' in '${SUITE_NAME}'    Modify basic_setup.cfg for 1FDD+3TDD Setup
        ...    ELSE IF    'B06' in '${SUITE_NAME}'    Modify basic_setup.cfg for intra-band 2TDD+2FDD Setup
        ...    ELSE IF    'B12' in '${SUITE_NAME}'    Modify basic_setup.cfg for 3FDD+4TDD Setup
        ...    ELSE IF    'B13' in '${SUITE_NAME}'    Modify basic_setup.cfg for 1FDD+1TDD Setup
        ...    ELSE IF    'B16' in '${SUITE_NAME}'    Modify basic_setup.cfg for 2TDD+2FDD only n7 setup
        ...    ELSE IF    'B17' in '${SUITE_NAME}'    Modify basic_setup.cfg for 3FDD Setup
        ...    ELSE IF    'B19' in '${SUITE_NAME}'    Modify basic_setup.cfg for intra-band 2TDD+2FDD Setup
        ...    ELSE                                   Modify basic_setup.cfg for 2TDD+2FDD setup
    wts . Save Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}


Modify basic_setup.cfg for 2TDD+2FDD Setup
    wts . Modify    set_cell id=${fdd_cell_1} gnb=2    nr_arfcn=507000:531000 gscn=${gscn_fdd_cell_1}
    wts . Modify    set_cell id=${fdd_cell_2} gnb=2    nr_arfcn=349500:368500 gscn=${gscn_fdd_cell_2}


Modify basic_setup.cfg for 2TDD+2FDD only n7 setup
    wts . Modify    set_cell id=${fdd_cell_1} gnb=2    nr_arfcn=507000:531000 gscn=${gscn_fdd_cell_1}
    wts . Modify    set_cell id=${fdd_cell_2} gnb=2    nr_arfcn=507000:531000 gscn=${gscn_fdd_cell_1}


Modify basic_setup.cfg for intra-band 2TDD+2FDD Setup
    wts . Modify    set_cell id=${fdd_cell_1} gnb=2    nr_arfcn=${arfcnUl_fdd_cell_1}:${arfcnDl_fdd_cell_1} gscn=${gscn_fdd_cell_1}
    wts . Modify    set_cell id=${fdd_cell_2} gnb=2    nr_arfcn=${arfcnUl_fdd_cell_2}:${arfcnDl_fdd_cell_2} gscn=${gscn_fdd_cell_2}


Modify basic_setup.cfg for 2FDD Setup
    wts . Modify    set_cell id=${fdd_cell_1} gnb=2    nr_arfcn=507000:531000 gscn=${gscn_fdd_cell_1}
    wts . Modify    set_cell id=${fdd_cell_2} gnb=2    nr_arfcn=349500:368500 gscn=${gscn_fdd_cell_2}


Modify basic_setup.cfg for 3FDD Setup
    wts . Modify    set_cell id=1 gnb=2    nr_arfcn=507000:531000 gscn=${gscn_fdd_cell_1}
    wts . Modify    set_cell id=2 gnb=2    nr_arfcn=507000:531000 gscn=${gscn_fdd_cell_1}
    wts . Modify    set_cell id=3 gnb=2    nr_arfcn=507000:531000 gscn=${gscn_fdd_cell_1}


Modify basic_setup.cfg for 1FDD+1TDD Setup
    wts . Modify    set_cell id=${fdd_cell_1} gnb=2    nr_arfcn=507000:531000 gscn=${gscn_fdd_cell_1}


Modify basic_setup.cfg for 1FDD+3TDD Setup
    wts . Modify    set_cell id=${fdd_cell_1} gnb=2    nr_arfcn=507000:531000 gscn=${gscn_fdd_cell_1}


Modify basic_setup.cfg for 3FDD+4TDD Setup
    wts . Modify    set_cell id=${fdd_cell_1} gnb=2    nr_arfcn=${arfcnUl_fdd_cell_1}:${arfcnDl_fdd_cell_1} gscn=${gscn_fdd_cell_1}
    wts . Modify    set_cell id=${fdd_cell_2} gnb=2    nr_arfcn=${arfcnUl_fdd_cell_2}:${arfcnDl_fdd_cell_2} gscn=${gscn_fdd_cell_2}
    wts . Modify    set_cell id=${fdd_cell_3} gnb=2    nr_arfcn=${arfcnUl_fdd_cell_3}:${arfcnDl_fdd_cell_3} gscn=${gscn_fdd_cell_3}



#-----------For iphy.xml Changes-----------------------------------------------------------------------------------------------------[150 characters]

Modify iphy.xml for 2TDD+2FDD Setup
    ${ru_version}  ${frm_sw}    Get RU Info from TargetBD    ru_type=AHEGHA
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${ap_alias}    connect . Connect to Airphone Common Unit
    ssh . Download File    /rom/simmode/new_iphy.xml    ${configuration_directory}/new_iphy_orig.xml    connection=${ap_alias}
        ${contents}    get file    ${configuration_directory}/new_iphy_orig.xml
        ${all_parts}    split string      ${contents}     </RE>
        ${p0}   set variable   ${all_parts}[0]    # 1st TDD Cell
        ${p1}   set variable   ${all_parts}[1]    # 2nd TDD Cell
        ${p2}   set variable   ${all_parts}[2]    # 1st FDD Cell
        ${p3}   set variable   ${all_parts}[3]    # 2nd FDD Cell
        ${p4}   set variable   ${all_parts}[4]    # last part of the iphy.xml file
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${p2}   replace string using regexp   ${p2}   cardName>.*<\/cardName>   cardName>AHEGHA<\/cardName>
        ${p2}   replace string using regexp   ${p2}   bldVersion>.*<\/bldVersion>   bldVersion>${ru_version}<\/bldVersion>
        ${p2}   replace string using regexp   ${p2}   buildversion>.*<\/buildversion>   buildversion>${ru_version}<\/buildversion>
        ${p2}   replace string using regexp   ${p2}   resourceBuildKey>.*<\/resourceBuildKey>   resourceBuildKey>LTX_AHEGHA<\/resourceBuildKey>
        ${p2}   replace string using regexp   ${p2}   GSCN>.*<\/GSCN>   GSCN>${gscn_fdd_cell_1}<\/GSCN>
        ${p2}   replace string using regexp   ${p2}   name>.*tar<\/name>   name>${frm_sw}<\/name>
        ${p2}   replace string using regexp   ${p2}   version>.*<\/version>   version>${ru_version}<\/version>
        ${p2}    remove string using regexp   ${p2}   <fddFrequencyRange>.*<\/fddFrequencyRange>
        ${p2}   replace string using regexp   ${p2}   scs>.*<\/scs>   scs>15<\/scs><fddFrequencyRange>FR1_WB<\/fddFrequencyRange>
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${p3}   replace string using regexp   ${p3}   cardName>.*<\/cardName>   cardName>AHEGHA<\/cardName>
        ${p3}   replace string using regexp   ${p3}   bldVersion>.*<\/bldVersion>   bldVersion>${ru_version}<\/bldVersion>
        ${p3}   replace string using regexp   ${p3}   buildversion>.*<\/buildversion>   buildversion>${ru_version}<\/buildversion>
        ${p3}   replace string using regexp   ${p3}   resourceBuildKey>.*<\/resourceBuildKey>   resourceBuildKey>LTX_AHEGHA<\/resourceBuildKey>
        ${p3}   replace string using regexp   ${p3}   GSCN>.*<\/GSCN>   GSCN>${gscn_fdd_cell_2}<\/GSCN>
        ${p3}   replace string using regexp   ${p3}   name>.*tar<\/name>   name>${frm_sw}<\/name>
        ${p3}   replace string using regexp   ${p3}   version>.*<\/version>   version>${ru_version}<\/version>
        ${p3}    remove string using regexp   ${p3}   <fddFrequencyRange>.*<\/fddFrequencyRange>
        ${p3}   replace string using regexp   ${p3}   scs>.*<\/scs>   scs>15<\/scs><fddFrequencyRange>FR1_WB<\/fddFrequencyRange>
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${new contents}      catenate         SEPARATOR=</RE>    ${p0}    ${p1}    ${p2}    ${p3}    ${p4}
        create file    ${configuration_directory}/new_iphy_updated.xml    ${new contents}
    ssh . Upload File       ${configuration_directory}/new_iphy_updated.xml    /rom/simmode/new_iphy.xml   connection=${ap_alias}


Modify iphy.xml for 2FDD Setup
    ${ru_version}  ${frm_sw}    Get RU Info from TargetBD    ru_type=AHEGHA
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${ap_alias}    connect . Connect to Airphone Common Unit
    ssh . Download File    /rom/simmode/new_iphy.xml    ${configuration_directory}/new_iphy_orig.xml    connection=${ap_alias}
        ${contents}    get file    ${configuration_directory}/new_iphy_orig.xml
        ${all_parts}    split string      ${contents}     </RE>
        ${p0}   set variable   ${all_parts}[0]    # 1st FDD Cell
        ${p1}   set variable   ${all_parts}[1]    # 2nd FDD Cell
        ${p2}   set variable   ${all_parts}[2]    # last part of the iphy.xml file
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${p0}   replace string using regexp   ${p0}   cardName>.*<\/cardName>   cardName>AHEGHA<\/cardName>
        ${p0}   replace string using regexp   ${p0}   bldVersion>.*<\/bldVersion>   bldVersion>${ru_version}<\/bldVersion>
        ${p0}   replace string using regexp   ${p0}   buildversion>.*<\/buildversion>   buildversion>${ru_version}<\/buildversion>
        ${p0}   replace string using regexp   ${p0}   resourceBuildKey>.*<\/resourceBuildKey>   resourceBuildKey>LTX_AHEGHA<\/resourceBuildKey>
        ${p0}   replace string using regexp   ${p0}   GSCN>.*<\/GSCN>   GSCN>${gscn_fdd_cell_1}<\/GSCN>
        ${p0}   replace string using regexp   ${p0}   name>.*tar<\/name>   name>${frm_sw}<\/name>
        ${p0}   replace string using regexp   ${p0}   version>.*<\/version>   version>${ru_version}<\/version>
        ${p0}    remove string using regexp   ${p0}   <fddFrequencyRange>.*<\/fddFrequencyRange>
        ${p0}   replace string using regexp   ${p0}   scs>.*<\/scs>   scs>15<\/scs><fddFrequencyRange>FR1_WB<\/fddFrequencyRange>
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${p1}   replace string using regexp   ${p1}   cardName>.*<\/cardName>   cardName>AHEGHA<\/cardName>
        ${p1}   replace string using regexp   ${p1}   bldVersion>.*<\/bldVersion>   bldVersion>${ru_version}<\/bldVersion>
        ${p1}   replace string using regexp   ${p1}   buildversion>.*<\/buildversion>   buildversion>${ru_version}<\/buildversion>
        ${p1}   replace string using regexp   ${p1}   resourceBuildKey>.*<\/resourceBuildKey>   resourceBuildKey>LTX_AHEGHA<\/resourceBuildKey>
        ${p1}   replace string using regexp   ${p1}   GSCN>.*<\/GSCN>   GSCN>${gscn_fdd_cell_2}<\/GSCN>
        ${p1}   replace string using regexp   ${p1}   name>.*tar<\/name>   name>${frm_sw}<\/name>
        ${p1}   replace string using regexp   ${p1}   version>.*<\/version>   version>${ru_version}<\/version>
        ${p1}    remove string using regexp   ${p1}   <fddFrequencyRange>.*<\/fddFrequencyRange>
        ${p1}   replace string using regexp   ${p1}   scs>.*<\/scs>   scs>15<\/scs><fddFrequencyRange>FR1_WB<\/fddFrequencyRange>
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${new contents}      catenate         SEPARATOR=</RE>    ${p0}    ${p1}    ${p2}
        create file    ${configuration_directory}/new_iphy_updated.xml    ${new contents}
    ssh . Upload File       ${configuration_directory}/new_iphy_updated.xml    /rom/simmode/new_iphy.xml   connection=${ap_alias}


Modify iphy.xml for 3FDD Setup
    ${ru_version}  ${frm_sw}    Get RU Info from TargetBD    ru_type=AHEGHA
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${ap_alias}    connect . Connect to Airphone Common Unit
    ssh . Download File    /rom/simmode/new_iphy.xml    ${configuration_directory}/new_iphy_orig.xml    connection=${ap_alias}
        ${contents}    get file    ${configuration_directory}/new_iphy_orig.xml
        ${all_parts}    split string      ${contents}     </RE>
        ${p0}   set variable   ${all_parts}[0]    # 1st FDD Cell
        ${p1}   set variable   ${all_parts}[1]    # 2nd FDD Cell
        ${p2}   set variable   ${all_parts}[2]    # 3rd FDD Cell
        ${p3}   set variable   ${all_parts}[3]    # last part of the iphy.xml file
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${p0}   replace string using regexp   ${p0}   cardName>.*<\/cardName>   cardName>AHEGHA<\/cardName>
        ${p0}   replace string using regexp   ${p0}   bldVersion>.*<\/bldVersion>   bldVersion>${ru_version}<\/bldVersion>
        ${p0}   replace string using regexp   ${p0}   buildversion>.*<\/buildversion>   buildversion>${ru_version}<\/buildversion>
        ${p0}   replace string using regexp   ${p0}   resourceBuildKey>.*<\/resourceBuildKey>   resourceBuildKey>LTX_AHEGHA<\/resourceBuildKey>
        ${p0}   replace string using regexp   ${p0}   GSCN>.*<\/GSCN>   GSCN>${gscn_fdd_cell_1}<\/GSCN>
        ${p0}   replace string using regexp   ${p0}   name>.*tar<\/name>   name>${frm_sw}<\/name>
        ${p0}   replace string using regexp   ${p0}   version>.*<\/version>   version>${ru_version}<\/version>
        ${p0}    remove string using regexp   ${p0}   <fddFrequencyRange>.*<\/fddFrequencyRange>
        ${p0}   replace string using regexp   ${p0}   scs>.*<\/scs>   scs>15<\/scs><fddFrequencyRange>FR1_WB<\/fddFrequencyRange>
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${p1}   replace string using regexp   ${p1}   cardName>.*<\/cardName>   cardName>AHEGHA<\/cardName>
        ${p1}   replace string using regexp   ${p1}   bldVersion>.*<\/bldVersion>   bldVersion>${ru_version}<\/bldVersion>
        ${p1}   replace string using regexp   ${p1}   buildversion>.*<\/buildversion>   buildversion>${ru_version}<\/buildversion>
        ${p1}   replace string using regexp   ${p1}   resourceBuildKey>.*<\/resourceBuildKey>   resourceBuildKey>LTX_AHEGHA<\/resourceBuildKey>
        ${p1}   replace string using regexp   ${p1}   GSCN>.*<\/GSCN>   GSCN>${gscn_fdd_cell_1}<\/GSCN>
        ${p1}   replace string using regexp   ${p1}   name>.*tar<\/name>   name>${frm_sw}<\/name>
        ${p1}   replace string using regexp   ${p1}   version>.*<\/version>   version>${ru_version}<\/version>
        ${p1}    remove string using regexp   ${p1}   <fddFrequencyRange>.*<\/fddFrequencyRange>
        ${p1}   replace string using regexp   ${p1}   scs>.*<\/scs>   scs>15<\/scs><fddFrequencyRange>FR1_WB<\/fddFrequencyRange>
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${p2}   replace string using regexp   ${p2}   cardName>.*<\/cardName>   cardName>AHEGHA<\/cardName>
        ${p2}   replace string using regexp   ${p2}   bldVersion>.*<\/bldVersion>   bldVersion>${ru_version}<\/bldVersion>
        ${p2}   replace string using regexp   ${p2}   buildversion>.*<\/buildversion>   buildversion>${ru_version}<\/buildversion>
        ${p2}   replace string using regexp   ${p2}   resourceBuildKey>.*<\/resourceBuildKey>   resourceBuildKey>LTX_AHEGHA<\/resourceBuildKey>
        ${p2}   replace string using regexp   ${p2}   GSCN>.*<\/GSCN>   GSCN>${gscn_fdd_cell_1}<\/GSCN>
        ${p2}   replace string using regexp   ${p2}   name>.*tar<\/name>   name>${frm_sw}<\/name>
        ${p2}   replace string using regexp   ${p2}   version>.*<\/version>   version>${ru_version}<\/version>
        ${p2}    remove string using regexp   ${p2}   <fddFrequencyRange>.*<\/fddFrequencyRange>
        ${p2}   replace string using regexp   ${p2}   scs>.*<\/scs>   scs>15<\/scs><fddFrequencyRange>FR1_WB<\/fddFrequencyRange>
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${new contents}      catenate         SEPARATOR=</RE>    ${p0}    ${p1}    ${p2}    ${p3}
        create file    ${configuration_directory}/new_iphy_updated.xml    ${new contents}
    ssh . Upload File       ${configuration_directory}/new_iphy_updated.xml    /rom/simmode/new_iphy.xml   connection=${ap_alias}


Modify iphy.xml for 3FDD+4TDD Setup
    ${ru_version_cell_1}  ${frm_sw_cell_1}    Get RU Info from TargetBD    ru_type=${re_fdd_cell_1}
    ${ru_version_cell_2}  ${frm_sw_cell_2}    Get RU Info from TargetBD    ru_type=${re_fdd_cell_2}
    ${ru_version_cell_3}  ${frm_sw_cell_3}    Get RU Info from TargetBD    ru_type=${re_fdd_cell_3}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${ap_alias}    connect . Connect to Airphone Common Unit
    ssh . Download File    /rom/simmode/new_iphy.xml    ${configuration_directory}/new_iphy_orig.xml    connection=${ap_alias}
        ${contents}    get file    ${configuration_directory}/new_iphy_orig.xml
        ${all_parts}    split string      ${contents}     </RE>
        ${p0}   set variable   ${all_parts}[0]    # 1st FDD Cell
        ${p1}   set variable   ${all_parts}[1]    # 2nd FDD Cell
        ${p2}   set variable   ${all_parts}[2]    # 2xTDD Cells
        ${p3}   set variable   ${all_parts}[3]    # 2xTDD Cells
        ${p4}   set variable   ${all_parts}[4]    # 3rd FDD Cell
        ${p5}   set variable   ${all_parts}[5]    # last part of the iphy.xml file
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${p0}   replace string using regexp   ${p0}   cardName>.*<\/cardName>   cardName>${re_fdd_cell_2}<\/cardName>
        ${p0}   replace string using regexp   ${p0}   bldVersion>.*<\/bldVersion>   bldVersion>${ru_version_cell_2}<\/bldVersion>
        ${p0}   replace string using regexp   ${p0}   buildversion>.*<\/buildversion>   buildversion>${ru_version_cell_2}<\/buildversion>
        ${p0}   replace string using regexp   ${p0}   sourceBuildKey>.*<\/resourceBuildKey>   sourceBuildKey>LTX_${re_fdd_cell_2}<\/resourceBuildKey>
        ${p0}   replace string using regexp   ${p0}   GSCN>.*<\/GSCN>   GSCN>${gscn_fdd_cell_2}<\/GSCN>
        ${p0}   replace string using regexp   ${p0}   name>.*tar<\/name>   name>${frm_sw_cell_2}<\/name>
        ${p0}   replace string using regexp   ${p0}   version>.*<\/version>   version>${ru_version_cell_2}<\/version>
        ${p0}    remove string using regexp   ${p0}   <fddFrequencyRange>.*<\/fddFrequencyRange>
        ${fddFrequencyRangeString}=    set variable if    '${chBw_fdd_cell_2}'=='35MHz' or '${chBw_fdd_cell_2}'=='50MHz'
        ...    <fddFrequencyRange>FR1_WB<\/fddFrequencyRange>    ${EMPTY}
        ${p0}   replace string using regexp   ${p0}   scs>.*<\/scs>   scs>15<\/scs>${fddFrequencyRangeString}
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${p1}   replace string using regexp   ${p1}   cardName>.*<\/cardName>   cardName>${re_fdd_cell_1}<\/cardName>
        ${p1}   replace string using regexp   ${p1}   bldVersion>.*<\/bldVersion>   bldVersion>${ru_version_cell_1}<\/bldVersion>
        ${p1}   replace string using regexp   ${p1}   buildversion>.*<\/buildversion>   buildversion>${ru_version_cell_1}<\/buildversion>
        ${p1}   replace string using regexp   ${p1}   sourceBuildKey>.*<\/resourceBuildKey>   sourceBuildKey>LTX_${re_fdd_cell_1}<\/resourceBuildKey>
        ${p1}   replace string using regexp   ${p1}   GSCN>.*<\/GSCN>   GSCN>${gscn_fdd_cell_1}<\/GSCN>
        ${p1}   replace string using regexp   ${p1}   name>.*tar<\/name>   name>${frm_sw_cell_1}<\/name>
        ${p1}   replace string using regexp   ${p1}   version>.*<\/version>   version>${ru_version_cell_1}<\/version>
        ${p1}    remove string using regexp   ${p1}   <fddFrequencyRange>.*<\/fddFrequencyRange>
        ${fddFrequencyRangeString}=    set variable if    '${chBw_fdd_cell_1}'=='35MHz' or '${chBw_fdd_cell_1}'=='50MHz'
        ...    <fddFrequencyRange>FR1_WB<\/fddFrequencyRange>    ${EMPTY}
        ${p1}   replace string using regexp   ${p1}   scs>.*<\/scs>   scs>15<\/scs>${fddFrequencyRangeString}
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${p4}   replace string using regexp   ${p4}   cardName>.*<\/cardName>   cardName>${re_fdd_cell_3}<\/cardName>
        ${p4}   replace string using regexp   ${p4}   bldVersion>.*<\/bldVersion>   bldVersion>${ru_version_cell_3}<\/bldVersion>
        ${p4}   replace string using regexp   ${p4}   buildversion>.*<\/buildversion>   buildversion>${ru_version_cell_3}<\/buildversion>
        ${p4}   replace string using regexp   ${p4}   sourceBuildKey>.*<\/resourceBuildKey>   sourceBuildKey>LTX_${re_fdd_cell_3}<\/resourceBuildKey>
        ${p4}   replace string using regexp   ${p4}   GSCN>.*<\/GSCN>   GSCN>${gscn_fdd_cell_3}<\/GSCN>
        ${p4}   replace string using regexp   ${p4}   name>.*tar<\/name>   name>${frm_sw_cell_3}<\/name>
        ${p4}   replace string using regexp   ${p4}   version>.*<\/version>   version>${ru_version_cell_3}<\/version>
        ${p4}    remove string using regexp   ${p4}   <fddFrequencyRange>.*<\/fddFrequencyRange>
        ${fddFrequencyRangeString}=    set variable if    '${chBw_fdd_cell_3}'=='35MHz' or '${chBw_fdd_cell_3}'=='50MHz'
        ...    <fddFrequencyRange>FR1_WB<\/fddFrequencyRange>    ${EMPTY}
        ${p4}   replace string using regexp   ${p4}   scs>.*<\/scs>   scs>15<\/scs>${fddFrequencyRangeString}
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${new contents}      catenate         SEPARATOR=</RE>    ${p0}    ${p1}    ${p2}    ${p3}   ${p4}    ${p5}
        create file    ${configuration_directory}/new_iphy_updated.xml    ${new contents}
    ssh . Upload File       ${configuration_directory}/new_iphy_updated.xml    /rom/simmode/new_iphy.xml   connection=${ap_alias}


Modify iphy.xml for 1FDD Setup
    ${ru_version}  ${frm_sw}    Get RU Info from TargetBD    ru_type=AHEGHA
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${ap_alias}    connect . Connect to Airphone Common Unit
    ssh . Download File    /rom/simmode/new_iphy.xml    ${configuration_directory}/new_iphy_orig.xml    connection=${ap_alias}
        ${contents}    get file    ${configuration_directory}/new_iphy_orig.xml
        ${all_parts}    split string      ${contents}     </RE>
        ${p0}   set variable   ${all_parts}[0]    # 1st FDD Cell
        ${p1}   set variable   ${all_parts}[1]    # 1st TDD Cell
        ${p2}   set variable   ${all_parts}[2]    # last part of the iphy.xml file
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${p0}   replace string using regexp   ${p0}   cardName>.*<\/cardName>   cardName>AHEGHA<\/cardName>
        ${p0}   replace string using regexp   ${p0}   bldVersion>.*<\/bldVersion>   bldVersion>${ru_version}<\/bldVersion>
        ${p0}   replace string using regexp   ${p0}   buildversion>.*<\/buildversion>   buildversion>${ru_version}<\/buildversion>
        ${p0}   replace string using regexp   ${p0}   resourceBuildKey>.*<\/resourceBuildKey>   resourceBuildKey>LTX_AHEGHA<\/resourceBuildKey>
        ${p0}   replace string using regexp   ${p0}   GSCN>.*<\/GSCN>   GSCN>${gscn_fdd_cell_1}<\/GSCN>
        ${p0}   replace string using regexp   ${p0}   name>.*tar<\/name>   name>${frm_sw}<\/name>
        ${p0}   replace string using regexp   ${p0}   version>.*<\/version>   version>${ru_version}<\/version>
        ${p0}    remove string using regexp   ${p0}   <fddFrequencyRange>.*<\/fddFrequencyRange>
        ${p0}   replace string using regexp   ${p0}   scs>.*<\/scs>   scs>15<\/scs><fddFrequencyRange>FR1_WB<\/fddFrequencyRange>
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${new contents}      catenate         SEPARATOR=</RE>    ${p0}    ${p1}    ${p2}
        create file    ${configuration_directory}/new_iphy_updated.xml    ${new contents}
    ssh . Upload File       ${configuration_directory}/new_iphy_updated.xml    /rom/simmode/new_iphy.xml   connection=${ap_alias}


Modify iphy.xml for 1FDD+3TDD Setup
    ${ru_version}  ${frm_sw}    Get RU Info from TargetBD    ru_type=AHEGHA
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${ap_alias}    connect . Connect to Airphone Common Unit
    ssh . Download File    /rom/simmode/new_iphy.xml    ${configuration_directory}/new_iphy_orig.xml    connection=${ap_alias}
        ${contents}    get file    ${configuration_directory}/new_iphy_orig.xml
        ${all_parts}    split string      ${contents}     </RE>
        ${p0}   set variable   ${all_parts}[0]    # 1st FDD Cell
        ${p1}   set variable   ${all_parts}[1]    # 2xTDD Cells
        ${p2}   set variable   ${all_parts}[2]    # 1xTDD Cell
        ${p3}   set variable   ${all_parts}[3]    # last part of the iphy.xml file
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${p0}   replace string using regexp   ${p0}   cardName>.*<\/cardName>   cardName>AHEGHA<\/cardName>
        ${p0}   replace string using regexp   ${p0}   bldVersion>.*<\/bldVersion>   bldVersion>${ru_version}<\/bldVersion>
        ${p0}   replace string using regexp   ${p0}   buildversion>.*<\/buildversion>   buildversion>${ru_version}<\/buildversion>
        ${p0}   replace string using regexp   ${p0}   resourceBuildKey>.*<\/resourceBuildKey>   resourceBuildKey>LTX_AHEGHA<\/resourceBuildKey>
        ${p0}   replace string using regexp   ${p0}   GSCN>.*<\/GSCN>   GSCN>${gscn_fdd_cell_1}<\/GSCN>
        ${p0}   replace string using regexp   ${p0}   name>.*tar<\/name>   name>${frm_sw}<\/name>
        ${p0}   replace string using regexp   ${p0}   version>.*<\/version>   version>${ru_version}<\/version>
        ${p0}    remove string using regexp   ${p0}   <fddFrequencyRange>.*<\/fddFrequencyRange>
        ${p0}   replace string using regexp   ${p0}   scs>.*<\/scs>   scs>15<\/scs><fddFrequencyRange>FR1_WB<\/fddFrequencyRange>
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${new contents}      catenate         SEPARATOR=</RE>    ${p0}    ${p1}    ${p2}    ${p3}
        create file    ${configuration_directory}/new_iphy_updated.xml    ${new contents}
    ssh . Upload File       ${configuration_directory}/new_iphy_updated.xml    /rom/simmode/new_iphy.xml   connection=${ap_alias}


Get RU Info from TargetBD
    [Arguments]    ${ru_type}=AEQE
    ${gnb_alias}=    connect . Connect to gNB Capacity Unit
    ${file_path}=    Get File Path on Target    file_pattern=/ffs/run/TargetBD*ENB*.xml    connection=${gnb_alias}
    ssh . download file    remote_path=${file_path}    local_path=${configuration_directory}/TargetBD.xml    connection=${gnb_alias}
    ssh . disconnect    ${gnb_alias}
    ${ru_version}  ${frm_sw}    CB011006_tools . get_values_from_targetbd    ${configuration_directory}/TargetBD.xml    ${ru_type}
    RETURN    ${ru_version}    ${frm_sw}

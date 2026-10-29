*** Settings ***
Documentation    Scenario specific keywords for CB009267-C subfeatures

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.wts                                     WITH NAME    wts

Resource   ./../resources/CB009267_initial_commissioning.robot
Resource   ./../resources/CB009267_test_steps.robot
Resource   ./../../../L2/resources/TEAL_additional_keywords.robot

*** Keywords ***

#-----------For Test Execution ------------------------------------------------------------------------------------------------------[150 characters]

# IMPORTANT: see ./../resources/CB009267_test_steps.robot for the "Scenario specific Keywords"



#-----------For Suite Setup ---------------------------------------------------------------------------------------------------------[150 characters]

Make Necessary Changes To SCF
    Update RnD Flags In SW Config File
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    IF    'FR1' in '${SUITE_NAME}'    Modify IPHY For 2TDD+2FDD FR1 Setup
    ...    ELSE IF    'FR2' in '${SUITE_NAME}'    Modify IPHY For 4TDD FR2 Setup
    ...    ELSE IF    'SAg' in '${SUITE_NAME}'    Modify IPHY For 2TDD+2FDD FR1 Setup
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    scf.Load Scf    ${original_gnb_scf}
    IF        'Ca SA FR1' in '${SUITE_NAME}'
                    Modify SCF For 2TDD+2FDD For SA FR1 Setup
    ELSE IF   'Cb NSA FR1' in '${SUITE_NAME}'
                    Modify SCF For 2TDD+2FDD For NSA FR1 Setup
    ELSE IF   'Ca SA FR2 BuffRLQ' in '${SUITE_NAME}'
                    Modify SCF For 4TDD For SA FR2 Setup
    ELSE IF   'Cb NSA FR2 BuffRLQ' in '${SUITE_NAME}'
                    Activate CA In NRBTS In FR2 For NSA
    ELSE IF   'Ca SA SAg' in '${SUITE_NAME}'
                    Modify SCF For 2TDD+2FDD For SA FR1 Setup
                    Modify SCF For PUSCH Slot Aggregation
    END
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
    scf.Save Scf    ${configuration_directory}/SCF_updated.xml
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Perform Commissioning On Classical BTS    ${configuration_directory}/SCF_updated.xml


Perform Commissioning on Classical BTS
    [Arguments]  ${scf_file}
    ${oam_alias}=  connect . Setup OAM http session
    admin . Perform Commissioning    scf_file=${scf_file}
    ...                              connection=${oam_alias}
    ...                              skip_parameter_relation_errors=False
    ...                              timeout=300
    connect . Teardown OAM http session


Change Reporting Interval
    [Arguments]    ${interval_duration}
    ${distName_NRPMRNL}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    @{list_of_pm_groups}=  create list  miNrCellAvailability  miNrCellUtilization  miNrTimingAdvance  miNrUlSignalQuality  miNrXnInterface
    ...                                 miNrHighRlcReport     miNrLowRlcReport     miNrMacPduTput     miNrPDCP1Report      miNrPDCP2Report
    ...                                 miNrPDCPCell          miNrRlfPerCell       miNrX2CB           miNrX2CC             miNrX2UInterface
    ...                                 miNrUlHarq            miNrDlHarq           miNrXnCCInterface  miNrCaDu             miNrNGCC
    ...                                 miNrCaCu              miNrCaDu             miNrCaDu01         miNrCaDuCp
    ...                                 miNrInterGnbMobilityCellCuNsa              miNrInterGnbMobilityCellCuSa
    ...                                 miNrIntraGnbMobilityCellCuSa
    FOR   ${pname}  IN   @{list_of_pm_groups}
        scf.modify scf element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=${pname}
    END
    ${distName_PMCADM}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_PMCADM[0]}   p_name=reportingIntervalPm



#-----------For basic_setup.cfg Changes----------------------------------------------------------------------------------------------[150 characters]

Update Basic Configuration File
    wts . Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
        IF    'FR1' in '${SUITE_NAME}'    Modify BASIC_SETUP for 2TDD+2FDD FR1 Setup
        ...    ELSE IF    'FR2' in '${SUITE_NAME}'    Modify BASIC_SETUP for 4TDD FR2 Setup
        ...    ELSE IF    'SAg' in '${SUITE_NAME}'    Modify BASIC_SETUP for 2TDD+2FDD FR1 Setup
    wts . Save Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}


Modify BASIC_SETUP for 2TDD+2FDD FR1 Setup
    # see reference:
    # https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1057877807#UserManualCNI56766-Performanceconsiderations
    # https://confluence.ext.net.nokia.com/display/AirPhoneWTS/Parameters+to+be+checked ( search for "sim_param_set NR_PDCP_TRUNCATE_DL_SIZE")
    wts.Delete    sim_param_set NR_PDCP_CIPHERING=distributed
    wts.Insert    sim_param_set NR_PDCP_BUNDLE_DL_TIMEOUT=100     after   sim_trace amf=1 protocol=ng on
    wts.Insert    sim_param_set NR_PDCP_BUNDLE_DL_MAX_SIZE=1200   after   sim_trace amf=1 protocol=ng on
    wts.Insert    sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47       after   sim_trace amf=1 protocol=ng on


Modify BASIC_SETUP for 4TDD FR2 Setup
    RETURN



#-----------For iphy.xml Changes-----------------------------------------------------------------------------------------------------[150 characters]

Modify IPHY for 2TDD+2FDD FR1 Setup
    ${ap_alias}    connect . Connect to Airphone Common Unit
    ssh . Download File    /rom/simmode/new_iphy.xml    ${configuration_directory}/new_iphy_orig.xml    connection=${ap_alias}


Modify IPHY for 4TDD FR2 Setup
    ${ap_alias}    connect . Connect to Airphone Common Unit
    ssh . Download File    /rom/simmode/new_iphy.xml    ${configuration_directory}/new_iphy_orig.xml    connection=${ap_alias}


Update RnD Flags In SW Config File
    @{rd_params}=  Create List
    ...    0x5801CB=0     # rdFakeUeSchedulingEnable; disables fakeUe scheduling, to avoid syslog ERR print
    gnb.Update SW Config File On System Module  param_list=${rd_params}

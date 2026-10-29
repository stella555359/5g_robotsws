*** Settings ***

Documentation   This is a Robot Test Suite for subfeature 5GC000480-G classical gNB
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
#-------------------------------------------------------------------------------------------------------------
Resource        ../keywordbook-480.robot
Resource        ../keywordbook-480-resourceUsage.robot
Resource        5GC000480-G-keywords.robot

Suite Setup     Prepare TL for 5GC000480-G Testing

*** Variables ***

${cell_distName}          NRCELL-1
${maxNumOfAttaches}       46
${maxNumOfSuccAttaches}   45

*** Test Cases ***

5GC000480_G_Unsuccessful_SgNBAddition_due_to_no_PUCCH_capacity
    [Documentation]    This Test Scenario verifies the counters M55114C00010, M55114C00036
    ...                M55115C00002, M55115C00003, M55115C00004, M55115C00005


    [Setup]    Perform Preconditions of Test Scenario
    prepare counters and expected values

    update parameter values with delta commissioning coam

    get resources taken before_test

    Log to console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval    additional-waiting-time=30s

    Attach many UEs on classical

    Log to console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval    additional-waiting-time=30s

    Release All UEs

    collect pm file and verify counter values many attaches
    Verify wireshark many attaches

    get resources taken after_test
    verify resource usage

    [Teardown]    Perform Postconditions of Test Scenario




*** Keywords ***
Prepare TL for 5GC000480-G Testing
    Create Test Suite Folders
    UTE Cloud Workaround
    Get test variables and upload start SCF
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    Update wts file for TC 480G classical
    Upload Customized WTS Config    config_path=${resultBaseDir}/basic_wts_480G.cfg
    Bring Airphone TL to on Air status


update parameter values with delta commissioning coam
    [Documentation]    [PRIVATE]    update parameter values with delta commissioning coam
    ...       :Autor: Sylvia Schneider
    ${d_reportingIntervalPm}      create dictionary
    ...    dist_name    ${pmcadm_distName}
    ...    parameter    reportingIntervalPm
    ...    value        ${measurement_period_in_min}min
    ${d_miNrRacCu}      create dictionary
    ...    dist_name    ${bts_distName}/NRPMRNL-1
    ...    parameter    miNrRacCu
    ...    value        ${measurement_period_in_min}min
    ${d_miNrRacDu}      create dictionary
    ...    dist_name    ${bts_distName}/NRPMRNL-1
    ...    parameter    miNrRacDu
    ...    value        ${measurement_period_in_min}min
    ${param_list}     Create List
    ...    ${d_reportingIntervalPm}
    ...    ${d_miNrRacCu}
    ...    ${d_miNrRacDu}
    json delta commissioning coam        ${param_list}


collect pm file and verify counter values many attaches
    [Documentation]    [PRIVATE]    collect pm file and verify counter values many attaches
    ...       :Autor: Sylvia Schneider
    Sleep     30s
    Collect PM Counters
    Verify counter values coam


Verify counter values coam
    [Documentation]    [PRIVATE]    Verify counter values coam
    ...       :Autor: Sylvia Schneider
    ${parsed_xml}    Parse Xml    ${pmCounter_xml_file}

    &{dict}    Create Dictionary    M55114C00001    ${M55114C00001}    M55114C00002    ${M55114C00002}
    ...                             M55114C00003    ${M55114C00003}    M55114C00004    ${M55114C00004}
    ...                             M55114C00010    ${M55114C00010}    M55114C00036    ${M55114C00036}
    ...                             M55115C00002    ${M55115C00002}    M55115C00003    ${M55115C00003}
    ...                             M55115C00004    ${M55115C00004}    M55115C00005    ${M55115C00005}
    Log Dictionary    ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}

    FOR    ${counter}    IN     @{dict_keys}
         @{counterList}    Get From Dictionary    ${dict}    ${counter}
         Verify Counter    ${counter}    ${counterList}    ${parsed_xml}
    END

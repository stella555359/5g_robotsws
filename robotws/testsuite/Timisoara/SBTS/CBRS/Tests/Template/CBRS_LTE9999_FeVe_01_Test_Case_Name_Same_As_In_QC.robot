*** Settings ***
Documentation
...    = Author =
...    _artur.czainski@nokia.com_
...    = Maintainer =
...    _artur.czainski@nokia.com_
...    = Reviewer =
...    _marek.kot@nokia.com_
...    _albert.sakowicz@nokia.com_
...    = Summary =
...    - This test checks is the template for writing tests in
...      MN SRAN Prod Oper Pz WRO 3 Vrf - CBRS team.
...    - Below exemplary TC (Test Case) template is preparted
...      to work in UTE Cloud environment
...    = Pre - Requirements =
...    - If your TC needs any pre-requirements to be executable and
...      to be able to finish with pass (if there is no any issue if
...      testing software), this is the place where it should be written
...    - actCBRS flag is set to false
...    - robotlte/config/<testline name>/__init__.py and site specific keyword

Resource    ./../../Resources/cbrs_common_keywords.robot
*** Keywords ***
CBRS_LTE9999_FeVe_01_Test_Case_Name_Same_As_In_QC
    [Documentation]    Requirements: OM_GEN_SFS_CBRS.9998    #Put the requirements which such Test covers
    ...                              OM_GEN_SFS_CBRS.9999
    [Timeout]    10min

    #This Section is intended to prepare variables which will be used in the next Test Case steps
    ${enb_id}            Set Variable    ${testlines.${testline_id}.enb_id}
    #ToDo Check if it works or should it be Append to List @{allowed_alarms}   ALARM DUPA
    @{allowed_alarms}    Set Variable    ${enb_allowed_alarms}    Allowed Alarm
    ${expected_alarms}   Create List     SAS Spectrum Inquiry Failure

    Wait Until BTS Is Not Busy    #Use this Keyword before any recommissioning

    Start Capturing Historical Alarms

    #Section for environment configuration and checking if ENB is ready and onAir before the test
    Wait For All Cells To Be OnAir   #At the beginning of the test




    #Test Case Body
    Print Given Text To Console N Times    given text=Someting
    ...                                    n=${10}
    Sleep    10s    #Try to avoid any "Sleeps" in the test but if it is unable, comment why Sleep is necessary here
    Wait For All Cells To Be OnAir
    No Alarm Except Allowed Should Appear On EnB

    Print Given Text To Console N Times    given text=Bajojajo
    ...                                    n=${2}
    Wait For All Cells To Be OnAir
    No Alarm Except Allowed Should Appear On EnB



    #Test Post-conditions
    Wait For All Cells To Be OnAir   #At the end of the test

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Perform Delta Recommissioning    delta_file=${postcondition_plan}
    ...                                                            alias=RAT_1ST    AND
    ...                           Save And Check Historical Alarms    expected_alarms=${expected_alarms}

#Test Case specifis keywords section
Print Given Text To Console N Times
    [Arguments]    ${given text}=Please specify the text you would like to write to console!    ${n}=${1}
    [Documentation]    This keyword has been created to print ${given text} to console ${n} times.
    ...                By default ${given text} will be printed one time.
    FOR   IN RANGE    0    ${n}
        Log    ${given text}    console=True
    END

*** Settings ***
Documentation   OMA configuration error
...             This test required the below VM test environement préparation :
...             1- Instalation of geckodriver on /opt/geckodriver/
...             2- Add /opt/geckodriver to system environement path
...             3- Install xvfb dependancy in order to use selenium_coam.enable_virtual_display
...             (to run browser under virtuel mode) if not the keyword will not function.

Library         OperatingSystem
Library         String
Library         Process
Library         Collections
Library         String
Library         DateTime

Library         taf.gnb.oam.commissioning                   WITH NAME   cm
Library         taf.transport.ssh                           WITH NAME   ssh

Resource        ${CURDIR}/../../configuration.robot
Resource        ${CURDIR}/../../logs.robot
Resource        ${CURDIR}/../../coam_selenium.robot


*** Variables ***
${WRONG_ANGLE}    210

*** Keywords ***
Abf_OAM_Configuration_error_case
    [Arguments]     ${beamset}
    [Teardown]      Run keyword and ignore error      configuration.Close Connections SSH


    # Check if required beam already configured.
    #Get beamSet infos
    ${cmd}      catenate
    ...         cat ${CURDIR}/ABF_BeamSet_PatternID
    ...         | grep -E ${beamSet}
    ${res}      Run       ${cmd}
    @{lines}    Split To Lines      ${res}
    @{bs}       Split String    @{lines}[0]    separator=;


    # get upperEdgeAngle value before try to set a wrong value
    # ${defor_upEdgeAngle}=    coam_selenium.get value of parameter    upperEdgeAngle    upperEdgeAngle
    ${defor_upEdgeAngle}=    Set Variable    @{bs}[5]
    ${cmd}      catenate
    ...         grep "\\"com.nokia.srbts.nrbts:NRCELL\\"" ${scf_path}/SCF_pre_check.xml
    ...         | awk -F "distName=" '{print $2}'| awk -F "\\"" '{print $2}'
    ${distname}=    Run    ${cmd}

    ${filter_param}=    Set Variable    Upper Cell Edge Angle
    ${abbr}=            Set Variable    upperEdgeAngle
    ${result}=          Set Wrong Parameter Value and Get Error Message    ${distname}    ${abbr}    ${WRONG_ANGLE}
    ...						${filter_param}
    Log    Result: ${result}
    Should Contain  ${result}    Given value is too big     The maximum value of the parameter is
    ...             ignore_case=True

    ${after_upEdgeAngle}=    Get Parameter Value Of    ${distname}     ${abbr}    ${filter_param}

    Should be equal     ${after_upEdgeAngle}    ${defor_upEdgeAngle}

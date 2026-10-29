*** Settings ***
Documentation    responsible tester: slawomir.jastrzebski@nokia.com
Library    Collections
Library    String

#Resource    ../../resources/setup_and_teardown.robot
#Resource    ../../resources/test_cases.robot
Resource    ./variables.robot

#Force Tags        CLOUD_R4BN9_CUS     CA_GVe   SBTS00     CRT   RAN_4G    RAN_4G_FDD

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=        ${CURDIR}/config/SCFC.xml
${CUSINI_FILE_PATH}=                ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                ${CURDIR}/config/epc.lua
${CONFIGURATION_NAME}=              1.1.1_ARGA_(2x20(Ig))L_I;1.1.3_ARGA_(1x20(Ig))L_I;1.1.5_AREA_(2x20(In))L_I;1.1.7_AREA_(1x20(In))L_I;
@{LCR_ID_CELL_BLOCK_LIST}=          ALL
${BASIC_CALL}=                      True
#${CA_SUPPORTED_BANDS}=              1:a:a+3:a:a|3:a:a+1:a:a
${CA_SUPPORTED_BANDS}=              4:a:a+11::a+64:a:
#${CA_SUPPORTED_BANDS}=              1:a:a+3:a:a+5::a+7::a+7::a|1:a:a+3:a:a|1:a:a+5:a:a|1:a:a+7:a:a|3:a:a+5:a:a|3:a:a+7:a:a|5:a:a+7:a:a|7:a:a+7:a:a
#${CA_SUPPORTED_BANDS}=              4:a:a+40::a|4:a:a+3::a|4:a:a+2::a|4:a:a+46::a|4:a:a+46::c|4:a:a+46::d|4:a:a+2::a+46::a|4:a:a+2::a+46::c|4:a:a+2
#                                    ::a+46::d|4:a:a+3::a+46::a|4:a:a+3::a+46::c|4:a:a+3::a+46::d|4:a:a+40::a+46::a|4:a:a+40::a+46::c|4:a:a+40::a+46
#                                    ::d|4:a:a+2::a+3::a|4:a:a+40::a+3::a|4:a:a+40::a+2::a|4:a:a+40::a+3::a+46::a|4:a:a+40::a+3::a+46::c|4:a:a+40:
#                                    :a+3::a+46::d|4:a:a+40::a+2::a+46::a|4:a:a+40::a+2::a+46::c|4:a:a+40::a+2::a+46::d|4:a:a+40::a+2::a+3::a+46
#                                    :a|4:a:a+40::a+2::a+3::a+46::c|4:a:a+40::a+2::a+3::a+46::d
${JSON_DELTA_FILE}                  ${CURDIR}/config/delta_file.json

#   supported_bands=1:false,3:false
*** Test Cases ***
Test
    Log   \nCA SUPPORTED BANDS: ${CA_SUPPORTED_BANDS}\n    console=True
    ${supported_bands}=    CUS Create Supported Bands    ${CA_SUPPORTED_BANDS}
    Log   \nCA SUPPORTED BANDS: ${supported_bands}\n    console=True

*** Keywords ***
CUS Create Supported Bands
    [Arguments]    ${ca_supported_bands}
    [Documentation]    Keyword performs attach in the case of carrier aggregation configuration cell
    ...    and checks if the relevant messages appears in the packets.
    ...    Author: slawomir.jastrzebski@nokia.com
    ...    Maintainer: slawomir.jastrzebski@nokia.com
    ${new_supported_bands}=    Remove String    ${CA_SUPPORTED_BANDS}    -  +  :  |  a  b  c  d
    Log   \nCA SUPPORTED BANDS: ${new_supported_bands}\n    console=True

    ${char_supported_bands}=    Split String To Characters    ${new_supported_bands}
    Log   \nCA SUPPORTED BANDS: ${char_supported_bands}\n    console=True

    ${char_supported_bands}=    Remove Duplicates    ${char_supported_bands}
     Log   \nCA SUPPORTED BANDS: ${char_supported_bands}\n    console=True

    ${supported_bands}=    Set Variable    supported_bands=
    FOR  ${supported_band}  IN  @{char_supported_bands}
      ${supported_bands}=    Catenate    ${supported_bands}    ${supported_band},
    END
    ${supported_bands}=    Remove String    ${supported_bands}    ${SPACE}
    ${supported_bands}=    Get Substring    ${supported_bands}    0    -1
    [Return]    ${supported_bands}


#    ${supported_bands}=    Remove String Using Regexp    ${CA_SUPPORTED_BANDS}    \d
#    Log   \nCA SUPPORTED BANDS: ${supported_bands}\n    console=True



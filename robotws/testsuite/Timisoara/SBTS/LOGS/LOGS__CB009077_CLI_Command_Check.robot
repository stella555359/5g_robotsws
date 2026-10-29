*** Settings ***
Library     ../../resources/python_resources/admin_cli.py  WITH NAME  hran_admin_cli
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam

Documentation    TC for LOGS__CB009077_CLI_Command_Check


*** Keywords ***
TC__LOGS__CB009077_CLI_Command_Check
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26689
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Step 1: Command Check getParameterByClass
    ...  Step 2: Command Check getParameterByDN
    ...  Step 3: Command Check getParameterByParentDN
    ...  Test case verifies 3 new CLI command introduce in CB009077
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 09.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26689- Initial creation
    ...


    Set Tags    CA-LOGS    OWNER-jakub.kokoszka@nokia.com    MAINTAINER-jakub.kokoszka@nokia.com
    ...    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS24R1    FEATURE-CB009077

    Step 0: Preconditions
    Step 1: Command Check getParameterByClass
    Step 2: Command Check getParameterByDN
    Step 3: Command Check getParameterByParentDN


Step 0: Preconditions
    [Documentation]
    ...   In this step necessary test variables are set.
    ...   to avoid errorCode:9 and requestMessage:License not available, parameter actCLI will change to true

    Log    Step 0: Preconditions    console=${True}

    ${active SW version}=  coam.Get Sw Version
    ${Mplane_IP}  bts_states.Get BTS Mplane
    ${btsid}   bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}    ${btsid}
    Wait Until Keyword Succeeds  5x  15s  Setup Admin CLI  ${active SW version}  ${Mplane_IP}  admin_dir=/home/ute/btsauto
    Set Test Variable  ${actCli}  ${False}
    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actCli  operation=update  value=true  skip_parameter_relation_errors=True
    Set Test Variable  ${actCli}  ${True}

Step 1: Command Check getParameterByClass
    [Documentation]
    ...   In this step Command getParameterByClass will be check
    ...   test check className:RMOD

    Log    Step 1: Command Check getParameterByClass    console=${True}

    ${request1}=  Set Variable
    ...   {"requestId":1,"parameters":{"name":"getParameterByClass","parameters":{"className":"RMOD"}}}
    ${request2}=  Set Variable
    ...   {"requestId":2,"parameters":{"name":"getParameterByClass","parameters":{"className":"RMOD","includeChildren":true}}}

    ${response1}  hran_admin_cli.Send Admin CLI request  ${request1}   output_json=${BTS_Files}/getParameterByClass1.txt
    OperatingSystem.File Should Exist    ${BTS_Files}/getParameterByClass1.txt
    ${file_content}    OperatingSystem.Get File    ${BTS_Files}/getParameterByClass1.txt
    ${distName}    Should Match Regexp    ${file_content}   MRBTS-${BTS_ID}/EQM-.*/APEQM-.*/RMOD-.*
    ${distName_RM}    Fetch From Left  ${distName}    ",
    Set Test Variable  ${distName_RM}

    ${response2}  hran_admin_cli.Send Admin CLI request  ${request2}   output_json=${BTS_Files}/getParameterByClass2.txt
    OperatingSystem.File Should Exist    ${BTS_Files}/getParameterByClass2.txt
    ${file_content2}    OperatingSystem.Get File    ${BTS_Files}/getParameterByClass2.txt
    Should Match Regexp      ${file_content2}   MRBTS-${BTS_ID}/EQM-.*/APEQM-.*/RMOD-.*/

Step 2: Command Check getParameterByDN
    [Documentation]
    ...   In this step Command getParameterByDN will be check
    ...   test check distName for first RMOD

    Log    Step 2: Command Check getParameterByDN    console=${True}

    ${request3}=  Set Variable
    ...   {"requestId":3,"parameters":{"name":"getParameterByDN","parameters":{"distName":"${distName_RM}"}}}
    ${request4}=  Set Variable
    ...   {"requestId":4,"parameters":{"name":"getParameterByDN","parameters":{"distName":"${distName_RM}","includeChildren":true}}}

    ${response3}  hran_admin_cli.Send Admin CLI request  ${request3}   output_json=${BTS_Files}/getParameterByDN.txt
    OperatingSystem.File Should Exist    ${BTS_Files}/getParameterByDN.txt
    ${file_content3}    OperatingSystem.Get File    ${BTS_Files}/getParameterByDN.txt
    Should Match Regexp      ${file_content3}   ${distName_RM}
    Should Match Regexp      ${file_content3}    prodCodePlanned

    ${response4}  hran_admin_cli.Send Admin CLI request  ${request4}   output_json=${BTS_Files}/getParameterByDN2.txt
    OperatingSystem.File Should Exist    ${BTS_Files}/getParameterByDN2.txt
    ${file_content4}    OperatingSystem.Get File    ${BTS_Files}/getParameterByDN2.txt
    Should Match Regexp      ${file_content4}   ${distName_RM}/

Step 3: Command Check getParameterByParentDN
    [Documentation]
    ...   In this step Command getParameterByParentDN will be check
    ...   test check parentDN ANTL for firts RMOD

    Log    Step 3: Command Check getParameterByParentDN    console=${True}

    ${request5}=  Set Variable
    ...   {"requestId":5,"parameters":{"name":"getParameterByParentDN","parameters":{"parentDN":"${distName_RM}"}}}

    ${response5}  hran_admin_cli.Send Admin CLI request  ${request5}   output_json=${BTS_Files}/getParameterByParentDN.txt
    OperatingSystem.File Should Exist    ${BTS_Files}/getParameterByParentDN.txt
    ${file_content5}    OperatingSystem.Get File    ${BTS_Files}/getParameterByParentDN.txt
    Should Match Regexp      ${file_content5}   ${distName_RM}/


Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}

    Run Keyword If  ${actCli}    Run Keywords    coam.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    parameter=actCli  operation=update  value=false  skip_parameter_relation_errors=True
    ...  AND  Set Test Variable  ${actCli}  ${False}


TC Setup
    Common Test Setup


TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown



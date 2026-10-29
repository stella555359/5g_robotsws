*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/cli.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     CLI.01_Admin_CLI_setRETProperties
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is check if setRETProperties command via Admin command line in order to send RET
...  configuration file is working. The setRETProperties request allows you to sets up the basic parameters of a
...  remote electrical tilt (RET).
...
...  +-----------+-----------+----------------------------------------------------------------+
...  |                          Vendor code: AN  Product code: ATM3                           |
...  +-----------+-----------+----------------------------------------------------------------+
...  | min angle | max angle | file name                                                      |
...  +-----------+-----------+----------------------------------------------------------------+
...  | 0         | 4.7       | 936LG65VTE-B.dat                                               |
...  +-----------+-----------+----------------------------------------------------------------+
...  | 0         | 6         | TMBXX-6517-R2M.dat                                             |
...  +-----------+-----------+----------------------------------------------------------------+
...  | 0         | 7         | ADFD1820-3333B-XDM.dat                                         |
...  +-----------+-----------+----------------------------------------------------------------+
...  | 0         | 8         | 932QLG65VTEB.dat                                               |
...  +-----------+-----------+----------------------------------------------------------------+
...  | 0         | 10        | HBX-6516DS-R2M.dat                                             |
...  +-----------+-----------+----------------------------------------------------------------+
...  | 0         | 15        | DBXLH-6565A-R2M-LO.dat                                         |
...  +-----------+-----------+----------------------------------------------------------------+
...  | 2         | 10        | DBXGKC-6565EC-VTM-HI.dat                                       |
...  +-----------+-----------+----------------------------------------------------------------+
...
...  +-----------+-----------+----------------------------------------------------------------+
...  |                        Vendor code: KA   Product code: 86010148                        |
...  +-----------+-----------+----------------------------------------------------------------+
...  | min angle | max angle | file name                                                      |
...  +-----------+-----------+----------------------------------------------------------------+
...  | 0         | 6         | KA_742225V02_1710-2180_extended2.bin                           |
...  +-----------+-----------+----------------------------------------------------------------+
...  | 0         | 10        | KA_84010054_2496-2690_extended2.bin                            |
...  +-----------+-----------+----------------------------------------------------------------+
...  | 0         | 12        | KA_80010544_2300-2690_extended2.bin                            |
...  +-----------+-----------+----------------------------------------------------------------+
...  | 0         | 14        | KA_80010290_806-960_extended2.bin                              |
...  +-----------+-----------+----------------------------------------------------------------+
...
...  +-----------+-----------+----------------------------------------------------------------+
...  |                       Vendor code: KA   Product code: 86010148V01                      |
...  +-----------+-----------+----------------------------------------------------------------+
...  | min angle | max angle | file name                                                      |
...  +-----------+-----------+----------------------------------------------------------------+
...  | 0         | 7         | KA_80010123V03_790-960_extended2_03-05.bin                     |
...  +-----------+-----------+----------------------------------------------------------------+
...  | 0         | 10        | KA_742236V01_1710-2180_LEFT_extended2_03-05.bin                |
...  +-----------+-----------+----------------------------------------------------------------+
...  | 0         | 14        | KA_80010290V01_1710-2180_TOP_extended2_03-05.bin               |
...  +-----------+-----------+----------------------------------------------------------------+
...
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  02.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-232 - Test case creation
...  13.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-251 - Add Test Specific Teardown
...  15.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-407 - Angle is out of angle range after uploading prev_confFile
...  11.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-466 - Modify CLI.01_Admin_CLI_setRETProperties
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
&{atm3_confFile_set}=  0-4.7=936LG65VTE-B.dat  0-6=TMBXX-6517-R2M.dat  0-7=ADFD1820-3333B-XDM.dat  0-8=932QLG65VTEB.dat
...  0-10=HBX-6516DS-R2M.dat  0-15=DBXLH-6565A-R2M-LO.dat  2-10=DBXGKC-6565EC-VTM-HI.dat
&{86010148_confFile_set}=  0-6=KA_742225V02_1710-2180_extended2.bin  0-10=KA_84010054_2496-2690_extended2.bin
...  0-12=KA_80010544_2300-2690_extended2.bin  0-14=KA_80010290_806-960_extended2.bin
&{86010148V01_confFile_set}=  0-7=KA_80010123V03_790-960_extended2_03-05.bin  0-10=KA_742236V01_1710-2180_LEFT_extended2_03-05.bin
...  0-14=KA_80010290V01_1710-2180_TOP_extended2_03-05.bin
${ATM3_confFile}=  /media/IAV_WCDMA/09_Users/tmar/~RET/RET_confFiles/ATM3
${86010148_confFile}=  /media/IAV_WCDMA/09_Users/tmar/~RET/RET_confFiles/86010148
${86010148V01_confFile}=  /media/IAV_WCDMA/09_Users/tmar/~RET/RET_confFiles/86010148V01

*** Keywords ***
CLI.01_Admin_CLI_setRETProperties

    CLI.01_Admin_CLI_setRETProperties.Test_Step.0 Check If RETs Are In Configuration
    CLI.01_Admin_CLI_setRETProperties.Test_Step.1 Enable CLI Feature And Select Angle Range
    CLI.01_Admin_CLI_setRETProperties.Test_Step.2 Sending Configuration File For Selected RET Via CLI
    CLI.01_Admin_CLI_setRETProperties.Test_Step.3 Sending Configuration File For Not Existing RET Via CLI
    CLI.01_Admin_CLI_setRETProperties.Test_Step.4 Sending Additional Data For Selected RET Via CLI
    CLI.01_Admin_CLI_setRETProperties.Test_Step.5 Check ALDs State

CLI.01_Admin_CLI_setRETProperties.Test_Step.0 Check If RETs Are In Configuration
    [Documentation]  Test step which checking if RETs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${ALD_R_RETs}
    ${RET_prodCode}=  Run Keyword If  ${num_of_RETs}!=${0}
    ...  Mapping RET To ProductCode  ${ALD_R_RETs}
    ${filtered_ALD_R_RETs}=  Create List
    FOR  ${item}  IN  @{RET_prodCode.keys()}
        ${productCode}=  Get From Dictionary  ${RET_prodCode}  ${item}
        Run Keyword If  '${productCode}'=='ATM3' or '${productCode}'=='86010148' or '${productCode}'=='86010148V01'
        ...  Append To List  ${filtered_ALD_R_RETs}  ${item}
    END
    ${num_of_filtered_RETs}=  Get Length  ${filtered_ALD_R_RETs}
    Run Keyword If  ${num_of_filtered_RETs}==${0}
    ...  Fail  msg=There is no at least one expected RET in configuration
    Log  You have ${num_of_filtered_RETs} expected RET(s) in configuration  console=${True}
    Set Test Variable  ${RET_prodCode}
    Set Test Variable  ${filtered_ALD_R_RETs}

CLI.01_Admin_CLI_setRETProperties.Test_Step.1 Enable CLI Feature And Select Angle Range
    [Documentation]
    ...    1.Check if parameter actCli is set as "true", if not then change it to "true".
    ...    2.Select valid RET.
    ...    3.Select new angle range.
    Log to console    \n========================================
    Log  Step: 1 Enable CLI feature and select new angle range  console=${True}
    Log to console    ========================================
    Set Feature On Expected Value  parameter=actCli  value=true
    ${chosen_RET}=  Select Random RET  ${filtered_ALD_R_RETs}
    ${chosen_prodCode}=  Get From Dictionary  ${RET_prodCode}  ${chosen_RET}
    ${ret_param}=  Get RETU Parameters  ${chosen_RET}
    ${ret_angle}  ${ret_maxAngle}  ${ret_minAngle}  ${ret_mechanicalAngle}=  Get RETU Angles  ${ret_param}
    ${current_angle_range}=  Set Variable  ${ret_minAngle}-${ret_maxAngle}
    ${status}  ${range_file_dict}=  Run Keyword If  '${chosen_prodCode}'=='ATM3'
    ...  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  5x  2s
    ...  Select New Angle Range  ${atm3_confFile_set}  ${current_angle_range}
    ...  ELSE IF  '${chosen_prodCode}'=='86010148'
    ...  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  5x  2s
    ...  Select New Angle Range  ${86010148_confFile_set}  ${current_angle_range}
    ...  ELSE IF  '${chosen_prodCode}'=='86010148V01'
    ...  Run Keyword And Ignore Error  Wait Until Keyword Succeeds  5x  2s
    ...  Select New Angle Range  ${86010148V01_confFile_set}  ${current_angle_range}
    ${new_angle_range}=  Get Dictionary Keys  ${range_file_dict}
    ${new_angle_range}=  Get From List  ${new_angle_range}  0
    ${input_file}=  Get From Dictionary  ${range_file_dict}  ${new_angle_range}
    ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
    ${ALD_A}=  Get From Dictionary  ${ALD_R_to_ALD_A}  ${chosen_RET}
    ${ignore}  ${ALD_A}=  Split String From Right  ${ALD_A}  separator=SCF-1/
    ${ALD_A}=  Replace String  ${ALD_A}  search_for=_A  replace_with=
    Log  \nChecking if current angle is within new angle range.  console=${True}
    ${ret_prev_minAngle}  ${ret_prev_maxAngle}=  Split String From Right  ${current_angle_range}  separator=-
    ${ret_minAngle}  ${ret_maxAngle}=  Split String From Right  ${new_angle_range}  separator=-
    ${ret_minAngle}  Set Variable IF    ${ret_minAngle}<${ret_prev_minAngle}    ${ret_prev_minAngle}    ${ret_minAngle}
    ${ret_maxAngle}  Set Variable IF    ${ret_maxAngle}>${ret_prev_maxAngle}    ${ret_prev_maxAngle}    ${ret_maxAngle}
    ${status}    ${new_angle}=  Run Keyword Unless  ${ret_minAngle}<${ret_angle}<${ret_maxAngle}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds  5x  2s  Generate Random RET Angle Value  ${ret_angle}    ${ret_maxAngle}    ${ret_minAngle}
    Run Keyword If    "${status}"=="PASS"   Run Keywords
    ...    Log    \nAngle is out of new angle range. Newly chosen ret angle: ${new_angle}°  console=${True}
    ...    AND    Send Tilt Angle     ${chosen_RET}    ${new_angle}
    ...    ELSE   Log    \nCurrent angle ${ret_angle}° is within new angle range (${new_angle_range})°    console=${True}
    Log  For ${ALD_A}:  console=${True}
    Log  \nCurrent angle range: ${current_angle_range}°,  console=${True}
    Log  \nNew angle range: ${new_angle_range}°,  console=${True}
    Log  \nInput file: ${input_file} will be sent.  console=${True}
    Set Test Variable  ${ALD_A}
    Set Test Variable  ${input_file}
    Set Test Variable  ${chosen_prodCode}
    Set Test Variable  ${chosen_RET}
    Set Test Variable  ${current_angle_range}

CLI.01_Admin_CLI_setRETProperties.Test_Step.2 Sending Configuration File For Selected RET Via CLI
    [Documentation]  This keyword send setRETProperties command for selected RET unit with RET configuration file as a input file.
    Log to console    \n========================================
    Log  Step: 2 Sending Configuration File for Selected RET Via CLI  console=${True}
    Log to console    ========================================
    Collect And Setup ADMIN CLI
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"setRETProperties","parameters":{"id":"${ALD_A}/RETU-1"}}}
    ${requestStatus}  ${error_code}  Run Keyword If  '${chosen_prodCode}'=='ATM3'
    ...  CLI Send Request And Return Status And Error Code  ${command_cli}  input_file=${ATM3_confFile}/${input_file}
    ...  ELSE IF  '${chosen_prodCode}'=='86010148'
    ...  CLI Send Request And Return Status And Error Code  ${command_cli}  input_file=${86010148_confFile}/${input_file}
    ...  ELSE IF  '${chosen_prodCode}'=='86010148V01'
    ...  CLI Send Request And Return Status And Error Code  ${command_cli}  input_file=${86010148V01_confFile}/${input_file}
    Run Keyword If  '${requestStatus}' != 'completed'
    ...  Fail  msg=Command sent with status: ${requestStatus}
    ...  ELSE   Log   Command sent with status: ${requestStatus}  console=${True}
    Calibrate Tilt  ${chosen_RET}
    [Teardown]  CLI.01_Admin_CLI_setRETProperties.Test Specific Teardown

CLI.01_Admin_CLI_setRETProperties.Test_Step.3 Sending Configuration File For Not Existing RET Via CLI
    [Documentation]  This keyword send setRETProperties command for selected RET.
    Log to console    \n========================================
    Log  Step: 3 Sending Configuration File for Not Existing RET Via CLI  console=${True}
    Log to console    ========================================
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"setRETProperties","parameters":{"id":"${ALD_A}/RETU-99"}}}
    ${requestStatus}  ${error_code}  Run Keyword If  '${chosen_prodCode}'=='ATM3'
    ...  CLI Send Request And Return Status And Error Code  ${command_cli}  input_file=${ATM3_confFile}/${input_file}
    ...  ELSE IF  '${chosen_prodCode}'=='86010148'
    ...  CLI Send Request And Return Status And Error Code  ${command_cli}  input_file=${86010148_confFile}/${input_file}
    ...  ELSE IF  '${chosen_prodCode}'=='86010148V01'
    ...  CLI Send Request And Return Status And Error Code  ${command_cli}  input_file=${86010148V01_confFile}/${input_file}
    Run Keyword If  ${error_code} != 70
    ...  Fail  msg=Reported error code: ${error_code} is different than: 70
    ...  ELSE   Log   Correct error code reported: ${error_code}  console=${True}

CLI.01_Admin_CLI_setRETProperties.Test_Step.4 Sending Additional Data For Selected RET Via CLI
    [Documentation]  This keyword send setRETProperties command for selected RET.
    Log to console    \n========================================
    Log  Step: 4 Sending Additional Data For Selected RET Via CLI  console=${True}
    Log to console    ========================================
    Log  ------ Generating RETU Parameters ------  console=${True}
    ${antModel}=  Generate Random String  15  [LETTERS][NUMBERS]$^&*!%()+<>[]
    ${antSerial}=  Generate Random String  17  [LETTERS][NUMBERS]$^&*!%()+<>[]
    ${baseStationID}=  Generate Random String  32  [LETTERS][NUMBERS]$^&*!%()+<>[]
    ${installDate}=  Generate Random String  6  [LETTERS][NUMBERS]$^&*!%()+<>[]
    ${installerID}=  Generate Random String  5  [LETTERS][NUMBERS]$^&*!%()+<>[]
    ${sectorID}=  Generate Random String  32  [LETTERS][NUMBERS]$^&*!%()+<>[]
    ${antennaBearing}=  Evaluate  round(random.uniform(0, 359.9),1)  modules=random
    ${mechanicalAngle}=  Evaluate  round(random.uniform(-90, 90),1)  modules=random
    Log  For ${ALD_A}:  console=${True}
    Log  \nmechanicalAngle: ${mechanicalAngle}°,  console=${True}
    Log  \nantennaBearing: ${antennaBearing}°,  console=${True}
    Log  \nbtsId: ${baseStationID},  console=${True}
    Log  \nsectorId: ${sectorID},  console=${True}
    Log  \nantennaSerialNumber: ${antSerial},  console=${True}
    Log  \nantennaModelNumber: ${antModel},  console=${True}
    Log  \ninstallationDate: ${installDate},  console=${True}
    Log  \ninstallerId: ${installerID}.  console=${True}
    ${var1}=  Set Variable  "mechanicalAngle":${mechanicalAngle},
    ${var2}=  Set Variable  "antennaBearing":${antennaBearing},
    ${var3}=  Set Variable  "btsId":"${baseStationID}",
    ${var4}=  Set Variable  "sectorId":"${sectorID}",
    ${var5}=  Set Variable  "antennaSerialNumber":"${antSerial}",
    ${var6}=  Set Variable  "antennaModelNumber":"${antModel}",
    ${var7}=  Set Variable  "installationDate":"${installDate}",
    ${var8}=  Set Variable  "installerId":"${installerID}"
    ${command_cli}=  Catenate  SEPARATOR=  {"requestId":321,"parameters":{"name":"setRETProperties","parameters":{"id":"${ALD_A}/RETU-1",  ${var1}
    ...  ${var2}  ${var3}  ${var4}  ${var5}  ${var6}  ${var7}  ${var8}  }}}
    ${requestStatus}  ${error_code}  CLI Send Request And Return Status And Error Code  ${command_cli}
    Run Keyword If  '${requestStatus}' != 'completed'
    ...  Fail  msg=Command sent with status: ${requestStatus}
    ...  ELSE   Log   Command sent with status: ${requestStatus}  console=${True}

CLI.01_Admin_CLI_setRETProperties.Test_Step.5 Check ALDs State
    [Documentation]  Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n========================================
    Log  Step: 5 Check ALDs State  console=${True}
    Log to console    ========================================
    Check ALDs State  ${ALD_expected_states}

CLI.01_Admin_CLI_setRETProperties.Test Specific Teardown
    [Documentation]  Test teardown which restores original configuration settings.
    Log  Test Specific Teardown  console=${True}
    ${prev_confFile}=  Run Keyword If  '${chosen_prodCode}'=='ATM3'
    ...  Get From Dictionary  ${atm3_confFile_set}  ${current_angle_range}
    ...  ELSE IF  '${chosen_prodCode}'=='86010148'
    ...  Get From Dictionary  ${86010148_confFile_set}  ${current_angle_range}
    ...  ELSE IF  '${chosen_prodCode}'=='86010148V01'
    ...  Get From Dictionary  ${86010148V01_confFile_set}  ${current_angle_range}
    Log  Back to previous angle setting for ${ALD_A}. \nInput file: ${prev_confFile}  console=${true}
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"setRETProperties","parameters":{"id":"${ALD_A}/RETU-1"}}}
    ${requestStatus}  ${error_code}  Run Keyword If  '${chosen_prodCode}'=='ATM3'
    ...  CLI Send Request And Return Status And Error Code  ${command_cli}  input_file=${ATM3_confFile}/${prev_confFile}
    ...  ELSE IF  '${chosen_prodCode}'=='86010148'
    ...  CLI Send Request And Return Status And Error Code  ${command_cli}  input_file=${86010148_confFile}/${prev_confFile}
    ...  ELSE IF  '${chosen_prodCode}'=='86010148V01'
    ...  CLI Send Request And Return Status And Error Code  ${command_cli}  input_file=${86010148V01_confFile}/${prev_confFile}
    Run Keyword If  '${requestStatus}' != 'completed'
    ...  Fail  msg=Command sent with status: ${requestStatus}
    ...  ELSE   Log   Command sent with status: ${requestStatus}  console=${True}
    Calibrate Tilt  ${chosen_RET}

CLI.01_Admin_CLI_setRETProperties.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}

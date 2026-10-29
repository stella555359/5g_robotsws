*** Settings ***
Library    SSHLibrary

*** Keywords ***
Read Rad Parameter Value From AaShell
    [Documentation]
    ...  *AUTHOR* lukasz.targonski@nokia.com
    ...  This keyword reads rad flag value from AaShell on BTS.
    ...  *INPUT*
    ...  | Parameter              | Description                                              |
    ...  | rad_parameter          | rad parameter name, for example: AaSysLogInputLevel      |
    ...  *OUTPUT*
    ...  | rad parameter value    | for example: 0x1

    [Arguments]  ${rad_parameter}
    SSHLibrary.Open Connection  ${SMOD1['IP']}
    SSHLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    SSHLibrary.Write  telnet localhost 15007
    SSHLibrary.Write  rad -nsr ${rad_parameter}
    Sleep  1s
    ${rad_command_output}  SSHLibrary.Read
    SSHLibrary.Close Connection
    ${rad_parameter_value}  Get Regexp Matches  ${rad_command_output}  = (0x[\\dA-F])  1

    Run Keyword If  ${rad_parameter_value}
    ...  Return From Keyword  ${rad_parameter_value[0]}
    ...  ELSE  FAIL  Value for rad parameter: ${rad_parameter} not found

Read Bts Log Level Value from AaSyslog
    [Documentation]
    ...  In this keyword BTS Log Level is calculated based on the AaSyslog rad parameters values. If AaSysLogInputLevel and AaSysLogOutputLevel
    ...  are set to '0x1', then log level is 1('Full')
    ...  are set to '0x2', then log level is 2('Normal')
    ...  are set to '0x6', then log level is 6('Minimum')
    ...  are set to different values, then log level is other
    ...  *INPUT*
    ...  | Parameter          | Description         |
    ...  | none               | none                |
    ...  *OUTPUT*
    ...  | log level value    | for example: 1      |

    ${AaSysLogInputLevel_value}  Read Rad Parameter Value From AaShell  AaSysLogInputLevel
    ${AaSysLogOutputLevel_value}  Read Rad Parameter Value From AaShell  AaSysLogOutputLevel
    Log  AaSysLogInputLevel value is set to: ${AaSysLogInputLevel_value}  console=${True}
    Log  AaSysLogOutputLevel value is set to: ${AaSysLogOutputLevel_value}  console=${True}

    Run Keyword If  '${AaSysLogInputLevel_value}'=='0x1' and '${AaSysLogOutputLevel_value}'=='0x1'
    ...  Return From Keyword  1
    ...  ELSE IF  '${AaSysLogInputLevel_value}'=='0x2' and '${AaSysLogOutputLevel_value}'=='0x2'
    ...  Return From Keyword  2
    ...  ELSE IF  '${AaSysLogInputLevel_value}'=='0x6' and '${AaSysLogOutputLevel_value}'=='0x6'
    ...  Return From Keyword  6
    ...  ELSE
    ...  Return From Keyword  other

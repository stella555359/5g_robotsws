*** Settings ***
Documentation    Protection of WebEM against HTTP flood attack
...
...              Test Case Scenario author: Piotr Suszynski
...              Test Case Scenario contact: piotr.suszynski@nokia.com
...
...              Test Case auto author: Piotr Suszynski, Jedrzej Kowalski
...              Test Case auto contact: piotr.suszynski@nokia.com, jedrzej.kowalski@nokia.com

Library          String
Library          OperatingSystem
Library          ../Resources/output_parser.py

*** Variables ***
${curl_cmd}=      ${CURDIR}${/}..${/}Resources${/}curl_bash.sh
${sleep_time}=    10 min 10 secs

*** Keywords ***
Number of HTTPS requests exceed the limitation number
    FOR  ${index}  IN RANGE  30
          ${output}=  run  ${curl_cmd}
          Log  \n${output}  console=True
          ${result}=  Parse Webem Login Output  ${output}  ACCESS_WEBEM_LIMITED
          Exit For Loop If    ${result} == True
    END
    Log  ${output}
    should be true  ${result}
    log  \n Info: ACCESS_WEBEM_LIMITED, waiting ${sleep_time} for unblocking...  console=True
    Sleep  ${sleep_time}  reason="Test waits for ${sleep_time} for unblocking logging to WebEM."
    ${output}=  run  ${curl_cmd}
    Log  \n${output}\n  console=True
    ${result}=  Should contain  ${output}  SUCCESS

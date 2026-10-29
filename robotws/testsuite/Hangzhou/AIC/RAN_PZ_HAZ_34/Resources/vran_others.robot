*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vran_others.robot




*** Variables ***



*** Keywords ***
Parse Number Only From Content
    [Arguments]  ${content}
    [Documentation]    Parse Integer Only From Content
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | content       |  yes | content |
    ...
    ...    *RETURN VALUE*
    ...    Number inside content
    ...
    ...    Example
    ...    keyword succeeds
    ...    | ${number} | Parse Intege Only From Content | abc10def |
    ...    | ${number} | Parse Intege Only From Content | abc 11 def |
    ...
    ...    keyword fails
    ...    | ${number} | Parse Intege Only From Content | abcsdfxxxdf.abc |
    ...
    ${matches}    Get Regexp Matches    ${content}    [^0-9]*(\\d+).*   1
    ${number}    Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}
    [Return]  ${number}


String Should Be An Ip Address
    [Arguments]  ${content}
    [Documentation]    String Should Be An Ip Address
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | content       |  yes | content |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | String Should Be An Ip Address | 10.108.227.133 | \# keyword succeeds |
    ...    | String Should Be An Ip Address | 10.108.227.abc |  \# keyword fails |
    ...
    ${matches}    Get Regexp Matches    ${content}    ^(\\d+\\.\\d+\\.\\d+\\.\\d+)$   1
    ${ip_addr}    Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}
    Should Not Be Empty  ${ip_addr}


Get Test Case Name
    [Documentation]   Get Test Case Name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    Test case name,  space and colon will be replaced by underline '_', e.g,
    ...    [1]OAM__vDU_Parameter_Relationships_NRBTS-NRSCTP-f1SctpProfileIdOfDu__5GC001662-M
    ...
    ...    Example
    ...    | ${case_name} | Get Test Case Name  |
    ...
    ${rtn}  Set Variable  ${TEST_NAME.replace(" ","_").replace(":","_")}
    [Return]  ${rtn}


Print A Dictionary
    [Arguments]  ${one_dict}
    [Documentation]   Print A Dictionary's keys/values
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | one_dict | yes   |  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Print A Dictionary | ${my_dict_var}   |
    ...
    ${debug_flag}   Set Variable  1
    Return From Keyword If  ${debug_flag}!=1
    Evaluate   pprint.pprint(${one_dict})   modules=pprint


Compare Version Of RU
    [Arguments]  ${v1}   ${v2}   ${operator}=gt
    [Documentation]    Compare Version Of RU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | v1         | yes | version number1 |
    ...    | v2         | yes | version number2 |
    ...    | operator        | no | operator, it can be eq/gt/ge/lt/le/ne. The meaning is eq:==, gt:>, ge:>=, lt:<, le:<=, ne:!= , default is eq |
    ...    |                 |    | eq:${v1}==${v2},gt:${v1}>${v2}, it's similar for ge/lt/le/ne |

    ...    *RETURN VALUE*
    ...    ${True} or ${False}
    ...
    ...    Example
    ...   Return ${True}
    ...  | ${r} | Compare Version Of RU | FRM50.19.R01 | FRM50.10.R01 | operator=gt |
    ...
    ...   Return ${False}
    ...  | ${r} | Compare Version Of RU | FRM50.09.R01 | FRM50.10.R01 | operator=gt |
    ...
    ${operator}   set variable  ${operator.lower()}

    ${r}  run keyword if  "${operator}"=="gt"    Evaluate  "${v1}">"${v2}"
      ...   ELSE IF   "${operator}"=="ge"   Evaluate  "${v1}">="${v2}"
      ...   ELSE IF   "${operator}"=="lt"   Evaluate  "${v1}"<"${v2}"
      ...   ELSE IF   "${operator}"=="le"   Evaluate  "${v1}"<="${v2}"
      ...   ELSE IF   "${operator}"=="ne"   Evaluate  "${v1}"!="${v2}"
      ...   ELSE IF   "${operator}"=="eq"   Evaluate  "${v1}"=="${v2}"
      ...   Fail    Unknown operator:${operator}

    [Return]  ${r}


Get Case Running Duration
    [Arguments]  ${previous_time}=${EMPTY}
    [Documentation]  Get Case Running Duration
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | previous_time       |  no | previous_time, default value is ${EMPTY} |
    ...
    ...    *RETURN VALUE*
    ...     test case running time, caculate from (<current_time>-${previous_time} ), unit is minute.
    ...
    ...    Example
    ...    |  ${duration} |  Get Case Running Duration |
    ...    |  ${duration} |  Get Case Running Duration | previous_time=2020-12-15 05:53:28 |
    ...
    ${previous_time}   run keyword if  "${previous_time}"=="${EMPTY}"   set variable  ${START_TIME}
    ...   ELSE   set variable  ${previous_time}
    ${current_time}    Get time    exclude_millis=yes
    #${delta}   Subtract Date From Date   ${current_time}   ${START_TIME}    exclude_millis=yes
    ${delta}   Subtract Date From Date   ${current_time}   ${previous_time}    exclude_millis=yes
    ${delta}   evaluate  int(${delta}/60)
    ${delta}   set variable if  ${delta}<1   1   ${delta}
    ${delta}  evaluate  int(${delta})+1
    [Return]  ${delta}


Awk
    [Arguments]  ${content}  ${column}=1  ${separator}=${None}
    [Documentation]  Same as linux command 'awk'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | content   |  yes | content to be fetched by column number |
    ...    | column    |  no | column number, 1 means 1st column, 2 means 2nd column,etc. default is 1 |
    ...    | separator |  no | separator, default is ${None} means whitespace |
    ...
    ...    *RETURN VALUE*
    ...     the value of column, return type is list.
    ...
    ...    Example
    ...    | ${alias} |  Get Unique Id |
    ...    | Connect To VDU Container With Tenant Interactively | ctr_abbr=sdp |  alias=${alias} |
    ...    | ${out} | issh.Execute     | command=ps -ef|grep sdp|grep -v grep  | alias=${alias} |
    ...    | ${out} | Strip Prompt     | ${out} |
    ...    | ${out} | Awk              | content=${out} | column=2 |
    ...    | Disconnect Interactive Connection | alias=${alias} |
    ...
   ${rtn_list}   Create List
   ${lines}  String.Split To Lines   ${content}
   ${column_index}   Evaluate  int(${column}-1)
   FOR  ${line}  IN  @{lines}
      ${column_list}   String.Split String   ${line}   separator=${separator}
      Append To List   ${rtn_list}  ${column_list[${column_index}]}
    END
   [Return]   ${rtn_list}


UTE Get Current Timestamp
    [Documentation]  UTE Get Current Timestamp of UTE server with UTC format
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    current timestamp of UTE server with UTC format, e.g '2023-06-29T16:41:16'
    ...
    ...    Example
    ...    |  ${cur_timestamp} | UTE Get Current Timestamp |
    ...
    ${cur_timestamp}  DateTime.Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S%z  exclude_millis=True
    Log To Console   UTE timestamp(UTC):${cur_timestamp}
    [Return]  ${cur_timestamp}


VDU Get Current Timestamp
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]  VDU Get Current Timestamp of VDU with local timezone, e.g, '2023-06-30 00:30:00'
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    Timestamp of VDU with loca timezone, e.g, '2023-06-30 00:30:00'
    ...
    ...    Example
    ...    |  ${vdu_timestamp} | VDU Get Current Timestamp |
    ...
    ${alias}  Get Unique ID
    Connect To VDU Container With Tenant Interactively   ctr_abbr=oamagent   alias=${alias}
    ${out}  issh.Execute   command=date "+%Y-%m-%dT%H:%M:%S"    alias=${alias}
    ${timestamp}  Strip Prompt   ${out}
    Log To Console   VDU timestamp(local zone):${timestamp}
    [Return]  ${timestamp}


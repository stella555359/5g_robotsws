*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vran_others.robot




#*** Variables ***



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


Parse Hex Number Only From Content
    [Arguments]  ${content}
    [Documentation]    Parse Hex Integer Only From Content
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | content       |  yes | content |
    ...
    ...    *RETURN VALUE*
    ...    Number inside content
    ...
    ...    Example
    ...    keyword succeeds
    ...    | ${hex_number} | Parse Hex Intege Only From Content | ggff00abc10defzz |
    ...    | ${hex_number} | Parse Hex Intege Only From Content | gg ff00abc10def zz |
    ...
    ...    keyword fails
    ...    | ${hex_number} | Parse Intege Only From Content | gghhiii |
    ...
    ${matches}    Get Regexp Matches    ${content}    [^0-9a-fA-F]*([0-9a-fA-F]+).*   1
    ${hex_number}    Set Variable If    ${matches}    ${matches[0]}    ${EMPTY}
    [Return]  ${hex_number}


Should Be A Numerical String
    [Arguments]  ${content}
    [Documentation]    Should Be A Numerical String
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | content       |  yes | content |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    keyword succeeds
    ...    | Should Be A Numerical String | 123 |
    ...    keyword Fails
    ...    | Should Be A Numerical String | a123 |
    ...
    ${tmp_str}   Parse Number Only From Content   ${content}
    should not be empty   ${tmp_str}
    should be true    ${tmp_str.__len__()}==${content.__len__()}


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


Ip Address Comparison Should Be True
    [Arguments]  ${ip1}  ${ip2}   ${operator}=eq
    [Documentation]    Ip Address Comparison Should Be True
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | ip1            | Yes |  ip address you want to increase eg, 10.107.63.206 |
    ...    | ip2            | Yes |  ip address you want to increase eg, 10.107.63.206 |
    ...    | operator       | no  | operator, eq:==, ge:>=, gt:>, le:<=, lt:<, ne:!=, default is eq |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Ip Address Comparison Should Be True | 1.1.1.1 | 1.1.1.2 | operator=le |
    ...    | Ip Address Comparison Should Be True | 1.1.1.1 | 1.1.1.1 | operator=eq |
    ...    | Ip Address Comparison Should Be True | 1.1.1.2 | 1.1.1.1 | operator=ge |
    ...    | Ip Address Comparison Should Be True | 1.1.1.1 | 1.1.1.1 | operator=ge |
    ...
    ${operator}   Set Variable  ${operator.lower()}
    ${result}  Compare_Ip  ip1=${ip1}  ip2=${ip2}   operator=${operator}
    Should Be True  ${result}


Check Pattern Exist
    [Arguments]     ${content}    ${pattern}
    [Documentation]    Check Pattern Exist
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | content | Yes | text to be searched |
    ...    | pattern | Yes | pattern, it's a regexp |
    ...    *RETURN VALUE*
    ...    it returns 1 if pattern exists in content, otherwise return 0
    ...
    ...    Example
    ...    | ${bExit} | Check Pattern Exist |  Machine Model.................................. QUANTA LB9  |  .*QUANTA LB9.* |
    ${bExist}    Set Variable    0
    @{lines}    Split To Lines    ${content}
    FOR   ${line}    IN   @{lines}
       ${line}   Set Variable  ${line.strip()}
       Continue For Loop If   ${line.__len__()}==0
       ${match}    Get Regexp Matches   ${line}    ${pattern}
       ${len}    Get Length    ${match}
       ${bExist}   Set Variable If    ${len}>0    1     0
       Exit For Loop If    ${bExist}==1
    END
    [Return]   ${bExist}





Two Numbers Substraction Should Be
    [Arguments]  ${number1}   ${number2}  ${op}=le  ${delta}=0
    [Documentation]    Two Numbers Substraction Should Be Less Than
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | number1         | yes | number1  |
    ...    | number2         | yes | number2 |
    ...    | op              | no | operator, le/lt/gt/ge/eq, le is <=, lt is <, gt is >, ge is >=, eq is =, default is le|
    ...    | delta           | no | delta value, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...  |  # keyword executes successfully |
    ...  | Two Numbers Substraction Should Be Less Than | number1=90 | number2=100 | op=le | delta=10 |
    ...  | Two Numbers Substraction Should Be Less Than | number1=90 | number2=100 | op=ge | delta=5 |
    ...  |  # keyword executes unsuccessfully |
    ...  | Two Numbers Substraction Should Be Less Than | number1=90 | number2=100 | op=le | delta=20 |
    ...  | Two Numbers Substraction Should Be Less Than | number1=90 | number2=100 | op=ge | delta=15 |
    ...
    ${number1}  Set Variable  ${number1.strip()}
    ${number2}  Set Variable  ${number2.strip()}
    ${diff}  Evaluate  abs(int(float('${number1}'))-int(float('${number2}')))
    Run Keyword If   "${op}"=="le"  Should Be True  ${diff}<=${delta}
    ...   ELSE IF  "${op}"=="lt"  Should Be True  ${diff}<${delta}
    ...   ELSE IF  "${op}"=="ge"  Should Be True  ${diff}>=${delta}
    ...   ELSE IF  "${op}"=="gt"  Should Be True  ${diff}>${delta}
    ...   ELSE IF  "${op}"=="eq"  Should Be True  ${diff}==${delta}
    ...   ELSE     Fail   Unknown parameter op:${op}

#
#Strip Prompt
#    [Arguments]  ${content}  ${remove_last_line}=${True}   ${remove_first_line}=${True}  ${return_list}=${False}
#    [Documentation]  Strip Prompt according to different host type
#    ...    *AUTHOR* chris.l.cao
#    ...    | Input Parameters | Man. | Description |
#    ...    | content        | yes | content to be striped |
#    ...    | remove_last_line  | no | remove_last_line,remove last line if true, else do not remove last line, default is True |
#    ...    | remove_first_line | no | skip_first_line, remove first line if true, else do not remove first line, default is True |
#    ...    | return_list       | no | if yes, return list, otherwise return string|
#    ...
#    ...    *RETURN VALUE*
#    ...    list or string
#    ...
#    ...    Example
#    ...    | connect to fhgw |
#    ...    | ${out}          | issh.Execute | command=hostname |
#    ...    | ${out}          | Strip Prompt | content=${out} |
#    ...    | Disconnect Interactive Connection |
#    ...
#    ${lines}   Split To Lines  ${content}
#
#    #process skip_first_line line
#    Run Keyword If   ${lines.__len__()}>=1 and "${remove_first_line}"=="${True}"   Remove From List  ${lines}   index=0
#
#    #process last line
#    Run Keyword If   ${lines.__len__()}>=1 and "${remove_last_line}"=="${True}"   Remove From List  ${lines}   index=-1
#
#    Return From Keyword If   "${return_list}"=="${True}"    ${lines}
#    ${rtn}  Evaluate  "\\r\\n".join(${lines})
#    [Return]   ${rtn}


Strip Last Line
    [Arguments]  ${content}    ${return_list}=${False}
    [Documentation]  Strip Last Line for content
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | content        | yes | content to be striped |
    ...    | return_list       | no | if yes, return list, otherwise return string|
    ...
    ...    *RETURN VALUE*
    ...    list or string
    ...
    ...    Example
    ...    | connect to fhgw |
    ...    | ${out}          | issh.Execute | command=hostname |
    ...    | ${out}          | Strip Last Line | content=${out} |
    ...    | Disconnect Interactive Connection |
    ...
    ${lines}   Split To Lines  ${content}
    Run Keyword If   ${lines.__len__()}>=1    Remove From List  ${lines}   index=-1
    Return From Keyword If   "${return_list}"=="${True}"    ${lines}
    ${rtn}  Evaluate  "\\r\\n".join(${lines})
    [Return]   ${rtn}


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


_Get Base File Name From URL
    [Arguments]  ${url}
    ${base_file_name}   set variable   ${url.split('/')[-1]}
    [Return]  ${base_file_name}


Get Parent Folder
    [Arguments]  ${folder}
    should be true  "${folder}"!="/"
    ${tmp}   evaluate    [i for i in ${folder.split("/")} if len(i)>0]
    [Return]  ${tmp[0]}


Upper List
    [Arguments]  ${list_in}
    [Documentation]  make list elements to upper.
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | list_in                |  yes | list_in |
    ...
    ...    *RETURN VALUE*
    ...    list which contains upper element
    ...
    ...    Example
    ...    | ${my_upper_list} | Upper List | ${my_list1} |
    ...
    ${tmp}   create list
    FOR   ${i}   IN   @{list_in}
       ${tmp_i}   set variable  ${i.upper()}
       append to list  ${tmp}   ${tmp_i}
    END
    [Return]  ${tmp}


List Substract
    [Arguments]  ${listA}  ${listB}
    [Documentation]  List Substract
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | listA | yes | listA |
    ...    | listB | yes | listB |
    ...
    ...    *RETURN VALUE*
    ...    result of listA-listB, type is list
    ...
    ...    Example
    ...    | ${listA} | create list | a | b | cc |
    ...    | ${listB} | create list | a | b |
    ...    | ${result} | List Substract | ${listA} | ${listB} |
    ...    | now ${result} is ['cc']  |
    ${rtn_list}   Evaluate   list(set(${listA})-set(${listB}))
    [Return]  ${rtn_list}


List Contain Another List
    [Arguments]  ${list1}   ${list2}   ${case_sensitive}=${False}
    [Documentation]  List Contain Another List, return ${True} if list1 contains list2, otherwise return ${False}
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    1.27.2021,chris.l.cao@nokia-sbell.com, add QC_ID(QC_123456) as valid tag
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | list1                |  yes | list1 |
    ...    | list2                |  yes | list2 |
    ...    | case_sensitive       |  no | default is ${False} |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | List Contain Another List | ${list1} | ${list2} |
    ...
    ${tmp_list1}    run keyword if  "${case_sensitive}"=="${False}"  Upper List  ${list1}
    ...   ELSE   set variable   ${list1}
    ${tmp_list2}    run keyword if  "${case_sensitive}"=="${False}"  Upper List  ${list2}
    ...   ELSE   set variable   ${list2}

    ${rtn}   set variable  ${True}
    FOR  ${i}   IN   @{tmp_list2}
        ${QC_UTE_ID_matches}   get regexp matches  ${i}   ^QC_\\d+$|UTE:ID:
        continue for loop if    ${QC_UTE_ID_matches}
        List Should Contain Value   ${tmp_list1}   ${i}
        #${r}  ${out}   run keyword and ignore error  List Should Contain Value   ${tmp_list1}   ${i}
        #run keyword if  "${r}"!="PASS"   log to console  ${i} is not found in ${tmp_list1}!!
        #${rtn}  set variable if  "${r}"!="PASS"   ${False}   ${rtn}
        #exit for loop if  "${r}"!="PASS"
    END

    [Return]  ${rtn}


List Member Appears In Content
    [Arguments]  ${list_name}   ${content}   ${case_sensitive}=${False}
    [Documentation]  List member appears in content, return ${True} , otherwise return ${False}
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | list_name            |  yes | list_name |
    ...    | content              |  yes | content |
    ...    | case_sensitive       |  no | default is ${False} |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${list1} | create list  |  text | here |
    ...    | ${r}     | List Member Appears In Content | ${list1} | abcde aerr jkdjsfa here |
    ...    | should be true | "${r}"=="${True}" |
    ...
    ${tmp_list_name}    run keyword if  "${case_sensitive}"=="${False}"  Upper List  ${list_name}
    ...   ELSE   set variable   ${list_name}

    ${tmp_content}    run keyword if  "${case_sensitive}"=="${False}"   set variable  ${content.upper()}
    ...   ELSE   set variable   ${content}

    ${rtn}   set variable  ${False}
    FOR  ${i}   IN   @{tmp_list_name}
        return from keyword if  """${i}""" in """${tmp_content}"""   ${True}
    END

    [Return]  ${rtn}


Get A Random Value From List
    [Arguments]  ${list_name}
    [Documentation]  Get A Random Value From List
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | list_name            |  yes | list_name |
    ...
    ...    *RETURN VALUE*
    ...    random value in list
    ...
    ...    Example
    ...    | ${list1} | create list  |  1 | 2 | 3 |
    ...    | ${r}     | list_name | ${list1} | ${list1}  |
    ...    | should be true | ${r}>=1 and ${r}<=3 |
    ...
    ${list_len}   get length  ${list_name}
    should be true   ${list_len}>0

    ${list_len_tmp}  evaluate   int(${list_len})-1
    ${random_index}   Evaluate   random.randint(0,int(${list_len_tmp}))    modules=random
    should be true   ${random_index}>=0
    should be true   ${random_index}<${list_len}

    [Return]  ${list_name[${random_index}]}


Compare Version
    [Arguments]  ${v1}   ${v2}   ${operator}=gt
    [Documentation]    Compare Version
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
    ...  | ${r} | Compare Version | 0.390.1224 | 0.390.1223 | operator=gt |
    ...
    ...   Return ${False}
    ...  | ${r} | Compare Version | 0.390.1222 | 0.390.1223 | operator=gt |
    ...
    ...   Return ${True}
    ...  | ${r} | Compare Version | 0.390.1222 | 0.390.1223 | operator=le |
    ...
    ...   Return ${True}
    ...  | ${r} | Compare Version | 0.390.1223 | 0.390.1223 | operator=le |
    ...
    ${v1_list}   split string   ${v1}  .
    ${v2_list}   split string   ${v2}  .
    should be true  ${v1_list.__len__()}== ${v2_list.__len__()}
    should be true  ${v1_list.__len__()}==3

    ${operator}   set variable  ${operator.lower()}

    ${v1_sub_version}   set variable  ${v1_list[2]}
    ${v2_sub_version}   set variable  ${v2_list[2]}

    run keyword if  "${operator}"=="gt"   return from keyword if   ${v1_sub_version}>${v2_sub_version}  ${True}
      ...   ELSE IF   "${operator}"=="ge"   return from keyword if   ${v1_sub_version}>=${v2_sub_version}  ${True}
      ...   ELSE IF   "${operator}"=="lt"   return from keyword if   ${v1_sub_version}<${v2_sub_version}  ${True}
      ...   ELSE IF   "${operator}"=="le"   return from keyword if   ${v1_sub_version}<=${v2_sub_version}  ${True}
      ...   ELSE IF   "${operator}"=="ne"   return from keyword if   ${v1_sub_version}!=${v2_sub_version}  ${True}
      ...   ELSE IF   "${operator}"=="eq"   return from keyword if   ${v1_sub_version}==${v2_sub_version}  ${True}

    [Return]  ${False}


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

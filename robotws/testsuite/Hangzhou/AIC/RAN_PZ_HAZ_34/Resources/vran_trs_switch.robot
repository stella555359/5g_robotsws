*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vran_trs_switch.robot



*** Variables ***



*** Keywords ***
FHGW Switch Set Mirror
    [Arguments]   ${mirror_type}=Mplane  ${mode}=all
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias_fhgw}
    [Documentation]   FHGW Switch Set Mirror
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | mirror_type      | no | mirror_type, e.g, Mplane, Uplane, default is Mplane |
    ...    | mode        | no | mode, e.g, Off, On,Ingress,Egress,All. It's not case-sensitive, the default is all |
    ...    | alias      | no | alias to FHGW, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | FHGW Switch Clear All Mirror Ports |            |
    ...   | FHGW Switch Set Mirror        | mirror_type=Mplane |
    ...   | FHGW Switch Set Mirror        | mirror_type=Mplane | mode=off |
    ...   | FHGW Switch Set Mirror        | mirror_type=Uplane |
    ...   | FHGW Switch Set Mirror        | mirror_type=Uplane | mode=off |
    ...   | Disconnect Interactive Connection  |
    ...
    #do not use old alias here, in order to imporve stability!
    ${alias_fhgw}   get unique id
    Connect To Fhgw   alias=${alias_fhgw}

    Run Keyword If   "${mirror_type}"=="Mplane"   FHGW Switch Set Mirror Port   port=xe0   mode=${mode}   alias=${alias_fhgw}
    ...   ELSE   fail  ${mirror_type} is not supported yet!

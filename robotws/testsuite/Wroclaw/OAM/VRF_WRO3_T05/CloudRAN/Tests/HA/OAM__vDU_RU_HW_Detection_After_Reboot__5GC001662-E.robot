*** Settings ***
Documentation
    ...    history change, <date>,<who>,<what and how>
    ...    7.9.2020, gang.ni@nokia-sbell.com, new case script add
    ...    5.3.2023, chris.l.cao@nokia-sbell.com, adapt to TDD AZQJ and AEQY
    ...    1.4.2023, chris.l.cao@nokia-sbell.com, adapt to FDD, do not check alarm after reboot RU
    ...    11.5.2023, chris.l.cao@nokia-sbell.com, change actDefaultFaultSnapTriggers to fause and restore it in test teardown
    ...                                            wait fault 4527 disappear if it has this fault
    ...    4.1.2024, chris.l.cao@nokia-sbell.com, adapt to DC+TDD
    ...    1.10.2024, jakub.kokoszka@nokia.com, adapt to new team TL

Library     BuiltIn
Library     DateTime
Library     Collections
Library     taf.ul.verify_snapshot    WITH NAME    snapshot
Resource    taf/rfrl/cbts/robot/ru/ru_operations.robot
Resource    ../../Resources/unpacking.robot
Resource    ../../Resources/verdicts.robot
Resource    ../../Resources/common_keywords.robot
Resource    ../../Resources/common_logging.robot
Resource    taf/rfrl/cbts/robot/vdu/vdu_operations.robot
Resource    taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Library     utils.py
Library     taf.hw.fhgw.cli    WITH NAME    fhgw_cli
Library     taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library     taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library     taf.selenium.gnb.oam.coam.vdu         WITH NAME    svdu
Library     taf.config.scf                        WITH NAME    scf
Library     taf.hw.fhgw.cli                       WITH NAME    issh

*** Variables ***
${VDU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vDu.xml
${VCU_SCFC_PATH}  ${CURDIR}/SCF/vCu/vCu.xml


*** Variables ***
${TIMEOUT}        600  # Maximum time to wait (600 seconds)
${INTERVAL}       30   # Interval between checks (30 seconds)


*** Keywords ***
OAM__vDU_RU_HW_Detection_After_Reboot__5GC001662-E
    Step 1: Reboot the first RU
    Step 2: Wait untill RU startup, check if detected RU is consistent with actual HW
    Step 3: Reboot vDU
    Step 4: Check if detected vDU is consistent with actual HW



Step 1: Reboot the first RU
    Log To Console    Step 1: Reboot the first RU
    ${productCode_ori}   ${serialNumber_ori}   ${RU_ID_ori}   Get RU runtime HW information from runtime SCF
    Set Test Variable    ${productCode_ori}
    Set Test Variable    ${serialNumber_ori}
    Set Test Variable    ${RU_ID_ori}
    Setup Host Variables

    ${rmod_id_list}  Get RMOD ID List By RESTAPI
    ${reset_ru_id_list}  Create List   ${rmod_id_list[0]}
    Reset RUs By REST    rmods_list=${reset_ru_id_list}
    Set Test Variable  ${NEED_RESET_VDU}   ${True}

Step 2: Wait untill RU startup, check if detected RU is consistent with actual HW
    Log To Console    Step 2: Wait untill RU startup, check if detected RU is consistent with actual HW
    Wait Until Keyword Succeeds   600  10   Check RU parameters and status Once

Step 3: Reboot vDU
    Log To Console    Step 3: Reboot vDU
    Rest Login vDU
    Reset VDU By REST   need_check_on_air=${True}
    Set Test Variable  ${NEED_RESET_VDU}   ${False}

Step 4: Check if detected vDU is consistent with actual HW
    log to console   Step 4: Check if detected vDU is consistent with actual HW
    Wait Until Keyword Succeeds   600  10   Check RU parameters and status Once




Reset VDU By REST
    [Arguments]    ${need_check_on_air}=${False}   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Reset VDU By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    25.3.2022, chris.l.cao@nokia-sbell.com, extend retry time from 100s to 300s for detecting OAM UP->DOWN
    ...    31.8.2023, chris.l.cao@nokia-sbell.com, check to not being pingable(DOWN), being pingable(UP)
    ...
    ...   | Input Parameters  | Man. | Description |
    ...   | need_check_on_air | No | need_check_on_air, default value is ${False}  |
    ...   | wait             | No | wait, default value is 600s  |
    ...   | gnb_index        | No | gnb_index, default is 0 |
    ...   | vdu_index        | No | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...  None
    ...
    ...   Example
    ...  | Rest Login vDU |
    ...  | Reset VDU By REST |
    ...  | Reset VDU By REST | need_check_on_air=${True} |
    ...
    log to console  Reset VDU By REST...
    ${alias}   Rest Login vDU    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${out}   vdu.reset_vdu    vdu_connection=${alias}
    ${status_msg}   set variable  ${out["status"]}
    should contain  ${status_msg}   ongoing
    ${oam_ip}    Set Variable    ${addr}
    ${out}   Reset VDU Status Should Be Successful   operation_id=${out["id"]}  conn=${alias}
    Run Keyword If  ${need_check_on_air}  Log To Console   Wait OAM up ...
    Run Keyword If  ${need_check_on_air}  wait until keyword succeeds  180  10  Host Should Be Pingable   target_ip=${oam_ip}  deadline=10
    Run Keyword If  ${need_check_on_air}  Log To Console   Wait VDU on-air ...
    Wait For Cells To Be OnAir

    [Teardown]  Run Keyword And Ignore Error  Rest Logout vDU  alias=${alias}

Wait For Cells To Be OnAir
    [Documentation]    Keyword checks cell status until the condition is met

    ${start_time}=     Evaluate    time.time()
    FOR    ${i}    IN RANGE    0    ${TIMEOUT}/${INTERVAL}
        Wait Until Keyword Succeeds   960  30    Get vDU Cells Status
        ${all_cells_ready}=    Check Cell Status    ${get_cells_statuses}
        Run Keyword If    ${all_cells_ready}    Return From Keyword
        Sleep    ${INTERVAL}
        ${elapsed_time}=    Evaluate    time.time() - ${start_time}
        Exit For Loop If    ${elapsed_time} > ${TIMEOUT}
    END
    Fail    Cells did not reach onair state within ${TIMEOUT} seconds

Get vDU Cells Status
    [Documentation]
    ...  This KW Get vDU Cells Status

    ${get_cells_statuses}=    vdu.Get Vdu Cells Status
    Set Test Variable  ${get_cells_statuses}

Check Cell Status
    [Documentation]
    ...  This KW Check Cell Status

    [Arguments]    ${get_cells_statuses}
    ${cells_statuses}=    Set Variable    ${get_cells_statuses}
    FOR    ${cell}    IN    @{cells_statuses}
        ${administrative_state}=    Get From Dictionary    ${cell}    administrative_state
        ${availability_status}=     Get From Dictionary    ${cell}    operational_state
        ${operational_state}=       Get From Dictionary    ${cell}    availability_status

        Run Keyword If    '${administrative_state}' == 'None'    Return From Keyword    False
        Run Keyword If    '${availability_status}' == 'None'    Return From Keyword    False
        Run Keyword If    '${operational_state}' == 'None'    Return From Keyword    False

        Run Keyword If    '${administrative_state.lower()}' != 'unlocked'    Return From Keyword    False
        Run Keyword If    '${availability_status.lower()}' != 'enabled'      Return From Keyword    False
        Run Keyword If    '${operational_state.lower()}' != 'on line'        Return From Keyword    False

    END
    RETURN    True

Get vDU Number
    [Arguments]   ${gnb_index}=0
    [Documentation]  Get vDU Number
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vDU number
    ...
    ...    Example
    ...    | ${vDU_number} | Get vDU Number |
    ...
    ${vDU_number}  get length   ${tl.gnbs[${gnb_index}].dus}
    RETURN   ${vDU_number}

CU Rest Login
   [Arguments]   ${gnb_index}=0   ${alias}=${None}   ${restapi_version}=cuoam_22r4  ${delay}=${EMPTY}
   ...  ${is_default_password}=${False}
   [Documentation]  Create rest session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  16.9.2021, chris.l.cao@nokia-sbell.com, add to logout before login
    ...  11.1.2022, chris.l.cao@nokia-sbell.com, add parameter delay
    ...  1.8.2022,  rui.3.li@nokia-sbell.com, update restapi_version default value to cuoam_22r4; add restapi version autodetection
    ...                           based on CU SW release stream, if 0.250, the latest restapi version will be selected,
    ...                           otherwise the previous version will be selected.
    ...  3.8.2022, chris.l.cao@nokia-sbell.com, add '_Get VCU Rest Api Version'
    ...  10.11.2022, rui.3.li@nokia-sbell.com, support call keyword after reinstall in case, rather than agent
    ...  1.7.2023, chris.l.cao@nokia-sbell.com, add 'Get Alias from vCU' to support multip VCU operation
    ...  21.8.2023, rui.3.li@nokia-sbell.com, adapt keyword for ipv6
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    | restapi_version | No | if you use 'get_counter' keyword in CU trunk build, the parameter should be given 'cuoam_21b'
    ...                             other senarios should be use default value - cuoam_21b |
    ...    |  alias | No. | alias that identifies this connection, if the argument is given,
    ...                     the alias must be given to the CU Logout keyword as connection argumument. |
    ...    |  delay | No |  delay, default is ${EMPTY}  |
    ...    |  is_default_password | No | is use default password 'nemuuser', default False use 'Nokia@123' |
	...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...    Example
    ...    | CU Rest Login   |
    ...    | CU Rest Login   |  delay=3  |
    ...    | ${alias}        | CU Rest Login | gnb_index=1 |
    ...
    ${alias}   Get Alias from vCU   gnb_index=${gnb_index}   alias=${alias}
    ${host}   Set Variable   ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}

    run keyword and ignore error  Rest Logout for CU   connection=${alias}   gnb_index=${gnb_index}
    ${host}   set variable if   ':' in '''${host}'''   [${host}]    ${host}
    ${status}  ${restapi_version}  Run Keyword And Ignore Error   _Get VCU Rest Api Version  gnb_index=${gnb_index}
    ${restapi_version}   Set Variable If    '${status}'=='FAIL'    ${VCU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}     ${restapi_version}
    ${index}     Get Index From List     ${VCU_REST_TAF_LIB_SUPPORTED_VERSION}     ${restapi_version}
    ${password}    Set Variable If    ${index}>=${3}    Nokia@123
    ...    ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${password}    Set Variable If    '${is_default_password}'=='${True}'    nemuuser    ${password}
    cu.connect to    host=${host}
    ...    port=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.port}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${password}
    ...    cu_version=${restapi_version}
    ...    secure=${True}
    ...    alias=${alias}
    ...    timeout=10


    Run Keyword If  "${delay}"!="${EMPTY}"  Sleep   ${delay}

    RETURN  ${alias}

Rest Logout for CU
    [Arguments]  ${connection}=${None}  ${gnb_index}=0
    [Documentation]  Teardown rest session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  1.7.2023, chris.l.cao@nokia-sbell.com, add 'gnb_index' to support multip VCU operation

    ...    | Input Parameters | Man. | Description |
    ...    | connection | No. | the connection alias that used in CU login |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Rest Logout for CU |   |
    ${alias}   Get Alias from vCU   gnb_index=${gnb_index}   alias=${connection}
    cu.disconnect   connection=${alias}  timeout=10

Get Alias from vCU
    [Arguments]  ${gnb_index}=0   ${alias}=${None}
    [Documentation]  Get Alias from vCU
    ...    author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   1.7.2023, chris.l.cao@nokia-sbell.com, support multiple VCU operation
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    |  alias | No. | alias that identifies this connection |
	...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...
    ...    Example
    ...    | ${alias} | Get Alias from vCU   |  gnb_index=0   |
    ...
    Return From Keyword If   "${alias}"!="${None}"      ${alias}
    ${alias}   Set Variable If   ${gnb_index}==0   ${None}   vcu_connection_${gnb_index}
    RETURN  ${alias}

Get VCU Cell Number From SCF
    [Arguments]   ${gnb_index}=${0}
    [Documentation]  Get VCU Cell Number From SCF
    ...   *Author*: rui.3.li@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2022-11-10 | r3li | new |
    ...   | 2023-7-5 | r3li | correct error for CU Rest Login changed |
    ...   | 2023-7-24 | chris.l.cao | change from "multiple_folder/scf.xml" to "one_folder/multiple_scf_.xml files |
    ...   | 2023-12-15 | chris.l.cao | change to use 'vCU Get Cell List From Webem'
    ...
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | gnb_index | No | gnb index to indicate which gnb will be used, default is 0 |
    ...
    ...   *Return*
    ...   Cell number from test line configuration
    ...
    ...   *Example*
    ...   | ${cell_number} | Get VCU Cell Number From SCF |
    ...
    ${cell_list}  vcu_operations.vCU Get Cell List From Webem   gnb_index=${gnb_index}
    RETURN   ${cell_list.__len__()}

Host Should Be Pingable
    [Arguments]  ${target_ip}   ${deadline}=10
    [Teardown]  run keyword and ignore error   disconnect interactive connection   alias=${alias}
    [Documentation]   Check whether Host is Pingable or not from current running UTE server. If it's pingable, do nothing.
    ...    If it's not pingable, report FAIL.
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | target_ip | Yes | Target host, e.g, 10.97.120.118  |
    ...    | deadline | no | deadline, default is 10  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | ${rtn} | Host Should Be Pingable | 10.97.120.118 |
    ...
    ${bIpV6Address}    Set Variable If    ":" in """${target_ip}"""    1      0
    ${cmd}    Set Variable If   ${bIpV6Address}==1   sudo ping6 ${target_ip} -c 2 -w ${deadline}
    ...   sudo ping ${target_ip} -c 2 -w ${deadline}

    ${random_number}    Evaluate    random.randint(1, 99)    modules=random
    ${random_number2}    Evaluate    random.randint(1, 99)    modules=random

    ${alias}  Set Variable    alias${random_number2}${random_number}
    connect to ute locally    alias=${alias}
    ${out}   issh.Execute   command=${cmd}   alias=${alias}

    ${matches}   Get Regexp Matches  ${out}   .*\\s+(\\d+)%\\s+packet\\s+loss.*   1
    Should Be True  ${matches}
    ${loss_number}   Set Variable  ${matches[0]}
    Should Be True  ${loss_number}==0

Reset VDU Status Should Be Successful
    [Arguments]  ${operation_id}   ${conn}=default
    [Documentation]   Reset VDU Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | Rest Login vDU |
    ...  | Reset VDU Status Should Be Successful | operation_id=<my_operation_id> |
    ...
    ${out}   Wait Until Keyword Succeeds  60   3   _Reset VDU Status Should Be Expected
    ...   operation_id=${operation_id}    expected_status=ongoing   conn=${conn}
    RETURN  ${out}


Get vDU OAM Ip
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get vDU OAM Ip
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VDU OAM ip
    ...
    ...    Example
    ...    | ${vdu_oam_ip} | Get vDU OAM Ip |
    ...    | ${vcu_oam_http_connection_info} | Get vDU OAM Ip | vdu_index=1 |
    ...

    ${vdu_oam_http_connection_info}   OAM Http Connection Info From vDU    gnb_index=${gnb_index}
    ${vdu_oam_ip}   set variable  ${vdu_oam_http_connection_info["addr"]}

    RETURN  ${vdu_oam_ip}

Check RU parameters and status Once
    Log To Console   Check RU parameters and status Once
    log to console    Get RU runtime HW information from runtime SCF
    ${productCode_get}   ${serialNumber_get}   ${RU_ID_get}   Get RU runtime HW information from runtime SCF
    should be equal    ${productCode_ori}     ${productCode_get}
    should be equal    ${serialNumber_ori}    ${serialNumber_get}
    should be equal    ${RU_ID_ori}           ${RU_ID_get}

    log to console    Get RU runtime Status from runtime SCF
    ${administrativeState}   ${operationalState}   ${proceduralStatus}   Get RU runtime Status from runtime SCF
    should be equal    ${administrativeState}    unlocked    ignore_case=True
    should be equal    ${operationalState}       enabled     ignore_case=True
    should be equal    ${proceduralStatus}       configured  ignore_case=True

Get RU runtime Status from runtime SCF
    [Arguments]
    [Documentation]   Get administrativeState/operationalState/proceduralStatus from runtime SCF
    ...    *AUTHOR* gang.ni@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |         |  |   |
    ...   *RETURN VALUE*
    ...    administrativeState, operationalState, proceduralStatus
    ...   Example
    ...   | Get RU runtime Status from runtime SCF |  |

    Rest Login vDU

    ${timestamp}    Get Timestamp
    ${scf_path}     Set Variable     /home/ute/logs/

    ${scf_file_with_fullpath}    vdu.Get_Current_Plan_File    local_dir_path=${scf_path}
    ...                                                       filename=scf_${timestamp}.xml
    ...                                                       include_runtime_data=${True}

    scf.Load_Scf    file_path=${scf_file_with_fullpath}

    ${mrbts_id}    Get BTS ID From vDU SCF    ${scf_file_with_fullpath}
    ${EQM_ID}    ${APEQM_ID}    ${RU_ID}  ${RU_ID_R}    Get Running EQM APEQM RMOD ID From vDU SCF    ${scf_file_with_fullpath}

    ${RMOD_DISTNAME}  Set Variable   MRBTS-${mrbts_id[0]}/EQM_R-${EQM_ID}/APEQM_R-${APEQM_ID}/RMOD_R-${RU_ID_R}

    ${administrativeState}    scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
    ...                                                 p_name=administrativeState
    Log To Console     ${administrativeState}
    ${operationalState}       scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
    ...                                                 p_name=operationalState
    Log To Console     ${operationalState}
    ${proceduralStatus}       scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
    ...                                                 p_name=proceduralStatus
    Log To Console     ${proceduralStatus}

    Rest Logout vDU

    RETURN    ${administrativeState}    ${operationalState}     ${proceduralStatus}

Get Timestamp
    [Arguments]  ${format}=epoch
    ${ts}    Get Time     ${format}
    RETURN  ${ts}

Get RU runtime HW information from runtime SCF
    [Documentation]   Get RU ID and also productName/productCode/serialNumber from runtime SCF
    ...    *AUTHOR* gang.ni@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |         |  |   |
    ...   *RETURN VALUE*
    ...    productName, productCode, serialNumber, RU_ID
    ...   Example
    ...   | Get RU runtime HW information from runtime SCF |  |

    Rest Login vDU
    ${scf_file_with_fullpath}  Get VDU SCF From Current Plan  include_runtime_data=${True}
    ${mrbts_id}    Get BTS ID From vDU SCF    ${scf_file_with_fullpath}
    ${eqm_id}    ${apeqm_id}    ${rmod_id}  ${rmod_id_r}    Get Running EQM APEQM RMOD ID From vDU SCF    ${scf_file_with_fullpath}

    ${rmod_distname}  Set Variable   MRBTS-${mrbts_id[0]}/EQM-${eqm_id}/APEQM-${apeqm_id}/RMOD-${rmod_id}

    scf.Load_Scf      file_path=${scf_file_with_fullpath}
    ${productCode}     scf.Get_Value_From_Scf    dist_name=${rmod_distname}    p_name=prodCodePlanned
    Log To Console     ${productCode}
    ${serialNumber}    scf.Get_Value_From_Scf    dist_name=${rmod_distname}    p_name=serialNumberPlanned
    Log To Console     ${serialNumber}

    RETURN     ${productCode}     ${serialNumber}    ${rmod_id}

Get Running EQM APEQM RMOD ID From vDU SCF
    [Arguments]  ${scf_path}
    [Documentation]   Get RU ID and also EQM/APEQM ID from runtime SCF
    ...    *AUTHOR* gang.ni@nokia-sbell.com
    ...  Change History
    ...  2022.1.1  chris.l.cao@nokia-sbell.com, change regexp
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path         | Yes | full path and file name  |
    ...
    ...   *RETURN VALUE*
    ...    EQM_ID, APEQM_ID, RMOD_ID
    ...
    ...   Example
    ...   |  ${eqm_id} |  ${apeqm_id} |  ${rmod_id} | Get Running EQM APEQM RMOD ID From vDU SCF | ${scf_file_with_fullpath} |

    ${scf_content}   OperatingSystem.Get File      ${scf_path}

    ${result_r}     Get Regexp Matches    ${scf_content}   .*MRBTS-(\\d+)/EQM_R-(\\d+)/APEQM_R-(\\d+)/RMOD_R-(\\d+)"   1  2  3  4
    ${result}       Get Regexp Matches    ${scf_content}   .*MRBTS-(\\d+)/EQM-(\\d+)/APEQM-(\\d+)/RMOD-(\\d+)"   1  2  3  4
    ${eqm_id}     Set Variable  ${result[0][1]}
    ${apeqm_id}   Set Variable  ${result[0][2]}
    ${rmod_id_r}      Set Variable  ${result_r[0][3]}
    ${rmod_id}      Set Variable  ${result[0][3]}

    RETURN    ${eqm_id}    ${apeqm_id}    ${rmod_id}    ${rmod_id_r}

Get BTS ID From vDU SCF
    [Arguments]  ${scf_path}
    [Documentation]  Get BTS ID From vDU SCF
    ...   *Author*: chris.l.cao@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | scf_path | Yes | scf file with absolute path, it's vDU scf file. |
    ...   *Return*
    ...   list value, contains [<mrbts_id>, <nrbts_id>, <nrdu_id>]
    ...   *Example*
    ...   | ${mrbts_id} | ${nrbts_id} | ${nrdu_id} | Get BTS ID From vDU SCF | scf_path=/tmp/a.scf |
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}     Get Regexp Matches    ${scf_content}   .*NRDU"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRDU-(\\d+)"\\s+.*   1  2  3
    ${mrbts_id}  Set Variable If  ${result}   ${result[0][0]}
    ${nrbts_id}  Set Variable If  ${result}   ${result[0][1]}
    ${nrdu_id}   Set Variable If  ${result}   ${result[0][2]}
    RETURN  ${mrbts_id}   ${nrbts_id}  ${nrdu_id}

Get VDU SCF From Current Plan
    [Arguments]   ${gnb_index}=0    ${vdu_index}=0   ${include_runtime_data}=${False}
    [Documentation]  Get VDU SCF From Current Plan
    ...  author: chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  13.5.2023   chris.l.cao@nokia-sbell.com, add include_runtime_data
    ...  2.7.2023   chris.l.cao@nokia-sbell.com, support multiple VDU
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...    | include_runtime_data | no | include_runtime_data, default is ${False} |
    ...
    ...    *RETURN VALUE*
    ...    scf file full name
    ...
    ...    Example
    ...    | ${scf_file_with_fullpath} | Get VDU SCF From Current Plan |
    ...    | ${scf_file_with_fullpath} | Get VDU SCF From Current Plan | include_runtime_data=${True} |
    ...    | ${scf_file_with_fullpath} | Get VDU SCF From Current Plan | gnb_index=0 | vdu_index=0 |
    ...    | ${scf_file_with_fullpath} | Get VDU SCF From Current Plan | gnb_index=0 | vdu_index=1 |
    ...    | ${scf_file_with_fullpath} | Get VDU SCF From Current Plan | gnb_index=1 | vdu_index=0 |
    ...    | ${scf_file_with_fullpath} | Get VDU SCF From Current Plan | gnb_index=1 | vdu_index=1 |
    ...
    ${tmp_scf_path}=  Set Variable    /home/ute/logs

    ${random_number}    Evaluate    random.randint(1, 99)    modules=random
    ${random_number2}    Evaluate    random.randint(1, 99)    modules=random
    ${file_name}        Set Variable    scf_tmp_${random_number}${random_number2}.xml

    ${alias}   Rest Login vDU    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${tmp_scf_full_path}  vdu.get_current_plan_file
      ...   local_dir_path=${tmp_scf_path}  filename=${file_name}  include_runtime_data=${include_runtime_data}   vdu_connection=${alias}
    RETURN  ${tmp_scf_full_path}

Reset RUs By REST
    [Arguments]   ${rmods_list}   ${vdu_index}=0   ${gnb_index}=0   ${expect_status}=ongoing
    [Documentation]   Reset RUs by rmod id list.
    ...   *AUTHOR* fen.huang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | Rest Login vDU |
    ...  |  Reset RUs By REST  |
    ...
    log to console   Reset RUs ${rmods_list} by REST...
    vdu login  vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${out}   vdu.reset_rmods     ${rmods_list}
    Reset RUs Operation Should Be Successful   operation_id=${out["operation_id"]}   expect_status=${expect_status}
    [Teardown]  vdu logout

vDU Logout
    [Arguments]   ${logout_type}=rest   ${alias}=default
    [Documentation]  Teardown login session to CU
    ...   *Author*: fen.huang@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2019-11-22 | f2huang | initial creation |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | logout_type | Yes | default is rest |
    ...   | alias | No | default is default |
    ...   *Return*
    ...   None
    ...   *Example*
    ...   | vDU Logout |
    run keyword if  "${logout_type}"=="rest"    Rest Logout vDU   alias=${alias}
    ...   ELSE    vDU WebEM Logout

Rest Logout vDU
    [Arguments]  ${vdu_index}=0  ${alias}=default    ${gnb_index}=0
    [Documentation]  Rest Logout vDU
    ...  *Author*:calla.wang@nokia-sbell.com
    ...  *History Change*:
    ...  | date | who | what or how |
    ...  | 2020-09-04 | chris.l.cao@nokia-sbell.com | add check for OAM up or down |
    ...  | 2020-09-11 | chris.l.cao@nokia-sbell.com | change to use 'Wait Until VDU OAM Up' |
    ...  | 2022-3-31 | r3li                        | update documentation |
    ...  | 2023-7-1  | chris.l.cao@nokia-sbell.com | add 'gnb_index' to support multip VCU operation |
    ...  | 2023-7-25  | chris.l.cao@nokia-sbell.com | add timeout to vdu.disconnect |
    ...
    ...  *Argument Decription*
    ...  | Input Parameters | Man. | Description |
    ...  | gnb_index | No | gnb index, default is 0 |
    ...  | vdu_index | No | vdu index, default is 0 |
    ...  | alias | No | The alias of connect vdu with rest api |
    ...
    ...  *Return*
    ...
    ...  *Example*
    ...  | Rest Login vDU |
    ...  | Rest Logout vDU |
    ...
    ${alias}   Get Alias for vDU   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    vdu.disconnect  vdu_connection=${alias}   timeout=10

Reset RUs Operation Should Be Successful
    [Arguments]  ${operation_id}   ${expect_status}=ongoing
    [Documentation]   Reset RUs operation should Be successful
    ...   *AUTHOR* fen.huang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   |  operation_id    | yes |  operation_id  |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | Rest Login vDU |
    ...  |  Reset RUs Operation Should Be Successful  | operation_id=1 |
    ...
    Wait Until Keyword Succeeds  600   30   _Reset RUs Status Should Be Expected   operation_id=${operation_id}    expected_status=${expect_status}

_Reset RUs Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}
    ${out}   vdu.get_reset_rmods_operation_status   operation_id=${operation_id}
    Should Be True  "${out["status"]}"=="${expected_status}"

vDU Login
    [Arguments]  ${login_type}=rest   ${restapi_version}=cuoam_22r4   ${vdu_index}=0   ${gnb_index}=0   ${vdu_version}=coam22r2
    [Documentation]  Login to vdu via rest or webem.
    ...   *Author*: calla.wang@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2019-11-13 | f2huang |  |
    ...   | 2022-1-27 | r3li | add variable ${vdu_version} |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   | 2023-9-5 | chenwei | update ${vdu_version} |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | login_type | No | login type, rest or webui, default is rest |
    ...   | restapi_version | No | restapi_version, Current possibilities: [`cuoam_19b`, `cuoam_21b`, 'cuoam_22r2', 'cuoam_22r4'].
    ...                            Defaults to newest implemented release - cuoam_22r4 |
    ...   | vdu_index | No | the index of vdu, default value is 0 |
    ...   | gnb_index | No | the index of gnb, default value is 0 |
    ...   | vdu_version | No | vdu version |
    ...   *Return*
    ...   None
    ...   *Example*
    ...   | vDU Login | rest | cuoam_21b | 0 | 0 | 5G22R2 |
    run keyword if  "${login_type}"=="rest"    Rest Login vDU   ${restapi_version}  ${vdu_index}  ${gnb_index}
    ...   ELSE   vDU WebEM Login  ${vdu_index}   ${gnb_index}   ${vdu_version}

Rest Login vDU
    [Arguments]   ${vdu_index}=0  ${gnb_index}=0  ${alias}=default  ${delay}=${EMPTY}
    ...           ${username}=${EMPTY}   ${password}=${Empty}
    [Documentation]  login vdu webem by restful api.
    ...   *Author*: calla.wang@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2022-3-31 | r3li | Update documentation |
    ...   | 2022-7-27 | calwang | update restapi_version default value to cuoam_22r4; add restapi version autodetection
    ...                           based on vDU SW release stream, if 0.300, the latest restapi version will be selected,
    ...                           otherwise the previous version will be selected. |
    ...   | 2022-8-1 | r3li | code enhance |
    ...   | 2022-8-3 | chris.l.cao | add 'VDU Rest Api Version Check' |
    ...   | 2022-10-21 | calla | adding two parameters - username and passowrd to support
    ...                          users can rest login to vdu by special username and password. |
    ...   | 2023-7-1 | chris.l.cao | add gnb_index while calling 'Rest Logout vDU'
    ...
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | restapi_version | No | restapi_version, Current possibilities: [`cuoam_19b`, `cuoam_21b`, 'cuoam_22r2', 'cuoam_22r4',
    ...                            'cuoam_23r1']. Defaults to newest implemented release - cuoam_23r1 |
    ...   | vdu_index | No | the index of vdu, default value is 0 |
    ...   | gnb_index | No | the index of gnb, default value is 0 |
    ...   | alias | No | connect name |
    ...   | delay | No | whether is there need sleep, default is ${EMPTY} means not sleep |
    ...   | username | No | vdu webem username, default is EMPTY. If not given, the username will be get from testline configuration |
    ...   | passwork | No | vdu webem password, default is EMPTY. If not given, password is 'Nokia@123' from 23r1 release,
    ...                     'nemuuser' in those older releases than 23r1 |
    ...   *Return*
    ...   None
    ...   *Example*
    ...   | Rest Login vDU | cuoam_21b | 0 | 0 | default | ${EMPTY} |
    ...   | Rest Login vDU | cuoam_19b | 0 | 0 | default | 10s |
    ...
    ${alias}   Get Alias for vDU   gnb_index=${gnb_index}  vdu_index=${vdu_index}   alias=${alias}
    run keyword and ignore error  Rest Logout vDU    alias=${alias}  vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${vdu_oam_http_connection_info}     OAM Http Connection Info From vDU    ${gnb_index}
    ${oam_httpaddr}   set variable   ${vdu_oam_http_connection_info["addr"]}
    ${oam_web_ip}   set variable if   ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    ${http_username}  Run Keyword If  "${username}"=="${EMPTY}"  set variable  ${vdu_oam_http_connection_info["username"]}
    ...  ELSE  set variable   ${username}
    ${http_password}  Run Keyword If  "${password}"=="${EMPTY}"   Set Variable  ${vdu_oam_http_connection_info["password"]}
    ...  ELSE  set variable   ${password}
    vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${http_username}
    ...  password=${http_password}
    ...  vdu_version=${vdu_oam_http_connection_info["restapi_version"]}
    ...  secure=True
    ...  connection_name=${alias}
    ...  timeout=10
    Run Keyword If  "${delay}"!="${EMPTY}"  Sleep   ${delay}
    RETURN  ${alias}

vDU WebEM Login
    [Arguments]   ${vdu_index}=0   ${logout_firstly}=${False}   ${version}=coam22r2
    [Documentation]  Login to vDU via WebEM.
    ...    author: calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...   07.9.2020,peng.lin@nokia-sbell.com, updat
    ...   11.9.2020,chris.l.cao@nokia-sbell.com, add check VDU OAM Up or Down
    ...   26.10.2021,chris.l.cao@nokia-sbell.com, add ${VDU_WEBEM_LOGIN_INSTANCE_ID} to speed case running time
    ...   27.1.2022,rui.3.li@nokia-sbell.com, add variable ${version}
    ...   25.8.2023,chris.l.cao@nokia-sbell.com, change version to coam22r2
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  vdu_index  | Yes | the index of vdu, default value is 0 |
    ...    | logout_firstly | No | is logout firstly, default is False |
    ...    | version | No | vdu version,default is 5G22R2 |

    log to console   \n*** Start vDU webui login  ***

    ${vdu_oam_http_connection_info}   OAM Http Connection Info From vDU  vdu_index=${vdu_index}
    ${oam_httpaddr}   set variable   ${vdu_oam_http_connection_info["addr"]}
    ${oam_web_ip}   set variable if   ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    ${vdu_oam_url}   Set Variable  https://${oam_web_ip}
    ${username}  set variable  ${vdu_oam_http_connection_info["username"]}
    ${password}  set variable  ${vdu_oam_http_connection_info["password"]}
    run keyword if  "${logout_firstly}"=="${True}"   run keyword and ignore error  vDU WebEM Logout
    wait until keyword succeeds  3x  5s
     ...   svdu.Login   url=${vdu_oam_url}    username=${username}   password=${password}   timeout=${120}   version=${version}

    Set Test Variable   ${VDU_WEBEM_LOGIN_INSTANCE_ID}    vDU WebEM Login is Called.

vDU WebEM Logout
      [Documentation]  Logout vDU webui.
    ...    author: calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...   11.9.2020,chris.l.cao@nokia-sbell.com, change to use 'Wait Until VDU OAM Up'
    ...   26.10.2021,chris.l.cao@nokia-sbell.com, add ${VDU_WEBEM_LOGIN_INSTANCE_ID} to speed case running time
    ...
    ...    | Input Parameters | Man. | Description |
    ...
    ...    |  CU Webui Logout   |     |
    ${r}   Run Keyword And Return Status   Variable Should Exist   ${VDU_WEBEM_LOGIN_INSTANCE_ID}
    Return From Keyword If  "${r}"=="${False}"
    Return From Keyword If  "${VDU_WEBEM_LOGIN_INSTANCE_ID}"=="${None}"

    log to console   \n*** VDU Webui Logout ***
    svdu.Logout

    Set Test Variable   ${VDU_WEBEM_LOGIN_INSTANCE_ID}    ${None}

OAM Http Connection Info From vDU
    [Arguments]    ${gnb_index}=0
    [Documentation]  OAM Http Connection Info From vDU
     ...   *author*: chris.l.cao@nokia-sbell.com
     ...   *history change*:
     ...   | date | who | what and how |
     ...   | 11.12.2021 | chris.l.cao@nokia-sbell.com | convert robot KW to python KW |
     ...   | 13.9.2022 | rui.3li@nokia-sbell.com | add version judgment |
     ...   | 21.10.2022 | calla | adding restapi_version in the return value |
     ...
     ...    | Input Parameters | Man. | Description |
     ...	| gnb_index | no | gnb_index, default is 0 |
     ...	| vdu_index | no | vdu_index, default is 0 |
     ...
     ...    *RETURN VALUE*
     ...    Dictionary of OAM connection information defined in __init__.py,
     ...           dictionary keys are addr, username, password and port.
     ...    example: {'addr': '1.1.1.1', 'username': 'Nemuadmin', 'password': 'nemuuser', 'port': '443'}
     ...
     ...    Example
     ...    | ${vdu_oam_http_connection_info} | OAM Http Connection Info From vDU |
     ...    | ${vdu_oam_http_connection_info} | OAM Http Connection Info From vDU | vdu_index=1 |
     ...
    ${status}  ${restapi_version}  Run Keyword And Ignore Error   VDU Rest Api Version Check  gnb_index=${gnb_index}
    ${restapi_version}   Set Variable If    '${status}'=='FAIL'    ${VDU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}     ${restapi_version}
    ${addr}    Set Variable    ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    Set Test Variable  ${addr}
    ${username}    Set Variable    ${tl.gnbs[0].dus[0].oam_http_connection_details.username}
    ${index}     Get Index From List     ${VDU_REST_TAF_LIB_SUPPORTED_VERSION}     ${restapi_version}
    ${password}    Set Variable If    ${index}>=${4}     Nokia@123
    ...    ${tl.gnbs[0].dus[0].oam_http_connection_details.password}
    ${result}    Create dictionary    addr=${addr}    username=${username}    password=${password}   port=443
    ...  restapi_version=${restapi_version}
    RETURN    ${result}

VDU Rest Api Version Check
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    ${current_build_version}    Get Running Build Number   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${sw_steam}=    Evaluate    '.'.join(${current_build_version.split('.')[:2]})
    ${restapi_version}    Set Variable   ${VDU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING['${sw_steam}']}
    RETURN   ${restapi_version}

Get Running Build Number
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${with_prefix}=${False}   ${print_or_not}=${False}
    [Documentation]   Get Running Build Number
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   27.11.2021,chris.l.cao@nokia-sbell.com, remove NCIR platform to shorten dryrun time
    ...   3.8.2022,chris.l.cao@nokia-sbell.com, remove NCS platform to shorten dryrun time
    ...   19.1.2023,chris.l.cao@nokia-sbell.com, add parameter with_prefix and print_or_not
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...    | with_prefix    | No | with_prefix, if ${True} it has the prefix like vDUCNF00_, default is ${False} |
    ...    | print_or_not      | No | print_or_not, if ${True} it prints the buil number, default is ${False} |
    ...
    ...    *RETURN VALUE*
    ...    vdu running build number, e.g, 0.390.928
    ...
    ...    Example
    ...    |  ${build_number}  | Get Running Build Number |
    ...
    ${build_number}    _Get Running Build Number OCP   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    Return From Keyword If  "${with_prefix}"=="${False}"   ${build_number}

    ${build_prefix}   Get Package Prefix From Global Variables File   build_number=${build_number}
    Run Keyword If   "${print_or_not}"=="${True}"  Log To Console  VDU Full Build Name:${build_prefix}_${build_number}
    RETURN  ${build_prefix}_${build_number}

_Get Running Build Number OCP
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   _Get Running Build Number OCP
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change:
    ...  3.8.2022, chris.l.cao@nokia-sbell.com, add gnb_index parameter
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu running build number, e.g, 0.390.928
    ...
    ...    Example
    ...    |  ${build_number}  | _Get Running Build Number OCP |
    ...

    ${random_number}    Evaluate    random.randint(1, 99)    modules=random
    ${random_number2}    Evaluate    random.randint(1, 99)    modules=random
    ${alias}  Set Variable    alias_${random_number}${random_number2}

    Connect To K8s Master With Tenant Interactively    vdu_index=${vdu_index}   alias=${alias}
    ${ns}   get vdu namespace from testline    gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${out}  fhgw_cli.Execute   command=helm list -a -n ${ns}|grep aic-vdu-|grep -v aic-vdu-prerequisite|grep -v aic-vdu-cluster|awk '{print $9}'
    ...    alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${build_number}  set variable  ${out.split("-")[-1]}
    RETURN  ${build_number}

Connect To K8s Master With Tenant Interactively
    [Arguments]   ${vdu_index}=0  ${alias}=default
    [Documentation]    Connect To K8s Master With Tenant Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   15.10.2020,chris.l.cao@nokia-sbell.com, initialization version
    ...   31.5.2021,chris.l.cao@nokia-sbell.com, support NCS
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index  |  no | VDU index, default is 0 |
    ...    | gnb_index  |  no | gnb index, default is 0 |
    ...    | alias      | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Connect To K8s Master With Tenant Interactively |
    ...    | ${out}      | fhgw_cli.Execute | command=kubectl get pod -o wide |
    ...    | disconnect interactive connection    |
    ...
    ${ip}    Set Variable   ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ${username}  Set Variable  ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ${password}  Set Variable  ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}

    ${prompt}  set variable    \\[cranuser\\d+@\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$

    fhgw_cli.Connect_To   ip=${ip}    username=${username}   password=${password}
       ...   prompt=${prompt}
       ...   alias=${alias}   width=200

Get Package Prefix From Global Variables File
    [Arguments]    ${build_number}
    [Documentation]  Get Package Prefix From Global Variables File
    ...    author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | build_number | Yes | build_number. eg: 0.300.001 or 14.300.001|
    ...
    ...    *RETURN VALUE*
    ...    package_prefix
    ...
    ...    Example
    ...    | ${package_prefix} | Get Package Prefix From Global Variables File | ${build_number} |

    ${SW_version_list1}    split string  ${build_number}    .
    ${trunk_or_branch}    Set Variable    ${SW_version_list1}[:2]
    ${trunk_or_branch}    Evaluate    '.'.join(${trunk_or_branch})
    ${package_prefix}    Set Variable   ${PACKAGE_PRE_MAPPING}[${trunk_or_branch}]
    RETURN    ${package_prefix}

Get Alias for vDU
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0   ${alias}=default
    [Documentation]  Get Alias for vDU
    ...    author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    1.7.2023, chris.l.cao@nokia-sbell.com, support multip VDU operation
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    |  vdu_index  | No |  gnb index to indicate which vdu will be used  |
    ...    |  alias | No. | alias that identifies this connection |

	...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...
    ...    Example
    ...    | ${alias} | Get Alias from vCU   |  gnb_index=0   |
    ...
    Return From Keyword If   "${alias}"!="default"      ${alias}
    ${alias}   Set Variable If   ${gnb_index}==0 and ${vdu_index}==0   default   vdu_connection_${gnb_index}_${vdu_index}
    RETURN    ${alias}

_Reset VDU Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}   ${conn}=default
    ${out}   vdu.get_reset_vdu_operation_status   operation_id=${operation_id}   vdu_connection=${conn}
    Should Be True  "${out["status"]}"=="${expected_status}"
    RETURN  ${out}

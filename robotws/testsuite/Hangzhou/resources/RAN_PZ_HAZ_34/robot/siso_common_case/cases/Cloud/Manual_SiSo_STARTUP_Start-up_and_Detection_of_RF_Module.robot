*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot

*** Keywords ***
Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this case is to verify if RF Module detection procedure is successful after
    ...                     connecting to System Module and works as specified in documentation.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. RU power off/on 2 times and check RU status.
    ...        2. Check RU config.
    ...        3. Get RU ip and check pingable.

    ...    - [EXPECTED RESULTS] .
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | loop_times | No | The loop times. Default value is 2. |
    ...    | vdu_index | No | The vdu index. Default value is 0. |
    ...    | gnb_index | No | The gnb index. Default value is 0. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 26.06.2024 - - Created
    ...    *******************
    ...    * Owner: yajie.li@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T01
    ...    *******************
    [Arguments]    ${loop_times}=2     ${vdu_index}=0    ${gnb_index}=0
    ${ru_index_list}  Get Rmod List
    ${ru_number}    Get Length    ${ru_index_list}
     FOR  ${i}  IN RANGE  ${loop_times}
          Cloud Perform RU Power Off And On    ru_number=${ru_number}
          Wait Until Keyword Succeeds    10min    1min
          ...    Verify All RU Status Should Be Normal on vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
     END
     FOR  ${ru_index}   IN RANGE  ${ru_number}
        ${output1}    Cloud Get RU SOAP info From RU    ru_index=${ru_index}
        ${output2}    Cloud Get RU SOAP Info From Webui    ru_index=${ru_index}
        Lists Should Be Equal    ${output1}    ${output2}
     END
     Cloud Get RU IP AND Check Pingable    ru_index=${ru_number}



Cloud Perform RU Power Off And On
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this case is to perform power off and power on RU.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Perform RU power off.
    ...        2. Perform RU power on.

    ...    - [EXPECTED RESULTS] .
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_number | Yes | The ru number. |
    ...    | ru_index | No | The ru index. Default value is ${1}. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 26.06.2024 - - Created
    ...    *******************
    ...    * Owner: yajie.li@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T01
    ...    *******************
    [Arguments]    ${ru_number}    ${ru_index}=${1}
    FOR  ${ru_index}   IN RANGE  ${ru_number}
        Cloud Perform RU Power Off    ru_index=${ru_index}
        sleep   60s
        Cloud Perform RU Power On    ru_index=${ru_index}
        sleep   30s
    END


Cloud Get RU IP AND Check Pingable
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this case is to get RU IP and check Pingable.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Get RU IP.
    ...        2. Connect To VDU OAM container and check Pingable.

    ...    - [EXPECTED RESULTS] .
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_index | No | The ru index. Default value is ${1}. |
    ...    | vdu_index | No | The vdu index. Default value is 0. |
    ...    | gnb_index | No | The gnb index. Default value is 0. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 26.06.2024 - - Created
    ...    *******************
    ...    * Owner: yajie.li@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T01
    ...    *******************
    [Arguments]    ${ru_index}=${1}    ${vdu_index}=0    ${gnb_index}=0
    FOR  ${ru_index}   IN RANGE  ${ru_index}
       log to console    "get ru ip and ping"
       ${IP}    Cloud Get RU IP    ru_index=${ru_index}    gnb_index=${gnb_index}     vdu_index=${vdu_index}
       Cloud VDU Connect To OAM Container AND Check Pingable    IP=${IP}
    END


Cloud VDU Connect To OAM Container AND Check Pingable
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this case is to connect To VDU OAM container and check Pingable.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Connect To VDU OAM container.
    ...        2. Check Pingable.

    ...    - [EXPECTED RESULTS] .
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | IP | YES | The ru IP. |
    ...    | vdu_index | No | The vdu index. Default value is 0. |
    ...    | gnb_index | No | The gnb index. Default value is 0. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 26.06.2024 - - Created
    ...    *******************
    ...    * Owner: yajie.li@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T01
    ...    *******************
    [Arguments]    ${IP}    ${vdu_index}=0    ${gnb_index}=0
     ${alias}   Run Keyword And Continue On Failure    Wait Until Keyword Succeeds   3x  10     VDU Connect To Container
     ...    pod_name=oamfh-0    container_name=oamfh
     ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}

     ${cmd}    Run keyword If    ${is_dc}==0    set variable    ping -c 30 -W 10 ${IP}
    ...    ELSE    set variable    ping -I 70.70.70.1 -c 30 -W 10 ${IP}

     ${output}    Run Keyword And Continue On Failure    Cloud SSH Execute CMD   command=${cmd}
     ...    expert_prompt=bash-5.2$    alias=${alias}
    Should contain    ${output}    30 packets transmitted, 30 received
    [Teardown]    Cloud Disconnect Alais    alias=${alias}


Cloud Get RU SOAP Info From Webui
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this case is to get RU SOAP info from webui.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Get rmod status and get RU product_code/serial_number/sw_version info.

    ...    - [EXPECTED RESULTS] .
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_index | NO | The ru index. Default value is ${1}. |
    ...    | vdu_index | No | The vdu index. Default value is 0. |
    ...    | gnb_index | No | The gnb index. Default value is 0. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 26.06.2024 - - Created
    ...    *******************
    ...    * Owner: yajie.li@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T01
    ...    *******************
    [Arguments]    ${ru_index}=${1}    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${info}    vdu_ope_base.Get Rmod Status    conn_alias=${conn_alias}
    ${product_code_webui}    set variable    ${info[${ru_index}-1]['product_code']}
    ${serial_number_webui}    set variable    ${info[${ru_index}-1]['serial_number']}
    ${SW_version_webui}    set variable    ${info[${ru_index}-1]['active_sw_version']}
    [Return]    ${product_code_webui}    ${serial_number_webui}    ${SW_version_webui}
    [Teardown]  vdu_gen.logout_rest    conn_alias=${conn_alias}


Cloud Get RU SOAP info From RU
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this case is to Get RU SOAP info from RU.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Connect to RU and get SOAP info from RU.

    ...    - [EXPECTED RESULTS] .
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_index | NO | The ru index. Default value is ${1}. |
    ...    | vdu_index | No | The vdu index. Default value is 0. |
    ...    | gnb_index | No | The gnb index. Default value is 0. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 26.06.2024 - - Created
    ...    *******************
    ...    * Owner: yajie.li@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T01
    ...    *******************
    [Arguments]    ${ru_index}=${1}    ${vdu_index}=0    ${gnb_index}=0
    ${alias}    Cloud Connect to RU    ru_index=${ru_index}
    ${connection}    Get Library Instance    ssh_conn
    ${output}    Call Method    ${connection.ssh_conn}
    ...    execute    cat /ram/UnitOAM_SOAP_Startup_Autodetection_Log/UnitOAM_SOAP_Startup_Autodetection_Log*.xml | grep productCode
    ...    check_result=${False}    alias=${alias}

    ${productCode_catSOAP}    Fetch From Left     ${output}   </productCode>
    ${productCode_catSOAP}    Fetch From Right    ${productCode_catSOAP}   <productCode>

    ${bldVersion_catSOAP}    Fetch From Left     ${output}   </bldVersion>
    ${bldVersion_catSOAP}    Fetch From Right    ${bldVersion_catSOAP}   <bldVersion>

    ${serialNum_catSOAP}    Fetch From Left     ${output}   </serialNum>
    ${serialNum_catSOAP}    Fetch From Right    ${serialNum_catSOAP}   <serialNum>

    [Return]    ${productCode_catSOAP}    ${serialNum_catSOAP}    ${bldVersion_catSOAP}
    [Teardown]    run keyword and ignore error    Cloud Disconnect Alais    alias=${alias}

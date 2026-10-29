*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Samik Sarkar
...              :contact: samik.sarkar@nokia.com
*** Keywords ***
Get And Check Scell Infos
    [Arguments]    ${scells_info}
    #${content}    OperatingSystem.Get File    path=${egate_file}
    ${content}    OperatingSystem.Get File    path=/home/ute/wts/CA_RRC.txt
    ${regexp}    Catenate    SEPARATOR=    sCellIndex\\s+(?P<sCellIndex>\\d+),[\\s\\S]*?physCellId\\s(?P<physCellId>\\d+),
    ...    [\\s\\S]*?frequencyBandList\\n\\s+\\{\\n\\s+(?P<frequencyBandList>\\d+)\\n\\s+\\},
    ${ret}    String.Get Regexp Matches    ${content}    ${regexp}    sCellIndex    physCellId    frequencyBandList
    BuiltIn.Log    ${ret}
    ${new_ret}=    Convert To String    ${ret}
    BuiltIn.Log    ${new_ret}
    Should Contain    ${new_ret}    ${scells_info}

Verfiy Scells Are Activation
    [Arguments]    ${cell_nums}
    Log To Console    verify Scell Info...
    FOR    ${id}    IN RANGE    1    ${cell_nums}
        ${scell_activation}    Set Variable    SCellIndex ${id} activated successfully.
    #\    ${check_rst}    Run    cat /home/ute/wts/egate_console.log.001|grep -i "${scell_activation}"|wc -l
        ${check_rst}    Run    cat /home/ute/wts_4.0.17644/egate_console.log.*|grep -i "${scell_activation}"|wc -l
        Should Be True    ${check_rst}==1
	END

Scell Release Triggered By A2 Event
    [Arguments]    ${ue_id}=1    ${meas_id}=2    ${scell_rsrp}=60    ${scell_rsrq}=20
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=9 scell_rsrp=${scell_rsrp} scell_rsrq=${scell_rsrq}
    ...    value SgNBModificationConfirm    timeout=20s
    Should Contain    ${ret1}    value SgNBModificationRequired
    Should Contain    ${ret1}    value Cause : radioNetwork : rRM-purpose
    Should Contain    ${ret1}    value SgNBModificationConfirm

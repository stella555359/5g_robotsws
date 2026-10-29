*** Settings ***
Documentation
...   author: cheng xianbiao
...   contact: xianbiao.cheng@nokia-sbell.com

Resource          taf/rfrl/cbts/robot/vdu/vdu_operations.robot

*** Keywords ***
vDU Verify All Cells Status Should Be Onair
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0
    [Documentation]  vDU Verify All Cells Status Should Be Onair
    ...             the keyword only support rest api v2.
    ...             the checked status are operational_state--disabled
    ...                                 administrative_state--locked
    ...                                 administrative_state--shutting_down
    ...   *Author*: calla.wang@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2020-11-26 | chris.l.cao | add check for ${on_line}>=1 |
    ...   | 2021-7-6 | chris.l.cao | exactly check all cells are on-air |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | vdu_index | Yes | specify which vdu needs to be check if the testline configed multi vdus |
    ...   *Return*
    ...   None
    ...   *Example*
    ...   |  vDU Verify All Cells Status Should Be Onair  |
    ...   |  vDU Verify All Cells Status Should Be Onair  | gnb_index=0 |
    ...   |  vDU Verify All Cells Status Should Be Onair  | gnb_index=0 |  vdu_index=0 |
    #${cell_number}   Get VCU Cell Number From TestLine    gnb_index=${gnb_index}
    ${cell_number}   Get VDU Cell Number From SCF

    vDU Verify Cells Status Should Be Onair With Expected Cell Number    gnb_index=${gnb_index}    vdu_index=${vdu_index}
     ...   expected_cell_number=${cell_number}

vDU Verify Cells Status Should Be Onair With Expected Cell Number
    [Arguments]  ${vdu_index}=0     ${gnb_index}=0   ${expected_cell_number}=1   ${expected_disabled}=0   ${expected_locked}=0
    [Documentation]    vDU Verify Cells Status Should Be Onair With Expected Cell Number
    ...    the keyword only support rest api v2.
    ...    the checked status are operational_state--disabled
    ...                           administrative_state--locked
    ...                           administrative_state--shutting_down
    ...    history change: <date>,<who>,<what and how>
    ...    Initialized by calla.wang@nokia-sbell.com,add support container.
    ...    26.11.2020, chris.l.cao@nokia-sbell.com,add check for ${on_line}>=1
    ...    7.6.2021, chris.l.cao@nokia-sbell.com,add parameter expected_cell_number
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...    | gnb_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...    | expected_cell_number | No. | expected_cell_number |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | vDU Verify Cells Status Should Be Onair With Expected Cell Number  |
    ...
    ${alias}=  get unique id
    aic_common_resources_new.Rest Login on vDU   vdu_index=${vdu_index}   gnb_index=${gnb_index}  alias=${alias}
    ${vdu_cells_summary}=  vdu.get_vdu_cells_summary  vdu_connection=${alias}
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}  ${expected_disabled}
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['administrative_state']['locked']}  ${expected_locked}
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}  0
    ${on_line}   set variable   ${vdu_cells_summary['availability_status']['on_line']}
    should be true  ${on_line}==${expected_cell_number}
    #should be true  ${on_line}>=1

    [Teardown]  vdu.disconnect   ${alias}

Get VDU Cell Number From SCF
    [Documentation]  Get VDU Cell Number From SCF
    ...   *Author*: chris.l.cao@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   | 2022-11-10 | r3li | fix error that call keyword after reinstall |
    ...   | 2023-7-5 | r3li | correct error for CU Rest Login changed |
    ...   | 2023-7-24 | chris.l.cao | change from "multiple_folder/scf.xml" to "one_folder/multiple_scf_.xml files
    ...   | 2023-12-15 | chris.l.cao | change to use 'vDU Get Cell List From Webem'
    ...
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | vdu_index | No | vdu index in init.py file, default is 0 |
    ...   | gnb_index | No | gnb index to indicate which gnb will be used, default is 0 |
    ...
    ...   *Return*
    ...   Cell number from test line configuration
    ...
    ...   *Example*
    ...   | ${cell_number} | Get VDU Cell Number From SCF |
    ...
#    ${cell_list}  vdu_operations.vDU Get Cell List From Webem  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${alias}    common_vdu.vDU Rest Login
    ${cell_id}         vdu.Get Vdu Cell Id
    ${cell_list}    Create List
    FOR    ${item}    IN    @{cell_id}
        ${keys}=    Get Dictionary Keys    ${item}
        ${key}=    Get From List    ${keys}    0
        Append To List    ${cell_list}    ${key}
    END

    [Return]   ${cell_list.__len__()}

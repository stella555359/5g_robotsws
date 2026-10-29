*** Settings ***
Documentation  Support handover in IPHY tests
...  Maintainer: slawomir.jastrzebski@nokia.com

Library     XML     use_LXML=true
Library     BuiltIn
Library     OperatingSystem
Library     Process
Library     ute_tshark
Library    taf.sw.wtssim    WITH NAME    wtssim

#Resource    ./throughput.robot
#Resource    ./egate.robot
#Resource    ./tshark.robot
#Resource    ../../../../../../../resources/WMP/GVe/Wroclaw/bts_scfc.robot

*** Variables ***
${tshark_ho_dir}=   intraHO
${tshark_alias}=    intraHO

*** Keywords ***
HO Execute Handover Loops
    [Arguments]    ${loops}    ${scfc_file_path}
    [Documentation]  Keyword perform desired number of handover loops from every to all cells
    ...    Maintainer: slawomir.jastrzebski@nokia.com
    Log   \nHandover loop: ${loops}    console=yes
    ${out_lcr_id_not_iot_list}=    SCFC Create Not IoT LcrId List    ${scfc_file_path}
    ${out_lcr_id_not_iot_list}=    Convert List To Integer    ${out_lcr_id_not_iot_list}
    Sort List    ${out_lcr_id_not_iot_list}
    ${out_lcr_id_not_iot_list}=    Convert List To String    ${out_lcr_id_not_iot_list}
    ${out_lcr_id_iot_sa_list}=    SCFC Create IoT Standalone LcrId List    ${scfc_file_path}
    ${out_lcr_id_iot_sa_list}=    Convert List To Integer    ${out_lcr_id_iot_sa_list}
    Sort List    ${out_lcr_id_iot_sa_list}
    ${out_lcr_id_iot_sa_list}=    Convert List To String    ${out_lcr_id_iot_sa_list}
    ${out_lcr_id_iot_sa_count}=    Get Length    ${out_lcr_id_iot_sa_list}
    ${out_ue_id_begin}=    Set Variable    1
    ${out_ue_id_end}=    Set Variable    ${UE_COUNT}
    ${out_bearer_id}=    Set Variable    1
    ${out_ue_iot_id_begin}=    Evaluate    ${UE_COUNT}+1
    ${out_ue_iot_id_end}=    Evaluate    ${UE_IoT_COUNT}+${UE_COUNT}
    ${out_iot_bearer_id}=    Set Variable    2
    ${loops}=    Evaluate    ${loops}+1
    FOR  ${index}  IN RANGE  1  ${loops}
      HO From Every To All Cells    ${out_lcr_id_not_iot_list}    ${scfc_file_path}    Loop:${index}
       ...    ${DL_HO_TPUT_RATE}    ${UL_HO_TPUT_RATE}    ${out_ue_id_begin}    ${out_ue_id_end}    ${out_bearer_id}
      Run Keyword If    ${out_lcr_id_iot_sa_count}>1  HO From Every To All Cells    ${out_lcr_id_iot_sa_list}
       ...    ${scfc_file_path}    Loop:${index}    ${DL_IOT_HO_TPUT_RATE}    ${UL_IOT_HO_TPUT_RATE}
       ...    ${out_ue_iot_id_begin}    ${out_ue_iot_id_end}    ${out_iot_bearer_id}
    END

HO From Every To All Cells
    [Arguments]    ${lcr_id_list}    ${scfc_file_path}    ${run}    ${dl_transfer}    ${ul_transfer}
    ...    ${ue_id_begin}    ${ue_id_end}    ${bearer_id}
    [Documentation]  Keyword performs one serier of handover from every to every cell
    ...    Maintainer: slawomir.jastrzebski@nokia.com
    ${cell_subcell_dict}=  SCFC Create Dictionary With Cell And Subcell  ${scfc_file_path}
    ${cell_subcell_dict_egate}  ${cell_subcell_dict}=  Change Dictionary Cells For Egate Purposes  ${cell_subcell_dict}
    FOR  ${source_cell}  IN  @{lcr_id_list}
      HO From Source To All Cells  ${source_cell}  ${lcr_id_list}  ${scfc_file_path}
      ...    ${run}_From:${cell_subcell_dict_egate['${source_cell}'][0]}
      ...    ${dl_transfer}  ${ul_transfer}  ${ue_id_begin}  ${ue_id_end}  ${bearer_id}
    END

HO From Source To All Cells
    [Arguments]    ${source_cell}    ${lcr_id_list}    ${scfc_file_path}    ${run}    ${dl_transfer}    ${ul_transfer}
    ...    ${ue_id_begin}    ${ue_id_end}    ${bearer_id}
    [Documentation]    Keyword performs handover from source to all cells
    ...    Maintainer: slawomir.jastrzebski@nokia.com
    FOR  ${destination_cell}  IN  @{lcr_id_list}
      ${cell_subcell_dict}=   SCFC Create Dictionary With Cell And Subcell    ${scfc_file_path}
      ${cell_subcell_dict_egate}    ${cell_subcell_dict}=    Change Dictionary Cells For Egate Purposes
      ...    ${cell_subcell_dict}
      ${status}=    Run Keyword And Return Status    Should Not Be Equal    ${source_cell}    ${destination_cell}
      Run Keyword If  ${status}  HO Single Handover From Source To Destination Cell
      ...    ${source_cell}    ${destination_cell}    ${scfc_file_path}
      ...    ${run}_To:${cell_subcell_dict_egate['${destination_cell}'][0]}
      ...    ${dl_transfer}    ${ul_transfer}    ${ue_id_begin}    ${ue_id_end}    ${bearer_id}
    END

HO Single Handover From Source To Destination Cell
     [Arguments]    ${source_cell}    ${destination_cell}    ${scfc_file_path}    ${run}    ${dl_transfer}
     ...    ${ul_transfer}    ${ue_id_begin}    ${ue_id_end}    ${bearer_id}
     ...    ${packet_loss}=${ACCEPTABLE_PACKET_LOSS}    ${time}=${THROUGHPUT_MEASUREMENT_TIME}
     [Documentation]  Keyword executes handover using egate command from ${source_cell} to ${destination_cell} when
     ...    data transfer is ongoing with specified values  ${dl_transfer}  ${ul_transfer}
     ...    Maintainer: slawomir.jastrzebski@nokia.com
     ${out_phy_cell_id_under_test}=    SCFC Get PhyCellId For LcrId    ${scfc_file_path}    ${destination_cell}
     ${source_lncel_id}=    SCFC Get LncelId For LcrId    ${scfc_file_path}    ${source_cell}
     ${cell_subcell_dict}=    SCFC Create Dictionary With Cell And Subcell         ${scfc_file_path}
     ${cell_subcell_dict_egate}  ${cell_subcell_dict}=  Change Dictionary Cells For Egate Purposes  ${cell_subcell_dict}
     ${sting_source_cell}=    Convert To String    ${source_cell}
     ${source_subcell_list}=    Get From Dictionary    ${cell_subcell_dict}    ${sting_source_cell}
     ${source_subcell_count}=    Get Length    ${source_subcell_list}
     ${source_random_subcell}=    Evaluate	   random.randint(0, ${source_subcell_count-1})    modules=random
     ${sting_destination_cell}=    Convert To String    ${destination_cell}
     ${destination_subcell_list}=    Get From Dictionary    ${cell_subcell_dict}    ${sting_destination_cell}
     ${destination_subcell_count}=    Get Length    ${destination_subcell_list}
     ${destination_random_subcell}=    Evaluate    random.randint(0, ${destination_subcell_count-1})    modules=random
     ${out_time_before_ho}=    Evaluate    ${time}/2
     ${out_time_after_ho}=    Evaluate    (${time}/2)-3
     Egate Change UE Location To    ${cell_subcell_dict_egate['${source_cell}'][${source_random_subcell}]}
     ...    ${ue_id_begin}    ${ue_id_end}
     Egate Perform Attach    ${run}    ${ue_id_begin}    ${ue_id_end}
     Egate Verify If UE Is In Cell    ${cell_subcell_dict_egate['${source_cell}'][${source_random_subcell}]}
     Log    \nattach to egate cell ${cell_subcell_dict_egate['${source_cell}'][${source_random_subcell}]} succeed
     ...    console=yes
     Tshark Start Capturing On Interface    eth4    alias=${tshark_alias}_${run}    capture_filter=less 1000
     ${destination_cell_int}=    Convert to Integer    ${destination_cell}
     ${out_throughput_parameters}    ${out_bps_throughput}=    SCFC Get Throughput Parameters For Cell
     ...    ${scfc_file_path}    ${source_lncel_id}
     ${ue_params_id}=  Set Variable  data_start ue\=${ue_id_begin}-${ue_id_end} id\=${bearer_id}
     ${ue_params_ul_troughput}=  Set Variable  dir\=ul ${out_bps_throughput}\=${ul_transfer} seconds\=${time}
     ${ue_params_dl_troughput}=  Set Variable  dir\=dl ${out_bps_throughput}\=${dl_transfer} seconds\=${time}
     wtssim.Execute Egate Command    ${ue_params_id} ${ue_params_ul_troughput}
     wtssim.Execute Egate Command    ${ue_params_id} ${ue_params_dl_troughput}
     TTI Trace Gather and Execute Sicftp    ${run}
     Sleep    ${out_time_before_ho}
     Log    Handover from egate cell ${cell_subcell_dict_egate['${source_cell}'][${source_random_subcell}]}
     ...    to ${cell_subcell_dict_egate['${destination_cell}'][${destination_random_subcell}]} is executed
     ...    console=yes
     Egate Execute Handover To Cell    ${cell_subcell_dict_egate['${destination_cell}'][${destination_random_subcell}]}
     Sleep    ${out_time_after_ho}
     FOR  ${ue_id}  IN RANGE  ${ue_id_begin}    ${ue_id_end}+1
       Verify If Throughput Is Correct For Direction    ul    ${ul_transfer}    ${out_bps_throughput}    ${ue_id}
        ...    ${bearer_id}    packet_loss=${packet_loss}    time=${time}
       Verify If Throughput Is Correct For Direction    dl    ${dl_transfer}    ${out_bps_throughput}    ${ue_id}
        ...    ${bearer_id}    packet_loss=${packet_loss}    time=${time}
     END
     Tshark Stop Capturing    ${tshark_alias}_${run}
     Egate Verify If UE Is In Cell  ${cell_subcell_dict_egate['${destination_cell}'][${destination_random_subcell}]}
     Tshark Verify Handover To Cell  ${out_phy_cell_id_under_test}  alias=${tshark_alias}_${run}
     [Teardown]    Run Keyword And Ignore Error  HO Teardown Single Handover  ${run}  ${ue_id_begin}  ${ue_id_end}

HO Teardown Single Handover
     [Arguments]  ${run}    ${ue_id_begin}    ${ue_id_end}
     [Documentation]    Keywords saves tshark files and performs detach procedure.
     ...    Maintainer: slawomir.jastrzebski@nokia.com
     Create Directory    ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/${tshark_ho_dir}
     Run Keyword And Ignore Error    Move File    ${SUITE_LOGS_DIR_PATH}/${tshark_alias}*
     ...    ${SUITE_LOGS_DIR_PATH}/${TEST_NAME}/${tshark_ho_dir}
     Tshark Teardown    ${tshark_alias}_${run}
     Teardown All Aliases For Tshark
     Egate Perform Detach    ${run}    ${ue_id_begin}    ${ue_id_end}


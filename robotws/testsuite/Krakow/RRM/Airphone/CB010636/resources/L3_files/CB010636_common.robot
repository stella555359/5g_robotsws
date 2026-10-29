*** Settings ***
Documentation
...            author:        Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com,
...                           Mateusz Michalik, mateusz.michalik@nokia.com,
...                           Jakub Rutyna, jakub.rutyna@nokia.com,
...                           Paulina Karpf Matoga, paulina.karpf_matoga@nokia.com
...            maintainer:    Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...                           Mateusz Michalik, mateusz.michalik@nokia.com,
...                           Jakub Rutyna, jakub.rutyna@nokia.com,
...                           Paulina Karpf Matoga, paulina.karpf_matoga@nokia.com

Library     taf.ccs.aashell   WITH NAME    cli
Library     CB010636_resources_new.py
Library     CB010636_CC_counters.py
Resource    testsuite/Krakow/resources/former_l3_sw2/configurators.robot
Resource    testsuite/Krakow/resources/former_l3_sw2/remote.robot
Resource    testsuite/Krakow/resources/former_l3_sw2/procedures.robot
Resource    testsuite/Krakow/resources/former_l3_sw2/wts.robot

*** Variables ***
&{RAD_HEXs}    L2TraceL2LoTxBitmap=0x57000B
...            rdDebugDlRlcPduBurstsCounters=0x5B0613
...            rdDebugDlPdcpPduBurstsCounters=0x5A0619
...            rdEnableDebugLogForBurst=0x570030
...            rdDebugBurstCounters=0x5b0608

*** Keywords ***
Get CSV Data for CC RLC counters from MacPduMuxReq
    [Documentation]    Returns a dictionary with items following this naming pattern:
    ...                For RLC Layer counters:
    ...                   dl_uex_ccx_mergedBytes
    ...                   dl_uex_ccx_mergedduration
    ...                   dl_uex_rlc_mergedBytes
    ...                   dl_uex_rlc_mergedduration
    ...                for every UE and Cell.
    [Arguments]    ${csv_file_path}    ${ue_info}    ${cell_info}     ${threshold_vol}=0     ${threshold_time}=0
    Log to Console    Calculating amountBytes and burst duration per UE per Cell from CSV: ${csv_file_path}
    ${csv_pcis}    Get Unique Column Values from CSV    csv_file_path=${csv_file_path}    col_nr=9
    ${csv_rntis}    Get Unique Column Values from CSV    csv_file_path=${csv_file_path}    col_nr=14
    ${diff_pcis}    Evaluate    set([cell['pci'] for cell in ${cell_info}]) - set(${csv_pcis})
    ${diff_rntis}    Evaluate    set([ue['rnti'] for ue in ${ue_info}]) - set(${csv_rntis})
    Should Be Empty    ${diff_pcis}    msg=Missing cell PCI ${diff_pcis} in CSV file: ${csv_file_path}
    Should Be Empty    ${diff_rntis}    msg=Missing UE RNTI ${diff_rntis} in CSV file: ${csv_file_path}
    ${ue_data}    Create Dictionary
    FOR    ${ue}    IN    @{ue_info}
      ${ue_id}=    Get From Dictionary    ${ue}    id
      ${ue_rnti}=    Get From Dictionary    ${ue}    rnti
      Add Amount Bytes And Time per CC For UE on All Cells To Dict
      ...    csv_file_path=${csv_file_path}    ue_id=${ue_id}   rnti=${ue_rnti}    cell_info=${cell_info}
      ...    data_dict=${ue_data}    threshold_vol=${threshold_vol}    threshold_time=${threshold_time}
    END
    [Return]    ${ue_data}

Add Amount Bytes And Time per CC For UE on All Cells To Dict
    [Arguments]    ${csv_file_path}    ${ue_id}    ${rnti}    ${cell_info}    ${data_dict}     ${threshold_vol}     ${threshold_time}
     ${merged_burst_volume}    ${merged_burst_duration}    ${cc_burst}    Get Burst Amount and Time per CC from All Cells for UE
     ...    csv_file_path=${csv_file_path}    rnti=${rnti}    cell_info=${cell_info}
     ...    threshold_vol=${threshold_vol}    threshold_time=${threshold_time}
     Set To Dictionary    ${data_dict}    dl_ue${ue_id}_rlc_mergedBytes    ${merged_burst_volume}
     Set To Dictionary    ${data_dict}    dl_ue${ue_id}_rlc_mergedduration    ${merged_burst_duration}
     FOR    ${key}    IN    @{cc_burst}
         ${cc_volume}=      Get From Dictionary    ${cc_burst}[${key}]   volume
         ${cc_duration}=    Get From Dictionary    ${cc_burst}[${key}]   duration
         Set To Dictionary    ${data_dict}    dl_ue${ue_id}_cc${key}_mergedBytes    ${cc_volume}
         Set To Dictionary    ${data_dict}    dl_ue${ue_id}_cc${key}_mergedduration    ${cc_duration}
     END

Get Unique Column Values from CSV
    [Arguments]    ${csv_file_path}    ${col_nr}
    ${result}    Run Process And Expect Success    sed    '1d'    ${csv_file_path}
    ...    |    cut    -d','     -f${col_nr}
    ...    |    sort    |    uniq
    ${values}    Split To Lines    ${result.stdout}
    [Return]    ${values}

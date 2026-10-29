*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***
# ${nrcell_r}   /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-849/NRCELL_R-1
${beam_pattern_id}   1
@{beam_pattern_id_list}   1

*** Keyword ***
Test_Mode_is_enabled_successfully_on_webem
    ${nrcell}   COAM Get Managed Objects   class_name=NRCELL_R
    Set Suite Variable   ${nrcell_r}   ${nrcell[0]['distName']}

    ${cell_info}   COAM Get Cell Info   cell_id=${nrcell_r}
    ${dist_name}   Set Variable   ${cell_info['id']['configuration']}
    ${nrarfcn}   Set Variable   ${cell_info['nrarfcn']}
    ${pMax}   COAM Get Parameter Value   dist_name=${dist_name}   parameter=pMax

    ${int_status}   Run Keyword And Return Status
    ...   COAM Start 5G Downlink Test
    ...   dist_name=${nrcell_r}
    ...   beam_pattern_id=${beam_pattern_id}
    ...   p_max=${${pMax}/10.0}
    ...   nrarfcn_dl=${nrarfcn}
    ${list_status}   Run Keyword And Return Status   run keyword if  not ${int_status}   Run Keyword And Return Status
    ...   COAM Start 5G Downlink Test
    ...   dist_name=${nrcell_r}
    ...   beam_pattern_id=${beam_pattern_id_list}
    ...   p_max=${${pMax}/10.0}
    ...   nrarfcn_dl=${nrarfcn}
    run keyword if  not ${int_status} or ${list_status}   Fail   Start 5G Downlink Test Failed!

Case Setup 5752-H
    Common Setup
    COAM Reset to Test Dedicated State
    Sleep   5m

Case Teardown 5752-H
    Run Keyword And Ignore Error   COAM Stop 5G Downlink Test   dist_name=${nrcell_r}
    Run Keyword And Ignore Error   COAM Reset Site
    Common Teardown

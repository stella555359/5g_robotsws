*** Settings ***
Documentation
...   feature keywords

Library       ute_admin_infomodel
Library       ute_admin

Library    ute_ue

Library       SSHLibrary
Library       ../../../resources/rrm_fixture.py
Library       ../../../resources/webui/interface.py
Library      ./pcap_verifiers.py
Library       ta5g_cell_operations
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/l1l2_collector.py
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py
Variables    ./variables_2640.py

*** Variables ***
${PCELL_ID}          100
${CA_UE}=     UE_1
${NON_CA_UE}=     UE_2
@{BIP_CA_MESSAGES_FILTER}    0xE118    0xE126    0xE128    0xE251

*** Keywords ***
Set Initial Attenuation For Test
    Initialise Attenuator
    Log To Console    ${ATTENUATOR}
    Set Attenuation  ${ATTENUATOR['NRCELL_100']['attenuation']}  ${ATTENUATOR['NRCELL_100']['ports']}
    ...  confirm=${TRUE}
    Set Attenuation  ${ATTENUATOR['NRCELL_101']['attenuation']}  ${ATTENUATOR['NRCELL_101']['ports']}
    ...  confirm=${TRUE}
    Set Attenuation  ${ATTENUATOR['NRCELL_103']['attenuation']}  ${ATTENUATOR['NRCELL_103']['ports']}
    ...  confirm=${TRUE}
    Set Attenuation  ${ATTENUATOR['NRCELL_104']['attenuation']}  ${ATTENUATOR['NRCELL_104']['ports']}
    ...  confirm=${TRUE}
    Set Attenuation  ${ATTENUATOR['NRCELL_105']['attenuation']}  ${ATTENUATOR['NRCELL_105']['ports']}
    ...  confirm=${TRUE}
    Set Attenuation  ${ATTENUATOR['NRCELL_106']['attenuation']}  ${ATTENUATOR['NRCELL_106']['ports']}
    ...  confirm=${TRUE}

Start Multiple Throughputs For Ca Ue
    [Arguments]    ${num}
    FOR    ${i}   IN RANGE    ${num}
        Log To Console    ${\n}${i}. Starting next tput: 120
        Start DL Traffic For Ue    ${CA_UE}    120Mbits/sec    duration=600s    dt=${i}    protocol=udp
        Run Keyword And Continue On Failure    Check Data Transfer Is Alive    DT_${CA_UE}_${i}
    END

Stop Multiple Throughputs For Ca Ue
    [Arguments]    ${num}
    FOR    ${i}   IN RANGE    ${num}
        Stop Data Transfer    DT_${CA_UE}_${i}
    END

Stop Single Data Transfer
    [Arguments]    ${id}
    Stop Data Transfer    DT_${CA_UE}_${id}

Activate 4CC
    Update Parameter    param=maxNumOfSCellAlloc    value=250
    ...    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-104

Deactivate 4CC
    Update Parameter    param=maxNumOfSCellAlloc    value=0
    ...    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-104

*** Settings ***
Documentation
...   author:  Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com

Library    testsuite/Wroclaw/RRM/resources/attenuator_keywords.py
Library    nrrele.py
Resource   testsuite/Wroclaw/RRM/resources/logs.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py



*** Keywords ***

Set Attenuation For ANR Cell With Id
    [Arguments]    ${cell_id}    ${attenuation}=90dB
    Initialise Attenuator
    Set Attenuation    ${attenuation}    port=${ATTENUATOR['NRCELL_${cell_id}']['ports']}    confirm=${TRUE}
    ...    attenuator_id=${ATTENUATOR['NRCELL_${cell_id}']['att_id']}

Decrease Attenuation For ANR Cell With Id
    [Arguments]    ${cell_id}    ${attenuation}=0dB
    Initialise Attenuator
    Set Attenuation    ${attenuation}    port=${ATTENUATOR['NRCELL_${cell_id}']['ports']}    confirm=${TRUE}
    ...    attenuator_id=${ATTENUATOR['NRCELL_${cell_id}']['att_id']}

Trigger A2 Attenuation For ANR Cell With Id
    [Arguments]    ${cell_id}    ${attenuation}=50dB
    Initialise Attenuator
    Set Attenuation    ${attenuation}    port=${ATTENUATOR['NRCELL_${cell_id}']['ports']}    confirm=${TRUE}
    ...    attenuator_id=${ATTENUATOR['NRCELL_${cell_id}']['att_id']}

Check ANR Nrrel
    [Arguments]    ${cell_id}
    ${x}=    Find Existing Nrrels Ids    ${cell_id}
    Should Not Be Empty    ${x}

Check ANR Nrrel Removal
    [Arguments]    ${cell_id}
    ${x}=    Find Existing Nrrels Ids    ${cell_id}
    Should Be Empty    ${x}

Set Max Number Of Users For ANR Cell
    [Arguments]    ${cell_id}    ${max_num}
    Update Parameter    param=maxNumOfUsersPerCell    value=${max_num}    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}

Restore Default Max Number Of Users For ANR Cell
    [Arguments]    ${cell_id}
    Update Parameter    param=maxNumOfUsersPerCell   value=275    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}

Reserve UE and Setup MTK Message
    Require Ue    UE_1    capabilities=REAL_MEDIATEK_UE
    mtk.Setup    pyro_ip=${tl.ues[0].ssh_connection_details.addr}    pyro_port=${tl.ues[0].server_port}
    mtk.Create Message Flow Alias    flow_alias=MTK_OTA_MESSAGE    message_type=ota_text

Perform ANR HO
    [Documentation]    Loop for ANR HO due to MTK70 limitation
    FOR    ${index}    IN RANGE    3
        Set Attenuation For ANR Cell With Id    3
        Clear Attenuation
        Set Attenuation For ANR Cell With Id    2
        Clear Attenuation
    END

Modify ANR Recheck parameters
    #Set Max Number Of Scell Alloc For Cell  2    0
    #Set Max Number Of Users For ANR Cell   2    0
    Set Max Number Of Scell Alloc For Cell  3    0
    Set Max Number Of Users For ANR Cell   3    0

Restore Default ANR Recheck parameters
    Restore Default Max Number Of Users For ANR Cell    2
    Restore Default Max Number Of Scell Alloc   2
    Restore Default Max Number Of Users For ANR Cell    3
    Restore Default Max Number Of Scell Alloc   3

ANR Teardown
    Clear Attenuation
    Restore Default ANR Recheck parameters
    Remove Nrrel    3    2

Check ANR Nrrele
    [Arguments]    ${cell_id}
    ${x}=    Find Existing Nrreles Ids    ${cell_id}
    Should Not Be Empty    ${x}

Check ANR Nrrele Removal
    [Arguments]    ${cell_id}
    ${x}=    Find Existing Nrreles Ids    ${cell_id}
    Should Be Empty    ${x}

Set tNgRelocOverall For ANR Cell
    [Arguments]    ${max_num}
    Update Parameter    param=tNgRelocOverall   value=${max_num}    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}

Set tNgRelocPrep For ANR Cell
    [Arguments]     ${max_num}
    Update Parameter    param=tNgRelocPrep   value=${max_num}    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}

Restore tNgRelocPrep For ANR Cell
    Update Parameter    param=tNgRelocPrep  value=5000    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}

Restore tNgRelocOverall For ANR Cell
    Update Parameter    param=tNgRelocOverall   value=5000    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}

Change Maxnumrrc
    change_maxNumRrc

8239 NRRELE Removal Trigger
    [Documentation]    Loop for ANR HO due to MTK70 limitation
    FOR    ${index}    IN RANGE    3
        Detach Ue   UE_2
        Attenuate All Cells
        Decrease Attenuation For ANR Cell With Id    3
        Attach Ue   UE_2    timeout=${10}
	    Trigger A2 Attenuation For ANR Cell With Id    3
        Decrease Attenuation For ANR Cell With Id    1
    END

8239 Teardown
    Clear Attenuation
    cell_notbarred
#    Restore tNgRelocPrep For ANR Cell
#    Restore tNgRelocOverall For ANR Cell
#    restore_maxNumRrc

Clear Attenuation On Ports
    FOR    ${index}    ${att}    IN ENUMERATE    @{tl.attenuators}
        Log To Console    Clearing attenuation on attenuator ${index+1}
        Set Attenuation  0dB  confirm=${TRUE}    attenuator_id=${index+1}
    END

Attenuate All Ports
    FOR    ${index}    ${att}    IN ENUMERATE    @{tl.attenuators}
        Log To Console    Clearing attenuation on attenuator ${index+1}
        Set Attenuation  90dB  confirm=${TRUE}    attenuator_id=${index+1}
    END

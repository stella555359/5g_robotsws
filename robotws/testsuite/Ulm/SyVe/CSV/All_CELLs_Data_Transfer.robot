*** Settings ***

Documentation
...  Description:
...    using NOKIA UEs
...    author:  Michele Bertolini
...    Team: 'MN ULM R&D SqdGp64'
...    Email: 'I_PZ_ULM_SQD_64@internal.nsn.com'
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.ue
Library    taf.sbts.oam.coam.admin.interface.admin    WITH NAME   coam

Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/connect.robot
Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/git_handling.robot
Resource    ../resources/attenuator.robot


*** Variables ***
${DL_MAX_THROUGHPUT}         10 Mbits/sec    #200 Mbits/sec    #10MHz BW:88 Mbits/sec
${UL_MAX_THROUGHPUT}         10 Mbits/sec    #82 Mbits/sec    #10MHz BW:35 Mbits/sec
${2UEs_DL_MAX_THROUGHPUT}    91 Mbits/sec    #10MHz BW:46 Mbits/sec
${2UEs_UL_MAX_THROUGHPUT}    42 Mbits/sec    #10MHz BW:17 Mbits/sec
${TPUT_DEVIATION}            8%
${INITIAL_4G_ATTENUATION}    ${0}
${INITIAL_5G_ATTENUATION}    ${20}
${INITIAL_OFF_VALUE}         ${110}
${NUM_OF_RU}                 ${3}


*** Test Cases ***
Data Transfer in all Cells
    [Tags]     CRT   All_Cells_Data_Transfer
    Log To Console    ${\n}IPSL Should be run.

    testline.Set Console Output
    testline.Create Test Suite Log Folders
    testline.Check TL Infos
    git_handling.Save Current Workspace Info

    ${oam_connection_alias}=   connect.Setup OAM http session   node_id=${0}
    ${5G_info}=    coam.Get Bts Info    connection=${oam_connection_alias}
    Log To Console    ${\n}--> INFO: ${\n}${5G_info}
    set suite variable    ${gNbCuType}    ${5G_info["gNbCuType"]}
    ${gNbCuType}=    convert to string    ${gNbCuType}
    Log To Console    ${\n}gNbCuType: ${gNbCuType}
    connect.Teardown OAM http session    node_id=${0}

    Log To Console    ${\n}Wait that gNB and eNB are Onair...
    gnb.Wait Until Node To Be Onair State   node_id=${0}
    gnb.Wait Until Node To Be Onair State   node_id=${0}    node_type=enb
    Log To Console    ${\n}Wait that X2 Link Status is Available
    gnb.Wait until X2 Link Status is Available

    attenuator.Set eNB all ports attenuation    value_in_db=${INITIAL_OFF_VALUE}
    attenuator.Set gNB all ports attenuation    value_in_db=${INITIAL_OFF_VALUE}

    attenuator.Set eNB all ports attenuation    value_in_db=${INITIAL_4G_ATTENUATION}

    log to console    Create Configuration for Qualcomm UEs
    ${ueType}=    testline.Get UE type
    Log To Console    ${\n}The UE type is: ${ueType}

    ${ALIAS_UE} =    Set Variable    UE_1
    Set Test Variable    ${ALIAS_UE}
    ${UE_name}    taf.ue.Require UE    ${ALIAS_UE}    capabilities=${ALIAS_UE}
    Log To Console    ${\n}The ${ALIAS_UE} is ${UE_name}

    FOR    ${ru_id_no}    IN RANGE    ${0}    ${NUM_OF_RU}
        Log To Console    ${\n}Data Transfer for RU_id=${ru_id_no}
        attenuator.Set gNB all ports attenuation      ${INITIAL_5G_ATTENUATION}    gnb_id=${0}    ru_id=${ru_id_no}

        taf.ue.Attach UE    ${ALIAS_UE}

        Log To Console    ${\n}Start UL Data Transfer protocol=tcp
        taf.ue.Start Data Transfer
        ...    dt_name=ulDataTransUE1DefaultQCI_TCP
        ...    ue_alias=${ALIAS_UE}
        ...    direction=ul
        ...    protocol=tcp
        ...    duration=30s
        taf.ue.Await Data Transfer Finish    ulDataTransUE1DefaultQCI_TCP

        Log To Console    ${\n}Start DL Data Transfer protocol=tcp
        taf.ue.Start Data Transfer
        ...    dt_name=dlDataTransUE1DefaultQCI_TCP
        ...    ue_alias=${ALIAS_UE}
        ...    direction=dl
        ...    protocol=tcp
        ...    duration=30s
        taf.ue.Await Data Transfer Finish    dlDataTransUE1DefaultQCI_TCP

        Log To Console    ${\n}Start UDP UL+DL Data Transfer
        taf.ue.Start Data Transfer
        ...    dt_name=ulDataTransUE1DefaultQCI
        ...    ue_alias=${ALIAS_UE}
        ...    direction=ul
        ...    duration=90s
        ...    throughput=${UL_MAX_THROUGHPUT}
        ...    packet_size=1330
        taf.ue.Start Data Transfer
        ...    dt_name=dlDataTransUE1DefaultQCI
        ...    ue_alias=${ALIAS_UE}
        ...    direction=dl
        ...    duration=90s
        ...    throughput=${DL_MAX_THROUGHPUT}

        Log To Console    ${\n}Await Data Transfer Finish...
        Run Keyword And Continue On Failure    taf.ue.Await Data Transfer Finish    ulDataTransUE1DefaultQCI
        Run Keyword And Continue On Failure    taf.ue.Await Data Transfer Finish    dlDataTransUE1DefaultQCI

        taf.ue.Stop Data Transfers For All Ues
        taf.ue.Detach UE    ${ALIAS_UE}

        Log To Console    ${\n}Check Data Transfer Throughput...
        Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation    dlDataTransUE1DefaultQCI
        ...        tput=${DL_MAX_THROUGHPUT}  deviation=${TPUT_DEVIATION}
        Run Keyword And Continue On Failure   taf.ue.verify_throughput_with_datagram_loss    dlDataTransUE1DefaultQCI     ${TPUT_DEVIATION}
        Run Keyword And Continue On Failure  taf.ue.Verify Average Throughput With Deviation    ulDataTransUE1DefaultQCI
        ...        tput=${UL_MAX_THROUGHPUT}  deviation=${TPUT_DEVIATION}
        Run Keyword And Continue On Failure   taf.ue.verify_throughput_with_datagram_loss    ulDataTransUE1DefaultQCI     ${TPUT_DEVIATION}

        attenuator.Set gNB all ports attenuation      ${INITIAL_OFF_VALUE}     gnb_id=${0}    ru_id=${ru_id_no}
    END

    [Teardown]    Run Keywords    Log To Console    ${\n}Teardown...
    ...    AND    taf.ue.Stop Data Transfers For All Ues
    ...    AND    Run Keyword And Ignore Error    taf.ue.Detach UE    ${ALIAS_UE}

    Log To Console    ${\n}The End...

*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Make TL Ready
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    5GC002546    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_suxu    CN1_SQ6    SBTS00    SBTS23R1
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config/
##${FULL_SCFC}                5GC002546_AP_LOO_scfc.xml
#${DELTA_SCFC}                2546_B004.json
##${IPHY_XML}                 ${CURDIR}/config/iphy_4F_2T.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/config
#${WTS_CFG}                   basic_2546_AP_LOO.cfg
#
#*** Test Cases ***
#5GC002546_ET_B003_Verify_3CaUEs_BufferBased_ScellActivationMethod_SA
#    SA F+T CA UE Attach    ueId=1    cellId=1
#    SA F+T CA UE Attach    ueId=2    cellId=2
#    A1 Triggered Scell Addition    ueId=2    rsrpnr=90
#    Check SA Scell PhyCellId With UeId    ue_id=2    scell_physicalid=52    scell_index=1
#    SA F+T CA UE Attach    ueId=3    cellId=5
#    SA Start Traffic And Check Tput    ueId=1    dlTput=360    ulTput=20
#    SA Start Traffic And Check Tput    ueId=2    dlTput=200    ulTput=20
#    SA Start Traffic And Check Tput    ueId=3    dlTput=100    ulTput=20
#    2546 B003 DetachUEs
#
#5GC002546_ET_B004_Verify_1CaUE_And_2nonCaUE_Coexist_OnSamePcell_SA
#    [Tags]    AP_P1
#    SA F+T CA UE Attach    ueId=2    cellId=2
#    A1 Triggered Scell Addition   ueId=2    rsrpnr=85
#    SA Start Traffic And Check Tput    ueId=2    dlTput=360    ulTput=25
#    Delta Commission With SCF File     ${DELTA_SCFC}
#    Verify Coam Site Is Ready
#    SA F+T CA UE Attach    ueId=4    cellId=2
#    A1 Triggered Scell Addition   ueId=4    rsrpnr=75
#    Check SA Scell PhyCellId With UeId    ue_id=4    scell_physicalid=52    scell_index=1
#    SA Traffic Stop Internal    ue_id=2    pdu_id=1
#    SA Start Traffic And Check Tput    ueId=4    dlTput=360    ulTput=25
#    SA F+T CA UE Attach    ueId=5    cellId=2
#    SA F+T CA UE Attach    ueId=6    cellId=2
#    NonCA UE Start Traffic And Check Tput    ueId=5    sendDlData=70    dlTput=25    ulTput=10
#    NonCA UE Start Traffic And Check Tput    ueId=6    sendDlData=70    dlTput=15    ulTput=10
#    SA UE Check Throughput    UE_ID=4    dl_tp_threshold=330    ul_tp_threshold=10
#
#*** Keywords ***
#Suite Setup Make TL Ready
#    Suite Setup Update GNB    #scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#
#A1 Triggered Scell Addition
#    [Arguments]    ${ueId}    ${rsrpnr}=80    ${measId}=1
#    ${command}    Set Variable    ue_measurement_send_nr id=${ueId} meas_id=${measId} event=A1 srsrp_nr=${rsrpnr} phycell_id=51
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=1minutes
#    Run Keyword And Ignore Error    Get And Check Scell Infos    ('1', '52', '41')
#
#Check SA Scell PhyCellId With UeId
#    [Arguments]    ${ue_id}    ${scell_physicalid}    ${scell_index}
#    Save Egate Log
#    ${t_scell_id}    Get PhysCellId With UE Id From Egate Log
#    ...    ${ue_id}    ${scell_index}    ${SUITE_LOG_DIRECTORY}/egate_console.log
#    Should Be True    "${scell_physicalid}"=="${t_scell_id}"
#
#SA F+T CA UE Attach
#    [Arguments]    ${ueId}    ${cellId}
#    SA 5G Attach    ue_id=${ueId}
#    SA Set Traffic Type To Internal    ue_id=${ueId}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${ueId}
#    Log To Console    ue${ueId} SA rach successfully.
#
#SA Start Traffic And Check Tput
#    [Arguments]    ${ueId}    ${dlTput}    ${ulTput}
#    SA Start DL Traffic Internal    ue_id=${ueId}    pdu_id=1    mbps=150    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${ueId}    pdu_id=1    mbps=150    trf_id=2
#    SA Start DL Traffic Internal    ue_id=${ueId}    pdu_id=1    mbps=150    trf_id=3
#    SA Start UL Traffic Internal    ue_id=${ueId}    pdu_id=1    mbps=50    trf_id=1
#    Wait Until Keyword Succeeds    1min    5s    SA UE Check Throughput    ${ueId}    ${dlTput}    ${ulTput}
#    ${pcell_TP}     Get CA Cell Average Throughput      ${ueId}    dl    pcell  0
#    ${scell_TP}     Get CA Cell Average Throughput      ${ueId}    dl    scell  1
#    Log To Console    pcell DL Troughput is ${pcell_TP}    console=True
#    Log To Console    scell DL Troughput is ${scell_TP}    console=True
#
#NonCA UE Start Traffic And Check Tput
#    [Arguments]    ${ueId}    ${sendDlData}    ${dlTput}    ${ulTput}
#    SA Start DL Traffic Internal    ue_id=${ueId}    pdu_id=1    mbps=${sendDlData}    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${ueId}    pdu_id=1    mbps=50    trf_id=1
#    Wait Until Keyword Succeeds    30s    5s    SA UE Check Throughput    ${ueId}    ${dlTput}    ${ulTput}
#
#2546 B003 DetachUEs
#    SA 5G Detach    ue_id=1
#    SA 5G Detach    ue_id=2
#    SA 5G Detach    ue_id=3
#
#SA Traffic Stop Internal
#    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}=bi
#    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir=${dir}

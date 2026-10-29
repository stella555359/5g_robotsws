*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G    RAN_5G_TDD    Owner_molyang
#...               CN1_SG6    CB008950    SBTS00
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                ${CURDIR}/Config
#${SCF_FILE}                Configuration_scf_22cells_TDDPcell_21Rels.xml
#${IPHY_FILE}               ${CURDIR}/Config/wts/iphy2.xml
#${LOCAL_WTS_DIR}           ${CURDIR}/Config/wts/
#${WTS_CFG}                 22cell6uec8amf8smf8upf_61ue.lua
#${PCELL_ID}                70
#${A1THRESHOLD}             90
#${PDU_ID}                  1
#@{EXP_DL_TPUT_LIST_OUT}    10    10    10
#@{EXP_DL_TPUT_LIST_IN}     10    10
#${EXP_UL_TPUT_OUT}         2
#${EXP_UL_TPUT_IN}          10
#
#*** Test Cases ***
#CB008950_ET_A505_Multi_Ues_With_10_Outgoing_And_10ues_With_10_Incoming_CA_Relations_TDD_Pcell
#    [Setup]    Run Keywords    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    10 Outgoing Ue Attach
#    10 Incoming Ue Attach
#    10 Outgoing Ue Start DL UL Traffic
#    10 Incoming Ue Start DL UL Traffic
#    Check 10 Outgoing Ue Tput
#    Check 10 Incoming Ue Tput
#    Check Each Outgoing UE Tput
#    Check Each Incoming UE Tput
#    Capture BIP Log By Admin Method    1s
#    Capture Convert Format Ttitrace With Streaming Mode    1s    log_dir=${test_log_directory}/ttitrace/1
#    CUDU_L2 Check DTXNACK Rate    log_id=1    expect_rate=0.05
#    CUDU_L2 Check UL DTXCRC Rate    log_id=1    expect_rate=0.05
#    [Teardown]    Run Keywords    Common Test Teardown
#    ...    AND    Stop Edaemon Egate
#
#*** Keywords ***
#10 Outgoing Ue Attach
#    FOR    ${ue_id}    IN RANGE    1    6
#        Single Ue Attach    ${ue_id}
#        ute_wtssim.Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A1 srsrp_nr=90 phycell_id=70
#    ...    pass_regexp=activated successfully at airphone
#    END
#
#10 Incoming Ue Attach
#    FOR    ${ue_id}    IN RANGE    41    50
#        Single Ue Attach    ${ue_id}
#    END
#    Single Ue Attach    51
#
#10 Outgoing Ue Start DL UL Traffic
#    FOR    ${ue_id}    IN RANGE    1    6
#        SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    150    trf_id=1
#        SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    10    trf_id=1
#    END
#    Sleep    5s    #Wait for traffic stable
#
#10 Incoming Ue Start DL UL Traffic
#    FOR    ${ue_id}    IN RANGE    41    50
#        SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    120    trf_id=1
#        SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    100    trf_id=1
#    END
#    SA Start DL Traffic Internal    51    ${pdu_id}    120    trf_id=1
#    SA Start UL Traffic Internal    51    ${pdu_id}    100    trf_id=1
#    Sleep    5s    #Wait for traffic stable
#
#Check 10 Outgoing Ue Tput
#    FOR    ${id}    IN RANGE    1    5
#        ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=1-5 type=pusch,pdsch scell=0-31    pass_regexp=EGATE>
#        Sleep    10s    #Wait for egate output
#    END
#
#Check 10 Incoming Ue Tput
#    FOR    ${id}    IN RANGE    1    5
#        ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=41-51 type=pusch,pdsch scell=0-31    pass_regexp=EGATE>
#        Sleep    10s    #Wait for egate output
#    END
#
#Check Each Outgoing UE Tput
#    FOR    ${ue_id}    IN RANGE    1    6
#        Check UE DL All Pcell Scell TP On Target For Single UE    ${ue_id}    ${EXP_DL_TPUT_LIST_OUT}    3
#        Check CA UE Pcell Scell Cell TPut On Target    ${ue_id}    ul    pcell    0    ${EXP_UL_TPUT_OUT}
#    END
#
#Check Each Incoming UE Tput
#    FOR    ${ue_id}    IN RANGE    41    50
#        Check UE DL All Pcell Scell TP On Target For Single UE    ${ue_id}    ${EXP_DL_TPUT_LIST_IN}    2
#        Check CA UE Pcell Scell Cell TPut On Target    ${ue_id}    ul    pcell    0    ${EXP_UL_TPUT_IN}
#    END
#    Check UE DL All Pcell Scell TP On Target For Single UE    51    ${EXP_DL_TPUT_LIST_IN}    2
#    Check CA UE Pcell Scell Cell TPut On Target    51    ul    pcell    0    ${EXP_UL_TPUT_IN}
#
#Single Ue Attach
#    [Arguments]    ${ue_id}    ${pdu_id}=1
#    Log To Console    UE${ue_id} Start Attach...
#    SA 5G Attach    ue_id=${ue_id}
#    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${pdu_id}
#    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1
#    ...    pass_regexp=setup/reestablishment complete    timeout=3minutes
#
#

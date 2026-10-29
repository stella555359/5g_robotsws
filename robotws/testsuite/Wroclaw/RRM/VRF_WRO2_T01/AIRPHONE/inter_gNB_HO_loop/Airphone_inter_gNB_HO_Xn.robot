*** Settings ***
Force Tags    CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...           NoResUsage

Documentation   :copyright: Nokia
...             :author: Tomasz Mozola
...             :contact: tomasz.mozola@nokia.com
...             :topology: CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...             :variant: custom configs

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/AIRPHONE/inter_gNB_HO_loop/Keywords_And_Variables.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/color_log.py           WITH NAME    line

Suite Setup        Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs    remote_host=${REMOTE_HOST_1_IP}
...                AND             Get Iphy Xml File    output_filepath=${OUTPUT_DIR}/iphy.xml
...                AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/SN_initial_commissioning.xml    remote_host=${REMOTE_HOST_1_IP}
...                AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/MN_initial_commissioning.xml
...                AND             Update And Put Iphy Xml         input_filepath=${IPHY}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC_GNB_SN}
...                                remote_host=${REMOTE_HOST_1_IP}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC_GNB_MN}
...                AND             Reach Onair    lua_cfg=${cfg}    remote_hosts=${REMOTE_HOSTS}
...                AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs


*** Variables ***
${SCFC_GNB_MN}=             MN_real_gNB_1.xml
${SCFC_GNB_SN}=             SN_real_gNB_2.xml
${IPHY}=                    ${CURDIR}/config/iphy.xml
${cfg}=                     ${CURDIR}/config/mozi.cfg
${ue_id}=                   1
${amf_id}=                  1
${pdu_id}=                  1
${cells}=                   50        51        52        53        54        55        56        57
${ssbfreq}=                 155790    368430    657984    660096    156030    126750    640032    644928


*** Test Cases ***
Inter_GNB_Xn_HO_with_loops
    [Documentation]
    ...    Establish X2 link, Attach to GNB1 cell-50, inter-HO between GNB1 and GNB2 with multiple loops.
    [Setup]    Run Keyword     Start Default Logging And Mark New Test

    Send Command To establish X2 link setup
    FOR    ${loop}    IN RANGE    1    6
        Attach UE1 And Establish PDU Session On GNB2
        builtin.sleep     10s    wait if attach is successfull
        wait for next pm counter interval aic
        line.write line          \n __Start Inter_gNB_Handover from gnb1 cell-50 to gnb2 cell-55 for loop_${loop}
        Trigger A3 event for UE1 with inter-HO to NRCELL-55 and SSB Frequency 126750
        builtin.sleep     5s
        line.write line          \n __Start Inter_gNB_Handover from gnb2 cell-55 to gnb1 cell-50 for loop_${loop}
        Trigger A3 event for UE1 with inter-HO to NRCELL-50 and SSB Frequency 155790
        builtin.sleep     5s
        line.write line          \n __Start Inter_gNB_Handover from gnb1 cell-50 to gnb2 cell-54 for loop_${loop}
        Trigger A3 event for UE1 with inter-HO to NRCELL-54 and SSB Frequency 156030
        builtin.sleep     5s
        line.write line          \n __Start Inter_gNB_Handover from gnb2 cell-54 to gnb1 cell-51 for loop_${loop}
        Trigger A3 event for UE1 with inter-HO to NRCELL-51 and SSB Frequency 368430
        builtin.sleep     5s
        line.write line          \n __Start Intra_gNB_Handover from gnb1 cell-51 to gnb1 cell-50 for loop_${loop}
        Trigger A3 event for UE1 with intra-GNB-HO to NRCELL-50 and SSB Frequency 155790
        builtin.sleep     5s
        line.write line          \n __Verify RRC messages for loop_${loop}
        run keyword and ignore error    Verify Primary Node Flow for UE
        line.write line          \n __Verify expected PM counters for loop_${loop}
        Verify PM counters on MasterNode gNB and SecondaryNode gNB sides
        line.write line          \n __All DONE for loop_${loop}
        Deregister UE    ue_id=${ue_id}
    END

    [Teardown]    Stop Default Processes And Gather Logs And Compress Logs

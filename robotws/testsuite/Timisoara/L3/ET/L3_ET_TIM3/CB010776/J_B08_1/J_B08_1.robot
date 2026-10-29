*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO    CONFIGURED    RAN_5G_TDD    RAN_5G    PY36
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristina Burtea
...              :contact: cristina.burtea@nokia.com

Resource    ../CB008225_Keywords.robot

Suite Setup    Run Keywords    Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get VM Password
...            AND             Get VM IP
...            AND             Start Vm Ethernet Interfaces
...  AND  Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=delta_8225_no_ran_sharing.json
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_non_ran_sharing.lua  timeout=800

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             log to console    Wait until AirPhone is ready to gather logs
...               AND             Sleep    200s
...               AND             Stop Default Processes And Gather Logs And Compress Logs


Test Setup        Run Keywords    Get Vm IP and Replace       delta_scf=delta_Cell_Trace_PCMD_Configuration.json        suite_path=${CURDIR}
...  AND  Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=delta_Cell_Trace_PCMD_Configuration.json
...               AND             Remove Vm IP from delta     delta_scf=delta_Cell_Trace_PCMD_Configuration.json       suite_path=${CURDIR}
...               AND             Run  /dcap_basic_config/hotfix/DCAP_Basic_controller.sh start
...            AND                Prepare and start DCAP  bts_mplane=10.0.1.2

Test Teardown    Run  docker stop $(docker ps -a -q)


*** Test Cases ***
USCB008225_J_B08_1_PCMD_records_from_gNB_DU_during_RRC_Inactive_to_RRC_Connected_transition_AC_fails_in_gNB_DU
    [Documentation]    This user scenario validates the PCMD records reported by gNB-DU when UE moves from
    ...                RRC_Inactive to RRC_Connected state and AC fails in gNB-DU.

    Set AMF To Send CNAI IE In UE Initial Context Setup Request   command=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489_UE2}
    Attach UE    ue_id=2
    Set PDU Param Internal Traffic    ue_id=2
    Establish PDU Session    ue_id=2    pdu_id=1    gw_id=2
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
    Execute Egate Command    cmd=trf_data_stop ue=2 pdu=1 qfi=1 dir=dl
    Sleep  180s
    Perform Parameter Commissioning    parameter=maxNumOfRrcSA    value=0    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
    Sleep  20s
    Stop DCAP trace and download logs
    Convert 5gm Files To Csv
    Convert lcbin Files To Csv



     Check msg in Control Plane logs  UEContextReleaseCommand::rrcReject
     Check msg in Cell Trace logs  UeCtxSetupTraceRecord::ueCtxSetupRecord,result miscFailure
     Check msg in Cell Trace logs  UeCtxSetupTraceRecord::ueCtxSetupRecord,initialUeRrcMessageTransferSndTime
     Check msg in Cell Trace logs  UeCtxSetupTraceRecord::ueCtxSetupRecord,gnb-cu-ue-f1ap-Id
     Check msg in Cell Trace logs  UeCtxSetupTraceRecord::ueCtxSetupRecord,gnb-du-ue-f1ap-Id
     Check msg in Control Plane logs  InitialULRRCMessageTransfer::rrcResumeRequest1




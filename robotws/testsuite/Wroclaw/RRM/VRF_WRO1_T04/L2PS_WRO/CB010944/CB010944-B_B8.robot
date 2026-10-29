*** Settings ***
Documentation
...    copyright: Nokia

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Resource     CB010944_keywords.robot
Library      CB010944_keywords.py
Library      ute_admin_infomodel


*** Variables ***
${iphy_CB010944}                 ${CURDIR}/config/AEQE_iphy.xml
${scf_CB010944}                  ${CURDIR}/config/SBTS00/full_CB010944_100MHz_1208.xml
${cfg_CB010944}                  ${CURDIR}/config/basic_setup.cfg
@{L2PS_BIP}                      0x3F007C = 100
${ADMIN_INFOMODEL_ALIAS}         infomodel_1
${ADMIN_INFOMODEL_LOG_DIR}       ${OUTPUT_DIR}
${ADMIN_INFOMODEL_FILENAME}      infomodel.ims2
${DL_SLOTS_ARTIFICIAL_LOAD}      M55308C00044
${LOCAL_MOID_PCELL}              PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

*** Keywords ***
CB010944-B#B8_Interworking with 5GC002538 PDSCH Extension in SSB and TRS slots
    Verify Target Beam Candidates
    Check Selected Beam Candidates    NRBEAM_EMF-1
    Start Gathering BIP Logs
    Stop gnbMirroring And Gather L1L2 Bip Logs
    Verify Max PRB for TargetLoad
    Verify PRB for TRS Slot
    Verify MCS TargetLoad
    Verify PM Counter For DL Slots Artificial Load
    Deactive Emf1 Test Mode
    Verify Target Beam Candidates Not Exist


Active Emf1 Beam
    Send Delta Commissioning    input_filepath=${CURDIR}/config/emfbeam_1.json

Deactive Emf1 Test Mode
    Send Delta Commissioning    input_filepath=${CURDIR}/config/deactive_emf_1.json

Verify Max PRB for TargetLoad
    Convert pcap file to pdml   tshark_filters=(dldata_pdschsendreql1sw||dldata_csirssendreql1sw)
    verify_PRB_for_patternId    pdml_path=${OUTPUT_DIR}/BIP_log_1.pdml    patternId=1287   num_prb=257

Verify MCS TargetLoad
    verify_mcs_for_targetload    pdml_path=${OUTPUT_DIR}/BIP_log_1.pdml    patternId=1287

Verify PRB for TRS Slot
    verify_num_of_prb_for_trs_slot    pdml_path=${OUTPUT_DIR}/BIP_log_1.pdml    prb=257


Verify PM Counter For DL Slots Artificial Load
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${DL_SLOTS_ARTIFICIAL_LOAD}
    ...    value=480000
    ...    local_moid=${LOCAL_MOID_PCELL}
    ...    filepath=${PM_COUNTERS_FILE}

Stop gnbMirroring And Gather L1L2 Bip Logs 2
     [Arguments]
     ...     ${alias}=L1L2_BIP_Logs
     ...     ${dir_path}=${OUTPUT_DIR}
     ...     ${delay}=0
     Sleep  ${delay}
     Create directory  path=${dir_path}/${alias}
     Create directory  path=/tmp/${alias}
     core.stop_collectors    names=tcpdump
     core.collect_collectors    names=tcpdump    target_dir=${OUTPUT_DIR}
     core.teardown_collectors    names=tcpdump
     ${rc}=    Run And Return Rc  mergecap -a ${dir_path}/tcpdump/*mirroring_L2L1*.pcap* -w /tmp/${alias}/tcpdump.pcap
     Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
     OperatingSystem.Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/BIP_L1L2_2.pcap
     Remove Directory    ${OUTPUT_DIR}/tcpdump
     ...                 recursive=True
     Sleep    10s

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${pdu}    ${qfi}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Sa    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} >= ${expected_tput}

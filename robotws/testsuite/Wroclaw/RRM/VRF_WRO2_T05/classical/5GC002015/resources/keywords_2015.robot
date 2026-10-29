*** Settings ***
Documentation
...   author: Karolina Pawlik
...   contact: karolina.pawlik.ext@nokia.com

Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    testsuite/Wroclaw/RRM/resources/connections.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002015/resources/keywords_2015.py
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
#Variables     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/variables.py
Library     Collections
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.collectors.btslog  WITH NAME   btslog
Library     taf.collectors.core   WITH NAME   core
Library     taf.config.scf     WITH NAME  scf
Library     taf.transport.ssh  WITH NAME  ssh
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
#Resource    testsuite/TRS/Wroclaw/Classical/coam_common_resources/coam_connections.robot
#Library     resources/Macro/Python/coam_parameter.py
Library     ute_ue
#Library     scopes.py
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Library     taf.converters.pcaptopdml    WITH NAME    pcaptopdml
Library     taf.ul.parser.pcap     WITH NAME    parser
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_kw.py
#Resource    testsuite/TRS/Wroclaw/Classical/coam_common_resources/bts_commissioning/perform_commissioning.py


*** Variables ***

${tput_DL_bandwith}     200Mbits/sec
${tput_UL_bandwith}     15MBits/sec
${tput_duration}        30s
${packet_size}          1024
${resource_path_2015}=       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002015/resources


*** Keywords ***

Connecting To Coam
    [Arguments]  ${alias}=cOAM
    Log to console      Connect to cOAM.
    coam.Connect to    name=${alias}


Disconnecting from Coam
    [Arguments]  ${alias}=cOAM
    coam.Teardown     connection=${alias}


Reserve UEs For tests
    ute_ue.Require Ue       UE_1        capabilities=REAL_ANDROID_UE_NSA
    ute_ue.Require Ue       UE_2        capabilities=REAL_ANDROID_UE_SA
    log to console          UEs reserved


Attach UE
    [Arguments]         ${UE_alias}
    ute_ue.Attach Ue    ${UE_alias}
    log to console      Attach UE ${UE_alias}


Detach UE
    [Arguments]         ${UE_alias}
    ute_ue.Detach Ue    ${UE_alias}
    log to console      Detach Ue  ${UE_alias}


Start Traffic UDP DLUL
    [Arguments]         ${used_ue}      ${transfer_DL_name}        ${transfer_UL_name}
    log to console          Started tput DLUL UDP
    Start Data Transfer     dt_name=${transfer_DL_name}   ue_alias=${used_ue}     direction=dl    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}          protocol=udp    packet_size=${Packet_Size}
    ...                     server_close_delay=240
    Start Data Transfer     dt_name=${transfer_UL_name}   ue_alias=${used_ue}     direction=ul    duration=${tput_duration}
    ...                     throughput=${tput_UL_bandwith}          protocol=udp    packet_size=${Packet_Size}
    ...                     server_close_delay=240
    Await Data Transfer Finish      dt_name=${transfer_DL_name}
    Await Data Transfer Finish      dt_name=${transfer_UL_name}
    Sleep    5s
    log to console          Data Transfer completed. Reset iperf.


Turn on parameter actDlDataDmrsFdm
    [Arguments]     ${dlDMRSAdditionalPosition}=No additional DMRS
    ...             ${actDl256Qam}=false
    ...             ${chBwDl}=10MHz
    ...             ${chBwUl}=10MHz
    ${cell_dist}    Get list of cells
    &{feature}         Create dictionary    actDlDataDmrsFdm=true
                                    ...     dlDataDmrsFdmThres256QamMcs=20
                                    ...     dlDataDmrsFdmThres64QamMcs=20
    log to console                  Perform parameters recommissioning
    initialise delta store
    FOR    ${cell}    IN   @{cell_dist}
        ${object_path}      Set variable    MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/${cell}
        Add param to delta            ${object_path}/NRCELL_FDD-1      chBwDl            value=${chBwDl}
        Add param to delta            ${object_path}/NRCELL_FDD-1      chBwUl            value=${chBwUl}
        Add list parameters to delta  ${object_path}      dlDataDmrsFdm                  &{feature}
        Add param to delta            ${object_path}      dlDMRSAdditionalPosition       value=${dlDMRSAdditionalPosition}
        Add param to delta            ${object_path}      actDl256Qam                    value=${actDl256Qam}
        Add param to delta            ${object_path}      dmrsTypeAPosition              value=pos3
        ${delta}            Collect delta store
    END
    AdminHelper.Recommission with delta from admin    ${delta}
    Sleep     30s
    Wait until keyword succeeds    10 min    30s    Verify all cells are onair with admin
    log to console      Parameter actDlDataDmrsFdm is turned on.


Turn off parameter actDlDataDmrsFdm
    ${cell_dist}       Get list of cells
    &{feature}         Create dictionary    actDlDataDmrsFdm=false
                                    ...     dlDataDmrsFdmThres256QamMcs=20
                                    ...     dlDataDmrsFdmThres64QamMcs=20
    log to console                  Perform parameter actDlDataDmrsFdm recommissioning
    Initialise delta store
    FOR    ${cell}    IN   @{cell_dist}
        ${object_path}      Set variable    MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/${cell}
        Add list parameters to delta    ${object_path}      dlDataDmrsFdm               &{feature}
        ${delta}            Collect delta store
        AdminHelper.Recommission with delta from admin    ${delta}
    END
    Sleep     30s
    Wait until keyword succeeds    10 min    30s    Verify all cells are onair with admin
    log to console      Parameter actDlDataDmrsFdm is turned off.


Check Amount Of MCS
    [Arguments]   ${dir}=${OUTPUT DIR}/${filename}
    ${msgs}    check mcs dmrs value     ${dir}      # check mcs dmrs value from keywords_2015.py
#    should be true    ${msgs}


Deactivate feature 2534
    ${cell_dist}    Get list of cells
    Log to console            >Deactivating feature 2534...<
    initialise delta store
    FOR    ${cell}    IN   @{cell_dist}
        ${object_path}        Set variable    MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/${cell}
        Add param to delta    ${object_path}    actPdschAtSsbSlots    value=false
    END
    ${delta}            Collect delta store
    AdminHelper.Recommission with delta from admin    ${delta}
    Log to Console           >Feature 2534 has been deactivated.<


Compare Two Truputs
    [Arguments]         ${tpt_feature_on}     ${tpt_feature_off}
    log to console      Compare Trughputs
    common_kw.Compare Truputs     ${tpt_feature_on}     ${tpt_feature_off}


Get Cell Id To Which Ue Is Attached 2015
    ${out}        keywords_2534.generated pcap data for subcellid     pcap_path=${filename}
    ${cellid}  get cell id from list  ${out}
    Sleep   10s
    Should contain any    ${cellid}    1  2  3
    [Return]    ${cellid}


Verify PM Counters 2015
    log to console      Verify PM counters values
    Sleep                       300s
    ${counters}                 Read Counters Value
    ${cell_id}                  Get Cell Id To Which Ue Is Attached 2015
    ${SSB_SLOT_PDSCH}           Get Counter Value From Single Cell      ${counters}     ${cell_id}      M55308C00015
    ${SSB_SLOT_PDSCH_TIME}      Get Counter Value From Single Cell      ${counters}     ${cell_id}      M55308C00016
    ${DATA_SLOT_PDSCH}          Get Counter Value From Single Cell      ${counters}     ${cell_id}      M55308C00005
    ${DATA_SLOT_PDSCH_TIME}     Get Counter Value From Single Cell      ${counters}     ${cell_id}      M55308C00008
    Should Be True      0<=${SSB_SLOT_PDSCH}
    Should Be True      ${SSB_SLOT_PDSCH}<=${DATA_SLOT_PDSCH}
    Should Be True      0<=${SSB_SLOT_PDSCH_TIME}
    Should Be True      ${SSB_SLOT_PDSCH_TIME}<=${DATA_SLOT_PDSCH_TIME}

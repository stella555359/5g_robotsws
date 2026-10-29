*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Library      ../resources/Python/webem_alarms.py
Library      taf.transport.ssh  WITH NAME  ssh
Library      CB010784_keywords.py
Library      taf.sbts.oam.coam.admin
Library      Collections
Library      String
Library      taf.ul.gnb.bip.collection    WITH NAME    bip_collection
Library      taf.collectors.l1l2bip       WITH NAME    l1l2bip

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_1AZQJ_1cell_100M_addExtDelay_200.xml
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=CB010784_prach_145_addExtDelay_200_4DL4UL.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup.cfg
    ...        AND             ADMIN Setup Admin       alias=admin

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs
    ...    AND   ADMIN Teardown Admin    alias=admin

*** Variables ***
${LOCAL_MOID}=              PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${Vlue_DownlinkSymbols}=    (nrofDownlinkSymbols 5)
${TA_RACH_RESP_BIN_17}=     M55307C01017

*** Test Cases ***
CB010784-A_B4_UE_call_to_regular_cell_with_3rdPS_SA_UEspecificCSIRS_GP7
    Verify NR of Downlink Symbols
    Verify Guard Period Lengh    expected_value=7Symbols
    Start Gathering BIP Logs
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Sleep    5s
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
	Start DL and UL Data Traffic SA
    Verify Tput For UE SA    ue_id=1    pdu=1    qfi=1    dir=dl    unit=M    expected_tput=98.5
    Verify Tput For UE SA    ue_id=1    pdu=1    qfi=1    dir=ul    unit=M    expected_tput=98.5
    Verify Timing Advance Counters
    Stop gnbMirroring And Gather L1L2 Bip
    Verify CSI-RS In Some BI Slots
    [Teardown]    Stop All Data Transfers And Detach UE

*** Keywords ***
Verify NR of Downlink Symbols
    Verify Egate Content    expected_pattern=${vlue_DownlinkSymbols}

Verify Guard Period Lengh
    [Arguments]    ${expected_value}
    ${out}    Check guardPeriodLength Value For Cell      cell_id=1
    Should Contain   ${out}    ${expected_value}

ADMIN Setup Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Setup Admin
    ...    alias=${alias}

ADMIN Teardown Admin
    [Arguments]    ${alias}=${ADMIN_ALIAS}
    taf.sbts.oam.coam.admin.Teardown Admin
    ...    connection=${alias}

ADMIN Get Managed Objects With Parameters
    [Documentation]    Get managed objects with parameters
    ...    class_name example: SMOD, RMOD_R, GNSS_L, NRCELL_A, NRCELL_L, NRCELL_R ...
    [Arguments]    ${class_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_objects_parameters_dict}    taf.sbts.oam.coam.admin.get_managed_objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    [Return]    ${out_list_of_objects_parameters_dict}

ADMIN Get Object Distname And Id List
    [Documentation]    Get object dist name (im path) and separetly list of object's ids
    ...    usage example: for class_name=NRCELL_A keyword returns full distname without id (output example below):
    ...    out_object_distName: /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-15/SCF-1/MRBTS_A-50370/NRBTS_A-50370/NRCELL_A
    ...    and list of object's ids (output example below):
    ...    out_object_id_list: [u'2', u'1']
    ...    class_name example: SMOD, RMOD_R, GNSS_L, NRCELL_A, NRCELL_L, NRCELL_R ...
    [Arguments]    ${class_name}
    ...            ${alias}=${ADMIN_ALIAS}
    ${object_parameters}    ADMIN Get Managed Objects With Parameters
    ...    class_name=${class_name}
    ...    alias=${alias}
    ${out_object_id_list}    Create List
    FOR    ${element}    IN    @{object_parameters}
        ${distName}    Get From Dictionary    ${element}    distName
        ${out_object_distName}    ${id}    Split String From Right    ${distName}    -    1
        Append To List    ${out_object_id_list}    ${id}
    END
    [Return]    ${out_object_distName}    ${out_object_id_list}

ADMIN Get Parameter
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${timeout}=10
    ...            ${connection}=${ADMIN_ALIAS}
    ${out_parameters}    taf.sbts.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=${parameter}
    ...    timeout=${timeout}
    ...    connection=${connection}
    [Return]    ${out_parameters}

Check guardPeriodLength Value For Cell
    [Arguments]    ${cell_id}
    ${nrcell_a_distname}    ${id_list}    ADMIN Get Object Distname And Id List
    ...    alias=admin
    ...    class_name=NRCELL_A
    ${parameter}    ADMIN Get Parameter
    ...    dist_name=${nrcell_a_distname}-${cell_id}
    ...    parameter=guardPeriodLength
    ...    connection=admin
    [Return]    ${parameter['tddFrameStructure']['guardPeriodLength']}

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Start DL and UL Data Traffic SA
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=100
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=100
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Sleep    30s

Verify Timing Advance Counters
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
	Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${TA_RACH_RESP_BIN_17}
    ...    value=1
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS}

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${pdu}    ${qfi}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Sa    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} >= ${expected_tput}

Start Gathering BIP Logs
    [Documentation]     Collect L1L2 BIP Logs using taf.ul.gnb.bip.collection - scripting approach
    ...     -   :param alias:     Alias for l1l2bip which is also a directory name (default L1L2_BIP_Logs)
    ...     -   :param bb_mods:   List of BB modules to start collection from them, default: [ABIO]
    [Arguments]
    ...     ${bb_mods}=[ABIO]

    bip_collection.Configure Bip Collection     l1_type=FS
    ...                                         gNB_common_unit=ASIL
    ...                                         gNB_capacity_units=${bb_mods}
    ...                                         use_script=True
    bip_collection.Start Bip Trace
    Log to console  BIP logs collecting started

Stop gnbMirroring And Gather L1L2 Bip
    [Documentation]     Stop collecting BIP Logs and save them at selected location
    ...     -   :param alias:       Alias for l1l2bip which is also a directory name without spaces (default L1L2_BIP_Logs)
    ...     -   :param dir_path:    Path where BIP logs should be copied (default ${OUTPUT_DIR}/
    ...     -   :param delay:       Time to wait before collecting the logs
    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    ...     ${dir_path}=${OUTPUT_DIR}
    ...     ${delay}=5
    Sleep  ${delay}
    Create directory  path=${dir_path}/${alias}
    Create directory  path=/tmp/${alias}
    bip_collection.Stop Bip Trace   target_dir=/tmp/${alias}
#    ${rc}=    Run And Return Rc  mergecap -a /tmp/${alias}/tcpdump*.pcap* -w /tmp/${alias}/tcpdump.pcap
    ${rc}=    Run And Return Rc  mergecap -a /tmp/${alias}/BTS1_*.pcap* -w /tmp/${alias}/tcpdump.pcap
    Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
    Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/BIP_L1L2.pcap
    Remove directory    /tmp/${alias}    recursive=True
    Log to console  BIP logs collecting finished
    Convert pcap file to pdml

Convert pcap file to pdml
    [Documentation]     Using luashark converting BIP log from pcap to pdml.
    [Arguments]   ${input_file}=${OUTPUT_DIR}/BIP_L1L2.pcap
    Log to console    Converting pcap to pdml
    ${tshark_cmd} =    Catenate    tshark
    ...    -r ${input_file}
    ...    -Y "(dldata_pdschsendreq) && (DlData_PdschGrant.isCsirsRateMatching==1) && (DlData_PdschGrant.numCsirsMappingRes !=0)"
    ...    -T pdml > ${OUTPUT_DIR}/BIP_log.pdml
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
    Sleep    5s

Verify CSI-RS In Some BI Slots
    ${isCsirsRateMatching}    ${numCsirsMappingRes}    Get isCsirsRateMatching And numCsirsMappingRes    pdml_path=${OUTPUT_DIR}/BIP_log.pdml
    Should Be True    ${isCsirsRateMatching}==${1}
    Should Be True    ${numCsirsMappingRes}!=${0}

Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

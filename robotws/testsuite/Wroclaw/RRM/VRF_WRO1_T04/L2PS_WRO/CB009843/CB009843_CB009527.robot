*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LOOO   VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G
...   RAN_5G_TDD

Documentation    :copyright: Nokia
...              :authors: Kamil Galczynski
...              :contact: kamil.galczynski@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     resources/CB009843_keywords.robot
Resource    ../CB007813/connect.robot
Library    ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    ../CB007813/CB007813-B_keywords.py
Library    resources/vendor_file_modifier.py
Library    Collections
Resource     ../resources/configuration_id.robot
Library    resources/CB009843.py
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.core    WITH NAME    core


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_6xAVHA_100mhz.xml
    ...                        swconfig_flags_list=@{SWCONFIG_FLAGS}
    ...        AND             Start Default Logging
    ...        AND             Get and Update BSR File  bsr_file_name=BSR_AVHA_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002.zip
    ...        AND             Download and Modify Vendor File and perform commissioning    scf=full_CB009527
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_9527.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS}=      0x8000A6=0

*** Test Cases ***
[1]CB009527-A#1_Attach_ and_data_transfer
	Set Beams
    Attach UEs
    Start Dl and UL Data Traffic For All UEs
    Start Gathering BIP Logs
    Stop gnbMirroring And Gather L1L2 Bip Logs
    Convert pcap file to pdml    ${OUTPUT_DIR}/BIP_L1L2.pcap    uldata_srsreceivereq    ${OUTPUT_DIR}/BIP_log.pdml
    verify_if_sub_band_SRS_is_enabled   pdml_path=${OUTPUT_DIR}/BIP_log.pdml
    [Teardown]    Send Configuration ID To Scout

*** Keywords ***
Convert pcap file to pdml
    [Arguments]   ${input_file}
    ...           ${filter}
    ...           ${dir_path}
    Log to console    Converting pcap to pdml
    ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -Y ${filter}
    ...    -T pdml > ${dir_path}
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
    Sleep    10s

Start Gathering BIP Logs
    [Arguments]    ${target_file_name}=tcpdump
     ${webservice}=  Create Dictionary
     ...  host=192.168.255.129
     ...  user=Nemuadmin
     ...  password=nemuuser
     ...  port=443

     create_interface_mirroring_l1l2bip_collector
     ...  name=tcpdump
     ...  webservice=${webservice}
     ...  target_file_name=tcpdump
     ...  timeout=1300
     ...  remove_zip_file=False
     core.setup_collectors    names=tcpdump
     core.start_collectors    names=tcpdump
     core.Set Suite Alias     ${target_file_name}
     Sleep    50

Stop gnbMirroring And Gather L1L2 Bip Logs
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
     OperatingSystem.Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/BIP_L1L2.pcap
     Remove Directory    ${OUTPUT_DIR}/tcpdump
     ...                 recursive=True
     Sleep    10s

Set Beams
	Execute Egate Command   cmd=ul_ue_beam_pos_nr profile_id=1 num_subband_info=2 mode=0 correlation=1,1
	...     num_interfered_bf_subband=0,0 interfered_srs_subband=0,0 srs_transmit_power_per_port=-550,-550
	FOR    ${id}    IN RANGE    1    7
		Execute Egate Command   cmd=ue_testmode_set_nr id=${id} testmode=ue_ul_beam_position action=activate profile_id=1
    END

Start Dl and UL Data Traffic For All UEs
    FOR    ${id}    IN RANGE    1    7
		Start Dl and UL Traffic     ue_id=${id}
    END
    Sleep    30s

Start Dl and UL Traffic
	[Arguments]    ${ue_id}
	Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} dir=dl mbps=175 trf_id=1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} dir=dl mbps=175 trf_id=2

    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} dir=ul mbps=50 trf_id=1

Attach UEs
	FOR    ${id}    IN RANGE    1    7
		Set Internal Traffic Type To UE    ue_id=${id}    pdu_id=${id}
        Attach Ue    ue_id=${id}
        Establish Pdu Session    ue_id=${id}     pdu_id=${id}     gw_id=${id}
    END

Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

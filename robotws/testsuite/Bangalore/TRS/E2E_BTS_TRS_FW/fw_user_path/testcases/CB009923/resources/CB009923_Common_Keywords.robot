*** Settings ***
Documentation
...     [Author]            "Punith K"
...     [Maintenance]       "TRS I & V Tools Bangalore Team"
...     [Procedure]         "The test case covers IP traffic capturing with ipsec configuration"
...     [Date]              "21-10-2024"
...     [QC_Path]           "QC_Path in Test Plan"
...     [QC_ID]             "--"
...     [Funtion_Hash_Tags]     "TRS - Security"
...     [Feature_ID]            "CB009923"
...     [Requirement ID]        ""
...     [Validation_Status] "Validated"
...     [Validated_TestLine]    "TL006"
...     [Config]            "This testcase needs basic scf with ipsec configuration"

variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot

*** Keywords ***
Perform ipsec configuration on vcu and vdu
    Perform Recommissioning     type=delta  delta_file=${CB009923_IPSEC_with_PSK_vCU}    skip_parameter_relation_errors=${True}
    ...     dut=vcu    alias=vcu   timeout=4000
    Perform Recommissioning     type=delta  delta_file=${CB009923_IPSEC_with_PSK_vDU}    skip_parameter_relation_errors=${True}
    ...     dut=vdu    alias=vdu     timeout=4000

Perform PSK Configuration on vcu and vdu
    Update Cu Psk Configuration     password=Testing@12345  timeout=30  dut=dbts  alias=vdu
    Update Cu Psk Configuration     password=Testing@12345  timeout=30  dut=cbts  alias=vcu

Perform ipsec configuration for PSK on VM
    Run     sudo ip a a fc00::11:1/116 dev eth7
    Run     sudo ip a a fc00::12:1/116 dev eth8
    Run     sudo cp ${CURDIR}/resources/ipsec_PSK.secrets /etc/ipsec.secrets
    Run     sudo cp ${CURDIR}/resources/ipsec_PSK.conf /etc/ipsec.conf
    Run     sudo ipsec restart

Attach UE and send ul dl traffic
   [Documentation]        This test case keyword is to trigger the calls
   Configure UE    5g=5g_basic_setup_cfg:data        command=ue_register   id=1
   Sleep     20
   Configure UE    5g=5g_basic_setup_cfg:data        command=set_pdu_param     ue=1    pdu=1   trf_type=internal
   Sleep     20
   Configure UE    5g=5g_basic_setup_cfg:data        command=ue_pdu_session_setup  pdu=1   gw=1    ue=1
   Sleep     20
   Configure UE    5g=5g_basic_setup_cfg:data        command=trf_data_start    ue=1    pdu=1   qfi=1   dir=dl  trf_id=1   mbps=100    protocol=tcp
   Sleep     20
   Configure UE    5g=5g_basic_setup_cfg:data        command=trf_data_start    ue=1    pdu=1   qfi=1   dir=ul  trf_id=1   mbps=100    protocol=tcp
   Sleep     20
   Configure UE    5g=5g_basic_setup_cfg:data        command=enb_x2_link_up     enb=1      target=2
   Sleep     20
   Configure UE    5g=5g_basic_setup_cfg:data        command=ue_attach     id=101       profile=1
   Sleep     20
   Configure UE    5g=5g_basic_setup_cfg:data        command=enb_ue_dc_start   ue=101  target_gnb=2    target_cells=1  bearer=2    type=split_scg
   Sleep     20
   Configure UE    5g=5g_basic_setup_cfg:data        command=trf_data_start    ue=101  id=2    dir=ul  trf_id=1    mbps=100
   Sleep     20
   Configure UE    5g=5g_basic_setup_cfg:data        command=trf_data_start    ue=101  id=2    dir=dl  trf_id=2    mbps=100
   Sleep     20

Stop traffic and detach UE
   [Documentation]        This test case keyword is to stop the Calls
   Configure UE    5g=5g_basic_setup_cfg:data        command=ue_deregister        id=1        ue_deregister_type=switch_off
   Sleep     20

Get downloaded enc_pcaps of vDU
    ${uplane_pcap_enc}=     Run     ls ${pcaps_dir}/ | grep gNB_vDU_1_po-${namespace}-l2nrt-0
    ${cplane_pcap_enc}=     Run     ls ${pcaps_dir}/ | grep gNB_vDU_1_po-${namespace}-cprt-0
    ${mplane_pcap_enc}=     Run     ls ${pcaps_dir}/ | grep gNB_vDU_1_po-${namespace}-oamext-0
    set suite variable  ${uplane_pcap_enc}  ${uplane_pcap_enc}
    set suite variable  ${cplane_pcap_enc}  ${cplane_pcap_enc}
    set suite variable  ${mplane_pcap_enc}  ${mplane_pcap_enc}

Get downloaded pcaps of vDU
    ${uplane_pcap}=     Run     ls ${pcaps_dir}/ | grep gNB_vDU_1_po-${namespace}-l2nrt-0
    ${cplane_pcap}=     Run     ls ${pcaps_dir}/ | grep gNB_vDU_1_po-${namespace}-cprt-0
    ${mplane_pcap}=     Run     ls ${pcaps_dir}/ | grep gNB_vDU_1_po-${namespace}-oamext-0
    set suite variable  ${uplane_pcap}  ${uplane_pcap}
    set suite variable  ${cplane_pcap}  ${cplane_pcap}
    set suite variable  ${mplane_pcap}  ${mplane_pcap}

Analyse downloaded pcaps of vDU
    Analyse Pcap    pcap_filename=${pcaps_dir}/${uplane_pcap}        analysis=traffic_ul     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${uplane_pcap}        analysis=traffic_dl     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${cplane_pcap}        analysis=traffic_cplane     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${mplane_pcap}        analysis=traffic_mplane     filter_file_name=traffic_filters.json

Analyse downloaded pcaps at PointB of vDU
    Analyse Pcap    pcap_filename=${pcaps_dir}/${uplane_pcap}        analysis=traffic_ul     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${uplane_pcap}        analysis=traffic_dl     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${cplane_pcap}        analysis=traffic_cplane_PointB     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${mplane_pcap}        analysis=traffic_mplane     filter_file_name=traffic_filters.json

Get downloaded enc_pcaps of vCU
    ${uplane_pcap_enc}=     Run     ls ${pcaps_dir}/ | grep gNB_vCU_1_po-${namespace}-upue-0
    ${cplane_pcap_enc}=     Run     ls ${pcaps_dir}/ | grep gNB_vCU_1_po-${namespace}-cpif-0
    ${mplane_pcap_enc}=     Run     ls ${pcaps_dir}/ | grep gNB_vCU_1_po-${namespace}-oamext-0
    set suite variable  ${uplane_pcap_enc}  ${uplane_pcap_enc}
    set suite variable  ${cplane_pcap_enc}  ${cplane_pcap_enc}
    set suite variable  ${mplane_pcap_enc}  ${mplane_pcap_enc}

Get downloaded pcaps of vCU
    ${uplane_pcap}=     Run     ls ${pcaps_dir}/ | grep gNB_vCU_1_po-${namespace}-upue-0
    ${cplane_pcap}=     Run     ls ${pcaps_dir}/ | grep gNB_vCU_1_po-${namespace}-cpif-0
    ${mplane_pcap}=     Run     ls ${pcaps_dir}/ | grep gNB_vCU_1_po-${namespace}-oamext-0
    set suite variable  ${uplane_pcap}  ${uplane_pcap}
    set suite variable  ${cplane_pcap}  ${cplane_pcap}
    set suite variable  ${mplane_pcap}  ${mplane_pcap}

Analyse downloaded pcaps of vCU
    Analyse Pcap    pcap_filename=${pcaps_dir}/${uplane_pcap}        analysis=traffic_ul_vcu     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${uplane_pcap}        analysis=traffic_dl_vcu     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${cplane_pcap}        analysis=traffic_cplane     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${mplane_pcap}        analysis=traffic_mplane     filter_file_name=traffic_filters.json

Analyse downloaded pcaps at PointB of vCU
    Analyse Pcap    pcap_filename=${pcaps_dir}/${uplane_pcap}        analysis=traffic_ul_vcu     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${uplane_pcap}        analysis=traffic_dl_vcu     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${cplane_pcap}        analysis=traffic_cplane_PointB_vcu     filter_file_name=traffic_filters.json
    Analyse Pcap    pcap_filename=${pcaps_dir}/${mplane_pcap}        analysis=traffic_mplane     filter_file_name=traffic_filters.json

Decrypt downloaded pcaps
    Run     openssl aes-128-cbc -d -a -in ${pcaps_dir}/${uplane_pcap_enc} -out ${pcaps_dir}/${decry_uplane_pcap} -k ${encrypt_password}
    Run     openssl aes-128-cbc -d -in ${pcaps_dir}/${cplane_pcap_enc} -out ${pcaps_dir}/${decry_cplane_pcap} -k ${encrypt_password} -iter 10000
    Run     openssl aes-128-cbc -d -in ${pcaps_dir}/${mplane_pcap_enc} -out ${pcaps_dir}/${decry_mplane_pcap} -k ${encrypt_password} -iter 10000
    set suite variable    ${uplane_pcap}  ${decry_uplane_pcap}
    set suite variable    ${cplane_pcap}  ${decry_cplane_pcap}
    set suite variable    ${mplane_pcap}  ${decry_mplane_pcap}
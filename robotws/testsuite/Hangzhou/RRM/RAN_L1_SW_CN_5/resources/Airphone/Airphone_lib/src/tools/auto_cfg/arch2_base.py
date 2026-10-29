# -*- coding: utf-8 -*-

"""
:author: eric.jiang
:contact: eric.jiang@nokia-sbell.com
:maintainer: eric.jiang@nokia-sbell.com
"""

from collections import OrderedDict

#############################################################################################################
# WTS_VARIABLES
#############################################################################################################
ARCH2_WTS_VARIABLES = OrderedDict()
ARCH2_WTS_VARIABLES["$CONTAINER_IP"] = "10.0.2.1"
ARCH2_WTS_VARIABLES["$SERVER_IP"] = "10.0.2.1"
ARCH2_WTS_VARIABLES["$DAEMON_IP"] = "10.0.2.1"
ARCH2_WTS_VARIABLES["$EDAEMON_PORT"] = "22222"
ARCH2_WTS_VARIABLES["$DAEMON_PORT"] = "22222"

ARCH2_WTS_VARIABLES["$PROXY_SERVER_IP"] = "10.0.2.80"
ARCH2_WTS_VARIABLES["$PROXY_SERVER2_IP"] = "10.0.2.90"
ARCH2_WTS_VARIABLES["$PROXY_SERVER3_IP"] = "10.0.2.91"
ARCH2_WTS_VARIABLES["$PROXY_SERVER4_IP"] = "10.0.2.92"
ARCH2_WTS_VARIABLES["$PROXY_SERVER5_IP"] = "10.0.2.93"

ARCH2_WTS_VARIABLES["$GNB2_NG_ADDR"] = "10.0.1.2"  # Real GNB2
ARCH2_WTS_VARIABLES["$GNB2_XN_ADDR"] = "10.0.1.2"
ARCH2_WTS_VARIABLES["$GNB2_X2_ADDR"] = "10.0.1.2"
ARCH2_WTS_VARIABLES["$GNB2_S1U_ADDR"] = "10.0.1.2"

ARCH2_WTS_VARIABLES["$GNB3_NG_ADDR"] = "10.0.1.122"  # Simulator or Real
ARCH2_WTS_VARIABLES["$GNB3_XN_ADDR"] = "10.0.1.123"
ARCH2_WTS_VARIABLES["$GNB3_X2_ADDR"] = ""
ARCH2_WTS_VARIABLES["$GNB3_S1U_ADDR"] = ""

ARCH2_WTS_VARIABLES["$GNB4_NG_ADDR"] = "10.0.1.124"
ARCH2_WTS_VARIABLES["$GNB4_XN_ADDR"] = "10.0.1.125"

ARCH2_WTS_VARIABLES["$ENB1_S1_ADDR"] = "10.0.1.136"
ARCH2_WTS_VARIABLES["$ENB1_X2_ADDR"] = "10.0.1.137"
ARCH2_WTS_VARIABLES["$ENB1_X2U_ADDR"] = "10.0.1.138"

ARCH2_WTS_VARIABLES["$ENB11_S1_ADDR"] = "10.0.1.139"
ARCH2_WTS_VARIABLES["$ENB11_X2_ADDR"] = "10.0.1.140"
ARCH2_WTS_VARIABLES["$ENB11_X2U_ADDR"] = "10.0.1.141"

ARCH2_WTS_VARIABLES["$AMF_NG_ADDR"] = "10.0.1.1"
ARCH2_WTS_VARIABLES["$AMF2_NG_ADDR"] = "10.0.1.102"
ARCH2_WTS_VARIABLES["$AMF3_NG_ADDR"] = "10.0.1.103"
ARCH2_WTS_VARIABLES["$AMF4_NG_ADDR"] = "10.0.1.104"
ARCH2_WTS_VARIABLES["$AMF5_NG_ADDR"] = "10.0.1.105"
ARCH2_WTS_VARIABLES["$AMF6_NG_ADDR"] = "10.0.1.106"

ARCH2_WTS_VARIABLES["$UPF_ADDR"] = "1.2.4.1"

ARCH2_WTS_VARIABLES["$MME1_S1_ADDR"] = "10.0.1.131"
ARCH2_WTS_VARIABLES["$SGW_S1U_ADDR"] = "10.0.1.133"
ARCH2_WTS_VARIABLES["$SGW_S11_ADDR"] = "10.0.1.134"
ARCH2_WTS_VARIABLES["$PGW_ADDR"] = "4.7.254.207"

ARCH2_WTS_VARIABLES["$UEC_ADDR"] = "72.22.0.1"

#############################################################################################################
# WTS_TEMPLATE
#############################################################################################################
ARCH2_WTS_TEMPLATE = OrderedDict()

ARCH2_WTS_TEMPLATE["5GCN_CONFIGURATION"] = OrderedDict()
ARCH2_WTS_TEMPLATE["5GCN_CONFIGURATION"]["amf_region"] = [
    "set_amf_region id=1 tac_list=0,100,200,222,258,280,788,7627107 plmn=311:489",
    "set_amf_region id=2 tac_list=0,100,200,222,258,280,788,7627107 plmn=311:489",
    "set_amf_region id=3 tac_list=0,100,200,222,258,280,788,7627107 plmn=311:489",
    "set_amf_region id=4 tac_list=0,100,200,222,258,280,788,7627107 plmn=311:489",
    "set_amf_region id=5 tac_list=0,100,200,222,258,280,788,7627107 plmn=311:489",
    "set_amf_region id=6 tac_list=0,100,200,222,258,280,788,7627107 plmn=311:489"]
ARCH2_WTS_TEMPLATE["5GCN_CONFIGURATION"]["amf"] = [
    "set_amf id=1 daemon=$SERVER_IP:$EDAEMON_PORT ng=$AMF_NG_ADDR:38412 region=1 set_id=2 pointer=2",
    "set_amf id=2 daemon=$SERVER_IP:$EDAEMON_PORT ng=$AMF2_NG_ADDR:38412 region=2 set_id=2 pointer=2",
    "set_amf id=3 daemon=$SERVER_IP:$EDAEMON_PORT ng=$AMF3_NG_ADDR:38412 region=3 set_id=2 pointer=2",
    "set_amf id=4 daemon=$SERVER_IP:$EDAEMON_PORT ng=$AMF4_NG_ADDR:38412 region=4 set_id=2 pointer=2",
    "set_amf id=5 daemon=$SERVER_IP:$EDAEMON_PORT ng=$AMF5_NG_ADDR:38412 region=5 set_id=2 pointer=2",
    "set_amf id=6 daemon=$SERVER_IP:$EDAEMON_PORT ng=$AMF6_NG_ADDR:38412 region=6 set_id=2 pointer=2"]
ARCH2_WTS_TEMPLATE["5GCN_CONFIGURATION"]["amf_param"] = [
    "amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc",
    "amf_param id=2 full_nas_auth=on ims_voice_3gpp=on nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc",
    "amf_param id=3 full_nas_auth=on ims_voice_3gpp=on nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc",
    "amf_param id=4 full_nas_auth=on ims_voice_3gpp=on nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc",
    "amf_param id=5 full_nas_auth=on ims_voice_3gpp=on nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc",
    "amf_param id=6 full_nas_auth=on ims_voice_3gpp=on nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc"]
ARCH2_WTS_TEMPLATE["5GCN_CONFIGURATION"]["upf"] = [
    "set_upf id=1 daemon=$SERVER_IP:$EDAEMON_PORT type=simulated addr=$UPF_ADDR/24 ngu=$AMF_NG_ADDR "
    "ngu_read_packets_threshold=10 ngu_snd_buff_size=20M ngu_rcv_buff_size=20M"]

ARCH2_WTS_TEMPLATE["GNB2_CONFIGURATION"] = OrderedDict()
ARCH2_WTS_TEMPLATE["GNB2_CONFIGURATION"]["gnb"] = []
ARCH2_WTS_TEMPLATE["GNB2_CONFIGURATION"]["cell"] = []

ARCH2_WTS_TEMPLATE["Simualtor_GNB3_TDD"] = OrderedDict()    # For Simulator GNB3
ARCH2_WTS_TEMPLATE["Simualtor_GNB3_TDD"]["gnb"] = [
    "set_gnb id=3 type=simulated gnb_id=0x23:22 plmn=311:489 ng=$GNB3_NG_ADDR daemon=$DAEMON_IP:$DAEMON_PORT "
    "x2_peers=none xn=$GNB3_XN_ADDR nssai=0x1:0xd143a5 amf=1"]
ARCH2_WTS_TEMPLATE["Simualtor_GNB3_TDD"]["gnb_param"] = [
    "gnb_param id=3 xn_listening_socket=1 send_xn_setup=false"]
ARCH2_WTS_TEMPLATE["Simualtor_GNB3_TDD"]["cell"] = [
    "set_cell id=1 gnb=3 pci=127:0 tdd_cell=on gscn=6414 tac=200 proxy=$PROXY_SERVER5_IP:9999 nrci=0x01 "
    "nr_arfcn=513234:513234 mandatory_for_activation=off"]

ARCH2_WTS_TEMPLATE["GNB3_CONFIGURATION"] = OrderedDict()    # For Real GNB3

ARCH2_WTS_TEMPLATE["Simualtor_GNB4_FDD"] = OrderedDict()
ARCH2_WTS_TEMPLATE["Simualtor_GNB4_FDD"]["gnb"] = [
    "set_gnb id=4 type=simulated gnb_id=0x24:22 plmn=311:489 ng=$GNB4_NG_ADDR daemon=$SERVER_IP:$EDAEMON_PORT "
    "x2_peers=none xn=$GNB4_XN_ADDR nssai=0x1:0xd143a5 amf=1"]
ARCH2_WTS_TEMPLATE["Simualtor_GNB4_FDD"]["gnb_param"] = [
    "gnb_param id=4 xn_listening_socket=1 send_xn_setup=false"]
ARCH2_WTS_TEMPLATE["Simualtor_GNB4_FDD"]["cell"] = [
    "set_cell id=1 gnb=4 pci=127:1 tdd_cell=off gscn=1590 tac=200 proxy=$PROXY_SERVER4_IP:9999 nrci=0x01 "
    "nr_arfcn=135000:127200 mandatory_for_activation=off"]

ARCH2_WTS_TEMPLATE["Simualtor_ENB1_FDD"] = OrderedDict()
ARCH2_WTS_TEMPLATE["Simualtor_ENB1_FDD"]["enb"] = [
    "set_enb id=1 type=simulated plmn=311:489 s1=$ENB1_S1_ADDR enb_id_macro=0x12346 "
    "daemon=$CONTAINER_IP:$EDAEMON_PORT x2=$ENB1_X2_ADDR x2u=$ENB1_X2U_ADDR x2_peers=all"]
ARCH2_WTS_TEMPLATE["Simualtor_ENB1_FDD"]["enb_param"] = [
    "enb_param id=1 drb_id_begin=3 endc_capable_qci=all"]
ARCH2_WTS_TEMPLATE["Simualtor_ENB1_FDD"]["enb_endc_param"] = [
    "enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14"]
ARCH2_WTS_TEMPLATE["Simualtor_ENB1_FDD"]["cell"] = [
    "set_cell id=1 enb=1 eci=0x1234601 pci=4:0 tac=200 proxy=$CONTAINER_IP:12219|$CONTAINER_IP:8889 "
    "earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off",
    "set_cell id=2 enb=1 eci=0x1234602 pci=4:1 tac=200 proxy=$CONTAINER_IP:12220|$CONTAINER_IP:8890 earfcn=2000:20000 "
    "mapped_earfcn=4200:22200 mandatory_for_activation=off"]

ARCH2_WTS_TEMPLATE["Simualtor_ENB11_FDD"] = OrderedDict()
ARCH2_WTS_TEMPLATE["Simualtor_ENB11_FDD"]["enb"] = [
    "set_enb id=11 type=simulated plmn=311:489 s1=$ENB11_S1_ADDR enb_id_macro=0x12347 "
    "daemon=$CONTAINER_IP:$EDAEMON_PORT x2=$ENB11_X2_ADDR x2u=$ENB11_X2U_ADDR x2_peers=none"]
ARCH2_WTS_TEMPLATE["Simualtor_ENB11_FDD"]["enb_param"] = [
    "enb_param id=11 drb_id_begin=3 endc_capable_qci=all"]
ARCH2_WTS_TEMPLATE["Simualtor_ENB11_FDD"]["enb_endc_param"] = [
    "enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14"]
ARCH2_WTS_TEMPLATE["Simualtor_ENB11_FDD"]["cell"] = [
    "set_cell id=1 enb=11 eci=0x1234701 pci=7:0 tac=222 proxy=$CONTAINER_IP:12217|$CONTAINER_IP:8887 "
    "earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off"]

ARCH2_WTS_TEMPLATE["4G_EPC_CONFIGURATION"] = OrderedDict()
ARCH2_WTS_TEMPLATE["4G_EPC_CONFIGURATION"]["mme_pool_area"] = [
    "mme_pool_area id=1 mmegi=1 plmn=311:489 eq_plmn=250:255 tac_list=111,200,210,222,333,444,777,4580",
    "mme_pool_area id=2 mmegi=2 plmn=311:489 tac_list=111,200,210,222,333,444,777,4580",
    "mme_pool_area id=3 mmegi=3 plmn=311:489 tac_list=111,200,210,222,333,444,777,4580"]
ARCH2_WTS_TEMPLATE["4G_EPC_CONFIGURATION"]["mme"] = [
    "set_mme id=1 ip=$CONTAINER_IP:$EDAEMON_PORT s1=$MME1_S1_ADDR:36412 "
    "supported_rat=lte,nblte pool=1:1 pool=2:3 pool=3:4"]
ARCH2_WTS_TEMPLATE["4G_EPC_CONFIGURATION"]["sgw"] = [
    "set_sgw id=1 ip=$CONTAINER_IP:$EDAEMON_PORT s1u=$SGW_S1U_ADDR s11=$SGW_S11_ADDR:2153 s5u_snd_buff_size=20M "
    "s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10"]
ARCH2_WTS_TEMPLATE["4G_EPC_CONFIGURATION"]["pgw"] = [
    "set_pgw id=1 type=simulated ip=$CONTAINER_IP:$EDAEMON_PORT addr=$PGW_ADDR/16 apn=lteapn1.com.mnc69.mcc450.gprs"]

ARCH2_WTS_TEMPLATE["UEC_CONFIGURATION"] = OrderedDict()
ARCH2_WTS_TEMPLATE["UEC_CONFIGURATION"]["uec"] = [
    "set_uec id=1 ip=$CONTAINER_IP:$EDAEMON_PORT daemon=$CONTAINER_IP:$EDAEMON_PORT peer=$CONTAINER_IP:2152 "
    "retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=$UEC_ADDR/26 proxy_read_packets_threshold=10 "
    "proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520"]

ARCH2_WTS_TEMPLATE["SA_UE_CONFIGURATION"] = OrderedDict()
ARCH2_WTS_TEMPLATE["SA_UE_CONFIGURATION"]["ue"] = []
ARCH2_WTS_TEMPLATE["SA_UE_CONFIGURATION"]["ue_param"] = []

ARCH2_WTS_TEMPLATE["NSA_UE_CONFIGURATION"] = OrderedDict()
ARCH2_WTS_TEMPLATE["NSA_UE_CONFIGURATION"]["ue"] = []
ARCH2_WTS_TEMPLATE["NSA_UE_CONFIGURATION"]["ue_param"] = []
ARCH2_WTS_TEMPLATE["NSA_UE_CONFIGURATION"]["bearer"] = []

ARCH2_WTS_TEMPLATE["CA_SA_UE_CONFIGURATION"] = OrderedDict()
ARCH2_WTS_TEMPLATE["CA_SA_UE_CONFIGURATION"]["ue"] = []
ARCH2_WTS_TEMPLATE["CA_SA_UE_CONFIGURATION"]["ue_param"] = []

ARCH2_WTS_TEMPLATE["CA_NSA_UE_CONFIGURATION"] = OrderedDict()
ARCH2_WTS_TEMPLATE["CA_NSA_UE_CONFIGURATION"]["ue"] = []
ARCH2_WTS_TEMPLATE["CA_NSA_UE_CONFIGURATION"]["ue_param"] = []
ARCH2_WTS_TEMPLATE["CA_NSA_UE_CONFIGURATION"]["bearer"] = []

# WTS_TEMPLATE["Bearer_CONFIGURATION"] = OrderedDict()
# WTS_TEMPLATE["Bearer_CONFIGURATION"]["bearer"] = []

ARCH2_WTS_TEMPLATE["COMMON_CONFIGURATION"] = OrderedDict()
ARCH2_WTS_TEMPLATE["COMMON_CONFIGURATION"]["qosflow"] = []
ARCH2_WTS_TEMPLATE["COMMON_CONFIGURATION"]["qosrule"] = []
ARCH2_WTS_TEMPLATE["COMMON_CONFIGURATION"]["nwslice"] = []
ARCH2_WTS_TEMPLATE["COMMON_CONFIGURATION"]["pdu_gateway"] = []

ARCH2_WTS_TEMPLATE["MODIFY_ADD_CONFIGURATION"] = OrderedDict()
ARCH2_WTS_TEMPLATE["MODIFY_ADD_CONFIGURATION"]["new_add"] = []

# ############################################################################################################
# END_CONFIGURATION
# ############################################################################################################
ARCH2_END_CONFIGURATION = [
    "debug_log level=2",
    "sim_debug_log level=2",
    "sim_debug_log level=2 mme=1",
    "sim_debug_log level=2 uec=1",
    "sim_debug_log level=2 pgw=1",
    "sim_debug_log level=2 sgw=1",
    "trace enb=1 protocol=x2 on",
    "trace uec=1 protocol=x2 on",

    "link_ctrl_param use_hb=off hb_period=5 hb_retries=5",
    "trace uec=1 protocol=rrc on",
    "trace uec=1 protocol=nr_rrc on",
    "sim_trace uec=1 protocol=nr_rrc on",
    "sim_trace amf=1 protocol=ng on",
    "cfg_end",
    "set_log log_to_file=on",
    "start version_check=off",
    "sim_trace uec=1 protocol=nr_rrc on",
    "sim_trace amf=1 protocol=ng on"]

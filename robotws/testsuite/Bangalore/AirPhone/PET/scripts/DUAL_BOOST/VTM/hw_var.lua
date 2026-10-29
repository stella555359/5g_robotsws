
---CELL_AMF Related param-------------------
PLMN="311:489"
TAC="200"
NSSAI="0x1:0xd143a5"
SNSSAI="0x01:0xD143A5"
START_SA_CELLID = 1

LCRID1="1"
LCRID2="2"
LCRID3="3"
LCRID4="4"
LCRID5="5"
LCRID6="6"
LCRID7="7"
LCRID8="8"
LCRID9="9"
LCRID10="10"
LCRID11="11"
LCRID12="12"

PCI1="16:2"
PCI2="17:0"
PCI3="17:1"
PCI4="17:2"
PCI5="18:0"
PCI6="18:1"
PCI7="18:2"
PCI8="19:0"
PCI9="19:1"
PCI10="19:2"
PCI11="20:0"
PCI12="20:1"

GSCN1="7880"
GSCN2="7950"
GSCN3="8019"

NRARFCN1="636666:636666"
NRARFCN2="643330:643330"
NRARFCN3="649994:649994"

NGNBPCI1="18:2"
NGNBPCI2="19:0"
NGNBPCI3="19:1"

NGNB_ID1="0x03"
NGNB_ID2="0x04"
NGNB_ID3="0x05"

SPCI_1 = 50
SPCI_2 = 51
SPCI_3 = 52
SPCI_4 = 53
SPCI_5 = 54
SPCI_6 = 55

NPCI_1 = 56
NPCI_2 = 57
NPCI_3 = 58

NRBAND1="78"

AMF_REGION_ID1 = 1
AMF_SET_ID1 = 2
AMF_POINTER_ID1 = 2
AMF_REGION_ID2 = 2
AMF_SET_ID2 = 3
AMF_POINTER_ID2 = 3
AMF_REGION_ID3 = 3
AMF_SET_ID3 = 4
AMF_POINTER_ID3 = 4
AMF_REGION_ID4 = 4
AMF_SET_ID4 = 5
AMF_POINTER_ID4 = 5
AMF_REGION_ID5 = 5
AMF_SET_ID5 = 6
AMF_POINTER_ID5 = 6
----IP Config---------------------------
os.execute('sudo ip addr add 10.0.2.3/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.4/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.5/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.6/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.7/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.8/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.9/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.10/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.11/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.12/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.13/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.14/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.15/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.16/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.17/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.18/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.19/24 dev eth4')
os.execute('sudo ip addr add 10.0.2.20/24 dev eth4')

os.execute('sudo ip addr add 10.0.1.61/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.62/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.63/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.64/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.200/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.201/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.202/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.203/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.204/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.205/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.206/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.218/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.219/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.220/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.236/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.237/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.238/24 dev eth3')

os.execute('sudo ip addr add 10.0.1.131/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.132/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.133/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.134/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.135/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.136/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.137/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.138/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.139/24 dev eth3')
----------------------------------------------------------------
os.execute('sudo sysctl net.sctp.rto_min=100')
----------------------------------------
-----APPLICATION IPs and ports------------------
----Southe Bound IPs--------------
CONTAINER_IP="10.0.2.1"
DAEMON_IP=CONTAINER_IP
SERVER_IP=CONTAINER_IP
SERVER_IP2="10.0.2.3"
SERVER_IP3="10.0.2.4"
SERVER_IP4="10.0.2.5"
SERVER_IP5="10.0.2.6"
SERVER_IP6="10.0.2.7"
SERVER_IP7="10.0.2.8"
SERVER_IP8="10.0.2.9"
SERVER_IP9="10.0.2.10"
SERVER_IP10="10.0.2.11"
SERVER_IP11="10.0.2.12"
SERVER_IP12="10.0.2.13"
SERVER_IP13="10.0.2.14"
SERVER_IP14="10.0.2.15"
SERVER_IP15="10.0.2.16"
SERVER_IP16="10.0.2.17"
SERVER_IP17="10.0.2.18"
SERVER_IP18="10.0.2.19"
SERVER_IP19="10.0.2.20"


UEC_ADDR="72.21.0.1"
UEC2_ADDR="72.23.0.1"
UEC3_ADDR="72.24.0.1"
UEC4_ADDR="72.25.0.1"
UEC5_ADDR="72.26.0.1"
UEC6_ADDR="72.27.0.1"
UEC7_ADDR="72.28.0.1"
UEC8_ADDR="72.29.0.1"

PROXY_SERVER_IP="10.0.2.80"
PROXY_SERVER_IP2="10.0.2.90"
---END OF SOUTH BOUND IPs--------------
------NORTH BOUND IPs-----
AMF_NG_ADDR="10.0.1.1"
AMF2_NG_ADDR="10.0.1.61"
AMF3_NG_ADDR="10.0.1.62"
AMF4_NG_ADDR="10.0.1.63"
AMF5_NG_ADDR="10.0.1.64"

UPF_ADDR="1.2.0.1"
UPF2_ADDR="1.2.8.1"
UPF3_ADDR="1.2.24.1"
UPF4_ADDR="1.2.32.1"
UPF5_ADDR="1.2.40.1"

GNB_S1U_ADDR="10.0.1.112"
GNB_X2_ADDR="10.0.1.2"
GNB_XN_ADDR="10.0.1.2"
GNB_NG_ADDR="10.0.1.2"


--LTE definitions
MME1_S1_ADDR="10.0.1.131"
SERVER_ADDR="10.0.1.132"
SGW_S1U_ADDR="10.0.1.133"
SGW_S11_ADDR="10.0.1.134"
ENB_X2U_ADDR="10.0.1.135"
ENB1_X2_ADDR="10.0.1.136"
ENB1_S1_ADDR="10.0.1.137"
SGW2_S1U_ADDR="10.0.1.138"
SGW2_S11_ADDR="10.0.1.139"
PGW_ADDR="4.7.0.254"
PGW2_ADDR="4.7.128.254"

PDN_IP="4.7.0.253"
PDN_IP2="4.7.100.253"
PDN_IP3="4.7.150.253"
PDN_IP4="4.7.200.253"

--gNBSim-
GNB3_XN_ADDR="10.0.1.201"
GNB3_NG_ADDR="10.0.1.202"
GNB4_XN_ADDR="10.0.1.203"
GNB4_NG_ADDR="10.0.1.204"
GNB5_XN_ADDR="10.0.1.205"
GNB5_NG_ADDR="10.0.1.206"
---END OF NORTH BOUND IPs----

--EDAMON and DEMON PORTS---                                              
EDAEMON_PORT="22222"
DAEMON_PORT=22222
----------------------------------------------------------------------
HO_Enabled = 'yes'
VTM_RUN_DURATION = '2Hrs'
UE_STATE_TRANSITION = '8225'
NG_PAGING = 'FAKE'
RNA_UPDATE = '!T380'
initial_delay = 300
----UE ID RANGE and ITS ASSOCIATED PARAM CONFIG-----
FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA = 1
LAST_INTRA_gNB_INTRA_FREQ_HO_UE_SA = FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA + 102
FIRST_INTRA_gNB_INTER_FREQ_HO_UE_SA = LAST_INTRA_gNB_INTRA_FREQ_HO_UE_SA + 1
LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA = FIRST_INTRA_gNB_INTER_FREQ_HO_UE_SA + 22
FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA = LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA + 1
LAST_INTER_gNB_INTRA_FREQ_HO_UE_SA = FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA + 65
FIRST_INTER_gNB_INTER_FREQ_HO_UE_SA = LAST_INTER_gNB_INTRA_FREQ_HO_UE_SA + 1
LAST_INTER_gNB_INTER_FREQ_HO_UE_SA = FIRST_INTER_gNB_INTER_FREQ_HO_UE_SA + 13
FIRST_CA_SCELL_ADD_UE_SA = LAST_INTER_gNB_INTER_FREQ_HO_UE_SA + 1
LAST_CA_SCELL_ADD_UE_SA = FIRST_CA_SCELL_ADD_UE_SA + 844
FIRST_CA_SCELL_ADD_DEL_UE_SA = LAST_CA_SCELL_ADD_UE_SA + 1
LAST_CA_SCELL_ADD_DEL_UE_SA = FIRST_CA_SCELL_ADD_DEL_UE_SA + 138
FIRST_ADITIONAL_DRB_ADD_UE_SA = LAST_CA_SCELL_ADD_DEL_UE_SA + 1
LAST_ADITIONAL_DRB_ADD_UE_SA  = FIRST_ADITIONAL_DRB_ADD_UE_SA + 35
FIRST_VONR_DRB_ADD_UE_SA = LAST_ADITIONAL_DRB_ADD_UE_SA + 1
LAST_VONR_DRB_ADD_UE_SA = FIRST_VONR_DRB_ADD_UE_SA + 96
FIRST_ATTACH_DETACH_UE_SA = LAST_VONR_DRB_ADD_UE_SA + 1
LAST_ATTACH_DETACH_UE_SA = FIRST_ATTACH_DETACH_UE_SA + 598
FIRST_TAU_UPDATE_UE_SA = LAST_ATTACH_DETACH_UE_SA + 1
LAST_TAU_UPDATE_UE_SA = FIRST_TAU_UPDATE_UE_SA + 26
FIRST_NGPAGING_UE_SA = LAST_TAU_UPDATE_UE_SA + 1
LAST_NGPAGING_UE_SA = FIRST_NGPAGING_UE_SA + 2657
FIRST_STATE_TRASITION_UE_SA = LAST_NGPAGING_UE_SA + 1
LAST_STATE_TRASITION_UE_SA = FIRST_STATE_TRASITION_UE_SA + 475
FIRST_RNA_UPDATE_UE_SA = LAST_STATE_TRASITION_UE_SA + 1
LAST_RNA_UPDATE_UE_SA = FIRST_RNA_UPDATE_UE_SA + 2094
FAKE_PAGING_UE_SA = LAST_RNA_UPDATE_UE_SA + 1
IMSI_1 = 21640000
QOS_ID = 2
----------------------------------------------------------------------------------------


author = "Thomas Vieille"
team = "MN 5G&SC Pz 5G I&V 1 NPS 2 SG"
email = "thomas.vieille@nokia.com"
version_of_taf_model = 5

# Teams NPS IV
#
# Tribe 1 Chadi Tarhini
# IV1 SG1 Uplane Val&Opt (Hassan Zeryouh)                       : MN 5G&SC Pz 5G I&V 1 NPS 1 SG
# IV1 SG2 OAM & Trsp & Adv (Sebastien Borowiec)                 : MN 5G&SC Pz 5G I&V 1 NPS 2 SG
# IV1 SG3 Radio Perf (Mikael Morand)                            : MN 5G&SC Pz 5G I&V 1 NPS 3 SG
# IV1 SG4 SiSo RF & Mobility (Marc Billemaz)                    : MN 5G&SC Pz 5G I&V 1 NPS 4 SG
# IV1 SG5 RRM & IODT (Mariana Dirani)                           : MN 5G&SC Pz 5G I&V 1 NPS 5 SG
#
# Tribe 2 Marta Porthilo
# IV2 SG1 RRM (Olivier Durox)                                   : MN 5G&SC Pz 5G I&V 2 NPS 1 SG
# IV2 SG2 Transp OAM RRM (Pierre-Yves Fauvernier)               : MN 5G&SC Pz 5G I&V 2 NPS 2 SG
# IV2 SG3 New Product Introduction (Pascal Morisset)            : MN 5G&SC Pz 5G I&V 2 NPS 3 SG
# IV2 SG4 SISO RF (Marine Nadjo)                                : MN 5G&SC Pz 5G I&V 2 NPS 4 SG
# IV2 SG5 Icebreaker (Sofiane Chekir)                           : MN 5G&SC Pz 5G I&V 2 NPS 5 SG
#
# Tribe 6 Eric Ortiz
# IV6 SG1 Virtual, Cloud & Auto (Pascal Girard)                 : MN 5G&SC Pz 5G I&V 6 NPS 1 SG
# IV6 SG2 RRM interactions (Laurent Valette)                    : MN 5G&SC Pz 5G I&V 6 NPS 2 SG
# IV6 SG3 (Aminou Issoudou Adamou)                              : MN 5G&SC Pz 5G I&V 6 NPS 3 SG
# IV6 SG4 (Djilali Boubakeur)                                   : MN 5G&SC Pz 5G I&V 6 NPS 4 SG
# IV6 SG5 FDD & RRM (Audrey Hallegouet)                         : MN 5G&SC Pz 5G I&V 6 NPS 5 SG

gNB_Type = "CLASSICAL"  # 'CLOUD' or 'CLASSICAL'
UE = "NONE"  # 'NONE', 'PRISMA', 'VIAVI', 'AIRPHONE' or 'QCT'
eNB = "REAL"  # 'NONE', 'PRISMA', 'REAL' or 'LTEEMU'
ePC = "REAL"  # 'NONE', 'PRISMA', 'REAL' or 'EPCSIM'

##################
#                #
#       VM       #
#                #
##################

test_VM = {
    "Address IP": "10.14.39.156",
    "Username": "localuser",
    "Password": "10c@1user",
}

VM_UTE = {
    "Address IP": "",
    "Username": "",
    "Password": "",
}

##################
#                #
#  PRODUCT PART  #
#                #
##################

# DUs and RUs
##############

dus = [
    {  #   DU#1
        "ATEN Address IP": "10.28.1.78",  # IP address of power switch for Airsclale if used else empty.
        "ATEN Port Number": "1",  # Port of power switch for Airsclale if used else empty.
        "RACK LEFT": {
            "lmp Address IP": "192.168.255.1",
            "ASIK Factory IP": "192.168.255.129",
            "Username": "toor4nsn",
            "Password": "oZPS0POrRieRtu",
            # Side ROCK LEFT:
            #   Address: ABIL #1 192.168.253.20 - ABIL #2 192.168.253.24 - ABIL #3 192.168.253.28
            #   Position can be B1, B2 or B3
            # Side ROCK RIGHT:
            #   Address: ABIL #1 192.168.253.36 - ABIL #2 192.168.253.40 - ABIL #3 192.168.253.44
            #   Position can be B4, B5 or B6
            "ABIL": [
                {
                    "IP Address": "192.168.253.20",
                    "Position": "B1",
                },
                {
                    "IP Address": "192.168.253.24",
                    "Position": "B2",
                },
                {
                    "IP Address": "192.168.253.28",
                    "Position": "B3",
                },
            ],
            "RUS": [],
        },
    },
]

# OAM
######

OAM = {
    "Backhaul site OAM IP": "10.14.49.34",
    "SSH Connection": {
        "Address IP": "10.14.49.34",
        "Username": "toor4nsn",
        "Password": "oZPS0POrRieRtu",
    },
    "OAM HTTP Connection": {
        "Address IP": "10.14.49.34",
        "Username": "Nemuadmin",
        "Password": "nemuuser",
        "Port": "443",
    },
}

OAM_Server = {
    "Type OAM": "",  # 'NETACT' or 'SAM'
    "Address IP": "",  # for 'NETACT' is VM was1 Address; for 'SAM' is NPS address
    "VM was2 Address": "",
    "VM ne3s Address": "",
    "Port Numnber": "",  # for 'SAM' is NPS Port
    "OMC Username": "",
    "OMC Password": "",
    "root Password": "",
    "GUI url": "",
    "GUI Username": "",
    "GUI Password": "",
}

# Other
#########

tl_number = 367
vnf_name = ""
GNB_nr_bts = 0
MRBTS = 0
cells = [
    {
        "Cell ID": "0",
        "nrArfcn": "0",
    },
]

################
#              #
#  iPERF PART  #
#              #
################

iPerf_CN_Side = {
    "Address IP": "",
    "Username": "",
    "Password": "",
    "Network Interface Address": "",
    "iPerf Path": "",
    "Port": "",
}

iPerf_UE_Side = {
    "Address IP": "",
    "Username": "",
    "Password": "",
    "Network Interface Address": "",
    "iPerf Path": "",
    "Port": "",
}

########################
#                      #
#  CUSTOMIZATION PART  #
#                      #
########################

# It is possible to add specific keys in custom dictionary in __init__.py file
# Key must be an string
# Value must: None, boolean, integer, float, string (simple <'xxx'> or raw <r'xxxx'>, binary <b'xxxx'>
#             list of simple types as
#                  None, boolean, integer, float, string (simple <'xxx'> or raw <r'xxxx'>, binary <b'xxxx'>
#             dictionary of simple types as
#                  None, boolean, integer, float, string (simple <'xxx'> or raw <r'xxxx'>, binary <b'xxxx'>
Customization = {
    "NUMBER_OF_CONTAINER": "12",
    "NUMBER_OF_BBMOD": "1",
    "NUMBER_OF_RMOD": "3",
    "NUMBER_OF_NRCELL": "3",
    "RMOD0_VM": "10.14.60.254",
    "RMOD1_VM": "10.14.60.255",
    "RMOD2_VM": "10.14.61.0",
    "RMOD3_VM": "192.168.253.17",
    "ASIK_IP_XEONB": "192.168.253.17",
    "PDU_MODEL": "aten",
    "PDU_username": "teladmin",
    "PDU_password": "telpwd",
    "PDU_PORT_ASIA": "2",
    "PDU_PORT_RMOD": "3",
    "DEVICE_MASTER_IP": "10.28.1.213",
    "DEVICE_MASTER_PORT_ASIKMASTER": "8001",
    "DEVICE_MASTER_PORT_ASIKPICASSO": "8002",
    "DEVICE_MASTER_PORT_ASIKSLAVE": "8003",
    "DEVICE_MASTER_PORT_ABIL1MASTER": "8004",
    "DEVICE_MASTER_PORT_ABIL1BMU": "8006",
    "DEVICE_MASTER_PORT_ABIL1SLAVE": "8005",
    "DEVICE_MASTER_PORT_ABIL1LONER": "8007",
    "ASIA_IP_OAM": "10.14.49.204",
    "ASIA_username": "toor4nsn",
    "ASIA_password": "oZPS0POrRieRtu",
    "4G_TEST_VM_IP": "10.14.38.251",
    "TL_RMOD": "AHLOA",
    "TL_FB": "n71",
    "TL_SECTOR": "3",
    "TL_CC": "1CC",
    "SNAPSHOT_TIMEOUT": "600",
    "TEST_FAILED_LOG_COLLECTION_TIMER": "280",
    "LNADJGNB_DN_eNB": "MRBTS-4367/LNBTS-22228/LNADJGNB-0",
    "KPI_1A_NUMBER_OF_TESTS_NEEDED": "34",
    "KPI_1A_AVG_TARGET": "540",
    "KPI_1A_MAX_TARGET": "648",
    "KPI_1A_SR_TARGET": "95",
    "KPI_3_NUMBER_OF_TESTS_NEEDED": "34",
    "KPI_3_AVG_TARGET": "540",
    "KPI_3_MAX_TARGET": "648",
    "KPI_3_SR_TARGET": "95",
    "KPI_51_NUMBER_OF_TESTS_NEEDED": "100",
    "KPI_51_AVG_TARGET": "120",
    "KPI_51_MAX_TARGET": "144",
    "KPI_51_SR_TARGET": "97",
    "QC_KPI_1A": "QC_385595",
    "QC_KPI_61A": "QC_385596",
    "QC_KPI_3": "QC_385597",
    "QC_KPI_63": "QC_385598",
    "QC_KPI_51": "QC_385599",
    "QC_KPI_651": "QC_385600",
    "RFSHARINGENABLED": True,
    "DEDICATEDENB": True,
    "REALCORENETWORKUSED": True,
}

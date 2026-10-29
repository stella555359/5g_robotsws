# GoldenSCF_ON_GIT = "/opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/7_5_UTE5G402T1112/"

STREAM_INFOs = {
    'SBTS00_ENB_9999': {'StreamPrefix': 'SBTSTRUNK', 'GoldenSCF': '/TL1112_GoldenSCF_4Cells_v2.xml'}
    }

TLCommonConfig = {
    "MultiUECFG": {
        "0": {  # ue0
            "detach_request": True,
            "power_reset": "true",
        },
    },
}


CASE_INPUT_5GC000829 = {
   'dcap_server_ip': 'host-10-70-230-71',
   'dcap_server_port': '443',
   'cellIndexOfPrimary': [1, 2],
   'cellIndexOfSecondary': [3, 4],
   '829_A_009': {'BBMODs_Reset': [
                                   {'index': 3, 'Rus': [{'index': 3, 'Cells': [{'index': 3}]}]},
                                   {'index': 4, 'Rus': [{'index': 4, 'Cells': [{'index': 4}]}]}
                               ],
                 'RMODs_Reset': [
                                 {'index': 3, 'Cells': [{'index': 3}]},
                                 {'index': 4, 'Cells': [{'index': 4}]}
                              ],
                 'RMODs_LockAndUnlock': [
                                        {'index': 3, 'Cells': [{'index': 3}]},
                                        {'index': 4, 'Cells': [{'index': 4}]}
                                      ],
                 'CELLs_LockAndUnlock': [{'index': 3}, {'index': 4}]
                 },
   '829_A_010': {'nrcell': '1'},
   '829_A_021': {'call_cell_index': 1, 'lock_unlock_cell_index': []},
   '829_A_022': {'call_cell_index': 4, 'lock_unlock_cell_index': [1, 2, 3]},
}

TestLineID = '7_5_UTE5G402T1110'
prefix_of_release = '5G_'

CASE_INPUT_5GC002479 = {
    'TLConfiguration': '2ASIB_2ABIO_4ABIL',
    'StreamPrefix': 'SBTS00_ENB_9999',
    # 'NETACT_URL': 'https://na20lbwas.qin1.srnhz.nsn-rdnet.net',
    # 'NETACT_URL': 'https://shanxilbwas.sui6.srnhz.nsn-rdnet.net',
    'NETACT_URL': 'https://gansulbwas.gansu.srnhz.nsn-rdnet.net/',
    'NETACT_USER': 'omc',
    # 'NETACT_PASSWORD':'Nokia123!',
    'NETACT_PASSWORD': 'Nokia126_',
    # 'NETACT_LOGSERVER_IP': '10.107.178.201',
    # 'NETACT_LOGSERVER_IP': '10.110.144.147', #this is shanxi
    # this is gansu
    'NETACT_LOGSERVER_IP': '10.108.248.82',
    'NETACT_LOGSERVER_USERNAME': 'omc',
    'NETACT_LOGSERVER_PASSWORD': 'Nokia126_',
    '5GC002479_HA_KPI1a': {
          'WebUI_reset_times': '5',
          # 'SFPCooledTransceiver':'True',#The value of SFPCooledTransceiver to TL
     },
    '5GC002479_HA_KPI3': {
          'Power_reset_times': '5',
          # 'SFPCooledTransceiver':'True',#The value of SFPCooledTransceiver to TL
     },
    'CB006939_HA_KPI51a': {
          'RF_Reset_Times': '2',
          # 'SFPCooledTransceiver':[
          # 					{'Declaration':'False'},
          # 					{'Declaration':'False'},
          # 					{'Declaration':'True'},
          # 					{'Declaration':'True'},
          # 					{'Declaration':'True'},
          # 					{'Declaration':'True'},
          # 				],#The value of SFPCooledTransceiver to different RMOD,In order from RMOD1
     },
    'CB006939_HA_KPI54a': {
          'RU_Reset_Times': '2',
          # 'SFPCooledTransceiver':[
          # 					{'Declaration':'False'},
          # 					{'Declaration':'False'},
          # 					{'Declaration':'True'},
          # 					{'Declaration':'True'},
          # 					{'Declaration':'True'},
          # 					{'Declaration':'True'},
          # 				],#The value of SFPCooledTransceiver to different RMOD,In order from RMOD1
     },
    '5GC002479_HA_KPI5': {
          # 'SFPCooledTransceiver':[
          # 					{'Declaration':'True'},
          # 					{'Declaration':'True'},
          # 					{'Declaration':'True'},
          # 					{'Declaration':'True'},
          # 					{'Declaration':'True'},
          # 					{'Declaration':'True'},
          # 				],#The value of SFPCooledTransceiver to different BBMOD,In order from BBMOD1
      },
    '5GC002479_IA': {
          'OriginalStream': 'SBTS22R3_ENB_0000',
          'OriginalStreamSCF': 'OriginalStreamSCF.xml',
          'SecondaryUTEVMIP': '10.57.167.209',
          'SecondaryTLName': '7_5_UTE5G402T1112',
          # 'SFPCooledTransceiver':'True',#The value of SFPCooledTransceiver to TL
      },
    '5GC002479_HA_07': {
          'CellLockUnLockDurtion': '40',
      },
}

CASE_INPUT_5GC000732 = {
    '5GC000732': {
                    'StreamPrefix': '5G_',
                    # 'dcap_server_ip':'host-10-70-230-71',
                    # 'dcap_server_port': '443',
                    '5GRU_PA_Ports': [1, 2, 3, 4],
                    'PA_Value_default': 0,
      },
    '5GC000732_A_03': {
                    'PA_Value_1': 0,
                    'PA_Value_2': 70,
     },
    '5GC000732_F_02': {
                    'PA_Value_1': 0,
                    'PA_Value_2': 90,
                    'PA_Value_3': 30,
     },
}

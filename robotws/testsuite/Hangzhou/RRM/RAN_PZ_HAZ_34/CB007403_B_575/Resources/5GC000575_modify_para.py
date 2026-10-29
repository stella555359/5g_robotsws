from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

# ##gnb1###
GNB_BTS_NAME1 = 'MRBTS-' + str(tl.gnbs[1].instance_id)
GNB_NR_BTS_NAME1 = GNB_BTS_NAME1 + '/NRBTS-' + str(tl.gnbs[1].global_bts_id)
GNB_NRPMRNL_Counter = GNB_NR_BTS_NAME1 + '/NRPMRNL-1'
# GNB_CELL1_NAME = GNB_NR_BTS_NAME1 + '/NRCELL-1'
# GNB_CELL2_NAME = GNB_NR_BTS_NAME1 + '/NRCELL-2'

# ##enb1###
LTE_BTS_NAME = 'MRBTS-' + str(tl.enbs[0].instance_id)
LTE_LNBTS_NAME = LTE_BTS_NAME + '/LNBTS-' + str(tl.enbs[0].global_bts_id)
LTE_LNCEL1_NAME = LTE_LNBTS_NAME + '/LNCEL-1'
LTE_LNCEL2_NAME = LTE_LNBTS_NAME + '/LNCEL-2'


enb1_para1 = [dict(dist_name=LTE_LNBTS_NAME, parameter='actHoWoSnChg', value='intraEnbHoEnabled'),
              dict(dist_name=LTE_LNCEL1_NAME, parameter='defaultLnRelGnbCellId', value='4'),
              dict(dist_name=LTE_LNCEL2_NAME, parameter='defaultLnRelGnbCellId', value='4')]

gnb1_para1 = [dict(dist_name=GNB_NR_BTS_NAME1, parameter='actIntraMeNBMobility', value='true'),
              dict(dist_name=GNB_NR_BTS_NAME1, parameter='srb3SupportEnabled', value='false'),
              dict(dist_name=GNB_NRPMRNL_Counter, parameter='miNrX2CC', value='5min')]

gnb1_para2 = [dict(dist_name=GNB_NR_BTS_NAME1, parameter='actIntraMeNBMobility', value='false'),
              dict(dist_name=GNB_NR_BTS_NAME1, parameter='srb3SupportEnabled', value='false'),
              dict(dist_name=GNB_NRPMRNL_Counter, parameter='miNrX2CC', value='5min')]

case4_filter = ['(x2ap.procedureCode == 27) && (x2ap.X2AP_PDU == 0)',
                '(x2ap.procedureCode == 27) && (x2ap.X2AP_PDU == 1)',
                '(x2ap.procedureCode == 29) && (x2ap.X2AP_PDU == 0)',
                '(x2ap.procedureCode == 29) && (x2ap.X2AP_PDU == 2)']

case4_para_dict = [{'SgNBSecurityKey': 'SgNBSecurityKey', 'meNB-DL-GTP-TEIDatMCG': 'gTP-TEID'},
                   {'sgNB-UL-GTP-TEIDatPDCP': 'gTP-TEID'},
                   {'sgNB-SecurityKey': 'sgNB-SecurityKey', 'meNB-DL-GTP-TEIDatMCG': 'gTP-TEID',
                    'Cause: radioNetwork': 'radioNetwork'},
                   {'Cause: misc': 'misc'}]

case7_filter = ['(x2ap.procedureCode == 27) && (x2ap.X2AP_PDU == 0)',
                '(x2ap.procedureCode == 27) && (x2ap.X2AP_PDU == 1)',
                '(x2ap.procedureCode == 29) && (x2ap.X2AP_PDU == 0)',
                '(x2ap.procedureCode == 29) && (x2ap.X2AP_PDU == 1)']

case7_para_dict = [{'SgNBSecurityKey': 'SgNBSecurityKey', 'meNB-DL-GTP-TEIDatMCG': 'gTP-TEID'},
                   {'sgNB-UL-GTP-TEIDatPDCP': 'gTP-TEID'},
                   {'sgNB-SecurityKey': 'sgNB-SecurityKey', 'meNB-DL-GTP-TEIDatMCG': 'gTP-TEID',
                    'Cause: radioNetwork': 'radioNetwork'},
                   {'sgNB-UL-GTP-TEIDatPDCP': 'gTP-TEID'}]

# structure_para2 = [dict(dist_name=LTE_LNCEL2_NAME,
#                         parameter='remoteSyslogConfig',
#                         value=[{'remoteSyslogServerIPaddress': '10.57.157.245',
#                         'remoteSyslogServerPortNo': '51000'}])]
# keywords_list1 = ['TRBLCADM_A-1']

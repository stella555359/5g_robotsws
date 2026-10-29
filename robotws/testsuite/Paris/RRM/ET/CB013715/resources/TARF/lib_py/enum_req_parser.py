

def return_allowedPdcchPowerBoostALDue_enum(key=0):
    config = {0: 'None', 1: 'AL2', 2: 'AL4', 3: 'AL2_AL4'}
    return config[key]


def return_UeAddCause_enum(key=0):
    config = {0: 'INITIALACCESS', 1: 'RRCREESTABLISHMENT', 2: 'HANDOVER', 3: 'UEADDWITHOUTRACH',
              4: 'BEAMCHANGE', 5: 'BEAMRECOVERY', 6: 'SGNBADDITION', 7: 'INTRADUHANDOVER',
              8: 'INTRACELLHANDOVER', 9: 'SCELLADDITION', 10: 'INITIALACCESSSGNBADDITION',
              11: 'INITIALACCESSNRDCSNODEADDITION', 12: 'RESUMEREQUEST'}
    return config[key]

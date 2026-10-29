
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'
TCEADM = MR_BTS_NAME + '/MNL-1/TCEADM-1'
TCE = MR_BTS_NAME + '/MNL-1/TCEADM-1/TCE-1'
NRMTRACECU = MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1'
NRMTRACEDU = MR_NR_BTS_NAME + '/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1'
NRRESOURCECU = NRMTRACECU + '/NRRESOURCECU-1'
NRRESOURCEDU = NRMTRACEDU + '/NRRESOURCEDU-1'
TIMEZONE = MR_BTS_NAME + '/MNL-1/MNLENT-1/SYNC-1/TIME-1'
TCE_IP = str(tl.test_pcs[0].default_ssh_connection_details.addr)
NRCTRLTS = MR_NR_BTS_NAME + '/NRCTRLTS-1'
NRMTRACECU = NRCTRLTS + '/NRMTRACECU-1'

DU_TIMEZONE_SCF = [dict(value='(GMT+8) Asia/Shanghai', dist_name=TIMEZONE, p_name='timeZone')]

TCEADM_OBJ = {
    TCEADM: {},
    TCE: {'tceIdentifier': '1', 'tceIpAddress': TCE_IP, 'tcePortNumber': '49151'}}

NRCTRLTS_OBJ = {
    NRCTRLTS: {},
    NRMTRACECU: {'actCellTraceReportingCU': 'true', 'actPCMDReporting': 'true', 'cellMaxActiveUEsTraced': '100',
                 'jobType': 'TraceOnly', 'nrMtraceCuId': '1',
                 'nrTceIdentifier': '1', 'scope': 'specificResources',
                 'traceNGAPSetting': 'all', 'traceNRRRCSetting': 'all', 'traceX2Setting': 'all',
                 'traceXNSetting': 'all'},
    NRRESOURCECU:  {'resourceDN': str(NR_CELL_NAME), 'typeNrCu': 'cell', 'nrResourceCuId': '1'}
}

NRCTRLTS_OBJ_ERROR1 = {
    NRCTRLTS: {},
    NRMTRACECU: {'actCellTraceReportingCU': 'true', 'actPCMDReporting': 'true', 'cellMaxActiveUEsTraced': '100',
                 'jobType': 'TraceOnly', 'nrMtraceCuId': '1',
                 'nrTceIdentifier': '1', 'scope': 'allResources',
                 'traceNGAPSetting': 'all', 'traceNRRRCSetting': 'all', 'traceX2Setting': 'all',
                 'traceXNSetting': 'all'},
    NRRESOURCECU: {'resourceDN': str(NR_CELL_NAME), 'typeNrCu': 'cell', 'nrResourceCuId': '1'}}

NRCTRLTS_OBJ_ERROR2 = {
    NRCTRLTS: {},
    NRMTRACECU: {'actCellTraceReportingCU': 'true', 'actPCMDReporting': 'true', 'cellMaxActiveUEsTraced': '100',
                 'jobType': 'TraceOnly', 'nrMtraceCuId': '1',
                 'nrTceIdentifier': '1', 'scope': 'specificResources',
                 'traceNGAPSetting': 'all', 'traceNRRRCSetting': 'all', 'traceX2Setting': 'all',
                 'traceXNSetting': 'all'},
    NRRESOURCECU: {'resourceDN': str(NR_CELL_NAME), 'typeNrCu': 'central', 'nrResourceCuId': '1'}}

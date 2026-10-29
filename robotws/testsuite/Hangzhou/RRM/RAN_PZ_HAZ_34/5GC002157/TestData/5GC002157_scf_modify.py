from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_NAME = NR_NAME + '/NRCELL-1'
NRTCE = MR_NR_BTS_NAME + '/NRCTRLTS-1/NRTCE-1'
NRMTRACECU = MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1'
NRMTRACEDU = MR_NR_BTS_NAME + '/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1'
TRACE_IP = tl.test_pcs[0].default_ssh_connection_details.addr
TRACE_PORT = tl.test_pcs[0].default_ssh_connection_details.port


DU_CELL_TRACE_FALSE = [
    dict(value='false', dist_name=MR_NR_BTS_NAME, parameter='actCellTraceReport')
]

DU_CELL_TRACE_TRUE = [
    dict(value='true', dist_name=MR_NR_BTS_NAME, parameter='actCellTraceReport')
]

DU_CELL_TRACE_TRUE_SCF = [
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCellTraceReport')
]

DU_CELL_TRACE_TRUE_PCMD_SCF = [
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCellTraceReport'),
    dict(value='true', dist_name=NRMTRACEDU, p_name='actPCMDReporting')
]

DU_SCF_CELLTRACE_PCMD_TRUE = [
    dict(value='true', dist_name=MR_NR_BTS_NAME, parameter='actCellTraceReport'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, parameter='actPCMDReport')
]

DU_SCF_CELLTRACE_PCMD_FALSE = [
    dict(value='false', dist_name=MR_NR_BTS_NAME, parameter='actCellTraceReport'),
    dict(value='false', dist_name=MR_NR_BTS_NAME, parameter='actPCMDReport')
]

DU_SCF_PCMD_FALSE = [
    dict(value='false', dist_name=MR_NR_BTS_NAME, parameter='actPCMDReport')
]

CU_SCF_CELLTRACE_PCMD_TRUE = {
    MR_NR_BTS_NAME: {'actCellTraceReport': 'true', 'actPCMDReport': 'true'}
}

CU_SCF_CELLTRACE_PCMD_FALSE = {
    MR_NR_BTS_NAME: {'actCellTraceReport': 'false', 'actPCMDReport': 'false'}
}

CU_SCF_PCMD_FALSE = {
    MR_NR_BTS_NAME: {'actPCMDReport': 'false'}
}

CU_SCF_CELL_TRACE_FALSE = [
    dict(value='false', dist_name=MR_NR_BTS_NAME, p_name='actCellTraceReport')
]

CU_SCF_ACTIVE_CELL_TRACE = [
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actSecDataUsageRep'),
    dict(value='10', dist_name=MR_NR_BTS_NAME, p_name='periodicalDataUsageReportTimer'),
    dict(value='5min', dist_name=MR_NR_BTS_NAME+"/NRPMRNL-1", p_name='miNrS1UInterface'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCellTraceReport')
]

CU_SCF_ACTIVE_CELL_TRACE_PCMD = [
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actSecDataUsageRep'),
    dict(value='10', dist_name=MR_NR_BTS_NAME, p_name='periodicalDataUsageReportTimer'),
    dict(value='5min', dist_name=MR_NR_BTS_NAME+"/NRPMRNL-1", p_name='miNrS1UInterface'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCellTraceReport'),
    dict(value='true', dist_name=NRMTRACECU, p_name='actPCMDReporting')
]

DU_SCF_ACTIVE_CELL_TRACE = [
    dict(value='true', dist_name=MR_NR_BTS_NAME, parameter='actCellTraceReport')
]

CU_CELL_TRACE_FALSE_DELTA = {MR_NR_BTS_NAME: {'actCellTraceReport': 'false'}}
CU_CELL_TRACE_TRUE_DELTA = {MR_NR_BTS_NAME: {'actCellTraceReport': 'true'}}
CU_DELETE_NRMTRACECU_DELTA = {MR_NR_BTS_NAME + '/NRCTRLTS-1/NRMTRACECU-1': {}}

from taf.sw.dcap.rd import rd
# import dcap_utilities.py
# import CPRT_Capture.py
import time
import os
from datetime import datetime
import subprocess
from CommonClass import Cmd_Executor
dcap_object = rd()
cell_list = {}
default = []


def Open_Connection_to_gNB(VmIp, vduIP=None, vduPwd=None, vcuIP=None, vcuPwd=None, UserName=None, NameSpace=None):
    global gNBType
    gNBType = Get_gNB_Type()
    if gNBType == "Classical-TL":
        connect_classical_gnb(VmIp)
    else:
        connect_vdu_vcu_gnb(VmIp)
        Disable_TLS(vduIP, vduPwd, vcuIP, vcuPwd, UserName, NameSpace)


def connect_classical_gnb(VmIp):
    print("dbg_ET-BLR: gNB-Type is " + gNBType)
    dcap_object.connect_to(host=str(VmIp), port='9443', username=None, password=None,
                           rd_version='dcapv3', secure=True, alias="ConObj")
    print("dbg_ET-BLR: Connected to DCAP")
    dcap_object.create_bts(host='10.0.1.2', port='443', username='Nemuadmin', password='nemuuser',
                           bts_alias='target_bts', connection="ConObj", timeout=30)
    print("dbg_ET-BLR: Added BTS Instance in DCAP")
    temp = dcap_object.get_all_bts_info(connection="ConObj")
    temp = temp[0].get('nr_cells')
    global cell_list
    global default
    for i in range(len(temp)):
        cell = "NRCELL_" + str(i + 1)
        cell_list[cell] = temp[i]['internal_id']
        default.append(temp[i]['internal_id'])
    print(default, cell_list)


def connect_vdu_vcu_gnb(VmIp):
    print("dbg_ET-BLR: gNB-Type is " + gNBType)
    print("AIC connection")
    command = "utf_lab-IP 10.0.1.1"
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    process.wait()
    time.sleep(5)
    dcap_object.connect_to(host=str(VmIp), port='9443', username=None, password=None,
                           rd_version='dcapv3', secure=True, alias="ConObj")
    print("dbg_ET-BLR: Connected to DCAP to AIC")
    dcap_object.create_bts(host='192.168.255.129', port='443', username='Nemuadmin', password='Nokia@123',
                           bts_alias='target_bts_vdu', credential_region_Id='DEFAULT_CREDENTIALS_VRAN',
                           connection="ConObj", timeout=30)
    time.sleep(2)
    dcap_object.create_bts(host='192.168.100.129', port='443', username='Nemuadmin', password='Nokia@123',
                           bts_alias='target_bts_vcu', credential_region_Id='DEFAULT_CREDENTIALS_VRAN',
                           connection="ConObj", timeout=30)
    print("dbg_ET-BLR: Added BTS Instance in DCAP")
    temp = dcap_object.get_all_bts_info(connection="ConObj")
    temp = temp[0].get('nr_cells')
    global cell_list
    global default
    for i in range(len(temp)):
        cell = "NRCELL_" + str(i + 1)
        cell_list[cell] = temp[i]['internal_id']
        default.append(temp[i]['internal_id'])
    print(default, cell_list)


def select_cells(cell_):
    nrcell = []
    if cell_ is None:
        nrcell.extend(default)
    else:
        for cell in cell_:
            nrcell.append(cell_list.get(cell))
    return nrcell


def check_ready_status(traceid):
    TraceRunningFlag = True
    while TraceRunningFlag:
        TraceStatus = dcap_object.get_trace_info_by_id(trace_id=int(traceid['tracer_id']), connection="ConObj")
        print("dbg_ET-BLR: Trace status=" + str(datetime.now().strftime('%H:%M:%S.%f') + str(TraceStatus['status'])))
        if TraceStatus['status'] == 'ready':
            TraceRunningFlag = False
        time.sleep(2)


def Start_Dcap_BIP_Trace(mirroring_time, CellId=None):
    global gNBType
    gNBType = Get_gNB_Type()
    if gNBType == "Classical-TL":
        start_BIP_classical(mirroring_time, CellId=None)
    else:
        print("*WARN*  BIP log is not available for AIC Environment")


def start_BIP_classical(mirroring_time, CellId=None):
    nrcell = select_cells(CellId)
    bts = {'host': '10.0.1.2', 'password': 'nemuuser', 'port': '443', 'username': 'Nemuadmin', 'nrCells': nrcell}
    gnb_custom_profile = ['bip_interface_mirroring']
    print("dbg_ET-BLR: Start-Trace " + str(datetime.now().strftime('%H:%M:%S.%f')) + " bts=" + str(bts)
          + " gnb_custom_profile=" + str(gnb_custom_profile) + " bip_mirroring_time=" + str(mirroring_time))
    global BipTraceId
    BipTraceId = dcap_object.start_trace(bts=bts, gnb_custom_profile=gnb_custom_profile,
                                         bip_mirroring_time=int(mirroring_time), bip_mirroring_interface="L1-L2",
                                         wait_for_activation=True, connection="ConObj")
    print("dbg_ET-BLR: Start-Trace ends " + str(datetime.now().strftime('%H:%M:%S.%f')))
    print("dbg_ET-BLR: BIP Trace stared -- trace_id=" + str(BipTraceId['tracer_id']))
    # check_ready_status(BipTraceId)


def Stop_Dcap_BIP_Trace():
    gNBType = Get_gNB_Type()
    if gNBType == "AIC-TL":
        return print("*WARN*  BIP log is not available for AIC Environment")
    print("dbg_ET-BLR: gNB-Type is " + gNBType)
    global BipTraceId
    check_ready_status(BipTraceId)
    print("dbg_ET-BLR: BIPTraceid=" + str(BipTraceId['tracer_id']))
    os.system("mkdir /tmp/l1l2")
    os.system("rm -rf /tmp/l1l2/*")
    os.system("mkdir /tmp/new")
    os.system("rm -rf /tmp/new/*")
    dcap_object.get_results(result_id=int(BipTraceId['tracer_id']), target_dir="/tmp/l1l2/", connection="ConObj")
    print("dbg_ET-BLR: Download bip log to path /tmp/l1l2")
    dcap_object.delete_trace(trace_id=int(BipTraceId['tracer_id']), connection="ConObj")
    print("dbg_ET-BLR: Trace deleted from DCAP")


def Start_Dcap_Syslog_Trace():
    global gNBType
    gNBType = Get_gNB_Type()
    if gNBType == "Classical-TL":
        start_syslog_classical()
    else:
        print("*WARN*  Syslog log is not available for AIC Environment")


def start_syslog_classical():
    print("dbg_ET-BLR: gNB-Type is " + gNBType)
    bts = {'host': '10.0.1.2', 'password': 'nemuuser', 'port': '443', 'username': 'Nemuadmin'}
    gnb_custom_profile = ['condor5gSyslog']
    global SyslogTraceId
    print("dbg_ET-BLR: Start-Trace " + str(datetime.now().strftime('%H:%M:%S.%f')) + " bts="
          + str(bts) + " gnb_custom_profile=" + str(gnb_custom_profile))
    SyslogTraceId = dcap_object.start_trace(bts=bts, gnb_custom_profile=gnb_custom_profile, wait_for_activation=True,
                                            connection="ConObj")
    print("dbg_ET-BLR: Start-Trace ends " + str(datetime.now().strftime('%H:%M:%S.%f')))
    print("dbg_ET-BLR: Syslog Trace stared -- trace_id=" + str(SyslogTraceId['tracer_id']))


def Stop_Dcap_Syslog_Trace():
    gNBType = Get_gNB_Type()
    if gNBType == "AIC-TL":
        return print("*WARN*  SYSlog is not available for AIC Environment")
    print("dbg_ET-BLR: gNB-Type is " + gNBType)
    global SyslogTraceId
    print("dbg_ET-BLR: Syslog_Traceid=" + str(SyslogTraceId))
    Print_Time_Stamp()
    dcap_object.stop_trace(trace_id=int(SyslogTraceId['tracer_id']), connection="ConObj")
    print("dbg_ET-BLR: " + str(datetime.now().strftime('%H:%M:%S.%f')) + "  Syslog trace stopped In DCAP")
    check_ready_status(SyslogTraceId)
    os.system("mkdir /tmp/syslog")
    os.system("rm -rf /tmp/syslog/*")
    os.system("mkdir /tmp/new")
    os.system("rm -rf /tmp/new/*")
    Print_Time_Stamp()
    dcap_object.get_results(result_id=int(SyslogTraceId['tracer_id']), target_dir="/tmp/syslog/",
                            connection="ConObj")
    print("dbg_ET-BLR: Download syslog log to path /tmp/syslog")
    Print_Time_Stamp()
    dcap_object.delete_trace(trace_id=int(SyslogTraceId['tracer_id']), connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: Instance of Syslog Trace deleted from DCAP")


def Start_Dcap_L2Component_Trace(component_list, CellId=None):
    global gNBType
    print("dbg_ET-BLR: gNB-Type is " + gNBType)
    gNBType = Get_gNB_Type()
    if gNBType == "Classical-TL":
        collect_classical_l2log(component_list, CellId)
    else:
        collect_aic_l2log(component_list, CellId)


def collect_classical_l2log(component_list, CellId):
    global gNBType
    print("dbg_ET-BLR: gNB-Type is " + gNBType)
    nrcell = select_cells(CellId)
    component = {'L2PS': 'L2Ps_Component', 'L2LO': 'L2Lo_Component', 'L2HIRLC': 'L2HiRlc_Component',
                 'L2HIPDCP': 'L2HiPdcp_Component'}
    bts = {'host': '10.0.1.2', 'port': '443', 'username': 'Nemuadmin', 'password': 'nemuuser', 'nrCells': nrcell}
    gnb_custom_profile = []
    for ele in component_list:
        gnb_custom_profile.append(component.get(ele))
    print("dbg_ET-BLR: Start-Trace " + str(datetime.now().strftime('%H:%M:%S.%f')) + " bts=" + str(bts)
          + " gnb_custom_profile=" + str(gnb_custom_profile))
    global TTitraceid
    TTitraceid = dcap_object.start_trace(bts=bts, gnb_custom_profile=gnb_custom_profile, wait_for_activation=True,
                                         connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: L2comp Trace stared -- trace_id=" + str(TTitraceid['tracer_id']))


def collect_aic_l2log(component_list, CellId):
    global gNBType
    print("dbg_ET-BLR: gNB-Type is " + gNBType)
    nrcell = select_cells(CellId)
    component = {'L2PS': 'L2Ps_Component', 'L2LO': 'L2Lo_Component', 'L2HIRLC': 'L2HiRlc_Component',
                 'L2HIPDCP': 'L2HiPdcp_Component'}
    bts_vdu = {'host': "192.168.255.129", 'username': 'Nemuadmin', 'port': "443",
               'password': 'Nokia@123', 'nrCells': nrcell}
    bts_vcu = {'host': "192.168.100.129", 'username': 'Nemuadmin', 'port': "443",
               'password': 'Nokia@123', 'nrCells': nrcell}
    vdu_custom_profile_ = []
    vcu_custom_profile_ = []
    for ele in component_list:
        if ele == "L2HIPDCP":
            vcu_custom_profile_.append(component.get(ele))
        else:
            vdu_custom_profile_.append(component.get(ele))
    logvdu = len(vdu_custom_profile_)
    logvcu = len(vcu_custom_profile_)
    global TTitraceidvdu
    global TTitraceidvcu
    TTitraceidvdu = 0
    TTitraceidvcu = 0
    if logvdu != 0:
        print("vdu profiles", vdu_custom_profile_)
        TTitraceidvdu = dcap_object.start_trace(bts=bts_vdu, vdu_custom_profile=vdu_custom_profile_,
                                                wait_for_activation=True,
                                                connection="ConObj")
    if logvcu != 0:
        print("vcu profiles", vcu_custom_profile_)
        TTitraceidvcu = dcap_object.start_trace(bts=bts_vcu, vcu_custom_profile=vcu_custom_profile_,
                                                wait_for_activation=True,
                                                connection="ConObj")
    Print_Time_Stamp()


def Stop_Dcap_L2Component_Trace():
    global gNBType
    print("dbg_ET-BLR: gNB-Type is " + gNBType)
    gNBType = Get_gNB_Type()
    if gNBType == "Classical-TL":
        stop_l2comp(TTitraceid)
    else:
        if TTitraceidvdu != 0:
            stop_l2comp(TTitraceidvdu)
        elif TTitraceidvcu != 0:
            stop_l2comp(TTitraceidvcu)


def stop_l2comp(ttitraceid):
    dcap_object.stop_trace(trace_id=int(ttitraceid['tracer_id']), connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: L2comp Trace stopped In DCAP")
    check_ready_status(ttitraceid)
    os.system("mkdir /tmp/TTITrace")
    os.system("rm -rf /tmp/TTITrace/*")
    os.system("mkdir /tmp/new")
    os.system("rm -rf /tmp/new/*")
    Print_Time_Stamp()
    dcap_object.get_results(result_id=int(ttitraceid['tracer_id']), target_dir="/tmp/TTITrace/",
                            connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: Download L2comp Trace log to path /tmp/TTITrace/")
    Print_Time_Stamp()
    dcap_object.delete_trace(trace_id=int(ttitraceid['tracer_id']), connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: Instance of L2comp Trace Trace deleted from DCAP")


def Get_Dcap_Snapshot_Trace(CellId=None):
    global gNBType
    print("dbg_ET-BLR: gNB-Type is " + gNBType)
    gNBType = Get_gNB_Type()
    if gNBType == "Classical-TL":
        collect_snapshot("10.0.1.2", 'nemuuser', CellId)
    else:
        collect_vdusnapshot_aic("192.168.255.129", 'Nokia@123', CellId)
        collect_vcusnapshot_aic("192.168.100.129", 'Nokia@123', CellId)


def collect_snapshot(btsip, password, CellId):
    nrcell = select_cells(CellId)
    bts = {'host': btsip, 'password': password, 'port': '443', 'username': 'Nemuadmin', 'nrCells': nrcell}
    bts_custom_profile = ['immediateSnapshot']
    global SnapshotTraceId
    print("dbg_ET-BLR: Start-Trace " + str(datetime.now().strftime('%H:%M:%S.%f')) + " bts="
          + str(bts) + " gnb_custom_profile=" + str(bts_custom_profile))
    SnapshotTraceId = dcap_object.start_trace(bts=bts, bts_custom_profile=bts_custom_profile,
                                              collection_timing='Immediate',
                                              wait_for_activation=True, connection="ConObj")
    print("dbg_ET-BLR: Snapshot Trace stared -- trace_id=" + str(SnapshotTraceId['tracer_id']))
    Print_Time_Stamp()
    check_ready_status(SnapshotTraceId)
    print("dbg_ET-BLR: Snapshot Trace stopped In DCAP")
    Print_Time_Stamp()
    os.system("mkdir /tmp/SnapshotTrace")
    os.system("rm -rf /tmp/SnapshotTrace/*")
    os.system("mkdir /tmp/new")
    os.system("rm -rf /tmp/new/*")
    dcap_object.get_results(result_id=int(SnapshotTraceId['tracer_id']), target_dir="/tmp/SnapshotTrace/",
                            connection="ConObj")
    print("dbg_ET-BLR: Download Snapshot Trace log to path /tmp/SnapshotTrace/")
    Print_Time_Stamp()
    dcap_object.delete_trace(trace_id=int(SnapshotTraceId['tracer_id']), connection="ConObj")
    print("dbg_ET-BLR: Instance of Snapshot Trace Trace deleted from DCAP")
    Print_Time_Stamp()


def collect_vcusnapshot_aic(btsip, password, CellId):
    nrcell = select_cells(CellId)
    bts = {'host': btsip, 'password': password, 'port': '443', 'username': 'Nemuadmin', 'nrCells': nrcell}
    vcu_custom_profile = ['snapshotVcu']
    global SnapshotTraceId
    print("dbg_ET-BLR: Start-Trace " + str(datetime.now().strftime('%H:%M:%S.%f')) + " bts="
          + str(bts) + " gnb_custom_profile=" + str(vcu_custom_profile))
    SnapshotTraceId = dcap_object.start_trace(bts=bts, vcu_custom_profile=vcu_custom_profile,
                                              wait_for_activation=True, connection="ConObj")
    print("dbg_ET-BLR: Snapshot Trace stared -- trace_id=" + str(SnapshotTraceId['tracer_id']))
    Print_Time_Stamp()
    check_ready_status(SnapshotTraceId)
    print("dbg_ET-BLR: Snapshot Trace stopped In DCAP")
    Print_Time_Stamp()
    dcap_object.get_results(result_id=int(SnapshotTraceId['tracer_id']), target_dir="/tmp/SnapshotTrace/",
                            connection="ConObj")
    print("dbg_ET-BLR: Download Snapshot Trace log to path /tmp/SnapshotTrace/")
    Print_Time_Stamp()
    dcap_object.delete_trace(trace_id=int(SnapshotTraceId['tracer_id']), connection="ConObj")
    print("dbg_ET-BLR: Instance of Snapshot Trace Trace deleted from DCAP")
    Print_Time_Stamp()


def collect_vdusnapshot_aic(btsip, password, CellId):
    nrcell = select_cells(CellId)
    bts = {'host': btsip, 'password': password, 'port': '443', 'username': 'Nemuadmin', 'nrCells': nrcell}
    vdu_custom_profile = ['snapshotVdu']
    global SnapshotTraceId
    print("dbg_ET-BLR: Start-Trace " + str(datetime.now().strftime('%H:%M:%S.%f')) + " bts="
          + str(bts) + " gnb_custom_profile=" + str(vdu_custom_profile))
    SnapshotTraceId = dcap_object.start_trace(bts=bts, vdu_custom_profile=vdu_custom_profile,
                                              wait_for_activation=True, connection="ConObj")
    print("dbg_ET-BLR: Snapshot Trace stared -- trace_id=" + str(SnapshotTraceId['tracer_id']))
    Print_Time_Stamp()
    check_ready_status(SnapshotTraceId)
    print("dbg_ET-BLR: Snapshot Trace stopped In DCAP")
    Print_Time_Stamp()
    os.system("mkdir /tmp/SnapshotTrace")
    os.system("rm -rf /tmp/SnapshotTrace/*")
    os.system("mkdir /tmp/new")
    os.system("rm -rf /tmp/new/*")
    dcap_object.get_results(result_id=int(SnapshotTraceId['tracer_id']), target_dir="/tmp/SnapshotTrace/",
                            connection="ConObj")
    print("dbg_ET-BLR: Download Snapshot Trace log to path /tmp/SnapshotTrace/")
    Print_Time_Stamp()
    dcap_object.delete_trace(trace_id=int(SnapshotTraceId['tracer_id']), connection="ConObj")
    print("dbg_ET-BLR: Instance of Snapshot Trace Trace deleted from DCAP")
    Print_Time_Stamp()


def Start_Dcap_Ipcapture_Trace(capture_point, uplane_interface):
    global gNBType
    gNBType = Get_gNB_Type()
    if gNBType == "Classical-TL":
        start_ipcapture_classical(capture_point, uplane_interface)
    else:
        print("*WARN*  IPcapture log is not available for AIC Environment")


def start_ipcapture_classical(capture_point, uplane_interface):
    bts = {'host': '192.168.255.129', 'password': 'nemuuser', 'port': '443', 'username': 'Nemuadmin'}
    bts_custom_profile = ['ipCapture']
    global IpTraceId
    print("dbg_ET-BLR: Start-Trace " + str(datetime.now().strftime('%H:%M:%S.%f')) + " bts="
          + str(bts) + " bts_custom_profile=" + str(bts_custom_profile) + " capture_point=" + str(capture_point)
          + " uplane_interface=" + str(uplane_interface))
    IpTraceId = dcap_object.start_trace(bts=bts, bts_custom_profile=bts_custom_profile, wait_for_activation=True,
                                        measurement_point=capture_point,
                                        uplane_interface=uplane_interface, connection="ConObj")
    print("dbg_ET-BLR: Start-Trace ends " + str(datetime.now().strftime('%H:%M:%S.%f')))
    print("dbg_ET-BLR: IP Trace stared -- trace_id=" + str(IpTraceId['tracer_id']))


def Stop_Dcap_Ipcapture_Trace():
    gNBType = Get_gNB_Type()
    if gNBType == "AIC-TL":
        return print("*WARN*  IPcapture is not available for AIC Environment")
    global IpTraceId
    TraceRunningFlag = True
    print("dbg_ET-BLR: IPtraceid=" + str(IpTraceId))
    Print_Time_Stamp()
    dcap_object.stop_trace(trace_id=int(IpTraceId['tracer_id']), connection="ConObj")
    print("dbg_ET-BLR: " + str(datetime.now().strftime('%H:%M:%S.%f')) + "  IP trace stopped In DCAP")
    check_ready_status(IpTraceId)
    os.system("mkdir /tmp/ip_capturelog")
    os.system("rm -rf /tmp/ip_capturelog/*")
    os.system("mkdir /tmp/new1")
    os.system("rm -rf /tmp/new1/*")
    Print_Time_Stamp()
    dcap_object.get_results(result_id=int(IpTraceId['tracer_id']), target_dir="/tmp/ip_capturelog/",
                            connection="ConObj")
    print("dbg_ET-BLR: Download IPcapture to path /tmp/ip_capturelog/")
    Print_Time_Stamp()
    dcap_object.delete_trace(trace_id=int(IpTraceId['tracer_id']), connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: Instance of IP Trace deleted from DCAP")


def start_vdu_controlplane(CellId=None):
    global gNBType
    print("dbg_ET-BLR: gNB-Type is " + gNBType)
    nrcell = select_cells(CellId)
    print(nrcell)
    bts_vdu = {'host': "192.168.255.129", 'username': 'Nemuadmin', 'port': "443",
               'password': 'Nokia@123', 'nrCells': nrcell}
    vdu_custom_profile_ = ['flowTracerVdu']
    print("dbg_ET-BLR: Start-Trace " + str(datetime.now().strftime('%H:%M:%S.%f')) + " bts=" + str(bts_vdu)
          + " vdu_custom_profile=" + str(vdu_custom_profile_))
    global controltrace
    controltrace = dcap_object.start_trace(bts=bts_vdu, vdu_custom_profile=vdu_custom_profile_,
                                           wait_for_activation=True,
                                           connection="ConObj")
    print("dbg_ET-BLR: Trace stared -- trace_id=" + str(controltrace['tracer_id']))
    Print_Time_Stamp()


def stop_vdu_controltrace():
    dcap_object.stop_trace(trace_id=int(controltrace['tracer_id']), connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: control Trace stopped In DCAP")
    check_ready_status(controltrace)
    os.system("mkdir /tmp/control")
    os.system("rm -rf /tmp/control/*")
    os.system("mkdir /tmp/new")
    os.system("rm -rf /tmp/new/*")
    Print_Time_Stamp()
    dcap_object.get_results(result_id=int(controltrace['tracer_id']), target_dir="/tmp/control/",
                            connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: Download controltrace Trace log to path /tmp/control/")
    Print_Time_Stamp()
    dcap_object.delete_trace(trace_id=int(controltrace['tracer_id']), connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: Instance of control Trace Trace deleted from DCAP")


def start_vcu_controlplane(CellId=None):
    global gNBType
    print("dbg_ET-BLR: gNB-Type is " + gNBType)
    nrcell = select_cells(CellId)
    bts_vcu = {'host': "192.168.100.129", 'username': 'Nemuadmin', 'port': "443",
               'password': 'Nokia@123', 'nrCells': nrcell}
    vcu_custom_profile_ = ['flowTracerVcu']
    print("dbg_ET-BLR: Start-Trace " + str(datetime.now().strftime('%H:%M:%S.%f')) + " bts=" + str(bts_vcu)
          + " vcu_custom_profile=" + str(vcu_custom_profile_))
    global controltracevcu
    controltracevcu = dcap_object.start_trace(bts=bts_vcu, vcu_custom_profile=vcu_custom_profile_,
                                              wait_for_activation=True,
                                              connection="ConObj")
    print("dbg_ET-BLR: Trace stared -- trace_id=" + str(controltracevcu['tracer_id']))
    Print_Time_Stamp()


def stop_vcu_controltrace():
    dcap_object.stop_trace(trace_id=int(controltracevcu['tracer_id']), connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: L2comp Trace stopped In DCAP")
    check_ready_status(controltracevcu)
    os.system("mkdir /tmp/controlvcu")
    os.system("rm -rf /tmp/controlvcu/*")
    os.system("mkdir /tmp/new")
    os.system("rm -rf /tmp/new/*")
    Print_Time_Stamp()
    dcap_object.get_results(result_id=int(controltracevcu['tracer_id']), target_dir="/tmp/controlvcu/",
                            connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: Download Trace log to path /tmp/controlvcu/")
    Print_Time_Stamp()
    dcap_object.delete_trace(trace_id=int(controltracevcu['tracer_id']), connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: Instance of controltracevcu deleted from DCAP")


def start_vdu_celltrace(CellId=None):
    global gNBType
    print("dbg_ET-BLR: gNB-Type is " + gNBType)
    nrcell = select_cells(CellId)
    bts_vdu = {'host': "192.168.255.129", 'username': 'Nemuadmin', 'port': "443",
               'password': 'Nokia@123', 'nrCells': nrcell}
    vdu_custom_profile_ = ['tracerVdu']
    print("dbg_ET-BLR: Start-Trace " + str(datetime.now().strftime('%H:%M:%S.%f')) + " bts=" + str(bts_vdu)
          + " vdu_custom_profile=" + str(vdu_custom_profile_))
    global celltrace
    celltrace = dcap_object.start_trace(bts=bts_vdu, vdu_custom_profile=vdu_custom_profile_,
                                        wait_for_activation=True,
                                        connection="ConObj")
    print("dbg_ET-BLR: Trace stared -- trace_id=" + str(celltrace['tracer_id']))
    Print_Time_Stamp()


def stop_vdu_celltrace():
    dcap_object.stop_trace(trace_id=int(celltrace['tracer_id']), connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: celltrace stopped In DCAP")
    check_ready_status(celltrace)
    os.system("mkdir /tmp/celltrace")
    os.system("rm -rf /tmp/celltrace/*")
    os.system("mkdir /tmp/new")
    os.system("rm -rf /tmp/new/*")
    Print_Time_Stamp()
    dcap_object.get_results(result_id=int(celltrace['tracer_id']), target_dir="/tmp/celltrace/",
                            connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: Download Trace log to path /tmp/celltrace/")
    Print_Time_Stamp()
    dcap_object.delete_trace(trace_id=int(celltrace['tracer_id']), connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: Instance of celltrace deleted from DCAP")


def start_vcu_celltrace(CellId=None):
    global gNBType
    print("dbg_ET-BLR: gNB-Type is " + gNBType)
    nrcell = select_cells(CellId)
    bts_vcu = {'host': "192.168.100.129", 'username': 'Nemuadmin', 'port': "443",
               'password': 'Nokia@123', 'nrCells': nrcell}
    vcu_custom_profile_ = ['tracerVcu']
    print("dbg_ET-BLR: Start-Trace " + str(datetime.now().strftime('%H:%M:%S.%f')) + " bts=" + str(bts_vcu)
          + " vdu_custom_profile=" + str(vcu_custom_profile_))
    global celltracevcu
    celltracevcu = dcap_object.start_trace(bts=bts_vcu, vcu_custom_profile=vcu_custom_profile_,
                                           wait_for_activation=True,
                                           connection="ConObj")
    print("dbg_ET-BLR: Trace stared -- trace_id=" + str(celltracevcu['tracer_id']))
    Print_Time_Stamp()


def stop_vcu_celltrace():
    dcap_object.stop_trace(trace_id=int(celltracevcu['tracer_id']), connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: L2comp Trace stopped In DCAP")
    check_ready_status(celltracevcu)
    os.system("mkdir /tmp/celltracevcu")
    os.system("rm -rf /tmp/celltracevcu/*")
    os.system("mkdir /tmp/new")
    os.system("rm -rf /tmp/new/*")
    Print_Time_Stamp()
    dcap_object.get_results(result_id=int(celltracevcu['tracer_id']), target_dir="/tmp/celltracevcu/",
                            connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: Download  Trace log to path /tmp/celltracevcu/")
    Print_Time_Stamp()
    dcap_object.delete_trace(trace_id=int(celltracevcu['tracer_id']), connection="ConObj")
    Print_Time_Stamp()
    print("dbg_ET-BLR: Instance of Trace Trace deleted from DCAP")


def Close_Connection_to_gNB(vduIP=None, vduPwd=None, vcuIP=None, vcuPwd=None, UserName=None, NameSpace=None):
    temp = dcap_object.get_all_bts_info(connection="ConObj", timeout=30)
    btsids = []
    for bts in range(len(temp)):
        btsids.append(temp[bts].get('id'))
    for bts in btsids:
        dcap_object.delete_bts(bts_id=bts, connection="ConObj", timeout=30)
        print(bts, "dbg_ET-BLR: Removed BTS Instance from DCAP")
    gNBType = Get_gNB_Type()
    if gNBType == "AIC-TL":
        Enable_TLS(vduIP, vduPwd, vcuIP, vcuPwd, UserName, NameSpace)


def Get_gNB_Type():
    WaitTimeInSecs = 3
    aic_ip = '192.168.100.129'
    CurTime = datetime.now()
    TimeLapsed = 0
    num_reachable = 0
    while TimeLapsed <= int(WaitTimeInSecs):
        Reachable = False
        response = os.system("ping -c 1 " + aic_ip)
        if response == 0:
            num_reachable = num_reachable + 1
            Reachable = True
        time.sleep(1)
        TimeLapsed = (datetime.now() - CurTime).total_seconds()
        print("TimeLapsed " + str(TimeLapsed) + " Reachable " + str(Reachable))
    if num_reachable > 0:
        return 'AIC-TL'
    else:
        return 'Classical-TL'


def Print_Time_Stamp():
    print("dbg_ET-BLR: " + str(datetime.now().strftime('%H:%M:%S.%f')))


def Disable_TLS(vduIP, vduPassword, vcuIP, vcuPassword, UserName, NameSpace):
    OamExtCmd = "kubectl get pods -n " + NameSpace + " | grep oamext | awk '{print $1}'"
    VduInstance = Cmd_Executor(vduIP, UserName, vduPassword)
    OamExtId = VduInstance.exec_get_output(OamExtCmd, "vDU")
    print('=' * 70, "Disable TLS ON vDU", '=' * 70)
    VduTlsDiasbleCmd = "kubectl exec -it -n " + NameSpace + " " + OamExtId + " -c ctr-" + NameSpace + \
                       "-providercontroller -- bash -c 'yes|/opt/nokia/bin/dataprovidercli add -u 172.16.5.1'"
    VcuTlsDiasbleCmd = "kubectl exec -it -n " + NameSpace + " " + OamExtId + " -c ctr-" + NameSpace + \
                       "-providercontroller -- bash -c 'yes|/opt/nokia/bin/dataprovidercli add -u 172.16.4.1'"
    stats = VduInstance.exec_get_output(VduTlsDiasbleCmd, "vDU")
    print(stats)
    print('=' * 70, "Show TLS ON vDU", '=' * 70)
    TlsShowCmd = "kubectl exec -it -n " + NameSpace + " " + OamExtId + " -c ctr-" + NameSpace + \
                 "-providercontroller -- bash -c 'yes|/opt/nokia/bin/dataprovidercli show'"
    stats = VduInstance.exec_get_output(TlsShowCmd, "vDU")
    print(stats)
    print('=' * 70, "Disable TLS ON vCU", '=' * 70)
    VcuInstance = Cmd_Executor(vcuIP, UserName, vcuPassword)
    stats = VcuInstance.exec_get_output(VcuTlsDiasbleCmd, "vCU")
    print(stats)
    print('=' * 70, "Show TLS ON vCU", '=' * 70)
    stats = VcuInstance.exec_get_output(TlsShowCmd, "vCU")
    print(stats)
    print('=' * 140)


def Enable_TLS(vduIP, vduPassword, vcuIP, vcuPassword, UserName, NameSpace):
    OamExtCmd = "kubectl get pods -n " + NameSpace + " | grep oamext | awk '{print $1}'"
    VduInstance = Cmd_Executor(vduIP, UserName, vduPassword)
    OamExtId = VduInstance.exec_get_output(OamExtCmd, "vDU")
    print('=' * 70, "Enable TLS ON vDU", '=' * 70)
    VduTlsEnableCmd = "kubectl exec -it -n " + NameSpace + " " + OamExtId + " -c ctr-" + NameSpace + \
                      "-providercontroller -- bash -c 'yes|/opt/nokia/bin/dataprovidercli delete -u 172.16.5.1'"
    VcuTlsEnableCmd = "kubectl exec -it -n " + NameSpace + " " + OamExtId + " -c ctr-" + NameSpace + \
                      "-providercontroller -- bash -c 'yes|/opt/nokia/bin/dataprovidercli delete -u 172.16.4.1'"
    stats = VduInstance.exec_get_output(VduTlsEnableCmd, "vDU")
    print(stats)
    print('=' * 70, "Enable TLS ON vCU", '=' * 70)
    VcuInstance = Cmd_Executor(vcuIP, UserName, vcuPassword)
    stats = VcuInstance.exec_get_output(VcuTlsEnableCmd, "vCU")
    print(stats)
    print('=' * 170)

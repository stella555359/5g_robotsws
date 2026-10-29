from datetime import datetime
import os
import time
from functools import wraps
from robot.libraries.BuiltIn import BuiltIn
import StringTool
import OsTool
import Archi
import Topology
from ReadConfig import TLConfig
from taf.gnb.oam.coam.admin import admin as coam
from taf.gnb.oam.coam.cu import cu
from taf.selenium.sbts import sbts as selenium_coam

import taf.rfrl.common_resources.python.coam_parameter as coam_parameter

"""
This file supports all OAM oriented services
It is composed of :
- a virtual class (Oam) that provides all entry points for OAM external services
- n derivation of this class to address specificity of some oam upon architecture (Classical, CloudBTS, AIC,...)
Each external services is named without "_" (connect, disconnect, resetSite, ...)
These external services will then route flow to internal services named "_<name>" (_connect, _disconnect,...)
that are implemented in derivated classes
Two decorators are proposed, that can be used for any service :
- letConnectionOpened     : connection to OAM thru HTTP is not closed after service call
- closeConnectionAfterUse : connection to OAM thru HTTP is closed after service call

"""


def letConnectionOpened(method):
    @wraps(method)
    def wrapper(self, *args, **kwargs):
        self._connectIfRequired()
        ret = method(self, *args, **kwargs)
        return ret
    return wrapper


def closeConnectionAfterUse(method):
    @wraps(method)
    def wrapper(self, *args, **kwargs):
        self._connectIfRequired()
        ret = method(self, *args, **kwargs)
        self.disconnect()
        return ret
    return wrapper


# ======================================================================================
# Abstract class for OAM
# ======================================================================================
class Oam(Archi.Host):
    def __init__(self, sshConnection, httpConnection, hw=Archi.HW.GNB, unit=Archi.Unit.DU, proxy=None):
        super(Oam, self).__init__(alias=self._getAlias(hw, unit), sshConnection=sshConnection, proxy=proxy)
        self.hw = hw
        self.unit = unit
        # For backward compatibility
        self.isCloud = "Cloud" in self.alias
        self.httpAlias = "HTTP_{}".format(self.alias)
        self.httpConnection = httpConnection
        self.url = "https://{}".format(self.httpConnection.addr)
        self.drvRef = None

    def __str__(self):
        return "{} Cloud:{} HTTP:{}:{} ({}/{})".\
            format(super(Oam, self).__str__(), self.isCloud,
                   self.httpConnection.addr, self.httpConnection.port,
                   self.httpConnection.username, self.httpConnection.password)

    def setEntity(self, entity):
        """ to provide a reference to father entity """
        self.entity = entity

    # -----------------
    # Internal services
    # -----------------
    def _connectIfRequired(self):
        if self.drvRef is None:
            self.connect()

    def _getAlias(self, hw, unit):
        return "{}_{}_{}".format(type(self).__name__, hw, unit)

    def _notSupported(self, service):
        StringTool.datedConsole("Service [{}] not supported for {}".format(service, type(self).__name__))

    def _apiTrace(self, msg):
        StringTool.datedConsole("OAM API:{}".format(msg))

    def _getPostfix(self):
        if self.unit == Archi.Unit.DU:
            return ""
        return "_{}".format(self.unit)

    def _setGlobalVariables(self, btsInfo, mrbts, nrcell, nrbts):
        postfix = self._getPostfix()
        BuiltIn().run_keyword("Set Suite Var", "GNB_BTS_INFO{}".format(postfix), btsInfo)
        BuiltIn().run_keyword("Set Suite Var", "MRBTS_ID{}".format(postfix), mrbts)
        BuiltIn().run_keyword("Set Suite Var", "NRCELL_DIST_NAME{}".format(postfix), nrcell)
        BuiltIn().run_keyword("Set Suite Var", "NRBTS_ID{}".format(postfix), nrbts)

    def _isProceduralStateOK(self, proceduralState):
        return proceduralState == 'Configured' or proceduralState == 'OnAir'

    # -----------------
    # External API
    # -----------------
    def connect(self):
        self._apiTrace("Connect to {} [URL={}:{} ({}/{})]".
                       format(self.alias, self.url, self.httpConnection.port,
                              self.httpConnection.username,
                              self.httpConnection.password))
        self.drvRef = self._connect()
        return self.httpAlias

    def disconnect(self):
        self._apiTrace("Disconnect from {}".format(self.alias))
        if self.drvRef is not None:
            # We attempt a disconnect, but it can fail if OAM set param occured a OAM reboot
            # then, reference to OAM is no more operational
            try:
                self._disconnect()
            except Exception as e:
                StringTool.datedConsole("disconnect failed (connection previously lost due to OAM reboot)")
        self.drvRef = None

    @closeConnectionAfterUse
    def startReset(self):
        self._apiTrace("Start Reset Site {} (URL={})".format(self.alias, self.url))
        self._startReset()

    @letConnectionOpened
    def waitSiteAvailable(self):
        self._apiTrace("Waiting for {} full availability".format(self))
        self._waitSiteAvailable()

    @letConnectionOpened
    def getBtsInfo(self):
        self._apiTrace("Get BTS Info from {}".format(self.alias))
        self._getBtsInfo()

    @letConnectionOpened
    def getCellsNr(self):
        self._apiTrace("Get Cells NR Info from {}".format(self.alias))
        return self._getCellsNr()

    @letConnectionOpened
    def getCellsNr(self):
        self._apiTrace("Get Cells NR Info from {}".format(self.alias))
        return self._getCellsNr()

    @letConnectionOpened
    def getSWVersion(self):
        self._apiTrace("Get SW Version from {}".format(self.alias))
        return self._getSWVersion()

    @closeConnectionAfterUse
    def getActiveAlarms(self):
        self._apiTrace("Get active alarms from {}".format(self.alias))
        return self._getActiveAlarms()

    @closeConnectionAfterUse
    def getScfFile(self, dir, file, timeout=30):
        self._apiTrace("Get SCF File from {}".format(self.alias))
        return self._getScfFile(dir=dir, file=file, timeout=timeout)

    @closeConnectionAfterUse
    def getSnapshot(self, path, prefix, isTimeStamped, timeout):
        self._apiTrace("Get Snapshot from {}".format(self.alias))
        finalPath = OsTool.getSnapshotPath(path, prefix, isTimeStamped, self._getPostfix())
        self._getSnapshot(path=finalPath, timeout=timeout)
        return finalPath

    @closeConnectionAfterUse
    def cellLock(self, state, cell_id):
        self._apiTrace("Set cell [{}] to {} from {}".format(cell_id, state, self.alias))
        self._cellLock(cell_id=cell_id, state=state)

    @closeConnectionAfterUse
    def isCellLocked(self, cell_id):
        self._apiTrace("Check if cell [{}] is locked from {}".format(cell_id, self.alias))
        return self._isCellLocked(cell_id=cell_id)

    @closeConnectionAfterUse
    def waitAvailable(self, wait_time):
        self._apiTrace("Wait {} until site is available [{}]".format(wait_time, self.alias))
        maxIter = int(int(wait_time) / 10)
        # Loop to reach state OK
        for i in range(1, maxIter):
            time.sleep(10)
            proceduralState = self._getProceduralState()
            StringTool.datedConsole("\tLoop {}:ProcedureState={} (waiting to be 'Configured' or 'OnAir')"
                                    .format(i, proceduralState))
            if self._isProceduralStateOK(proceduralState):
                break
        # Trace error if still not reached
        if not self._isProceduralStateOK(proceduralState):
            StringTool.datedConsole("ERROR:OAM {} is in BAD state ({})".format(self.alias, proceduralState))
            return False
        return True

    @closeConnectionAfterUse
    def fullCommissioning(self, scf_file, skip_relation_errors):
        self._apiTrace("Full commissioning SCF:{} from {} (skip_relation_errors={})"
                       .format(scf_file, self.alias, skip_relation_errors))
        return self._fullCommissioning(scf_file=scf_file, skip_relation_errors=skip_relation_errors)

    @closeConnectionAfterUse
    def setParams(self, modify_param, timeout):
        self._apiTrace("Set Params from {} (tiimeout={})"
                       .format(self.alias, timeout))
        return self._setParams(modify_param=modify_param, timeout=timeout)

    @closeConnectionAfterUse
    def changeStringInScf(self, scfFilePath, oldVal, newVal):
        return self._changeStringInScf(scfFilePath, oldVal, newVal)


# ======================================================================================
# OAM CLASSICAL
# ======================================================================================
class OamClassical(Oam):
    def __init__(self, sshConnection, httpConnection, hw=Archi.HW.GNB, unit=Archi.Unit.DU, proxy=None):
        super(OamClassical, self).__init__(sshConnection=sshConnection,
                                           httpConnection=httpConnection,
                                           hw=hw, unit=unit, proxy=proxy)

    # -----------------
    # Internal services
    # -----------------
    def _getCellIdFormatted(self, cell_id):
        cells_info = self.drvRef.get_cells_info(connection=self.httpAlias)
        if len(cell_id) == 0:
            cell_id = cells_info[0]['globalCellId']
        cell_id = int(cell_id)
        StringTool.datedConsole("Cell_id={} type=[{}]".format(cell_id, type(cell_id)))
        return cell_id

    def _closeStartupWindowWithBestEffort(self, selenium_ref):
        try:
            StringTool.datedConsole("Selenium : Close Startup Window With Best Effort")
            selenium_ref.close_start_up_view_window()
        except Exception as e:
            pass

    # -----------------
    # External API wrapped
    # -----------------
    def _connect(self):
        self.drvRef = coam()
        self.drvRef.connect_to(bts_host=self.httpConnection.addr, name=self.httpAlias)
        return self.drvRef

    def _disconnect(self):
        self.drvRef.teardown(connection=self.httpAlias)

    def _startReset(self):
        self.drvRef.reset_site(connection=self.httpAlias, wait_for_reconnection=True)
        StringTool.datedConsole("Site is now up...")

    def _waitSiteAvailable(self):
        self._notSupported("waitSiteAvailable")

    def _getBtsInfo(self):
        btsInfo = self.drvRef.get_bts_info(connection=self.httpAlias)
        mrbts = btsInfo['mrbtsID']
        nrcell = btsInfo['cells']['nr'][0]['id']['configuration']
        nrbts = (nrcell.split("/")[1]).split("-")[1]
        self._setGlobalVariables(btsInfo=btsInfo, mrbts=mrbts, nrcell=nrcell, nrbts=nrbts)

    def _getCellsNr(self):
        btsInfo = self.drvRef.get_bts_info(connection=self.httpAlias)
        return btsInfo['cells']['nr']

    def _getSWVersion(self):
        return self.drvRef.get_sw_version(connection=self.httpAlias)

    def _getActiveAlarms(self):
        txtAlarms = []
        for alarm in self.drvRef.get_active_alarms(connection=self.httpAlias):
            txtAlarms.append("[{}]({}) {:40}:{}".
                             format(alarm['alarmId'], alarm['severity'],
                                    alarm['alarmName'], alarm['alarmDetail']))
        return txtAlarms

    def _getScfFile(self, dir, file, timeout):
        return self.drvRef.get_current_scf_file(local_dir_path=dir, file_name=file,
                                                timeout=timeout, connection=self.httpAlias)

    def _getSnapshot(self, path, timeout):
        self.drvRef.get_snapshot(target_file_name=path, coverage="Full", force=True,
                                 timeout=timeout, connection=self.httpAlias)

    def _cellLock(self, cell_id, state):
        cell_id = self._getCellIdFormatted(cell_id)
        selenium = selenium_coam()
        selenium.enable_virtual_display()
        selenium.login(url=self.url, username=self.httpConnection.username, password=self.httpConnection.password)
        selenium.disable_message_box()
        self._closeStartupWindowWithBestEffort(selenium)
        if state == "LOCK":
            selenium.block_cell(cell_idx=cell_id)
        else:
            selenium.unblock_cell(cell_idx=cell_id)
        time.sleep(30)
        selenium.logout()

    def _getProceduralState(self):
        btsStatus = self.drvRef.get_bts_statuses(connection=self.httpAlias)
        return btsStatus['proceduralState']

    def _fullCommissioning(self, scf_file, skip_relation_errors):
        return self.drvRef.perform_commissioning(scf_file=scf_file,
                                                 skip_parameter_relation_errors=skip_relation_errors,
                                                 timeout=600,
                                                 connection=self.httpAlias)

    def _setParams(self, modify_param, timeout):
        StringTool.datedConsole("OAM Set Params:\n\t{}".format(modify_param))
        para_file = coam_parameter.create_update_parameters_delta(parameters=modify_param, connection=self.httpAlias)
        status = coam_parameter.perform_scf_delta_commission(delta_file=para_file['updated'], timeout=timeout,
                                                             connection=self.httpAlias)
        StringTool.datedConsole("OAM Set Params:status=[{}]".format(status))
        assert "PASS" in status, "OAM Set Params:status was {} (expected [PASS] or [REST_PASS])".format(status)
        self.waitAvailable(wait_time=300)
        return status

    def _changeStringInScf(self, scfFilePath, oldVal, newVal):
        outfilePath = None
        if os.path.isfile(scfFilePath):
            fin = open(scfFilePath, "rt")
            outdir = os.path.dirname(scfFilePath)
            outfilePath = outdir+"/scfmodified.xml"
            fout = open(outfilePath, "wt")
            for line in fin:
                fout.write(line.replace(oldVal, newVal))
            fin.close()
            fout.close()
        return outfilePath


# ======================================================================================
# OAM FOR Cloud BTS
# ======================================================================================
class OamCloudBts(Oam):
    def __init__(self, sshConnection, httpConnection, hw=Archi.HW.GNB, unit=Archi.Unit.DU, proxy=None):
        super(OamCloudBts, self).__init__(sshConnection=sshConnection,
                                          httpConnection=httpConnection,
                                          hw=hw, unit=unit, proxy=proxy)

    def _connect(self):
        self.drvRef = cu()
        self.drvRef.connect_to(host=self.httpConnection.addr,
                               username=self.httpConnection.username,
                               password=self.httpConnection.password,
                               port=self.httpConnection.port,
                               cu_version="cuoam_19b",
                               secure=True)
        return self.drvRef

    def _disconnect(self):
        self.drvRef.disconnect()

    def _startReset(self):
        self.drvRef.reset_cu()
        StringTool.datedConsole("Site is now up...")

    def _waitSiteAvailable(self):
        sleepDuration = 300
        self._notSupported("waitSiteAvailable")
        StringTool.datedConsole("Waiting {} seconds".format(sleepDuration))
        time.sleep(sleepDuration)

    def _getBtsInfo(self):
        btsInfo = self.drvRef.get_cu_state()
        nrbts = 1
        mrbts = btsInfo['id']
        nrcell = "NRBTS-{}/NRCELL-1".format(nrbts)
        self._setGlobalVariables(btsInfo=btsInfo, mrbts=mrbts, nrcell=nrcell, nrbts=nrbts)

    def _getCellsNr(self):
        btsInfo = self.drvRef.get_cu_state()
        return btsInfo['cells']['nr']

    def _getSWVersion(self):
        return cu.get_active_software_version()

    def _getActiveAlarms(self):
        return cu().get_active_alarms()

    def _getScfFile(self, dir, file, timeout):
        self._notSupported("getScfFile")
        return ""

    def _getSnapshot(self, path, timeout):
        self.drvRef.get_local_snapshot(directory=path, request_timeout=None,
                                       operation_timeout=timeout, connection=self.httpAlias)

    def _cellLock(self, cell_id, state):
        self._notSupported("cellLock")

    def _isCellLocked(self, cell_id):
        self._notSupported("isCellLocked")

    def _getProceduralState(self):
        self._notSupported("getProceduralState")

    def _fullCommissioning(self, scf_file, skip_relation_errors):
        self._notSupported("fullCommissioning")

    def _setParams(self, modify_param, timeout):
        self._notSupported("setParams")


# ======================================================================================
# OAM FOR Cloud AIC (CU)
# ======================================================================================
class OamCloudAicCU(Oam):
    def __init__(self, sshConnection, httpConnection, hw=Archi.HW.GNB, unit=Archi.Unit.DU, proxy=None):
        super(OamCloudAicCU, self).__init__(sshConnection=sshConnection,
                                            httpConnection=httpConnection,
                                            hw=hw, unit=unit, proxy=proxy)


# ======================================================================================
# OAM FOR Cloud AIC (DU)
# ======================================================================================
class OamCloudAicDU(Oam):
    def __init__(self, sshConnection, httpConnection, hw=Archi.HW.GNB, unit=Archi.Unit.DU, proxy=None):
        super(OamCloudAicDU, self).__init__(sshConnection=sshConnection,
                                            httpConnection=httpConnection,
                                            hw=hw, unit=unit, proxy=proxy)


# ======================================================================================
# Service to build an oam knowing its HW and its unit
# ======================================================================================
def getOam(sshConnection, httpConnection, hw=Archi.HW.GNB, unit=Archi.Unit.DU, proxy=None):
    if hw == Archi.HW.AP:
        return OamClassical(sshConnection, httpConnection, hw, unit, proxy)
    if unit == Archi.Unit.CU:
        if TLConfig.archi == Topology.Archi.CLASSICAL:
            return None
        if TLConfig.archi == Topology.Archi.CLOUD_BTS:
            return OamCloudBts(sshConnection, httpConnection, hw, unit, proxy)
        if TLConfig.archi == Topology.Archi.AIC_BTS:
            return OamCloudAicCU(sshConnection, httpConnection, hw, unit, proxy)
    if unit == Archi.Unit.DU:
        if TLConfig.archi == Topology.Archi.AIC_BTS:
            return OamCloudAicDU(sshConnection, httpConnection, hw, unit, proxy)
        return OamClassical(sshConnection, httpConnection, hw, unit, proxy)
    return None

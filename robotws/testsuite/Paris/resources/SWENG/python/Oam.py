from datetime import datetime
import os
import time
import operator
import re
import ast
from functools import wraps
from robot.libraries.BuiltIn import BuiltIn
import StringTool
import OsTool
import Enums
import Hosts
from ReadConfig import TLConfig
import XmlScf
from taf.gnb.oam.coam.cu import cu
from taf.sbts.oam.coam.admin import admin as sbts_coam
from taf.gnb.oam.coam.vdu import Vdu as vdu
import CoamParameter as coam_parameter
import MultiScf

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


def closeConnectionAfterUseWithTimeout(method):
    @wraps(method)
    def wrapper(self, *args, **kwargs):
        timeout = 600
        remainingTime = timeout
        sleepTime = 10
        connectionOk = False
        while remainingTime > 0:
            # StringTool.datedConsole("closeConnectionAfterUseWithTimeout: sleep 10s")
            time.sleep(sleepTime)
            remainingTime = remainingTime - sleepTime
            try:
                # StringTool.datedConsole("closeConnectionAfterUseWithTimeout: try to connect")
                self.connect()
                StringTool.datedConsole("closeConnectionAfterUseWithTimeout: OAM connection OK")
                connectionOk = True
                break
            except Exception as e:
                StringTool.datedConsole("Failed to establish the connection")

        if not connectionOk:
            StringTool.datedConsole(f"ERROR : connection could not be established after {timeout} seconds")
            # ADT - raise exception to stop the test (otherwise the test is not interrupted)
            raise Exception("Error connecting to OAM")

        # ADT - extra time as on TL TDD39, with redondant config, the DB seems not ready once OAM connection is OK
        #       and this causes test failure (missing of alarm data)
        time.sleep(60)

        ret = method(self, *args, **kwargs)
        self.disconnect()
        return ret

    return wrapper


def sbtsLetConnectionOpened(method):
    @wraps(method)
    def wrapper(self, *args, **kwargs):
        self._sbtsConnectIfRequired()
        ret = method(self, *args, **kwargs)
        return ret

    return wrapper


def sbtsCloseConnectionAfterUse(method):
    @wraps(method)
    def wrapper(self, *args, **kwargs):
        self._sbtsConnectIfRequired()
        ret = method(self, *args, **kwargs)
        self.sbtsDisconnect()
        return ret

    return wrapper


# ======================================================================================
# Abstract class for OAM
# ======================================================================================


class Oam(Hosts.Host):

    def __init__(self, sshConnection, httpConnection, hw=Enums.HW.GNB, unit=Enums.Unit.DU, index=0, proxy=None):
        super(Oam, self).__init__(alias=self._getAlias(hw, unit, index), sshConnection=sshConnection, proxy=proxy,
                                  isSudo=True)
        self.hw = hw
        self.unit = unit
        # Index of GNB in list of gnbs
        self.index = index
        # For backward compatibility
        self.isCloud = "Cloud" in self.alias
        self.httpAlias = f"HTTP_{self.alias}"
        self.httpConnection = httpConnection
        self.url = f"https://{self.httpConnection.addr}"
        self.drvRef = None
        self.sbtsHttpAlias = f"SBTS_HTTP_{self.alias}"
        self.sbtsDrvRef = None
        self.vms = self._createVMs()

    def __str__(self):
        return (f"SSH:{self.sshConnection.addr} Cloud:{self.isCloud} "
                f"HTTP:{self.httpConnection.addr}:{self.httpConnection.port} "
                f"({self.httpConnection.username}/{self.httpConnection.password})")

    def getVM(self, name):
        for vm in self.vms:
            if Oam.vmNameToSshId(name) == vm.sshId:
                return vm
        return None

    def setEntity(self, entity):
        """ to provide a reference to father entity """
        self.entity = entity

    # -----------------
    # Internal services
    # -----------------
    def _createVMs(self):
        # By default (generic Oam), no vms
        return []

    def displayVMs(self):
        for vm in self.vms:
            StringTool.prefixDatedConsole(f"    VM:{vm}")

    @staticmethod
    def vmNameToSshId(name):
        return f"{name.lower()}-0.local"

    def _connectIfRequired(self):
        # check if the existing connection  is still active
        if self.drvRef is not None:
            if not self.isActiveConnection():
                StringTool.datedConsole("Reset connection reference for reconnecting")
                self.drvRef = None
        if self.drvRef is None:
            self.connect()

    def _getAlias(self, hw, unit, index):
        return f"{type(self).__name__}_T{hw}_{unit}{index}"

    def _notSupported(self, service):
        StringTool.datedConsole(f"Service [{service}] not supported for {type(self).__name__}")

    def _apiTrace(self, msg):
        StringTool.datedConsole(f"OAM API:{msg}")

    def _getPostfix(self):
        if self.entity.unit == Enums.Unit.DU:
            return ""
        return f"_{self.unit}"

    def _setGlobalVar(self, name, value):
        postFix = self._getPostfix()
        # Build variable as : T<Var>[index] to address multi GNB feature
        precName = f"{name}{postFix}"
        fullName = f"T{precName}[{self.index}]"
        BuiltIn().run_keyword("Set Suite Var", fullName, value)
        # for AIC, define same variables without extension _CU
        if TLConfig.topo.archi.isAic() and postFix == "_CU":
            BuiltIn().run_keyword("Set Suite Var", name, value)
        # For backward compatibility. Mapping also previous variables (MRBTS_ID) on TGNB_xx[0]
        if self.index == 0:
            BuiltIn().run_keyword("Set Suite Var", precName, value)

    def _setGlobalVariables(self, btsInfo, mrbts, nrcell, nrbts, nrCellGrp,
                            nbOfNrCells=0, nrcellId=None, cellDnList=None, cellIdList=None):
        # DO NOT REPLACE name="xxx" with "Txxx[0]" !!!!!!
        self._setGlobalVar(name="GNB_BTS_INFO", value=btsInfo)
        self._setGlobalVar(name="MRBTS_ID", value=mrbts)
        self._setGlobalVar(name="NRCELL_DIST_NAME", value=nrcell)
        self._setGlobalVar(name="NRBTS_ID", value=nrbts)
        self._setGlobalVar(name="NRCELL_GRP", value=nrCellGrp)
        self._setGlobalVar(name="NRCELL_DN", value=nrcell)
        self._setGlobalVar(name="NRCELL_ID", value=nrcellId)
        self._setGlobalVar(name="NRCELL_DN_LIST", value=cellDnList)
        self._setGlobalVar(name="NRCELL_ID_LIST", value=cellIdList)
        self._setGlobalVar(name="NRCELL_NB", value=nbOfNrCells)

    def _isProceduralStateOK(self, proceduralState):
        return proceduralState.lower() == 'integrated to ran' or \
               proceduralState.lower() == 'configured' or \
               proceduralState.lower() == 'onair'

    def _sbtsConnectIfRequired(self):
        if self.sbtsDrvRef is None:
            self.sbtsConnect()

    def _setParams(self, modify_param, timeout):
        self._notSupported("setParams")

    def _setParamError(self, error="PASS"):
        assert "PASS" in error, f"ERROR on OAM Set param:{error}"
        return error

    # -----------------
    # External API
    # -----------------

    def connect(self):
        self._apiTrace(f"Connect to {self.alias} [URL={self.url}:{self.httpConnection.port}"
                       f" ({self.httpConnection.username}/{self.httpConnection.password})]")
        self.drvRef = self._connect()
        return self.httpAlias

    def disconnect(self):
        self._apiTrace(f"Disconnect from {self.alias}")
        if self.drvRef is not None:
            # We attempt a disconnect, but it can fail if OAM set param occurred a OAM reboot
            # then, reference to OAM is no more operational
            try:
                self._disconnect()
            except Exception as e:
                StringTool.datedConsole(f"WARNING: Oam.disconnect() failed with exception = {e}")
        self.drvRef = None

    def isActiveConnection(self):
        if self.drvRef is not None:
            return self._isActiveConnection()
        else:
            return False

    @closeConnectionAfterUse
    def startReset(self):
        self._apiTrace(f"Start Reset Site {self.alias} (URL={self.url})")
        self._startReset()

    @closeConnectionAfterUse
    def softwareUpdate(self, sw_package, should_activate, timeout):
        self._apiTrace(f"Start software update on {self.alias} (URL={self.url})")
        return self._softwareUpdate(sw_package=sw_package, should_activate=should_activate, timeout=timeout)

    @letConnectionOpened
    def waitSiteAvailable(self):
        self._apiTrace(f"Waiting for {self} full availability")
        self._waitSiteAvailable()

    @letConnectionOpened
    def getBtsInfo(self):
        self._apiTrace(f"Get BTS Info from {self.alias}")
        self._getBtsInfo()

    @letConnectionOpened
    def getBtsInfoRaw(self):
        self._apiTrace(f"Get BTS Raw Info from {self.alias}")
        return self._getBtsInfoRaw()

    @letConnectionOpened
    def runOamCmd(self, cmd, cmdArgs=None):
        self._apiTrace(f"Run command {cmd} on {self.alias}'")
        return self._runOamCmd(cmd, cmdArgs)

    @letConnectionOpened
    def getCellsNr(self):
        self._apiTrace(f"Get Cells NR Info from {self.alias}")
        return self._getCellsNr()

    @letConnectionOpened
    def getSWVersion(self):
        self._apiTrace(f"Get SW Version from {self.alias}")
        return self._getSWVersion()

    @closeConnectionAfterUse
    def getActiveAlarms(self, textFormat):
        self._apiTrace(f"Get active alarms from {self.alias}")
        return self._getActiveAlarms(textFormat)

    @closeConnectionAfterUse
    def getScfFile(self, dir, file, timeout=30, with_auto_configured_parameters=False):
        self._apiTrace(f"Get SCF File from {self.alias}")
        file = self._getScfFile(dir=dir, file=file, timeout=timeout,
                                with_auto_configured_parameters=with_auto_configured_parameters)
        self._apiTrace(f"The SCF file was stored here: {file}")
        return file

    @closeConnectionAfterUse
    def getSnapshot(self, path, prefix, isTimeStamped, timeout):
        self._apiTrace(f"Get Snapshot from {self.alias}")
        finalPath = OsTool.getSnapshotPath(path, prefix, isTimeStamped, self._getPostfix())
        self._getSnapshot(path=finalPath, timeout=timeout)
        return finalPath

    @closeConnectionAfterUse
    def cellLock(self, state, cell_id):
        self._apiTrace(f"Set cell [{cell_id}] to {state} from {self.alias}")
        self._cellLock(cell_id=cell_id, state=state)

    @closeConnectionAfterUse
    def isCellLocked(self, cell_id):
        self._apiTrace(f"Check if cell [{cell_id}] is locked from {self.alias}")
        return self._isCellLocked(cell_id=cell_id)

    @closeConnectionAfterUseWithTimeout
    def waitAvailable(self, wait_time):
        self._apiTrace(f"Wait {wait_time} until site is available [{self.alias}]")
        maxIter = int(int(wait_time) / 10)
        # Loop to reach state OK
        for i in range(1, maxIter):
            time.sleep(10)
            # ADT - add try-except to avoid exiting on error when the DB is not yet ready
            try:
                proceduralState = self._getProceduralState()
                StringTool.datedConsole(f"\tLoop {i}: procedure state = {proceduralState} "
                                        f"(waiting to be 'Configured' or 'OnAir')")
                if self._isProceduralStateOK(proceduralState):
                    break
            except Exception as e:
                StringTool.datedConsole(f"\tLoop {i}: Failed to get procedural state")

        # Trace error if still not reached
        if not self._isProceduralStateOK(proceduralState):
            StringTool.datedConsole(f"ERROR:OAM {self.alias} is in BAD state ({proceduralState})")
            return False
        return True

    @closeConnectionAfterUse
    def validateScfOnline(self, scf_file, skip_relation_errors):
        self._apiTrace(f"Validate SCF On Line:{scf_file} from {self.alias} "
                       f"(skip_relation_errors={skip_relation_errors})")
        return self._validateScfOnline(scf_file=scf_file, skip_relation_errors=skip_relation_errors)

    @closeConnectionAfterUse
    def fullCommissioning(self, scf_file, skip_relation_errors):
        self._apiTrace(f"Full commissioning SCF:{scf_file} from {self.alias} "
                       f"(skip_relation_errors={skip_relation_errors})")
        return self._fullCommissioning(scf_file=scf_file, skip_relation_errors=skip_relation_errors)

    @closeConnectionAfterUse
    def setParams(self, modify_param, timeout=60):
        self._apiTrace(f"Set Params from {self.alias} (timeout={timeout})")
        return self._setParams(modify_param=modify_param, timeout=timeout)

    @closeConnectionAfterUse
    def changeStringInScf(self, scfFilePath, oldVal, newVal):
        return self._changeStringInScf(scfFilePath, oldVal, newVal)

    def sbtsConnect(self):
        self._apiTrace(f"SBTS Connect to {self.alias} [URL={self.url}:{self.httpConnection.port} "
                       f"({self.httpConnection.username}/{self.httpConnection.password})]")
        self.sbtsDrvRef = self._sbtsConnect()
        return self.httpAlias

    def sbtsDisconnect(self):
        self._apiTrace(f"SBTS Disconnect from {self.alias}")
        if self.sbtsDrvRef is not None:
            # We attempt a disconnect, but it can fail if OAM set param occured a OAM reboot
            # then, reference to OAM is no more operational
            try:
                self._sbtsDisconnect()
            except Exception as e:
                StringTool.datedConsole("SBTS disconnect failed (connection previously lost due to OAM reboot)")
        self.sbtsDrvRef = None

    @sbtsLetConnectionOpened
    def sbtsRunOamCmd(self, cmd, cmdArgs=None):
        self._apiTrace(f"SBTS Run command {cmd} on {self.alias}'")
        return self._sbtsRunOamCmd(cmd, cmdArgs)

    @closeConnectionAfterUse
    def getNrDrbDn(self, call_type, bearer_id):
        self._apiTrace(f"Get nrDrbDN for {call_type} call and bearerId {bearer_id} from {self.alias}")
        return self._getNrDrbDn(call_type=call_type, bearer_id=bearer_id)

    @closeConnectionAfterUse
    def getNrCellGrp(self, nr_cell_id):
        self._apiTrace(f"Get NRCELLGRP including NRCellId {nr_cell_id} in its nrCellList from {self.alias}")
        return self._getNrCellGrp(nr_cell_id=nr_cell_id)

    @closeConnectionAfterUse
    def isItemValuePresentInItemName(self, item_name, item_value):
        self._apiTrace(f"Check if {item_name} number {item_value} is present in {self.alias}")
        return self._isItemValuePresentInItemName(item_name=item_name, item_value=item_value)

    @closeConnectionAfterUse
    def getParameterByDistname(self, dist_name, parameter_list, include_children, timeout, detailed_output):
        self._apiTrace(f"Get parameter by distname '{dist_name}' from {self.alias}")
        if TLConfig.topo.archi.isAic():
            return self.getParam(param=parameter_list, dn=dist_name)
        return self._getParameterByDistname(dist_name=dist_name, parameter_list=parameter_list,
                                            include_children=include_children, timeout=timeout,
                                            detailed_output=detailed_output)


# ======================================================================================
# OAM FOR CLASSICAL
# ======================================================================================


class OamClassical(Oam):

    def __init__(self, sshConnection, httpConnection, hw=Enums.HW.GNB, unit=Enums.Unit.DU, index=0, proxy=None):
        super(OamClassical, self).__init__(sshConnection=sshConnection,
                                           httpConnection=httpConnection,
                                           hw=hw, unit=unit, index=index, proxy=proxy)

    # -----------------
    # Internal services
    # -----------------
    def _getCellIdFormatted(self, cell_id):
        cells_info = self.drvRef.get_cells_info(connection=self.httpAlias)
        if len(cell_id) == 0:
            cell_id = cells_info[0]['globalCellId']
        cell_id = int(cell_id)
        StringTool.datedConsole(f"Cell_id={cell_id} type=[{type(cell_id)}]")
        return cell_id

    # -----------------
    # External API wrapped
    # -----------------
    def _connect(self):
        self.drvRef = sbts_coam()
        self.drvRef.connect_to(bts_host=self.httpConnection.addr, name=self.httpAlias)
        return self.drvRef

    def _getParameterByDistname(self, dist_name, parameter_list, include_children, timeout, detailed_output):
        try:
            result = self.drvRef.get_parameter_by_distname(dist_name=dist_name,
                                                           parameter_list=parameter_list,
                                                           include_children=include_children,
                                                           timeout=timeout,
                                                           detailed_output=detailed_output,
                                                           connection=self.httpAlias)
            StringTool.datedConsole(f"Success to get parameter by distname '{dist_name}' result='{result}'")
            return result
        except Exception as e:
            StringTool.datedConsole(f"An error occurred during get parameter by distname: '{e}'")
        return None

    def _disconnect(self):
        self.drvRef.teardown(connection=self.httpAlias)

    def _isActiveConnection(self):
        try:
            data = self.drvRef.get_sw_version(connection=self.httpAlias)
        except Exception as e:
            StringTool.datedConsole("Failure to get software version using the existing connection")
            StringTool.datedConsole("    --> the current connection is not active anymore")
            StringTool.datedConsole(f"Exception = {e}")
            return False
        StringTool.datedConsole("        Success to get software version using the existing connection")
        StringTool.datedConsole("        --> the current connection is still active")
        return True

    def _startReset(self):
        self.drvRef.reset_site(connection=self.httpAlias, wait_for_reconnection=True)
        StringTool.datedConsole("Site is now up...")

    def _softwareUpdate(self, sw_package, should_activate, timeout):
        self._apiTrace(f"... software update with load: {sw_package}")
        result = self.drvRef.update_software(sw_package=sw_package, should_activate=should_activate,
                                             timeout=timeout, connection=self.httpAlias)
        self._apiTrace(f"... software update result is: {result}")
        return result

    def _waitSiteAvailable(self):
        self._notSupported("waitSiteAvailable")

    def _getIdx(self, pci):
        pci5x = [50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62]
        pci10x = [101, 102, 103, 104, 105, 106, 107, 108, 109, 100, 101, 102, 103]
        pci23x = [239, 237, 238, 242, 240, 241, 243, 244, 245, 246, 247, 248, 249]  # CNI-102921 case
        if pci in pci5x:
            return pci5x.index(pci)
        if pci in pci10x:
            return pci10x.index(pci)
        # CNI-102921 case:
        if pci in pci23x:
            return pci23x.index(pci)
        StringTool.consoleError(f"ERROR searching for physicalCellId {pci}. Please contact AF team")
        return -1

    def _getBtsInfo(self):
        btsInfo = self.drvRef.get_bts_info(connection=self.httpAlias)
        mrbts = btsInfo['mrbtsID']
        # build the list of available cells (max = 12 cells)
        cellDnList = [None, None, None, None, None, None, None, None, None, None, None, None, None]
        cellIdList = [None, None, None, None, None, None, None, None, None, None, None, None, None]
        nbOfNrCells = 0
        for cell in btsInfo['cells']['nr']:
            idx = self._getIdx(cell['physicalCellId'])
            if idx != -1:
                cellDnList[idx] = cell['id']['configuration']
                cellIdList[idx] = cell['globalCellId']
                nbOfNrCells += 1
        # get information related to the 1st cell
        for cellDn in cellDnList:
            if cellDn is not None:
                nrcell = cellDn
                cellIdx = cellDnList.index(cellDn)
                nrcellId = cellIdList[cellIdx]
                break
        nrbts = (nrcell.split("/")[1]).split("-")[1]
        # Collect all cell groups and select the lowest index
        listCellGrp = []
        for cellGrp in btsInfo['cellsGroup']:
            listCellGrp.append(cellGrp['name'])
        listCellGrp.sort()
        nrCellGrp = listCellGrp[0]
        self._setGlobalVariables(btsInfo=btsInfo, mrbts=mrbts, nrcell=nrcell, nbOfNrCells=nbOfNrCells,
                                 nrbts=nrbts, nrCellGrp=nrCellGrp,
                                 nrcellId=nrcellId, cellDnList=cellDnList, cellIdList=cellIdList)

    def _getBtsInfoRaw(self):
        btsInfo = self._runOamCmd("get_bts_info")
        return btsInfo

    def _runOamCmd(self, cmd, cmdArgs=None):
        tmpCmdArgs = "connection=self.httpAlias"
        if (cmdArgs is not None):
            for key, value in cmdArgs.items():
                tmpCmdArgs = tmpCmdArgs + f",{key}={value}"
        oamCmd = "self.drvRef." + cmd + "(" + tmpCmdArgs + ")"
        StringTool.datedConsole(f"OAM full command is <{oamCmd}>")
        data = eval(oamCmd)
        return data

    def _getCellsNr(self):
        btsInfo = self.drvRef.get_bts_info(connection=self.httpAlias)
        return btsInfo['cells']['nr']

    def _getSWVersion(self):
        return self.drvRef.get_sw_version(connection=self.httpAlias)

    def _getActiveAlarms(self, textFormat):
        txtAlarms = []
        listAlarms = self.drvRef.get_active_alarms(connection=self.httpAlias)
        # Format is native one (dictionary)
        if not textFormat:
            return listAlarms
        # Else : format is text
        for alarm in listAlarms:
            alarmingObjectIds = alarm['alarmingObjectIds']
            supplInfo = ((alarm['alarmText'])['alarmAdditionalInfo'])['supplAlarmInfo']
            alarmNm = alarm['alarmName'].encode('ascii', 'ignore')
            alarmDet = alarm['alarmDetail'].encode('ascii', 'ignore')
            alarmObjId = (alarmingObjectIds[0])['configuration'].encode('ascii', 'ignore')
            prefix_info = f"[{alarm['alarmId']}][{alarm['faultId']}]({alarm['severity']})"
            txtAlarms.append(f"{prefix_info} {alarmNm} :{alarmDet} [{alarmObjId}] [{supplInfo}]")
        return txtAlarms

    def _getScfFile(self, dir, file, timeout, with_auto_configured_parameters=False):
        return self.drvRef.get_current_scf_file(local_dir_path=dir, file_name=file,
                                                timeout=timeout,
                                                with_auto_configured_parameters=with_auto_configured_parameters,
                                                connection=self.httpAlias)

    def _getSnapshot(self, path, timeout):
        self.drvRef.get_snapshot(target_file_name=path, coverage="Full", force=True,
                                 timeout=timeout, connection=self.httpAlias)

    def _cellLock(self, cell_id, state):
        cell_dn = 'notfound'
        do_nothing = False
        cells_info = self.drvRef.get_cells_info(connection=self.httpAlias)
        for c in cells_info:
            if c['globalCellId'] == int(cell_id):
                cell_dn = c['id']['configuration']
                if state == "LOCK" and c['status']['blockingState'] != 'Unblocked':
                    # A warning message is sufficient:
                    StringTool.datedConsole(f"WARNING : CELL already blocked ==> {cell_dn}:{c['blocking_state']}")
                    do_nothing = True
                if state == "UNLOCK" and c['status']['blockingState'] != 'Blocked':
                    # A warning message is sufficient:
                    StringTool.datedConsole(f"WARNING: CELL already unblocked ==> {cell_dn}:{c['blocking_state']}")
                    do_nothing = True
                break
        if cell_dn == 'notfound':
            raise Exception(f"CELL ID: {cell_id} not FOUND")
        if do_nothing:
            return
        if state == "LOCK":
            self.drvRef.block_cell(dist_name=cell_dn, connection=self.httpAlias)
        else:
            self.drvRef.unblock_cell(dist_name=cell_dn, connection=self.httpAlias)
        time.sleep(30)

    def _getProceduralState(self):
        btsStatus = self.drvRef.get_bts_statuses(connection=self.httpAlias)
        return btsStatus['proceduralState']

    def _validateScfOnline(self, scf_file, skip_relation_errors):
        return self.drvRef.validate_scf_online(scf_file=scf_file,
                                               skip_parameter_relation_errors=skip_relation_errors,
                                               timeout=120,
                                               connection=self.httpAlias)

    def _fullCommissioning(self, scf_file, skip_relation_errors):
        return self.drvRef.perform_commissioning(scf_file=scf_file,
                                                 skip_parameter_relation_errors=skip_relation_errors,
                                                 timeout=600,
                                                 connection=self.httpAlias)

    def _setParams(self, modify_param, timeout):
        StringTool.datedConsole(f"OAM Set Params:\n\t{modify_param}")
        para_file = coam_parameter.create_update_parameters_delta(parameters=modify_param, connection=self.httpAlias)
        status = coam_parameter.perform_scf_delta_commission(delta_file=para_file['updated'], timeout=timeout,
                                                             connection=self.httpAlias)
        StringTool.datedConsole(f"OAM Set Params:status=[{status}]")
        assert "PASS" in status, f"OAM Set Params:status was {status} (expected [PASS] or [RESET_PASS])"
        self.waitAvailable(wait_time=300)
        return status

    def _changeStringInScf(self, scfFilePath, oldVal, newVal):
        outfilePath = None
        if os.path.isfile(scfFilePath):
            fin = open(scfFilePath, "rt")
            outdir = os.path.dirname(scfFilePath)
            outfilePath = outdir + "/scfmodified.xml"
            fout = open(outfilePath, "wt")
            for line in fin:
                fout.write(line.replace(oldVal, newVal))
            fin.close()
            fout.close()
        return outfilePath

    def _sbtsConnect(self):
        self.sbtsDrvRef = sbts_coam()
        self.sbtsDrvRef.connect_to(bts_host=self.httpConnection.addr, name=self.sbtsHttpAlias)
        return self.sbtsDrvRef

    def _sbtsDisconnect(self):
        self.sbtsDrvRef.teardown(connection=self.sbtsHttpAlias)

    def _sbtsRunOamCmd(self, cmd, cmdArgs=None):
        tmpCmdArgs = "connection=self.sbtsHttpAlias"
        if (cmdArgs is not None):
            for key, value in cmdArgs.items():
                tmpCmdArgs = tmpCmdArgs + f",{key}={value}"
        oamCmd = "self.sbtsDrvRef." + cmd + "(" + tmpCmdArgs + ")"
        StringTool.datedConsole(f"OAM full command is <{oamCmd}>")
        data = eval(oamCmd)
        return data

    def _getNrDrbDn(self, call_type, bearer_id):
        # Input parameters check:
        if call_type == "NSA":
            list_name = "qciValueList"
            nr_drb_type = "NRDRB_QCI"
        elif call_type == "SA":
            list_name = "fiveqiValueList"
            nr_drb_type = "NRDRB_5QI"
        else:
            StringTool.consoleError(f"<{call_type}>: not managed by OAM_Get_NrDrbDN. Please contact AF team")
            return None

        pattern = re.compile(f'MRBTS-[0-9]*/NRBTS-[0-9]*/{nr_drb_type}-[0-9]*')
        nr_drb_dn = None
        # get, read and parse the SCF file
        scf_file = self._getScfFile(dir="/tmp", file="scf.xml", timeout=30)
        with open(scf_file, 'r') as file:
            data = file.read()
        matches = pattern.findall(data)
        StringTool.prefixDatedConsole(f"Discovered {nr_drb_type} list is: {matches}")
        # For each item found, search the expected list_name to get the nrDrbDN value:
        for item in matches:
            value = coam_parameter.get_single_value_from_scf_file(parameter=list_name,
                                                                  dist_name=item,
                                                                  local_dir_path=scf_file,
                                                                  connection=self.httpAlias)
            result = self._searchValueInList(value, str(bearer_id))
            if result:
                nr_drb_dn = coam_parameter.get_single_value_from_scf_file(parameter="nrDrbDN",
                                                                          dist_name=item,
                                                                          connection=self.httpAlias)
            if nr_drb_dn is not None:
                break
        # cleanup of all temporary scf files and return the discovered nrDrbDN value
        cmd_clean = f"rm {scf_file}"
        result = OsTool.execCmd(cmd_clean)
        return nr_drb_dn

    def _getNrCellGrp(self, nr_cell_id):
        list_name = "nrCellList"
        pattern = re.compile('MRBTS-[0-9]*/NRBTS-[0-9]*/NRCELLGRP-[0-9]*')
        nr_cellgrp_dn = ""
        # get, read and parse the SCF file
        scf_file = self._getScfFile(dir="/tmp", file="scf.xml", timeout=30)
        with open(scf_file, 'r') as file:
            data = file.read()
        matches = pattern.findall(data)
        StringTool.prefixDatedConsole(f"Discovered NRCELLGRP list is: {matches}")
        # For each item found, check if NR Cell Id is present in the nrCellList param:
        for item in matches:
            value = coam_parameter.get_single_value_from_scf_file(parameter=list_name,
                                                                  dist_name=item,
                                                                  local_dir_path=scf_file,
                                                                  connection=self.httpAlias)
            result = self._searchValueInList(value, str(nr_cell_id))
            if result:
                nr_cellgrp_dn = item
                break
        # cleanup of all temporary scf files and return the discovered NRCELLGRP value
        cmd_clean = f"rm {scf_file}"
        result = OsTool.execCmd(cmd_clean)
        self.disconnect()                                       # RDH DEBUG: utile ou pas ?
        return nr_cellgrp_dn

    def _searchValueInList(self, list, value):
        for elem in list:
            if elem == value:
                return True
        return False

    def _isItemValuePresentInItemName(self, item_name, item_value):
        txtAlarms = []
        found = False
        listAlarms = self.drvRef.get_active_alarms(connection=self.httpAlias)
        for alarm in listAlarms:
            txtAlarms.append(f"{alarm[item_name]}")
        StringTool.datedConsole(f"{item_name} are:{txtAlarms}")
        if txtAlarms.count(item_value) > 0:
            found = True
        StringTool.datedConsole(f"{item_name} {item_value} found {txtAlarms.count(item_value)} times")
        return found


# ======================================================================================
# OAM FOR Generic Cloud
# ======================================================================================


class OamCloud(Oam):

    def _connect(self):
        self.drvRef = cu()
        self.drvRef.connect_to(host=self.httpConnection.addr,
                               username=self.httpConnection.username,
                               password=self.httpConnection.password,
                               port=self.httpConnection.port,
                               # cu_version="cuoam_19b",
                               secure=True)
        return self.drvRef

    def _disconnect(self):
        self.drvRef.disconnect()

    def _isActiveConnection(self):
        try:
            swVersion = self.drvRef.get_active_software_version(connection=self.httpAlias)
        except Exception as e:
            StringTool.datedConsole("Failure to get software version using the existing connection")
            StringTool.datedConsole("    --> the current connection is not active anymore")
            StringTool.datedConsole(f"Exception = {e}")
            return False
        StringTool.datedConsole("        Success to get software version using the existing connection")
        StringTool.datedConsole("        --> the current connection is still active")
        return True

    def _startReset(self):
        res = self.drvRef.reset_cu()
        StringTool.datedConsole(f"VCU _startReset: {res}")

    def _isVcuEnabled(self):
        try:
            out = self.drvRef.get_cu_state()
        except Exception as e:
            raise Exception(f"VCU _isVcuEnabled Exception: {e}")
        StringTool.datedConsole(f"VCU _isVcuEnabled State  : {out['operational_state']}")
        if out['operational_state'] == 'enabled':
            return True
        return False

    def _getBtsInfo(self):
        btsInfo = self.drvRef.get_cu_state()
        nrbts = 1
        mrbts = btsInfo['mrbts_id']
        nrcell = f"NRBTS-{nrbts}/NRCELL-1"
        self._setGlobalVariables(btsInfo=btsInfo, mrbts=mrbts, nrcell=nrcell, nbOfNrCells=1,
                                 nrbts=nrbts, nrCellGrp=None,
                                 nrcellId=None, cellDnList=None, cellIdList=None)

    def _getCellsNr(self):
        btsInfo = self.drvRef.get_cu_state()
        return btsInfo['cells']['nr']

    def _getSWVersion(self):
        return self.drvRef.get_active_software_version()

    def _getActiveAlarms(self, textFormat):
        return self.drvRef.get_active_alarms()

    def _getScfFile(self, dir, file, timeout, with_auto_configured_parameters=False):
        scf_file_path = os.path.join(dir, file)
        plan_file = self.drvRef.get_current_plan_file(path=scf_file_path,
                                                      include_runtime_data=False,
                                                      timeout=timeout)
        result = "".join((scf_file_path, plan_file))
        return scf_file_path

    def _getSnapshot(self, path, timeout):
        file_path, file_name = os.path.split(path)
        self.drvRef.get_local_snapshot(directory=file_path,
                                       request_timeout=None,
                                       operation_timeout=timeout)

    def _cellLock(self, cell_id, state):
        self._notSupported("cellLock")

    def _isCellLocked(self, cell_id):
        self._notSupported("isCellLocked")

    def _getProceduralState(self):
        # self._notSupported("getProceduralState")
        output = self.drvRef.get_cu_state()
        cu_state = output['operational_state']  # return enabled if OK
        StringTool.datedConsole(f"CU State  : {cu_state}")
        if cu_state == 'enabled':
            return 'Configured'
        return 'Disabled'

    def _check_operation_state(self, *args, **kwargs):
        method = kwargs.pop('method')
        method_callable = getattr(self.drvRef, method)
        output = method_callable(*args, **kwargs)
        status = output['status']
        StringTool.datedConsole(f"CU Check_op: ... {method}:  {status}")
        msg = 'No change in this plan. : No change in this plan.'
        if status == 'failure':
            if method == 'get_action_state_of_validating_delta_plan' and output['error_message'] == msg:
                StringTool.datedConsole(f"CU Check_op {method} WARNING !!!!: No changes in delta plan.")
            elif method == 'get_operation_state_of_activating_delta_plan' and \
                    output['error_message'] == 'No change in this plan.':
                StringTool.datedConsole(f"CU Check_op {method} WARNING !!!!: No changes in delta plan.")
            else:
                self.testnok = True
            StringTool.datedConsole(f"CU Check_op: FAILED ... {method}:  {output}")
            return True
        elif status == 'ongoing':
            return False
        elif status == 'success':
            return True
        StringTool.datedConsole(f"CU Check_op {method}:  {output}")
        return True

    def getParam(self, param):
        self._connectIfRequired()
        res = self.drvRef.search_parameters_of_current_plan(parameter_name=param)
        StringTool.datedConsole(f"VCU getParam {param}={res}")

    def _setParams(self, modify_param, timeout=60):
        self.testnok = False
        self._clean_plan()
        self.timeout = 60
        StringTool.datedConsole(f" - CU Set Params:\n\t{modify_param}")
        delta_out = self.drvRef.generate_delta_plan(plan_name='delta_plan_from_AF')
        self.plan_id = delta_out['plan_id']
        StringTool.datedConsole(f" - CU Set Params plan_id: {self.plan_id}")
        if not self._launch_op('get_action_state_of_generating_delta_plan', delta_out['action_id']):
            return self._setParamError("GENERATING DELTA PLAN")
        uuid = None
        delta_plan_tree = self.drvRef.get_delta_plan_tree_diff(plan_id=self.plan_id)

        # list from classical (to be compliant):
        # [{'parameter': 'enDcSyncStatus', 'dist_name': 'MRBTS-1/NRBTS-1/NRCELL-1', 'value': 'asynchronous'}, {}, ...]
        # the 'operation' key is optional and set to 'replace' by default

        for p in modify_param:
            param_list = []
            modn = p['dist_name'].split('/')[-1]
            op = p['operation'] if 'operation' in p else 'replace'
            param_dict = {'operation_type': op, 'parameter_path': '/' + p['parameter'], 'value': p['value']}
            param_list.append(param_dict)

            for mo_info in delta_plan_tree["created"]:
                if mo_info["name"] == modn:
                    uuid = mo_info["mo_uuid"]
                    StringTool.datedConsole(f" - CU uuid for {mo_info['name']}:{uuid}")
                    break
            if uuid is None:
                StringTool.datedConsole(f" - CU uuid not found for provided dist_name {modn}")
                return self._setParamError("UUID NOT FOUND")
            update_out = self.drvRef.update_parameters_of_delta_plan(plan_id=self.plan_id,
                                                                     mo_uuid=uuid, parameter_change_list=param_list)

            if not self._launch_op('get_action_state_of_updating_parameters_of_delta_plan', update_out["action_id"]):
                return self._setParamError("UPDATING DELTA PLAN")

        valid_out = self.drvRef.validate_delta_plan(plan_id=self.plan_id)
        if not self._launch_op('get_action_state_of_validating_delta_plan', valid_out["action_id"]):
            return self._setParamError("VALIDATING DELTA PLAN")
        self.timeout = timeout
        activ_out = self.drvRef.activate_delta_plan(plan_id=self.plan_id)
        if not self._launch_op('get_operation_state_of_activating_delta_plan', activ_out['operation_id']):
            return self._setParamError("ACTIVATING DELTA PLAN")
        self._clean_plan()
        return self._setParamError()

    def _launch_op(self, op, action):
        if op == 'get_action_state_of_generating_delta_plan':
            OsTool.waitUntil(retry=self.timeout, retry_interval=5, keyword=self._check_operation_state,
                             action_id=action, method=op)
        elif op == 'get_operation_state_of_activating_delta_plan':
            OsTool.waitUntil(retry=self.timeout, retry_interval=90, keyword=self._check_operation_state,
                             operation_id=action, plan_id=self.plan_id, method=op)
        else:
            OsTool.waitUntil(retry=self.timeout, retry_interval=5, keyword=self._check_operation_state,
                             action_id=action, plan_id=self.plan_id, method=op)
        if self.testnok:
            return False
        return True

    def _clean_plan(self):
        plan_list = self.drvRef.get_delta_plan_list()
        for plan in plan_list:
            StringTool.datedConsole(f"VCU Clean_plan plan: {plan}")
            if plan["plan_name"] == 'delta_plan_from_AF':
                self.drvRef.delete_delta_plan(plan['plan_id'])

    def remove_all_plan(self):
        self._connectIfRequired()
        plan_list = self.drvRef.get_delta_plan_list()
        for plan in plan_list:
            StringTool.datedConsole(f"VCU remove_all_plan removing delta plan: {plan}")
            self.drvRef.delete_delta_plan(plan['plan_id'])
        plan_list = self.drvRef.get_plan_info()
        for plan in plan_list:
            StringTool.datedConsole(f"VCU remove_all_plan removing plan: {plan}")
            self.drvRef.plan_delete(plan['plan_id'])

    def _fullCommissioning(self, scf_file, skip_relation_errors):
        # Upload Plan File:
        StringTool.datedConsole("CU scf: Plan File Uploading...")
        output = self.drvRef.upload_plan_file(path_to_plan_file=scf_file)
        plan_id = output["plan_id"]
        time.sleep(15)

        # Plan Validation:
        StringTool.datedConsole("CU scf: Plan File Validation...")
        output = self.drvRef.plan_validation(plan_id=plan_id)
        action_id = output['action_id']
        time.sleep(10)
        OsTool.waitUntil(retry=300, retry_interval=10, keyword=self._wait_operation_state,
                         plan_id=plan_id, operation_id=action_id, method='validating_plan')
        if self.testnok:
            raise Exception("Error during Validation")

        # Plan Activation:
        StringTool.datedConsole("CU scf: Plan File Activation...")
        output = self.drvRef.plan_activation(plan_id=plan_id)
        action_id = output['id']
        time.sleep(250)
        OsTool.waitUntil(retry=900, retry_interval=30, keyword=self._wait_operation_state,
                         plan_id=plan_id, operation_id=action_id, method='activating_plan')
        if self.testnok:
            raise Exception("Error during activation or timeout reached")

    def _wait_operation_state(self, *args, **kwargs):
        action = kwargs.pop('method')
        method = f'get_operation_state_of_{action}'
        method_callable = getattr(self.drvRef, method)
        output = method_callable(*args, **kwargs)
        status = output['status']
        StringTool.datedConsole(f"CU scf: ... {action}: {status}")
        if status != 'success':
            error_message = output['error_message'] if 'error_message' in output else None
            if error_message is not None:
                StringTool.datedConsole(f"CU scf: OPERATION FAIL: {error_message}")
            else:
                StringTool.datedConsole(f"CU scf: ... output: {output}")
            self.testnok = True
            return False
        self.testnok = False
        return True

    def _getNrDrbDn(self, call_type, bearer_id):
        StringTool.consoleError("OAM Get NrDrbDN is not designed for Generic Cloud. Please contact AF team")
        return None

    def _getNrCellGrp(self, nr_cell_id):
        StringTool.consoleError("OAM Get NR Cell GROUP is not designed for Generic Cloud. Please contact AF team")
        return None

    def _isItemValuePresentInItemName(self, item_name, item_value):
        StringTool.consoleError(f"OAM Is {item_name} Present is not designed for Generic Cloud. Please contact AF team")
        return None

    def _softwareUpdate(self, sw_package, should_activate, timeout):
        error_msg = "OAM Software Update is not designed for Generic Cloud. Please contact AF team"
        StringTool.consoleError(error_msg)
        return error_msg


# ======================================================================================
# OAM FOR Cloud BTS (vRAN 1.0)
# ======================================================================================
class OamCloudBts(OamCloud):
    LIST_VM_NAME = ["CPIF", "CPCL", "CPNB", "CPUE", "UPUE"]

    def _createVMs(self):
        vms = []
        for vmName in OamCloudBts.LIST_VM_NAME:
            vm = Hosts.Host(alias=f"{self.alias}_{vmName}", proxy=self, sshConnection=self.sshConnection,
                            sshId=Oam.vmNameToSshId(vmName), isSudo=True)
            vms.append(vm)
        return vms


# ======================================================================================
# OAM FOR Cloud AIC CU (vRAN 2.0)
# ======================================================================================
class OamCloudAicCU(OamCloud):

    def __init__(self, sshConnection, httpConnection, hw=Enums.HW.GNB, unit=Enums.Unit.DU, index=0, proxy=None):
        super(OamCloudAicCU, self).__init__(sshConnection=sshConnection,
                                            httpConnection=httpConnection,
                                            hw=hw, unit=unit, index=index, proxy=proxy)

    def _connect(self):
        self.drvRef = cu()
        self.drvRef.connect_to(host=self.httpConnection.addr,
                               username=self.httpConnection.username,
                               password=self.httpConnection.password,
                               port='',
                               secure=True)
        return self.drvRef

    def _disconnect(self):
        self.drvRef.disconnect()

    def _isActiveConnection(self):
        try:
            data = self.drvRef.get_active_software_version()
        except Exception as e:
            StringTool.datedConsole("Failure to get software version using the existing connection")
            StringTool.datedConsole("    --> the current connection is not active anymore")
            StringTool.datedConsole(f"Exception = {e}")
            return False
        StringTool.datedConsole("        Success to get software version using the existing connection")
        StringTool.datedConsole("        --> the current connection is still active")
        return True

    def _connect21(self):
        self.drvRef21b = cu()
        self.drvRef21b.connect_to(host=self.httpConnection.addr,
                                  username=self.httpConnection.username,
                                  password=self.httpConnection.password,
                                  port=self.httpConnection.port,
                                  secure=True)
        return self.drvRef21b

    def _disconnect21(self):
        self.drvRef21b.disconnect()

    def _getActiveAlarms(self, textFormat):
        txtAlarms = []
        cuAlarms = self.drvRef.get_active_alarms()
        listAlarms = cuAlarms.get('alarms', cuAlarms)
        if not textFormat:
            return listAlarms
        for alarm in listAlarms:
            txtAlarms.append(f"[{alarm['alarm_id']}][{alarm['fault_id']}]({alarm['severity']}) "
                             f"{alarm['alarm_name']:40}:{alarm['additional_info']} "
                             f"[{alarm['alarming_object']}]")

        return txtAlarms

    def _getSWVersion(self):
        swVersion = self.drvRef.get_active_software_version()
        StringTool.datedConsole(f"VCU software version is: {swVersion}")
        return swVersion

    def _getIdx(self, pci):
        pci5x = [50, 51, 52, 53, 54, 55, 56, 57, 58]
        pci10x = [101, 102, 103, 104, 105, 106, 107, 108, 109]
        if pci in pci5x:
            return pci5x.index(pci)
        if pci in pci10x:
            return pci10x.index(pci)
        StringTool.consoleError(f"ERROR searching for physicalCellId {pci}. Please contact AF team")
        return -1

    def _getPostfix(self):
        return f"_{self.unit}"

    def _getBtsInfo(self):
        localScf = self.getScfFile(dir="/tmp", file="TmpVcu.xml")
        btsInfo = XmlScf.get_bts_Infos(localScf)
        mrbtsId = btsInfo["mrbts_id"]
        nrbtsId = btsInfo["nrbts_id"]
        nrcellId = btsInfo["nrcell_Id"]
        nrcellDn = btsInfo["nrcell_DN"]
        nrcellGrpId = "NRCELLGRP-" + btsInfo["nrcell_Grp_Id"]
        nrcellDnList = btsInfo["nrcell_DN_list"]
        nrcellGrpIdList = btsInfo["cell_Grp_Id_list"]
        # build the list of available cells (max = 9 cells)
        nrcellIdList = [None, None, None, None, None, None, None, None, None]
        index = 0
        nbOfNrCells = 0
        for cell in btsInfo['nrcell_Id_list']:
            nrcellIdList[index] = int(cell)
            index += 1
            nbOfNrCells += 1
        self._setGlobalVariables(btsInfo=None, mrbts=mrbtsId, nrcell=nrcellDn, nbOfNrCells=nbOfNrCells,
                                 nrbts=nrbtsId, nrCellGrp=nrcellGrpId,
                                 nrcellId=nrcellId, cellDnList=nrcellDnList, cellIdList=nrcellIdList)

    def _getCellsNr(self):
        btsInfo = self.drvRef.get_cu_state()
        return btsInfo['cells']['nr']

    def get_counter_c2(self, counter_id, dimension_dn):
        self._connect21()
        measurement_p = "55323"
        ret_error = "EMPTY"
        last_val_retrieved = 0
        if OsTool.pmcDebug():
            StringTool.datedConsole(f" - TEST_BEGIN get_counter_c ===> {'test'} <===")
            StringTool.datedConsole(f" - TEST get_counter_c2 counter_id ===> {counter_id} <===")
            StringTool.datedConsole(f" - TEST get_counter_c2 dimension_dn ===> {dimension_dn} <===")
            StringTool.datedConsole(f" - TEST get_counter_c2 measurement_p ===> {measurement_p} <===")
        val = self.drvRef21b.get_counter(measurement_id=measurement_p,
                                         dimension_dist_name=dimension_dn, counter_id=counter_id)
        if OsTool.pmcDebug():
            StringTool.datedConsole(f" - VCU get_counter ret_c2 ===> {val} <===")
        if len(val) == 0:
            StringTool.datedConsole(f" - ERROR get_counter empty===> {val} <===")
        for s2, v2 in val.items():
            if OsTool.pmcDebug():
                StringTool.datedConsole(f" - VCU s2 v2 ===> {s2} {v2} <===")
            if s2 == "values":
                if OsTool.pmcDebug():
                    StringTool.datedConsole(f" - VCU s2 is value ===> {s2} <===")
                    StringTool.datedConsole(f" - VCU v2 is value ===> {v2} <===")
                if len(v2) == 0:
                    StringTool.datedConsole(f" - ERROR get_counter v2_empty===> {v2} <===")
                    return ret_error
                # GET_SUM
                # sort
                v2.sort(key=operator.itemgetter('start_time'))
                if OsTool.pmcDebug():
                    StringTool.datedConsole(f" - VCU v2 is value after sort ===> {v2} <===")
                    # extract last
                    StringTool.datedConsole(f" - VCU type v2 last ===> {v2[-1]} <===")
                last_el = v2[-1]
                for s5, v5 in last_el.items():
                    if s5 == "start_time":
                        if OsTool.pmcDebug():
                            StringTool.datedConsole(f" - VCU last val date ===> {v5} <===")
                    if s5 == "value":
                        if OsTool.pmcDebug():
                            StringTool.datedConsole(f" - VCU last val date----------- ===> {v5} <===")
                        last_val_retrieved = v5
        StringTool.datedConsole(f" - last_val_retrieved------------ ===> {last_val_retrieved} <===")
        self._disconnect21()
        return last_val_retrieved

    def get_counter_sum_c2(self, counter_id, dimension_dn):
        self._connect21()
        measurement_p = "55323"
        ret_error = "EMPTY"
        sum_retrieved = 0
        if OsTool.pmcDebug():
            StringTool.datedConsole(f" - TEST_BEGIN get_counter_sum_c2 ===> {'test'} <===")
            StringTool.datedConsole(f" - TEST get_counter_sum_c2 counter_id ===> {counter_id} <===")
            StringTool.datedConsole(f" - TEST get_counter_sum_c2 dimension_dn ===> {dimension_dn} <===")
            StringTool.datedConsole(f" - TEST get_counter_sum_c2 measurement_p ===> {measurement_p} <===")
        val = self.drvRef21b.get_counter(measurement_id=measurement_p,
                                         dimension_dist_name=dimension_dn, counter_id=counter_id)
        if OsTool.pmcDebug():
            StringTool.datedConsole(f" - VCU get_counter ret_sum_c2 ===> {val} <===")
        if len(val) == 0:
            StringTool.datedConsole(f" - ERROR get_counter empty===> {val} <===")
        if OsTool.pmcDebug():
            StringTool.datedConsole(f" - VCU get_counter ===> {val} <===")
        for s2, v2 in val.items():
            if OsTool.pmcDebug():
                StringTool.datedConsole(f" - VCU s2 v2 ===> {s2} {v2} <===")
            if s2 == "values":
                if OsTool.pmcDebug():
                    StringTool.datedConsole(f" - VCU s2 is value ===> {s2} <===")
                    StringTool.datedConsole(f" - VCU v2 is value ===> {v2} <===")
                # ERROR CASE, return
                if len(v2) == 0:
                    StringTool.datedConsole(f" - ERROR get_counter v2_empty===> {v2} <===")
                    return ret_error
                # GET_SUM
                for el in v2:
                    for s3, v3 in el.items():
                        if OsTool.pmcDebug():
                            StringTool.datedConsole(f" - VCU s3 v3 ===> {s3} {v3} <===")
                        if s3 == "start_time":
                            if OsTool.pmcDebug():
                                StringTool.datedConsole(f" - VCU val date ===> {v3} <===")
                        if s3 == "value":
                            if OsTool.pmcDebug():
                                StringTool.datedConsole(f" - VCU val retrieved ------------===> {v3} <===")
                            sum_retrieved = sum_retrieved + int(v3)
                    if OsTool.pmcDebug():
                        StringTool.datedConsole(f" - VCU  el ===> {el} <===")
        StringTool.datedConsole(f" - TOTAL sum ===> {sum_retrieved} <===")
        self._disconnect21()
        return sum_retrieved

    def get_counter_values_2(self, counter_id, dimension_dn):
        self._connect21()
        measurement_p = "55323"
        ret_error = "EMPTY"
        val_list = []
        if OsTool.pmcDebug():
            StringTool.datedConsole(f" - TEST_BEGIN get_counter_sum_c2 ===> {'test'} <===")
            StringTool.datedConsole(f" - TEST get_counter_sum_c2 counter_id ===> {counter_id} <===")
            StringTool.datedConsole(f" - TEST get_counter_sum_c2 dimension_dn ===> {dimension_dn} <===")
            StringTool.datedConsole(f" - TEST get_counter_sum_c2 measurement_p ===> {measurement_p} <===")
        val = self.drvRef21b.get_counter(measurement_id=measurement_p,
                                         dimension_dist_name=dimension_dn, counter_id=counter_id)
        if OsTool.pmcDebug():
            StringTool.datedConsole(f" - VCU get_counter ret_sum_c2 ===> {val} <===")
        if len(val) == 0:
            StringTool.datedConsole(f" - ERROR get_counter empty===> {val} <===")
        if OsTool.pmcDebug():
            StringTool.datedConsole(f" - VCU get_counter ===> {val} <===")
        for s2, v2 in val.items():
            if OsTool.pmcDebug():
                StringTool.datedConsole(f" - VCU s2 v2 ===> {s2} {v2} <===")
            if s2 == "values":
                if OsTool.pmcDebug():
                    StringTool.datedConsole(f" - VCU s2 is value ===> {s2} <===")
                    StringTool.datedConsole(f" - VCU v2 is value ===> {v2} <===")
                # ERROR CASE, return
                if len(v2) == 0:
                    StringTool.datedConsole(f" - ERROR get_counter v2_empty===> {v2} <===")
                    return ret_error
                # GET_SUM
                for el in v2:
                    for s3, v3 in el.items():
                        if OsTool.pmcDebug():
                            StringTool.datedConsole(f" - VCU s3 v3 ===> {s3} {v3} <===")
                        if s3 == "start_time":
                            if OsTool.pmcDebug():
                                StringTool.datedConsole(f" - VCU val date ===> {v3} <===")
                        if s3 == "value":
                            if OsTool.pmcDebug():
                                StringTool.datedConsole(f" - VCU val retrieved ------------===> {v3} <===")
                            val_list.append(v3)
                    if OsTool.pmcDebug():
                        StringTool.datedConsole(f" - VCU  el ===> {el} <===")
        StringTool.datedConsole(f" - TOTAL val ===> {val_list} <===")
        self._disconnect21()
        return val_list

    def _searchValueInList(self, list, value):
        for elem in list:
            if elem == value:
                return True
        return False

    def _getNrDrbDn(self, call_type, bearer_id):
        # Input parameters check:
        if call_type == "NSA":
            list_name = "qciValueList"
            nr_drb_type = "NRDRB_QCI"
        elif call_type == "SA":
            list_name = "fiveqiValueList"
            nr_drb_type = "NRDRB_5QI"
        else:
            StringTool.consoleError(f"<{call_type}>: not managed by OAM_Get_NrDrbDN. Please contact AF team")
            return None
        # Create pattern to be found in scf file:
        pattern = re.compile(f'MRBTS-[0-9]*/NRBTS-[0-9]*/{nr_drb_type}-[0-9]*')
        # Get, read and parse the SCF file:
        scf_file = self.getScfFile(dir="/tmp", file="scf_cu.xml", timeout=30)
        with open(scf_file, 'r') as file:
            data = file.read()
        matches = pattern.findall(data)
        StringTool.prefixDatedConsole(f"Discovered {nr_drb_type} list is: {matches}")
        # Create an instance of MultiScf class to use its scf services:
        scf = MultiScf.MultiScf()
        scf.load_scf(second_scf_path=scf_file)
        # For each item found, search the expected list_name to get the nrDrbDN value:
        nr_drb_dn = None
        for item in matches:
            value = scf.get_value_from_scf(dist_name=item, aicListEntity='VCU',
                                           scope='Aic', list_name=list_name)
            result = self._searchValueInList(value, str(bearer_id))
            if result:
                nr_drb_dn = scf.get_value_from_scf(dist_name=item, aicListEntity='VCU',
                                                   scope='Aic', p_name="nrDrbDN")

            if nr_drb_dn is not None:
                break
        # cleanup of all temporary scf files and return the discovered nrDrbDN value
        cmd_clean = f"rm {scf_file}"
        result = OsTool.execCmd(cmd_clean)
        return nr_drb_dn

    def _getNrCellGrp(self, nr_cell_id):
        StringTool.consoleError("OAM Get NR Cell GROUP is not designed for Cloud AIC (CU). Please contact AF team")
        return None

    def _isItemValuePresentInItemName(self, item_name, item_value):
        StringTool.consoleError(f"OAM Is {item_name} Present is not designed for Cloud AIC (CU). "
                                f"Please contact AF team")
        return None

    def _softwareUpdate(self, sw_package, should_activate, timeout):
        error_msg = "OAM Software Update is not designed for Cloud AIC CU. Please contact AF team"
        StringTool.consoleError(error_msg)
        return error_msg

    def radReloadDomains(self, timeout=300):
        """
        Reload RAD domain on Cloud RAN VCU.

        This method allows RAD reload domain on the VCU entity.

        Args:
            timeout (int): Maximum wait time in seconds (default: 300)

        Returns:
            dict: Final operation result with status
        """
        self._connectIfRequired()
        StringTool.datedConsole("VCU radReloadDomains: Reloading RAD domains...")
        try:
            result = self.drvRef.rad_reload_domains(
                timeout=30,
                connection=self.httpAlias,
                use_m2m=False
            )
            result = self._wait_for_rad_debug_operation(
                operation_id=result.get('operation_id'),
                initial_status=result.get('status'),
                timeout=timeout
            )
            StringTool.datedConsole("VCU radReloadDomains: RAD domains reloaded successfully")
        except Exception as e:
            error_msg = f"VCU radReloadDomains: Failed to reload domains: {e}"
            StringTool.consoleError(error_msg)
            raise Exception(error_msg)
        return result

    def radReloadParams(self, domain_name, timeout=300):
        """
        Reload RAD parameters on Cloud RAN VCU.

        This method allows RAD reload parameters on the VCU entity.

        Args:
            domain_name (str): RAD domain name (e.g., 'L2PS', 'RLC', 'MAC')
            timeout (int): Maximum wait time in seconds (default: 300)

        Returns:
            dict: Final operation result with status
        """
        self._connectIfRequired()
        StringTool.datedConsole(f"VCU radReloadParams: Reloading params for domain {domain_name}...")
        try:
            result = self.drvRef.rad_reload_params(
                domain_name=domain_name,
                param_name=None,
                non_default_only=False,
                timeout=30,
                connection=self.httpAlias,
                use_m2m=False
            )
            result = self._wait_for_rad_debug_operation(
                operation_id=result.get('operation_id'),
                initial_status=result.get('status'),
                timeout=timeout
            )
            StringTool.datedConsole(f"VCU radReloadParams: Domain {domain_name} params reloaded successfully")
        except Exception as e:
            error_msg = f"VCU radReloadParams: Failed to reload params for {domain_name}: {e}"
            StringTool.consoleError(error_msg)
            raise Exception(error_msg)
        return result

    def _wait_for_rad_debug_operation(self, operation_id, initial_status, timeout=300):
        """
        Wait for RAD debug parameter operation to complete on VCU.

        Args:
            operation_id (str): Operation ID to monitor
            initial_status (str): Initial operation status
            timeout (int): Maximum wait time in seconds

        Returns:
            dict: Final operation result with status and operation_id
        """
        StringTool.datedConsole(f"VCU _wait_for_rad_debug_operation: Monitoring operation {operation_id}")
        result = {'operation_id': operation_id, 'status': initial_status}
        start_time = time.time()

        while result.get('status') != 'succeeded':
            if time.time() - start_time > timeout:
                error_msg = f"VCU RAD debug operation timeout after {timeout}s. Status: {result.get('status')}"
                StringTool.consoleError(error_msg)
                raise Exception(error_msg)

            current_op_id = result.get('operation_id', 'N/A')
            current_status = result.get('status', 'N/A')
            StringTool.datedConsole(f"VCU _wait_for_rad_debug_operation: op_id='{current_op_id}', "
                                    f"status='{current_status}'. Waiting...")

            try:
                result = self.drvRef.get_rad_debug_params_update_operation(
                    operation_id=operation_id,
                    timeout=30,
                    connection=self.httpAlias,
                    use_m2m=False
                )
                time.sleep(2)
            except Exception as e:
                error_msg = f"VCU _wait_for_rad_debug_operation: Error checking operation status: {e}"
                StringTool.consoleError(error_msg)
                raise Exception(error_msg)

        StringTool.datedConsole(f"VCU _wait_for_rad_debug_operation: Operation completed. Final result: {result}")
        return result

    def updateRadDebugParams(self, domain_name, parameters, persistency='persistent', timeout=300):
        """
        Configure RAD debug parameters on Cloud RAN VCU.

        This method updates RAD parameters on the VCU entity. The orchestration of domain reloads
        (before and after the update) should be done at Robot Framework level.

        Args:
            domain_name (str): RAD domain name (e.g., 'L2PS', 'RLC', 'MAC')
            parameters (list): List of parameter dicts with 'name' and 'value' keys
                              Example: [{'name': 'rdFeatureFlagBitmapLevel', 'value': '4'},
                                       {'name': 'rdFeatureFlagBitmap4', 'value': '79'}]
            persistency (str): 'persistent' or 'non-persistent' (default: 'persistent')
            timeout (int): Maximum wait time in seconds for operation completion (default: 300)

        Returns:
            dict: Final operation result with status

        Example:
            params = [{'name': 'rdFeatureFlagBitmapLevel', 'value': '4'},
                     {'name': 'rdFeatureFlagBitmap4', 'value': '79'}]
            result = oam.updateRadDebugParams(domain_name='L2PS', parameters=params)
        """
        self._connectIfRequired()
        StringTool.datedConsole(f"VCU updateRadDebugParams: domain={domain_name}, params={parameters}, "
                                f"persistency={persistency}")
        StringTool.datedConsole("VCU updateRadDebugParams: Updating RAD debug parameters...")
        try:
            result = self.drvRef.update_rad_debug_params(
                persistency=persistency,
                domain_name=domain_name,
                parameters=parameters,
                connection=self.httpAlias
            )
            StringTool.datedConsole("VCU updateRadDebugParams: execution done then waiting for success...")
            result = self._wait_for_rad_debug_operation(
                operation_id=result.get('operation_id'),
                initial_status=result.get('status'),
                timeout=timeout
            )
            StringTool.datedConsole("VCU updateRadDebugParams: Parameters updated successfully")
        except Exception as e:
            error_msg = f"VCU updateRadDebugParams: Failed to update parameters: {e}"
            StringTool.consoleError(error_msg)
            raise Exception(error_msg)
        return result


# ======================================================================================
# OAM FOR Cloud AIC (DU)
# ======================================================================================
class OamCloudAicDU(Oam):
    def _connect(self):
        self.drvRef = vdu()
        self.drvRef.connect_to(host=self.httpConnection.addr,
                               port="",
                               username=self.httpConnection.username,
                               password=self.httpConnection.password,
                               secure=True,
                               login_disabled=False,
                               connection_name=self.httpAlias)
        return self.drvRef

    def _disconnect(self):
        self.drvRef.disconnect(vdu_connection=self.httpAlias)

    def _isActiveConnection(self):
        try:
            data = self.drvRef.get_system_info(vdu_connection=self.httpAlias)
        except Exception as e:
            StringTool.datedConsole("Failure to get system info using the existing connection")
            StringTool.datedConsole("    --> the current connection is not active anymore")
            StringTool.datedConsole(f"Exception = {e}")
            return False
        StringTool.datedConsole("        Success to get system info using the existing connection")
        StringTool.datedConsole("        --> the current connection is still active")
        return True

    def _connectBis(self):
        self.drvRefBis = vdu()
        self.drvRefBis.connect_to(
            host=self.httpConnection.addr,
            port="",
            username=self.httpConnection.username,
            password=self.httpConnection.password,
            vdu_version='cuoam_19b',
            secure=True,
            login_disabled=False,
            connection_name='pm_vdu')
        return self.drvRefBis

    def _disconnectBis(self):
        self.drvRefBis.disconnect(vdu_connection='pm_vdu')

    def _getScfFile(self, dir, file, timeout, with_auto_configured_parameters=False):
        return self.drvRef.get_current_plan_file(local_dir_path=dir,
                                                 filename=file,
                                                 include_runtime_data=False,
                                                 timeout=timeout,
                                                 vdu_connection=self.httpAlias)

    def getParam(self, param, dn):
        self._connectIfRequired()
        try:
            val = self.drvRef.search_parameter_of_current_plan(
                mo_dn=dn, para_name=param, vdu_connection=self.httpAlias)
            StringTool.datedConsole(f"Success to get VDU parameter by distname '{dn}' result='{val}'")
            return val
        except Exception as e:
            StringTool.datedConsole(f"An error occurred during get parameter by distname: '{e}'")
        return None

    def getVduStateData(self):
        self._connectIfRequired()
        return self.drvRef.get_vdu_state_data(vdu_connection=self.httpAlias)

    def _startReset(self, wait=True, wait_time=120):
        self.testnok = False
        res = self.drvRef.reset_vdu(vdu_connection=self.httpAlias)
        if "No error" not in res['error_message']:
            raise Exception(f" - VDU _startReset ERROR: {res['error_message']}")
        if not self._launch_op('get_reset_vdu_operation_status', action=res['id']):
            raise Exception(" - VDU _startReset ERROR")
        StringTool.datedConsole(" - VDU _startReset: reset ongoing")

    def _isVDUEnabled(self):
        StringTool.datedConsole("VDU _isVDUEnabled")  # todo
        # if self._getProceduralState() == 'integrated to RAN':
        if self._getProceduralState() == 'integrated to RAN' or self._getProceduralState() == 'Configured':
            return True
        return False

    def _getProceduralState(self):
        try:
            out = self.drvRef.get_vdu_state_data(vdu_connection=self.httpAlias)
        except Exception as e:
            raise Exception(f"VDU _getProceduralState Exception: >{e}<")
        StringTool.datedConsole(f"VDU _getProceduralState State: >{out['operational_state']}<")
        # if out['operational_state'] != 'integrated to RAN':
        if out['operational_state'] == 'configured':
            return 'Configured'
        return out['operational_state']

    def _wait_for_rad_debug_operation(self, operation_id, initial_status, timeout=300):
        """
        Wait for RAD debug parameter operation to complete.

        Args:
            operation_id (str): Operation ID to monitor
            initial_status (str): Initial operation status
            timeout (int): Maximum wait time in seconds

        Returns:
            dict: Final operation result with status and operation_id
        """
        StringTool.datedConsole(f"VDU _wait_for_rad_debug_operation: Monitoring operation {operation_id}")
        result = {'operation_id': operation_id, 'status': initial_status}
        start_time = time.time()

        while result.get('status') != 'succeeded':
            if time.time() - start_time > timeout:
                error_msg = f"VDU RAD debug operation timeout after {timeout}s. Status: {result.get('status')}"
                StringTool.consoleError(error_msg)
                raise Exception(error_msg)

            current_op_id = result.get('operation_id', 'N/A')
            current_status = result.get('status', 'N/A')
            StringTool.datedConsole(f"VDU _wait_for_rad_debug_operation: op_id='{current_op_id}', "
                                    f"status='{current_status}'. Waiting...")

            try:
                result = self.drvRef.get_rad_debug_params_update_operation(
                    operation_id=operation_id,
                    timeout=30,
                    vdu_connection=self.httpAlias,
                    use_m2m=False
                )
                time.sleep(2)
            except Exception as e:
                error_msg = f"VDU _wait_for_rad_debug_operation: Error checking operation status: {e}"
                StringTool.consoleError(error_msg)
                raise Exception(error_msg)

        StringTool.datedConsole(f"VDU _wait_for_rad_debug_operation: Operation completed. Final result: {result}")
        return result

    def radReloadDomains(self, timeout=300):
        """
        Reload RAD domain on Cloud RAN VDU.

        This method allows RAD reload domain on the VDU entity.

        Args:
            timeout (int): Maximum wait time in seconds (default: 300)

        Returns:
            dict: Final operation result with status
        """
        self._connectIfRequired()
        StringTool.datedConsole("VDU radReloadDomains: Reloading RAD domains...")
        try:
            result = self.drvRef.rad_reload_domains(
                timeout=30,
                vdu_connection=self.httpAlias,
                use_m2m=False
            )
            result = self._wait_for_rad_debug_operation(
                operation_id=result.get('operation_id'),
                initial_status=result.get('status'),
                timeout=timeout
            )
            StringTool.datedConsole("VDU radReloadDomains: RAD domains reloaded successfully")
        except Exception as e:
            error_msg = f"VDU radReloadDomains: Failed to reload domains: {e}"
            StringTool.consoleError(error_msg)
            raise Exception(error_msg)
        return result

    def radReloadParams(self, domain_name, timeout=300):
        """
        Reload RAD parameters on Cloud RAN VDU.

        This method allows RAD reload parameters on the VDU entity.

        Args:
            domain_name (str): RAD domain name (e.g., 'L2PS', 'RLC', 'MAC')
            timeout (int): Maximum wait time in seconds (default: 300)

        Returns:
            dict: Final operation result with status
        """
        self._connectIfRequired()
        StringTool.datedConsole(f"VDU radReloadParams: Reloading params for domain {domain_name}...")
        try:
            result = self.drvRef.rad_reload_params(
                domain_name=domain_name,
                param_name=None,
                non_default_only=False,
                timeout=30,
                vdu_connection=self.httpAlias,
                use_m2m=False
            )
            result = self._wait_for_rad_debug_operation(
                operation_id=result.get('operation_id'),
                initial_status=result.get('status'),
                timeout=timeout
            )
            StringTool.datedConsole(f"VDU radReloadParams: Domain {domain_name} params reloaded successfully")
        except Exception as e:
            error_msg = f"VDU radReloadParams: Failed to reload params for {domain_name}: {e}"
            StringTool.consoleError(error_msg)
            raise Exception(error_msg)
        return result

    def perform_object_recommissioning(self, dist_name, parameter, operation='update',
                                       should_activate=True, timeout=300):
        """
        Perform object recommissioning on the specified distribution name with given parameters.

        Args:
            dist_name (str): The distribution name.
            parameter (list): A list of parameters.
            operation (str, optional): The operation to perform. Defaults to 'update'.
            should_activate (bool, optional): Whether to activate or not. Defaults to True.
            timeout (int, optional): The timeout in seconds. Defaults to 300.
            vdu_connection:

        Returns:
            result: The result of the recommissioning operation.
        """
        self._connectIfRequired()
        StringTool.datedConsole(f"\nVDU perform_object_recommissioning: dist_name={dist_name}"
                                f"\nlist of parameters={parameter}")
        try:
            # Attempt to perform object recommissioning
            result = self.drvRef.perform_object_recommissioning(
                dist_name=dist_name,
                parameter=parameter,
                operation=operation,
                should_activate=should_activate,
                timeout=timeout,
                vdu_connection=self.httpAlias
            )
            StringTool.datedConsole("VDU perform_object_recommissioning: Perform object recommissioning successfully")
        except Exception as e:
            # Handle any exceptions that occur during recommissioning
            error_msg = f"VDU perform_object_recommissioning: Failed to perform object recommissioning: {e}"
            StringTool.consoleError(error_msg)
            raise Exception(error_msg)
        StringTool.datedConsole(f"VDU perform_object_recommissioning: operation_id={result}")
        return result

    def updateRadDebugParams(self, domain_name, parameters, persistency='persistent', timeout=300):
        """
        Configure RAD debug parameters on Cloud RAN VDU.

        This method updates RAD parameters on the VDU entity. The orchestration of domain reloads
        (before and after the update) should be done at Robot Framework level.

        Args:
            domain_name (str): RAD domain name (e.g., 'L2PS', 'RLC', 'MAC')
            parameters (list): List of parameter dicts with 'name' and 'value' keys
                              Example: [{'name': 'rdFeatureFlagBitmapLevel', 'value': '4'},
                                       {'name': 'rdFeatureFlagBitmap4', 'value': '79'}]
            persistency (str): 'persistent' or 'non-persistent' (default: 'persistent')
            timeout (int): Maximum wait time in seconds for operation completion (default: 300)

        Returns:
            dict: Final operation result with status

        Example:
            params = [{'name': 'rdFeatureFlagBitmapLevel', 'value': '4'},
                     {'name': 'rdFeatureFlagBitmap4', 'value': '79'}]
            result = oam.updateRadDebugParams(domain_name='L2PS', parameters=params)
        """
        self._connectIfRequired()
        StringTool.datedConsole(f"VDU updateRadDebugParams: domain={domain_name}, params={parameters}, "
                                f"persistency={persistency}")
        StringTool.datedConsole("VDU updateRadDebugParams: Updating RAD debug parameters...")
        try:
            result = self.drvRef.update_rad_debug_params(
                persistency=persistency,
                domain_name=domain_name,
                parameters=parameters,
                vdu_connection=self.httpAlias
            )
            StringTool.datedConsole("VDU updateRadDebugParams: execution done then waiting for success...")
            result = self._wait_for_rad_debug_operation(
                operation_id=result.get('operation_id'),
                initial_status=result.get('status'),
                timeout=timeout
            )
            StringTool.datedConsole("VDU updateRadDebugParams: Parameters updated successfully")
        except Exception as e:
            error_msg = f"VDU updateRadDebugParams: Failed to update parameters: {e}"
            StringTool.consoleError(error_msg)
            raise Exception(error_msg)
        return result

#    def updateRadDebugParams(self, domain_name, parameters, persistency='persistent', node_id=None, timeout=300):
#        """
#        Configure RAD debug parameters on Cloud RAN VDU with persistent storage.
#
#        This method allows dynamic configuration of RAD parameters on the VDU entity,
#        with automatic domain reload to apply changes.
#
#        Args:
#            domain_name (str): RAD domain name (e.g., 'L2PS', 'RLC', 'MAC')
#            parameters (list): List of parameter dicts with 'name' and 'value' keys
#                              Example: [{'name': 'rdFeatureFlagBitmapLevel', 'value': '4'},
#                                       {'name': 'rdFeatureFlagBitmap4', 'value': '79'}]
#            persistency (str): 'persistent' or 'non-persistent' (default: 'persistent')
#            node_id (str): Optional node identifier (default: None)
#            timeout (int): Maximum wait time in seconds (default: 300)
#
#        Returns:
#            dict: Final operation result with status
#
#        Example:
#            params = [{'name': 'rdFeatureFlagBitmapLevel', 'value': '4'},
#                     {'name': 'rdFeatureFlagBitmap4', 'value': '79'}]
#            result = oam.updateRadDebugParams(domain_name='L2PS', parameters=params)
#        """
#        self._connectIfRequired()
#        StringTool.datedConsole(f"VDU updateRadDebugParams: domain={domain_name}, params={parameters}, "
#                                f"persistency={persistency}")
#
#        # Step 1: Reload domains
#        StringTool.datedConsole("VDU updateRadDebugParams: Step 1 - Reloading RAD domains...")
#        try:
#            result = self.drvRef.rad_reload_domains(
#                timeout=30,
#                vdu_connection=self.httpAlias,
#                use_m2m=False
#            )
#            self._wait_for_rad_debug_operation(
#                operation_id=result.get('operation_id'),
#                initial_status=result.get('status'),
#                timeout=timeout
#            )
#            StringTool.datedConsole("VDU updateRadDebugParams: RAD domains reloaded successfully")
#        except Exception as e:
#            error_msg = f"VDU updateRadDebugParams: Failed to reload domains: {e}"
#            StringTool.consoleError(error_msg)
#            raise Exception(error_msg)
#
#        # Step 2: Reload parameters for the specific domain
#        StringTool.datedConsole(f"VDU updateRadDebugParams: Step 2 - Reloading params for domain {domain_name}...")
#        try:
#            result = self.drvRef.rad_reload_params(
#                domain_name=domain_name,
#                param_name=None,
#                non_default_only=False,
#                timeout=30,
#                vdu_connection=self.httpAlias,
#                use_m2m=False
#            )
#            self._wait_for_rad_debug_operation(
#                operation_id=result.get('operation_id'),
#                initial_status=result.get('status'),
#                timeout=timeout
#            )
#            StringTool.datedConsole(f"VDU updateRadDebugParams: Domain {domain_name} params reloaded successfully")
#        except Exception as e:
#            error_msg = f"VDU updateRadDebugParams: Failed to reload params for {domain_name}: {e}"
#            StringTool.consoleError(error_msg)
#            raise Exception(error_msg)
#
#        # Step 3: Update RAD debug parameters
#        StringTool.datedConsole("VDU updateRadDebugParams: Step 3 - Updating RAD debug parameters...")
#        try:
#            result = self.drvRef.update_rad_debug_params(
#                persistency=persistency,
#                domain_name=domain_name,
#                parameters=parameters,
#                node_id=node_id,
#                timeout=30,
#                vdu_connection=self.httpAlias,
#                use_m2m=False
#            )
#            self._wait_for_rad_debug_operation(
#                operation_id=result.get('operation_id'),
#                initial_status=result.get('status'),
#                timeout=timeout
#            )
#            StringTool.datedConsole("VDU updateRadDebugParams: Parameters updated successfully")
#        except Exception as e:
#            error_msg = f"VDU updateRadDebugParams: Failed to update parameters: {e}"
#            StringTool.consoleError(error_msg)
#            raise Exception(error_msg)
#
#        # Step 4: Reload domains again to apply changes
#        StringTool.datedConsole("VDU updateRadDebugParams: Step 4 - Reloading RAD domains to apply changes...")
#        try:
#            result = self.drvRef.rad_reload_domains(
#                timeout=30,
#                vdu_connection=self.httpAlias,
#                use_m2m=False
#            )
#            self._wait_for_rad_debug_operation(
#                operation_id=result.get('operation_id'),
#                initial_status=result.get('status'),
#                timeout=timeout
#            )
#            StringTool.datedConsole("VDU updateRadDebugParams: RAD domains reloaded successfully")
#        except Exception as e:
#            error_msg = f"VDU updateRadDebugParams: Failed to reload domains after update: {e}"
#            StringTool.consoleError(error_msg)
#            raise Exception(error_msg)
#
#        # Step 5: Final reload of parameters
#        StringTool.datedConsole(f"VDU updateRadDebugParams: Step 5 - Final reload of params for "
#                                f"domain {domain_name}...")
#        try:
#            result = self.drvRef.rad_reload_params(
#                domain_name=domain_name,
#                param_name=None,
#                non_default_only=False,
#                timeout=30,
#                vdu_connection=self.httpAlias,
#                use_m2m=False
#            )
#            final_result = self._wait_for_rad_debug_operation(
#                operation_id=result.get('operation_id'),
#                initial_status=result.get('status'),
#                timeout=timeout
#            )
#            StringTool.datedConsole(f"VDU updateRadDebugParams: Completed successfully. "
#                                    f"Final status: {final_result.get('status')}")
#            return final_result
#        except Exception as e:
#            error_msg = f"VDU updateRadDebugParams: Failed final reload of params for {domain_name}: {e}"
#            StringTool.consoleError(error_msg)
#            raise Exception(error_msg)

    def _setParams(self, modify_param, timeout=60):
        self._clean_plan()
        self.testnok = False
        self.timeout = timeout
        StringTool.datedConsole(f" - VDU _setParams: {modify_param}")

        delta_out = self.drvRef.generate_delta_plan(plan_name='delta_plan_from_AF', plan_description='',
                                                    vdu_connection=self.httpAlias)
        self.plan_id = delta_out['plan_id']
        if not self._launch_op('get_delta_plan_generated_action_status', delta_out['action_id']):
            return self._setParamError("GENERATING DELTA PLAN")
        StringTool.datedConsole(f" - VDU _setParams plan_id: {self.plan_id} generated")

        # list from classical (to be compliant):
        # [{'parameter': 'enDcSyncStatus', 'dist_name': 'MRBTS-1/NRBTS-1/NRCELL-1', 'value': 'asynchronous'}, {}, ...]
        # the 'operation' key is optional and set to 'replace' by default

        for p in modify_param:
            op = p['operation'] if 'operation' in p else 'replace'
            param_dict = {p['parameter']: p['value']}
            update_out = self.drvRef.update_vdu_parameter_of_delta_plan(self.plan_id, mo_dn=p['dist_name'],
                                                                        updated_paras_dict=param_dict, operation=op,
                                                                        timeout=self.timeout,
                                                                        vdu_connection=self.httpAlias)
            if not self._launch_op('get_update_paras_action_status_of_delta_plan', update_out['action_id']):
                return self._setParamError("UPDATE PARAM IN DELTA PLAN")

        StringTool.datedConsole(f" VDU _setParams plan_id: {self.plan_id} updated")

        validate_out = self.drvRef.validate_delta_plan(delta_plan_id=self.plan_id, vdu_connection=self.httpAlias)
        time.sleep(3)
        if not self._launch_op('get_validate_delta_plan_operation_status', validate_out['action_id']):
            return self._setParamError("VALIDATING DELTA PLAN")
        StringTool.datedConsole(f" - VDU _setParams plan_id: {self.plan_id} validated")

        activate_out = self.drvRef.activate_delta_plan(delta_plan_id=self.plan_id, force_reset=True,
                                                       vdu_connection=self.httpAlias)

        if not self._launch_op('get_activate_delta_plan_operation_status', activate_out['id']):
            return self._setParamError("ACTIVATING DELTA PLAN")
        StringTool.datedConsole(f" - VDU _setParams plan_id: {self.plan_id} activated")
        return self._setParamError()

    def _fullCommissioning(self, scf_file, skip_relation_errors):
        self.timeout = 60
        self.testnok = False
        upload_out = self.drvRef.upload_plan(path_to_plan_file=scf_file, vdu_connection=self.httpAlias)
        self.plan_id = upload_out['plan_id']
        if not self._launch_op('get_upload_plan_operation_status', upload_out['action_id']):
            return self._setParamError("UPLOAD PLAN")
        StringTool.datedConsole(f" VDU _fullCommissioning plan uploaded {self.plan_id}")

        validate_out = self.drvRef.validate_plan(self.plan_id, vdu_connection=self.httpAlias)
        if not self._launch_op('get_validate_plan_operation_status', validate_out['action_id']):
            return self._setParamError("VALIDATING PLAN")
        StringTool.datedConsole(f" VDU _fullCommissioning plan validated {self.plan_id}")

        self.timeout = 300
        activate_out = self.drvRef.activate_plan(self.plan_id, vdu_connection=self.httpAlias)
        StringTool.datedConsole(f" ##### VDU _fullCommissioning WILL REBOOT NOW:{activate_out}")
        time.sleep(self.timeout)
        self._connectIfRequired()

        if not self._launch_op('get_activate_plan_operation_status', activate_out['id']):
            return self._setParamError("ACTIVATING PLAN")
        StringTool.datedConsole(" VDU _fullCommissioning plan activated")
        return self._setParamError()

    def _clean_plan(self):
        plan_list = self.drvRef.get_delta_plan_info_list(vdu_connection=self.httpAlias)
        for plan in plan_list:
            if plan['plan_name'] == 'delta_plan_from_AF':
                self.drvRef.delete_delta_plan_file(plan['plan_id'], vdu_connection=self.httpAlias)
                StringTool.datedConsole("VDU _clean_plan: deleting previous delta_plan_from_AF")

    def _launch_op(self, op, action):
        if op == 'get_upload_plan_operation_status':
            OsTool.waitUntil(retry=self.timeout, retry_interval=5, keyword=self._check_operation_state,
                             operation_id=action, method=op, vdu_connection=self.httpAlias)
        elif op == 'get_delta_plan_generated_action_status':
            OsTool.waitUntil(retry=self.timeout, retry_interval=5, keyword=self._check_operation_state,
                             action_id=action, method=op, vdu_connection=self.httpAlias)
        elif op == 'get_update_paras_action_status_of_delta_plan':
            OsTool.waitUntil(retry=self.timeout, retry_interval=5, keyword=self._check_operation_state,
                             action_id=action, plan_id=self.plan_id, method=op,
                             vdu_connection=self.httpAlias)
        elif op == 'get_validate_delta_plan_operation_status':
            OsTool.waitUntil(retry=self.timeout, retry_interval=5, keyword=self._check_operation_state,
                             action_id=action, delta_plan_id=self.plan_id, method=op,
                             vdu_connection=self.httpAlias)
        elif op == 'get_activate_delta_plan_operation_status':
            OsTool.waitUntil(retry=self.timeout, retry_interval=15, keyword=self._check_operation_state,
                             operation_id=action, delta_plan_id=self.plan_id, method=op,
                             vdu_connection=self.httpAlias)
        elif op == 'get_reset_vdu_operation_status':
            OsTool.waitUntil(retry=300, retry_interval=10, keyword=self._check_operation_state,
                             operation_id=action, method=op, expected='ongoing', vdu_connection=self.httpAlias)
        else:
            OsTool.waitUntil(retry=self.timeout, retry_interval=5, keyword=self._check_operation_state,
                             operation_id=action, plan_id=self.plan_id, method=op,
                             vdu_connection=self.httpAlias)
        if self.testnok:
            return False
        return True

    def _check_operation_state(self, *args, **kwargs):
        status = ''
        expected = 'success'
        if 'expected' in kwargs:
            expected = kwargs.pop('expected')
        method = kwargs.pop('method')
        method_callable = getattr(self.drvRef, method)
        output = method_callable(*args, **kwargs)
        status = output['status']
        StringTool.datedConsole(f"VDU _check_operation_state: ... {method}: {status}")
        msg = 'No change in this plan. : No change in this plan.'
        if status == 'failure':
            self.testnok = False
            if method == 'get_validate_delta_plan_operation_status' and output['error_message'] == msg:
                StringTool.datedConsole(f"VDU _check_operation_state {method} WARNING !!!! : No changes in delta plan.")
            elif method == 'get_activate_delta_plan_operation_status' and \
                    output['error_message'] == 'No change in this plan.':
                StringTool.datedConsole(f"VDU _check_operation_state {method} WARNING !!!! : No changes in delta plan.")
            else:
                self.testnok = True
            StringTool.datedConsole(f"VDU _check_operation_state ERROR: {method}:{output}")
            return True
        elif status == expected:
            self.testnok = False
            return True
        elif status == 'ongoing':
            self.testnok = True
            return False
        return True

    def remove_all_plan(self):
        self._connectIfRequired()
        try:
            plan_list = self.drvRef.get_delta_plan_info_list(vdu_connection=self.httpAlias)
        except Exception as e:
            self.connect()
            plan_list = self.drvRef.get_delta_plan_info_list(vdu_connection=self.httpAlias)
        for plan in plan_list:
            StringTool.datedConsole(f"VDU remove_all_plan: deleting delta_plan: {plan}")
            self.drvRef.delete_delta_plan_file(plan['plan_id'], vdu_connection=self.httpAlias)
        plan_list = self.drvRef.get_staged_plans_info_list(vdu_connection=self.httpAlias)
        for plan in plan_list:
            StringTool.datedConsole(f"VDU remove_all_plan removing staged plan: {plan}")
            self.drvRef.delete_staged_plan_file(plan_id=plan['plan_id'], vdu_connection=self.httpAlias)

    def _getSnapshot(self, path, timeout):
        tmp_path = "/tmp"
        # timeout in float because otherwise issue in taf - compares str and float and error appears
        self.drvRef.get_local_snapshot(directory=tmp_path, operation_timeout=float(timeout),
                                       vdu_connection=self.httpAlias, compressed_or_not=True)
        # snapshot file is moved from temporary to official repository:
        os.system(f"cp /tmp/Snapshot_20*.zip {path};rm -f /tmp/Snapshot_20*.zip")

    def _getActiveAlarms(self, textFormat):
        txtAlarms = []
        vduAlarms = self.drvRef.vdu_get_active_alarms(vdu_connection=self.httpAlias)
        StringTool.datedConsole(f"VDU alarms: {vduAlarms}")
        listAlarms = vduAlarms['alarms']
        StringTool.datedConsole(f"VDU listAlarms: {listAlarms}")
        # replace <u'> by <'>
        if not textFormat:
            return listAlarms
        # format is text
        for alarm in listAlarms:
            txtAlarms.append(f"[{alarm['alarm_id']}][{alarm['fault_id']}]({alarm['severity']}) "
                             f"{alarm['alarm_name']:40}:{alarm['additional_info']} "
                             f"[{alarm['alarming_object']}]")
        return txtAlarms

    def _getSWVersion(self):
        vduState = self.drvRef.get_vdu_state_data(vdu_connection=self.httpAlias)
        swVersion = vduState['software_version']
        StringTool.datedConsole(f"VDU software version is: {swVersion}")
        return swVersion

    def _getPostfix(self):
        return f"_{self.unit}"

    def _getBtsInfo(self):
        localScf = self.getScfFile(dir="/tmp", file="TmpVdu.xml")
        btsInfo = XmlScf.get_bts_Infos(localScf)
        mrbtsId = btsInfo["mrbts_id"]
        nrbtsId = btsInfo["nrbts_id"]
        nrcellId = btsInfo["nrcell_Id"]
        nrcellDn = btsInfo["nrcell_DN"]
        nrcellGrpId = "NRCELLGRP-" + btsInfo["nrcell_Grp_Id"]
        nrcellDnList = btsInfo["nrcell_DN_list"]
        nrcellGrpIdList = btsInfo["cell_Grp_Id_list"]
        # build the list of available cells (max = 9 cells)
        nrcellIdList = [None, None, None, None, None, None, None, None, None]
        index = 0
        nbOfNrCells = 0
        for cell in btsInfo['nrcell_Id_list']:
            nrcellIdList[index] = int(cell)
            index += 1
            nbOfNrCells += 1
        self._setGlobalVariables(btsInfo=None, mrbts=mrbtsId, nrcell=nrcellDn, nbOfNrCells=nbOfNrCells,
                                 nrbts=nrbtsId, nrCellGrp=nrcellGrpId,
                                 nrcellId=nrcellId, cellDnList=nrcellDnList, cellIdList=nrcellIdList)

    def _getCellsNr(self):
        StringTool.datedConsole("Get cells status for AIC VDU")
        cellsNr = self.drvRef.get_vdu_cells_status(vdu_connection=self.httpAlias)
        self._apiTrace(f"Cell status =[ {cellsNr} ]")
        return cellsNr

    def _cellLock(self, cell_id, state):
        cell_dn = 'notfound'
        do_nothing = False
        cells_info = self.drvRef.get_vdu_cells_status(vdu_connection=self.httpAlias)
        for c in cells_info:
            if int(c['id']) == int(cell_id):
                cell_dn = c['dist_names']['config']
                if state == "LOCK" and c['blocking_state'] != 'Unblocked':
                    # A warning message is sufficient:
                    StringTool.datedConsole(f"WARNING : CELL already blocked ==> {cell_dn}:{c['blocking_state']}")
                    do_nothing = True
                if state == "UNLOCK" and c['blocking_state'] != 'Blocked':
                    # A warning message is sufficient:
                    StringTool.datedConsole(f"WARNING: CELL already unblocked ==> {cell_dn}:{c['blocking_state']}")
                    do_nothing = True
                break
        if cell_dn == 'notfound':
            raise Exception(f"CELL ID: {cell_id} not FOUND")
        if do_nothing:
            return
        if state == "LOCK":
            self.drvRef.block_cell(cell_id=cell_dn, vdu_connection=self.httpAlias)
        else:
            self.drvRef.unblock_cell(cell_id=cell_dn, vdu_connection=self.httpAlias)
        time.sleep(30)

    def get_counter(self, counter_id, dimension_dn):
        self._connectBis()
        ret_error = "EMPTY"
        last_val_retrieved = 0
        val = self.drvRefBis.get_counter_values(counter_id=counter_id,
                                                dimension_dn=dimension_dn, vdu_connection='pm_vdu')
        if OsTool.pmcDebug():
            StringTool.datedConsole(f" - VDU get_counter val ===> {val} <===")
        if len(val) == 0:
            StringTool.datedConsole(f" - ERROR get_counter empty===> {val} <===")
            return ret_error
        if OsTool.pmcDebug():
            StringTool.datedConsole(f" - VCU v2 is value before sort ===> {val} <===")
        # sort
        val.sort(key=operator.itemgetter('start_time'))
        if OsTool.pmcDebug():
            StringTool.datedConsole(f" - VCU v2 is value after sort ===> {val} <===")
            # extract last
            StringTool.datedConsole(f" - VCU type val last el ===> {val[-1]} <===")
        last_el = val[-1]
        for s2, v2 in last_el.items():
            # FOR_DEBUG
            if OsTool.pmcDebug():
                StringTool.datedConsole(f" - VCU s2 v2 ===> {s2} {v2} <===")
            if s2 == "value":
                if OsTool.pmcDebug():
                    StringTool.datedConsole(f" - VCU s2 is value ===> {s2} <===")
                    StringTool.datedConsole(f" - VCU v2 is value ===> {v2} <===")
                    StringTool.datedConsole(f" - VCU last val date----------- ===> {v2} <===")
                last_val_retrieved = v2
        StringTool.datedConsole(f" - last_val_retrieved------------ ===> {last_val_retrieved} <===")
        self._disconnectBis()
        return last_val_retrieved

    def get_counter_sum(self, counter_id, dimension_dn):
        self._connectBis()
        ret_error = "EMPTY"
        sum_retrieved = 0
        val = self.drvRefBis.get_counter_values(counter_id=counter_id,
                                                dimension_dn=dimension_dn, vdu_connection='pm_vdu')
        if OsTool.pmcDebug():
            StringTool.datedConsole(f" - VDU get_counter sum val ===> {val} <===")
        if len(val) == 0:
            StringTool.datedConsole(f" - ERROR get_counter sum empty===> {val} <===")
            return ret_error
        for el in val:
            if OsTool.pmcDebug():
                StringTool.datedConsole(f" - VDU el ===> {el} <===")
            for s1, v1 in el.items():
                if OsTool.pmcDebug():
                    StringTool.datedConsole(f" - VDU s1 v1 ===> {s1} {v1} <===")
                if s1 == "start_time":
                    if OsTool.pmcDebug():
                        StringTool.datedConsole(f" - VDU val date ===> {v1} <===")
                if s1 == "value":
                    if OsTool.pmcDebug():
                        StringTool.datedConsole(f" - VDU val retrieved ===> {v1} <===")
                    sum_retrieved = sum_retrieved + int(v1)
        StringTool.datedConsole(f" - TOTAL sum ===> {sum_retrieved} <===")
        self._disconnectBis()
        return sum_retrieved

    def get_counter_values(self, counter_id, dimension_dn):
        self._connectBis()
        ret_error = "EMPTY"
        val_list = []
        val = self.drvRefBis.get_counter_values(counter_id=counter_id,
                                                dimension_dn=dimension_dn, vdu_connection='pm_vdu')
        if OsTool.pmcDebug():
            StringTool.datedConsole(f" - VDU get_counter sum val ===> {val} <===")
        if len(val) == 0:
            StringTool.datedConsole(f" - ERROR get_counter sum empty===> {val} <===")
            return ret_error
        for el in val:
            if OsTool.pmcDebug():
                StringTool.datedConsole(f" - VDU el ===> {el} <===")
            for s1, v1 in el.items():
                if OsTool.pmcDebug():
                    StringTool.datedConsole(f" - VDU s1 v1 ===> {s1} {v1} <===")
                if s1 == "start_time":
                    if OsTool.pmcDebug():
                        StringTool.datedConsole(f" - VDU val date ===> {v1} <===")
                if s1 == "value":
                    if OsTool.pmcDebug():
                        StringTool.datedConsole(f" - VDU val retrieved ===> {v1} <===")
                    val_list.append(v1)
                    # val_list.append(int(v1))
        StringTool.datedConsole(f" - LIST val ===> {val_list} <===")
        self._disconnectBis()
        return val_list

    def _runOamCmd(self, cmd, cmdArgs=None):
        tmpCmdArgs = "vdu_connection=self.httpAlias"
        if (cmdArgs is not None):
            for key, value in cmdArgs.items():
                tmpCmdArgs = tmpCmdArgs + f",{key}={value}"
        oamCmd = f"self.drvRef.{cmd}({tmpCmdArgs})"
        StringTool.datedConsole(f"OAM full command is <{oamCmd}>")
        data = eval(oamCmd)
        StringTool.datedConsole(f"Result of eval data {data}")
        return data

    def _searchValueInList(self, list, value):
        for elem in list:
            if elem == value:
                return True
        return False

    def _getNrDrbDn(self, call_type, bearer_id):
        # Input parameters check:
        if call_type == "NSA":
            list_name = "qciValueList"
            nr_drb_type = "NRDRB_QCI"
        elif call_type == "SA":
            list_name = "fiveqiValueList"
            nr_drb_type = "NRDRB_5QI"
        else:
            StringTool.consoleError(f"<{call_type}>: not managed by OAM_Get_NrDrbDN. Please contact AF team")
            return None
        # Create pattern to be found in scf file:
        pattern = re.compile(f'MRBTS-[0-9]*/NRBTS-[0-9]*/{nr_drb_type}-[0-9]*')
        # Get, read and parse the SCF file:
        scf_file = self.getScfFile(dir="/tmp", file="scf_du.xml", timeout=30)
        with open(scf_file, 'r') as file:
            data = file.read()
        matches = pattern.findall(data)
        StringTool.prefixDatedConsole(f"Discovered {nr_drb_type} list is: {matches}")
        # Create an instance of MultiScf class to use its scf services:
        scf = MultiScf.MultiScf()
        scf.load_scf(scf_path=scf_file)
        # For each item found, search the expected list_name to get the nrDrbDN value:
        nr_drb_dn = None
        for item in matches:
            value = scf.get_value_from_scf(dist_name=item, aicListEntity='VDU',
                                           scope='Aic', list_name=list_name)
            result = self._searchValueInList(value, str(bearer_id))
            if result:
                nr_drb_dn = scf.get_value_from_scf(dist_name=item, aicListEntity='VDU',
                                                   scope='Aic', p_name="nrDrbDN")

            if nr_drb_dn is not None:
                break
        # cleanup of all temporary scf files and return the discovered nrDrbDN value
        cmd_clean = f"rm {scf_file}"
        result = OsTool.execCmd(cmd_clean)
        return nr_drb_dn

    def _getNrCellGrp(self, nr_cell_id):
        StringTool.consoleError("OAM Get NR Cell GROUP is not designed for Cloud AIC (DU). Please contact AF team")
        return None

    def _isItemValuePresentInItemName(self, item_name, item_value):
        StringTool.consoleError(f"OAM Is {item_name} Present is not designed for Cloud AIC (DU). "
                                f"Please contact AF team")
        return None

    def _softwareUpdate(self, sw_package, should_activate, timeout):
        error_msg = "OAM Software Update is not designed for Cloud AIC DU. Please contact AF team"
        StringTool.consoleError(error_msg)
        return error_msg


# ======================================================================================
# Service to build an oam knowing its HW and its unit
# ======================================================================================
def getOam(sshConnection, httpConnection, hw=Enums.HW.GNB, unit=Enums.Unit.DU, index=0, proxy=None):
    if hw == Enums.HW.AP:
        return OamClassical(sshConnection, httpConnection, hw, unit, index, proxy)
    if unit == Enums.Unit.CU:
        if TLConfig.topo.archi.isClassical():
            return None
        if TLConfig.topo.archi.isAic():
            return OamCloudAicCU(sshConnection, httpConnection, hw, unit, index, proxy)
    if unit == Enums.Unit.DU:
        if TLConfig.topo.archi.isAic():
            return OamCloudAicDU(sshConnection, httpConnection, hw, unit, index, proxy)
        return OamClassical(sshConnection, httpConnection, hw, unit, index, proxy)
    return None

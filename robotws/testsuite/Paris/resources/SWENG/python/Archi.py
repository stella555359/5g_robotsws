from ReadConfig import TLConfig
import re
import OsTool
import StringTool
import Enums
import Airscales
import Airframes
import Hosts
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
import taf.config.testline.cloud_hosting as cloud_hosting
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.cloud_hosting import MasterNode, K8S, ComputeNode
from taf.transport.ssh import ssh

DURATION_DISCOVERY_WAIT = 10
DISCOVERY_ATTEMPT_TRIES = 10

ADETS_CMD_PART1 = "OWNID=`sh /usr/bin/ownnid`; export PYTHONPATH=/opt/hwmt/python; "
ADETS_CMD_PART2 = "python3 /opt/hwmt/python/hwapi/AdetS.py -s -p 15004 -n $OWNID"
ADETS_CMD = ADETS_CMD_PART1 + ADETS_CMD_PART2
CHK_SYSBSH_CMD = "chk sysbsh"


def getAirscaleOamHttp(cu):
    return HttpConnectionDetails(
        addr=cu.backhaul_site_oam_ip,
        username=cu.oam_http_connection_details.username,
        password=cu.oam_http_connection_details.password,
        port=cu.oam_http_connection_details.port)


def getAirscaleOamSsh(cu):
    return HttpConnectionDetails(
        addr=cu.backhaul_site_oam_ip,
        username=cu.oam_ssh_connection_details.username,
        password=cu.oam_ssh_connection_details.password)


def getAirscaleDUssh(du):
    return du.airscale.common_units[0].lmp_connection


def getEntity(hw, unit, index=0):
    """
    Compute which kind of entity (Airscale, Airframe, ...) should be created upon the hardware and the unit
    """
    archi = TLConfig.topo.archi
    hw = Enums.HW['{}'.format(hw)]
    unit = Enums.Unit['{}'.format(unit)]
    tl = TLConfig.getTL()

    # ==== AP case ================================================================================
    if hw == Enums.HW.AP:
        if unit == Enums.Unit.DU:
            return Airscales.getAirscale(sshConnection=tl.ues[0].l1.common_units[0].lmp_connection,
                                         hw=hw, unit=unit, index=index,
                                         oamSSH=TLConfig.ues[0].oam_ssh_connection_details,
                                         oamHTTP=TLConfig.ues[0].oam_http_connection_details)
        return None

    # ==== GNB case ===============================================================================

    # set new OAM password for VRAN trunk only
    if archi.isAic():
        if TLConfig.isVranTrunkRelease():
            print("Set new CU and DU OAM password")
            newPasswd = "Nokia@123"
            tl.gnbs[index].dus[0].oam_http_connection_details.password = newPasswd
            tl.gnbs[index].cu.oam_http_connection_details.password = newPasswd

    du = tl.gnbs[index].dus[0]
    cu = tl.gnbs[index].cu
    cuOamSsh = cu.oam_ssh_connection_details
    cuOamHttp = cu.oam_http_connection_details

    # ---- CLASSICAL ------------------------------------------------------------------------------
    if archi.isClassical():
        if unit == Enums.Unit.DU:
            testPc = Hosts.Host(alias="PC{}".format(index+1),
                                sshConnection=tl.test_pcs[index].default_ssh_connection_details)
            return Airscales.getAirscale(sshConnection=getAirscaleDUssh(du),
                                         rootHost=testPc,
                                         hw=hw, unit=unit, index=index,
                                         oamSSH=getAirscaleOamSsh(cu),
                                         oamHTTP=getAirscaleOamHttp(cu))
        return None

    # ---- AIC ------------------------------------------------------------------------------------
    if archi.isAic():
        if unit == Enums.Unit.DU:
            return Airframes.K8sDU(hw=hw, unit=unit, index=index,
                                   oamSSH=du.oam_http_connection_details,
                                   oamHTTP=du.oam_http_connection_details,
                                   k8s=du.cloud_deployment.cloud_hosting)
        if unit == Enums.Unit.CU:
            return Airframes.K8sCU(hw=hw, unit=unit, index=index,
                                   oamSSH=cuOamSsh,
                                   oamHTTP=cuOamHttp,
                                   k8s=tl.gnbs[0].cloud_deployment.cloud_hosting)

    return None


def getEntitymwts(hw, unit, index=0):
    """
    Compute which kind of entity (Airscale, Airframe, ...) should be created upon the hardware and the unit
    This is a specific version for MWTS (Multi WTS -Wireless Test System-) entities.
    """
    archi = TLConfig.topo.archi
    hw = Enums.HW['{}'.format(hw)]
    unit = Enums.Unit['{}'.format(unit)]
    tl = TLConfig.getTL()

    # Ensure the correct attribute is accessed
    if not hasattr(tl, 'test_pc'):
        raise AttributeError("The 'TestLine' object does not have a 'test_pc' attribute.")

    # ==== AP case ================================================================================
    if hw == Enums.HW.AP:
        if unit == Enums.Unit.DU:
            return Airscales.getAirscale(sshConnection=tl.ues[0].l1.common_units[0].lmp_connection,
                                         hw=hw, unit=unit, index=index,
                                         oamSSH=TLConfig.ues[0].oam_ssh_connection_details,
                                         oamHTTP=TLConfig.ues[0].oam_http_connection_details)
        return None

    # ==== GNB case ===============================================================================

    # set new OAM password for VRAN trunk only
    if archi.isAic():
        if TLConfig.isVranTrunkRelease():
            print("Set new CU and DU OAM password")
            newPasswd = "Nokia@123"
            tl.gnbs[index].dus[0].oam_http_connection_details.password = newPasswd
            tl.gnbs[index].cu.oam_http_connection_details.password = newPasswd

    du = tl.gnbs[index].dus[0]
    cu = tl.gnbs[index].cu
    cuOamSsh = cu.oam_ssh_connection_details
    cuOamHttp = cu.oam_http_connection_details

    # ---- CLASSICAL ------------------------------------------------------------------------------
    if archi.isClassical():
        if unit == Enums.Unit.DU:
            # Use test_pcs if present, else fallback to test_pc
            if hasattr(tl, "test_pcs"):
                test_pc_obj = tl.test_pcs[index]
            else:
                test_pc_obj = tl.test_pc[index] if isinstance(tl.test_pc, list) else tl.test_pc
            testPc = Hosts.Host(alias="PC{}".format(index+1),
                                sshConnection=test_pc_obj.default_ssh_connection_details)
            return Airscales.getAirscale(sshConnection=getAirscaleDUssh(du),
                                         rootHost=testPc,
                                         hw=hw, unit=unit, index=index,
                                         oamSSH=getAirscaleOamSsh(cu),
                                         oamHTTP=getAirscaleOamHttp(cu))
        return None

    # ---- AIC ------------------------------------------------------------------------------------
    if archi.isAic():
        if unit == Enums.Unit.DU:
            return Airframes.K8sDU(hw=hw, unit=unit, index=index,
                                   oamSSH=du.oam_http_connection_details,
                                   oamHTTP=du.oam_http_connection_details,
                                   k8s=du.cloud_deployment.cloud_hosting)
        if unit == Enums.Unit.CU:
            return Airframes.K8sCU(hw=hw, unit=unit, index=index,
                                   oamSSH=cuOamSsh,
                                   oamHTTP=cuOamHttp,
                                   k8s=tl.gnbs[0].cloud_deployment.cloud_hosting)

    return None


def buildEntity(hw, unit, index=0):
    entity = None
    powersaving_state = "OFF"
    isOK = False
    for tryNb in range(DISCOVERY_ATTEMPT_TRIES):
        entity = getEntity(hw, unit, index)
        if entity is not None:
            if entity.display():
                return entity, powersaving_state
            # the entity has a failed item
            # if it is a classical BTS, we should check if this item is sleeping or not:
            if TLConfig.topo.archi.isClassical():
                try:
                    powersaving_state, isOK = checkSleepingStateOrNot(hw, unit, index)
                except Exception as e:
                    StringTool.prefixDatedConsole("ERROR: {}".format(e))
            if isOK is True and powersaving_state == "ON":
                return entity, powersaving_state
            if tryNb < DISCOVERY_ATTEMPT_TRIES - 1:
                OsTool.TracedSleep(duration=DURATION_DISCOVERY_WAIT,
                                   msg="    Try {}/{}:Entity {}_{} was not OK".
                                   format(tryNb + 1, DISCOVERY_ATTEMPT_TRIES, hw, unit))

    if entity is not None:
        raise Exception("ERROR: UNABLE TO REACH STABLE STATE FOR ENTITY {}_{} AFTER {} TRIES !!!".
                        format(hw, unit, DISCOVERY_ATTEMPT_TRIES))


def buildEntitymwts(hw, unit, index=0):
    entity = None
    powersaving_state = "OFF"
    isOK = False
    for tryNb in range(DISCOVERY_ATTEMPT_TRIES):
        entity = getEntitymwts(hw, unit, index)
        if entity is not None:
            if entity.display():
                return entity, powersaving_state
            # the entity has a failed item
            # if it is a classical BTS, we should check if this item is sleeping or not:
            if TLConfig.topo.archi.isClassical():
                try:
                    powersaving_state, isOK = checkSleepingStateOrNot(hw, unit, index)
                except Exception as e:
                    StringTool.prefixDatedConsole("ERROR: {}".format(e))
            if isOK is True and powersaving_state == "ON":
                return entity, powersaving_state
            if tryNb < DISCOVERY_ATTEMPT_TRIES - 1:
                OsTool.TracedSleep(duration=DURATION_DISCOVERY_WAIT,
                                   msg="    Try {}/{}:Entity {}_{} was not OK".
                                   format(tryNb + 1, DISCOVERY_ATTEMPT_TRIES, hw, unit))

    if entity is not None:
        raise Exception("ERROR: UNABLE TO REACH STABLE STATE FOR ENTITY {}_{} AFTER {} TRIES !!!".
                        format(hw, unit, DISCOVERY_ATTEMPT_TRIES))


def checkSleepingStateOrNot(hw, unit, index=0):
    StringTool.prefixDatedConsole("\t\tTHIS MAY BE DUE TO THE POWER SAVING FEATURE (SLEEPING ITEM).")
    StringTool.prefixDatedConsole("\t\tTO VERIFY THIS HYPOTHESIS, ADETS SCRIPT IS LAUNCHED ON {}_{}:".
                                  format(hw, unit))
    sleep_nodeId = []
    failed_nodeId = []
    tl = TLConfig.getTL()
    du = tl.gnbs[index].dus[0]
    sshId = getAirscaleDUssh(du)
    csn = ssh()
    powersaving_state = "OFF"
    isOK = False
    try:
        csn.connect_to(hostname=sshId.addr, username=sshId.username, password=sshId.password, alias='Archi')
        adetsOutput = csn.execute(ADETS_CMD, connection='Archi')
        sysBshOutput = csn.execute(CHK_SYSBSH_CMD, connection='Archi')

        for line in adetsOutput.split("\n"):
            if "sleep" in line:
                sleep_nodeId.append(re.match(r"\[(.+?)\].*", line).group(1))
                powersaving_state = "ON"

        for line in sysBshOutput.split("\n"):
            if "failed" in line and "- slave" in line:
                fields = line.split(" ")
                failed_nodeId.append(fields[7].replace("[", "").replace("]", ""))

        # List comparison
        dif_list = list(set(sleep_nodeId) - set(failed_nodeId)) + list(set(failed_nodeId) - set(sleep_nodeId))
        if len(dif_list) == 0:
            isOK = True
            goodnews = f"GOOD NEWS: THE FOLLOWING ITEM IS IN SLEEP MODE: {hw}_{unit} NodeID {failed_nodeId}"
            StringTool.prefixDatedConsole("=========================================================================")
            StringTool.prefixDatedConsole(goodnews)
            StringTool.prefixDatedConsole("\t\t  => LET'S CONTINUE THE TEST !!!")
            StringTool.prefixDatedConsole("=========================================================================")
        else:
            warnnews = f"WARNING: THIS FAILED ITEM IS NOT IN SLEEP MODE: {hw}_{unit} NodeID {failed_nodeId}"
            StringTool.prefixDatedConsole(warnnews)
            StringTool.prefixDatedConsole("\t\t=> LET'S TRY OUR LUCK AGAIN IN A FEW MOMENTS !!!")
            StringTool.prefixDatedConsole("=========================================================================")

    except Exception as e:
        StringTool.prefixDatedConsole("ERROR, unable to connect:\n{}".format(e))
    return powersaving_state, isOK

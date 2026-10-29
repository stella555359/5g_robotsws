from __future__ import absolute_import
import re
import StringTool
from taf.transport.ssh import ssh
try:
    import robot.api.logger as logging
except ImportError:
    import logging

csn = ssh()


def getNodeId(connection):
    """
    Compute node ID by executing ownid command on a host
    """
    result = csn.execute("sh /usr/bin/ownnid", connection=connection)
    return result.split('\r\n')[0]


def getAdetOutput(connection, nodeId='0x1011'):
    """
    Execute AdetS command for a particular node ID and return result
    :param connection: alias of concerned host
    :param nodeId: Id of the node (for instance : "0x1011" )
    :return: multi line string
    """
    csn.force_reconnect(connection=connection)
    portOption = "-p 15004"
    csn.send_command(
        "export PYTHONPATH=/opt/hwmt/python;"
        " python3 /opt/hwmt/python/hwapi/AdetS.py -s {} -n {} ".format(portOption, nodeId),
        connection=connection, timeout=300)
    output = csn.read_output(connection=connection)
    # csn.send_command("cp /opt/hwmt/python/hwapi/AdetS.py.ori /opt/hwmt/python/hwapi/AdetS.py")
    return output


def getAirscaleStatus(connection, nodeId='0x1011', *args):
    """
    Compute table of status for a list of root node id
    Example : Calling getAirscaleStatus(HOST_GNB_SYS_M, nodeId='0x1011', ['0x10', '0x12']
    will retrun something like : [ {'0x10' : "ready", '0x12' : "uninitialized' ]
    :param connection: alias of concerned host
    :param nodeId: precise node ID for AdetS command
    :param args: list of expected root node id
    :return: table of dictionary
    """
    output = getAdetOutput(connection, nodeId)
    airscaleStatus = {}
    if (output is None) or (len(output) < 10):
        for nID in args:
            airscaleStatus[nID] = "NOT EXIST"
    else:
        for nID in args:
            status = "NOT EXIST"
            if 'moduleInfoValid is FALSE' in output:
                status = "moduleInfoValid is FALSE"
            else:
                output = re.sub('.*Storing.*\n', '', output)
                try:
                    status = re.search(r'{}\s*\S*\s*\S*'.format(nID), output).group(0).split()[2][:-3]
                except (AttributeError, KeyError):
                    logging.warn("status for {} is NOT exist!".format(nID))
                    status = "NOT EXIST"
            airscaleStatus[nID] = status
    StringTool.console("getAirscaleStatus:{}".format(airscaleStatus))
    return airscaleStatus


def checkAirscaleStatus(connection, nodeId='0x1011', *args):
    """
    Check that a list of root Node ID are all ready
    :param connection: alias of concerned host
    :param nodeId: precise node ID for AdetS command
    :param args: ist of expected root node id
    :return: empty string if all nodes are ready, error message (list of non ready nodes) otherwise
    """
    statusList = getAirscaleStatus(connection, nodeId, *args)
    errorStr = ""
    for subNodeId in statusList:
        if statusList[subNodeId] == 'moduleInfoValid is FALSE':
            errorStr = "moduleInfoValid is FALSE"
            break
        elif statusList[subNodeId] != "ready":
            errorStr = "{}NodeID={} STATUS={}, ".format(errorStr, subNodeId, statusList[subNodeId])
    return errorStr


def displayAirscale(airscale, partition):
    StringTool.datedConsole("{}Airscale:{:3} SYS:{} BB:{}       Chassis={} Domain={}      ListNodeId={}   Partition={}"
                            .format(StringTool.PREFIX_DISPLAY, airscale.name, len(airscale.sys), len(airscale.bb),
                                    airscale.slotNumber, airscale.domainId, airscale.listNodeId, partition))
    # Printing sys
    for idx, sys in enumerate(airscale.sys):
        displayHost(airscale, sys.M, index=idx, isSys=True, kind="M")
        displayHost(airscale, sys.S, index=idx, isSys=True, kind="S")
    for idx, bb in enumerate(airscale.bb):
        displayHost(airscale, bb.M, index=idx, isSys=False, kind="M")
        displayHost(airscale, bb.S, index=idx, isSys=False, kind="S")
        displayHost(airscale, bb.L1, index=idx, isSys=False, kind="L1")


def displayHost(airscale, host, index=0, isSys=True, kind="M"):
    proxyAlias = "N/A"
    prefix = "sys"
    nodeId = "N/A"
    addr = ""
    host.airscale = airscale
    if host.hasProxy:
        proxyAlias = "{}".format(host.proxy.alias)
    if not isSys:
        prefix = " bb"
    if isSys and kind == "M":
        nodeId = host.nodeId
        addr = "@={}".format(host.sshConnection.addr)
    ipstr = "  {}[{}].{:2}:Alias={:11} type={:4} nodeId={:6} ".format(
        prefix, index, kind, host.alias, host.boardType, nodeId)
    ssdStr = "Proxy={:12} ssdId={:8} slot:proc={}:{} {}".format(
        proxyAlias, host.sshId, host.slot, host.proc, addr)
    StringTool.datedConsole("{}{}".format(StringTool.PREFIX_DISPLAY, ipstr + ssdStr))


def get_l1_mode(tl_config):
    try:
        for idx, ue in enumerate(tl_config.ues):
            prefix = "ues[{}]".format(idx)
            ue_ssh_alias = "ue_ssh_alias_{}".format(idx)
            cmd = 'grep "<L1Bypass>" /ffs/run/simmode/iphy.xml'
            csn.connect_to(ue.oam_ssh_connection_details.addr,
                           username=ue.oam_ssh_connection_details.username,
                           password=ue.oam_ssh_connection_details.password,
                           alias=ue_ssh_alias,
                           timeout=3)
            logging.info("Retrieving L1Bypass property : {}".format(cmd))
            l1bypass_property = csn.execute(command=cmd, connection=ue_ssh_alias)
            csn.disconnect(connection=ue_ssh_alias)
            logging.info("L1Bypass property found : {}".format(l1bypass_property))
            tl_config.isL1BP = "true" in l1bypass_property
            # StringTool.datedConsole("Airphone......:{} TLConfig.isL1BP={}".
            #                         format(ue.oam_ssh_connection_details.addr, tl_config.isL1BP))
            # limit to first ue
            break
    except Exception as e:
        StringTool.console(e)

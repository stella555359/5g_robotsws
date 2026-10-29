import re
from robot.api import logger
from taf.transport.ssh import ssh

ssh = ssh()


def check_if_static_route_is_present(dest_ip, gateway):
    if dest_ip == "0.0.0.0":
        dest_ip = "default"
    result = ssh.execute("route", connection="cOAM_toor4nsn")
    logger.console("route :{}".format(result))
    pattern = re.compile("(?<=" + dest_ip + ")(.*)(ethlmp0)")
    logger.console("pattern :{}".format(pattern))
    assert pattern.search(result).groups()[1] == "ethlmp0", \
        "route {} via {} is not present in route table".format(
            dest_ip, gateway)


def params_for_route(destIpAddr, destinationIpPrefixLength, gateway):
    return [{"destIpAddr": destIpAddr, "destinationIpPrefixLength": destinationIpPrefixLength, "gateway": gateway}]


def params_for_route_ipv6(destIpAddr, destinationIpPrefixLength, gateway):
    return [{"destIpv6Addr": destIpAddr, "destinationIpv6PrefixLength": destinationIpPrefixLength,
             "gatewayIpv6Addr": gateway}]


def add_params_rtpol(params, orderNumber, srcIpPrefixLength, routingTableDN, srcIpAddress, userLabel):
    for idx, val in enumerate(params):
        # logger.console("pattern :{} , {}".format(idx,val))
        tmpRTDN = val["routingTableDN"]
        logger.console("routingTableDN :{} , {}".format(idx, tmpRTDN))
        newTmp = tmpRTDN.split("SCF-1/")[1]
        logger.console("newRTDN :{} ,".format(newTmp.replace("_A", "")))
        val["routingTableDN"] = newTmp.replace("_A", "")
        val["userLabel"] = ""
        logger.console("pattern :{} , {}".format(idx, val))
    return params + [{"orderNumber": orderNumber, "srcIpPrefixLength": srcIpPrefixLength,
                      "routingTableDN": routingTableDN, "srcIpAddress": srcIpAddress, "userLabel": userLabel}]


def get_format_rtpol(params, newparams):
    for parm in params:
        tmpRTDN = parm["routingTableDN"]
        newDN = formatDN(tmpRTDN)
        if parm["userLabel"]:
            newparams = newparams + [{"orderNumber": str(parm["orderNumber"]), "routingTableDN": newDN,
                                      "srcIpAddress": parm["srcIpAddress"],
                                      "srcIpPrefixLength": str(parm["srcIpPrefixLength"]),
                                      "userLabel": parm["userLabel"]}]
        else:
            newparams = newparams + [{"orderNumber": str(parm["orderNumber"]), "routingTableDN": newDN,
                                      "srcIpAddress": parm["srcIpAddress"],
                                      "srcIpPrefixLength": str(parm["srcIpPrefixLength"])}]
    return newparams


def formatDN(oldDN):
    return oldDN.split("SCF-1/")[1].replace("_A", "")


def add_RTPOL(params, orderNumber, srcIpPrefixLength, routingTableDN, srcIpAddress, userLabel):
    return params + [{"orderNumber": orderNumber, "srcIpPrefixLength": srcIpPrefixLength,
                      "routingTableDN": routingTableDN, "srcIpAddress": srcIpAddress, "userLabel": userLabel}]


def del_RTPOL(params, orderNumber, srcIpPrefixLength, routingTableDN, srcIpAddress, userLabel):
    # logger.console("oldparams :{}".format(params))
    params.remove({"orderNumber": orderNumber, "srcIpPrefixLength": srcIpPrefixLength,
                   "routingTableDN": routingTableDN, "srcIpAddress": srcIpAddress, "userLabel": userLabel})
    return params


def add_simple_rtpol(params, orderNumber, srcIpPrefixLength, routingTableDN, srcIpAddress):
    return params + [{"orderNumber": orderNumber, "srcIpPrefixLength": srcIpPrefixLength,
                      "routingTableDN": routingTableDN, "srcIpAddress": srcIpAddress}]


def getRTable(table):
    if table == "main":
        return "main"
    return str(1) + str(table)


def Covert_BTS_Version(version):
    package = version.split('_')[-2]
    package_21B = version.split('_')[-3]
    if package == '000400':
        scf_name = 'SCF_0.400_DU.xml'
    elif package == '001100':
        scf_name = 'SCF_10.1100_DU.xml'
    if package_21B == '0012':
        scf_name = 'SCF_12.400_DU.xml'
    return scf_name

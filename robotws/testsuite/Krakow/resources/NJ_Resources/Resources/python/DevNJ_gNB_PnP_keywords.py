import os
import re
import logging
from xml.dom.minidom import parse
from taf.fdsw.rc.interfaces.FDSW18SP.autoconnection import ValidationPreChecks


def rename_gnb_commissioning_file(path_to_scf):
    """
    Rename the commissioning file with the name format gNB_PnP_{id}.xml

    :param path_to_scf: the full path of the saved commission file
    :return: path to renamed commission file
    """
    plan_id = ''
    if os.path.exists(path_to_scf):
        with open(path_to_scf, 'r') as scf_handler:
            for line in scf_handler.readlines():
                result = re.search("\"all\"\\s+id=\"(\\S+)\">", line)
                if result is not None:
                    plan_id = result.group(1)

    if plan_id:
        local_path = os.path.dirname(path_to_scf)
        logging.info("The id of the saved commission file is : {0}, rename it now.".format(plan_id))
        os.rename(path_to_scf, os.path.join(local_path, "gNB_PnP_{0}.xml".format(plan_id)))
        if os.path.exists(os.path.join(local_path, "gNB_PnP_{0}.xml".format(plan_id))):
            return os.path.join(local_path, "gNB_PnP_{0}.xml".format(plan_id))


def parse_auto_connection_parameters(path_to_file):
    """
    Parse the Autoconnection_Parameters.xml file and store related parameters into dedicated dict
    Note : currently only take tls=off scenario into consideration
    :param path_to_file: the full path of the Autoconnection_Parameters.xml file
    :return: dict with the name of Parameters
    """
    Parameters = {}
    key_list = ["_eNBIpAddress",
                "_netPrefixLength",
                "_defaultGateway",
                "_vlanId",
                "_identificationServerIpAddress"]

    if os.path.exists(path_to_file):
        domTree = parse(path_to_file)
        rootNode = domTree.documentElement
        for item in key_list:
            if rootNode.getElementsByTagName(item):
                Parameters[item] = rootNode.getElementsByTagName(item)[0].childNodes[0].data

        Parameters['ipAddress'] = Parameters.pop('_eNBIpAddress')
        ValidationPreChecks.validate_ip_address(address=Parameters['ipAddress'])
        Parameters['prefixLength'] = Parameters.pop('_netPrefixLength')
        Parameters['gateway'] = Parameters.pop('_defaultGateway')
        ValidationPreChecks.validate_ip_address(address=Parameters['gateway'])
        Parameters['vlanId'] = Parameters.pop('_vlanId')
        Parameters['omsIpAddress'] = Parameters.pop('_identificationServerIpAddress')
        ValidationPreChecks.validate_ip_address(address=Parameters['omsIpAddress'])
        logging.info("gNB PnP detailed management parameters are : {0}".format(Parameters))
    else:
        logging.error("{0} is not exist, please check!".format(path_to_file))

    return Parameters


def get_auto_connection_protocol(path_to_file):
    """
    Parse the Autoconnection_Parameters.xml file to get OAM protocol

    :param path_to_file: the full path of the Autoconnection_Parameters.xml file
    :return: protocol type
    """
    if os.path.exists(path_to_file):
        domTree = parse(path_to_file)
        rootNode = domTree.documentElement
        if rootNode.getElementsByTagName("_btsOamPeerProtocol"):
            oam_protocol = rootNode.getElementsByTagName("_btsOamPeerProtocol")[0].childNodes[0].data
            logging.info("The PnP OAM protocol is : {0}".format(oam_protocol))
            return oam_protocol


def set_auto_conn_parameters(parameters, protocol, connection):
    """
    Set the auto connection parameters that is managementPlaneParameters ,pnpProtocolParameters and
    certificateServerParameters then save
    Note : currently only take tls=off scenario into consideration
    :param parameters: PnP parameters which will be sent to rc
    :param protocol: PnP protocol parameters name Legacy or Ne3s
    :param connection: RescueConsoleConnection object or if used, string name alias
    """
    tmp_dict, AutoConn_Dict = {}, {}
    if parameters and protocol in ['LEGACY', 'NE3S']:
        tmp_dict['selectedProtocol'] = protocol
        AutoConn_Dict["managementPlaneParameters"] = parameters
        AutoConn_Dict["pnpProtocolParameters"] = tmp_dict
        AutoConn_Dict["certificateServerParameters"] = {}
        logging.info("The auto conn parameters to be sent to RC is : {0}".format(AutoConn_Dict))
        if AutoConn_Dict:
            result = connection._fdsw_interface._client.send(
                     method='config.autoconnection.update',
                     parameters=AutoConn_Dict,
                     timeout=60)
            if result.status is False:
                logging.error("Failed to set AutoConn parameters!")
                return 'Failure'
            else:
                return 'Success'
    else:
        logging.error("Management IP address or Protocol value is empty, please double check!")
        return 'Failure'

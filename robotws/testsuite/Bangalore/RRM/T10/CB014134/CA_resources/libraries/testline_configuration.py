"""Robotframework library for handing data from testline_configuration repository"""
from collections import namedtuple

from robot.api import logger
from taf.config.testline import CUS

Node = namedtuple("Node", ["addr", "smod", "cus"])
Smod = namedtuple("Smod", ["hw_type", "pdu"])
Cus = namedtuple("Cus", ["pdu"])
Pdu = namedtuple("Pdu", ["addr", "model", "outlet"])

HW_TYPE_MAPPING = {
    "FSMr3": "FSMF",
    "FSIP": "ASIA",
}


def nodes_from_ute_config(tl):
    nodes = []
    for i, _ in enumerate(tl, 1):
        try:
            host, fsm = tl.host[i], tl.fsm[i]
            try:
                cus_pdu = tl.cus[i].pdu
                cus = Cus(
                    pdu=Pdu(
                        addr=cus_pdu.addr, model=cus_pdu.device, outlet=cus_pdu.port
                    )
                )
            except IndexError:
                cus = None

            node = Node(
                addr=host.addr,
                smod=Smod(
                    hw_type=HW_TYPE_MAPPING.get(fsm.hw_type, fsm.hw_type),
                    pdu=Pdu(
                        addr=fsm.pdu.addr, model=fsm.pdu.device, outlet=fsm.pdu.port
                    ),
                ),
                cus=cus,
            )
        except Exception as e:
            logger.error(
                "`%s` occured while parsing testline configuration: %s."
                " Node #%d details were set to `None`" % (e.__class__.__name__, e, i)
            )
            node = Node(addr=None, smod=None, cus=None)
        finally:
            nodes.append(node)
    return nodes


def nodes_from_taf_config(tl):
    nodes = []
    for i, vm in enumerate(tl.test_pcs):
        try:
            smod = tl.enbs[i].system_module.common_units[0]
            for connection in vm.connections:
                try:
                    if isinstance(connection.device, CUS):
                        _pdu_port = connection.device.l1.common_units[0].pdu_port
                        cus = Cus(
                            pdu=Pdu(
                                addr=_pdu_port.pdu.addr,
                                model=_pdu_port.pdu.model or _pdu_port.pdu.vendor,
                                outlet=_pdu_port.port_no,
                            )
                        )
                        break
                except AttributeError:
                    continue
            else:
                cus = None
            node = Node(
                addr=vm.default_ssh_connection_details.addr,
                smod=Smod(
                    hw_type=smod.hardware_type,
                    pdu=Pdu(
                        addr=smod.pdu_port.pdu.addr,
                        model=smod.pdu_port.pdu.model or smod.pdu_port.pdu.vendor,
                        outlet=smod.pdu_port.port_no,
                    ),
                ),
                cus=cus,
            )
        except Exception as e:
            logger.error(
                "`%s` occured while parsing testline configuration: %s."
                " Node #%d details were set to `None`" % (e.__class__.__name__, e, i)
            )
            node = Node(addr=None, smod=None, cus=None)
        finally:
            nodes.append(node)
    return nodes


def unsupported_type(c):
    logger.error(
        "Reading testline configuration from %s is not supported."
        " Node details were set to `None`" % (type(c))
    )
    return [Node(addr=None, smod=None, cus=None)]


def parse_configuration(tl):
    """Returns list of testline VMs (nodes) and stuff accesible from them

    ``tl`` is an object imported from <TESTLINE_NAME> package of testline_configuration
    repository.
    """
    handler = {
        "UTE_CONFIG": nodes_from_ute_config,
        "TestLine": nodes_from_taf_config,
    }
    parse = handler.get(tl.__class__.__name__, unsupported_type)
    logger.debug("Parsing {0} using {1}".format(tl.__class__, parse))
    return parse(tl)


__all__ = ["parse_configuration"]

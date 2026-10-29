"""
Convert ute_testline_configuration PDU types to taf.config.testline model.

Requires:
    taf.config.testline ~= 1.125
    pysnmp ~= 4.4.4

Example usage in Robot Framework:

    ${taf_pdu}=    taf_pdu_from_ute_config_pdu    ${tl.fsm[1].pdu}
    taf.pdu.Setup PDU                             ${PDU}

PDU mapping is based on ute_pdu.factory.PduFactory & existing support in
taf.config.testline and taf.pdu.

VENDOR_TO_CLS dict maps ute_testline_configuration models to appropriate
taf.config.testline vendor classes. It should only contain keys that are
defined in ute_confit_testline.base.PduMixin.PDU_TYPES_ALLOWED. Mapping to
'None' means there's no support in TAF.

If any of these unsupported PDUs ever become supported, adding the right class
from taf.config.testline to the mapping will allow the pdu to be converted into
it via this keyword.

NOTE: for EPC PDUs this has a side effect of performing a speculative SNMP
"get" request to the defined port, to see which model of EPC we are actually
dealing with. The ute_pdu library did this to differentiate between EPC8220-1
and EPC8221-1, which have different OIDs.

Author: Blazej Michalik <blazej.michalik@nokia.com>
Maintainer: TAF Team <I_TAF_WRO@internal.nsn.com>
"""
import logging
from pysnmp.entity.rfc3413.oneliner import cmdgen
from taf.config.testline import pdu as taf_model


VENDOR_TO_CLS = {
    "APC": taf_model.APC,
    # Same as APC, except it has 16 outlets instead of 8
    "APC16": taf_model.APC,
    "SWH": taf_model.SWH,
    "ATEN": taf_model.ATEN,
    "ATEN24": taf_model.ATEN,
    # EPC was renamed to Gude, old EPC is deprecated
    "EPC": taf_model.Gude,
    # Same as EPC, just with "normally closed" ports (insert rant about
    # unnecessarily complicating SNMP interface semantics)
    "EPCNC": taf_model.Gude,
    "FACOM": taf_model.FACOM,
    # Enics acquired PKC circa 2017
    "PKC": taf_model.ENICS,
    # Same as PKC, except it has 16 outlets instead of 8
    "PKC16": taf_model.ENICS,
    # Similar to BBOX, but this one is actually supported by taf.pdu
    "BBOXPSE": taf_model.BlackBox,
    "HBTE": taf_model.HBTE,
    "FPFH": taf_model.FPFH,
    # Unsupported PDUs
    "DCS": None,
    # XXX: BBOX has a definition in taf.pdu, but not in taf.config.testline,
    # and its not really available anyway
    "BBOX": None,
    "MOXA": None,
    "SHCL": None,
    "MYCOMP": None,
    # This one isn't even supported in ute_pdu
    "SIMATIC": None,
    # XXX: this one is supported by taf.pdu, but not in taf.config.testline
    "ICT": None,
}


def taf_pdu_from_ute_config_pdu(pdu_object):
    """Convert old ute_testline_configuration Pdu to taf.config.testline.Pdu

    If the PDU is an EPC, this will try to connect to the PDU in question and
    check which of the two models supported by ute_pdu it is.

    This DOES NOT check whether the PDU was configured correctly in the old
    model object.
    """
    if isinstance(pdu_object, taf_model.Pdu):
        # This is taf.config.testline already - return as is
        return pdu_object

    pdu_config = {
        "addr": pdu_object.addr,
        "port_numbers": [pdu_object.port],
        "model": pdu_object.device,
        # XXX: Default versions should be fine, but we haven't cross-examined
        # whether any of the models apart from EPC need special casing here.
        "version": None,
        "snmp_user": pdu_object.snmp_user,
    }

    # Old ute_testline_configuration was holding PDUs per-model, while
    # taf.config.testline does it per-vendor. This does not matter anyway,
    # because all of the old models map 1:1 to taf.config.testline vendors.
    vendor = pdu_object.device
    TafConfigTestlinePdu = VENDOR_TO_CLS[vendor]

    if TafConfigTestlinePdu is None:
        # Vendor == model in case of ute_pdu. See commends above.
        raise ValueError(
            "This PDU model is not supported by TAF: {!r}.".format(vendor)
        )

    if vendor == "EPC":
        # This code checks which EPC we are talking about. Ute_pdu supported
        # two different models of EPC, speculatively using one OID, then
        # falling back to another if it didn't work.
        logging.info(
            "PDU to convert is an EPC. "
            "Executing SNMP requests to see which model exactly..."
        )
        outlet_id = str(pdu_object.port)
        epc_8220_1_oid = "1.3.6.1.4.1.28507.38.1.3.1.2.1.3." + outlet_id
        epc_8221_1_oid = "1.3.6.1.4.1.28507.56.1.3.1.2.1.3." + outlet_id

        udp_timeout = 1.0
        udp_port = 161
        udp_transport = cmdgen.UdpTransportTarget(
            (
                pdu_config["addr"],
                udp_port,
            ),
            udp_timeout,
        )

        snmpv3_config = pdu_config["snmp_user"]
        if snmpv3_config:
            auth = cmdgen.UsmUserData(**snmpv3_config)
        else:
            # Taken from ute_pdu.epc.EPC
            security_name = "my-agent"
            community = "private"
            version = 1
            auth = cmdgen.CommunityData(security_name, community, version)

        # Try 8220-1 first
        result_8220_1 = cmdgen.CommandGenerator().getCmd(
            auth, udp_transport, epc_8220_1_oid
        )
        result_8221_1 = cmdgen.CommandGenerator().getCmd(
            auth, udp_transport, epc_8221_1_oid
        )

        logging.debug("Results for 8220-1: {!r}.".format(result_8220_1))
        logging.debug("Results for 8221-1: {!r}.".format(result_8221_1))

        # Both results give no indication of an error (thanks, EPC), but the
        # bad one translates into an empty string.
        outlet_status_8220_1 = str(result_8220_1[3][0][1])
        outlet_status_8221_1 = str(result_8221_1[3][0][1])

        if outlet_status_8221_1 and not outlet_status_8220_1:
            version = "8221-1"
        elif outlet_status_8220_1 and not outlet_status_8221_1:
            version = "8220-1"
        else:
            raise RuntimeError(
                "Cannot discriminate EPC PDU version: PDU returned non-empty "
                "values for both OIDs."
            )

        pdu_config["version"] = version

    taf_pdu = TafConfigTestlinePdu(**pdu_config)

    if vendor == "EPCNC":
        for p in taf_pdu.port:
            # We didn't came up with this - it was the OEM.
            p.contactor = "NORMALLY_CLOSED"

    return taf_pdu

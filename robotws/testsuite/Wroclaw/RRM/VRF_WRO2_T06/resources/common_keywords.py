from ta_tshark_hex_parser import uesim_parser


def enforce_protocol(protocol: str):
    """
    Functions enforces rrc_protocol for a parser used by ta_messaging.

    :param protocol: either 'rrc' or 'nr-rrc'
    """
    uesim_parser.enforce_rrc_protocol(protocol)

"""
:copyright: Nokia Networks
:author: Marek Kieltyka <marek.kieltyka@nokia.com>, Mateusz Matusik <mateusz.matusik@nokia.com>
:maintainer: Marek Kieltyka <marek.kieltyka@nokia.com>, Mateusz Matusik <mateusz.matusik@nokia.com>
"""

import logging
from ta_messaging.message_verifiers import message_verifier
from ta_messaging.message_flows import get_flow
import ta_messaging.message_sources.message_sources_tshark_based as ta_msg_lib
from robot.libraries.BuiltIn import BuiltIn
from ta_tshark_hex_parser.hex_source import NRRRCHexSourceDescription


CB008985_XSFN_TIMESTAMP_HEX_SOURCE = \
    NRRRCHexSourceDescription(line_template=r'(\d+\.\d+\s+\d+\s+\d+\s+0x\S+\s+0x\S+\s+\d+\s+\d+\s+\S+)',
                              separator="\s+",  # nopep8
                              column_descripions=['occurrence_time', 'enb_id', 'cell_id', 'protocol', 'type', 'xsfn',
                                                  'rv_index', 'hex'],
                              sample_line='12345.111    2      1      0x3433    0x003f    784    12    00555555550000')
CB008985_XSFN_TSHARK_FIELDS = \
    "-e frame.time_epoch -e iphy.enb_id -e iphy.cell_id -e iphy.protocol.type -e iphy.message.type -e iphy.xsfn " \
    " -e iphy.rv_index -e iphy.data"

ta_msg_lib.TIMESTAMP_ENBID_CELLID_HEX_SOURCE_5G = CB008985_XSFN_TIMESTAMP_HEX_SOURCE
ta_msg_lib.TIMESTAMP_ENBID_CELLID_TSHARK_FIELDS_DEFINITION_5G = CB008985_XSFN_TSHARK_FIELDS


@message_verifier
def verify_sib1_was_sent_from_each_subcell(flow_alias, subcells_count):
    subcells_count = int(subcells_count)
    rv_indices = set()

    for alias_id in range(1, subcells_count+1):
        sib1_from_next_subcell = get_flow(flow_alias).get_message('SIB1_{}'.format(alias_id))
        rv_indices.add(sib1_from_next_subcell.rv_index)

    # BuiltIn().log_to_console(rv_indices)
    return len(rv_indices) == subcells_count

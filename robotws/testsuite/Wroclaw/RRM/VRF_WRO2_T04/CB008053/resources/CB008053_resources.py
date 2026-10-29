"""
:copyright: Nokia Networks
:authors:
    Michal Obszarny <michal.obszarny@nokia.com>
    Dawid Chuchnowski <dawid.chuchnowski@nokia.com>
:maintainers:
    Blanka Gozdek <blanka.gozdek@nokia.com>
"""

import logging
from ta_egate_cmd_parser import ta_egate_cmd_parser
from robot.api.deco import keyword


@keyword("Log traffic on scells NR-UE${ue_id} scells ${scell_range_start} to ${scell_range_stop}")
def get_traffic_values(ue_id="1", scell_range_start="0", scell_range_stop="7"):
    """
        Prints traffic values for scell in shorter form.
    """

    ta_egate = ta_egate_cmd_parser()
    cmd = ta_egate.get_command('ue_stats_nr')
    output = cmd(id=ue_id, scell=scell_range_start + '-' + scell_range_stop, type="pdsch", format="short",
                 size_unit='auto', delay="1000").execute()

    output = str(output).encode().decode('unicode-escape')
    start = output.index("=============================================================")
    stop = output.rindex("=============================================================")
    print(output[start+1:stop])

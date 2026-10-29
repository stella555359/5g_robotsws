"""
:copyright: Nokia Networks
:author: Krzysztof Domino
:contact: krzysztof.domino@nokia.com
"""
from taf.rfrl.utilities.robot.general import get_builtin_value

tl = get_builtin_value(param_name="tl")
mrbts = tl.gnbs[0].global_bts_id
nrbts = tl.gnbs[0].instance_id

delta_4CC_UL = [{"distName": "MRBTS-{}/NRBTS-{}".format(mrbts, nrbts), "operation": "update",
                 "parameters": [{"parameterName": "actTddPrePooling", "value": "true", "operation": "update"},
                                {"parameterName": "maxNumScellsUl", "value": "3", "operation": "update"}]},
                {"distName": "MRBTS-{}/NRBTS-{}/NRCELL-3".format(mrbts, nrbts), "operation": "update",
                 "parameters": [{"parameterName": "nrCellType", "value": "2DL2UL", "operation": "update"},
                                {"parameterName": "cellBarred", "value": "notBarred", "operation": "update"}]},
                {"distName": "MRBTS-{}/NRBTS-{}/NRCELL-4".format(mrbts, nrbts), "operation": "update",
                 "parameters": [{"parameterName": "nrCellType", "value": "2DL2UL", "operation": "update"},
                                {"parameterName": "cellBarred", "value": "notBarred", "operation": "update"}]},
                {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-3".format(mrbts),
                 "operation": "create",
                 "parameters": [{"parameterName": "direction", "value": "RX", "operation": "update"},
                                {"parameterName": "resourceDN",
                                 "value": "MRBTS-{}/EQM-1/APEQM-1/RMOD-1/PHYANT-1".format(mrbts),
                                 "operation": "update"}]},
                {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-4".format(mrbts),
                 "operation": "create",
                 "parameters": [{"parameterName": "direction", "value": "RX", "operation": "update"},
                                {"parameterName": "resourceDN",
                                 "value": "MRBTS-{}/EQM-1/APEQM-1/RMOD-1/PHYANT-1".format(mrbts),
                                 "operation": "update"}]},
                {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-3".format(mrbts),
                 "operation": "create",
                 "parameters": [{"parameterName": "direction", "value": "RX", "operation": "update"},
                                {"parameterName": "resourceDN",
                                 "value": "MRBTS-{}/EQM-1/APEQM-1/RMOD-1/PHYANT-1".format(mrbts),
                                 "operation": "update"}]},
                {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-4".format(mrbts),
                 "operation": "create",
                 "parameters": [{"parameterName": "direction", "value": "RX", "operation": "update"},
                                {"parameterName": "resourceDN",
                                 "value": "MRBTS-{}/EQM-1/APEQM-1/RMOD-1/PHYANT-1".format(mrbts),
                                 "operation": "update"}]}]

delta_2CC_UL = [{"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-3".format(mrbts),
                 "operation": "delete",
                 "parameters": []},
                {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-4".format(mrbts),
                 "operation": "delete",
                 "parameters": []},
                {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-3".format(mrbts),
                 "operation": "delete",
                 "parameters": []},
                {"distName": "MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-4".format(mrbts),
                 "operation": "delete",
                 "parameters": []},
                {"distName": "MRBTS-{}/NRBTS-{}", "operation": "update".format(mrbts, nrbts),
                "parameters": [{"parameterName": "actTddPrePooling", "value": "false", "operation": "update"},
                               {"parameterName": "maxNumScellsUl", "value": "1", "operation": "update"}]},
                {"distName": "MRBTS-{}/NRBTS-{}/NRCELL-3".format(mrbts, nrbts), "operation": "update",
                 "parameters": [{"parameterName": "nrCellType", "value": "2DL0UL", "operation": "update"},
                                {"parameterName": "cellBarred", "value": "barred", "operation": "update"}]},
                {"distName": "MRBTS-{}/NRBTS-{}/NRCELL-4".format(mrbts, nrbts), "operation": "update",
                 "parameters": [{"parameterName": "nrCellType", "value": "2DL0UL", "operation": "update"},
                                {"parameterName": "cellBarred", "value": "barred", "operation": "update"}]}]

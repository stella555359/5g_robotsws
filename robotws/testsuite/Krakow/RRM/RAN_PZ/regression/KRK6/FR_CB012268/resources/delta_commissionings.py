"""
:copyright: Nokia Networks
...   maintainer:     Jakub Matuszczyk, jakub.matuszczyk@nokia.com
...   author:         Dawid Chuchnowski, dawid.chuchnowski@nokia.com
"""

from taf.rfrl.utilities.robot.general import get_builtin_value

_tl = get_builtin_value(param_name="tl")
_mrbts_id = _tl.gnbs[0].instance_id
_nrbts_id = _tl.gnbs[0].global_bts_id

DL_MAC_SDU_meas_enabling = [
    {
        "distName": f"MRBTS-{_mrbts_id}/NRBTS-{_nrbts_id}/NRPMRNL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "miNrHighRlcCell",
                "value": "5min",
                "operation": "update"
            },
            {
                "parameterName": "miNrLowRlcCellNrpmqap",
                "value": "5min",
                "operation": "update"
            },
            {
                "parameterName": "miNrMacSduReport",
                "value": "5min",
                "operation": "update"
            }
        ]
    }
]

cell_edge_DL_pathloss_thresholds = [
    {
        "distName": f"MRBTS-{_mrbts_id}/NRBTS-{_nrbts_id}/NRCELL-260/NRPMCCP_CELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cellEdgeUeDlPathlossThrPmCount",
                "value": "41",
                "operation": "update"
            },
            {
                "parameterName": "cellNearUeDlPathlossThrPmCount",
                "value": "40",
                "operation": "update"
            },
        ]
    }
]

cell_middle_DL_pathloss_thresholds = [
    {
        "distName": f"MRBTS-{_mrbts_id}/NRBTS-{_nrbts_id}/NRCELL-260/NRPMCCP_CELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cellEdgeUeDlPathlossThrPmCount",
                "value": "120",
                "operation": "update"
            },
            {
                "parameterName": "cellNearUeDlPathlossThrPmCount",
                "value": "40",
                "operation": "update"
            },
        ]
    }
]

cell_near_DL_pathloss_thresholds = [
    {
        "distName": f"MRBTS-{_mrbts_id}/NRBTS-{_nrbts_id}/NRCELL-260/NRPMCCP_CELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cellEdgeUeDlPathlossThrPmCount",
                "value": "120",
                "operation": "update"
            },
            {
                "parameterName": "cellNearUeDlPathlossThrPmCount",
                "value": "100",
                "operation": "update"
            },
        ]
    }
]

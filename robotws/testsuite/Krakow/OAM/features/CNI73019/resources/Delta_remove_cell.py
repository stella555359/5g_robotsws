from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
instance_id = tl.gnbs[0].instance_id

remove_cell_delta = [
  {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELLGRP-0".format(instance_id), "operation": "update",
   "parameters": [{"parameterName": "nrCellList", "value": ["1"], "operation": "update"}]},
  {
    "distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-10".format(instance_id),
    "operation": "delete",
    "parameters": []
  },
  {
    "distName": "MRBTS-{0}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-10".format(instance_id),
    "operation": "delete",
    "parameters": []
  }
]

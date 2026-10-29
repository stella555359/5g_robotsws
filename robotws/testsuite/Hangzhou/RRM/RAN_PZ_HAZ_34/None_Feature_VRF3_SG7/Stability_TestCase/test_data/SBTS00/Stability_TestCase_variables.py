from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id

HO_PARAMS = [
  "NRBTS:actConflictConfiguration=true",
  "NRBTS:actIncXn=true"
]

from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')
gnb_commissioning = GnbCommissioning()
bts0_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')

delta = [
  {
    "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-2".format(bts0_id),
    "operation": "update",
    "parameters": [
      {
        "value": [
                    {
                        "sharingEnabled": "false",
                        "btsInfoEnabled": "true",
                        "peerRatInfo": "eutraSupport",
                        "btsInfoEnabled": "false"
                    }
                ],
        "operation": "update",
        "parameterName": "sharingConfig"

      }
    ]
  },
  {
    "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-2".format(bts0_id),
    "operation": "update",
    "parameters": [
      {
        "operation": "delete",
        "parameterName": "peerBtsPortList"

      }
    ]
  }
]

delta_2 = [
  {
    "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-2".format(bts0_id),
    "operation": "update",
    "parameters": [
      {
        "value": [
                    {
                        "controllerRole": "Primary",
                        "sharingEnabled": "true",
                        "btsInfoEnabled": "true",
                        "peerRatInfo": "eutraSupport",
                        "btsInfoEnabled": "false"
                    }
                ],
        "operation": "update",
        "parameterName": "sharingConfig"

      }
    ]
  },
  {
    "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-2".format(bts0_id),
    "operation": "update",
    "parameters": [
        {
            "operation": "update",
            "parameterName": "peerBtsPortList",
            "value": ["3", "4"],
        }
    ]
  },
]


def disable_asirmod_sharing(du_id=0, gnb_id=0):
    core_units = tl.gnbs[gnb_id].dus[du_id].airscale.core_units
    for core_unit in core_units:
        for asirmod_id in range(len(core_unit.rus)):
            gnb_commissioning.perform_configuration_parameter_recommissioning(
                dist_name="MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-{}".format(bts0_id, asirmod_id+1),
                parameter="sharingConfig",
                operation="delete",
                value=[{"controllerRole": "Primary"}],
                bts_id=gnb_id,
                du_id=du_id)

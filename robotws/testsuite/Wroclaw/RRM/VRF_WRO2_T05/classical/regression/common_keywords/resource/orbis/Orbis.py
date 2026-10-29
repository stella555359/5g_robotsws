from robot.libraries.BuiltIn import BuiltIn
from requests import get, put
import json
import os
try:
    # Python 2
    from urlparse import urljoin
except ImportError:
    # Python 3
    from urllib.parse import urljoin


def put_payload(payload, url):
    response = put(url, json=payload)
    print("Response code: ", str(response))
    if response.status_code == 504:
        raise Exception("[ERROR] HTTP access denied. Check firewall on Orbis PC and proxy settings "
                        "on the PC you are using to run this script. Switch them off.")
    if response.status_code != 200:
        raise Exception("[ERROR] Command did not execute properly! Make sure "
                        "the power is on and positioner's UI's mode is not switched to local.")


def query_params_for_wait_movement_stops(axis, timeout):
    params = {
        "timeout": timeout,
        "axis": axis
    }
    params = {param: value for (param, value) in params.items() if value is not None}
    return params


def validate_axis_input(axis):
    if axis not in ["all", "any", "x", "y", "z", "azimuth", "rotation", "elevation", None]:
        raise ValueError


def position_payload(azimuth, elevation, rotation, x, y, z):
    position_payload_input = {
        "azimuth": int(azimuth),
        "elevation": int(elevation),
        "rotation": rotation,
        "x": x,
        "y": y,
        "z": z
    }
    return {axis: position for (axis, position) in position_payload_input.items() if position is not None}


def properties_payload(azimuth=2, elevation=1):
    properties_payload_input = {
        "azimuth":
            {
             "acceleration": 0.0,
             "deceleration": 0.0,
             "speed": float(azimuth),
             "lowLimit": -180.0,
             "highLimit": 180.0
            },
        "elevation":
            {
             "acceleration": 0.0,
             "deceleration": 0.0,
             "speed": float(elevation),
             "lowLimit": -180.0,
             "highLimit": 180.0
            }
    }
    return properties_payload_input


def query_params_for_wait_movement_stops(axis, timeout):
    params = {
        "timeout": timeout,
        "axis": axis
    }
    params = {param: value for (param, value) in params.items() if value is not None}
    return params


def set_dut_position(base_url, azimuth=0, elevation=0, rotation=None, x=None, y=None, z=None):
    url = urljoin(base=base_url, url="/api/dutMove/v0/positions")
    payload = position_payload(azimuth, elevation, rotation, x, y, z)
    put_payload(payload, url)


def set_properties(base_url, azimuth=2, elevation=1):
    url = urljoin(base=base_url, url="/api/dutMove/v0/properties")
    payload = properties_payload(azimuth, elevation)
    put_payload(payload, url)


def wait_for_dut_movement_to_stop(base_url, timeout=60, axis=None):
    validate_axis_input(axis)
    if not axis:
        axis = "all"
    try:
        response = get(
            url=urljoin(base=base_url, url="api/dutMove/v0/waitMoving"),
            params=query_params_for_wait_movement_stops(axis, timeout)
        )
        parse_response(response)
    except Exception as e:
        pass

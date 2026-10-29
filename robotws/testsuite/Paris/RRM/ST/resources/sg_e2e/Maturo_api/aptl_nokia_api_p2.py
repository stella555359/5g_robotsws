"""
This is Nokia Library to pilot Maturo Gmbh APTL positioner.

Versions:
    15/01/2019 - Version 1.0 - First library version

Specifications:
    * Maximum Device Under Test weight: 50 kg
    * Horizontal angular range: +140/-140 deg
    * Vertical angular range for AEUA: +60/-30 deg
    * Vertical angular range for AEQA: +60/-10 deg
    * Polarity angular range: +95/-95 deg
    * Angular precision: 0,05 deg
    * Acceleration/Deceleration range: 1 to 10 deg/s/s
    * Acceleration/Deceleration precision: 0,1 deg/s/s
    * Speed range: 0,5 deg/s to 30 deg/s
    * Speed precision: 0,1 deg/s

"""

import socket
import time
import math

# Socket to communicate with APTL Positioner
socket_aptl = None

# Horizontal angle range
max_positive_angle_hor = 140.00
max_negative_angle_hor = -140.00
cw_hor_mechanical_stop_angle = 140.00
ccw_hor_mechanical_stop_angle = -140.00
# Vertical angle range
max_positive_angle_ver = 60.00
max_negative_angle_ver = -10.00
max_negative_angle_ver_AEUA = -30.00
max_negative_angle_ver_AEQA = -10.00
cw_ver_mechanical_stop_angle = 60.00
ccw_ver_mechanical_stop_angle = -10.00
# Polarity angle range
max_positive_angle_pol = 95.00
max_negative_angle_pol = -95.00
cw_pol_mechanical_stop_angle = 95.00
ccw_pol_mechanical_stop_angle = -95.00
# Acceleration/Deceleration range
min_acceleration = 1
max_acceleration = 10
# Speed range
min_speed = 0.5
max_speed = 30


def _send_aptl_msg(msg):
    message = b''.join([bytes(msg), '\x00'])
    # print('Sending command {} ...'.format(message))
    socket_aptl.send(message)

    response = socket_aptl.recv(65565)[:-1].decode('ascii')
    # print('Received:', response)
    return response


def _send_aptl_msg_no_resp(msg):
    message = b''.join([bytes(msg), '\x00'])
    # print('Sending command {} ...'.format(message))
    socket_aptl.send(message)
    return


def _send_device(axis_type):
    print('Device to be used: {}'.format(axis_type))
    if axis_type == 'hor':
        axis_type_aptl = '1'
    elif axis_type == 'ver':
        axis_type_aptl = '3'
    elif axis_type == 'pol':
        axis_type_aptl = '5'
    else:
        print('send_device: Bad Axis Type -  {}'.format(axis_type))
        return 'Error Bad Axis Type {}'.format(axis_type)
    cmd_to_send = 'LD ' + axis_type_aptl + ' DV'
    return _send_aptl_msg(cmd_to_send)


def _send_acceleration(acceleration):
    print('Acceleration to be sent: {0:.2f} deg/s/s'.format(acceleration))
    if acceleration > max_acceleration:
        acceleration = max_acceleration
    elif acceleration < min_acceleration:
        acceleration = min_acceleration
    print('Acceleration sent: {0:.2f} deg/s/s'.format(acceleration))
    cmd_to_send = 'LD ' + '{0:.2f}'.format(acceleration) + ' AF'
    return _send_aptl_msg(cmd_to_send)


def _send_deceleration(deceleration):
    print('Deceleration to be sent: {0:.2f} deg/s/s'.format(deceleration))
    if deceleration > max_acceleration:
        deceleration = max_acceleration
    elif deceleration < min_acceleration:
        deceleration = min_acceleration
    print('Acceleration sent: {0:.2f} deg/s/s'.format(deceleration))
    cmd_to_send = 'LD ' + '{0:.2f}'.format(deceleration) + ' DF'
    return _send_aptl_msg(cmd_to_send)


def _send_speed(speed_in_deg_per_s):
    print('Speed to be sent: {0:.2f} deg/s/s'.format(speed_in_deg_per_s))
    if speed_in_deg_per_s > max_speed:
        speed_in_deg_per_s = max_speed
    elif speed_in_deg_per_s < min_speed:
        speed_in_deg_per_s = min_speed
    speed_in_rpm = speed_in_deg_per_s / 6
    print('Speed in rpm: {}'.format(speed_in_rpm))
    print('Rounded speed in rpm: {}'.format(round(speed_in_rpm, 2)))
    print('Speed sent: {0:.2f} deg/s = {1:.2f} rpm'.format(speed_in_deg_per_s, round(speed_in_rpm, 2)))
    cmd_to_send = 'LD ' + '{0:.2f}'.format(speed_in_rpm) + ' SF'
    return _send_aptl_msg(cmd_to_send)


def _send_device_acc_dec_speed(axis_type, acceleration, deceleration, speed):
    # APTL COMMAND 1 - Set Device to axis_type rotation
    resp = _send_device(axis_type)
    if 'OK:' not in resp:
        return 1
    # APTL COMMAND 2 - Set acceleration
    resp = _send_acceleration(acceleration)
    if 'OK:' not in resp:
        return 1
    # APTL COMMAND 3 - Set deceleration
    resp = _send_deceleration(deceleration)
    if 'OK:' not in resp:
        return 1
    # APTL COMMAND 4 - Set rotation speed
    resp = _send_speed(speed)
    if 'OK:' not in resp:
        return 1
    return 0


def _any_axis_moving():
    # Wait 5ms before querying
    time.sleep(0.005)
    return _send_aptl_msg('BB') == '1'


def _check_rotation_angle(axis_type, angle):
    if axis_type == 'hor':
        if angle > cw_hor_mechanical_stop_angle:
            angle = cw_hor_mechanical_stop_angle
        elif angle < ccw_hor_mechanical_stop_angle:
            angle = ccw_hor_mechanical_stop_angle
    elif axis_type == 'ver':
        if angle > cw_ver_mechanical_stop_angle:
            angle = cw_ver_mechanical_stop_angle
        elif angle < ccw_ver_mechanical_stop_angle:
            angle = ccw_ver_mechanical_stop_angle
    elif axis_type == 'pol':
        if angle > cw_pol_mechanical_stop_angle:
            angle = cw_pol_mechanical_stop_angle
        elif angle < ccw_pol_mechanical_stop_angle:
            angle = ccw_pol_mechanical_stop_angle
    return angle


def _check_rotation_angle_toward_max(axis_type, angle):
    if axis_type == 'hor':
        if angle > max_positive_angle_hor:
            angle = max_positive_angle_hor
        elif angle < max_negative_angle_hor:
            angle = max_negative_angle_hor
    elif axis_type == 'ver':
        if angle > max_positive_angle_ver:
            angle = max_positive_angle_ver
        elif angle < max_negative_angle_ver:
            angle = max_negative_angle_ver
    elif axis_type == 'pol':
        if angle > max_positive_angle_pol:
            angle = max_positive_angle_pol
        elif angle < max_negative_angle_pol:
            angle = max_negative_angle_pol
    return angle


def _send_axis_rotation(axis_type, angle):
    print('Rotation angle to be sent: {} deg'.format(angle))
    # Check angle is not too big
    angle = _check_rotation_angle(axis_type, angle)
    print('Rotating: {} deg'.format(angle))
    cmd_to_send = 'LD ' + '{0:.2f}'.format(angle) + ' DG NP GO'
    resp = _send_aptl_msg(cmd_to_send)
    # Wait until the movement is completed
    while True:
        if not _any_axis_moving():
            break
    # Check returned value and return
    if 'OK:' not in resp:
        print('Error returned: {}'.format(resp))
        return 1
    return 0


def _send_all_axis_rotation(hor_angle, ver_angle, pol_angle):
    print('Hor/Ver/Pol rotation angles to be sent: {}/{}/{} deg'.format(hor_angle, ver_angle, pol_angle))
    # Check horizontal angle
    hor_angle = _check_rotation_angle('hor', hor_angle)
    # Check vertical angle
    ver_angle = _check_rotation_angle('ver', ver_angle)
    # Check polarity angle
    pol_angle = _check_rotation_angle('hor', pol_angle)
    # Perform rotation
    print('Rotating: {}/{}/{} deg'.format(hor_angle, ver_angle, pol_angle))
    cmd_to_send = 'NA {0:.2f};{1:.2f};{2:.2f};'.format(hor_angle, ver_angle, pol_angle)
    resp = _send_aptl_msg(cmd_to_send)
    # Wait until the movement is completed
    while True:
        if not _any_axis_moving():
            break
    # Check returned value and return
    if 'OK:' not in resp:
        print('Error returned: {}'.format(resp))
        return 1
    return 0


def _command_response_mode():
    for i in range(3):  # repeat until in command response mode, but max 3 times.
        resp = _send_aptl_msg('CR?')
        print('resp for CR?: {}'.format(resp))
        if resp != 'CR1 Cmd Response Enabled':
            _send_aptl_msg_no_resp('CR 1')
            print('Sent CR 1')
            time.sleep(0.2)
        else:
            return True
    return False


def _init_aptl(radio_unit_type):
    global max_negative_angle_ver
    print('Initialization of APTL Positioner...')
    print('Retrieve identification string...')
    resp = _send_aptl_msg('*IDN?')
    print('APTL IDN String: {}'.format(resp))

    # Activate the Command Response Mode
    if not _command_response_mode():
        print('_init_aptl: not possible to activate Command Response Mode!')
        return 1
    # Set Horizontal/Vertical/Polarity Axis to 0 position
    # if reset_all_axis() == 1:
    #    return 1
    # Update max angle values based on Radio Unit type

    print('_init_aptl: Radio Unit type is {}'.format(radio_unit_type))

    if radio_unit_type == 'AEUA':
        max_negative_angle_ver = max_negative_angle_ver_AEUA
    elif radio_unit_type == 'AEQA':
        max_negative_angle_ver = max_negative_angle_ver_AEQA

    # Set Horizontal Axis Mechanical Stops
    if set_axis_clockwise_mechanical_stop('hor', max_positive_angle_hor) == 1:
        return 1
    if set_axis_counterclockwise_mechanical_stop('hor', max_negative_angle_hor) == 1:
        return 1

    # Set Vertical Axis Mechanical Stops
    if set_axis_clockwise_mechanical_stop('ver', max_positive_angle_ver) == 1:
        return 1
    if set_axis_counterclockwise_mechanical_stop('ver', max_negative_angle_ver) == 1:
        return 1

    # Set Polarity Axis Mechanical Stops
    if set_axis_clockwise_mechanical_stop('pol', max_positive_angle_pol) == 1:
        return 1
    if set_axis_counterclockwise_mechanical_stop('pol', max_negative_angle_pol) == 1:
        return 1

    # Read current positions
    hor_pos, ver_pos, pol_pos = read_all_axis()
    print('_init_aptl: current positions - {0:.2f}, {1:.2f}, {2:.2f}'.format(hor_pos, ver_pos, pol_pos))
    return 0


def open_aptl_connection(host, port, radio_unit_type):
    """
    This function opens the TCP connection toward Maturo positioner.

    .. warning:: Use the correct radio_unit_type not to have Radio Unit collide with positioner on a counterclockwise
    vertical rotation.

    Args
    ----
    host : string
        IP address of Maturo NCD-F Positioner Controller
    port : int
        TCP port of Maturo NCD-F Positioner Controller
    radio_unit_type : string
        'AEUA' or 'AEQA'

    Returns
    -------
    int
        0 in case of success, 1 in case of error

    See Also
    --------
    close_aptl_connection()

    """
    print('Calling open_aptl_connection({}, {}, {}):'.format(host, port, radio_unit_type))
    global socket_aptl
    socket_aptl = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    socket_aptl.connect((host, port))
    print('Connection established with host {} on port {}'.format(host, port))
    # Initialize APTL and return
    return _init_aptl(radio_unit_type)


def close_aptl_connection():
    """
    This function closes the TCP connection toward Maturo positioner.

    Returns
    -------
    int
        0 in case of success, 1 in case of error

    See Also
    --------
    open_aptl_connection()

    """
    print('Calling close_aptl_connection():')
    global socket_aptl
    print('Closing connection...')
    socket_aptl.close()
    socket_aptl = None
    return 0


def reset_axis(axis_type):
    """
    This function sets angular position to 0 for provided axis_type.

    Args
    ----
    axis_type : string
        'hor' for horizontal, 'ver' for vertical and 'pol' for polarization

    Returns
    -------
    int
        0 in case of success, 1 in case of error

    See Also
    --------
    reset_all_axis()

    """
    print('Calling reset_axis({}):'.format(axis_type))
    # APTL COMMANDS 1 - Set device, acceleration, deceleration and speed
    if _send_device_acc_dec_speed(axis_type, 5, 5, 15) == 1:
        return 1
    # APTL COMMAND 2 - Rotate to 0.00
    return _send_axis_rotation(axis_type, 0.00)


def reset_all_axis():
    """
    This function sets angular position to 0 for horizontal, vertical and polarization axis.

    Returns
    -------
    int
        0 in case of success, 1 in case of error

    See Also
    --------
    reset_axis()

    """
    print('Calling reset_all_axis():')
    # APTL COMMANDS 1 - Set device to Horizontal, acceleration, deceleration and speed
    if _send_device_acc_dec_speed('hor', 5, 5, 15) == 1:
        return 1
    # APTL COMMANDS 2 - Set device to Vertical, acceleration, deceleration and speed
    if _send_device_acc_dec_speed('ver', 5, 5, 15) == 1:
        return 1
    # APTL COMMANDS 3 - Set device to Polarity, acceleration, deceleration and speed
    if _send_device_acc_dec_speed('pol', 5, 5, 15) == 1:
        return 1
    # APTL COMMAND 4 - Set Horizontal/Vertical/Polarity positions to 0 degrees
    return _send_all_axis_rotation(0.00, 0.00, 0.00)


def read_axis(axis_type):
    """
    This function reads angular position for provided axis_type.

    Args
    ----
    axis_type : string
        'hor' for horizontal, 'ver' for vertical and 'pol' for polarization

    Returns
    -------
    int
        0 in case of success, 1 in case of error
    float
        In case of success (first returned value is 0) : angular position (deg) (2 decimals precision) for axis_type
    string
        In case of error (first returned value is 1) : error string

    See Also
    --------
    read_all_axis()

    """
    print('Calling read_axis({}):'.format(axis_type))
    # APTL COMMAND 1 - Set Device to axis_type rotation
    resp = _send_device(axis_type)
    if 'OK:' not in resp:
        return 1, resp
    # APTL COMMAND 2 - Read horizontal position
    resp = _send_aptl_msg("RP")
    if 'Error' in resp:
        return 1, resp
    check_resp = float(resp)
    check_resp_abs = math.fabs(check_resp)
    if check_resp_abs == 0.0:
        returned_resp = '{0:.2f}'.format(check_resp_abs)
    else:
        returned_resp = '{0:.2f}'.format(check_resp)
    return 0, float(returned_resp)


def read_all_axis():
    """
    This function reads angular positions for horizontal, vertical and polarization axis.

    Returns
    -------
    float
        Horizontal position (deg) (2 decimals precision)
    float
        Vertical position (deg) (2 decimals precision)
    float
        Polarization position (deg) (2 decimals precision)

    See Also
    --------
    read_axis()

    """
    print('Calling read_all_axis():')
    # APTL COMMAND 1 - Read all positions
    resp = _send_aptl_msg('RA')
    print('read_all_axis: current positions - {}'.format(resp))
    # Get each position and return
    cur_positions = resp.split(';')
    print(cur_positions)
    if len(cur_positions) == 4:
        return float(cur_positions[0]), float(cur_positions[1]), float(cur_positions[2])
    else:
        return None


def get_axis_clockwise_mechanical_stop(axis_type):
    """
    This function returns angular position that was set as mechanical stop for given axis_type in clockwise direction.

    Args
    ----
    axis_type : string
        'hor' for horizontal, 'ver' for vertical and 'pol' for polarization

    Returns
    -------
    float
        Angular position (deg) (2 decimals precision) set as mechanical stop

    See Also
    --------
    set_axis_clockwise_mechanical_stop()

    """
    print('Calling get_axis_clockwise_mechanical_stop({}):'.format(axis_type))
    if axis_type == 'hor':
        return cw_hor_mechanical_stop_angle
    elif axis_type == 'ver':
        return cw_ver_mechanical_stop_angle
    elif axis_type == 'pol':
        return cw_pol_mechanical_stop_angle
    else:
        return cw_ver_mechanical_stop_angle


def set_axis_clockwise_mechanical_stop(axis_type, angular_position):
    """
    This function sets provided angular position as mechanical stop for given axis_type in clockwise direction.

    Args
    ----
    axis_type : string
        'hor' for horizontal, 'ver' for vertical and 'pol' for polarization
    angular_position : float
        Angle (deg) (2 decimals precision) to be set as mechanical stop

    Returns
    -------
    int
        0 in case of success, 1 in case of error

    See Also
    --------
    get_axis_clockwise_mechanical_stop()

    """
    global cw_hor_mechanical_stop_angle
    global cw_ver_mechanical_stop_angle
    global cw_pol_mechanical_stop_angle

    print('Calling set_axis_clockwise_mechanical_stop({}, {}):'.format(axis_type, angular_position))
    # APTL COMMAND 1 - Set Device to axis_type rotation
    resp = _send_device(axis_type)
    if 'OK:' not in resp:
        return 1
    # Set angular_position to positive value
    angular_position = math.fabs(angular_position)
    # Set Maximum limit
    angular_position = _check_rotation_angle_toward_max(axis_type, angular_position)
    # Save mechanical stop value
    if axis_type == 'hor':
        cw_hor_mechanical_stop_angle = angular_position
    elif axis_type == 'ver':
        cw_ver_mechanical_stop_angle = angular_position
    elif axis_type == 'pol':
        cw_pol_mechanical_stop_angle = angular_position
    # APTL COMMAND 2 - Set Horizontal rotation clockwise limit
    cmd_to_send = 'LD ' + '{0:.2f}'.format(angular_position) + ' DG WL'
    resp = _send_aptl_msg(cmd_to_send)
    if 'OK:' not in resp:
        return 1
    return 0


def get_axis_counterclockwise_mechanical_stop(axis_type):
    """
    This function returns angular position that was set as mechanical stop for given axis_type
    in counterclockwise direction.

    Args
    ----
    axis_type : string
        'hor' for horizontal, 'ver' for vertical and 'pol' for polarization

    Returns
    -------
    float
        Angular position (deg) (2 decimals precision) set as mechanical stop

    See Also
    --------
    set_axis_counterclockwise_mechanical_stop()

    """
    print('Calling get_axis_counterclockwise_mechanical_stop({}):'.format(axis_type))
    if axis_type == 'hor':
        return ccw_hor_mechanical_stop_angle
    elif axis_type == 'ver':
        return ccw_ver_mechanical_stop_angle
    elif axis_type == 'pol':
        return ccw_pol_mechanical_stop_angle
    else:
        return ccw_ver_mechanical_stop_angle


def set_axis_counterclockwise_mechanical_stop(axis_type, angular_position):
    """
    This function sets provided angular position as mechanical stop for given axis_type in counterclockwise direction.

    Args
    ----
    axis_type : string
        'hor' for horizontal, 'ver' for vertical and 'pol' for polarization
    angular_position : float
        Angle (deg) (2 decimals precision) to be set as mechanical stop

    Returns
    -------
    int
        0 in case of success, 1 in case of error

    See Also
    --------
    get_axis_counterclockwise_mechanical_stop()

    """
    global ccw_hor_mechanical_stop_angle
    global ccw_ver_mechanical_stop_angle
    global ccw_pol_mechanical_stop_angle
    print('Calling set_axis_counterclockwise_mechanical_stop({}, {}):'.format(axis_type, angular_position))
    # APTL COMMAND 1 - Set Device to axis_type rotation
    resp = _send_device(axis_type)
    if 'OK:' not in resp:
        return 1
    # Set angular_position to negative value
    angular_position = -math.fabs(angular_position)
    # Set Maximum limit
    angular_position = _check_rotation_angle_toward_max(axis_type, angular_position)
    # Set angle to positive value before applying CL command
    angular_position = math.fabs(angular_position)
    # Save mechanical stop value
    if axis_type == 'hor':
        ccw_hor_mechanical_stop_angle = -angular_position
    elif axis_type == 'ver':
        ccw_ver_mechanical_stop_angle = -angular_position
    elif axis_type == 'pol':
        ccw_pol_mechanical_stop_angle = -angular_position
    # APTL COMMAND 2 - Set Horizontal rotation counterclockwise limit
    cmd_to_send = 'LD ' + '-''{0:.2f}'.format(angular_position) + ' DG CL'
    resp = _send_aptl_msg(cmd_to_send)
    if 'OK:' not in resp:
        return 1
    return 0


def turn_absolute_axis(axis_type, angle, acceleration, speed):
    """
    This function performs rotation on given axis_type to absolute angle value,
    at provided acceleration/deceleration and speed.

    Args
    ----
    axis_type : string
        'hor' for horizontal, 'ver' for vertical and 'pol' for polarization
    angle : float
        Absolute target angle (deg) (2 decimals precision)
    acceleration : float
        Acceleration/deceleration (deg/s/s) (1 decimal precision) at beginning/end of movement
    speed : float
        Speed of movement (deg/s) (1 decimal precision) after acceleration and before deceleration

    Returns
    -------
    int
        0 in case of success, 1 in case of error

    See Also
    --------
    turn_absolute_all_axis(), turn_relative_axis(), turn_axis_with_step()

    """
    print('Calling turn_absolute_axis({}, {}, {}, {}):'.format(axis_type, angle, acceleration, speed))
    # APTL COMMANDS 1 - Set device, acceleration, deceleration and speed
    if _send_device_acc_dec_speed(axis_type, acceleration, acceleration, speed) == 1:
        return 1
    # APTL COMMAND 2 - Rotate to angle
    return _send_axis_rotation(axis_type, angle)


def turn_absolute_all_axis(hor_angle, hor_acc, hor_speed,
                           ver_angle, ver_acc, ver_speed,
                           pol_angle, pol_acc, pol_speed):
    """
    This function performs rotation on horizontal/vertical/polarization axis at same time
    to provided absolute angle values, at provided accelerations/decelerations and speeds.

    Args
    ----
    hor_angle : float
        Horizontal absolute target angle (deg) (2 decimals precision)
    hor_acc : float
        Horizontal acceleration/deceleration (deg/s/s) (1 decimal precision) at beginning/end of movement
    hor_speed : float
        Horizontal speed of movement (deg/s) (1 decimal precision) after acceleration and before deceleration
    ver_angle : float
        Vertical absolute target angle (deg) (2 decimals precision)
    ver_acc : float
        Vertical acceleration/deceleration (deg/s/s) (1 decimal precision) at beginning/end of movement
    ver_speed : float
        Vertical speed of movement (deg/s) (1 decimal precision) after acceleration and before deceleration
    pol_angle : float
        Polarity absolute target angle (deg) (2 decimals precision)
    pol_acc : float
        Polarity acceleration/deceleration (deg/s/s) (1 decimal precision) at beginning/end of movement
    pol_speed : float
        Polarity speed of movement (deg/s) (1 decimal precision) after acceleration and before deceleration

    Returns
    -------
    int
        0 in case of success, 1 in case of error

    See Also
    --------
    turn_absolute_axis(), turn_relative_axis(), turn_axis_with_step()

    """
    print('Calling turn_absolute_all_axis({}, {}, {}, {}, {}, {}, {}, {}, {}):'.format(
        hor_angle, hor_acc, hor_speed,
        ver_angle, ver_acc, ver_speed,
        pol_angle, pol_acc, pol_speed))
    # APTL COMMANDS 1 - Set device, acceleration, deceleration and speed for hor rotation
    if _send_device_acc_dec_speed('hor', hor_acc, hor_acc, hor_speed) == 1:
        return 1
    # APTL COMMANDS 2 - Set device, acceleration, deceleration and speed for ver rotation
    if _send_device_acc_dec_speed('ver', ver_acc, ver_acc, ver_speed) == 1:
        return 1
    # APTL COMMANDS 3 - Set device, acceleration, deceleration and speed for pol rotation
    if _send_device_acc_dec_speed('pol', pol_acc, pol_acc, pol_speed) == 1:
        return 1
    # APTL COMMAND 4 - Rotate to angle
    return _send_all_axis_rotation(hor_angle, ver_angle, pol_angle)


def turn_relative_axis(axis_type, angle, acceleration, speed):
    """
    This function performs rotation on given axis_type to relative angle value,
    at provided acceleration/deceleration and speed.

    Args
    ----
    axis_type : string
        'hor' for horizontal, 'ver' for vertical and 'pol' for polarization
    angle : float
        Relative target angle (deg) (2 decimals precision)
    acceleration : float
        Acceleration/deceleration (deg/s/s) (1 decimal precision) at beginning/end of movement
    speed : float
        Speed of movement (deg/s) (1 decimal precision) after acceleration and before deceleration

    Returns
    -------
    int
        0 in case of success, 1 in case of error

    See Also
    --------
    turn_absolute_axis(), turn_absolute_all_axis(), turn_axis_with_step()

    """
    print('Calling turn_relative_axis({}, {}, {}, {}):'.format(axis_type, angle, acceleration, speed))
    # APTL COMMANDS 1 - Set device, acceleration, deceleration and speed
    if _send_device_acc_dec_speed(axis_type, acceleration, acceleration, speed) == 1:
        return 1
    # APTL COMMAND 2 - Read Position
    ret_value, current_pos = read_axis(axis_type)
    if ret_value == 1:
        return 1
    target_position = current_pos + angle
    # APTL COMMAND 3 - Rotate to angle
    return _send_axis_rotation(axis_type, target_position)


def turn_axis_with_step(axis_type, angle, step, acceleration, speed, pause_time):
    """
    This function performs successive rotations of 'step' degrees on given axis_type,
    at provided acceleration/deceleration and speed, up to reaching relative 'angle' value.

    Args
    ----
    axis_type : string
        'hor' for horizontal, 'ver' for vertical and 'pol' for polarization
    angle : float
        Relative final target angle (deg) (2 decimals precision)
    step : float
        Angle (deg) (2 decimals precision) of each rotation
    acceleration : float
        Acceleration/deceleration (deg/s/s) (1 decimal precision) at beginning/end of each movement
    speed : float
        Speed of movement (deg/s) (1 decimal precision) after acceleration and before deceleration
    pause_time : int
        Time to wait (ms) between each rotation

    Returns
    -------
    int
        0 in case of success, 1 in case of error

    See Also
    --------
    turn_absolute_axis(), turn_absolute_all_axis(), turn_axis_with_step()

    """
    print('Calling turn_axis_with_step({}, {}, {}, {}, {}, {}):'.format(axis_type, angle, step,
                                                                        acceleration, speed, pause_time))
    if angle == 0:
        print('turn_axis_with_step: Error angle is 0')
        return 1
    if step == 0:
        print('turn_axis_with_step: Error step is 0')
        return 1
    if angle < 0:
        step = -math.fabs(step)
    else:
        step = math.fabs(step)
    # APTL COMMANDS 1 - Set device, acceleration, deceleration and speed
    if _send_device_acc_dec_speed(axis_type, acceleration, acceleration, speed) == 1:
        return 1
    # APTL COMMAND 2 - Read Position
    ret_value, current_angle = read_axis(axis_type)
    if ret_value == 1:
        return 1
    # APTL COMMAND 3 - Perform rotations
    print('turn_axis_with_step: current_angle = {}'.format(current_angle))
    target_angle = current_angle + angle
    # Limit target angle based on set mechanical stops
    target_angle = _check_rotation_angle(axis_type, target_angle)
    print('turn_axis_with_step: target_angle = {}'.format(target_angle))
    # Check whether current position is already at mechanical stop
    if step > 0:
        if current_angle >= target_angle:
            return 0
    else:
        if current_angle <= target_angle:
            return 0
    while 1:
        step_target_angle = current_angle + step
        # Limit rotation angle in case it is exceeding target angle
        if step > 0:
            if step_target_angle > target_angle:
                step_target_angle = target_angle
        else:
            if step_target_angle < target_angle:
                step_target_angle = target_angle
        ret_value = _send_axis_rotation(axis_type, step_target_angle)
        # Check returned value and return
        if ret_value == 1:
            return 1
        current_angle = step_target_angle
        if current_angle == target_angle:
            break
        else:
            time.sleep(pause_time / 1000)
    return 0


def turn_absolute_diagonal(hor_angle, hor_acc, hor_speed,
                           ver_angle, ver_acc, ver_speed):
    """
    This function performs rotation on horizontal/vertical axis at same time
    to provided absolute angle values, at provided accelerations/decelerations and speeds.

    Args
    ----
    hor_angle : float
        Horizontal absolute target angle (deg) (2 decimals precision)
    hor_acc : float
        Horizontal acceleration/deceleration (deg/s/s) (1 decimal precision) at beginning/end of movement
    hor_speed : float
        Horizontal speed of movement (deg/s) (1 decimal precision) after acceleration and before deceleration
    ver_angle : float
        Vertical absolute target angle (deg) (2 decimals precision)
    ver_acc : float
        Vertical acceleration/deceleration (deg/s/s) (1 decimal precision) at beginning/end of movement
    ver_speed : float
        Vertical speed of movement (deg/s) (1 decimal precision) after acceleration and before deceleration

    Returns
    -------
    int
        0 in case of success, 1 in case of error

    See Also
    --------
    turn_relative_diagonal(), turn_diagonal_with_step()

    """
    print('Calling turn_absolute_diagonal({}, {}, {}, {}, {}, {}):'.format(hor_angle, hor_acc, hor_speed,
                                                                           ver_angle, ver_acc, ver_speed))
    # APTL COMMANDS 1 - Set device, acceleration, deceleration and speed for hor rotation
    if _send_device_acc_dec_speed('hor', hor_acc, hor_acc, hor_speed) == 1:
        return 1
    # APTL COMMANDS 2 - Set device, acceleration, deceleration and speed for ver rotation
    if _send_device_acc_dec_speed('ver', ver_acc, ver_acc, ver_speed) == 1:
        return 1
    # APTL COMMAND 3 - Get current position for pol rotation
    ret_value, pol_angle = read_axis('pol')
    if ret_value == 1:
        return 1
    # APTL COMMAND 4 - Rotate to angle
    return _send_all_axis_rotation(hor_angle, ver_angle, pol_angle)


def turn_relative_diagonal(hor_angle, hor_acc, hor_speed,
                           ver_angle, ver_acc, ver_speed):
    """
    This function performs rotation on horizontal/vertical axis at same time
    to provided relative angle values, at provided accelerations/decelerations and speeds.

    Args
    ----
    hor_angle : float
        Horizontal relative target angle (deg) (2 decimals precision)
    hor_acc : float
        Horizontal acceleration/deceleration (deg/s/s) (1 decimal precision) at beginning/end of movement
    hor_speed : float
        Horizontal speed of movement (deg/s) (1 decimal precision) after acceleration and before deceleration
    ver_angle : float
        Vertical relative target angle (deg) (2 decimals precision)
    ver_acc : float
        Vertical acceleration/deceleration (deg/s/s) (1 decimal precision) at beginning/end of movement
    ver_speed : float
        Vertical speed of movement (deg/s) (1 decimal precision) after acceleration and before deceleration

    Returns
    -------
    int
        0 in case of success, 1 in case of error

    See Also
    --------
    turn_absolute_diagonal(), turn_diagonal_with_step()

    """
    print('Calling turn_relative_diagonal({}, {}, {}, {}, {}, {}):'.format(hor_angle, hor_acc, hor_speed,
                                                                           ver_angle, ver_acc, ver_speed))
    # APTL COMMANDS 1 - Set device, acceleration, deceleration and speed for hor rotation
    if _send_device_acc_dec_speed('hor', hor_acc, hor_acc, hor_speed) == 1:
        return 1
    # APTL COMMANDS 2 - Set device, acceleration, deceleration and speed for ver rotation
    if _send_device_acc_dec_speed('ver', ver_acc, ver_acc, ver_speed) == 1:
        return 1
    # APTL COMMAND 3 - Read Horizontal/Vertical/Polarity Positions
    current_hor_angle, current_ver_angle, current_pol_angle = read_all_axis()
    target_hor_angle = current_hor_angle + hor_angle
    target_ver_angle = current_ver_angle + ver_angle
    # APTL COMMAND 4 - Rotate to angle
    return _send_all_axis_rotation(target_hor_angle, target_ver_angle, current_pol_angle)


def turn_diagonal_with_step(hor_angle, hor_step, hor_acc, hor_speed,
                            ver_angle, ver_step, ver_acc, ver_speed, pause_time):
    """
    This function performs successive rotations of 'step' degrees on horizontal and vertical axis at same time,
    at provided acceleration/deceleration and speed, up to reaching relative 'angle' values.

    Args
    ----
    hor_angle : float
        Relative final horizontal target angle (deg) (2 decimals precision)
    hor_step : float
        Horizontal angle (deg) (2 decimals precision) of each rotation
    hor_acc : float
        Horizontal acceleration/deceleration (deg/s/s) (1 decimal precision) at beginning/end of each movement
    hor_speed : float
        Horizontal speed of movement (deg/s) (1 decimal precision) after acceleration and before deceleration
    ver_angle : float
        Relative final vertical target angle (deg) (2 decimals precision)
    ver_step : float
        Vertical angle (deg) (2 decimals precision) of each rotation
    ver_acc : float
        Vertical acceleration/deceleration (deg/s/s) (1 decimal precision) at beginning/end of each movement
    ver_speed : float
        Vertical speed of movement (deg/s) (1 decimal precision) after acceleration and before deceleration
    pause_time : int
        Time to wait (ms) between each rotation

    Returns
    -------
    int
        0 in case of success, 1 in case of error

    See Also
    --------
    turn_absolute_diagonal(), turn_relative_diagonal()

    """
    print('Calling turn_diagonal_with_step({}, {}, {}, {}, {}, {}, {}, {}, {}):'.format(
        hor_angle, hor_step, hor_acc, hor_speed,
        ver_angle, ver_step, ver_acc, ver_speed, pause_time))
    if hor_angle == 0:
        print('turn_diagonal_with_step: Error hor_angle is 0')
        return 1
    if ver_angle == 0:
        print('turn_diagonal_with_step: Error ver_angle is 0')
        return 1
    if hor_step == 0:
        print('turn_diagonal_with_step: Error hor_step is 0')
        return 1
    if ver_step == 0:
        print('turn_diagonal_with_step: Error ver_step is 0')
        return 1
    if hor_angle < 0:
        hor_step = -math.fabs(hor_step)
    else:
        hor_step = math.fabs(hor_step)
    if ver_angle < 0:
        ver_step = -math.fabs(ver_step)
    else:
        ver_step = math.fabs(ver_step)
    # APTL COMMANDS 1 - Set device, acceleration, deceleration and speed for hor rotation
    if _send_device_acc_dec_speed('hor', hor_acc, hor_acc, hor_speed) == 1:
        return 1
    # APTL COMMANDS 2 - Set device, acceleration, deceleration and speed for ver rotation
    if _send_device_acc_dec_speed('ver', ver_acc, ver_acc, ver_speed) == 1:
        return 1
    # APTL COMMAND 3 - Read Horizontal/Vertical/Polarity Positions
    current_hor_angle, current_ver_angle, current_pol_angle = read_all_axis()
    target_hor_angle = current_hor_angle + hor_angle
    target_ver_angle = current_ver_angle + ver_angle
    # Limit target hor angle based on set mechanical stops
    target_hor_angle = _check_rotation_angle('hor', target_hor_angle)
    # Limit target ver angle based on set mechanical stops
    target_ver_angle = _check_rotation_angle('ver', target_ver_angle)
    # Check whether current positions are already at mechanical stop
    if hor_step > 0:
        if current_hor_angle >= target_hor_angle:
            return 0
    else:
        if current_hor_angle <= target_hor_angle:
            return 0
    if ver_step > 0:
        if current_ver_angle >= target_ver_angle:
            return 0
    else:
        if current_ver_angle <= target_ver_angle:
            return 0
    # APTL COMMAND 4 - Perform rotations
    while 1:
        step_target_hor_angle = current_hor_angle + hor_step
        step_target_ver_angle = current_ver_angle + ver_step
        # Limit rotation angle in case it is exceeding target angle
        if hor_step > 0:
            if step_target_hor_angle > target_hor_angle:
                step_target_hor_angle = target_hor_angle
        else:
            if step_target_hor_angle < target_hor_angle:
                step_target_hor_angle = target_hor_angle
        if ver_step > 0:
            if step_target_ver_angle > target_ver_angle:
                step_target_ver_angle = target_ver_angle
        else:
            if step_target_ver_angle < target_ver_angle:
                step_target_ver_angle = target_ver_angle
        ret_value = _send_all_axis_rotation(step_target_hor_angle,
                                            step_target_ver_angle,
                                            current_pol_angle)
        # Check returned value and return
        if ret_value == 1:
            return 1
        current_hor_angle = step_target_hor_angle
        current_ver_angle = step_target_ver_angle
        if current_hor_angle == target_hor_angle:
            break
        elif current_ver_angle == target_ver_angle:
            break
        else:
            time.sleep(pause_time / 1000)
    return 0

#!/bin/python -B
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
# Helpfull library to use Matturo robot in robot tests
"""

import aptl_nokia_api_p2 as aptl_nokia_api

host = '10.28.0.192'  # CV003 Maturo robot ip adress
port = 200
axis_type_H = 'hor'
axis_type_V = 'ver'
radio_unit_type = 'AEQA'  # IMPORTANT TO PROTECT SPAN ROTATION
speed = 3.0
acceleration = 1.0
angle_err_tolerance = 5.0


def moveRobot_to_Position(h_angle, v_angle, host=host, port=port,
                          acceleration=acceleration, speed=speed):
    # Conversion from unicode to float work from robot script
    if isinstance(h_angle, unicode):
        h_angle = float(h_angle.replace(u'\N{MINUS SIGN}', '-'))
    if isinstance(v_angle, unicode):
        v_angle = float(v_angle.replace(u'\N{MINUS SIGN}', '-'))
    err_msg = ''

    aptl_nokia_api.open_aptl_connection(host, port,
                                        radio_unit_type)
    aptl_nokia_api.turn_absolute_axis(axis_type_H, h_angle, acceleration, speed)
    ret_value, ret_angle = aptl_nokia_api.read_axis(axis_type_H)
    angle_err = abs(ret_angle - h_angle)

    if bool(ret_value):
        err_msg = "Error occurred {} \n".format(ret_angle)
    elif angle_err > angle_err_tolerance:
        err_msg = "Error occurred on position set {} and returned {}\n".format(h_angle, ret_angle)
    else:
        aptl_nokia_api.turn_absolute_axis(axis_type_V, v_angle, acceleration, speed)
        ret_value, ret_angle = aptl_nokia_api.read_axis(axis_type_V)
        angle_err = abs(ret_angle - v_angle)
        if bool(ret_value):
            err_msg = "Error occurred {} \n".format(ret_angle)
        elif angle_err > angle_err_tolerance:
            err_msg = "Error occurred on position set {} and returned {}\n".format(v_angle, ret_angle)

    aptl_nokia_api.close_aptl_connection()

    return err_msg


def moveRobot(filename, host=host, port=port, acceleration=acceleration, speed=speed):
    # MATURO INIT FOR PARTICULAR RADIO_UNIT:
    aptl_nokia_api.open_aptl_connection(host, port,
                                        radio_unit_type)
    # POSITION:
    with open(filename, "r") as f:
        for line in f:
            columns = line.split(',')
            x = float(columns[0])
            y = float(columns[1])
            axis_type = 'hor'

            aptl_nokia_api.turn_absolute_axis(axis_type, x, acceleration, speed)
            ret_value, angle = aptl_nokia_api.read_axis('hor')

            axis_type = 'ver'
            aptl_nokia_api.turn_absolute_axis(axis_type, y, acceleration, speed)
            ret_value, angle = aptl_nokia_api.read_axis('ver')

    aptl_nokia_api.close_aptl_connection()

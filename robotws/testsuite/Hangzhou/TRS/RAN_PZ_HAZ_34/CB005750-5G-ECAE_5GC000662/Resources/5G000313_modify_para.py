# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1'

PARAMS_TO_MODIFY_DomainNumber0 = [dict(dist_name=MR_NR_BTS_NAME, parameter='gnssControlMode', value='GPS only')]

PARAMS_TO_MODIFY_DomainNumber1 = [dict(dist_name=MR_NR_BTS_NAME, parameter='gnssControlMode', value='GLONASS only')]

PARAMS_TO_MODIFY_DomainNumber2 = [dict(dist_name=MR_NR_BTS_NAME, parameter='gnssControlMode', value='Beidou only')]

PARAMS_TO_MODIFY_DomainNumber3 = [dict(dist_name=MR_NR_BTS_NAME, parameter='gnssControlMode', value='GLONASS-Beidou')]

PARAMS_TO_MODIFY_DomainNumber4 = [dict(dist_name=MR_NR_BTS_NAME, parameter='gnssControlMode', value='GPS-GLONASS')]

PARAMS_TO_MODIFY_DomainNumber5 = [dict(dist_name=MR_NR_BTS_NAME, parameter='gnssControlMode', value='GPS-Beidou')]

PARAMS_GPS_only = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actGps', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actBeidou', value='false'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actGlonass', value='false')]

PARAMS_GLONASS_only = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actGps', value='false'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actBeidou', value='false'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actGlonass', value='true')]

PARAMS_Beidou_only = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actGps', value='false'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actBeidou', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actGlonass', value='false')]

PARAMS_GLONASS_Beidou = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actGps', value='false'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actBeidou', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actGlonass', value='true')]

PARAMS_GPS_GLONASS = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actGps', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actBeidou', value='false'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actGlonass', value='true')]

PARAMS_GPS_Beidou = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actGps', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actBeidou', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actGlonass', value='false')]

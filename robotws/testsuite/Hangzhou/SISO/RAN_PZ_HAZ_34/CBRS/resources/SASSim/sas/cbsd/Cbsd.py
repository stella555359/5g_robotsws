# !/usr/bin/env python
# -*- coding: utf-8 -*-

import time
import datetime
import json
import threading
from sas.Consts import *
from grant.Grant import Grant


# remove the key finded firstly from a dictionary by recursion search.
def dict_pop(dic, key):
    if (isinstance(dic, dict)):
        if key in dic:
            dic.pop(key)
            return True
        else:
            for value_item in iter(dic.values()):
                if isinstance(value_item, dict):
                    if (dict_pop(value_item, key)):
                        return True
    return False


# update the key value finded firstly from a dictionary by recursion search.
def dict_update(dic, key, val):
    if (isinstance(dic, dict)):
        if key in dic:
            dic[key] = val
            return True
        else:
            for value_item in iter(dic.values()):
                if isinstance(value_item, dict):
                    if (dict_update(value_item, key, val)):
                        return True
    return False


class CBSD(object):
    def __init__(self, config, logHandler):
        self.config = config
        self.log = logHandler
        self.version = None
        self.opState = STATE_UNREG
        self.userID = ''
        self.fccID = ''
        self.serialNum = ''
        self.callSign = None
        self.category = None
        self.cbsdID = ''
        self.channelID = ''
        self.PeakPower = 0
        self.cbsdInfo = {}
        self.airIf = {}
        self.instPar = {}
        self.groupPar = {}
        self.meas = []
        self.grantList = {}
        self.grantBlockedRequestSequenceList = {}
        self.excludePar = False

    def cleanup(self):
        self.version = None
        self.userID = ''
        self.fccID = ''
        self.serialNum = ''
        self.callSign = None
        self.category = None
        self.cbsdID = ''
        self.channelID = ''
        self.PeakPower = 0
        self.cbsdInfo.clear()
        self.airIf.clear()
        self.instPar.clear()
        self.groupPar.clear()
        self.meas = []
        self.grantList.clear()
        self.excludePar = False

    def stop(self):
        for grant_id in self.grantList.keys():
            grant = self.grantList[grant_id]
            grant.stop()
        self.cleanup()
        self.opState = STATE_UNREG
        self.log.info('cbsd %s is stopped' % self.cbsdID)

    def get_opState(self):
        return self.opState

    def set_opState(self, state, duration=None):
        old_state = self.opState
        if state == STATE_UNREG:
            if old_state == STATE_REG:
                for grant_id in self.grantList:
                    grant = self.grantList[grant_id]
                    grant.stop()
                self.grantList.clear()
            self.opState = state
            self.log.info('cbsd %s change op state to %s from %s' % (self.cbsdID, state, old_state))
        elif state == STATE_REG:
            if old_state == STATE_UNREG:
                self.opState = state
                self.log.info('cbsd %s change op state to %s from %s' % (self.cbsdID, state, old_state))
        else:
            self.log.warning('invalid op state %s' % state)

    def check_REG_Conditional_param(self, reg_req):
        # REG-Conditional Parameters in TS1.1
        if self.version >= SAS_VERSION_TS_11:
            if PAR_CBSD_CAT not in reg_req:
                return PAR_CBSD_CAT
            if PAR_AIR_IF not in reg_req:
                return PAR_AIR_IF
            else:
                if PAR_RADIO_TECH not in reg_req[PAR_AIR_IF]:
                    return PAR_RADIO_TECH
            if reg_req[PAR_CBSD_CAT] != 'B':
                if PAR_INSTALL_PAR not in reg_req:
                    return PAR_INSTALL_PAR
                else:
                    if PAR_LATITUDE not in reg_req[PAR_INSTALL_PAR]:
                        return PAR_LATITUDE
                    if PAR_LONGITUDE not in reg_req[PAR_INSTALL_PAR]:
                        return PAR_LONGITUDE
                    if PAR_HEIGHT not in reg_req[PAR_INSTALL_PAR]:
                        return PAR_HEIGHT
                    if PAR_HEIGHT_TYPE not in reg_req[PAR_INSTALL_PAR]:
                        return PAR_HEIGHT_TYPE
                    if PAR_INDOOR_DEP not in reg_req[PAR_INSTALL_PAR]:
                        return PAR_INDOOR_DEP
                    # antennaAzimuth, antennaDowntilt and antennaBeamwidth denpends on Category
                    if PAR_ANT_GAIN not in reg_req[PAR_INSTALL_PAR]:
                        return PAR_ANT_GAIN
            if PAR_MEAS_CAP not in reg_req:
                return PAR_MEAS_CAP
            return None

    def reg_handler(self, msg, protocol, blist=None):
        self.cleanup()
        if isinstance(msg, dict) is not True:
            # MISSING_PARAM
            self.log.warning('msg body is not dict type')
            return [102, '']
        if protocol not in sas_version_t:
            self.log.warning('not supported SAS-CBSD protocol version: %s' % protocol)
            return [100, sas_version_t]
        else:
            self.version = protocol
        reg_req = msg
        # Required Parameters
        # userId
        if PAR_USER_ID not in reg_req:
            self.log.warning('missing %s in registeration request' % PAR_USER_ID)
            return [102, PAR_USER_ID]
        # fccId
        if PAR_FCC_ID not in reg_req:
            self.log.warning('missing %s in registeration request' % PAR_FCC_ID)
            return [102, PAR_FCC_ID]
        elif len(reg_req[PAR_FCC_ID]) > 19:
            self.log.warning('length of %s exceeded 19 characters' % PAR_FCC_ID)
            return [103, PAR_FCC_ID]
        # cbsdSerialNumber
        if PAR_CBSD_SN not in reg_req:
            self.log.warning('missing %s in registeration request' % PAR_CBSD_SN)
            return [102, PAR_CBSD_SN]
        elif len(reg_req[PAR_CBSD_SN]) > 64:
            self.log.warning('length of %s exceeded 64 characters' % PAR_CBSD_SN)
            return [103, PAR_CBSD_SN]
        self.userID = reg_req[PAR_USER_ID]
        self.fccID = reg_req[PAR_FCC_ID]
        self.serialNum = reg_req[PAR_CBSD_SN]
        self.cbsdID = self.userID + '_' + self.fccID + '_' + self.serialNum
        self.config.getCbsdSpecificConfig(self.cbsdID)
        # REG-Conditional Parameters in TS1.1
        if self.version >= SAS_VERSION_TS_11:
            missed_param = self.check_REG_Conditional_param(reg_req)
            if missed_param is not None:
                self.log.warning('missing %s in registeration request' % missed_param)
                return [102, missed_param]
        # Optional/Conditional Parameters
        if PAR_CALL_SIGN in reg_req:
            self.callSign = reg_req[PAR_CALL_SIGN]
        if PAR_CBSD_CAT in reg_req:
            if reg_req[PAR_CBSD_CAT] != 'A' and reg_req[PAR_CBSD_CAT] != 'B':
                self.log.warning('invalid value of %s : %s' % (PAR_CBSD_CAT, reg_req[PAR_CBSD_CAT]))
                return [103, PAR_CBSD_CAT]
            self.category = reg_req[PAR_CBSD_CAT]
        if PAR_CBSD_INFO in reg_req:
            cbsdInfo = reg_req[PAR_CBSD_INFO]
            if PAR_INFO_VENDOR in cbsdInfo:
                self.cbsdInfo[PAR_INFO_VENDOR] = cbsdInfo[PAR_INFO_VENDOR]
            if PAR_INFO_MODEL in cbsdInfo:
                self.cbsdInfo[PAR_INFO_MODEL] = cbsdInfo[PAR_INFO_MODEL]
            if PAR_INFO_SV in cbsdInfo:
                self.cbsdInfo[PAR_INFO_SV] = cbsdInfo[PAR_INFO_SV]
            if PAR_INFO_HV in cbsdInfo:
                self.cbsdInfo[PAR_INFO_HV] = cbsdInfo[PAR_INFO_HV]
            if PAR_INFO_FV in cbsdInfo:
                self.cbsdInfo[PAR_INFO_FV] = cbsdInfo[PAR_INFO_FV]
        if PAR_AIR_IF in reg_req:
            airIf = reg_req[PAR_AIR_IF]
            if PAR_RADIO_TECH in airIf:
                self.airIf[PAR_RADIO_TECH] = airIf[PAR_RADIO_TECH]
            if PAR_RADIO_SPEC in airIf:  # supportedSpec is removed from TS1.1
                self.airIf[PAR_RADIO_SPEC] = airIf[PAR_RADIO_SPEC]
        if PAR_INSTALL_PAR in reg_req:
            instPar = reg_req[PAR_INSTALL_PAR]
            if PAR_LATITUDE in instPar:
                latitude = instPar[PAR_LATITUDE]
                if ((isinstance(latitude, int) or isinstance(latitude, float)) and
                        latitude >= -90.000000 and latitude <= 90.000000):
                    self.instPar[PAR_LATITUDE] = instPar[PAR_LATITUDE]
                else:
                    self.log.warning('invalid value of %s : %s' % (PAR_LATITUDE, latitude))
                    return [103, PAR_LATITUDE]
            if PAR_LONGITUDE in instPar:
                longitude = instPar[PAR_LONGITUDE]
                if ((isinstance(longitude, int) or
                     isinstance(longitude, float)) and longitude >= -180.000000 and longitude <= 180.000000):
                    self.instPar[PAR_LONGITUDE] = instPar[PAR_LONGITUDE]
                else:
                    self.log.warning('invalid value of %s : %s' % (PAR_LONGITUDE, longitude))
                    return [103, PAR_LONGITUDE]
            if PAR_HEIGHT in instPar:
                if isinstance(instPar[PAR_HEIGHT], int) or isinstance(instPar[PAR_HEIGHT], float):
                    self.instPar[PAR_HEIGHT] = instPar[PAR_HEIGHT]
            if PAR_HEIGHT_TYPE in instPar:
                height_type = instPar[PAR_HEIGHT_TYPE]
                if height_type not in heigt_type_t:
                    self.log.warning('invalid value of %s : %s' % (PAR_HEIGHT_TYPE, height_type))
                    return [103, PAR_HEIGHT_TYPE]
                self.instPar[PAR_HEIGHT_TYPE] = instPar[PAR_HEIGHT_TYPE]
            if PAR_HORI_ACCU in instPar:
                if isinstance(instPar[PAR_HORI_ACCU], int) or isinstance(instPar[PAR_HORI_ACCU], float):
                    if instPar[PAR_HORI_ACCU] >= 50:
                        self.log.warning('invalid value of %s : %s' % (PAR_HORI_ACCU, instPar[PAR_HORI_ACCU]))
                        return [103, PAR_HORI_ACCU]
                    self.instPar[PAR_HORI_ACCU] = instPar[PAR_HORI_ACCU]
            if PAR_VERT_ACCU in instPar:
                if isinstance(instPar[PAR_VERT_ACCU], int) or isinstance(instPar[PAR_VERT_ACCU], float):
                    if instPar[PAR_VERT_ACCU] >= 3:
                        self.log.warning('invalid value of %s : %s' % (PAR_VERT_ACCU, instPar[PAR_VERT_ACCU]))
                        return [103, PAR_HORI_ACCU]
                    self.instPar[PAR_VERT_ACCU] = instPar[PAR_VERT_ACCU]
            if PAR_INDOOR_DEP in instPar:
                if isinstance(instPar[PAR_INDOOR_DEP], bool):
                    self.instPar[PAR_INDOOR_DEP] = instPar[PAR_INDOOR_DEP]
            if PAR_ANT_AZIM in instPar:
                azim = instPar[PAR_ANT_AZIM]
                if isinstance(azim, int) and azim >= 0 and azim <= 359:
                    self.instPar[PAR_ANT_AZIM] = instPar[PAR_ANT_AZIM]
                else:
                    self.log.warning('invalid value of %s : %s' % (PAR_ANT_AZIM, azim))
                    return [103, PAR_ANT_AZIM]
            elif self.category == 'B':
                self.log.warning('missing %s in registeration request for Category B CBSD' % PAR_ANT_AZIM)
                return [102, PAR_ANT_AZIM]
            if PAR_ANT_DOWN_TILT in instPar:
                tilt = instPar[PAR_ANT_DOWN_TILT]
                if isinstance(tilt, int) and tilt >= -90 and tilt <= 90:
                    self.instPar[PAR_ANT_DOWN_TILT] = instPar[PAR_ANT_DOWN_TILT]
                else:
                    self.log.warning('invalid value of %s : %s' % (PAR_ANT_DOWN_TILT, tilt))
                    return [103, PAR_ANT_DOWN_TILT]
            elif self.category == 'B':
                self.log.warning('missing %s in registeration request for Category B CBSD' % PAR_ANT_DOWN_TILT)
                return [102, PAR_ANT_DOWN_TILT]
            if PAR_ANT_GAIN in instPar:
                gain = instPar[PAR_ANT_GAIN]
                if isinstance(gain, int) and gain >= -127 and gain <= 128:
                    self.instPar[PAR_ANT_GAIN] = instPar[PAR_ANT_GAIN]
                else:
                    self.log.warning('invalid value of %s : %s' % (PAR_ANT_GAIN, gain))
                    return [103, PAR_ANT_GAIN]
            if PAR_ANT_EIRP in instPar:
                eirp = instPar[PAR_ANT_EIRP]
                if isinstance(eirp, int) and eirp >= -127 and eirp <= 47:
                    self.instPar[PAR_ANT_EIRP] = instPar[PAR_ANT_EIRP]
                else:
                    self.log.warning('invalid value of %s : %s' % (PAR_ANT_EIRP, eirp))
                    return [103, PAR_ANT_EIRP]
            if PAR_ANT_BEAMW in instPar:
                beamw = instPar[PAR_ANT_BEAMW]
                if isinstance(beamw, int) and beamw >= 0 and beamw <= 360:
                    self.instPar[PAR_ANT_BEAMW] = instPar[PAR_ANT_BEAMW]
                else:
                    self.log.warning('invalid value of %s : %s' % (PAR_ANT_BEAMW, beamw))
                    return [103, PAR_ANT_BEAMW]
            elif self.category == 'B':
                self.log.warning('missing %s in registeration request for Category B CBSD' % PAR_ANT_BEAMW)
                return [102, PAR_ANT_BEAMW]
            if PAR_ANT_MODEL in instPar:
                if len(instPar[PAR_ANT_MODEL]) > 128:
                    self.log.warning('length of %s exceeded 128 characters' % PAR_ANT_MODEL)
                    return [103, PAR_ANT_MODEL]
                self.instPar[PAR_ANT_MODEL] = instPar[PAR_ANT_MODEL]
        if PAR_MEAS_CAP in reg_req:
            if isinstance(reg_req[PAR_MEAS_CAP], list):
                meas_caps = meas_cap_t
                if self.version >= SAS_VERSION_TS_11:
                    meas_caps = meas_cap_11_t
                for meas_cap_item in reg_req[PAR_MEAS_CAP]:
                    #  If the measCapability parameter contains only the empty string (""),
                    #  the SAS assumes that the CBSD is not capable of reporting any measurements
                    if meas_cap_item == "":
                        pass
                    elif meas_cap_item in meas_caps:
                        self.meas.append(meas_cap_item)
                    else:
                        self.log.warning('invalid value of %s : %s' % (PAR_MEAS_CAP, meas_cap_item))
                        return [103, PAR_MEAS_CAP]
        if PAR_GROUP_PAR in reg_req:
            group = reg_req[PAR_GROUP_PAR]
            if PAR_GROUP_TYPE in group:
                self.__group[PAR_GROUP_TYPE] = group[PAR_GROUP_TYPE]
            if PAR_GROUP_ID in group:
                self.__group[PAR_GROUP_ID] = group[PAR_GROUP_ID]
        # handle forced case
        if self.config.SAS_METHOD_FORCE == METHOD_REG:
            self.config.force_sas_method_sequences['DUMMY_GRANT'] += 1
            if self.config.RESPONSE_CODE_FORCE is not None and self.config.RESPONSE_CODE_FORCE != 0:
                if self.config.SAS_METHOD_FORCE_SEQUENCE is None \
                        or self.config.force_sas_method_sequences['DUMMY_GRANT'] == \
                        self.config.SAS_METHOD_FORCE_SEQUENCE:
                    self.log.info('force the value of resonseCode to be %d' % self.config.RESPONSE_CODE_FORCE)
                    return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]
        self.set_opState(STATE_REG)
        return [0, '']

    def reg_handler_cleanup(self):
        if (self.config.SAS_METHOD_FORCE == METHOD_REG and
                self.config.RESPONSE_CODE_FORCE == 0 and self.excludePar is True):
            if self.get_opState() == STATE_REG:
                self.set_opState(STATE_UNREG)
                self.log.info('change CBSD state to Unregistered due to config.RESPONSE_CODE_FORCE==0 '
                              '& config.EXCLUDE_PARAM_FORCE=True')

    def dereg_handler(self, msg, protocol):
        dereg_req = msg
        if self.get_opState() != STATE_REG:
            self.log.warning('invalid deregistration request because cbsd is not in registered state')
            return [502, '']

        if protocol != self.version:
            self.log.warning('invalid SAS-CBSD protocol version: %s' % protocol)
            return [100, self.version]

        # handle forced case
        if self.config.SAS_METHOD_FORCE == METHOD_DEREG:
            self.config.force_sas_method_sequences['DUMMY_GRANT'] += 1
            if self.config.RESPONSE_CODE_FORCE is not None and self.config.RESPONSE_CODE_FORCE != 0:
                if self.config.SAS_METHOD_FORCE_SEQUENCE is None or \
                        self.config.force_sas_method_sequences['DUMMY_GRANT'] == self.config.SAS_METHOD_FORCE_SEQUENCE:
                    self.log.info('force the value of resonseCode to be %d' % self.config.RESPONSE_CODE_FORCE)
                    return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]
            # For test purpose,do not change CBSD state if RESPONSE_CODE_FORCE==0 & EXCLUDE_PARAM_FORCE=<a valid value>
            # 'cbsdId'/'response'/'responseCode' are the valid parameters in deregistration response
            # check if EXCLUDE_PARAM_FORCE equal to these valid parameters instead of checking CBSD.__excludePar
            elif self.config.RESPONSE_CODE_FORCE == 0:
                if self.config.SAS_METHOD_FORCE_SEQUENCE is None or \
                        self.config.force_sas_method_sequences['DUMMY_GRANT'] == self.config.SAS_METHOD_FORCE_SEQUENCE:
                    if self.config.EXCLUDE_PARAM_FORCE == PAR_CBSD_ID:
                        self.log.info('do not perform deregistration due to config.RESPONSE_CODE_FORCE==0 & '
                                      'config.EXCLUDE_PARAM_FORCE=True')
                        return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]
                    elif self.config.EXCLUDE_PARAM_FORCE == PAR_ERROR or \
                            self.config.EXCLUDE_PARAM_FORCE == PAR_ERR_CODE:
                        self.log.info('do not perform deregistration due to config.RESPONSE_CODE_FORCE==0 & '
                                      'config.EXCLUDE_PARAM_FORCE=True')
                        return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]
        for grant_id in self.grantList:
            grant = self.grantList[grant_id]
            if grant.get_opState() != GRANT_STATE_IDLE:
                grant.stop()
        self.grantList.clear()
        self.set_opState(STATE_UNREG)
        return [0, '']

    def inquiry_handler(self, msg, protocol, channel_list):
        """
        This method parse spectrum inquiry request -- msg.
        channel_list is a dict which contains available channel data with follow form:
            channel_id, (low_frequency, high_frequency)
        This method returns a list. The first list item is 0 on success or none-zero on failure.
        The second item is a list which contains available channel data to match the inquiry spectrum
        on success or is a list which contains missing/invalid parameters on failure.
        The available channel data has the same form with channel_list.
        """
        if isinstance(msg, dict) is not True:
            # MISSING_PARAM
            self.log.warning('msg body is not dict type')
            return [102, []]

        if protocol != self.version:
            self.log.warning('invalid SAS-CBSD protocol version: %s' % protocol)
            return [100, self.version]

        inq_req = msg
        # Required Parameters
        if PAR_INQ_SPECT not in inq_req:
            self.log.warning('missing %s parameter in inquiry spectrum request' % PAR_INQ_SPECT)
            return [102, [PAR_INQ_SPECT]]

        ret_list = []
        inq_list = inq_req[PAR_INQ_SPECT]
        if not isinstance(inq_list, list):
            self.log.warning('the type of %s in inquiry spectrum request should be list' % PAR_INQ_SPECT)
            return [103, []]
        for inq in inq_list:
            if isinstance(inq, dict):
                if PAR_LOW_FREQ in inq and PAR_HIGH_FREQ in inq:
                    low = inq[PAR_LOW_FREQ]
                    high = inq[PAR_HIGH_FREQ]
                    self.log.info('inquiry frequency [%d - %d]' % (low, high))
                    matched = False
                    for ch_id in channel_list.keys():
                        if (channel_list[ch_id][0][0] <= low and channel_list[ch_id][0][0] <= high and
                                channel_list[ch_id][0][1] >= low and channel_list[ch_id][0][1] >= high):
                            ret_list.append((ch_id, channel_list[ch_id][0][0], channel_list[ch_id][0][1],
                                             channel_list[ch_id][1]))
                            self.log.info('matched channel %s [%d - %d]' %
                                          (ch_id, channel_list[ch_id][0][0], channel_list[ch_id][0][1]))
                            matched = True
                            break

                    if matched is not False:
                        # join individaul channel
                        join_list = {}
                        key_list = list(channel_list.keys())
                        key_list.sort()
                        for ch_id in key_list:
                            joined = False
                            for join_id in join_list.keys():
                                if join_list[join_id][0][1] == channel_list[ch_id][0][0]:
                                    join_list[join_id][0][1] = channel_list[ch_id][0][1]
                                    join_list[join_id][1] = False
                                    joined = True
                                    break
                                elif join_list[join_id][0][0] == channel_list[ch_id][0][1]:
                                    join_list[join_id][0][0] = channel_list[ch_id][0][0]
                                    join_list[join_id][1] = False
                                    joined = True
                                    break
                            if joined is not False:
                                join_list.setdefault(ch_id, [[channel_list[ch_id][0][0], channel_list[ch_id][0][1]],
                                                             channel_list[ch_id][1]])
                        for ch_id in join_list.keys():
                            if (join_list[ch_id][0][0] <= low and join_list[ch_id][0][0] <= high and
                                    join_list[ch_id][0][1] >= low and join_list[ch_id][0][1] >= high):
                                ret_list.append((ch_id, join_list[ch_id][0][0], join_list[ch_id][0][1],
                                                 join_list[ch_id][1]))
                                self.log.info('matched joined channel %s [%d - %d]' %
                                              (ch_id, join_list[ch_id][0][0], join_list[ch_id][0][1]))
                                matched = True
                                break

        if len(ret_list) > 0:
            # handle forced case
            if self.config.SAS_METHOD_FORCE == METHOD_INQUIRY:
                self.config.force_sas_method_sequences['DUMMY_GRANT'] += 1
                if self.config.RESPONSE_CODE_FORCE is not None and self.config.RESPONSE_CODE_FORCE != 0:
                    if self.config.SAS_METHOD_FORCE_SEQUENCE is None or \
                            self.config.force_sas_method_sequences['DUMMY_GRANT'] == \
                            self.config.SAS_METHOD_FORCE_SEQUENCE:
                        self.log.info('force the value of resonseCode to be %d' % self.config.RESPONSE_CODE_FORCE)
                        return [self.config.RESPONSE_CODE_FORCE, [self.config.RESPONSE_DATA_FORCE]]
            return [0, ret_list]
        else:
            return [300, []]

    def grant_handler(self, msg, protocol, channel_list, tlist, ppa_list):
        """
        This method parse spectrum grant request -- msg.
        channel_list is a dict which contains available channel data with follow form:
            channel_id, (low_frequency, high_frequency)
        This method returns a list. The first list item is 0 on success or none-zero on failure.
        The second item is grantId provided for approved grant or is error data on failure.
        """
        if isinstance(msg, dict) is not True:
            # MISSING_PARAM
            self.log.warning('msg body is not dict type')
            return [102, '']

        if protocol != self.version:
            self.log.warning('invalid SAS-CBSD protocol version: %s' % protocol)
            return [100, self.version]

        grant_req = msg
        # Required Parameters
        if PAR_OP_PAR not in grant_req:
            self.log.warning('missing parameter %s in grant request' % PAR_OP_PAR)
            return [102, PAR_OP_PAR]
        op_par = grant_req[PAR_OP_PAR]
        if PAR_MAX_EIRP not in op_par:
            self.log.warning('missing parameter of %s in grant request' % PAR_MAX_EIRP)
            return [102, PAR_MAX_EIRP]
        if PAR_OP_FREQ_RANG not in op_par:
            self.log.warning('missing parameter of %s in grant request' % PAR_OP_FREQ_RANG)
            return [102, PAR_OP_FREQ_RANG]
        fre_range = op_par[PAR_OP_FREQ_RANG]
        if PAR_LOW_FREQ not in fre_range:
            self.log.warning('missing parameter of %s in grant request' % PAR_LOW_FREQ)
            return [102, PAR_LOW_FREQ]
        if PAR_HIGH_FREQ not in fre_range:
            self.log.warning('missing parameter of %s in grant request' % PAR_HIGH_FREQ)
            return [102, PAR_HIGH_FREQ]

        lowFreq = fre_range[PAR_LOW_FREQ]
        highFreq = fre_range[PAR_HIGH_FREQ]
        grantID = str(lowFreq) + '_' + str(highFreq)
        if self.config.RESPONSE_CODE_FORCE == "400" and self.config.SAS_METHOD_FORCE_GRANTIDS.find(grantID) == 0:
            return [400, '']

        if self.get_opState() == STATE_UNREG:
            self.log.warning('invalid grant request because cbsd is not registered yet')
            return [502, '']

        eirp = op_par[PAR_MAX_EIRP]
        low = fre_range[PAR_LOW_FREQ]
        high = fre_range[PAR_HIGH_FREQ]
        self.log.info('requested grant [%d - %d]' % (low, high))
        grant = Grant(self.config, self.log)
        grant_id = grant.get_ID(low, high)
        if grant_id in self.grantList:
            grant = self.grantList[grant_id]
            if grant.get_opState() != GRANT_STATE_IDLE:
                # self.log.warning('conflict with an existing Grant of the same CBSD.')
                # return 400 -- INTERFERENCE for this case following Lan's comments
                self.log.warning('Requested operation parameters cause too much interference.')
                return [400, '']

        isPPA = False
        if self.cbsdID in ppa_list:
            isPPA = True
        grant_result = grant.grant(self.cbsdID, eirp, low, high, channel_list, tlist, isPPA)
        if grant_result[0] == 0:
            self.grantList.setdefault(grant_id, grant)
            return [0, grant.get_ID()]
        else:
            return [grant_result[0], grant_result[1]]

    def grant_handler_cleanup(self, grant_id):
        if (self.config.SAS_METHOD_FORCE == METHOD_GRANT and
                self.config.RESPONSE_CODE_FORCE == 0 and self.excludePar is True):
            if grant_id in self.grantList:
                grant = self.grantList[grant_id]
                if grant.get_opState() != GRANT_STATE_IDLE:
                    grant.stop()
                    self.grantList.pop(grant_id)
                    self.log.info('stoped grant due to config.RESPONSE_CODE_FORCE==0 & '
                                  'config.EXCLUDE_PARAM_FORCE=True')

    def get_grantID_from_req(self, req):
        if PAR_GRANT_ID not in req:
            return None
        grantID = req[PAR_GRANT_ID]
        if grantID not in self.grantList:
            return None
        return grantID

    def grant_timeout_handler(self, grant_id):
        self.log.info('cbsd %s received grant expire event' % self.cbsdID)
        if grant_id in self.grantList:
            return self.grantList[grant_id].grant_timeout_handler()
        else:
            self.log.warning('could not find grant %s for grant expire event' % grant_id)
            return -1

    def transmit_timeout_handler(self, grant_id, slist=None, tlist=None):
        self.log.info('cbsd %s received transmit expire event' % self.cbsdID)
        if grant_id in self.grantList:
            return self.grantList[grant_id].transmit_timeout_handler(tlist, slist)
        else:
            self.log.warning('could not find grant %s for transmit expire event' % grant_id)
            return -1

    def heartbeat_handler(self, msg,  protocol, blist=None, slist=None, tlist=None):
        if isinstance(msg, dict) is not True:
            # MISSING_PARAM
            self.log.warning('msg body is not dict type')
            return [102, '']

        if protocol != self.version:
            self.log.warning('invalid SAS-CBSD protocol version: %s' % protocol)
            return [100, self.version]

        hb_req = msg
        # Required Parameters
        if PAR_GRANT_ID not in hb_req:
            self.log.warning('missing %s parameter in heartbeat request' % PAR_GRANT_ID)
            return [102, PAR_GRANT_ID]

        if PAR_OP_STATE not in hb_req:
            self.log.warning('missing %s parameter in heartbeat request' % PAR_OP_STATE)
            return [102, PAR_OP_STATE]

        grantRenew = False
        if PAR_GRANT_RENEW in hb_req:
            if isinstance(hb_req[PAR_GRANT_RENEW], bool):
                if hb_req[PAR_GRANT_RENEW] is True:
                    grantRenew = True
                    self.log.debug('CBSD is asking for grant renewal')

        # blacklist check
        # move balcklist validation to grant.heartbeat
        # if blist is not None:
            # if hb_req[PAR_CBSD_ID] in blist:
                # self.set_opState(STATE_UNREG)
                # self.log.info('cbsd %s is blacklisted, change op state to %s'
                    # % (hb_req[PAR_CBSD_ID], STATE_UNREG))
                # return [101, '']

        grant_id = hb_req[PAR_GRANT_ID]
        if grant_id not in self.grantList:
            self.log.warning('invalid grantID %s in heartbeat request' % grant_id)
            return [103, PAR_GRANT_ID]

        grant = self.grantList[grant_id]
        result = grant.heartbeat(hb_req[PAR_OP_STATE], grantRenew, blist, tlist, slist)
        if result[0] == 101:
            # we should change op state to unknown if CBSD is blacklisted
            # but the update of op state will stop all related Grants and
            # it will make grantId invalid in response builder
            # so the op state will change after response is built completely
            pass
        return [result[0], result[1]]

    def heartbeat_handler_cleanup(self, grant_id):
        if (self.config.SAS_METHOD_FORCE == METHOD_HEARTBEAT and
                self.config.RESPONSE_CODE_FORCE == 0 and self.excludePar is True):
            if grant_id in self.grantList:
                grant = self.grantList[grant_id]
                if grant.get_opState() == GRANT_STATE_AUTHORIZED:
                    grant.set_opState(GRANT_STATE_GRANTED)
                    self.log.info('change grant state to granted due to config.RESPONSE_CODE_FORCE==0 '
                                  '& config.EXCLUDE_PARAM_FORCE=True')

    def heartbeat_timeout_handler(self, grant_id):
        self.log.info('cbsd %s received hearbeat expire event' % self.cbsdID)
        if grant_id in self.grantList:
            return self.grantList[grant_id].heartbeat_timeout_handler()
        else:
            self.log.warning('could not find grant %s for heartbeat expire event' % grant_id)
            return -1

    def relinquish_handler(self, msg, protocol):
        if isinstance(msg, dict) is not True:
            # MISSING_PARAM
            self.log.warning('msg body is not dict type')
            return [102, '']
        if protocol != self.version:
            self.log.warning('invalid SAS-CBSD protocol version: %s' % protocol)
            return [100, self.version]
        rlq_req = msg
        # Required Parameters
        if PAR_GRANT_ID not in rlq_req:
            self.log.warning('missing %s parameter in relinquishment request' % PAR_GRANT_ID)
            return [102, PAR_GRANT_ID]
        grant_id = rlq_req[PAR_GRANT_ID]
        if grant_id not in self.grantList:
            self.log.warning('invalid grantID %s in relinquishment request' % grant_id)
            return [103, PAR_GRANT_ID]
        grant = self.grantList[grant_id]
        result = grant.relinquish()
        return [result[0], result[1]]

    def mng_cbsd_handler(self, msg):
        if isinstance(msg, dict) is not True:
            # MISSING_PARAM
            self.log.warning('msg body is not dict type')
            return [102, '']
        if REQ_MNG_CBSD not in msg:
            self.log.warning('%s is not included in msg body' % REQ_MNG_CBSD)
            return [102, '']
        data = {}
        data[PAR_CBSD_ID] = self.cbsdID
        data[PAR_USER_ID] = self.userID
        data[PAR_FCC_ID] = self.fccID
        data[PAR_CBSD_SN] = self.serialNum
        data[PAR_OP_STATE] = self.opState
        if self.callSign is not None:
            data[PAR_CALL_SIGN] = self.callSign
        if self.category is not None:
            data[PAR_CBSD_CAT] = self.category
        if len(self.airIf) > 0:
            data[PAR_AIR_IF] = self.airIf
        if len(self.instPar) > 0:
            data[PAR_INSTALL_PAR] = self.instPar
        if len(self.cbsdInfo) > 0:
            data[PAR_CBSD_INFO] = self.cbsdInfo
        if len(self.groupPar) > 0:
            data[PAR_GROUP_PAR] = self.groupPar
        if len(self.meas) > 0:
            data[PAR_MEAS_CAP] = self.meas
        grantList = []
        for grantId in self.grantList:
            grant = self.grantList[grantId]
            grantItem = {}
            grantItem[PAR_OP_STATE] = grant.get_opState()
            if grant.get_ID() is not None:
                grantItem[PAR_GRANT_ID] = grant.get_ID()
            if grant.get_maxEirp() is not None:
                grantItem[PAR_MAX_EIRP] = grant.get_maxEirp()
            if grant.get_lowFreq() is not None:
                grantItem[PAR_LOW_FREQ] = grant.get_lowFreq()
            if grant.get_lowFreq() is not None:
                grantItem[PAR_HIGH_FREQ] = grant.get_highFreq()
            if grant.isPALGrant() is True:
                grantItem[PAR_CHN_TYPE] = CHN_TYPE_PAL
            else:
                grantItem[PAR_CHN_TYPE] = CHN_TYPE_GAA
            if grant.get_grantExp() is not None:
                grantItem[PAR_GRANT_EXP] = grant.get_grantExp().strftime("%Y-%m-%dT%H:%M:%SZ")
            if grant.get_transmitExp() is not None:
                grantItem[PAR_TRANS_EXP] = grant.get_transmitExp().strftime("%Y-%m-%dT%H:%M:%SZ")
            grantList.append(grantItem)
        data[PAR_GRANTS] = grantList
        return [0, data]

    def update_param_in_response(self, res_type, res_msg):
        if (self.config.SAS_METHOD_FORCE in sas_method_2_res_t and
                sas_method_2_res_t[self.config.SAS_METHOD_FORCE] == res_type):
            if self.config.EXCLUDE_PARAM_FORCE is not None:
                if (dict_pop(res_msg, self.config.EXCLUDE_PARAM_FORCE)):
                    self.excludePar = True
                    self.log.info('force to remove parameter %s from %s' % (self.config.EXCLUDE_PARAM_FORCE, res_type))
            if self.config.UPDATE_PARAM_FORCE is not None and self.config.UPDATE_PARAM_DATA_FORCE is not None:
                try:
                    pdata = json.loads(self.config.UPDATE_PARAM_DATA_FORCE, strict=False)
                    if (dict_update(res_msg, self.config.UPDATE_PARAM_FORCE, pdata)):
                        self.log.info('force to update parameter of %s with %s in %s' %
                                      (self.config.UPDATE_PARAM_FORCE, pdata, res_type))
                except TypeError:
                    self.log.warning('type error: invalid syntax of config.UPDATE_PARAM_DATA_FORCE')
                except ValueError:
                    self.log.warning('value error: invalid syntax of config.UPDATE_PARAM_DATA_FORCE')

    def response_builder(self, res_type=RES_HEARTBEAT, error=0, *args, **kw):
        res = {}

        if res_type not in sas_res_t:
            self.log.warning('response type %s is not supported' % res_type)
            return res

        if error not in error_code_table:
            self.log.warning('error code %d is not supported' % error)
            return res

        if res_type == RES_REG:
            if error == 0:
                # including cbsdId only if the responseCode indicates success
                res[PAR_CBSD_ID] = self.cbsdID
                if len(self.meas) > 0:
                    res[PAR_MEAS_REP] = self.meas
            if error == 100 or error == 102 or error == 103 or error == 200:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error], PAR_ERR_DATA: args}
            else:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
        elif res_type == RES_DEREG:
            if error == 0:
                res[PAR_CBSD_ID] = self.cbsdID
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
            if error == 100 or error == 102 or error == 103:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error], PAR_ERR_DATA: args}
            else:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
        elif res_type == RES_INQUIRY:
            if error == 0:
                res[PAR_CBSD_ID] = self.cbsdID
                maxEirp = self.config.MAX_EIRP_FORCE
                sequence = self.config.SAS_METHOD_FORCE_SEQUENCE
                if maxEirp is not None:
                    if sequence is not None:
                        self.config.force_sas_method_sequences['DUMMY_INQUIRY'] += 1
                        self.log.info('Will set maxEirp %d in spectrumInquiryResponse at sequence %d' %
                                      (maxEirp, sequence))
                    else:
                        self.log.info('Will set maxEirp %d in spectrumInquiryResponse always' % maxEirp)
                else:
                    self.log.info('Will not set maxEirp in spectrumInquiryResponse')
                ch_list = []
                for ch_item in args:
                    ch = {}
                    fre = {}
                    fre[PAR_LOW_FREQ] = ch_item[1]
                    fre[PAR_HIGH_FREQ] = ch_item[2]
                    ch[PAR_FREQ_RANG] = fre
                    if ch_item[3] is True:
                        ch[PAR_CHN_TYPE] = CHN_TYPE_PAL
                    else:
                        ch[PAR_CHN_TYPE] = CHN_TYPE_GAA
                    ch[PAR_RULE_APPL] = 'FCC Part 96'
                    spectrum_key = int(fre[PAR_LOW_FREQ])/1000000
                    spectrum_table_key = str(spectrum_key) + '-10'
                    if maxEirp is not None:
                        if sequence is None or self.config.force_sas_method_sequences['DUMMY_INQUIRY'] == sequence:
                            ch[PAR_MAX_EIRP] = maxEirp
                    elif len(self.config.force_max_eirp_group) != 0:
                        grantID = str(fre[PAR_LOW_FREQ]) + '_' + str(fre[PAR_HIGH_FREQ])
                        if (grantID in self.config.force_max_eirp_group_sequences):
                            self.config.force_max_eirp_group_sequences[grantID] += 1
                        else:
                            self.config.force_max_eirp_group_sequences[grantID] = 0
                        for force_max_eirp in self.config.force_max_eirp_group:
                            force_max_eirp_keys = force_max_eirp.split(',')
                            if force_max_eirp_keys[0] == grantID:
                                self.log.info('find the grantid')
                                self.log.info('grant id is %s' % force_max_eirp_keys[0])
                                self.log.info('sequence is %s' % force_max_eirp_keys[1])
                                sequence = int(force_max_eirp_keys[1])
                                self.log.info('sequence is %d' % sequence)
                                if (self.config.force_max_eirp_group_sequences[grantID] == sequence):
                                    self.log.info('find the sequence')
                                    self.log.info('force the value of maxEirp to be %s' % force_max_eirp_keys[2])
                                    ch[PAR_MAX_EIRP] = int(force_max_eirp_keys[2])
                    else:
                        if(len(self.config.spectrum_table[spectrum_table_key]) > 3) and (
                                self.config.spectrum_table[spectrum_table_key][3] != ''):
                            ch[PAR_MAX_EIRP] = self.config.spectrum_table[spectrum_table_key][3]
                    if ch[PAR_CHN_TYPE] == CHN_TYPE_GAA or (
                            ch[PAR_CHN_TYPE] == CHN_TYPE_PAL and
                            (self.config.spectrum_table[spectrum_table_key][2] == self.cbsdID or
                             self.config.spectrum_table[spectrum_table_key][2] == 'DUMMYCBSD')):
                        ch_list.append(ch)
                res[PAR_AVAIL_CHN] = ch_list
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
            else:
                # if len(args) > 0:
                if error == 100 or error == 102 or error == 103:
                    res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error], PAR_ERR_DATA: args}
                else:
                    res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
        elif res_type == RES_GRANT:
            if self.cbsdID is not None and self.cbsdID != '':
                res[PAR_CBSD_ID] = self.cbsdID
            if error == 0:
                res[PAR_GRANT_ID] = args[0]
                if len(self.meas) > 0:
                    res[PAR_MEAS_REP] = self.meas
                if args[0] in self.grantList:
                    grant = self.grantList[args[0]]
                    res[PAR_GRANT_EXP] = grant.get_grantExp().strftime("%Y-%m-%dT%H:%M:%SZ")
                res[PAR_HB_DUR] = self.config.HEART_BEAT_DUR
                spectrum_key = int(grant.get_lowFreq())/1000000
                spectrum_table_key = str(spectrum_key) + '-10'
                if (grant.isPALGrant() is True and
                    self.config.spectrum_table[spectrum_table_key][2] == 'DUMMYCBSD') or \
                        self.config.spectrum_table[spectrum_table_key][2] == self.cbsdID:
                    res[PAR_CHN_TYPE] = CHN_TYPE_PAL
                else:
                    res[PAR_CHN_TYPE] = CHN_TYPE_GAA
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
            else:
                if error == 100 or error == 102 or error == 103 or error == 401:
                    res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error], PAR_ERR_DATA: args}
                elif error == 400 and self.config.GRANT_DISAPPROVE_REASSIGN is True:
                    if len(self.config.operationParamsForGrant) != 0:
                        operationParam = self.config.operationParamsForGrant.pop(0)
                        operationParamForGrant_keys = operationParam.split(',')
                        freRange = {}
                        freRange[PAR_LOW_FREQ] = int(operationParamForGrant_keys[1])
                        freRange[PAR_HIGH_FREQ] = int(operationParamForGrant_keys[2])
                        opPar = {}
                        opPar[PAR_MAX_EIRP] = int(operationParamForGrant_keys[0])
                        opPar[PAR_OP_FREQ_RANG] = freRange
                        res[PAR_OP_PAR] = opPar
                        res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
                    else:
                        freRange = {}
                        freRange[PAR_LOW_FREQ] = self.config.FREQ_LOW_REASSIGN
                        freRange[PAR_HIGH_FREQ] = self.config.FREQ_HIGH_REASSIGN
                        opPar = {}
                        opPar[PAR_MAX_EIRP] = self.config.MAX_EIRP_REASSIGN
                        opPar[PAR_OP_FREQ_RANG] = freRange
                        res[PAR_OP_PAR] = opPar
                        res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
                else:
                    res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
        elif res_type == RES_HEARTBEAT:
            if self.cbsdID is not None and self.cbsdID != '':
                res[PAR_CBSD_ID] = self.cbsdID
            if 'grantID' in kw:
                if kw['grantID'] is not None:
                    res[PAR_GRANT_ID] = kw['grantID']
                    if kw['grantID'] in self.grantList:
                        grant = self.grantList[kw['grantID']]
                        # transmitExpireTime is required parameter
                        transmitExp = grant.get_transmitExp_ex()
                        if transmitExp is not None:
                            res[PAR_TRANS_EXP] = transmitExp.strftime("%Y-%m-%dT%H:%M:%SZ")
            # use a past time as grantExpireTime if we could not get a valid value
            if PAR_TRANS_EXP not in res:
                exp = datetime.datetime(1970, 1, 1)
                res[PAR_TRANS_EXP] = exp.strftime("%Y-%m-%dT%H:%M:%SZ")
            if error == 0:
                if len(self.meas) > 0:
                    res[PAR_MEAS_REP] = self.meas
                grant = self.grantList[kw['grantID']]
                # res[PAR_TRANS_EXP] = grant.get_transmitExp().strftime("%Y-%m-%dT%H:%M:%SZ")
                # grantExpireTime is required if the responseCode parameter indicates SUCCESS or SUSPENDED_GRANT
                # and the grantRenew parameter was included and set to True in the corresponding HeartbeatRequest
                # object. This parameter may be included at other times by SAS choice.
                # As per EI requirement, this parameter is included regardless grantRenew is present or not
                # if grant.grantRenew() is True:
                # grantExpireTime may be included if grant is suspened
                # Here we just include grantExpireTime if the request is approved
                # res[PAR_GRANT_EXP] = grant.get_grantExp().strftime("%Y-%m-%dT%H:%M:%SZ")
                res[PAR_GRANT_EXP] = grant.get_grantExp().strftime("%Y-%m-%dT%H:%M:%SZ")
            if ((error == 500 and self.config.TERMINATED_REASSIGN is True) or
                    (error == 501 and self.config.SUSPENDED_REASSIGN is True)):
                # add new operational parameters
                if len(self.config.operationParamsForHeartbeat) != 0:
                    operationParam = self.config.operationParamsForHeartbeat.pop(0)
                    operationParamsForHeartbeat_keys = operationParam.split(',')
                    opPar = {}
                    freRange = {}
                    if (operationParamsForHeartbeat_keys[0] is not None and
                            operationParamsForHeartbeat_keys[0] != '' and
                            operationParamsForHeartbeat_keys[1] is not None and
                            operationParamsForHeartbeat_keys[1] != '' and
                            operationParamsForHeartbeat_keys[2] is not None and
                            operationParamsForHeartbeat_keys[2] != ''):
                        freRange[PAR_LOW_FREQ] = int(operationParamsForHeartbeat_keys[1])
                        freRange[PAR_HIGH_FREQ] = int(operationParamsForHeartbeat_keys[2])
                        opPar[PAR_MAX_EIRP] = int(operationParamsForHeartbeat_keys[0])
                        opPar[PAR_OP_FREQ_RANG] = freRange
                        res[PAR_OP_PAR] = opPar
                else:
                    opPar = {}
                    freRange = {}
                    freRange[PAR_LOW_FREQ] = self.config.FREQ_LOW_REASSIGN
                    freRange[PAR_HIGH_FREQ] = self.config.FREQ_HIGH_REASSIGN
                    opPar[PAR_MAX_EIRP] = self.config.MAX_EIRP_REASSIGN
                    opPar[PAR_OP_FREQ_RANG] = freRange
                    res[PAR_OP_PAR] = opPar
            if error == 100 or error == 102 or error == 103:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error], PAR_ERR_DATA: args}
            else:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
        elif res_type == RES_RELINQUISH:
            res[PAR_CBSD_ID] = self.cbsdID
            if 'grantID' in kw:
                if kw['grantID'] is not None:
                    res[PAR_GRANT_ID] = kw['grantID']
            if error == 100 or error == 102 or error == 103:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error], PAR_ERR_DATA: args}
            else:
                res[PAR_ERROR] = {PAR_ERR_CODE: error, PAR_ERR_MSG: error_code_table[error]}
        else:
            # TBD
            self.log.warning('the response type %s is not supported yet' % res_type)
        self.update_param_in_response(res_type, res)
        return res

    def get_state(self):
        return self.opState

    def get_cbsdID(self, msg=None, msg_type=REQ_REG):
        if msg is not None:
            if REQ_REG == msg_type:
                reg_req = msg
                if ((PAR_USER_ID in reg_req) and
                   (PAR_FCC_ID in reg_req) and
                   (PAR_CBSD_SN in reg_req)):
                    return reg_req[PAR_USER_ID] + '_' + reg_req[PAR_FCC_ID] + '_' + reg_req[PAR_CBSD_SN]
            if REQ_INQUIRY == msg_type:
                inquiry_req = msg
                if PAR_CBSD_ID in inquiry_req:
                    return inquiry_req[PAR_CBSD_ID]
            if REQ_GRANT == msg_type:
                grant_req = msg
                if PAR_CBSD_ID in grant_req:
                    return grant_req[PAR_CBSD_ID]
            if REQ_HEARTBEAT == msg_type:
                hb_req = msg
                if PAR_CBSD_ID in hb_req:
                    return hb_req[PAR_CBSD_ID]
            if REQ_RELINQUISH == msg_type:
                relq_req = msg
                if PAR_CBSD_ID in relq_req:
                    return relq_req[PAR_CBSD_ID]
            if REQ_DEREG == msg_type:
                dereg_req = msg
                if PAR_CBSD_ID in dereg_req:
                    return dereg_req[PAR_CBSD_ID]
        return self.cbsdID

    def get_excludePar(self):
        return self.excludePar

    def set_blocked_request_sequence(self, grantID):
        if grantID not in self.grantBlockedRequestSequenceList:
            self.grantBlockedRequestSequenceList[grantID] = 0
        self.grantBlockedRequestSequenceList[grantID] += 1

    def get_blocked_request_sequence(self, grantID):
        return self.grantBlockedRequestSequenceList[grantID]

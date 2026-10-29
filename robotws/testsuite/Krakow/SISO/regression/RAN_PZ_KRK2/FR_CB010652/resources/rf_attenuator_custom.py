"""
:copyright: Nokia Networks
:author: Grzegorz Kaczor
"""

import re
import logging
from taf.hw.rf_attenuator import rf_attenuator as attenuator
from taf.hw.rf_attenuator.devices.topyoung.topyoung import TopYoung
from taf.hw.rf_attenuator.facade import AttenuatorFacade
from taf.hw.rf_attenuator.attenuator_factory import AttenuatorFactory
from taf.hw.rf_attenuator.available_devices import SupportedAttenuatorVendors, AttenuatorTypes


class AttenuatorHandlerCustom(attenuator):

    def __init__(self):
        super(AttenuatorHandlerCustom, self).__init__()


class AttenuatorFactoryCustom(AttenuatorFactory):

    def __init__(self):
        super(AttenuatorFactoryCustom, self).__init__()

    @staticmethod
    def _create(vendor, ip, port, model=None, version=None, min_attenuation=None, max_attenuation=None, **kwargs):
        vendors = SupportedAttenuatorVendors()
        vendors._attenuators['TOPYOUNG_TAS_18B18BNG_CDNSWT_01_01_01'] = AttenuatorTypes(
            TopYoungTAS18B18BNGCDNSWT010101)
        vendors._TOPYOUNG["TAS_18B18BNG_CDNSWT_01_01_01"] = vendors._attenuators[
            'TOPYOUNG_TAS_18B18BNG_CDNSWT_01_01_01']
        attenuator_device = vendors[vendor][model][version]
        return attenuator_device(ip=ip, port=port, min_attenuation=min_attenuation,
                                 max_attenuation=max_attenuation, **kwargs)


class AttenuatorFacadeCustom(AttenuatorFacade):

    def __init__(self):
        super(AttenuatorFacadeCustom, self).__init__()

    @staticmethod
    def setup_attenuator(attenuator=None, **kwargs):
        device = AttenuatorFactoryCustom.create(attenuator=attenuator, **kwargs)
        return device


class TopYoungTAS18B18BNGCDNSWT010101(TopYoung):
    MAX_SUPPORTED_ATTENUATION = 93
    MIN_SUPPORTED_ATTENUATION = 0
    _SET_CMD = 'set:{}:{}'
    _SET_RES_OK = r'set ok'
    _SET_RES_FAIL = r'set:\d+:fail'
    _READ_CMD = 'read:{}'
    _READ_RES_OK = r'read id {} value (\d+)'
    _READ_RES_FAIL = r'read:\d+:fail'

    def _verify_set_attenuation_command_response(self, rf_port_address, res):
        if re.search(self._SET_RES_OK, res):
            return
        self._check_if_set_command_failed(self._SET_RES_FAIL, res)
        self._check_if_command_error(self._CMD_ERR, res)

    def _verify_read_attenuation_command_response(self, rf_port_address, res):
        self._check_if_read_command_failed(self._READ_RES_FAIL, res)
        self._check_if_command_error(self._CMD_ERR, res)
        re_out = re.search(self._READ_RES_OK.format(rf_port_address), res)
        if re_out:
            value_read = re_out.groups()[0]
            logging.info('Channel {} attenuation value is {} dB.'.format(rf_port_address, value_read))
            return int(value_read)
        raise AttenuationReadError


class AttenuationReadError(Exception):
    pass

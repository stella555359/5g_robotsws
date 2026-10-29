# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
"""


__all__ = ['generate_srs_modify_params']


class BaseSRSChange(object):
    chbw = ''

    bSRS = ''
    cSRS = ''

    @classmethod
    def generate_csrs_bsrs(cls, dist_name, list_name):
        params = []
        params.append(dict(dist_name=dist_name, list_name=list_name, parameter='bSRS', value=cls.bSRS))
        params.append(dict(dist_name=dist_name, list_name=list_name, parameter='cSRS', value=cls.cSRS))
        return params


class BaseSRSChange20(BaseSRSChange):
    chbw = '20'

    cSRS = '12'
    bSRS = '2'


class BaseSRSChange30(BaseSRSChange):
    chbw = '30'

    cSRS = '12'
    bSRS = '2'


class BaseSRSChange40(BaseSRSChange):
    chbw = '40'

    cSRS = '12'
    bSRS = '2'


class BaseSRSChange50(BaseSRSChange):
    chbw = '50'

    cSRS = '32'
    bSRS = '2'


class BaseSRSChange60(BaseSRSChange):
    chbw = '60'

    cSRS = '38'
    bSRS = '2'


class BaseSRSChange70(BaseSRSChange):
    chbw = '70'

    cSRS = '38'
    bSRS = '2'


class BaseSRSChange80(BaseSRSChange):
    chbw = '80'

    cSRS = '49'
    bSRS = '2'


class BaseSRSChange90(BaseSRSChange):
    chbw = '90'

    cSRS = '55'
    bSRS = '3'


class BaseSRSChange100(BaseSRSChange):
    chbw = '100'

    cSRS = '63'
    bSRS = '2'


class GenerateModifyParams(object):

    _SUPPORTED_SRS = [BaseSRSChange20, BaseSRSChange30, BaseSRSChange40, BaseSRSChange50, BaseSRSChange60,
                      BaseSRSChange70, BaseSRSChange80, BaseSRSChange90, BaseSRSChange100]

    def __init__(self, cell_band, dist_name):
        self.cell_band = cell_band
        self.dist_name = dist_name
        self.list_name = 'srsForBeamMgmt'

    def generate_params(self):
        modify_params = self._select_srs_change_class(cell_band=self.cell_band).generate_csrs_bsrs(
            dist_name=self.dist_name, list_name=self.list_name)
        return modify_params

    def _select_srs_change_class(self, cell_band):
        for supported_cell_srs in self._SUPPORTED_SRS:
            if supported_cell_srs.chbw == cell_band:
                return supported_cell_srs
        raise Exception('get SRSChange Value failed')


def generate_srs_modify_params(cell_band, dist_name, release='master'):
    modify_srs_release = ['SBTS22R2']
    modify_params = []
    if release not in modify_srs_release:
        get_params = GenerateModifyParams(cell_band=cell_band, dist_name=dist_name)
        modify_params = modify_params + get_params.generate_params()
    return modify_params

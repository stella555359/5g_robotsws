# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: stella.lin@nokia-sbell.com
"""
#

EXPECT_DL_TPUT_TABLE = {
    '100': '1441',
    '80': '1127',
    '60': '843',
    '40': '534',
    '20': '247',
    'not_peak': '700'}

EXPECT_UL_TPUT_TABLE = {
    '100': '10',
    '80': '10',
    '60': '10',
    '40': '10',
    '20': '10',
    'not_peak': '10'}

SCELL_ARFCN_TABLE = {
    '100_80': '527838',
    '100_60': '525996',
    '100_40': '523878',
    '100_20': '521988',
    '80_40': '521994',
    '80_80': '525996',
    '60_60': '522000'}


class TputInfoGeneration(object):
    def __init__(self):
        self._pcell_index = 0
        self._scell_index = 1
        self._pcell_chbw = '100Mhz'
        self._scell_chbw = '80Mhz'

    def set_pcell_index(self, value):
        self._pcell_index = value

    def set_scell_index(self, value):
        self._scell_index = value

    def set_pcell_chbw(self, value):
        self._pcell_chbw = value

    def set_scell_chbw(self, value):
        self._scell_chbw = value

    def get_tput_data_for_CA_call(self):
        return {'CA_WITHOUT_PEAK': {
                'UL': {
                    'cell_index': self._pcell_index,
                    'expect_UL_tput': EXPECT_UL_TPUT_TABLE['not_peak'],
                    'expect_UL_bler': '0.3'},
                'DL_PCELL': {
                    'cell_index': self._pcell_index,
                    'expect_DL_tput': EXPECT_DL_TPUT_TABLE['not_peak'],
                    'expect_DL_bler': '0.1'},
                'DL_SCELL_1': {
                    'cell_index': self._scell_index,
                    'expect_DL_tput': EXPECT_DL_TPUT_TABLE['not_peak'],
                    'expect_DL_bler': '0.1'}},
                self._pcell_chbw + '_' + self._scell_chbw: {
                'UL': {
                    'cell_index': self._pcell_index,
                    'expect_UL_tput': EXPECT_UL_TPUT_TABLE[self._pcell_chbw],
                    'expect_UL_bler': '0.3'},
                'DL_PCELL': {
                    'cell_index': self._pcell_index,
                    'expect_DL_tput': EXPECT_DL_TPUT_TABLE[self._pcell_chbw],
                    'expect_DL_bler': '0.2'},
                'DL_SCELL_1': {
                    'cell_index': self._scell_index,
                    'expect_DL_tput': EXPECT_DL_TPUT_TABLE[self._scell_chbw],
                    'expect_DL_bler': '0.2'}}
                }

    def get_tput_data_for_None_CA_call(self):
        return {'UL': {
            'cell_index': self._pcell_index,
            'expect_UL_tput': EXPECT_UL_TPUT_TABLE[self._pcell_chbw],
            'expect_UL_bler': '0.1'},
            'DL': {
            'cell_index': self._pcell_index,
            'expect_DL_tput': EXPECT_DL_TPUT_TABLE[self._pcell_chbw],
            'expect_DL_bler': '0.1'}}

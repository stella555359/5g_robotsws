# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
"""
import os
import re
from AbfSet import AbfSet


def _get_panel_count(beamSet_name):
    pattern = re.compile(r'beamSetFR2(.*)_(?P<count>\d)P_N(.*)')
    matched = pattern.match(beamSet_name)
    if matched:
        return int(matched.groupdict()['count'])
    else:
        raise AbfSet.BeamSetNameDefinition


def _search_files(folder_path, string_to_search):
    files_found = []
    for fn in os.listdir(folder_path):
        if string_to_search in fn:
            files_found.append(fn)
    return files_found


class BeamSetLib:
    """
    beam set class definition
    """
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    __version__ = '1.0.0'

    def __init__(self):
        pass

    def load_beamSet(self, beamSet, beams_csv_path=None, beam='Beam',
                     elevation='Elevation Angle',
                     azimuth='Azimuth Angle',
                     beamId='Internal Beam Id', rBeamId='Radiated Beam ID'):
        self.beamSet_name = beamSet
        count = _get_panel_count(beamSet)
        if beams_csv_path is None:
            beams_csv_path = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                          'BeamSets')
        files_list = _search_files(beams_csv_path, beamSet)

        if files_list.__len__() != count:
            raise AbfSet.BeamSetDataDefinition

        self.panels = [None] * count

        for fn in files_list:
            ind = 0
            if count == 1:
                ind = 1
            elif 'AWEUA_beamSet' in fn:
                ind = 1
            elif "FA3UA_beamSet" in fn:
                ind = 2
            elif "FA3UA_#2" in fn:
                ind = 3
            if bool(ind):
                csv_file = os.path.join(beams_csv_path, fn)
                self.panels[ind - 1] = AbfSet(
                    csv_file, beam=beam, elevation=elevation,
                    azimuth=azimuth, beamId=beamId, rBeamId=rBeamId
                )
            else:
                raise AbfSet.BeamSetDataDefinition

    def get_panels_count(self):
        return self.panels.__len__()

    def get_rows_count(self, panel_num=0):
        return self.panels[panel_num].get_rows_count()

    def get_beams_rows(self, panel_num=0, row_num=None):
        return self.panels[panel_num].get_beams_rows(rowNum=row_num)

    def get_left_edge_beam(self, panel_num=0, row_num=None):
        return self.panels[panel_num].get_left_edge_azimuth(rowNum=row_num)

    def get_right_edge_beam(self, panel_num=0, row_num=None):
        return self.panels[panel_num].get_right_edge_azimuth(rowNum=row_num)

    def get_left_edge_position(self, panel_num=0, row_num=None):
        beam = self.panels[panel_num].get_left_edge_azimuth(rowNum=row_num)
        return beam.values()[0]

    def get_right_edge_position(self, panel_num=0, row_num=None):
        beam = self.panels[panel_num].get_right_edge_azimuth(rowNum=row_num)
        return beam.values()[0]

    def get_beam_position(self, panel_num=0, row_num=None):
        return self.panels[panel_num].get_beam_position(rowNum=row_num)

    def get_beam_position(self, panel_num=0, azimuth_offset=0.0, elevation_offset=0.0):
        return self.panels[panel_num].set_panels_position_offset(azimuth_offset, elevation_offset)

    def get_panels_position_offset(self, panel_num=0):
        return self.panels[panel_num].get_panels_position_offset()

    def get_beams_rows_position(self, panel_num=0, row_num=None):
        return self.panels[panel_num].get_beams_rows_position(row_num)

    def get_list_of_beams(self, panel_num=0, row_num=None):
        return self.panels[panel_num].get_list_of_beams(row_num)

    def get_list_of_ssbidx(self, panel_num=0, row_num=None):
        beams_list = self.panels[panel_num].get_list_of_beams(row_num)
        ssbidx = [x-1 for x in beams_list]
        return ssbidx

    def get_list_of_radiating_beams(self, panel_num=0, row_num=None):
        return self.panels[panel_num].get_list_of_radiating_beams(row_num)

    def get_internal_beams_id(self, beam_idx, panel_num=0):
        beam_idx = map(int, [beam_idx])[0]
        beam_idx = self.panels[panel_num].get_internal_beams_id(beam_idx)
        return beam_idx

    def get_radiating_beams_id(self, beam_idx, panel_num=0):
        beam_idx = map(int, [beam_idx])[0]
        return self.panels[panel_num].get_radiating_beams_id(beam_idx)

    def get_internal_beam_vs_radiating_beam(self, rbeam, panel_num=0):
        rbeam = map(int, [rbeam])[0]
        return self.panels[panel_num].get_internal_beam_vs_radiating_beam(rbeam)

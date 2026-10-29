##!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)

        Python function library to handle ABF basics operations.

"""

import csv
from collections import OrderedDict
import operator
import os
import re


def _load_csv(csv_file, delimiter=','):
    """

    :param csv_file: file path
    :return: a csv DictReader
    """
    rows = []
    with open(csv_file) as fh:
        rd = csv.DictReader(fh, delimiter=delimiter)
        for row in rd:
            rows.append(row)
    return rows


def _get_beams_rows(csv_dict,
                    beam='Beam',
                    elevation='Elevation Angle',
                    azimuth='Azimuth Angle'):
    rows = {}
    for row in csv_dict:
        elv = float(row[elevation])
        if elv not in rows.keys():
            rows.update({elv: {}})
        rows[elv].update({int(row[beam]): float(row[azimuth])})

    # Order By Elevation
    keys = sorted(rows.keys())

    # Order By Azimuth
    beams_rows = OrderedDict()
    for key in keys:
        beams_rows[key] = OrderedDict(sorted(rows[key].items(), key=operator.itemgetter(1), reverse=False))
    # return ordered dictionary
    return beams_rows


def _get_internal_beams_id(csv_dict, beam='Beam', beamId='Internal Beam Id'):
    beamIds = OrderedDict()
    for row in csv_dict:
        beamIds.update({int(row[beam]): int(row[beamId])})
    return beamIds


def _get_radiating_beams_id(csv_dict, beam='Beam', rBeamId='Radiated Beam ID'):
    beamIds = OrderedDict()
    for row in csv_dict:
        beamIds.update({int(row[beam]): int(row[rBeamId])})
    return beamIds


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


class AbfSet:
    """
    Abf function library
    """

    # define user defined exceptions
    class Error(Exception):
        """class for user defined exceptions"""
        pass

    class Empty(Error):
        """Raised when the csv rows is empty"""
        pass

    class RowNumErr(Error):
        """Raised when not 1 <=rowNum <= len(beams_rows.keys())"""
        pass

    class BeamNotDefined(Error):
        """Raised when the beam is not defined"""
        pass

    class BeamSetNameDefinition(Error):
        """Raised when we get beamSet name definition Error"""
        pass

    class BeamSetDataDefinition(Error):
        """Raised when missing of csv beamSet definition"""
        pass

    class Abf:
        """
          Abf basic function library
        """

        def __init__(self, csv_file, beam='Beam', elevation='Elevation Angle', azimuth='Azimuth Angle',
                     beamId='Internal Beam Id', rBeamId='Radiated Beam ID'):

            self.csv_file = []
            self.csv_rows = _load_csv(csv_file)
            if not self.csv_rows:
                raise AbfSet.Empty
            self.__beams_rows = _get_beams_rows(self.csv_rows, beam=beam, elevation=elevation, azimuth=azimuth)
            self.__beamIds = _get_internal_beams_id(self.csv_rows, beam=beam, beamId=beamId)
            self.__rBeamIds = _get_radiating_beams_id(self.csv_rows, beam=beam, rBeamId=rBeamId)
            self._azimuth_offset = 0.0
            self._elevation_offset = 0.0
            # clean variable
            self.csv_rows = ""

        def get_rows_count(self):
            """

            :return:
            """
            return len(self.__beams_rows.keys())

        def get_beams_rows(self, rowNum=None):
            """

            :param rowNum:
            :return:
            """
            # return ordered dictionary
            keys = self.__beams_rows.keys()
            if not bool(rowNum):
                return self.__beams_rows
            elif 1 <= rowNum <= len(keys):
                rowNum -= 1
                return {keys[rowNum]: self.__beams_rows[keys[rowNum]]}
            else:
                raise AbfSet.RowNumErr

        def get_list_of_beams(self, rowNum=None):
            """

            :param rowNum:
            :return:
            """
            # return table of beam
            beams = []
            keys = self.__beams_rows.keys()
            if not bool(rowNum):
                for v in self.__beams_rows.values():
                    beams.extend(v.keys())
            elif 1 <= rowNum <= len(keys):
                rowNum -= 1
                beams.extend(self.__beams_rows[keys[rowNum]].keys())
            else:
                raise AbfSet.RowNumErr

            return list(set(beams))

        def get_list_of_radiating_beams(self, rowNum=None):
            """

                        :param rowNum:
                        :return:
                        """
            # return table of beam

            beams = self.get_list_of_beams(rowNum=rowNum)
            rbeams = [self.get_radiating_beams_id(x) for x in beams]
            return rbeams

        def get_internal_beams_id(self, beam):
            """

            :param beam:
            :return:
            """
            if beam not in self.__beamIds.keys():
                raise AbfSet.BeamNotDefined
            return self.__beamIds[beam]

        def get_radiating_beams_id(self, beam):
            """

            :param beam:
            :return:
            """
            if beam not in self.__beamIds.keys():
                raise AbfSet.BeamNotDefined
            return self.__rBeamIds[beam]

        def get_beam_position(self, beam, rowNum=None):
            """

            :param beam:
            :param rowNum:
            :return:
            """
            keys = self.__beams_rows.keys()
            if not bool(rowNum):
                for k, v in self.__beams_rows.items():
                    if beam in v.keys():
                        return k+self._azimuth_offset, v[beam]+self._elevation_offset
            elif 1 <= rowNum <= len(keys):
                rowNum -= 1
                v = self.__beams_rows[keys[rowNum]]
                if beam in v.keys():
                    return keys[rowNum]+self._azimuth_offset, v[beam]+self._elevation_offset

            else:
                raise AbfSet.RowNumErr

            raise AbfSet.BeamNotDefined

        def set_panels_position_offset(self, azimuth_offset, elevation_offset):
            """

            :param azimuth_offset:
            :param elevation_offset:
            """
            self._azimuth_offset = azimuth_offset
            self._elevation_offset = elevation_offset

        def get_panels_position_offset(self):
            """

            :return:
            """
            return self._azimuth_offset, self._elevation_offset

        def get_right_edge_azimuth(self, rowNum=None):
            """

            :param rowNum:
            :return:
            """
            azm = []
            keys = self.__beams_rows.keys()
            if not bool(rowNum):
                for k, v in self.__beams_rows.items():
                    azm.append((k, v.items()[0]))
            elif 1 <= rowNum <= len(keys):
                rowNum -= 1
                azm.append((keys[rowNum], self.__beams_rows[keys[rowNum]].items()[0]))
            else:
                raise AbfSet.RowNumErr
            return azm[0][1][0], (azm[0][0], azm[0][1][1])

        def get_left_edge_azimuth(self, rowNum=None):
            """

            :param rowNum:
            :return:
            """
            azm = []
            keys = self.__beams_rows.keys()
            if not bool(rowNum):
                for k, v in self.__beams_rows.items():
                    azm.append((k, v.items()[-1]))
            elif 1 <= rowNum <= len(keys):
                rowNum -= 1
                azm.append((keys[rowNum], self.__beams_rows[keys[rowNum]].items()[-1]))
            else:
                raise AbfSet.RowNumErr
            return azm[-1][1][0], (azm[-1][0], azm[-1][1][1])

    class BeamSet:
        """
        beam set class definition
        """
        ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

        def __init__(self):
            pass

        beamSet_name = ""
        panels = []

        def load_beamSet(self, beamSet, beams_csv_path, beam='Beam',
                         elevation='Elevation Angle',
                         azimuth='Azimuth Angle',
                         beamId='Internal Beam Id', rBeamId='Radiated Beam ID'):
            self.beamSet_name = beamSet
            count = _get_panel_count(beamSet)
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
                    self.panels[ind - 1] = AbfSet.Abf(
                        csv_file, beam=beam, elevation=elevation,
                        azimuth=azimuth, beamId=beamId, rBeamId=rBeamId
                    )
                else:
                    raise AbfSet.BeamSetDataDefinition

        def get_panels_count(self):
            return self.panels.__len__()

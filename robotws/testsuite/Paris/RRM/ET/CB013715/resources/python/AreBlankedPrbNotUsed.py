# -*- coding: utf-8 -*

"""
:copyright: Nokia Networks
:author: Christophe SAMSON
:contact: christophe.samson@nokia.com
:maintainer:
:contact:
"""

import os.path
import logging
from testsuite.Paris.RRM.ET.resources.common.TtiTrace.python.tti_analyzer_framework import pandas_gate


def get_directory(file_path):
    """ Returns a path without a fie name
        Args:
            file_path (str): full path to any file
        Returns:
            str: a path without a file name
    """
    split_path = file_path.split('/')
    return "/".join(split_path[:-1])


class AreBlankedPrbNotUsed:
    def predicate(self, context, path_to_pickle):
        status = True
        dir = context['dir']
        physCellId = context['physCellId']
        bandwidth = context['bandwidth']
        actPrbBlanking = context['actPrbBlanking']
        print('bandwidth='+str(bandwidth))
        if dir == 'ul':
            nbrOfBlankedPRBsLowEdgeUL = context['prbBlanking']['nbrOfBlankedPRBsLowEdgeUL']
            nbrOfBlankedPRBsHighEdgeUL = context['prbBlanking']['nbrOfBlankedPRBsHighEdgeUL']
            print('nbrOfBlankedPRBsLowEdgeUL=' + str(nbrOfBlankedPRBsLowEdgeUL))
            print('nbrOfBlankedPRBsHighEdgeUL=' + str(nbrOfBlankedPRBsHighEdgeUL))
        else:
            nbrOfBlankedPRBsLowEdgeDL = context['prbBlanking']['nbrOfBlankedPRBsLowEdgeDL']
            nbrOfBlankedPRBsHighEdgeDL = context['prbBlanking']['nbrOfBlankedPRBsHighEdgeDL']
            print('nbrOfBlankedPRBsLowEdgeDL=' + str(nbrOfBlankedPRBsLowEdgeDL))
            print('nbrOfBlankedPRBsHighEdgeDL=' + str(nbrOfBlankedPRBsHighEdgeDL))

        df = self.load_dataframe(path_to_pickle=path_to_pickle)
        # print(df)
        df = df[df['rnti'] != '65535']
        df = df[df['physCellId'] == int(physCellId)]
        # print(df)
        if dir == 'ul':
            df_filtered = self.filter_dataframe_prbblanking_ul(df)
            df_filtered = df_filtered.rename(columns={
                "ulFdSchedData.startPrb": "startPrb",
                "ulFdSchedData.numOfPrb": "numOfPrb"})
        else:
            df_filtered = self.filter_dataframe_prbblanking_dl(df)
            df_filtered = df_filtered.rename(columns={
                "dlFdSchedData.startPrb": "startPrb",
                "dlFdSchedData.numOfPrb": "numOfPrb"})

        print(df_filtered)

        if actPrbBlanking and dir == 'ul':
            # Apply the function to each row in the DataFrame and create a new column
            df_filtered['check_ul_low_edge'] = \
                df_filtered.apply(lambda row: self.check_low_edge(row, nbrOfBlankedPRBsLowEdgeUL), axis=1)
            df_filtered['check_ul_high_edge'] = \
                df_filtered.apply(lambda row: self.check_high_edge(row, bandwidth, nbrOfBlankedPRBsHighEdgeUL),
                                  axis=1)
            status = all(df_filtered['check_ul_low_edge'])
            status &= all(df_filtered['check_ul_high_edge'])
        elif actPrbBlanking and dir == 'dl':
            df_filtered['check_dl_low_edge'] = \
                df_filtered.apply(lambda row: self.check_low_edge(row, nbrOfBlankedPRBsLowEdgeDL),
                                  axis=1)
            df_filtered['check_dl_high_edge'] = \
                df_filtered.apply(lambda row: self.check_high_edge(row, bandwidth, nbrOfBlankedPRBsHighEdgeDL),
                                  axis=1)
            status = all(df_filtered['check_dl_low_edge'])
            status &= all(df_filtered['check_dl_high_edge'])
        else:
            print('actPrbBlanking is {%s} with {%s}, check is not applicable!' % (actPrbBlanking, dir))
            status = True
        self.save_data_for_analysis(df_filtered, path_to_pickle, dir, physCellId)
        return status

    @staticmethod
    def load_dataframe(path_to_pickle):
        global pd
        pd = pandas_gate.install_and_import_pandas()
        df = pd.read_pickle(path_to_pickle)
        df = df.reset_index(drop=True)
        return df

    @staticmethod
    def save_data_for_analysis(udf, path_to_pickle, dir='dl', physCellId=50, suffix='prbBlanking'):
        file = "%s/%s_manual_analysis_physCellId_%s_%s.csv"
        udf.to_csv(str(file % (get_directory(path_to_pickle), dir, str(physCellId), suffix)), sep=';')

    @staticmethod
    def filter_dataframe_prbblanking_dl(df):
        required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'dlFdSchedData.subcellId',
                                   'dlFdSchedData.startPrb', 'dlFdSchedData.numOfPrb', 'dlFdSchedData.rat0Bitmap',
                                   'dlFdSchedData.ueBwpId', 'dlFdSchedData.cellBwpId', 'lcrId']
        #  'dlFdSchedData.patternId1',
        df = df[required_discriminators].copy()
        df.dropna(inplace=True)
        df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
        # logging.info("=====> filter_dataframe_prbblanking_dl=%s" % df)
        return df

    @staticmethod
    def filter_dataframe_prbblanking_ul(df):
        required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'ulFdSchedData.subcellId',
                                   'ulFdSchedData.startPrb', 'ulFdSchedData.numOfPrb', 'ulFdSchedData.cellBwpId',
                                   'lcrId']
        df = df[required_discriminators].copy()
        df.dropna(inplace=True)
        df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
        return df

    @staticmethod
    def check_low_edge(row, nbr_of_blanked_prbs_low_edge=0):
        status = True
        if int(row['startPrb']) < int(nbr_of_blanked_prbs_low_edge):
            status = False
        return status

    @staticmethod
    def check_high_edge(row, bandwidth, nbr_of_blanked_prbs_high_edge):
        status = True
        if int(row['startPrb']) + int(row['numOfPrb']) - 1 > int(bandwidth) - int(nbr_of_blanked_prbs_high_edge):
            status = False
        return status


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    # Example usage
    prbBlanking_ul_1 = {
        'nbrOfBlankedPRBsLowEdgeUL': 0,
        'nbrOfBlankedPRBsHighEdgeUL': 4
    }
    context_ul_cell_1 = {
        'dir': 'ul',
        'physCellId': 50,
        'actPrbBlanking': True,
        'bandwidth': 52,
        'prbBlanking': prbBlanking_ul_1
    }
    path_to_pickle = '/home/ute/csamson/TRACES/ttitrace_streaming_ulFdSchedData.pkl'

    are_blanked_prb_not_used = AreBlankedPrbNotUsed()
    status = are_blanked_prb_not_used.predicate(context_ul_cell_1, path_to_pickle)
    print(f"Status: {status}")

import logging
import math

from datetime import datetime
from datetime import timedelta

from testsuite.Paris.RRM.ET.CB011028.resources.python.tti_analysis.helper_functions import display_df_as_html
from testsuite.Paris.RRM.ET.resources.common.TtiTrace.python.tti_analyzer_framework import pandas_gate

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

rbi = BuiltIn()
pd = None


def log_begin_end_func_name(fn):
    def inner(*args, **kwargs):
        logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


""" Functions to be used """


@log_begin_end_func_name
def filter_valid_events_and_check_dlFdSchedData(path_to_pickle, target_pkl_path):
    """ This function filters needed rows for dlFdSchedData Check and
        saves it into a new pickle to be used by other functions

        :param path_to_pickle: Path of input pickle file
        :param target_pkl_path: Path of new target pickle file

        :returns: target_pkl_path
    """
    global pd
    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)
    pd.reset_option('^display.')

    # TTI Trace Events
    numAllocCellPrbDl_event = 'dlAllocatedPooledResourcesData.numAllocCellPrbDl'
    hasZabPrivilege_event = 'dlAllocatedPooledResourcesData.hasZabPrivilege'
    dlFdSchedData_numOfPrb_event = 'dlFdSchedData.numOfPrb'
    isValidWhatIsProposed = 'dlFdSchedData.isValidWhatIsProposed'

    filtered_df = (
        df.loc[((df[isValidWhatIsProposed] != 0) & (df['rnti'] != 65535)),
               ['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
                numAllocCellPrbDl_event, hasZabPrivilege_event, dlFdSchedData_numOfPrb_event]]).dropna(
        subset=[
            numAllocCellPrbDl_event,
            hasZabPrivilege_event,
            dlFdSchedData_numOfPrb_event
        ], how='all').reset_index(drop=True)

    filtered_df = filtered_df.fillna(0)
    filtered_df = filtered_df.astype(int)

    rbi.log('DF successfully filtered!', 'INFO')
    rbi.log(filtered_df)

    # Save back to pickle
    filtered_df.to_pickle(target_pkl_path)

    return target_pkl_path

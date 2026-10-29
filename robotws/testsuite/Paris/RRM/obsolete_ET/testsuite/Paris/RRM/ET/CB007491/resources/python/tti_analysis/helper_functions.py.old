# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

rbi = BuiltIn()


""" Helper Common Function for Pandas """


def display_df_as_html(df, log_level='TRACE'):
    """ This function transforms the data frame into an HTML table

        :param df: Pandas dataframe
        :param log_level: What log level to show the data frame
    """

    html_formatted_df = df.to_html()
    rbi.log(html_formatted_df, log_level, html=True)


def normalize_sfn_values(df):
    """ SFN rolls over at 1023 to 0 instead continue the SFN count i.e. 1024, 1025 etc.
        This makes each SFN unique and can be grouped for analysis

        :param df: Pandas dataframe
    """

    df['normalized_sfn'] = (df['sfn'] + df['sfn'].diff().lt(0).cumsum() * 1024).astype(int)
    return df

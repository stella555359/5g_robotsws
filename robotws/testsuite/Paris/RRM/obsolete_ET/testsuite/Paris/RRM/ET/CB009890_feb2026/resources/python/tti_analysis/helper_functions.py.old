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

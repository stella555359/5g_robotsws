import logging
import requests
import os


def check_nidd_change(baseline0, baseline):
    """
    Description

    checks if versions of NIDD_RADIO and SBTS_NIDD components (SBTS_NIDD usually not defined in trunk
    but defined in some branches)
    differs in 2 specified SW builds (whose names are given as parameters)
    the info is retrieved from WfT using new JSON/XML API query
    returns the string in form "YES|NO|undecided, YES|NO|undecided" where 1st part concerns
    NIDD_RADIO and 2nd part SBTS_NIDD
    e.g. "YES, NO" means NIDD_RADIO changed, SBTS_NIDD unchanged

    | Parameters  | Man.    | Description                         | Default
    | baseline0   | YES     | SW build active before SW update    | --
    | baseline    | YES     | SW build being installed            | --

    *RETURN VALUE*
    the string in form "YES|NO|undecided, YES|NO|undecided" where 1st part concerns NIDD_RADIO and 2nd part SBTS_NIDD

    *AUTHOR*
    krzysztof.olczak@nokia.com

    *DATE*
    April, 2018
    """

    b = baseline0.split("_")
    branch = b[0].replace("00", "_TRUNK") + "_" + b[1]

    WFT_general_key = "QF5oQmJRkaK4UWIDMGH0Ore6RcQMzseZ459IdCIB"
    WFT_API_KEY = os.environ.get('WFT_API_KEY', WFT_general_key)
    # Query retrieving changed modules ("changed_baselines") in given build
    # compared to previous build; data are compiled for a range of builds
    URL = 'https://wft.int.net.nokia.com:8091/api/v1/build.json?' \
          'access_key={wft_access_key}&' \
          'utf8=%E2%9C%93&' \
          'view_id=3&' \
          'view[temporary]=1&' \
          'view[object]=Build&' \
          'view[page]=1&' \
          'view[items]=100&' \
          'view[sorting_field]=baseline&' \
          'view[sorting_direction]=DESC&' \
          'view[columns][]=baseline&' \
          'view[columns][]=changed_baselines&' \
          'view[view_filters_attributes[675538899460915]][column]=branch.title&' \
          'view[view_filters_attributes[675538899460915]][operation]=eq&' \
          'view[view_filters_attributes[675538899460915]][value][]={wft_branch}&' \
          'view[view_filters_attributes[1517573595124]][column]=baseline&' \
          'view[view_filters_attributes[1517573595124]][operation]=gt&' \
          'view[view_filters_attributes[1517573595124]][value][]={wft_baseline0}&' \
          'view[view_filters_attributes[1517573627642]][column]=baseline&' \
          'view[view_filters_attributes[1517573627642]][operation]=lteq&' \
          'view[view_filters_attributes[1517573627642]][value][]={wft_baseline}'.format(wft_access_key=WFT_API_KEY,
                                                                                        wft_branch=branch,
                                                                                        wft_baseline0=baseline0,
                                                                                        wft_baseline=baseline)

    logging.debug("WFT_API query URL:")
    logging.debug(URL)
    try:
        response = requests.get(URL).text

    except Exception as e:
        if "connection failed" in str(e):
            logging.debug("Connection to WfT failed")
        return "undecided, undecided"

    else:
        logging.debug(response)
        if "ERROR:" in response:
            return "undecided, undecided"
        if "_RADIO_" in response:
            ret = "YES"
        else:
            ret = "NO"
        if "_NIDD_" in response:
            ret = ret + ", YES"
        else:
            ret = ret + ", NO"
        return ret

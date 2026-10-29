import json
import taf.gnb.oam.coam.vdu as vdu
import re


vdu_kw = vdu.vdu()


def extract_physcellid_from_vdu(alias):
    """
    Retrieve the physical cell Ids for all cells in the current plan of vDU.
    This is a helper function for KW `Get gNB Physical Cell ID From AiC`.

    *Scope*  Internal

    | alias | The alias for the VDU REST API connection |

    *Returns*   dictionary with cell name as key and its pysical cell IDs as vaule
    """
    dist_phy_cell_id = {}
    for item in (vdu_kw.get_current_plan_objects(vdu_connection=alias, class_name=['NRCELL'])['objects']):
        if type(item) == dict:
            dist_phy_cell_id[item['distName'].rpartition('/')[-1]] = json.loads(item['json_repr'])[
                'physCellId']
    return dist_phy_cell_id


def extract_distnames_from_aic_vdu(alias, regex):
    """
    Retrieves classes and objects present in the AiC DU Plan
    Extracts all the distNames and matches them with the given regular expression
    This is a helper function for KW `Get distNames from aic VDU`.

    *Scope*  Internal

    | alias | The alias for the VDU REST API connection |

    *Returns*   List with matched distNames
    """
    regex_matches = []
    for item in (vdu_kw.get_current_plan_objects(vdu_connection=alias)['objects']):
        if re.match(str(regex), item['distName']):
            regex_matches.append(item['distName'])
    return regex_matches

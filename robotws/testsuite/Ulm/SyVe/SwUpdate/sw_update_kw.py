# ====================================================================================================
# This is a Python File, which helps to implement the Robot Keywords used in Update_eNB_gNB_Software.robot
# Team: 'MN 5G&SC 5G Pz ULM 2 SqdGp63'
# Email: 'I_MN_5GSC_PZ_ULM_SQD_64@nokia.com'
# Author: Monika Kolleshi
# ----------------------------------------------------------------------------------------------------[120 characters]
# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn


def Get_Node_Ids_From_Node_Names(node_name):
    node_list = node_name.split(',') if node_name else []
    node_id = [x[-1] for x in node_list]
    node_id = [eval(i) for i in node_id]
    return node_id

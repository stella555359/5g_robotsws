# Documentation
#  Author: Barbara Wozniak, barbara.wozniak@nokia.com
#  Maintainer: Piotr Siedlak, piotr.siedlak@nokia.com

import datetime
from taf.nms.netact.cm_editor.api.exceptions import ManagedObjectNotFound


def delete_HWResetReqs(netact, asi_mo_id, alias):
    date = datetime.datetime.now()
    plan_name = "Plan_Sanity_Delete_HWResetReq_"+date.strftime("%m-%d-%Y, %H:%M:%S")
    plan = netact.create_plan_configuration(plan_name, alias=alias)
    configuration = netact.get_actual_configuration(alias=alias)
    asi_mo = netact.get_managed_object(configuration, asi_mo_id, alias=alias)
    mo_id = asi_mo_id+"/CMD-1/HWRESETREQ-"
    meta_class = "com.nokia.asi:HWRESETREQ"
    is_plan_empty = True
    mo_ids = []
    for i in range(1, 5):
        mo_ids.append(mo_id+str(i))
        try:
            netact.get_managed_object(configuration, mo_id+str(i), alias=alias)
            netact.create_managed_object(plan, meta_class, asi_mo.meta_version, mo_id+str(i), operation="DELETE",
                                         alias=alias)
            is_plan_empty = False
        except ManagedObjectNotFound:
            pass
    if not is_plan_empty:
        netact.provision_plan(plan_name, dist_names=asi_mo_id, backup_plan_name="Backup"+plan_name,
                              create_backup_plan=True, alias=alias)
    netact.delete_ne_data_from_configurator(dist_names=mo_ids, alias=alias)

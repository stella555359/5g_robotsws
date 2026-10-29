from testsuite.AIRPHONE.Resources.Python.DeltaStore import DeltaStore
from taf.sbts.oam.coam.admin import admin

# The library below is a set of examples of some basic online recommissioning options. If you'd like to combine
# those options into one big recommissioning plan (i.e. a change of parameters from multiple managed objects + lists),
# please check the testsuite/AIRPHONE/Resources/Python/DeltaStore.py library for more options of filling the delta.
# After your delta is prepared - the recommissioning is being done through taf.admin library keywords.
#
# Please note that the recommissioning will be performed online ONLY when all of the parameters being changed in the
# delta have their 'modification type' equal to 'online'. In other cases the recommissioning should pass properly too,
# but it might trigger a BTS restart (like when uploading an scf).


deltaFun = DeltaStore()


def recommission_a_set_of_parameters_in_one_managed_object(dist_name,
                                                           skip_errors=False,
                                                           activate=True,
                                                           **params):
    deltaFun.initialise_delta_store
    deltaFun.add_parameters_to_delta(dist_name=dist_name, **params)
    delta = deltaFun.collect_delta_store
    admin_alias = admin.connect_to
    validation_results = admin.perform_delta_recommissioning(delta_file=delta,
                                                             skip_parameter_relation_errors=skip_errors,
                                                             should_activate=activate,
                                                             connection=admin_alias
                                                             )
    return validation_results


def add_new_managed_object_with_parameters_and_perform_recommissioning(dist_name,
                                                                       skip_errors=False,
                                                                       activate=True,
                                                                       **params):
    deltaFun.initialise_delta_store
    deltaFun.add_managed_object_and_parameter_to_delta(dist_name=dist_name, **params)
    delta = deltaFun.collect_delta_store
    admin_alias = admin.connect_to
    validation_results = admin.perform_delta_recommissioning(delta_file=delta,
                                                             skip_parameter_relation_errors=skip_errors,
                                                             should_activate=activate,
                                                             connection=admin_alias
                                                             )
    return validation_results


def delete_managed_object_and_perform_recommissioning(dist_name,
                                                      skip_errors=False,
                                                      activate=True):
    deltaFun.initialise_delta_store
    deltaFun.delete_managed_object_from_delta(dist_name=dist_name)
    delta = deltaFun.collect_delta_store
    admin_alias = admin.connect_to
    validation_results = admin.perform_delta_recommissioning(delta_file=delta,
                                                             skip_parameter_relation_errors=skip_errors,
                                                             should_activate=activate,
                                                             connection=admin_alias
                                                             )
    return validation_results


def add_list_with_parameters_and_perform_recommissioning(dist_name,
                                                         list_name,
                                                         skip_errors=False,
                                                         activate=True,
                                                         **params):
    # Remember to at least fill the values of all the mandatory parameters of the created list
    deltaFun.initialise_delta_store
    deltaFun.add_list_parameters_to_delta(dist_name=dist_name, list_name=list_name, **params)
    delta = deltaFun.collect_delta_store
    admin_alias = admin.connect_to
    validation_results = admin.perform_delta_recommissioning(delta_file=delta,
                                                             skip_parameter_relation_errors=skip_errors,
                                                             should_activate=activate,
                                                             connection=admin_alias
                                                             )
    return validation_results

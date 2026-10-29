import os


class _ComponentNotFoundError(Exception):
    pass


class _CommonBTSComponentRetriever:

    def get_info_on_specific_component(self, all_components_info, component_id):
        """
        Works on output of admin CLI methods that return info on those BTS components that can be more than one:
        :return: json for component with specified id
        """
        for single_component in all_components_info:
            id_from_resp = self._get_component_id_from_name(
                self._get_component_name_from_path(
                    self._get_path_from_component_info(single_component)
                )
            )
            if int(id_from_resp) == int(component_id):
                return single_component
        else:
            raise _ComponentNotFoundError(
                "Component with ID: {} not found".format(component_id)
            )

    def _get_path_from_component_info(self, single_component_json):
        return single_component_json["id"]["configuration"]

    def _get_component_name_from_path(self, path):
        """example - /MRBTS-1/RAT-1/VIEW-1/MRBTS_R-1/NRBTS_R-50301/NRCELL_R-58836 -> NRCELL_R-58836"""
        return os.path.basename(path)

    def _get_component_id_from_name(self, name):
        """Example: NRCELL_R-58836 -> 58836"""
        return int(name.split("-")[-1])


class _RuRetriever(_CommonBTSComponentRetriever):

    def _get_path_from_component_info(self, single_component_json):
        """Some RUs have different structure of response
        #TODO fill in RU types for docu
        """
        try:
            return single_component_json["rmod"]["id"]["configuration"]
        except KeyError:
            return single_component_json["id"]["configuration"]


def get_info_on_specific_component(all_components_info, component_id):
    return _CommonBTSComponentRetriever().get_info_on_specific_component(all_components_info, component_id)


def get_info_on_specific_ru(all_components_info, component_id):
    return _RuRetriever().get_info_on_specific_component(all_components_info, component_id)

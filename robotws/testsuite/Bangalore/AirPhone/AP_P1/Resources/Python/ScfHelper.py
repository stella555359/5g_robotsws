from taf.config.scf import scf


class ScfHelper:
    def __init__(self):
        self.scf = scf()

    def load_scf(self, file_path):
        return self.scf.load_scf(file_path)

    def get_feature_paramters_from_scf(self, scf_path, feature_params, distname, listname=None):
        feature_params_dict = {}
        self.load_scf(file_path=scf_path)
        for param in feature_params:
            if listname:
                param_value = self.scf.get_value_from_scf(dist_name=distname, list_name=listname, p_name=param)
            else:
                param_value = self.scf.get_value_from_scf(dist_name=distname, p_name=param)
            param_value = param_value if param_value not in ['True', 'False'] else param_value.lower()
            param_value = 'infinity' if param_value == 'inf' else param_value
            feature_params_dict[param] = param_value
        return feature_params_dict

    def check_if_object_is_present_in_scf(self, scf_path, distname):
        self.load_scf(file_path=scf_path)
        status = self.scf.is_object_in_scf(distname)
        if status:
            print("{} exists in scf".format(distname))
        else:
            raise Exception("{} does not exist in scf".format(distname))
        return

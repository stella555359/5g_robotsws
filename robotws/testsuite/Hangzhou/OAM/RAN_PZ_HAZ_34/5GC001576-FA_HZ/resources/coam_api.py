import xml.etree.ElementTree as ET


class coam_api(object):
    def _update_from_locals(self, local_args):
        local_args.pop('self')
        vars(self).update(local_args)

    def connect(self):
        raise NotImplementedError

    def disconnect(self):
        raise NotImplementedError

    def get_scf(self, coverage):
        raise NotImplementedError

    def send_delta_scf(self, delta):
        raise NotImplementedError

    @staticmethod
    def _get_mo_from_cmData(cmData, distName):
        return cmData.find(".//*[@distName='{}']".format(distName))

    def check_if_mos_exist(self, distNames, scf=None):
        if scf is None:
            scf = self.get_scf('Full Runtime')
        tree = ET.parse(scf)
        raml = tree.getroot()
        cmData = raml[0]
        for name in distNames:
            if self._get_mo_from_cmData(cmData, name) is None:
                print (name)
                return False
        return True

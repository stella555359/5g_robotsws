class LogProfile(dict):
    gcp = 'gnb_custom_profile'
    gtp = 'gnb_trace_profile'
    ecp = 'enb_custom_profile'
    etp = 'enb_trace_profile'
    bcp = 'bts_custom_profile'
    btp = 'bts_trace_profile'
    vcutp = 'vcu_trace_profile'
    vcucp = 'vcu_custom_profile'
    vdutp = 'vdu_trace_profile'
    vducp = 'vdu_custom_profile'

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self['wait_for_activation'] = True

    def with_5g_tti_trace(self):
        self._add_key_to_custom_profile_if_not_yet_added('L2Ps_Component', self.gcp)
        return self

    def with_5g_syslog(self):
        self._add_key_to_custom_profile_if_not_yet_added('condor5gSyslog', self.gcp)
        return self

    def with_5g_bip(self, interface='L1-L2', mirroring_time=0):
        self._add_key_to_custom_profile_if_not_yet_added('bip_interface_mirroring', self.gcp)
        self['bip_mirroring_interface'] = interface
        self['bip_mirroring_time'] = mirroring_time
        return self

    def with_5g_cplane(self, cplane_interface=None):
        self._add_key_to_custom_profile_if_not_yet_added('cp_5g', self.gcp)
        self['control_plane_interface'] = cplane_interface
        return self

    def with_lte_cplane(self):
        self._add_key_to_custom_profile_if_not_yet_added('cp_4g', self.ecp)
        return self

    def with_vcu_cplane(self):
        self._add_key_to_custom_profile_if_not_yet_added('controlPlane5gVcu', self.vcucp)
        return self

    def with_vdu_cplane(self):
        self._add_key_to_custom_profile_if_not_yet_added('controlPlane5gVdu', self.vducp)
        return self

    def with_tracer_5g(self):
        self._add_key_to_custom_profile_if_not_yet_added('Tracer_5g', self.gcp)
        return self

    def with_tracer_lte(self):
        self._add_key_to_custom_profile_if_not_yet_added('lteTracer_4g', self.ecp)
        return self

    def with_tracer_vcu(self):
        self._add_key_to_custom_profile_if_not_yet_added('tracerVcu', self.vcucp)
        return self

    def with_tracer_vdu(self):
        self._add_key_to_custom_profile_if_not_yet_added('tracerVdu', self.vducp)
        return self

    def with_lte_tti(self):
        self._add_key_to_custom_profile_if_not_yet_added('condor4gTti', self.ecp)
        return self

    def with_lte_syslog(self):
        self._add_key_to_custom_profile_if_not_yet_added('condor4gSyslog', self.ecp)
        return self

    def with_scf(self):
        self._add_key_to_custom_profile_if_not_yet_added('scf', self.bcp)
        return self

    def with_pm_files(self):
        self._add_key_to_custom_profile_if_not_yet_added('pmFiles', self.bcp)
        return self

    def with_ip_capture(self, uplane_interface=False):
        self._add_key_to_custom_profile_if_not_yet_added('ipCapture', self.bcp)
        self['uplane_interface'] = uplane_interface
        return self

    def with_snapshot(self):
        self._add_key_to_custom_profile_if_not_yet_added('immediateSnapshot', self.bcp)
        return self

    def with_vcu_snapshot(self):
        self._add_key_to_custom_profile_if_not_yet_added('snapshotVcu', self.vcucp)
        return self

    def with_vdu_snapshot(self):
        self._add_key_to_custom_profile_if_not_yet_added('snapshotVdu', self.vducp)
        return self

    def with_vcu_syslog(self):
        self._add_key_to_custom_profile_if_not_yet_added('syslogVcu', self.vcucp)
        return self

    def with_vdu_syslog(self):
        self._add_key_to_custom_profile_if_not_yet_added('syslogVdu', self.vducp)
        return self

    def _add_key_to_custom_profile_if_not_yet_added(self, key, profile):
        if profile not in self:
            self[profile] = []
        if key not in self[profile]:
            self[profile].append(key)

    def select_predefined_gnb_profile(self, gnb_profile):
        self[self.gtp] = gnb_profile

    def select_predefined_enb_profile(self, enb_profile):
        self[self.etp] = enb_profile

    def select_predefined_bts_profile(self, bts_profile):
        self[self.btp] = bts_profile

    def select_predefined_vcu_profile(self, vcu_profile):
        self[self.vcutp] = vcu_profile

    def select_predefined_vdu_profile(self, vdu_profile):
        self[self.vdutp] = vdu_profile

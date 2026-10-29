from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

_enb_id = str(tl.enbs[0].instance_id)
_gnb_id = str(tl.gnbs[0].instance_id)
_gnb_id2 = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-' + _gnb_id
_MRBTSname2 = 'MRBTS-' + _gnb_id2
_MRBTSname_enb = 'MRBTS-' + _enb_id
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id
_NRBTSname2 = _MRBTSname2 + '/NRBTS-' + _gnb_id2
_LNBTSname = _MRBTSname_enb + '/LNBTS-' + _enb_id

_LTECELL48040name = _LNBTSname + '/LNCEL-48040'
_LTECELL48041name = _LNBTSname + '/LNCEL-48041'
_LTECELL48042name = _LNBTSname + '/LNCEL-48042'
_LTECELL48043name = _LNBTSname + '/LNCEL-48043'
_LTECELL48044name = _LNBTSname + '/LNCEL-48044'
_LTECELL48045name = _LNBTSname + '/LNCEL-48045'
_LTECELL48046name = _LNBTSname + '/LNCEL-48046'
_LTECELL48047name = _LNBTSname + '/LNCEL-48047'
_LTECELL48048name = _LNBTSname + '/LNCEL-48048'
_LTECELL48049name = _LNBTSname + '/LNCEL-48049'

lock_all_lte_cells = [
    dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48041name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48042name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48043name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48044name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48046name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48047name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48048name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48049name, parameter='administrativeState'),
]

unlock_all_lte_cells = [
    dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48041name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48042name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48043name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48044name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48046name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48047name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48048name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48049name, parameter='administrativeState'),
]

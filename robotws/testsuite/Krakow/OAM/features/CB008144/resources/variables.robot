*** Variables ***
@{TC_1_expected_cells_without_alarm} =  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-18003
...  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-18002
...  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-18001
@{TC_1_expected_rmods_without_alarm} =  MRBTS-${tl.gnbs[0].global_bts_id}/EQM-1/APEQM-1/RMOD-1
...  MRBTS-${tl.gnbs[0].global_bts_id}/EQM-1/APEQM-1/RMOD-2  MRBTS-${tl.gnbs[0].global_bts_id}/EQM-1/APEQM-1/RMOD-3
@{TC_6_expected_cells_with_alarm} =  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-18003
...  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-18002
@{TC_6_not_expected_cells_with_alarm} =  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-18001

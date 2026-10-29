from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_wts import run_egate_cmd
import csv


def assign_ues_to_beams(ues_list=None, beams_list=None, assignments=None):
    """
    Assign specified beams to a list of UEs. One beam can be assigned to multiple UEs,
    but the assignments must be specified by the user.

    :param ues_list: List of UE IDs to assign beams to (default is 6 UEs).
    :param beams_list: List of available beam IDs (default is 6 beams).
    :param assignments: Dictionary that maps UE IDs to beam IDs.
    :return: None
    """
    ue_beam_indices = [
        "0,2,1,3,4,5",
        "1,0,2,3,4,5",
        "2,1,0,3,4,5",
        "3,0,2,5,4,1",
        "4,2,0,3,1,5",
        "5,0,2,3,4,1",
    ]

    for profile_id, ue_beam_index in enumerate(ue_beam_indices, start=1):
        run_egate_cmd(
            f'beam_control_testmode_nr profile_id={profile_id} '
            f'ueBeamIndexInitial={ue_beam_index} '
            f'ssbeam_bestbeam={profile_id - 1} '
            f'ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50'
        )

    # Default values for UEs and beams
    if ues_list is None:
        ues_list = [1, 2, 3, 4, 5, 6]

    if beams_list is None:
        beams_list = [1, 2, 3, 4, 5, 6]

    if assignments is None:
        raise ValueError("You must provide beam assignments for UEs (assignments).")

    # Validate the assignments
    for ue_id in ues_list:
        if ue_id not in assignments:
            raise ValueError(f"Missing beam assignment for UE {ue_id}. You must specify a beam for this UE.")
        beam = assignments[ue_id]
        if beam not in beams_list:
            raise ValueError(f"Beam {beam} assigned to UE {ue_id} is not in the available beams list.")

    # Assign beams to UEs
    for ue_id in ues_list:
        beam = assignments[ue_id]
        run_egate_cmd(
            f'ue_testmode_set_nr id={ue_id} testmode=beam_control action=activate '
            f'profile_id={beam} beamaction=attach'
        )


def mue_prach_control_testmode(
        profile_id_index=None, first_ue_id_index=None, last_ue_id_index=None,
        is_consecutive=False, multiUE=True):
    if multiUE:
        prach_time_param = "mUe_in_consecutive_prachTime=true" if is_consecutive else "mUe_in_same_prach_time=true"
        run_egate_cmd(
            f'mue_prach_control_testmode_nr profile_id={profile_id_index} '
            f'{prach_time_param} numOfSfnToBeAddedInPrachTime=26'
        )
        run_egate_cmd(
            f'ue_testmode_set_nr id={first_ue_id_index}-{last_ue_id_index} testmode=mue_prach_control '
            f'action=activate profile_id={profile_id_index}')
    else:
        prach_time_param = "mUe_in_consecutive_prachTime=true" if is_consecutive else "mUe_in_same_prach_time=true"
        run_egate_cmd(
            f'mue_prach_control_testmode_nr profile_id={profile_id_index} '
            f'{prach_time_param} numOfSfnToBeAddedInPrachTime=26'
        )
        run_egate_cmd(
            f'ue_testmode_set_nr id={first_ue_id_index} testmode=mue_prach_control action=activate '
            f'profile_id={profile_id_index}')


def verify_rach_occasion_with_6_different_preambles(file_path):
    with open(file_path) as csv_file:
        csv_reader = csv.reader(csv_file)

        # Rach occasion with different 6 preambles
        rach_occasion_with_6_preambles = [row for row in csv_reader if len(row) == 6]

        # Check if there is exactly one rach occasion with 6 preambles
        if len(rach_occasion_with_6_preambles) == 1:
            # Print the found line
            print(f"Rach occasion with 6 different preambles: {rach_occasion_with_6_preambles[0]}")

            # Verify that all preambles in this row are unique
            if len(set(rach_occasion_with_6_preambles[0])) == 6:
                return True
            else:
                return "Rach occasion with 6 preambles contains repeated values"
        else:
            return "There are more rach occasion with 6 preambles or no rach occasion with 6 preambles"

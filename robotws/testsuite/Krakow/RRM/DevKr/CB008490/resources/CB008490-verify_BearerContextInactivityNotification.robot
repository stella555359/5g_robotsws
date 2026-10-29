*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Michal Szymakowski 	<michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     CB008490.py

*** Variables ***

*** Keywords ***
##### BearerContextInactivityNotification keywords #####
Verify in BearerContextInactivityNotification that uE-Activity eq ${act} and dRB-Activity-List is not present for ${opt:MN|SN} gNB${gnb}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextInactivityNotification
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     ActivityInformation contains (uE-Activity eq '${act}') and dRB-Activity-List is not present
    ...     message_alias=BearerContextInactivityNotification
    ...     flow_alias=${flow_alias}

Verify in BearerContextInactivityNotification that uE-Activity is not present and dRB-Activity-List contains DRBs [${drb_ids}] for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextInactivityNotification
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     uE-Activity is not present
    ...     message_alias=BearerContextInactivityNotification
    ...     flow_alias=${flow_alias}

    verify_drbs_in_BearerContextInactivityNotification    ${flow_alias}    BearerContextInactivityNotification    ${drb_ids}

Verify in ${mult}BearerContextInactivityNotification${suffix} that ${drb_num} out of ${all_drbs} DRBs ${opt:is|are} active for ${opt:MN|SN} gNB${gnb}
    ${flow_alias}=     Get flow name
    ...     procedure=${mult}bearerContextInactivityNotification
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     uE-Activity is not present
    ...     message_alias=BearerContextInactivityNotification${suffix}
    ...     flow_alias=${flow_alias}

    verify_drb_activity    ${flow_alias}    BearerContextInactivityNotification${suffix}    ${drb_num}    ${all_drbs}

Verify that inactivity occurred after ${time} seconds for ${opt:MN|SN} gNB${gnb_id} with single E1AP inactivity message
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextInactivityNotification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    verify_message_delay_from_message_to_time_point
    ...    flow_alias=${flow_alias}
    ...    message_alias=BearerContextInactivityNotification
    ...    time_alias=${opt}_DRB_inact_start
    ...    expected_diff_time=${time}
    ...    tolerance=1.0

Verify that inactivity occurred after ${time} seconds for ${opt:MN|SN} gNB${gnb_id} with multiple E1AP inactivity messages
    ${flow_alias}=     Get flow name
    ...     procedure=2*bearerContextInactivityNotification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    verify_message_delay_from_message_to_time_point
    ...    flow_alias=${flow_alias}
    ...    message_alias=BearerContextInactivityNotification_2
    ...    time_alias=${opt}_DRB_inact_start
    ...    expected_diff_time=${time}
    ...    tolerance=1.0

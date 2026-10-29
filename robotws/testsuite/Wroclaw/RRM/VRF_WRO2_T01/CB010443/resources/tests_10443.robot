*** Settings ***
Documentation
...  Author:        Maciej Cupial, Adam Tokarski
...  Contact:       maciej.cupial@nokia.com, adam.tokarski@nokia.com
...  Feature owner: Karol Malutkiewicz, Witold Galka
...  Description:   Power Saving feature for 4G site, part 2
...                 Feature Corner:     https://feature-corner.nsn-net.net/materials/clchjwwcs374404xkzix2h4shg

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010443/resources/keywords_9920.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010443/resources/keywords_10443.robot


*** Keywords ***
Activation_and_configuration_of_feature_CB010443-A_Coordinated_4G-5G_power_saving_part2 - 4G
    Perform Commissioning 10443 LTE
    Activate 10443
    Verify 9920_2 Activation


Deactivation_of_feature_CB010443-A_Coordinated_4G-5G_power_saving_part2 - 4G
    Perform Commissioning 10443 LTE
    Activate 10443
    Deactivate 10443
    Verify 9920_2 Activation

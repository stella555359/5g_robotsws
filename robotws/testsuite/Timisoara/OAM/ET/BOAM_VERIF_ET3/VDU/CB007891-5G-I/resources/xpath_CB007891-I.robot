*** Variables ***

${INPUT_NAME_FIELD}    login-username
${INPUT_PASSWORD_FIELD}    login-password
${LOGIN_BUTTON}    //span[contains(text(), 'Login')]

${BUTON1BMC1}       //*[@id="main"]/div/div[2]/aside[2]/div/section[2]/div/div/div[2]/form/div[1]/label/div/ins
${BUTON2BMC1}       //*[@id="main"]/div/div[2]/aside[2]/div/section[2]/div/div/div[2]/form/div[2]/label/div/ins

${BUTON1BMC2}       //*[@id="main"]/div/div[2]/aside[2]/div/section[2]/div/div/div[2]/form/div[1]/label/div/ins
${BUTON2BMC2}       //*[@id="main"]/div/div[2]/aside[2]/div/section[2]/div/div/div[2]/form/div[2]/label/div/ins

${CHECK_ALARMS1}    //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                 webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[3]
${CHECK_ALARMS2}    //*[@id="/alarm/active"]/span

${UPPODS1}          //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                 -webem-panel-split/-split/div[2]/div/div/vdu-dashboard/dashboard-container/div/ngx-gridster/div/
...                 ngx-gridster-item[6]/div/div[1]/-vnfc-status/ui-webem-rich-panel/ui-webem-panel/div/div[1]/div/div/
...                 span[2]/ui-webem-button/p-button/button
${UPPODS2}          //*[@id="toggle-view-button"]/button/span[2]
${UPPODS3}          //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                 ui-webem-panel-split/as-split/div[2]/div/div/infrastructure-status/
...                  infrastructure-status-table-view/ui-webem-table-view/
...                 -table/div/div[1]/div/cdk-virtual-scroll-viewport/div[1]/table/tbody/tr[10]
${UPPODS4}          //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
...                 ui-webem-panel-split/as-split/div[2]/div/div/infrastructure-status/
...                 infrastructure-status-table-view/ui-webem-table-view/
...                 -table/div/div[1]/div/cdk-virtual-scroll-viewport/div[1]/table/tbody/tr[11]

#!/bin/bash
# If the first argument to %preun is 0, the action is uninstallation.
# If the first argument is 1, then action is upgrade.
if [ $1 -eq 0 ]; then
    # When Sentinel is removed we stop the service if it's still running
    # then we remove the link in init.d directory
    /usr/bin/systemctl status sentinel.service 1> /dev/null
    if [ $? -eq 0 ]; then
        /usr/bin/systemctl stop sentinel.service
    fi
    rm -rf /usr/lib/systemd/system/sentinel.service
fi

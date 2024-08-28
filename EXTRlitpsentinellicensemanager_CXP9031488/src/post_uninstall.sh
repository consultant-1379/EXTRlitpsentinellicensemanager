#!/bin/bash
# If the first argument to %postun is 0, the action is uninstallation.
# If the first argument is 1, then action is upgrade.
if [ $1 -eq 0 ]; then
    # When Sentinel is removed we must clean up /opt/SentinelRMSSDK as
    # no way to list %files with maven rpm plugin
    rm -rf /opt/SentinelRMSSDK
fi

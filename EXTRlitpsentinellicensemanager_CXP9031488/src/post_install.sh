#!/bin/bash
# If the first argument to %post is 1, the action is initial installation.
# If the first argument is 2, then action is upgrade.

SENTINEL_SVC='/usr/lib/systemd/system/sentinel.service'

remove_demo_licences() {
    # When Sentinel is initially installed, clean all default licenses that are
    # supplied for sdk demo apps
    # LITPCDS-10839
    # We must set LSFORCEHOST to hostname to remove licences
    /usr/bin/systemctl status sentinel.service 1> /dev/null
    WAS_RUNNING=$?

    cd /opt/SentinelRMSSDK/bin/
    if [ ${WAS_RUNNING} -eq 0 ]; then
        /usr/bin/systemctl stop sentinel.service 1> /dev/null
    fi
    ./lserv 1> /dev/null
    export LSFORCEHOST=$(hostname)
    /usr/bin/expect<<'EOF'
    set timeout -1
    log_user 0
    spawn /opt/SentinelRMSSDK/bin/lslic -DL "VTL" "1.0" "C5978F5311954364"
    expect "This will delete license(s) from the server, do you want to continue? (Y/N): "
    send -- "Y\r"
    expect eof
EOF
    /usr/bin/expect<<'EOF'
    set timeout -1
    log_user 0
    spawn /opt/SentinelRMSSDK/bin/lslic -DL "99" "" "4852BF08F8355F8C"
    expect "This will delete license(s) from the server, do you want to continue? (Y/N): "
    send -- "Y\r"
    expect eof
EOF
    /usr/bin/expect<<'EOF'
    set timeout -1
    log_user 0
    spawn /opt/SentinelRMSSDK/bin/lslic -DL "DOTS" "1.0" "48E81F711008CB71"
    expect "This will delete license(s) from the server, do you want to continue? (Y/N): "
    send -- "Y\r"
    expect eof
EOF
    /usr/bin/expect<<'EOF'
    set timeout -1
    log_user 0
    spawn /opt/SentinelRMSSDK/bin/lslic -DL "HOOKDEMO" "1.0" "E26765BC3860CAB4"
    expect "This will delete license(s) from the server, do you want to continue? (Y/N): "
    send -- "Y\r"
    expect eof
EOF
    /usr/bin/killall lserv
    unset LSFORCEHOST
    /usr/bin/systemctl status sentinel.service 1> /dev/null
    WAS_RUNNING=$?
    if [ ${WAS_RUNNING} -eq 0 ]; then
        /usr/bin/systemctl stop sentinel.service 1> /dev/null
    fi
}


if [ $1 -eq 1 ]; then
    # When Sentinel is initially installed, create link to sentinel service unit
    if [ ! -f ${SENTINEL_SVC} ] ; then
        ln -s /opt/SentinelRMSSDK/bin/sentinel.service ${SENTINEL_SVC}
    fi
    remove_demo_licences

    # LITPCDS-13438 Sentinel delivers world writeable files and directories
    # Agreed to set sticky bit only.
    _DIRS=( "/var/.slm" "/var/.slmauth" "/var/.slmbackup" )

    for _DIR in "${_DIRS[@]}"
    do
        if [ -d $_DIR ]; then
            chmod +t -R $_DIR
        fi
    done
    /usr/bin/systemctl enable sentinel.service 1> /dev/null
    /usr/bin/systemctl start sentinel.service 1> /dev/null


elif [ $1 -eq 2 ]; then
    # When Sentinel is upgraded to newer version restart Sentinel Server
    # to load new binaries.
    remove_demo_licences
    /usr/bin/systemctl status sentinel.service 1> /dev/null
    if [ $? -eq 0 ]; then
        /usr/bin/systemctl stop sentinel.service
        /usr/bin/systemctl start sentinel.service
    else
        systemctl daemon-reload
        /usr/bin/systemctl restart sentinel.service
    fi
fi

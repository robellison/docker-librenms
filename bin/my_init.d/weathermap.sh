#!/bin/bash
#
# Installs network weathermap if it isn't in /opt/librenms/html and schedules
# it in cron.d
#

HTMLDIR='/opt/librenms/html'
WEATHERMAP="$HTMLDIR/weathermap"
C='*/5 *     * * *   root    /opt/librenms/html/weathermap/map-poller.php >> /dev/null 2>&1'

# Check env for cue to enable
if [ "$USE_WEATHERMAP" = true ]; then

    # If weathermap isn't in librenms htmldir, install it
    if [ ! -d "$WEATHERMAP" ]; then
        cd $HTMLDIR
        #git clone https://github.com/exoscale/php-weathermap weathermap
        chown -hR nobody:users "$WEATHERMAP"
    fi

    # Regardless, schedule map-poller.php
    echo "$C" > /etc/cron.d/weathermap
    /etc/init.d/cron restart

fi

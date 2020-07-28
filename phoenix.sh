#!/bin/sh
#
# phoenix.sh — Restart the dumb Apache Directory Service as needed 😡
#
# This script runs an LDAP query and if it fails with exit code 254 (time
# out?) it'll restart Apache DS on the host edrn-ds.jpl.nasa.gov
#
# Note this still isn't totally secure since we have to pass the password on
# the command line to `ldapsearch` (and its `-W` option doesn't read from
# `stdin` but from `/dev/tty`)


PATH=/usr/local/bin:/usr/bin:/bin
export PATH

passwords="$HOME/.secrets/passwords.sh"
server="ldaps://edrn-ds.jpl.nasa.gov"
manager="uid=admin,ou=system"
frequency=1
wait=1
ldapsearch_exit_timeout=254
ldapsearch_other_error=255


edrn_ldap_manager_password=${EDRN_LDAP_MANAGER_PASSWORD:-secret}
jpl_kelly_password=${JPL_PASSWORD:-secret}

if [ "$edrn_ldap_manager_password" = "secret" ]; then
    [ -f "$passwords" ] && . "$passwords"
fi


# Sudo Password
# -------------
#
# First, create a temporary program that we can use for sudo's ASKPASS. We'll
# make it executable and arrange for it to be deleted on exit later.

askpass=`mktemp`
cat > $askpass <<EOF
#!/bin/sh
echo "$jpl_kelly_password"
exit 0
EOF
chmod 700 $askpass


# LDAP Options
# ------------
#
# We need a specific set of options for use with `ldapsearch`, so make a
# temporary config file. I tried specifying these with the the `-o` option
# to `ldapsearch` but it refused virtually any combination of case, under-
# scores, etc. 🤷‍♀️
#
# This'll also be deleted on exit.

ldaprc=`mktemp`
cat > $ldaprc << EOF
NETWORK_TIMEOUT $wait
TIMELIMIT $wait
TIMEOUT $wait
EOF


# Cleanup Prep
# ------------
#
# Get rid of our generated files on exit.

trap "rm -f $askpass $ldaprc" EXIT


# Here we go
# ----------
#
# Every `$frequency` seconds, try

while :; do
    # Check health
    env LDAPCONF=$ldaprc LDAPTLS_REQCERT=never ldapsearch \
        -A -l $wait -b uid=admin,ou=system -s sub -D $manager \
        -H ldaps://edrn-ds.jpl.nasa.gov -w "$edrn_ldap_manager_password" \
        -x '(uid=admin)' uid >/dev/null
    rc=$?

    # Timeout?
    if [ $rc -eq $ldapsearch_exit_timeout -o $rc -eq $ldapsearch_other_error ]; then
        # Yes, restart it
        env SUDO_ASKPASS=$askpass sudo --askpass /etc/init.d/apacheds restart
        if [ $? -ne 0 ]; then
            echo "💥 Failed to restart Apache DS; giving up" 1>&2
            exit 2
        fi
        # It can take a long time for ApacheDS to come back. It's Java.
        sleep 30
    elif [ $rc -ne 0 ]; then
        # No, some other error, abort
        echo "💣 Apache DS query got unexpected result $rc; giving up" 1>&2
        exit 1
    fi

    # So far so good, wait and try again
    sleep $frequency
done

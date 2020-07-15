#!/bin/sh -e
#
# Back up our directory branches
# 
# This creates two timestamped files with backups of the EDRN and MCL
# directory branches in the EDRN directory service (which servies more
# than just EDRN, as you can see).
#
# The manager distinguished name for the directory is assumed to be
# ``uid=admin,ou=system``.  The password is passed as an environment variable
# $EDRN_LDAP_MANAGER_PASSWORD. You can preferentially create a
# ``~/.secrets/passwords.sh`` file and set a shell variable named
# edrn_ldap_manager_password there to set a password. Otherwise the password
# defaults to ``secret`` 😉
#
# Note this still isn't totally secure since we have to pass the password on
# the command line to ``ldapsearch`` (and its ``-W`` option doesn't read from
# ``stdin`` but from ``/dev/tty``)


# Setup
# -----

PATH=/usr/local/bin:/usr/bin:/bin
export PATH

passwords="$HOME/.secrets/passwords.sh"
server="ldaps://edrn-ds.jpl.nasa.gov"
manager="uid=admin,ou=system"
edrn_ldap_manager_password=${EDRN_LDAP_MANAGER_PASSWORD:-secret}
date=`date '+%Y-%m-%d'`

if [ "$edrn_ldap_manager_password" = "secret" ]; then
    [ -f "$passwords" ] && . "$passwords"
fi


# Do It
# -----
#
# Grab the two branches we're after.
#
#
# EDRN
# ~~~~
#
# First, EDRN. The query string grabs everything except the context entry
# dc=edrn,dc=jpl,dc=nasa,dc=gov. EDRN stands for Early Detection Research
# Network, by the way 😉

ldapsearch \
    -x \
    -w "$edrn_ldap_manager_password" \
    -H "$server" \
    -D "$manager" \
    -s "sub" \
    -b "dc=edrn,dc=jpl,dc=nasa,dc=gov" \
    '(&(objectClass=*)(!(dc=edrn)))' '*' '+' > "edrn-$date.ldif"


# MCL
# ~~~
#
# Next, MCL. As above, we avoid the context entry. By the way, MCL is the
# horrible acronym for the horribly long "Consortium for Molecular and
# Cellular Characterization of Screen-Detected Lesions" 🤢

ldapsearch \
    -x \
    -w "$edrn_ldap_manager_password" \
    -H "$server" \
    -D "$manager" \
    -s "sub" \
    -b "o=MCL" \
    '(&(objectClass=*)(!(o=MCL)))' '*' '+' > "mcl-$date.ldif"


# Done
# ----
#
# That's all folks 👋

exit 0

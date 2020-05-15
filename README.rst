****************************
 EDRN Directory (Utilities)
****************************

Here are some utilities for dealing with the EDRN Directory Service.


Notes
=====

The current one is at ``ldaps://edrn.jpl.nasa.gov`` but the new one will be at
``ldaps://edrn-ds.jpl.nasa.gov``


Features
========

The only feature right now is ``backup.sh``. It backs up to the current
directory, creating two files:

• ``edrn-DATE.ldif``, an LDIF file containing all the EDRN_ entries.
• ``mcl-DATE.ldif``, an LDIF file containing all the MCL_ entries.

The ``DATE`` is a ``YYYY-MM-DD`` timestamp for today.  You can load this into
a new LDAP server if you first clear out the existing EDRN and MCL entries
(leaving the empty context nodes ``dc=edrn,dc=jpl,dc=nasa,dc=gov`` and
``o=MCL`` entries).  LDAP command line utilties are woefully inadequate.
Let's hope you won't have to do this too often so we won't bother to audomate
it; just use ApacheDirectoryStudio_.

You can then add them back with::

    ldapadd -x -W -D uid=admin,ou=system -H ldaps://edrn-ds.jpl.nasa.gov -f edrn-DATE.ldif
    ldapadd -x -W -D uid=admin,ou=system -H ldaps://edrn-ds.jpl.nasa.gov -f mcl-DATE.ldif

Note that you might have to move parent nodes like ``ou=users,o=MCL`` to the
top of the files.


Installation
============

Nope.


Build
=====

Also nope.


Documentation
=============

Also also nope 😅


Translations
============

Are you kidding? 🤣


Contribute
==========

• Issue Tracker: https://github.com/EDRN/edrn.dir/issues
• Source Code: https://github.com/EDRN/edrn.dir
• Wiki: https://github.com/EDRN/edrn.dir/wiki


Support
=======

If you are having issues, please let us know.  You can reach us at
``edrn-ic@jpl.nasa.gov``.


License
=======

The project is licensed under the Apache License, version 2. See the
LICENSE.txt file for details.


.. Copyright © 2020 California Institute of Technology ("Caltech").
   ALL RIGHTS RESERVED. U.S. Government sponsorship acknowledged.

.. _EDRN: https://edrn.nci.nih.gov/
.. _MCL: https://mcl.nci.nih.gov/
.. _ApacheDirectoryStudio: https://directory.apache.org/studio/

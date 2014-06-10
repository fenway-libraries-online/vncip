INSTALLATION
============

This file summarizes the installation and configuration process for vncip, an
NCIP version 1 responder for the Voyager ILS.


PRELIMINARIES
-------------

*   Assumptions

    If any of these assumptions is false, do not try to install the software!

    There is a "voyager" user and its home directory is located at
    /home/voyager.

    You are able to run programs as the superuser ("root").  Note that the
    install scripts drop privileges ("become voyager") to do most things.

    The Voyager software itself is installed under the directory /m1 (it's OK
    if this is a symlink to /exlibris/m1).

*   About the install process

    The installation portion proper (installing prerequisites and the vncip
    software itself) is done in a long series of small steps.  If a step fails,
    the installation script may be safely run again; any completed steps will be
    skipped.

*   What is installed, and where?

    * The Z Shell (zsh), in /bin.
    * Several small Perl scripts and shell scripts, in /home/voyager/bin.
    * A bunch of supporting Perl modules, in /home/voyager/lib/perl5lib.
    * The main vncip code itself, in /usr/local/vncip.
    * A few data files, in /var/local/vncip.


INSTRUCTIONS
------------

The following commands must be run as the root user.

*   Download and untar the vncip-$VERSION.tar.gz file:

        [You've probably already done this!]
        mkdir -p /usr/local/src
        cd /usr/local/src
        sudo -u voyager wget http://prospero.flo.org/sw/vncip-x.xx.tar.gz
        sudo -u voyager tar -xzf vncip-x.xx.tar.gz
        cd vncip-x.xx/

*   Install all prerequisites and the vncip software itself:

        make install

*   Check the environment to make sure nothing is unexpectedly missing:

        make check

*   Configure vncip:

        make config

*   If everything went according to plan, you may now start the NCIP responder:

        make run



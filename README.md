# Automation for building slurm packages at the Hutch

This make file will create debian packages with Hutch customizations, including the plugins we use for setting default account and QOS.

To use, first set these variables to the appropriate values.  These numbers match the tags used by SchedMD.  For Slurm tag "slurm-17-11-3-2" set:

    export major=17
    export minor=11
    export sub=3
    export rel=2

The next environment variable sets the local release version- if we have to make further changes to the packaging files, etc.

    export local_rel=1

Finally set the distribution name:

    export distribution=trusty

Then simply `make deb`.

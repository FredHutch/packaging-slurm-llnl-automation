# Set these environment variables according to the 
# release you want to make
# major=17
# minor=02
# sub=8
# rel=1
# local_rel=1
# distribution=trusty

tld=$(major).$(minor).$(sub)-$(rel)
srcdir=slurm-llnl_$(major).$(minor).$(sub)

orig=$(srcdir).orig
slurm_repo=/home/mrg/Work/Build/slurm-wlm/schedmd-slurm.git
slurm_tag=slurm-$(major)-$(minor)-$(sub)-$(rel)
deb_repo=git@github.com:atombaby/packaging-slurm-llnl.git
deb_tag=$(major).$(minor).$(sub)_$(rel)fhcrc$(local_rel)_$(distribution)

$(tld):
	mkdir $(tld)

source: $(tld)/$(srcdir)
$(tld)/$(srcdir): $(tld)
	cd $(tld) && git clone $(slurm_repo) $(srcdir)
	cd $(tld)/$(srcdir) && git checkout $(slurm_tag)

tarball: $(tld)/$(srcdir)/$(orig).tar.xz
$(tld)/$(srcdir)/$(orig).tar.xz: $(tld)
	cd $(tld) && tar \
		--exclude=debian \
		--exclude=.gitignore \
		--exclude=.git \
		-c -f $(orig).tar $(srcdir) 
	cd $(tld) && xz --force $(orig).tar 

packaging: $(tld)/$(srcdir)/debian
$(tld)/$(srcdir)/debian:
	cd $(tld)/$(srcdir) && git clone $(deb_repo) debian
	cd $(tld)/$(srcdir)/debian && git checkout $(deb_tag)
	cd $(tld)/$(srcdir)/debian && rm -rf .git .gitignore

plugins: $(tld)/$(srcdir)/src/plugins/job_submit/gizmo-plugins
$(tld)/$(srcdir)/src/plugins/job_submit/gizmo-plugins:
	cd $(tld)/$(srcdir)/src/plugins/job_submit && \
		curl -L https://github.com/atombaby/gizmo-plugins/archive/0.1.1.tar.gz | \
		tar xzf -
	cd $(tld)/$(srcdir)/src/plugins/job_submit && \
		mv gizmo-plugins-0.1.1 gizmo-plugins
	cd $(tld)/$(srcdir) && \
		patch --no-backup-if-mismatch < \
		src/plugins/job_submit/gizmo-plugins/configure.ac.patch && \
		rm src/plugins/job_submit/gizmo-plugins/configure.ac.patch
	cd $(tld)/$(srcdir) && \
		patch --no-backup-if-mismatch -p1 < \
		src/plugins/job_submit/gizmo-plugins/makefile.job_submit.patch && \
		rm src/plugins/job_submit/gizmo-plugins/makefile.job_submit.patch 

deb: $(tld)/$(srcdir) $(tld)/$(srcdir)/src/plugins/job_submit/gizmo-plugins $(tld)/$(srcdir)/debian $(tld)/$(srcdir)/$(orig).tar.xz 
	cd $(tld)/$(srcdir) && debuild -us -uc

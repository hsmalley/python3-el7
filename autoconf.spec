# To Build:
#
# sudo yum -y install rpmdevtools m4 && rpmdev-setuptree
# wget https://raw.github.com/hsmalley/rpm-autoconf/master/autoconf.spec -O ~/rpmbuild/SPECS/autoconf.spec
# wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz -O  ~/rpmbuild/SOURCES/autoconf-2.69.tar.gz
# rpmbuild -bb ~/rpmbuild/SPECS/autoconf.spec

Name:       autoconf
Version:    2.71
Release:    1
Summary:    Auto-Configuration of Source Code
Group:      Development/Tools
License:    GNU GPL
URL:        http://www.gnu.org/software/autoconf/
Source0:    http://ftp.gnu.org/gnu/autoconf/autoconf-%{version}.tar.gz
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildRequires: m4
BuildArch: noarch
Requires(post): /sbin/install-info
Requires(postun):   /sbin/install-info
Requires: m4

%description
Autoconf is an extensible package of M4 macros that produce shell scripts to automatically configure software source code packages. These scripts can adapt the packages to many kinds of UNIX-like systems without manual user intervention. Autoconf creates a configuration script for a package from a template file that lists the operating system features that the package can use, in the form of M4 macro calls.

%prep
%setup -q

%build
%configure --prefix=/usr
make

%install
rm -rf %{buildroot}
make install DESTDIR=%{buildroot}
rm -rf %{buildroot}%{_infodir}/dir

%clean
rm -rf %{buildroot}

%post
/sbin/install-info %{_infodir}/autoconf.info %{_infodir}/dir || :

%preun
if [ "$1" = 0 ]; then
/sbin/install-info --del %{_infodir}/autoconf.info %{_infodir}/dir || :
fi

%files
%defattr(-,root,root,-)
%doc AUTHORS COPYING ChangeLog NEWS README THANKS TODO
%exclude %{_infodir}/standards*
%{_bindir}/*
%{_datadir}/autoconf
%{_infodir}/*
%{_mandir}/*/*

%changelog

* Thu Nov 02 2023 Hugh Smalley 2.71-1
* Sat Aug 03 2013 Nathan Milford <nathan@milford.io> 2.69-2
- Minor cosmetic adjustments.
* Tue Mar 26 2013 Francis Reyes <ruckerz@gmail.com> 2.69-1
- New version
* Thu Dec 24 2009 Robert Xu <robxu9@gmail.com> 2.65-1
- New Upstream Version
- Created Real Filelist
- ***COMPARISON with major distributions***
* Tue Nov 17 2009 Robert Xu <robxu9@gmail.com> 2.63-1
- Created Initial Spec File.

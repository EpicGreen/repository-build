Name:           minmon
Version:        0.0.0
Release:        1%{?dist}
Summary:        Minimal monitoring and alarming tool for Linux with simple configuration and efficient performance.
License:        MIT AND Apache-2.0
Group:          System Tools
URL:            https://github.com/flo-at/minmon
Source0:        https://github.com/flo-at/minmon/releases/download/v%{version}/minmon-%{version}.tar.gz
BuildArch:      x86_64
BuildRequires:  cargo
BuildRequires:  gcc
Requires:       systemd

%description
MinMon is an opinionated minimal monitoring and alarming tool for Linux. It focuses on simplicity and efficiency without complex configurations or GUIs. It provides alerts based on system metrics and can be easily integrated into existing workflows.

%global debug_package %{nil}

%prep
%setup -q -n minmon-%{version}

%build
cargo build --release

%install
mkdir -p %{buildroot}/%{_bindir}
install -m 755 target/release/minmon %{buildroot}/%{_bindir}/minmon
mkdir -p %{buildroot}/%{_sysconfdir}/minmon
install -m 644 %{SOURCE0} %{buildroot}/%{_sysconfdir}/minmon/minmon.toml
mkdir -p %{buildroot}/usr/share/licenses/minmon
install -m 644 LICENSE-MIT %{buildroot}/usr/share/licenses/minmon/LICENSE-MIT
install -m 644 LICENSE-APACHE %{buildroot}/usr/share/licenses/minmon/LICENSE-APACHE
mkdir -p %{buildroot}/%{_unitdir}
install -m 644 systemd.minmon.service %{buildroot}/%{_unitdir}/minmon.service

%files
%{_bindir}/minmon
%config(noreplace) %{_sysconfdir}/minmon/minmon.toml
/usr/share/licenses/minmon/LICENSE-MIT
/usr/share/licenses/minmon/LICENSE-APACHE
%{_unitdir}/minmon.service

%changelog
* Sun Jun 29 2025 Ante de Baas <antedebaas@users.github.com> - 0.10.0-1
- Initial RPM release.

%maintainer Ante de Baas <antedebaas@users.github.com>
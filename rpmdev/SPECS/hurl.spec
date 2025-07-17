
Name:           hurl
Version:        6.1.1
Release:        1%{?dist}
Summary:        Hurl, run and test HTTP requests with plain text.
License:        Apache-2.0
Group:          Development Tools
URL:            https://github.com/Orange-OpenSource/hurl
Source0:        https://github.com/Orange-OpenSource/hurl/releases/download/v%{version}/hurl-v%{version}.tar.gz
BuildArch:      x86_64
BuildRequires:  cargo
BuildRequires:  gcc

%description
Hurl, run and test HTTP requests with plain text.

%global debug_package %{nil}

%prep
%setup -q -c

%build
cargo build --release

%install
mkdir -p %{buildroot}/%{_bindir}
install -m 755 target/release/hurl %{buildroot}/%{_bindir}/hurl
mkdir -p %{buildroot}/usr/share/licenses/hurl
install -m 644 LICENSE %{buildroot}/usr/share/licenses/hurl/LICENSE

%files
%{_bindir}/hurl
/usr/share/licenses/hurl/LICENSE

%changelog
* Sun Jun 29 2025 Ante de Baas <antedebaas@users.github.com> - 0.10.0-1
- Initial RPM release.

%maintainer Ante de Baas <antedebaas@users.github.com>
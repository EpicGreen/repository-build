Name:           bore
Version:        0.6.0
Release:        1%{?dist}
Summary:        Bore is a simple CLI tool for making tunnels to localhost.
License:        MIT
Group:          System Tools
URL:            https://github.com/ekzhang/bore
Source0:        https://github.com/ekzhang/bore/releases/download/v%{version}/bore-%{version}.tar.gz
BuildArch:      x86_64
BuildRequires:  cargo
BuildRequires:  gcc

%description
Bore is a modern, simple TCP tunnel in Rust that exposes local ports to a remote server, bypassing standard NAT connection firewalls. That's all it does: no more, and no less.

%global debug_package %{nil}

%prep
%setup -q -c

%build
cargo build --release

%install
mkdir -p %{buildroot}/%{_bindir}
install -m 755 target/release/bore %{buildroot}/%{_bindir}/bore
mkdir -p %{buildroot}/usr/share/licenses/bore
install -m 644 LICENSE %{buildroot}/usr/share/licenses/bore/LICENSE

%files
%{_bindir}/bore
/usr/share/licenses/bore/LICENSE

%changelog
* Sun Jun 29 2025 Ante de Baas <antedebaas@users.github.com> - 0.10.0-1
- Initial RPM release.

%maintainer Ante de Baas <antedebaas@users.github.com>
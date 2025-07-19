Name:           harper
Version:        0.0.0
Release:        1%{?dist}
Summary:        Offline, privacy-first grammar checker. Fast, open-source, Rust-powered
License:        Apache-2.0
Group:          System Tools
URL:            https://github.com/automattic/harper
Source0:        https://github.com/Automattic/harper/releases/download/v%{version}/harper-%{version}.tar.gz
BuildArch:      x86_64
BuildRequires:  cargo
BuildRequires:  gcc

%description
Hurl, run and test HTTP requests with plain text.

%global debug_package %{nil}

%prep
%setup -n harper-%{version}

%build
rustup run nightly cargo build --release

%install
mkdir -p %{buildroot}/%{_bindir}
install -m 755 target/release/harper-tree-sitter %{buildroot}/%{_bindir}/harper-tree-sitter
install -m 755 target/release/harper-stats %{buildroot}/%{_bindir}/harper-stats
install -m 755 target/release/harper-typst %{buildroot}/%{_bindir}/harper-typst
install -m 755 target/release/harper-html %{buildroot}/%{_bindir}/harper-html
install -m 755 target/release/harper-comments %{buildroot}/%{_bindir}/harper-comments
install -m 755 target/release/harper-literate-haskell %{buildroot}/%{_bindir}/harper-literate-haskell
install -m 755 target/release/harper-ls %{buildroot}/%{_bindir}/harper-ls
install -m 755 target/release/harper-wasm %{buildroot}/%{_bindir}/harper-wasm
install -m 755 target/release/harper-cli %{buildroot}/%{_bindir}/harper-cli

mkdir -p %{buildroot}/usr/share/licenses/harper
install -m 644 LICENSE %{buildroot}/usr/share/licenses/harper/LICENSE

%files
%{_bindir}/harper-tree-sitter
%{_bindir}/harper-stats
%{_bindir}/harper-typst
%{_bindir}/harper-html
%{_bindir}/harper-comments
%{_bindir}/harper-literate-haskell
%{_bindir}/harper-ls
%{_bindir}/harper-wasm
%{_bindir}/harper-cli
/usr/share/licenses/harper/LICENSE

%changelog
* Fri Jul 18 2025 Ante de Baas <antedebaas@users.github.com> - 0.51.0-1
- Initial RPM release.

%maintainer Ante de Baas <antedebaas@users.github.com>
#!/usr/bin/env bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/default.env"

if [ "$1" = '--buildall' ]; then
    for product in "${!PRODUCTS[@]}"; do
        echo "Building product: $product"
        "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/build.sh" "$product" "${@:2}"
        if [ $? -ne 0 ]; then
            echo "Build failed for product: $product"
            exit 1
        fi
    done
    exit 0
fi

if ! { [ "$#" -eq 1 ] || ( [ "$#" -eq 2 ] && [ "$2" = '--rebuild' ] ); }; then
    echo "Usage: $0 <product-name>"
    echo "Available products: ${!PRODUCTS[@]}"
    exit 1
fi

if [[ -z "${PRODUCTS[$1]}" ]]; then
    echo "Product '$1' not found in the products array."
    echo "Available products: ${!PRODUCTS[@]}"
    exit 1
fi

if ! command -v rpmbuild &> /dev/null
then
    echo "rpm-build could not be found, installing it."
    dnf -y -q install rpm-build
fi

if ! command -v rpmsign &> /dev/null
then
    echo "rpm-sign could not be found, installing it."
    dnf -y -q install rpm-sign
fi

if ! command -v createrepo &> /dev/null; then
    echo "createrepo could not be found, installing it."
    dnf -y -q install createrepo
fi

PRODUCT=$1
REPO=${PRODUCTS[$PRODUCT]}
DIST=$(grep -oP '^PLATFORM_ID="platform:?\K[^"]+' /etc/os-release)
BUILD_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$BUILD_DIR"
}
trap cleanup EXIT

LATEST_TAG=$(curl -s "https://api.github.com/repos/$REPO/tags" | grep -oP '"name": "\K(.*)(?=")' | head -n1)
if [ -z "$LATEST_TAG" ]; then
    echo "Failed to retrieve the latest release tag."
    exit 1
fi
echo "Latest release tag: $LATEST_TAG"
VERSION="${LATEST_TAG#v}"

SOURCE_TARBALL=$(curl -s "https://api.github.com/repos/$REPO/tags" | grep -oP '"tarball_url": "\K(.*)(?=")' | head -n1)
curl -L -o "$BUILD_DIR/SOURCES/${PRODUCT}-v${VERSION}.tar.gz" "$SOURCE_TARBALL"
if [ $? -eq 0 ]; then
    echo "Source download successfull."
else
    echo "Source download failed."
    exit 1
fi

if [ ! -f "SPECS/$PRODUCT.spec" ]; then
    echo "Spec file SPECS/$PRODUCT.spec does not exist."
    exit 1
fi

CURRENT_VERSION=$(grep -m1 '^Version:' "SPECS/$PRODUCT.spec" | awk '{print $2}')
if [ "$(printf '%s\n' "$CURRENT_VERSION" "$VERSION" | sort -V | head -n1)" = "$VERSION" ] && [ "$2" != '--rebuild' ]; then
    echo "Version $CURRENT_VERSION is greater or equal to ${VERSION}"
    exit 0
fi

mkdir -p $BUILD_DIR/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

RELEASE=$(grep -m1 '^Release:' "SPECS/$PRODUCT.spec" | awk '{print $2}' | sed 's/%{?dist}//')
ARCH=$(grep -m1 '^BuildArch:' "SPECS/$PRODUCT.spec" | awk '{print $2}')
echo "Building $PRODUCT version $VERSION rpm-release $RELEASE for architecture $ARCH"

sed -i "s/^Version:.*/Version:        $VERSION/" "SPECS/$PRODUCT.spec"
cp "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/SPECS/$PRODUCT.spec" "$BUILD_DIR/SPECS/"

cd "$BUILD_DIR"
rpmbuild -ba "SPECS/$PRODUCT.spec" --define "_topdir $(pwd)"
if [ $? -eq 0 ]; then
    echo "RPM built successfully."
else
    echo "RPM build failed."
    exit 1
fi

RPMFILENAME="${PRODUCT}-${VERSION}-${RELEASE}.${DIST}"

rpm --addsign ${BUILD_DIR}/RPMS/${ARCH}/$RPMFILENAME.${ARCH}.rpm
if [ $? -eq 0 ]; then
    echo "RPM signed successfully."
else
    echo "RPM signing failed."
    exit 1
fi

for EPEL_RELEASE in "${!EPELRELEASES[@]}"; do
    mkdir -p $REPO_DIR/${EPELRELEASES[$EPEL_RELEASE]}/{RELEASE,SOURCES}
done

cp ${BUILD_DIR}/RPMS/${ARCH}/$RPMFILENAME.${ARCH}.rpm ${REPO_DIR}/${DIST}/RELEASE/
cp ${BUILD_DIR}/SRPMS/$RPMFILENAME.src.rpm ${REPO_DIR}/${DIST}/SOURCES/

rpm -qpi ${REPO_DIR}/${DIST}/RELEASE/$RPMFILENAME.${ARCH}.rpm
rpm --checksig --verbose ${REPO_DIR}/${DIST}/RELEASE/$RPMFILENAME.${ARCH}.rpm

for EPEL_RELEASE in "${!EPELRELEASES[@]}"; do
    createrepo --update --database "$REPO_DIR/${EPELRELEASES[$EPEL_RELEASE]}/RELEASE"
    if [ $? -ne 0 ]; then
        echo "Failed to update RPM repository for EPEL release ${EPELRELEASES[$EPEL_RELEASE]}/RELEASE."
    fi
    echo "Repository for EPEL release ${EPELRELEASES[$EPEL_RELEASE]}/RELEASE created/updated successfully."

    createrepo --update --database "$REPO_DIR/${EPELRELEASES[$EPEL_RELEASE]}/SOURCES"
    if [ $? -ne 0 ]; then
        echo "Failed to update RPM repository for EPEL release ${EPELRELEASES[$EPEL_RELEASE]}/SOURCES."
    fi
    echo "Repository for EPEL release ${EPELRELEASES[$EPEL_RELEASE]}/SOURCES created/updated successfully."
done
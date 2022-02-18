#!/bin/bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "usage: make-deb.sh <VERSION> <ARCH>"
  exit 1
fi

VERSION=$1
ARCH=$2



ALL_VERSIONS=$(git ls-remote --tags --refs --sort="-v:refname" https://github.com/aws/aws-cli.git | sed -n 's/^.*refs\/tags\/\(2\..*\)$/\1/p')

if [ "$VERSION" == "latest" ]; then
  VERSION=$(echo "$ALL_VERSIONS" | head -n 1)
else
  # test if version exists
  if [[ ! $ALL_VERSIONS == *"$VERSION"* ]]; then
    echo "this version does not exist"
    exit 1
  fi
fi

case $ARCH in
  "amd64")
    FILENAME=awscli-exe-linux-x86_64-"$VERSION".zip
    ;;
  "arm64")
    FILENAME=awscli-exe-linux-aarch64-"$VERSION".zip
    ;;
  *)
    echo "unknown arch '$ARCH'"
    exit 1
  ;;
esac


TMPDIR=$(mktemp -d)

pushd "$TMPDIR"
wget --output-document=awscli2.zip https://awscli.amazonaws.com/$FILENAME

if [ ! -e "awscli2.zip" ]; then
  echo "unable to download $VERSION"
  exit 1
fi


mkdir awscli2
unzip -q awscli2.zip -d awscli2
rm awscli2.zip

DIST=$(realpath awscli2/*/dist)

mkdir DEBIAN

cat <<EOF >> DEBIAN/control
Package: awscli2
Version: $VERSION
Architecture: $ARCH
Maintainer: Tobias Salzmann
Installed-Size: 102841
Section: admin
Priority: optional
Homepage: https://github.com/Eun/deb-awscli2
Description: unofficial aws cli v2
EOF

cat <<EOF >> DEBIAN/postinst
#!/bin/sh
ln -s /usr/local/aws-cli/aws /usr/local/bin/aws
ln -s /usr/local/aws-cli/aws_completer /usr/local/bin/aws_completer
EOF
chmod +x DEBIAN/postinst

cat <<EOF >> DEBIAN/prerm
#!/bin/sh
rm /usr/local/bin/aws
rm /usr/local/bin/aws_completer
EOF
chmod +x DEBIAN/prerm

mkdir -p usr/local/
mv "$DIST" usr/local/aws-cli
rm -rf awscli2


wget --output-document=DEBIAN/changelog https://raw.githubusercontent.com/aws/aws-cli/"$VERSION"/CHANGELOG.rst

popd
dpkg-deb --build "$TMPDIR" .

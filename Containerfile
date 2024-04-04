# Multi-stage build
ARG FEDORA_MAJOR_VERSION=40

## Build ublue-os-base
FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}
# See https://pagure.io/releng/issue/11047 for final location

COPY --from=docker.io/mikefarah/yq /usr/bin/yq /usr/bin/yq

RUN bash <(curl -sSf https://raw.githubusercontent.com/bshephar/fedora-sb/main/nordvpn-install.sh)

RUN rpm-ostree override remove firefox firefox-langpacks && \
    rpm-ostree install 'gcc-c++' gcc glib glib2-static krb5-workstation libvirt lld make neovim pre-commit ripgrep zsh && \

    sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    systemctl enable flatpak-system-update.timer && \
	systemctl enable nordvpnd && \
    rm -rf \
        /tmp/* \
        /var/* && \
    ostree container commit


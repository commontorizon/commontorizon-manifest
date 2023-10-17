FROM commontorizon/crops:kirkstone

USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -q -y update && \
    apt-get -q -y install \
    universal-ctags \
    lsb-release && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sudo mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get -q -y update && \
    apt-get -q -y install \
    htop \
    sshpass \
    netcat \
    telnet \
    gcc-aarch64-linux-gnu \
    gdb-multiarch \
    libssl-dev \
    bc \
    bmap-tools \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install powershell
RUN apt-get -q -y update && \
    wget https://github.com/PowerShell/PowerShell/releases/download/v7.3.4/powershell_7.3.4-1.deb_amd64.deb && \
    apt-get -y install ./powershell_7.3.4-1.deb_amd64.deb && \
    rm -rf powershell_7.3.4-1.deb_amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# this works on debian
RUN groupadd -f docker && groupmod --non-unique --gid 998 docker && adduser usersetup docker

COPY profile.sh /usr/bin/bitbakes.sh
COPY profile.sh /usr/bin/startup-tdx.sh

# for the kgdb serial use
RUN chmod +x /usr/bin/bitbakes.sh && \
    chmod +x /usr/bin/startup-tdx.sh && \
    chsh -s /bin/bash usersetup && \
    adduser usersetup dialout

# for the wsl docker socket
RUN groupadd -g 1001 dockerwsl && usermod -aG dockerwsl usersetup

## ⚠️⚠️ WARNING: This is a security risk ⚠️⚠️
## This is only for development purposes and should never be used in production!
RUN echo "usersetup ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER usersetup

# configure a dummy git user
RUN git config --global user.email "common@torizon" && \
    git config --global user.name "Common Torizon"

CMD ["/bin/bash"]

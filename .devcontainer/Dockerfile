FROM matheuscastello/crops:kirkstone

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
    docker-ce docker-ce-cli containerd.io docker-compose-plugin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# this works on debian
RUN groupadd -f docker && groupmod --non-unique --gid 998 docker && adduser usersetup docker

COPY profile.sh /usr/bin/bitbakes.sh
RUN chmod +x /usr/bin/bitbakes.sh

USER usersetup

CMD ["/bin/bash"]

FROM ubuntu:bionic

ENV NODE_ENV development
ENV HOME /opt/app

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update -q && \
apt-get install -y --no-install-recommends apt-utils && \
apt-get install -yqq \
curl \
wget \
vim \
git \
nano \
psmisc \
gcc \
make \
zlib1g-dev \
libncurses5-dev \
libgdbm-dev \
libnss3-dev \
libssl-dev \
libreadline-dev \
libffi-dev \
build-essential \
sudo && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR ${HOME}
COPY ./.tool-versions ${HOME}/.tool-versions

RUN git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf
RUN cd ${HOME}/.asdf && git checkout "$(git describe --abbrev=0 --tags)" && cd ${HOME}

ENV BASH_ENV="${HOME}/.asdf/asdf.sh"
SHELL ["/usr/bin/env", "bash", "-c"]

RUN echo -e "\n. ${HOME}/.asdf/asdf.sh" >>${HOME}/.bashrc
RUN echo -e "\n. ${HOME}/.asdf/completions/asdf.bash" >>${HOME}/.bashrc

RUN cat .tool-versions | cut -f 1 -d ' ' | xargs -n 1 asdf plugin-add || true
RUN asdf plugin-update --all
RUN bash ${HOME}/.asdf/plugins/nodejs/bin/import-release-team-keyring
RUN asdf install
RUN asdf reshim

RUN bash -c "source ${HOME}/.bashrc"

COPY ./ ${HOME}

RUN yarn install --frozen-lockfile && \
yarn cache clean

RUN pip install -r requirements.txt && \
asdf reshim

EXPOSE 3000

CMD [ "bash", "-c", "node express" ]

# docker build -t test-asdf-docker .
# docker run -itd -p 3000:3000 test-asdf-docker


FROM ubuntu:focal AS base
WORKDIR /usr/local/bin
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y software-properties-common curl git build-essential sudo && \
  apt-add-repository -y ppa:ansible/ansible && \
  apt-get update && \
  apt-get install -y curl git ansible build-essential && \
  apt-get clean autoclean && \
  apt-get autoremove --yes

FROM base AS prime
ARG TAGS

RUN addgroup --gid 1000 kodizen
RUN adduser --gecos kodizen --uid 1000 --gid 1000 --disabled-password kodizen
RUN usermod -aG sudo kodizen
RUN echo "kodizen ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir -p /home/kodizen/.ssh && \
  chmod 700 /home/kodizen/.ssh

WORKDIR /home/kodizen

FROM prime
COPY . .

RUN chown -R kodizen:kodizen /home/kodizen

USER kodizen
CMD ["sh", "-c", "ansible-playbook $TAGS local.yml"]

FROM --platform=linux/amd64 ubuntu:20.04

ENV WORKDIR="/home/user"

ARG CLIENT_ID=""
ARG CLIENT_SECRET=""
ARG API_BASE_URL=""

USER root

# Hack
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Not entirely necessary yet it doesn't harm
RUN apt-get clean autoclean && apt-get autoremove --yes
# Apt update + package installations
RUN apt-get update && apt-get install -y gettext-base curl

# Copy CrowdStrike deb package
COPY deb/crowdstrike-cs-falconhoseclient_2.18.0_amd64.deb "${WORKDIR}/crowdstrike.deb"
RUN dpkg -i "${WORKDIR}/crowdstrike.deb"

# Create output + enroll file
RUN touch /var/log/crowdstrike/falconhoseclient/output
RUN touch /var/log/crowdstrike/falconhoseclient/enroll

# Prepare a simple user instead of root
RUN groupadd -g 1000 user && useradd -r -u 1000 -g user user
RUN chown -R user:user /var/log/crowdstrike/falconhoseclient
RUN chmod -R 755 /var/log/crowdstrike/falconhoseclient
RUN chown -R user:user /opt/crowdstrike/etc

WORKDIR "${WORKDIR}"

# Copy entrypoint
COPY entrypoint.sh "${WORKDIR}"
RUN chmod +x "${WORKDIR}/entrypoint.sh"

# Link the binary executables to /usr/bin
RUN ln -s /opt/crowdstrike/bin/cs.falconhoseclient /usr/bin/cs.falconhoseclient
RUN ln -s "${WORKDIR}/entrypoint.sh" /usr/bin/falconhoseclient

# Copy CrowdStrike configuration file
COPY cfg/cs.falconhoseclient.cfg.template "${WORKDIR}"

# Environment setup (if defined the values are used in the entrypoint)
COPY .env "${WORKDIR}"

# Install required certificates
# This step is not always required but it certainly avoids some problems
RUN curl -s -o /etc/ssl/certs/DigiCertHighAssuranceEVRootCA.crt https://www.digicert.com/CACerts/DigiCertHighAssuranceEVRootCA.crt
RUN curl -s -o /etc/ssl/certs/DigiCertAssuredIDRootCA.crt https://dl.cacerts.digicert.com/DigiCertAssuredIDRootCA.crt

# Change owner of workdir
RUN chown -R user:user "${WORKDIR}"

# Change to user
USER user

ENV PATH="${WORKDIR}:${PATH}"

ENTRYPOINT [ "falconhoseclient" ]

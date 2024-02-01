FROM --platform=linux/amd64 ubuntu:20.04

ARG FALCON_CFG="cs.falconhoseclient.cfg"

USER root

# Hack
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Apt stuff
RUN apt-get update && apt-get install -y gettext-base curl

# Prepare a simple user instead of root
RUN groupadd -r user && useradd -r -g user user
RUN mkdir -p /var/log/crowdstrike/falconhoseclient
RUN chown -R user:user /var/log/crowdstrike/falconhoseclient
RUN chmod -R 755 /var/log/crowdstrike/falconhoseclient

WORKDIR /home/user

# CrowdStrike deb package
COPY deb/crowdstrike-cs-falconhoseclient_2.18.0_amd64.deb ./crowdstrike.deb
RUN dpkg -i ./crowdstrike.deb

# Entrypoint
COPY entrypoint.sh .
RUN chmod +x ./entrypoint.sh

# CrowdStrike configuration file
COPY cfg/${FALCON_CFG}.template .

# Environment setup
COPY .env .
RUN export $(grep -v '^#' .env | xargs) && envsubst < ./${FALCON_CFG}.template > ./${FALCON_CFG}

# Move the final configuration to the proper location
RUN mv ./${FALCON_CFG} /opt/crowdstrike/etc

# Install required certificates
# This step is not always required but we had problems
RUN curl -s -o /etc/ssl/certs/DigiCertHighAssuranceEVRootCA.crt https://www.digicert.com/CACerts/DigiCertHighAssuranceEVRootCA.crt
RUN curl -s -o /etc/ssl/certs/DigiCertAssuredIDRootCA.crt https://dl.cacerts.digicert.com/DigiCertAssuredIDRootCA.crt

# Change to user
USER user

ENTRYPOINT [ "./entrypoint.sh" ]

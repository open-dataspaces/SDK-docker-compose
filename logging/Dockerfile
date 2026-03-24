FROM fluent/fluentd:v1.19.1-debian-2.1

# Run as root because the default user (fluent) cannot execute the following commands
USER root

# Copy the SSL certificate into the container
# COPY ./cert-file/cert.cer /usr/local/share/ca-certificates/cert.crt

# Install the updated certificate
# RUN update-ca-certificates

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential ruby-dev \
  && gem install fluent-plugin-s3 --no-document \
  && apt-get purge -y --auto-remove build-essential ruby-dev \
  && rm -rf /var/lib/apt/lists/*

USER fluent

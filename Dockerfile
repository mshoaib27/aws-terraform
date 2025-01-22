# Use an official Alpine image as a base
FROM alpine:3.21.0

# Install necessary tools
RUN apk add --no-cache \
    bash \
    jq \
    aws-cli \
    gcc \
    musl-dev \
    libffi-dev \
    postgresql-client \
    postgresql \
    git \
    bind-tools \
    wget \
    unzip \
    libc6-compat

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip && \
    unzip terraform_1.0.0_linux_amd64.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform  && \
    rm -rf terraform_1.0.0_linux_amd64.zip

# Verify installation
RUN terraform -v

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/sh"]

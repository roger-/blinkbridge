# Use the Python Alpine image
FROM python:alpine

# Install necessary packages
RUN apk add --no-cache \
    ffmpeg \
    wget \
    tar \
    ca-certificates \
    && pip install --upgrade pip \
    && pip install rich blinkpy aiohttp

# Install MediaMTX
RUN MEDIAMTX_VERSION=v1.8.5 && \
    ARCH=$(uname -m) && \
    case ${ARCH} in \
        x86_64) MEDIAMTX_ARCH="amd64" ;; \
        aarch64) MEDIAMTX_ARCH="arm64v8" ;; \
        armv7l) MEDIAMTX_ARCH="armv7" ;; \
        *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
    esac && \
    wget -O /tmp/mediamtx.tar.gz \
        "https://github.com/bluenviron/mediamtx/releases/download/${MEDIAMTX_VERSION}/mediamtx_${MEDIAMTX_VERSION}_linux_${MEDIAMTX_ARCH}.tar.gz" && \
    tar -xzf /tmp/mediamtx.tar.gz -C /tmp && \
    mv /tmp/mediamtx /usr/local/bin/mediamtx && \
    chmod +x /usr/local/bin/mediamtx && \
    rm -rf /tmp/mediamtx.tar.gz /tmp/mediamtx.yml

# Add Intel hardware acceleration support for ffmpeg
# RUN apk add --no-cache \
#     libva-intel-driver \
#     intel-media-driver

# Add blinkbridge source
COPY blinkbridge /app/blinkbridge

# Copy startup script
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the working directory
WORKDIR /app/

# Expose RTSP port
EXPOSE 8554

# Set the entry point to the startup script
ENTRYPOINT ["/entrypoint.sh"]

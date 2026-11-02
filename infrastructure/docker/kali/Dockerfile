FROM kasmweb/kali-rolling-desktop:1.15.0

USER root

ENV DEBIAN_FRONTEND=noninteractive

COPY setup.sh /usr/local/sbin/kali-setup.sh

RUN chmod 0755 /usr/local/sbin/kali-setup.sh \
    && /usr/local/sbin/kali-setup.sh \
    && rm -f /usr/local/sbin/kali-setup.sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Preserva a inicialização original da imagem Kasm.
# Não definir ENTRYPOINT ou CMD aqui.

ENV HOME=/home/kasm-user
WORKDIR /home/kasm-user

USER 1000:1000

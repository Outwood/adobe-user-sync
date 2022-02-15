FROM python:3.10-alpine AS build

RUN apk add --no-cache curl

# user-sync deps
RUN apk add --no-cache \
  dbus-dev \
  gcc \
  glib-dev \
  krb5-conf \
  krb5-dev \
  libffi-dev \
  make \
  musl-dev \
  openssl-dev

RUN curl -L https://github.com/adobe-apiplatform/user-sync.py/archive/refs/tags/v2.7.0.tar.gz | \
  tar -xz && \
  mv user-sync.py-2.7.0 /opt/app

WORKDIR /opt/app
RUN pip install ./external/okta-0.0.3.1-py2.py3-none-any.whl && \
  pip install ./sign_client && \
  pip install -e . && \
  pip install -e .[test] && \
  pip install -e .[setup]
RUN make

FROM alpine
COPY --from=build /opt/app/dist/user-sync /bin/user-sync
ENTRYPOINT ["/bin/user-sync"]
CMD ["--help"]

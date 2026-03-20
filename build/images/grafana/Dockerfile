ARG BASE_IMAGE

FROM ${BASE_IMAGE}

COPY plugins /data/plugins
COPY css/grafana.dark.6839ffb2aed352838f3a.css /usr/share/grafana/public/build/
COPY css/grafana.light.6839ffb2aed352838f3a.css /usr/share/grafana/public/build/

EXPOSE 3000

ENTRYPOINT ["grafana-server"]

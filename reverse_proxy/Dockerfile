FROM nginx:1.21.4-alpine
CMD sh -c 'envsubst \
  "\$REWIND_HOST \$WORKBENCH_HOST \$HISTORY_HOST \$GRAFANA_HOST \$PROMETHEUS_HOST \$HTTP_PORT" \
  < /etc/nginx/templates/nginx.conf \
  > /etc/nginx/nginx.conf \
  && nginx -g "daemon off;"'

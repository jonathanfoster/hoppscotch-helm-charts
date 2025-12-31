{{/*
Return the Redis URL based on the Redis chart or external Redis settings
*/}}
{{- define "hoppscotch.secret.redisUrl" -}}
  {{- if .Values.redis.enabled -}}
    {{- $namespace := include "hoppscotch.namespace" . -}}
    {{- $host := printf "%s-redis-master.%s.svc.%s" .Release.Name $namespace .Values.clusterDomain -}}
    {{- $port := 6379 -}}
    {{- $password := .Values.redis.auth.password -}}
    {{- if not $password -}}
      {{- $redisSecretName := printf "%s-redis" .Release.Name -}}
      {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" $redisSecretName "namespace" $namespace "key" "redis-password") -}}
    {{- end -}}
    {{- include "hoppscotch.secret.formatRedisUrl" (dict "host" $host "port" $port "password" $password) -}}
  {{- else -}}
    {{- $host := .Values.externalRedis.host -}}
    {{- $port := .Values.externalRedis.port | default 6379 | int -}}
    {{- $password := .Values.externalRedis.password -}}
    {{- if and (not $password) .Values.externalRedis.existingSecret -}}
      {{- $namespace := include "hoppscotch.namespace" . -}}
      {{- $secretKey := .Values.externalRedis.existingSecretPasswordKey | default "password" -}}
      {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" .Values.externalRedis.existingSecret "namespace" $namespace "key" $secretKey) -}}
    {{- end -}}
    {{- include "hoppscotch.secret.formatRedisUrl" (dict "host" $host "port" $port "password" $password) -}}
  {{- end -}}
{{- end -}}

{{/*
Format a Redis URL for use in configuration files.
Usage: {{- include "hoppscotch.secret.formatRedisUrl" (dict "host" $host "port" $port "password" $password) -}}
*/}}
{{- define "hoppscotch.secret.formatRedisUrl" -}}
  {{- $authspec := "" -}}
  {{- $hostspec := .host -}}
  {{- if .password -}}
    {{- $authspec = printf ":%s@" .password -}}
  {{- end -}}
  {{- if .port -}}
    {{- $hostspec = printf "%s:%d" .host .port -}}
  {{- end -}}
  {{- printf "redis://%s%s" $authspec $hostspec -}}
{{- end -}}

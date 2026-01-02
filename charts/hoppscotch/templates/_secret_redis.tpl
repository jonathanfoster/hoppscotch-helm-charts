{{/*
Return the Redis URL based on the Redis chart or external Redis settings
*/}}
{{- define "hoppscotch.secret.redisUrl" -}}
  {{- $defaultPort := 6379 -}}
  {{- $defaultSecretKey := "redis-password" -}}
  {{- $namespace := include "hoppscotch.namespace" . -}}
  {{- if .Values.redis.enabled -}}
    {{- $host := printf "%s-redis-master.%s.svc.%s" .Release.Name $namespace .Values.clusterDomain -}}
    {{- $password := .Values.redis.auth.password -}}
    {{- if not $password -}}
      {{- if .Values.redis.auth.existingSecret -}}
        {{- $secretKey := .Values.redis.auth.existingSecretPasswordKey | default $defaultSecretKey -}}
        {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" .Values.redis.auth.existingSecret "namespace" $namespace "key" $secretKey) -}}
      {{- else -}}
        {{- $secretName := printf "%s-redis" .Release.Name -}}
        {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" $secretName "namespace" $namespace "key" $defaultSecretKey) -}}
      {{- end -}}
    {{- end -}}
    {{- include "hoppscotch.secret.formatRedisUrl" (dict "host" $host "port" $defaultPort "password" $password) -}}
  {{- else -}}
    {{- $host := .Values.externalRedis.host -}}
    {{- $port := .Values.externalRedis.port | default $defaultPort | int -}}
    {{- $password := .Values.externalRedis.password -}}
    {{- if and (not $password) .Values.externalRedis.existingSecret -}}
      {{- $secretKey := .Values.externalRedis.existingSecretPasswordKey | default $defaultSecretKey -}}
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

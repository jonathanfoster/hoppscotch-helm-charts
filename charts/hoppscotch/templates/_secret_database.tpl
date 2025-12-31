{{/*
Return the database URL based on the PostgreSQL chart or external database settings
*/}}
{{- define "hoppscotch.secret.databaseUrl" -}}
  {{- if .Values.postgresql.enabled -}}
    {{- $namespace := include "hoppscotch.namespace" . -}}
    {{- $host := printf "%s-postgresql.%s.svc.%s" .Release.Name $namespace .Values.clusterDomain -}}
    {{- $port := 5432 -}}
    {{- $user := .Values.postgresql.auth.username -}}
    {{- $database := .Values.postgresql.auth.database -}}
    {{- $password := .Values.postgresql.auth.password -}}
    {{- if not $password -}}
      {{- $postgresSecretName := printf "%s-postgresql" .Release.Name -}}
      {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" $postgresSecretName "namespace" $namespace "key" "password") -}}
    {{- end -}}
    {{- include "hoppscotch.secret.formatPostgresUrl" (dict "host" $host "port" $port "user" $user "password" $password "database" $database) -}}
  {{- else if .Values.externalDatabase.sqlConnection -}}
    {{- .Values.externalDatabase.sqlConnection -}}
  {{- else -}}
    {{- $host := .Values.externalDatabase.host -}}
    {{- $port := .Values.externalDatabase.port | default 5432 | int -}}
    {{- $user := .Values.externalDatabase.user -}}
    {{- $database := .Values.externalDatabase.database -}}
    {{- $password := .Values.externalDatabase.password -}}
    {{- if and (not $password) .Values.externalDatabase.existingSecret -}}
      {{- $namespace := include "hoppscotch.namespace" . -}}
      {{- $secretKey := .Values.externalDatabase.existingSecretPasswordKey | default "password" -}}
      {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" .Values.externalDatabase.existingSecret "namespace" $namespace "key" $secretKey) -}}
    {{- end -}}
    {{- include "hoppscotch.secret.formatPostgresUrl" (dict "host" $host "port" $port "user" $user "password" $password "database" $database) -}}
  {{- end -}}
{{- end -}}

{{/*
Format a database URL for use in configuration files.
Usage: {{- include "hoppscotch.secret.formatPostgresUrl" (dict "host" $host "port" $port "user" $user "password" $password "database" $database "params" $params) -}}
*/}}
{{- define "hoppscotch.secret.formatPostgresUrl" -}}
  {{- $userspec := "" -}}
  {{- $hostspec := .host -}}
  {{- $dbname := "" -}}
  {{- $paramspec := "" -}}
  {{- if and .user .password -}}
    {{- $userspec = printf "%s:%s@" .user .password -}}
  {{- else if .user -}}
    {{- $userspec = printf "%s@" .user -}}
  {{- end -}}
  {{- if .port -}}
    {{- $hostspec = printf "%s:%d" .host .port -}}
  {{- end -}}
  {{- if .database -}}
    {{- $dbname = printf "/%s" .database -}}
  {{- end -}}
  {{- if .params -}}
    {{- $paramspec = printf "?%s" .params -}}
  {{- end -}}
  {{- printf "postgres://%s%s%s%s" $userspec $hostspec $dbname $paramspec -}}
{{- end -}}

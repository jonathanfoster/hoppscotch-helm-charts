{{/*
Return the database URL based on the PostgreSQL chart or external database settings.
*/}}
{{- define "hoppscotch.secret.databaseUrl" -}}
  {{- $defaultPort := 5432 -}}
  {{- $defaultSecretKey := "password" -}}
  {{- $namespace := include "hoppscotch.namespace" . -}}
  {{- if .Values.postgresql.enabled -}}
    {{- $host := printf "%s-postgresql.%s.svc.%s" .Release.Name $namespace .Values.clusterDomain -}}
    {{- $user := .Values.postgresql.auth.username -}}
    {{- $database := .Values.postgresql.auth.database -}}
    {{- $password := .Values.postgresql.auth.password -}}
    {{- if not $password -}}
      {{- if .Values.postgresql.auth.existingSecret -}}
        {{- $secretKey := .Values.postgresql.auth.secretKeys.userPasswordKey | default $defaultSecretKey -}}
        {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" .Values.postgresql.auth.existingSecret "namespace" $namespace "key" $secretKey) -}}
      {{- else -}}
        {{- $secretName := printf "%s-postgresql" .Release.Name -}}
        {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" $secretName "namespace" $namespace "key" $defaultSecretKey) -}}
      {{- end -}}
    {{- end -}}
    {{- include "hoppscotch.secret.formatPostgresUrl" (dict "host" $host "port" $defaultPort "user" $user "password" $password "database" $database) -}}
  {{- else if .Values.externalDatabase.sqlConnection -}}
    {{- .Values.externalDatabase.sqlConnection -}}
  {{- else if and .Values.externalDatabase.existingSecret .Values.externalDatabase.existingSecretSqlConnectionKey -}}
    {{- include "hoppscotch.secret.lookupValue" (dict "name" .Values.externalDatabase.existingSecret "namespace" $namespace "key" .Values.externalDatabase.existingSecretSqlConnectionKey) -}}
  {{- else -}}
    {{- $host := .Values.externalDatabase.host -}}
    {{- $port := .Values.externalDatabase.port | default $defaultPort | int -}}
    {{- $user := .Values.externalDatabase.user -}}
    {{- $database := .Values.externalDatabase.database -}}
    {{- $password := .Values.externalDatabase.password -}}
    {{- if and (not $password) .Values.externalDatabase.existingSecret -}}
      {{- $secretKey := .Values.externalDatabase.existingSecretPasswordKey | default $defaultSecretKey -}}
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

{{/*
Return the ClickHouse host based on the ClickHouse chart or external ClickHouse settings
*/}}
{{- define "hoppscotch.secret.clickhouseHost" -}}
  {{- $defaultPort := 8123 -}}
  {{- if .Values.clickhouse.enabled -}}
    {{- $namespace := include "hoppscotch.namespace" . -}}
    {{- printf "%s-clickhouse.%s.svc.%s:%d" .Release.Name $namespace .Values.clusterDomain $defaultPort -}}
  {{- else if .Values.externalClickhouse.host -}}
    {{- $port := .Values.externalClickhouse.port | default $defaultPort | int -}}
    {{- printf "%s:%d" .Values.externalClickhouse.host $port -}}
  {{- end -}}
{{- end -}}

{{/*
Return the ClickHouse password based on the ClickHouse chart or external ClickHouse settings
*/}}
{{- define "hoppscotch.secret.clickhousePassword" -}}
  {{- $namespace := include "hoppscotch.namespace" . -}}
  {{- if .Values.clickhouse.enabled -}}
    {{- $password := .Values.clickhouse.auth.password -}}
    {{- if not $password -}}
      {{- $secretName := .Values.clickhouse.auth.existingSecret | default (printf "%s-clickhouse" .Release.Name) -}}
      {{- $secretKey := .Values.clickhouse.auth.existingSecretKey | default "admin-password" -}}
      {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" $secretName "namespace" $namespace "key" $secretKey) -}}
    {{- end -}}
    {{- $password -}}
  {{- else -}}
    {{- $password := .Values.externalClickhouse.password -}}
    {{- if and (not $password) .Values.externalClickhouse.existingSecret -}}
      {{- $secretKey := .Values.externalClickhouse.existingSecretPasswordKey | default "password" -}}
      {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" .Values.externalClickhouse.existingSecret "namespace" $namespace "key" $secretKey) -}}
    {{- end -}}
  {{- $password -}}
  {{- end -}}
{{- end -}}

{{/*
Return the ClickHouse user based on the ClickHouse chart or external ClickHouse settings
*/}}
{{- define "hoppscotch.secret.clickhouseUser" -}}
  {{- if .Values.clickhouse.enabled -}}
    {{- .Values.clickhouse.auth.username -}}
  {{- else -}}
    {{- .Values.externalClickhouse.user -}}
  {{- end -}}
{{- end -}}

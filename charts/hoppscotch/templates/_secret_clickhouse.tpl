{{/*
Return the ClickHouse host based on the ClickHouse chart or external ClickHouse settings
*/}}
{{- define "hoppscotch.secret.clickhouseHost" -}}
  {{- if .Values.clickhouse.enabled -}}
    {{- printf "%s-clickhouse.%s.svc.%s:8123" .Release.Name (include "hoppscotch.namespace" .) .Values.clusterDomain -}}
  {{- else if .Values.externalClickhouse.host -}}
    {{- printf "%s:%d" .Values.externalClickhouse.host (.Values.externalClickhouse.port | int) -}}
  {{- else -}}
    {{- "" -}}
  {{- end -}}
{{- end -}}

{{/*
Return the ClickHouse password based on the ClickHouse chart or external ClickHouse settings
*/}}
{{- define "hoppscotch.secret.clickhousePassword" -}}
  {{- if .Values.clickhouse.enabled -}}
    {{- $password := .Values.clickhouse.auth.password -}}
    {{- if not $password -}}
      {{- $namespace := include "hoppscotch.namespace" . -}}
      {{- $clickhouseSecretName := printf "%s-clickhouse" .Release.Name -}}
      {{- $password = include "hoppscotch.secret.lookupValue" (dict "name" $clickhouseSecretName "namespace" $namespace "key" "admin-password") -}}
    {{- end -}}
    {{- $password -}}
  {{- else -}}
    {{- $password := .Values.externalClickhouse.password -}}
    {{- if and (not $password) .Values.externalClickhouse.existingSecret -}}
      {{- $namespace := include "hoppscotch.namespace" . -}}
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

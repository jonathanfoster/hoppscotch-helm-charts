{{/*
Return the secret name to use for environment variables.
*/}}
{{- define "hoppscotch.secretName" -}}
  {{- if .Values.existingSecret -}}
    {{- .Values.existingSecret -}}
  {{- else -}}
    {{- include "hoppscotch.fullname" . -}}
  {{- end -}}
{{- end -}}

{{/*
Generate a secure data encryption key that persists across upgrades
*/}}
{{- define "hoppscotch.secret.dataEncryptionKey" -}}
  {{- $secretName := include "hoppscotch.fullname" . -}}
  {{- $existingSecret := include "hoppscotch.secret.lookupValue" (dict "namespace" .Release.Namespace "name" $secretName "key" "DATA_ENCRYPTION_KEY") -}}
  {{- if $existingSecret -}}
    {{- $existingSecret -}}
  {{- else if .Values.hoppscotch.backend.dataEncryptionKey -}}
    {{- .Values.hoppscotch.backend.dataEncryptionKey -}}
  {{- else -}}
    {{- randAlphaNum 32 -}}
  {{- end -}}
{{- end -}}

{{/*
Generate a secure JWT secret that persists across upgrades
*/}}
{{- define "hoppscotch.secret.jwtSecret" -}}
  {{- $secretName := include "hoppscotch.fullname" . -}}
  {{- $existingSecret := include "hoppscotch.secret.lookupValue" (dict "namespace" .Release.Namespace "name" $secretName "key" "JWT_SECRET") -}}
  {{- if $existingSecret -}}
    {{- $existingSecret -}}
  {{- else if .Values.hoppscotch.backend.authToken.jwtSecret -}}
    {{- .Values.hoppscotch.backend.authToken.jwtSecret -}}
  {{- else -}}
    {{- randAlphaNum 64 -}}
  {{- end -}}
{{- end -}}

{{/*
Return the value of a secret key. An empty string is returned if the key is not found.
Usage: {{- include "hoppscotch.secret.lookupValue" (dict "name" "my-secret" "namespace" "my-namespace" "key" "my-key") -}}
*/}}
{{- define "hoppscotch.secret.lookupValue" -}}
  {{- $secret := (lookup "v1" "Secret" .namespace .name) -}}
  {{- if and $secret $secret.data (hasKey $secret.data .key) -}}
    {{- index $secret.data .key | b64dec | trimAll "\n" -}}
  {{- end -}}
{{- end }}

{{/*
Generate a secure session secret that persists across upgrades
*/}}
{{- define "hoppscotch.secret.sessionSecret" -}}
  {{- $secretName := include "hoppscotch.fullname" . -}}
  {{- $existingSecret := include "hoppscotch.secret.lookupValue" (dict "namespace" .Release.Namespace "name" $secretName "key" "SESSION_SECRET") -}}
  {{- if $existingSecret -}}
    {{- $existingSecret -}}
  {{- else if .Values.hoppscotch.backend.authToken.sessionSecret -}}
    {{- .Values.hoppscotch.backend.authToken.sessionSecret -}}
  {{- else -}}
    {{- randAlphaNum 64 -}}
  {{- end -}}
{{- end -}}

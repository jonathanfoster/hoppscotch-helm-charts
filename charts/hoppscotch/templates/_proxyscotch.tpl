{{/*
Proxyscotch resource name.
*/}}
{{- define "hoppscotch.proxyscotch.name" -}}
  {{- printf "%s-proxyscotch" (include "hoppscotch.fullname" .) -}}
{{- end -}}


{{/*
Proxyscotch component name.
*/}}
{{- define "hoppscotch.proxyscotch.component" -}}
  {{- printf "proxyscotch" -}}
{{- end -}}

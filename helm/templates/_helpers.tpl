{{- define "data-platform.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "data-platform.namespace" -}}
{{ .Values.global.namespace | default .Release.Namespace }}
{{- end }}

{{- define "data-platform.labels" -}}
app.kubernetes.io/name: {{ include "data-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

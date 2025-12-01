{{/* NAME HELPERS */}}
{{- define "data-platform.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "data-platform.fullname" -}}
{{ printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "data-platform.namespace" -}}
{{ default .Release.Namespace .Values.global.namespace }}
{{- end }}

{{/* LABEL HELPERS */}}
{{- define "data-platform.labels" -}}
app.kubernetes.io/name: {{ include "data-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

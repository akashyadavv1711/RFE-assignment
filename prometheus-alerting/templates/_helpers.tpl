{{/*
Expand the name of the chart.
*/}}
{{- define "prometheus-alerting.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "prometheus-alerting.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "prometheus-alerting.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "prometheus-alerting.labels" -}}
helm.sh/chart: {{ include "prometheus-alerting.chart" . }}
{{ include "prometheus-alerting.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "prometheus-alerting.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prometheus-alerting.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Prometheus labels
*/}}
{{- define "prometheus-alerting.prometheus.labels" -}}
{{ include "prometheus-alerting.labels" . }}
app.kubernetes.io/component: prometheus
{{- end }}

{{/*
Prometheus selector labels
*/}}
{{- define "prometheus-alerting.prometheus.selectorLabels" -}}
app: prometheus
{{ include "prometheus-alerting.selectorLabels" . }}
{{- end }}

{{/*
AlertManager labels
*/}}
{{- define "prometheus-alerting.alertmanager.labels" -}}
{{ include "prometheus-alerting.labels" . }}
app.kubernetes.io/component: alertmanager
{{- end }}

{{/*
AlertManager selector labels
*/}}
{{- define "prometheus-alerting.alertmanager.selectorLabels" -}}
app: alertmanager
{{ include "prometheus-alerting.selectorLabels" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "prometheus-alerting.serviceAccountName" -}}
{{- if .Values.prometheus.serviceAccount.create }}
{{- default (include "prometheus-alerting.fullname" .) .Values.prometheus.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.prometheus.serviceAccount.name }}
{{- end }}
{{- end }}
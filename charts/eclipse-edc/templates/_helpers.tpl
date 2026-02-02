{{/*
Expand the name of the chart.
*/}}
{{- define "eclipse-edc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "eclipse-edc.fullname" -}}
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
{{- define "eclipse-edc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "eclipse-edc.labels" -}}
helm.sh/chart: {{ include "eclipse-edc.chart" . }}
{{ include "eclipse-edc.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "eclipse-edc.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eclipse-edc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "eclipse-edc.serviceAccountName" -}}
{{- if .Values.connector.serviceAccount.create }}
{{- default (include "eclipse-edc.fullname" .) .Values.connector.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.connector.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Connector image
*/}}
{{- define "eclipse-edc.image" -}}
{{- $tag := default .Chart.AppVersion .Values.connector.image.tag }}
{{- printf "%s:%s" .Values.connector.image.repository $tag }}
{{- end }}

{{/*
DSP callback address
*/}}
{{- define "eclipse-edc.dspCallbackAddress" -}}
{{- if .Values.connector.config.hostname }}
{{- printf "https://%s/protocol" .Values.connector.config.hostname }}
{{- else }}
{{- printf "http://%s:%d/protocol" (include "eclipse-edc.fullname" .) (int .Values.connector.ports.protocol) }}
{{- end }}
{{- end }}

{{/*
Data plane public base URL
*/}}
{{- define "eclipse-edc.publicBaseUrl" -}}
{{- if .Values.connector.config.hostname }}
{{- printf "https://%s/public" .Values.connector.config.hostname }}
{{- else }}
{{- printf "http://%s:%d/public" (include "eclipse-edc.fullname" .) (int .Values.connector.ports.public) }}
{{- end }}
{{- end }}

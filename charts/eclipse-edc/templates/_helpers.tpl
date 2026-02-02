{{/*
Expand the name of the chart.
*/}}
{{- define "eclipse-edc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
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
Control Plane fullname
*/}}
{{- define "eclipse-edc.controlplane.fullname" -}}
{{- printf "%s-controlplane" (include "eclipse-edc.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Control Plane labels
*/}}
{{- define "eclipse-edc.controlplane.labels" -}}
{{ include "eclipse-edc.labels" . }}
app.kubernetes.io/component: controlplane
{{- end }}

{{/*
Control Plane selector labels
*/}}
{{- define "eclipse-edc.controlplane.selectorLabels" -}}
{{ include "eclipse-edc.selectorLabels" . }}
app.kubernetes.io/component: controlplane
{{- end }}

{{/*
Data Plane fullname
*/}}
{{- define "eclipse-edc.dataplane.fullname" -}}
{{- printf "%s-dataplane" (include "eclipse-edc.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Data Plane labels
*/}}
{{- define "eclipse-edc.dataplane.labels" -}}
{{ include "eclipse-edc.labels" . }}
app.kubernetes.io/component: dataplane
{{- end }}

{{/*
Data Plane selector labels
*/}}
{{- define "eclipse-edc.dataplane.selectorLabels" -}}
{{ include "eclipse-edc.selectorLabels" . }}
app.kubernetes.io/component: dataplane
{{- end }}

{{/*
Create the name of the service account to use for control plane
*/}}
{{- define "eclipse-edc.controlplane.serviceAccountName" -}}
{{- if .Values.controlPlane.serviceAccount.create }}
{{- default (include "eclipse-edc.controlplane.fullname" .) .Values.controlPlane.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.controlPlane.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use for data plane
*/}}
{{- define "eclipse-edc.dataplane.serviceAccountName" -}}
{{- if .Values.dataPlane.serviceAccount.create }}
{{- default (include "eclipse-edc.dataplane.fullname" .) .Values.dataPlane.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.dataPlane.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Control Plane image
*/}}
{{- define "eclipse-edc.controlplane.image" -}}
{{- $tag := default .Chart.AppVersion .Values.controlPlane.image.tag }}
{{- printf "%s:%s" .Values.controlPlane.image.repository $tag }}
{{- end }}

{{/*
Data Plane image
*/}}
{{- define "eclipse-edc.dataplane.image" -}}
{{- $tag := default .Chart.AppVersion .Values.dataPlane.image.tag }}
{{- printf "%s:%s" .Values.dataPlane.image.repository $tag }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "eclipse-edc.postgresql.host" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" (include "eclipse-edc.fullname" .) }}
{{- else }}
{{- .Values.postgresql.external.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "eclipse-edc.postgresql.port" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.primary.service.ports.postgresql | default 5432 }}
{{- else }}
{{- .Values.postgresql.external.port | default 5432 }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database
*/}}
{{- define "eclipse-edc.postgresql.database" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database | default "edc" }}
{{- else }}
{{- .Values.postgresql.external.database | default "edc" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL JDBC URL
*/}}
{{- define "eclipse-edc.postgresql.jdbcUrl" -}}
{{- printf "jdbc:postgresql://%s:%s/%s" (include "eclipse-edc.postgresql.host" .) (include "eclipse-edc.postgresql.port" . | toString) (include "eclipse-edc.postgresql.database" .) }}
{{- end }}

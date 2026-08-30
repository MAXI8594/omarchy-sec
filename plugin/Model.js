.pragma library

/**
 * Returns formatted status string based on agent and manager health
 */
function deriveStatus(agentActive, managerActive) {
  if (agentActive && managerActive) return "Protegido (EDR Activo)";
  if (agentActive && !managerActive) return "Agente Activo (Manager Desconectado)";
  if (!agentActive && managerActive) return "Agente Detenido (Alerta EDR)";
  return "Desprotegido (Servicios Inactivos)";
}

/**
 * Maps severity number to color
 */
function severityColor(level, successColor, warningColor, urgentColor) {
  if (level >= 10) return urgentColor || "#ef4444";
  if (level >= 7) return warningColor || "#eab308";
  return successColor || "#22c55e";
}

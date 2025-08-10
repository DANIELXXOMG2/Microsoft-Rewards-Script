#!/usr/bin/env bash
set -euo pipefail

# Monitor en Bash para Microsoft Rewards Script
# Uso:
#   ./monitor.sh [accion] [dias]
# Acciones:
#   status   -> muestra estado del contenedor y resumen diario (por defecto)
#   logs     -> muestra los últimos 50 logs del contenedor
#   start    -> inicia el contenedor con docker compose
#   restart  -> reinicia el contenedor con docker compose
#   help     -> muestra esta ayuda
# Opcional:
#   dias     -> (solo para status) cantidad de días hacia atrás para el resumen (por defecto 7)

CONTAINER_NAME="microsoft-rewards-script"
LOG_DIR="./logs"
JSON_LOG="$LOG_DIR/execution_log.json"
NDJSON_LOG="$LOG_DIR/execution_log.ndjson"
ACTION="${1:-status}"
DAYS_BACK="${2:-7}"
EXPECTED_DAILY_RUNS="${EXPECTED_DAILY_RUNS:-2}"

# Colores simples
c_red="\033[31m"; c_green="\033[32m"; c_yellow="\033[33m"; c_cyan="\033[36m"; c_gray="\033[90m"; c_reset="\033[0m"

print_help() {
  echo -e "${c_cyan}Monitor Bash - Microsoft Rewards Script${c_reset}"
  echo "Uso: $0 [status|logs|start|restart|help] [dias]"
  echo "Ejemplos:"
  echo "  $0 status 7"
  echo "  $0 logs"
  echo "  $0 start"
  echo "  $0 restart"
}

show_status() {
  echo -e "${c_cyan}\n🔍 ESTADO DEL MICROSOFT REWARDS SCRIPT${c_reset}"
  echo -e "${c_gray}============================================================${c_reset}"

  # Estado del contenedor
  if docker ps --filter "name=$CONTAINER_NAME" --format 'table {{.Names}}\t{{.Status}}\t{{.RunningFor}}' | grep -q "$CONTAINER_NAME"; then
    echo -e "${c_green}📦 ESTADO DEL CONTENEDOR:${c_reset}"
    docker ps --filter "name=$CONTAINER_NAME" --format 'table {{.Names}}\t{{.Status}}\t{{.RunningFor}}'
  else
    echo -e "${c_red}❌ El contenedor no está ejecutándose${c_reset}"
  fi

  # Resumen de ejecuciones
  echo -e "${c_cyan}\n📊 RESUMEN DE EJECUCIONES DIARIAS (últimos $DAYS_BACK días)${c_reset}"
  echo -e "${c_gray}============================================================${c_reset}"

  if [ -f "$NDJSON_LOG" ]; then
    # NDJSON: una entrada JSON por línea
    for i in $(seq 0 $((DAYS_BACK-1))); do
      day=$(date -d "-$i day" +%Y-%m-%d 2>/dev/null || date -v -"$i"d +%Y-%m-%d)
      count=$(grep -F "\"timestamp\":\"$day" "$NDJSON_LOG" 2>/dev/null | grep -c '"type":"EXECUTION_SUCCESS"' || true)
      if [ -z "$count" ]; then count=0; fi
      status="❌ FALTANTE"; color="$c_red"
      if [ "$count" -ge "$EXPECTED_DAILY_RUNS" ]; then status="✅ COMPLETO"; color="$c_green"; fi
      if [ "$count" -gt 0 ] && [ "$count" -lt "$EXPECTED_DAILY_RUNS" ]; then status="⚠️  PARCIAL"; color="$c_yellow"; fi
      echo -e "${color}📅 $day | Ejecuciones: $count/$EXPECTED_DAILY_RUNS | $status${c_reset}"
    done
  elif [ -f "$JSON_LOG" ]; then
    # JSON (array bonito): usar grep simple por fecha y tipo
    for i in $(seq 0 $((DAYS_BACK-1))); do
      day=$(date -d "-$i day" +%Y-%m-%d 2>/dev/null || date -v -"$i"d +%Y-%m-%d)
      # Contar líneas que contengan la fecha y luego el tipo de éxito en las siguientes líneas
      # Aproximación: filtrar bloques con fecha y éxitos
      count=$(awk -v d="$day" 'BEGIN{c=0} /"timestamp"/ && $0 ~ d {inblk=1} inblk && /"type"\s*:\s*"EXECUTION_SUCCESS"/ {c++ ; inblk=0} END{print c}' "$JSON_LOG" 2>/dev/null)
      if [ -z "$count" ]; then count=0; fi
      status="❌ FALTANTE"; color="$c_red"
      if [ "$count" -ge "$EXPECTED_DAILY_RUNS" ]; then status="✅ COMPLETO"; color="$c_green"; fi
      if [ "$count" -gt 0 ] && [ "$count" -lt "$EXPECTED_DAILY_RUNS" ]; then status="⚠️  PARCIAL"; color="$c_yellow"; fi
      echo -e "${color}📅 $day | Ejecuciones: $count/$EXPECTED_DAILY_RUNS | $status${c_reset}"
    done
  else
    echo -e "${c_yellow}⚠️  No se encontró archivo de log en $LOG_DIR (ni NDJSON ni JSON).${c_reset}"
  fi

  # Consejos de uso
  echo -e "${c_cyan}\n💡 COMANDOS ÚTILES:${c_reset}"
  echo -e "${c_gray}  ./monitor.sh status 7    # Ver estado y resumen últimos 7 días${c_reset}"
  echo -e "${c_gray}  ./monitor.sh logs         # Ver últimos 50 logs del contenedor${c_reset}"
  echo -e "${c_gray}  ./monitor.sh start        # Iniciar contenedor${c_reset}"
  echo -e "${c_gray}  ./monitor.sh restart      # Reiniciar contenedor${c_reset}"
}

show_container_logs() {
  echo -e "${c_cyan}\n📋 LOGS DEL CONTENEDOR (últimas 50 líneas)${c_reset}"
  echo -e "${c_gray}============================================================${c_reset}"
  if docker ps --filter "name=$CONTAINER_NAME" --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
    docker logs --tail 50 "$CONTAINER_NAME" || true
  else
    echo -e "${c_red}❌ El contenedor no está ejecutándose${c_reset}"
  fi
}

start_container() {
  echo -e "${c_yellow}\n🚀 INICIANDO CONTENEDOR...${c_reset}"
  docker compose up -d
  echo -e "${c_green}✅ Contenedor iniciado exitosamente${c_reset}"
}

restart_container() {
  echo -e "${c_yellow}\n🔄 REINICIANDO CONTENEDOR...${c_reset}"
  docker compose restart
  echo -e "${c_green}✅ Contenedor reiniciado exitosamente${c_reset}"
}

case "$ACTION" in
  status)   show_status ;;
  logs)     show_container_logs ;;
  start)    start_container ; show_status ;;
  restart)  restart_container ; show_status ;;
  help|-h|--help) print_help ;;
  *) echo -e "${c_red}Acción no válida: $ACTION${c_reset}"; print_help; exit 1 ;;
 esac
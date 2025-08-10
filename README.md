# Microsoft-Rewards-Script
Script automatizado para Microsoft Rewards, esta vez usando TypeScript, Cheerio y Playwright.

¡En desarrollo, pero principalmente para uso personal!

## Cómo Instalar ##
1. Descarga o clona el código fuente.
2. Ejecuta `npm i` para instalar los paquetes.
3. Renombra `accounts.example.jsonc` a `accounts.jsonc` y añade los datos de tu cuenta.
4. Modifica `config.jsonc` a tu gusto.
5. Ejecuta `npm run build` para compilar el script.
6. Ejecuta `npm run start` para iniciar el script compilado.

## Notas ##
- Si finalizas el script sin cerrar primero la ventana del navegador (solo con `headless` en `false`), quedarán instancias de Chrome consumiendo recursos. Usa el administrador de tareas para cerrarlas o utiliza el script incluido `npm run kill-chrome-win`. (Windows)
- Si automatizas este script, configúralo para que se ejecute al menos 2 veces al día para asegurarte de que recoge todas las tareas. Establece `"runOnZeroPoints": false` para que no se ejecute si no se encuentran puntos.

## Docker (Experimental) ##
### **Antes de Empezar**

- Si has compilado y ejecutado previamente el script de forma local, **elimina** las carpetas `/node_modules` y `/dist` de tu directorio `Microsoft-Rewards-Script`.
- Si has usado Docker con una versión anterior del script (p. ej., 1.4), **elimina** cualquier archivo `config.jsonc` y carpetas de sesión guardadas de forma persistente. Los archivos `accounts.jsonc` antiguos pueden ser reutilizados.

### **Configurar los Archivos Fuente**

1. **Descarga el Código Fuente**

2. **Actualiza `accounts.jsonc`**

3. **Edita `config.jsonc`,** asegurándote de que los siguientes valores estén establecidos (otras configuraciones son a tu preferencia):

   ```json
   "headless": true,
   "clusters": 1,
   ```

### **Personalizar el Archivo `compose.yaml`**

Se proporciona un archivo `compose.yaml` básico. Sigue estos pasos para configurar y ejecutar el contenedor:

1. **Establece tu Zona Horaria:** Ajusta la variable `TZ` para asegurar una programación correcta.
2. **Configura el Almacenamiento Persistente:**
   - Mapea `config.jsonc` y `accounts.jsonc` para conservar la configuración y las cuentas.
   - (Opcional) Usa una carpeta de `sessions` persistente para guardar las sesiones de inicio de sesión.
3. **Personaliza la Programación:**
   - Modifica `CRON_SCHEDULE` para establecer los tiempos de ejecución. Usa [crontab.guru](https://crontab.guru) para obtener ayuda.
   - **Nota:** El contenedor añade una variabilidad aleatoria de 5 a 50 minutos a cada hora de inicio programada.
4. **(Opcional) Ejecutar al Iniciar:**
   - Establece `RUN_ON_START=true` para ejecutar el script inmediatamente cuando el contenedor se inicie.
5. **Inicia el Contenedor:** Ejecuta `docker compose up -d` para construir y lanzar.
6. **Monitoriza los Logs:** Usa `docker logs microsoft-rewards-script` para ver la ejecución del script y para obtener los códigos de inicio de sesión 'sin contraseña'.


## Configuración ## 
| Opción        | Descripción           | Por Defecto  |
| :------------- |:-------------| :-----|
|  baseURL    | Página de MS Rewards | `https://rewards.bing.com` |
|  sessionPath    | Ruta donde quieres que se guarden las sesiones/huellas digitales | `sessions` (En ./browser/sessions) |
|  headless    | Si la ventana del navegador debe ser visible o ejecutarse en segundo plano | `false` (El navegador es visible) |
|  parallel    | Si quieres que las tareas de escritorio y móvil se ejecuten en paralelo o secuencialmente| `true` |
|  runOnZeroPoints    | Ejecutar el resto del script si se pueden ganar 0 puntos | `false` (No se ejecutará con 0 puntos) |
|  clusters    | Cantidad de instancias ejecutadas al inicio, 1 por cuenta | `1` (Se ejecutará 1 cuenta a la vez) |
|  saveFingerprint.mobile    | Reutilizar la misma huella digital cada vez | `false` (Generará una nueva huella cada vez) |
|  saveFingerprint.desktop    | Reutilizar la misma huella digital cada vez | `false` (Generará una nueva huella cada vez) |
|  workers.doDailySet    | Completar las tareas del set diario | `true`  |
|  workers.doMorePromotions    | Completar los artículos promocionales | `true`  |
|  workers.doPunchCards    | Completar las tarjetas perforadas | `true`  |
|  workers.doDesktopSearch    | Completar las búsquedas diarias de escritorio | `true`  |
|  workers.doMobileSearch    | Completar las búsquedas diarias de móvil | `true`  |
|  workers.doDailyCheckIn    | Completar la actividad de check-in diario | `true`  |
|  workers.doReadToEarn    | Completar la actividad de leer para ganar | `true`  |
|  searchOnBingLocalQueries    | Completar la actividad "buscar en Bing" usando `queries.json` o el obtenido de este repo | `false` (Lo obtendrá de este repo)   |
|  globalTimeout    | El tiempo antes de que la acción se agote | `30s`   |
|  searchSettings.useGeoLocaleQueries    | Generar consultas de búsqueda basadas en tu geolocalización | `false` (Usa consultas generadas para EN-US)  |
|  searchSettings.scrollRandomResults    | Desplazarse aleatoriamente en los resultados de búsqueda | `true`   |
|  searchSettings.clickRandomResults    | Visitar un sitio web aleatorio de los resultados de búsqueda| `true`   |
|  searchSettings.searchDelay    | Tiempo mínimo y máximo en milisegundos entre consultas de búsqueda | `min: 3min`    `max: 5min` |
|  searchSettings.retryMobileSearchAmount     | Seguir reintentando las búsquedas móviles la cantidad especificada de veces | `2` |
|  logExcludeFunc | Funciones a excluir de los logs y webhooks | `SEARCH-CLOSE-TABS` |
|  webhookLogExcludeFunc | Funciones a excluir de los logs de webhooks | `SEARCH-CLOSE-TABS` |
|  proxy.proxyGoogleTrends     | Habilitar o deshabilitar el proxy para la solicitud a través del proxy configurado | `true` (será enviado por proxy) |
|  proxy.proxyBingTerms     | Habilitar o deshabilitar el proxy para la solicitud a través del proxy configurado | `true` (será enviado por proxy) |
|  webhook.enabled     | Habilitar o deshabilitar tu webhook configurado | `false` |
|  webhook.url     | La URL de tu webhook de Discord | `null` |

## Características ##
- [x] Soporte Multi-Cuenta
- [x] Almacenamiento de Sesión
- [x] Soporte 2FA
- [x] Soporte sin Contraseña
- [x] Soporte Headless (sin interfaz gráfica)
- [x] Soporte para Webhook de Discord
- [x] Búsquedas de Escritorio
- [x] Tareas Configurables
- [x] Búsquedas en Microsoft Edge
- [x] Búsquedas Móviles
- [x] Soporte de Desplazamiento Emulado
- [x] Soporte de Clic en Enlaces Emulado
- [x] Consultas de Búsqueda por Geolocalización
- [x] Completar Set Diario
- [x] Completar Más Promociones
- [x] Resolver Cuestionarios (variante de 10 puntos)
- [x] Resolver Cuestionarios (variante de 30-40 puntos)
- [x] Completar Recompensas por Clic
- [x] Completar Encuestas
- [x] Completar Tarjetas Perforadas
- [x] Resolver Cuestionario "Esto o Aquello" (Aleatorio)
- [x] Resolver Cuestionario ABC
- [x] Completar Check-in Diario
- [x] Completar "Leer para Ganar"
- [x] Soporte de Clustering
- [x] Soporte de Proxy
- [x] Soporte de Docker (experimental)
- [x] Programación Automática (vía Docker)

## Descargo de Responsabilidad ##
¡Tu cuenta puede estar en riesgo de ser baneada o suspendida al usar este script, has sido advertido!
<br /> 
¡Usa este script bajo tu propio riesgo!

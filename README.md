# Velódromo-623
Este proyecto implementa un sistema para el control y monitoreo de un velódromo digital, desarrollado en lenguaje ensamblador para microcontroladores HCS12/68HC12.

El sistema permite:
- Detectar eventos mediante sensores y botones
- Calcular velocidad de un ciclista
- Mostrar información en:
  - LCD
  - Displays de 7 segmentos multiplexados
  - LEDs indicadores
  - Controlar un relé al finalizar un ciclo
- Gestionar múltiples tareas mediante máquinas de estados y timers

## Características principales

### Hardware utilizado
- Microcontrolador HCS12 / 68HC12
- Pantalla LCD
- Display multiplexado de 7 segmentos
- Teclado matricial
- LEDs indicadores
- Relé
- Convertidor ATD (ADC)
- Push buttons PB1 y PB2

### Arquitectura del sistema
El programa está organizado mediante:
- Máquinas de estados
- Timers por software
- Rutinas de interrupción
- Subrutinas reutilizables

### Modos de operación
El sistema cuenta con 4 modos principales:

| Modo | Descripción |
|------|-------------|
| Espera | Estado inicial del sistema |
| Configurar | Permite ingresar el número de vueltas |
| Correr | Ejecuta el monitoreo y cálculo de velocidad |
| Resumen | Muestra estadísticas finales |

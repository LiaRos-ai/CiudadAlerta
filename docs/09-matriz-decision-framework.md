# 09 · Matriz de decisión ponderada del framework — CiudadAlerta

> Artefacto del **Día 2 · Sprint 1 · Hito 1**. Evidencia evaluada con la
> **Matriz 1** (20 pts) del sistema de evaluación del curso.
> Plantilla editable para los 4 proyectos paralelos: `matriz_decision/plantilla_matriz_decision.xlsx`.

## 1. Qué es una matriz de decisión ponderada

Es una herramienta de análisis que convierte una decisión técnica subjetiva
("¿qué framework uso?") en un proceso comparable y defendible:

1. **Criterios**: qué aspectos importan para el proyecto (rendimiento, costo, curva de aprendizaje…).
2. **Peso (%)**: cuánto importa cada criterio; la suma de pesos = 100 %.
3. **Puntaje (1–5)**: qué tan bien cumple cada framework ese criterio.
4. **Puntaje ponderado** = Σ (peso/100 × puntaje) por framework; se elige el mayor.

La matriz no decide sola: **justifica** la decisión con datos y criterios explícitos.
En los proyectos paralelos los equipos definen sus propios criterios y pesos,
comparando **al menos 3 frameworks**, y los defienden en el Informe 1.

## 2. Matriz del docente — Proyecto Guía CiudadAlerta (ejemplo completo)

Criterios y pesos tomados de la Propuesta Tecnológica del plan de la asignatura.
Puntajes 1 (pésimo) a 5 (excelente).

| Criterio | Peso % | Flutter | React Native + Expo | Ionic + Capacitor | .NET MAUI | Kotlin nativo |
|---|---|---|---|---|---|---|
| Curva de aprendizaje con base en POO (Programación III) | 20 | 4 | 4 | 4 | 3 | 3 |
| Tiempo de instalación y configuración en laboratorio | 15 | 3 | 5 | 4 | 2 | 2 |
| Rendimiento y consistencia visual entre dispositivos | 10 | 5 | 4 | 3 | 4 | 5 |
| Ecosistema, comunidad y empleabilidad regional | 15 | 4 | 5 | 3 | 2 | 4 |
| Cobertura de contenidos del programa (BD, APIs, SDK, distribución) | 15 | 5 | 5 | 5 | 4 | 4 |
| Costo y licencias | 10 | 5 | 5 | 5 | 4 | 5 |
| Distribución Android + iOS sin requerir Mac | 10 | 2 | 5 | 3 | 2 | 1 |
| Afinidad con la bibliografía del programa | 5 | 2 | 3 | 5 | 4 | 5 |
| **Puntaje ponderado (sobre 5)** | **100** | **3,90** | **4,60** | **3,95** | **3,00** | **3,45** |
| **Posición** | | **3** | **1** | **2** | **5** | **4** |

### Lectura de la matriz (transparencia docente)

- Con los pesos por defecto, **React Native gana por margen estrecho** (4,60 vs 3,95 y 3,90):
  instala más rápido (Expo Go) y domina la empleabilidad regional.
- La **decisión del docente es Flutter** y se asume de forma explícita como criterio
  adicional del curso: con los pesos por defecto Flutter queda 3.º, pero cubre
  100 % del programa (BD, APIs de Google y AWS, distribución), su motor de renderizado
  propio (Impeller) da consistencia visual total entre dispositivos, y Dart —tipado y
  orientado a objetos, muy cercano a Java/C#— nivela la curva de aprendizaje el Día 3.
- Moraleja metodológica: **los pesos definen el ganador**. Por eso cada equipo debe
  justificar SUS pesos según SU proyecto, no copiar la matriz del docente.

## 3. Guía para completar la matriz de tu proyecto paralelo

1. Copia `matriz_decision/plantilla_matriz_decision.xlsx` en tu equipo.
2. Definan **5 a 8 criterios propios** ligados a su problema (p. ej. MoviPaz:
   rendimiento de mapas; SaludCerca: accesibilidad y notificaciones;
   EmprendeLocal: costos; CulturaAndina: modo sin conexión).
3. Asignen pesos que sumen 100 % y justifiquen cada peso en una línea.
4. Comparen **al menos 3 frameworks** (se sugiere Flutter, React Native e Ionic).
5. Escriban la justificación final (½ página) en el Informe 1: decisión + 3 razones
   + 1 implicación (qué NO podrán hacer fácil con ese framework).
6. Suban el archivo y el MD a su repositorio en `docs/` con commit `docs: matriz de
   decisión del framework`.

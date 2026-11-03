# 7 · Convenciones de Git y GitHub — CiudadAlerta

> Referencia rápida para el Día 1 (repositorio y tablero) y para todo el curso.
> Complementa la Guía Práctica de la Clase 1.

## 1. Flujo de ramas (GitFlow simplificado)

```
main        ← siempre estable, con releases (v0.1, v0.2, ...)
 └── dev    ← integración del sprint
      └── feature/HU-03-lista-reportes   ← una rama por historia/tarea
```

- Nunca se hace push directo a `main`: todo cambio entra por **Pull Request**.
- Al cerrar cada sprint se crea un **Release** en GitHub con el APK (Sprint 2+).

## 2. Commits convencionales (Conventional Commits)

| Tipo | Uso | Ejemplo |
|---|---|---|
| `feat:` | nueva funcionalidad (historia de usuario) | `feat: lista de reportes con datos mock (HU-03)` |
| `fix:` | corrección de bug | `fix: validación de teléfono en formulario nuevo reporte` |
| `docs:` | documentación | `docs: registrar product vision board (Sprint 0)` |
| `chore:` | mantenimiento, configuración | `chore: inicializar repositorio del Proyecto Guía` |
| `test:` | pruebas | `test: pruebas unitarias del modelo Reporte` |
| `refactor:` | cambio de código sin cambiar comportamiento | `refactor: extraer widget ReportCard reutilizable` |

Reglas:

- Mensaje en minúsculas, en modo imperativo, de 50 a 72 caracteres.
- Un commit = un cambio coherente (no mezclar `feat` y `fix`).
- Referenciar la historia: `(HU-03)` al final del mensaje.

## 3. Comandos del día 1 (cheatsheet)

```bash
# Configuración única por computadora (no son claves; usa tu correo de GitHub)
git config --global user.name "Tu Nombre"
git config --global user.email "tu_correo@usuarios.github.com"

# Crear y subir el repositorio del equipo
git init
git add .
git commit -m "chore: inicializar repositorio del proyecto paralelo"
git branch -M main
git remote add origin https://github.com/<organizacion>/<proyecto>.git
git push -u origin main

# Ciclo diario de trabajo
git switch -c feature/HU-03-lista-reportes   # nueva rama por historia
git add . && git commit -m "feat: lista de reportes (HU-03)"
git push -u origin feature/HU-03-lista-reportes
# → abrir Pull Request en GitHub → pedir revisión → merge → mover tarjeta a Hecho

# Actualizarse antes de empezar
git switch main && git pull origin main
```

## 4. Tablero GitHub Projects (Scrum)

Columnas: **Backlog → Ready → En curso → En revisión → Hecho**

- Máximo **2 tarjetas "En curso" por persona**.
- Cada tarjeta: historia (ID) + estimación (puntos) + responsable + etiqueta
  (épica, Must/Should/Could, `bug` si corresponde).
- La tarjeta se enlaza al Pull Request y a la evidencia (captura o video).
- El gráfico burndown del sprint se revisa en el Daily.

## 5. Seguridad en el repositorio

- **Nunca** subir API keys, tokens o contraseñas: se usan `--dart-define`,
  variables de entorno o GitHub Secrets.
- Si se sube una clave por error: **revocarla inmediatamente** en el proveedor,
  limpiar el historial y avisar al docente.
- `.gitignore` siempre versionado antes del primer commit (ver raíz del repo).

# 🔧 REQUERIMIENTOS BACKEND - SISTEMA ENTRENAMIENTO

## 📅 **Fecha**: 30 de Enero de 2025
## 🎯 **Para**: Equipo Backend
## 📝 **De**: Frontend - Sistema de Entrenamiento Atleta

---

## 🚨 **PROBLEMAS PENDIENTES QUE REQUIEREN BACKEND**

### **1. ❌ Planning Service - Error 401 Unauthorized**
**CRÍTICO** - Bloquea integración completa

```
❌ API: Error en GET /planning/v1/routines?nivel=Principiante - 401
❌ [RoutineService] ERROR obteniendo rutinas: 401 Unauthorized  
❌ [RoutineService] Token de autenticación inválido o expirado
```

**Verificar:**
- Variables de entorno `JWT_ISSUER_URL` y `JWT_AUDIENCE` en Planning Service
- Reinicio del Planning Service después de cambios
- Logs del Planning Service para errores específicos de JWT

---

## 📋 **ENDPOINTS REQUERIDOS PARA ENTRENAMIENTO**

### **🔥 ALTA PRIORIDAD - Planning Service**

#### **1. Rutinas Asignadas del Atleta**
```http
GET /planning/v1/assignments/me
Authorization: Bearer {jwt_token}

Response esperado:
[
  {
    "id": "uuid",
    "nombreRutina": "Rutina Principiante",
    "nombreEntrenador": "Coach Juan",
    "estado": "PENDIENTE" | "EN_PROGRESO" | "COMPLETADA",
    "fechaAsignacion": "2025-01-30T10:00:00Z",
    "rutinaId": "rutina-uuid",
    "assignerId": "coach-uuid"
  }
]
```

#### **2. Detalle de Rutina con Ejercicios**
```http
GET /planning/v1/routines/:id
Authorization: Bearer {jwt_token}

Response esperado:
{
  "id": "rutina-uuid",
  "nombre": "Rutina Principiante Boxeo",
  "nivel": "Principiante",
  "descripcion": "Rutina básica para principiantes",
  "ejercicios": [
    {
      "id": "ejercicio-uuid",
      "nombre": "Movimientos de hombro",
      "descripcion": "Rotaciones circulares",
      "setsReps": "3x30", 
      "duracionEstimadaSegundos": 180,
      "categoria": "calentamiento" // NUEVO CAMPO REQUERIDO
    },
    {
      "id": "ejercicio-uuid-2", 
      "nombre": "Burpees",
      "setsReps": "3x50",
      "duracionEstimadaSegundos": 300,
      "categoria": "resistencia" // NUEVO CAMPO REQUERIDO
    },
    {
      "id": "ejercicio-uuid-3",
      "nombre": "Jab directo", 
      "setsReps": "10x100",
      "duracionEstimadaSegundos": 600,
      "categoria": "tecnica" // NUEVO CAMPO REQUERIDO
    }
  ]
}
```

#### **3. Actualizar Estado de Asignación**
```http
PATCH /planning/v1/assignments/:id
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "estado": "EN_PROGRESO" | "COMPLETADA"
}

Response:
{
  "id": "assignment-uuid",
  "estado": "EN_PROGRESO",
  "fechaActualizacion": "2025-01-30T10:30:00Z"
}
```

---

### **🏃‍♂️ MEDIA PRIORIDAD - Performance Service**

#### **4. Registrar Sesión de Entrenamiento**
```http
POST /performance/v1/sessions
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "assignmentId": "assignment-uuid", // Referencia a la asignación
  "fechaInicio": "2025-01-30T10:00:00Z",
  "fechaFin": "2025-01-30T10:30:00Z",
  "duracionTotalSegundos": 1800,
  "tiempoObjetivoSegundos": 1620,
  "ejerciciosCompletados": 12,
  "secciones": [
    {
      "categoria": "calentamiento",
      "tiempoUsadoSegundos": 180,
      "tiempoObjetivoSegundos": 180,
      "ejerciciosCompletados": 4
    },
    {
      "categoria": "resistencia", 
      "tiempoUsadoSegundos": 300,
      "tiempoObjetivoSegundos": 300,
      "ejerciciosCompletados": 4
    },
    {
      "categoria": "tecnica",
      "tiempoUsadoSegundos": 600,
      "tiempoObjetivoSegundos": 540,
      "ejerciciosCompletados": 4
    }
  ]
}

Response:
{
  "id": "session-uuid",
  "message": "Sesión registrada exitosamente",
  "rachaActualizada": 5 // Nueva racha del atleta
}
```

#### **5. Historial de Sesiones del Atleta**
```http
GET /performance/v1/sessions/me
Authorization: Bearer {jwt_token}

Response:
[
  {
    "id": "session-uuid",
    "fechaInicio": "2025-01-30T10:00:00Z",
    "duracionTotalSegundos": 1800,
    "tiempoObjetivoSegundos": 1620,
    "ejerciciosCompletados": 12,
    "nombreRutina": "Rutina Principiante",
    "estado": "COMPLETADA"
  }
]
```

---

## 🔧 **MODIFICACIONES REQUERIDAS**

### **⚠️ Planning Service - Campo "categoria" faltante**

**Problema actual:**
```json
// ❌ Estructura actual - ejercicios planos
{
  "ejercicios": [
    {
      "id": "uuid",
      "nombre": "Burpees",
      "setsReps": "3x50",
      "duracionEstimadaSegundos": 300
      // ❌ FALTA CAMPO "categoria"
    }
  ]
}
```

**Estructura requerida:**
```json
// ✅ Estructura necesaria - con categorías
{
  "ejercicios": [
    {
      "id": "uuid",
      "nombre": "Burpees", 
      "setsReps": "3x50",
      "duracionEstimadaSegundos": 300,
      "categoria": "resistencia" // ✅ NUEVO CAMPO REQUERIDO
    }
  ]
}
```

### **📊 Categorías válidas:**
- `"calentamiento"` - Ejercicios de preparación
- `"resistencia"` - Ejercicios cardiovasculares y fuerza
- `"tecnica"` - Ejercicios de técnica de boxeo

---

## 🎯 **FLUJO ESPERADO FRONTEND ↔ BACKEND**

### **1. Al cargar vista atleta:**
```
Frontend: GET /planning/v1/assignments/me
Backend: → Lista de rutinas asignadas (PENDIENTE/EN_PROGRESO)

Frontend: GET /planning/v1/routines/{rutinaId}  
Backend: → Detalle con ejercicios categorizados
```

### **2. Al iniciar entrenamiento:**
```
Frontend: PATCH /planning/v1/assignments/{id}
Body: {"estado": "EN_PROGRESO"}
Backend: → Confirma cambio de estado
```

### **3. Al completar entrenamiento:**
```
Frontend: POST /performance/v1/sessions
Body: {datos completos de la sesión}
Backend: → Registra sesión + actualiza racha

Frontend: PATCH /planning/v1/assignments/{id}
Body: {"estado": "COMPLETADA"}  
Backend: → Marca asignación como completada
```

---

## 🔐 **AUTORIZACIÓN Y PERMISOS**

### **Roles y accesos:**
- **Atleta** puede:
  - `GET /planning/v1/assignments/me` (solo sus asignaciones)
  - `GET /planning/v1/routines/:id` (solo rutinas asignadas)
  - `PATCH /planning/v1/assignments/:id` (solo sus asignaciones)
  - `POST /performance/v1/sessions` (solo sus sesiones)
  - `GET /performance/v1/sessions/me` (solo sus sesiones)

- **Coach** puede:
  - Todos los endpoints de Planning Service
  - `GET /performance/v1/sessions/athlete/:atletaId`

---

## 🚀 **PRIORIDADES DE IMPLEMENTACIÓN**

### **🔥 CRÍTICO (Bloqueante)**
1. **Resolver error 401 en Planning Service**
2. **Agregar campo "categoria" a ejercicios**

### **⚡ ALTA**
3. **Endpoint /planning/v1/assignments/me**
4. **Endpoint /planning/v1/routines/:id con categorías**

### **📈 MEDIA**
5. **Performance Service - registrar sesiones**
6. **Estados de asignación (PATCH assignments)**

### **📊 BAJA**
7. **Historial de sesiones**
8. **Métricas avanzadas**

---

## 📞 **COORDINACIÓN**

**Frontend está preparado y esperando:**
- ✅ Servicios implementados (`RoutineService`, `AssignmentService`)
- ✅ DTOs definidos (`RoutineDetailDto`, `AthleteAssignmentDto`)
- ✅ UI completa funcionando con datos mock
- ✅ Flujo de entrenamiento completo

**Una vez resuelto el Planning Service, el sistema estará 100% funcional.**

---

## 🎯 **RESULTADO ESPERADO**

**Al completar estos endpoints:**
1. **Atleta verá rutinas reales** asignadas por su coach
2. **Tiempos y ejercicios reales** del backend
3. **Progreso guardado** en base de datos
4. **Racha actualizada** automáticamente
5. **Sistema completo** sin datos mock

**¿Pueden confirmar el cronograma para estos endpoints?** 
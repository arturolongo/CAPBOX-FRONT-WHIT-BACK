# 📋 DIAGNÓSTICO COMPLETO - INTEGRACIÓN RUTINAS BACKEND

## 🗓️ **Fecha**: `${new Date().toLocaleDateString('es-ES')}`
## 👨‍💻 **Desarrollador**: Frontend Flutter  
## 🎯 **Objetivo**: Conectar funcionalidad de rutinas con backend real

---

## 📊 **RESUMEN EJECUTIVO**

### ✅ **IMPLEMENTACIONES COMPLETADAS**
- ✅ **RoutineService** - CRUD completo de rutinas  
- ✅ **ExerciseService** - Consulta de ejercicios disponibles  
- ✅ **AssignmentService** - Asignación y gestión de rutinas a atletas  
- ✅ **DTOs actualizados** - Estructura adaptada al backend  
- ✅ **UI actualizada** - Todas las pantallas consumen servicios reales  
- ✅ **Logs detallados** - Request/Response tracking completo  

### 🔍 **ENDPOINTS IMPLEMENTADOS**

#### **Planning Service** (`https://api.capbox.site/planning/v1/`)
| Método | Endpoint | Implementado | Propósito |
|--------|----------|-------------|-----------|
| `GET` | `/routines` | ✅ | Listar rutinas (con filtro por nivel) |
| `GET` | `/routines/:id` | ✅ | Obtener detalle de rutina |
| `POST` | `/routines` | ✅ | Crear nueva rutina |
| `PUT` | `/routines/:id` | ✅ | Actualizar rutina existente |
| `DELETE` | `/routines/:id` | ✅ | Eliminar rutina |
| `GET` | `/exercises` | ✅ | Listar ejercicios (con filtro sportId=1) |
| `POST` | `/assignments` | ✅ | Asignar rutina a atletas |
| `GET` | `/assignments/me` | ✅ | Consultar asignaciones del atleta |
| `DELETE` | `/assignments/:id` | ✅ | Cancelar asignación |
| `PATCH` | `/assignments/:id` | ✅ | Actualizar estado de asignación |

---

## 🔍 **CASOS DE USO CUBIERTOS**

### **1. COACH - Gestión de Rutinas**
- **Crear rutina**: ✅ Formulario completo con ejercicios por categoría
- **Listar rutinas**: ✅ Por nivel con contadores dinámicos  
- **Asignar rutinas**: ✅ Por nivel y personalizada
- **Eliminar rutinas**: ✅ Con confirmación y recarga automática

### **2. COACH - Asignación a Atletas**  
- **Rutinas por nivel**: ✅ Filtrado automático según nivel del atleta
- **Rutina personalizada**: ✅ Cualquier rutina a cualquier atleta
- **Seguimiento**: ✅ Estados (PENDIENTE, EN_PROGRESO, COMPLETADA)

### **3. ATLETA - Visualización**
- **Mis rutinas asignadas**: ✅ Lista completa con estados
- **Cambio de estado**: ✅ Iniciar → Completar rutinas
- **Información detallada**: ✅ Entrenador, fecha de asignación

---

## 🚨 **PUNTOS A VALIDAR CON BACKEND**

### **1. RESPUESTAS ESPERADAS vs REALES**

#### **GET /planning/v1/routines**
```javascript
// ESPERADO por DTO:
{
  "id": "string",
  "nombre": "string", 
  "nivel": "string",
  "coachId": "string",
  "sportId": number
}

// ¿BACKEND DEVUELVE?
// - ¿Campo 'nivel' o 'level'?
// - ¿Campo 'coachId' o 'createdBy'?
// - ¿Incluye 'sportId' en listado?
```

#### **GET /planning/v1/routines/:id** (Detalle)
```javascript
// ESPERADO por DTO:
{
  "id": "string",
  "nombre": "string",
  "nivel": "string", 
  "coachId": "string",
  "sportId": number,
  "descripcion": "string?",
  "ejercicios": [
    {
      "id": "string",
      "nombre": "string",
      "descripcion": "string?", 
      "setsReps": "string?",
      "duracionEstimadaSegundos": number?
    }
  ]
}

// ¿BACKEND DEVUELVE?
// - ¿Los ejercicios están poblados?
// - ¿Campo 'ejercicios' o 'exercises'?
// - ¿Estructura de ejercicios completa?
```

#### **GET /planning/v1/exercises?sportId=1**
```javascript
// ESPERADO por DTO:
[
  {
    "id": "string",
    "nombre": "string",
    "descripcion": "string?"
  }
]

// ¿BACKEND DEVUELVE?
// - ¿Lista de ejercicios de boxeo disponibles?
// - ¿Campo 'nombre' o 'name'?
```

#### **POST /planning/v1/assignments**
```javascript
// ENVIADO:
{
  "rutinaId": "string",
  "metaId": null,
  "atletaIds": ["string1", "string2"]
}

// ESPERADO RESPUESTA:
{
  "mensaje": "string",
  "asignacionesCreadas": number
}

// ¿BACKEND DEVUELVE?
// - ¿Confirma cantidad de asignaciones?
// - ¿Maneja atletas múltiples?
```

#### **GET /planning/v1/assignments/me**
```javascript
// ESPERADO por DTO:
[
  {
    "id": "string",
    "nombreRutina": "string",
    "nombreEntrenador": "string", 
    "estado": "PENDIENTE|EN_PROGRESO|COMPLETADA",
    "fechaAsignacion": "ISO 8601",
    "rutinaId": "string",
    "assignerId": "string"
  }
]

// ¿BACKEND DEVUELVE?
// - ¿Incluye nombre del entrenador?
// - ¿Estados en español o inglés?
// - ¿Fechas en formato ISO?
```

---

## 🔧 **CONFIGURACIÓN TÉCNICA**

### **Headers Requeridos**
```javascript
{
  "Authorization": "Bearer {JWT_TOKEN}",
  "Content-Type": "application/json"
}
```

### **Query Parameters**
- `GET /routines?nivel={Principiante|Intermedio|Avanzado|General}`
- `GET /exercises?sportId=1` (Boxeo)

### **Manejo de Errores Implementado**
- **401**: Token inválido/expirado → Re-login
- **403**: Sin permisos → Mensaje específico por rol  
- **404**: Recurso no encontrado → Crear o actualizar
- **422**: Datos inválidos → Validación frontend
- **500**: Error interno → Contactar backend

---

## 📱 **PANTALLAS ACTUALIZADAS**

### **Coach**
1. **`CoachRoutinesPage`** → Menú principal con 3 opciones
2. **`CoachAssignRoutinePage`** → Consume `RoutineService.getRoutines(nivel)`
3. **`CoachCreateRoutinePage`** → Usa `ExerciseService.getExercises()` + `RoutineService.createRoutine()`
4. **`CoachManageRoutinesPage`** → Lista real con contadores y eliminación

### **Atleta**  
1. **`BoxerHomePage`** → Sección "Mis Rutinas Asignadas" con `AssignmentService.getMyAssignments()`

---

## 🧪 **CASOS DE PRUEBA SUGERIDOS**

### **Para Backend**
1. **Crear rutina** con 5 ejercicios de diferentes categorías
2. **Listar rutinas** por cada nivel (Principiante, Intermedio, Avanzado)
3. **Asignar rutina** a 3 atletas simultáneamente  
4. **Cambiar estado** de asignación: PENDIENTE → EN_PROGRESO → COMPLETADA
5. **Eliminar rutina** que tiene asignaciones activas
6. **Consultar ejercicios** disponibles para sportId=1

### **Validaciones de Datos**
- ¿Qué pasa si `nivel` no existe?
- ¿Qué pasa si `atletaId` no existe? 
- ¿Qué pasa si `rutinaId` no existe?
- ¿Qué pasa si atleta ya tiene esa rutina asignada?

---

## 📈 **MÉTRICAS DE LOGS**

### **Request Logging**
```
🟢 [ServiceName] GET /endpoint
📋 [ServiceName] Parámetros: {datos}
📊 [ServiceName] Payload: {datos}
```

### **Response Logging**  
```
✅ [ServiceName] Response status: 200
📊 [ServiceName] Response data: {datos}
✅ [ServiceName] X elementos cargados
```

### **Error Logging**
```
❌ [ServiceName] ERROR: mensaje
📝 [ServiceName] Endpoint no encontrado en backend
📝 [ServiceName] Sin permisos para acción
```

---

## 🎯 **SIGUIENTE PASOS**

### **Inmediatos**
1. **Ejecutar primer test** con backend para validar estructura de respuestas
2. **Ajustar DTOs** según respuestas reales del backend  
3. **Validar autenticación** en endpoints de Planning Service
4. **Confirmar query parameters** aceptados por backend

### **Seguimiento**
1. **Monitorear logs** de errores 404/403/500
2. **Medir performance** de endpoints con múltiples rutinas
3. **Validar UX** de carga de ejercicios disponibles  
4. **Testear casos edge** (rutina sin ejercicios, atleta sin asignaciones)

---

## 📞 **CONTACTO BACKEND**

En caso de encontrar inconsistencias, proporcionar:
- **Endpoint específico** con problema
- **Request completo** enviado  
- **Response recibida** vs esperada
- **Logs del frontend** con timestamps
- **Caso de uso** específico que falla

---

**🚀 Frontend listo para integración. Esperando validación del backend.** 
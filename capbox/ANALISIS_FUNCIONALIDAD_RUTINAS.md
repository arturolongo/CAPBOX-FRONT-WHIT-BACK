# 📋 ANÁLISIS FUNCIONALIDAD RUTINAS - CONEXIÓN BACKEND

## 🎯 **ESTADO ACTUAL DE LA FUNCIONALIDAD**

### **📱 PÁGINAS IMPLEMENTADAS**:

1. **`coach_assign_routine_page.dart`** ✅:
   - Asignar rutinas a estudiantes
   - Lista de rutinas por nivel (principiante, intermedio, avanzado)
   - Vista expandible de ejercicios por categoría
   - Datos hardcodeados actualmente

2. **`coach_create_routine_page.dart`** ✅:
   - Crear nuevas rutinas
   - Formulario con nombre, nivel, categorías
   - Agregar ejercicios por categoría (calentamiento, resistencia, técnica)
   - Validaciones básicas

3. **`coach_manage_routines_page.dart`** ✅:
   - Gestión de rutinas por nivel
   - Navegación a crear rutina
   - Menú de niveles disponibles

4. **`coach_manage_routine_page.dart`** ✅:
   - Editar rutinas existentes
   - Vista detallada de rutina

### **📊 MODELOS DE DATOS EXISTENTES**:

1. **`routine_dto.dart`** ✅:
   - `RoutineListDto`: Lista de rutinas
   - `RoutineDetailDto`: Detalle de rutina
   - `EjercicioDto`: Ejercicio individual
   - `AssignmentDto`: Asignación de rutina

### **🎨 WIDGETS IMPLEMENTADOS**:

1. **`routine_card.dart`** ✅:
   - Tarjeta expandible de rutina
   - Categorías de ejercicios
   - Tabla de ejercicios

2. **`routine_card_manage.dart`** ✅:
   - Tarjeta para gestión de rutinas

3. **`routine_category_tab.dart`** ✅:
   - Pestañas de categorías
   - Formulario de ejercicios

## 🔧 **FUNCIONALIDADES A CONECTAR CON BACKEND**

### **1. GESTIÓN DE RUTINAS**:

**Endpoints necesarios**:
```
GET /routines - Obtener lista de rutinas
GET /routines/{id} - Obtener detalle de rutina
POST /routines - Crear nueva rutina
PUT /routines/{id} - Actualizar rutina
DELETE /routines/{id} - Eliminar rutina
```

**Estructura de datos**:
```json
{
  "id": "uuid",
  "nombre": "Rutina para mejorar velocidad",
  "nivel": "principiante",
  "duracionEstimadaMinutos": 25,
  "cantidadEjercicios": 4,
  "ejercicios": [
    {
      "id": "uuid",
      "nombre": "Saco pesado",
      "categoria": "calentamiento",
      "duracion": "10:00",
      "setsReps": "3x10"
    }
  ]
}
```

### **2. ASIGNACIÓN DE RUTINAS**:

**Endpoints necesarios**:
```
GET /assignments - Obtener asignaciones del estudiante
POST /assignments - Asignar rutina a estudiante
PUT /assignments/{id} - Actualizar asignación
DELETE /assignments/{id} - Cancelar asignación
```

**Estructura de datos**:
```json
{
  "idAsignacion": "uuid",
  "tipoPlan": "rutina",
  "idPlan": "uuid-rutina",
  "nombrePlan": "Rutina para mejorar velocidad",
  "idAsignador": "uuid-coach",
  "idEstudiante": "uuid-estudiante",
  "estado": "activa",
  "fechaAsignacion": "2025-01-29T10:30:00Z",
  "fechaVencimiento": "2025-02-05T10:30:00Z"
}
```

### **3. SEGUIMIENTO DE PROGRESO**:

**Endpoints necesarios**:
```
GET /progress/{studentId} - Obtener progreso del estudiante
POST /progress - Registrar progreso de ejercicio
GET /progress/routine/{routineId} - Progreso de rutina específica
```

**Estructura de datos**:
```json
{
  "id": "uuid",
  "idEstudiante": "uuid",
  "idRutina": "uuid",
  "idEjercicio": "uuid",
  "completado": true,
  "fechaCompletado": "2025-01-29T10:30:00Z",
  "tiempoRealizado": "08:30",
  "notas": "Ejercicio completado correctamente"
}
```

## 🚀 **PLAN DE IMPLEMENTACIÓN**

### **FASE 1: SERVICIOS DE API** (Prioridad Alta)

1. **Crear `RoutineService`**:
   ```dart
   class RoutineService {
     Future<List<RoutineListDto>> getRoutines();
     Future<RoutineDetailDto> getRoutineDetail(String id);
     Future<RoutineDetailDto> createRoutine(CreateRoutineDto routine);
     Future<RoutineDetailDto> updateRoutine(String id, UpdateRoutineDto routine);
     Future<void> deleteRoutine(String id);
   }
   ```

2. **Crear `AssignmentService`**:
   ```dart
   class AssignmentService {
     Future<List<AssignmentDto>> getStudentAssignments(String studentId);
     Future<AssignmentDto> assignRoutine(AssignRoutineDto assignment);
     Future<AssignmentDto> updateAssignment(String id, UpdateAssignmentDto assignment);
     Future<void> cancelAssignment(String id);
   }
   ```

3. **Crear `ProgressService`**:
   ```dart
   class ProgressService {
     Future<List<ProgressDto>> getStudentProgress(String studentId);
     Future<ProgressDto> recordProgress(RecordProgressDto progress);
     Future<List<ProgressDto>> getRoutineProgress(String routineId);
   }
   ```

### **FASE 2: DTOs ADICIONALES** (Prioridad Alta)

1. **`CreateRoutineDto`**:
   ```dart
   class CreateRoutineDto {
     final String nombre;
     final String nivel;
     final List<CreateEjercicioDto> ejercicios;
   }
   ```

2. **`AssignRoutineDto`**:
   ```dart
   class AssignRoutineDto {
     final String idRutina;
     final String idEstudiante;
     final DateTime fechaVencimiento;
     final String? notas;
   }
   ```

3. **`ProgressDto`**:
   ```dart
   class ProgressDto {
     final String id;
     final String idEstudiante;
     final String idRutina;
     final String idEjercicio;
     final bool completado;
     final DateTime? fechaCompletado;
     final String? tiempoRealizado;
     final String? notas;
   }
   ```

### **FASE 3: CUBITS/STATE MANAGEMENT** (Prioridad Media)

1. **`RoutineCubit`**:
   ```dart
   class RoutineCubit extends Cubit<RoutineState> {
     Future<void> loadRoutines();
     Future<void> createRoutine(CreateRoutineDto routine);
     Future<void> updateRoutine(String id, UpdateRoutineDto routine);
     Future<void> deleteRoutine(String id);
   }
   ```

2. **`AssignmentCubit`**:
   ```dart
   class AssignmentCubit extends Cubit<AssignmentState> {
     Future<void> loadStudentAssignments(String studentId);
     Future<void> assignRoutine(AssignRoutineDto assignment);
     Future<void> cancelAssignment(String id);
   }
   ```

### **FASE 4: INTEGRACIÓN EN UI** (Prioridad Media)

1. **Actualizar `coach_assign_routine_page.dart`**:
   - Cargar rutinas desde API
   - Implementar asignación real
   - Manejo de estados de carga/error

2. **Actualizar `coach_create_routine_page.dart`**:
   - Guardar rutina en backend
   - Validaciones mejoradas
   - Feedback de éxito/error

3. **Actualizar `coach_manage_routines_page.dart`**:
   - Lista dinámica de rutinas
   - Acciones de editar/eliminar
   - Filtros por nivel

### **FASE 5: FUNCIONALIDADES AVANZADAS** (Prioridad Baja)

1. **Seguimiento de progreso**:
   - Vista de progreso del estudiante
   - Gráficos de rendimiento
   - Notificaciones de vencimiento

2. **Rutinas personalizadas**:
   - Crear rutinas específicas por estudiante
   - Ajustes automáticos según progreso
   - Recomendaciones inteligentes

## 📋 **ENDPOINTS BACKEND REQUERIDOS**

### **1. RUTINAS**:
```
GET /api/v1/routines
GET /api/v1/routines/{id}
POST /api/v1/routines
PUT /api/v1/routines/{id}
DELETE /api/v1/routines/{id}
```

### **2. ASIGNACIONES**:
```
GET /api/v1/assignments/student/{studentId}
POST /api/v1/assignments
PUT /api/v1/assignments/{id}
DELETE /api/v1/assignments/{id}
```

### **3. PROGRESO**:
```
GET /api/v1/progress/student/{studentId}
POST /api/v1/progress
GET /api/v1/progress/routine/{routineId}
```

## 🎯 **PRÓXIMOS PASOS**

1. **Crear servicios de API** ✅
2. **Implementar DTOs adicionales** ✅
3. **Crear Cubits para state management** ✅
4. **Integrar en páginas existentes** ✅
5. **Testing y validación** ✅

**¿Quieres que empecemos con la FASE 1 creando los servicios de API?** 🚀 
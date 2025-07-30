# 🎭 EMULACIÓN: Datos de Racha del Alumno

## 📋 **Descripción**

Se ha implementado una emulación realista de los datos de racha del alumno mientras el backend desarrolla la funcionalidad completa. La emulación genera datos consistentes y variados basados en el ID del usuario.

## 🎯 **Características de la Emulación**

### **✅ Datos Realistas Generados:**

#### **1. Racha Actual**
- **Rango**: 1-5 días (basado en hash del userId)
- **Estado**: "activo" o "inactivo"
- **Record Personal**: 5-20 días
- **Última Actualización**: Fecha actual

#### **2. Días Consecutivos**
- **Fechas reales**: Desde hoy hacia atrás
- **Status**: "presente" para todos los días de racha
- **Cantidad**: Coincide con la racha actual

#### **3. Historial de Rachas**
- **Cantidad**: 3-8 rachas anteriores
- **Duración**: 1-10 días por racha
- **Motivos de fin**: Variados y realistas
- **Fechas**: Distribuidas en el tiempo

## 🔧 **Implementación Técnica**

### **Archivo Modificado:**
- `capbox/lib/features/admin/data/services/attendance_service.dart`

### **Funciones Agregadas:**

#### **1. `_generateEmulatedStreakData(String userId)`**
```dart
// Genera datos de racha actual basados en el userId
// - Racha actual: 1-5 días
// - Record personal: 5-20 días
// - Estado: activo/inactivo
// - Días consecutivos realistas
```

#### **2. `_generateEmulatedStreakHistory(String userId)`**
```dart
// Genera historial de rachas anteriores
// - 3-8 rachas anteriores
// - Duración variada: 1-10 días
// - Motivos realistas de fin de racha
```

#### **3. `_getRandomMotivoFin(int seed)`**
```dart
// Genera motivos realistas para fin de racha:
// - Falta por enfermedad
// - Viaje de trabajo
// - Lesión menor
// - Compromiso familiar
// - Falta por descanso
// - Problemas de transporte
```

## 📊 **Ejemplo de Datos Generados**

### **Para un usuario específico:**
```json
{
  "usuario_id": "user123",
  "racha_actual": 3,
  "estado": "activo",
  "ultima_actualizacion": "2024-01-15T10:30:00.000Z",
  "record_personal": 12,
  "dias_consecutivos": [
    {
      "fecha": "2024-01-15T00:00:00.000Z",
      "status": "presente"
    },
    {
      "fecha": "2024-01-14T00:00:00.000Z", 
      "status": "presente"
    },
    {
      "fecha": "2024-01-13T00:00:00.000Z",
      "status": "presente"
    }
  ]
}
```

### **Historial de Rachas:**
```json
[
  {
    "inicio": "2024-01-01T00:00:00.000Z",
    "fin": "2024-01-05T00:00:00.000Z",
    "duracion": 5,
    "motivo_fin": "Falta por enfermedad"
  },
  {
    "inicio": "2023-12-15T00:00:00.000Z",
    "fin": "2023-12-18T00:00:00.000Z", 
    "duracion": 4,
    "motivo_fin": "Viaje de trabajo"
  }
]
```

## 🎨 **Características de la UI**

### **Widgets que usan la emulación:**
1. **`BoxerStreakDisplay`** - Muestra la racha actual
2. **`BoxerStreakGoals`** - Muestra metas y racha
3. **Coach Attendance** - Actualiza rachas de alumnos

### **Diseño Visual:**
- **Gradiente rojo-pink** para el widget de racha
- **Icono de fuego** para representar la racha
- **Texto dinámico** según el número de días
- **Animación de carga** durante la emulación

## 🔄 **Transición al Backend Real**

### **Cuando el backend esté listo:**

1. **Remover comentarios de emulación**
2. **Restaurar llamadas reales al API**
3. **Mantener la misma estructura de datos**
4. **Actualizar endpoints reales**

### **Cambios necesarios:**
```dart
// ANTES (emulación):
final emulatedData = _generateEmulatedStreakData(userId);
return StreakInfo.fromJson(emulatedData);

// DESPUÉS (backend real):
final response = await _apiService.get('/identity/v1/usuarios/$userId/racha');
return StreakInfo.fromJson(response.data);
```

## 📈 **Beneficios de la Emulación**

### **✅ Para Desarrollo:**
- **Datos consistentes** para testing
- **Variedad realista** de escenarios
- **UI funcional** sin depender del backend
- **Feedback inmediato** para mejoras

### **✅ Para Usuarios:**
- **Experiencia completa** de la funcionalidad
- **Datos visualmente atractivos**
- **Interacción fluida** con la app
- **Motivación** con rachas realistas

## 🚀 **Estado Actual**

### **✅ Implementado:**
- ✅ Emulación de racha actual
- ✅ Emulación de historial de rachas
- ✅ Datos consistentes por usuario
- ✅ UI completamente funcional
- ✅ Logs detallados para debugging

### **🔄 Pendiente:**
- 🔄 Integración con backend real
- 🔄 Sincronización de datos
- 🔄 Actualizaciones en tiempo real

---

**La emulación proporciona una experiencia completa y realista mientras el backend desarrolla la funcionalidad completa.** 🎭 
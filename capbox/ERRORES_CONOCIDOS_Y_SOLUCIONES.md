# 🚨 ERRORES CONOCIDOS Y SOLUCIONES

## 📋 **RESUMEN DE ERRORES**

Este documento detalla los errores más comunes en CAPBOX y sus soluciones implementadas.

---

## 🔍 **ERROR 1: Registro con respuesta null**

### **Síntomas:**
```
❌ AUTH INTERCEPTOR: Error null
❌ API: Error de Dio - null
❌ API: Respuesta del servidor - null
❌ REGISTRO ERROR: Exception: Error registrando usuario: null
```

### **Causa:**
- El servidor no responde (timeout o error de red)
- El interceptor no maneja correctamente errores null
- Problemas de conectividad con el backend

### **Solución Implementada:**
```dart
// 🔧 CORRECCIÓN IMPLEMENTADA: Manejar errores null
if (err.response == null) {
  print('⚠️ ERROR NULL: Respuesta del servidor es null');
  
  // Crear error más descriptivo
  final descriptiveError = DioException(
    requestOptions: err.requestOptions,
    response: err.response,
    type: err.type,
    error: 'Error de conexión: No se recibió respuesta del servidor',
  );
  
  handler.next(descriptiveError);
  return;
}
```

### **Prevención:**
1. ✅ Verificar conectividad a internet
2. ✅ Verificar que el backend esté funcionando
3. ✅ Reintentar la operación después de unos segundos

---

## 🔍 **ERROR 2: Coach Error 403 al aprobar atletas**

### **Síntomas:**
```
❌ AUTH INTERCEPTOR: Error 403
🔧 API: Error 403 detectado, ejecutando auto-fix para coach...
❌ AUTH INTERCEPTOR: Error 403
❌ API: Auto-fix falló: DioException [bad response]
❌ API: Error original 403 - coach sin permisos
```

### **Causa:**
- El backend valida demasiados permisos para coaches
- Coaches no tienen `estado_atleta: 'activo'`
- Validaciones de `datos_fisicos_capturados` del coach

### **Solución Implementada:**
```dart
// 🔧 CORRECCIÓN IMPLEMENTADA: Proporcionar mensaje más descriptivo
throw Exception(
  'Error 403: El coach no tiene permisos para aprobar atletas. '
  'Contacta al administrador del sistema para activar tu cuenta de coach.',
);
```

### **Solución Backend (Pendiente):**
```javascript
// CAMBIAR DE:
if (user.role !== 'Entrenador' || user.estado_atleta !== 'activo') {
  return res.status(403).json({ error: 'Sin permisos' });
}

// CAMBIAR A:
if (user.role !== 'Entrenador' && user.role !== 'Admin') {
  return res.status(403).json({ error: 'Solo coaches y admins pueden aprobar atletas' });
}
```

### **Prevención:**
1. ✅ Activar coaches automáticamente al registrarse
2. ✅ Eliminar validaciones innecesarias en backend
3. ✅ Simplificar sistema de permisos

---

## 🔍 **ERROR 3: Error de conexión general**

### **Síntomas:**
```
❌ API: Error inesperado - DioException [connection error]
❌ API: Error de conexión - No se pudo conectar con el servidor
```

### **Causa:**
- Problemas de red
- Backend no disponible
- Timeout de conexión

### **Solución Implementada:**
```dart
// 🔧 CORRECCIÓN IMPLEMENTADA: Manejo mejorado de errores
if (e.response == null) {
  throw Exception('Error de conexión: No se pudo conectar con el servidor');
}
```

### **Prevención:**
1. ✅ Verificar conectividad
2. ✅ Implementar retry automático
3. ✅ Mostrar mensajes claros al usuario

---

## 🔍 **ERROR 4: Error 409 - Email ya existe**

### **Síntomas:**
```
❌ API: Error registrando usuario: 409
```

### **Causa:**
- Usuario intenta registrarse con email ya existente

### **Solución Implementada:**
```dart
if (e.response?.statusCode == 409) {
  throw Exception('Ya existe una cuenta con este email');
}
```

### **Prevención:**
1. ✅ Validar email antes del registro
2. ✅ Mostrar mensaje claro al usuario
3. ✅ Sugerir iniciar sesión en lugar de registrarse

---

## 🔍 **ERROR 5: Error 422 - Datos inválidos**

### **Síntomas:**
```
❌ API: Error registrando usuario: 422
```

### **Causa:**
- Datos de registro no cumplen validaciones
- Campos requeridos faltantes
- Formato de datos incorrecto

### **Solución Implementada:**
```dart
if (e.response?.statusCode == 422) {
  throw Exception('Datos de registro inválidos');
}
```

### **Prevención:**
1. ✅ Validar datos en frontend antes de enviar
2. ✅ Mostrar errores específicos por campo
3. ✅ Guiar al usuario sobre el formato correcto

---

## 🛠️ **HERRAMIENTAS DE DIAGNÓSTICO**

### **Logs Detallados:**
```dart
print('🔍 ERROR NULL: Tipo de error: ${err.type}');
print('🔍 ERROR NULL: Mensaje: ${err.message}');
print('📋 API: Body enviado - $body');
print('📊 API: Status Code: ${response.statusCode}');
```

### **Verificación de Conectividad:**
```dart
// Verificar si el backend responde
try {
  final response = await _dio.get('/health');
  print('✅ Backend responde correctamente');
} catch (e) {
  print('❌ Backend no responde: $e');
}
```

### **Auto-fix para Coaches:**
```dart
// Intentar activar coach automáticamente
try {
  await _dio.post('/identity/v1/usuarios/fix-coaches-estado', data: {});
  print('✅ Auto-fix ejecutado exitosamente');
} catch (e) {
  print('❌ Auto-fix falló: $e');
}
```

---

## 🎯 **PRÓXIMOS PASOS**

### **Inmediatos:**
1. ✅ **Implementar retry automático** para errores de red
2. ✅ **Mejorar mensajes de error** para el usuario
3. ✅ **Validar datos** antes de enviar al backend

### **Futuros:**
1. 📊 **Dashboard de errores** para monitoreo
2. 📱 **Notificaciones push** para errores críticos
3. 🔄 **Recuperación automática** de errores comunes

---

## 📞 **CONTACTO Y SOPORTE**

**Para errores técnicos:**
- Revisar logs de consola
- Verificar conectividad a internet
- Contactar al equipo de backend

**Para errores de permisos:**
- Verificar rol del usuario
- Contactar al administrador del sistema
- Revisar configuración de permisos

---

*Última actualización: Enero 2025*
*Versión del documento: 1.0.0* 